import { Task } from '../Model/DailyTask';
import { TaskType } from '../Model/Enum';
import { RemindTime } from '../Model/RemindTimeBase';
import { taskStore } from '../Model/TaskStore';
import { courseStore } from '../Model/CourseStore';
import {
  AgentCreateTaskArgs,
  AgentDeleteTaskArgs,
  AgentReminderPayload,
  AgentScheduleCreatePayload,
  AgentScheduleDeletePayload,
  AgentScheduleLocatorPayload,
  AgentScheduleUpdateChangesPayload,
  AgentScheduleUpdatePayload,
  AgentTaskCandidateOption,
  AgentTaskOperationResult,
  AgentTimePayload,
  AgentUpdateTaskArgs
} from '../Model/AgentModels';
import { AgentJsonHelper } from './AgentJsonHelper';
import { AgentLogger } from './AgentLogger';
import { AgentTimeBlock, AgentTimeHelper } from './AgentTimeHelper';

class AgentTaskRecord {
  task: Task = new Task();
  date: Date = new Date();
}

export class TaskOperationService {
  private static readonly SCOPE: string = 'TaskOperationService';
  private static readonly LOG_SCH_MATCH: string = 'SCH.MATCH';
  private static readonly LOG_SCH_CREATE: string = 'SCH.CREATE';
  private static readonly LOG_SCH_UPDATE: string = 'SCH.UPDATE';
  private static readonly LOG_SCH_DELETE: string = 'SCH.DELETE';

  public static createTask(args: AgentCreateTaskArgs): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    const date: Date | null = AgentTimeHelper.parseDateText(args.date);
    if (date === null) {
      result.userText = '创建失败，日期格式不正确。';
      return result;
    }
    const startBlock: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(args.startTime);
    const endBlock: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(args.endTime);
    if (startBlock === null || endBlock === null) {
      result.userText = '创建失败，时间格式不正确。';
      return result;
    }
    if (endBlock.startMinute <= startBlock.startMinute) {
      result.userText = '创建失败，结束时间需要晚于开始时间。';
      return result;
    }
    const title: string = args.title.trim();
    if (title.length === 0) {
      result.userText = '创建失败，缺少日程主题。';
      return result;
    }
    const location: string = TaskOperationService.normalizeLocation(args.location);
    const detail: string = TaskOperationService.normalizeDetail(args.detail, title);
    const conflictText: string = TaskOperationService.detectConflict(date, startBlock.startMinute, endBlock.startMinute, '');
    if (conflictText.length > 0) {
      result.userText = conflictText;
      return result;
    }
    const task: Task = new Task();
    task.setTitle(title);
    task.setSelectedDate(date);
    task.setBeginHour(Math.floor(startBlock.startMinute / 60));
    task.setBeginMinute(startBlock.startMinute % 60);
    task.setEndHour(Math.floor(endBlock.startMinute / 60));
    task.setEndMinute(endBlock.startMinute % 60);
    task.setIsSelectedEndTime(true);
    task.setLocation(location);
    task.setDetail(detail);
    task.setRemindTime([]);
    task.setTaskType(TaskOperationService.inferTaskType(title + ' ' + detail));
    const addSuccess: boolean = taskStore.addTask(date.getFullYear(), date.getMonth() + 1, date.getDate(), task);
    if (!addSuccess) {
      result.userText = '创建失败，未能写入日程。';
      AgentLogger.error(TaskOperationService.SCOPE, 'createTask save failed title=' + title);
      return result;
    }
    result.success = true;
    result.taskId = task.getId();
    result.taskDate = AgentTimeHelper.formatDate(date);
    result.userText = '创建成功，已切到对应日期的日视图。';
    TaskOperationService.notifyReloadTask();
    AgentLogger.info(TaskOperationService.SCOPE, 'createTask success id=' + result.taskId);
    return result;
  }

  public static updateTask(args: AgentUpdateTaskArgs): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    const record: AgentTaskRecord | null = TaskOperationService.findTask(args.query.date, args.query.title);
    if (record === null) {
      result.userText = '未找到要修改的日程，请提供更准确的日期或标题。';
      return result;
    }
    const targetDate: Date = TaskOperationService.resolvePatchDate(record.date, args.patch.date);
    const startMinute: number = TaskOperationService.resolvePatchMinute(record.task.getBeginHour(),
      record.task.getBeginMinute(), args.patch.startTime);
    const endMinute: number = TaskOperationService.resolvePatchMinute(record.task.getEndHour(),
      record.task.getEndMinute(), args.patch.endTime);
    if (startMinute < 0 || endMinute < 0) {
      result.userText = '修改失败，时间格式不正确。';
      return result;
    }
    if (endMinute <= startMinute) {
      result.userText = '修改失败，结束时间需要晚于开始时间。';
      return result;
    }
    const title: string = args.patch.title.trim().length > 0 ? args.patch.title.trim() : record.task.getTitle();
    const location: string = args.patch.location.trim().length > 0 ? TaskOperationService.normalizeLocation(args.patch.location) :
      record.task.getLocation();
    const detail: string = args.patch.detail.trim().length > 0 ? TaskOperationService.normalizeDetail(args.patch.detail, title) :
      record.task.getDetail();
    const conflictText: string = TaskOperationService.detectConflict(targetDate, startMinute, endMinute, record.task.getId());
    if (conflictText.length > 0) {
      result.userText = conflictText;
      return result;
    }

    if (AgentTimeHelper.isSameDate(record.date, targetDate)) {
      const updatedTask: Task = TaskOperationService.copyTask(record.task);
      updatedTask.setTitle(title);
      updatedTask.setSelectedDate(targetDate);
      updatedTask.setBeginHour(Math.floor(startMinute / 60));
      updatedTask.setBeginMinute(startMinute % 60);
      updatedTask.setEndHour(Math.floor(endMinute / 60));
      updatedTask.setEndMinute(endMinute % 60);
      updatedTask.setIsSelectedEndTime(true);
      updatedTask.setLocation(location);
      updatedTask.setDetail(detail);
      updatedTask.setTaskType(TaskOperationService.inferTaskType(title + ' ' + detail));
      const success: boolean = taskStore.updateTask(targetDate.getFullYear(), targetDate.getMonth() + 1, targetDate.getDate(),
        updatedTask);
      if (!success) {
        result.userText = '修改失败，未能写入日程。';
        return result;
      }
      result.success = true;
      result.taskId = updatedTask.getId();
      result.taskDate = AgentTimeHelper.formatDate(targetDate);
      result.userText = '修改成功，已切到对应日期的日视图。';
      TaskOperationService.notifyReloadTask();
      return result;
    }

    const deleted: boolean = taskStore.deleteTask(record.date.getFullYear(), record.date.getMonth() + 1, record.date.getDate(),
      record.task);
    if (!deleted) {
      result.userText = '修改失败，旧日程删除失败。';
      return result;
    }
    const movedTask: Task = TaskOperationService.copyTask(record.task);
    movedTask.setId('');
    movedTask.setTitle(title);
    movedTask.setSelectedDate(targetDate);
    movedTask.setBeginHour(Math.floor(startMinute / 60));
    movedTask.setBeginMinute(startMinute % 60);
    movedTask.setEndHour(Math.floor(endMinute / 60));
    movedTask.setEndMinute(endMinute % 60);
    movedTask.setIsSelectedEndTime(true);
    movedTask.setLocation(location);
    movedTask.setDetail(detail);
    movedTask.setTaskType(TaskOperationService.inferTaskType(title + ' ' + detail));
    const addSuccess: boolean = taskStore.addTask(targetDate.getFullYear(), targetDate.getMonth() + 1, targetDate.getDate(), movedTask);
    if (!addSuccess) {
      result.userText = '修改失败，新日程写入失败。';
      return result;
    }
    result.success = true;
    result.taskId = movedTask.getId();
    result.taskDate = AgentTimeHelper.formatDate(targetDate);
    result.userText = '修改成功，已切到对应日期的日视图。';
    TaskOperationService.notifyReloadTask();
    return result;
  }

  public static deleteTask(args: AgentDeleteTaskArgs): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    const record: AgentTaskRecord | null = TaskOperationService.findTask(args.date, args.title);
    if (record === null) {
      result.userText = '未找到要删除的日程。';
      return result;
    }
    const success: boolean = taskStore.deleteTask(record.date.getFullYear(), record.date.getMonth() + 1, record.date.getDate(),
      record.task);
    if (!success) {
      result.userText = '删除失败，请稍后再试。';
      return result;
    }
    result.success = true;
    result.taskDate = AgentTimeHelper.formatDate(record.date);
    result.userText = '删除成功，已更新日程列表。';
    TaskOperationService.notifyReloadTask();
    return result;
  }

  public static describeDeleteTarget(args: AgentDeleteTaskArgs): string {
    const title: string = args.title.trim().length > 0 ? args.title.trim() : '该日程';
    const date: string = args.date.trim();
    if (date.length > 0) {
      return date + ' 的“' + title + '”';
    }
    return '“' + title + '”';
  }

  private static notifyReloadTask(): void {
    const currentValue: boolean = Boolean(AppStorage.get('reloadTask') ?? false);
    AppStorage.setOrCreate('reloadTask', !currentValue);
  }

  private static resolvePatchDate(originDate: Date, dateText: string): Date {
    if (dateText.trim().length === 0) {
      return new Date(originDate.getFullYear(), originDate.getMonth(), originDate.getDate());
    }
    const parsed: Date | null = AgentTimeHelper.parseDateText(dateText);
    if (parsed === null) {
      return new Date(originDate.getFullYear(), originDate.getMonth(), originDate.getDate());
    }
    return parsed;
  }

  private static resolvePatchMinute(originHour: number, originMinute: number, timeText: string): number {
    if (timeText.trim().length === 0) {
      return originHour * 60 + originMinute;
    }
    const parsed: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(timeText);
    if (parsed === null) {
      return -1;
    }
    return parsed.startMinute;
  }

  private static copyTask(source: Task): Task {
    const target: Task = new Task();
    target.setId(source.getId());
    target.setTitle(source.getTitle());
    target.setSelectedDate(new Date(source.getSelectedDate().getFullYear(), source.getSelectedDate().getMonth(),
      source.getSelectedDate().getDate()));
    target.setBeginHour(source.getBeginHour());
    target.setBeginMinute(source.getBeginMinute());
    target.setEndHour(source.getEndHour());
    target.setEndMinute(source.getEndMinute());
    target.setIsSelectedEndTime(source.getIsSelectedEndTime());
    target.setLocation(source.getLocation());
    target.setDetail(source.getDetail());
    target.setRemindTime(source.getRemindTime());
    target.setTaskType(source.getTaskType());
    return target;
  }

  private static findTask(dateText: string, titleText: string): AgentTaskRecord | null {
    const date: Date | null = AgentTimeHelper.parseDateText(dateText);
    if (date === null) {
      return null;
    }
    const tasks: Array<Task> = taskStore.getTask(date.getFullYear(), date.getMonth() + 1, date.getDate());
    const normalizedTitle: string = titleText.trim();
    let fuzzyMatch: Task | null = null;
    for (let index: number = 0; index < tasks.length; index++) {
      const task: Task = tasks[index];
      if (task.getTitle() === normalizedTitle) {
        const record: AgentTaskRecord = new AgentTaskRecord();
        record.task = task;
        record.date = date;
        return record;
      }
      if (normalizedTitle.length > 0 && task.getTitle().indexOf(normalizedTitle) >= 0) {
        if (fuzzyMatch === null) {
          fuzzyMatch = task;
        } else {
          fuzzyMatch = null;
          break;
        }
      }
    }
    if (fuzzyMatch !== null) {
      const record: AgentTaskRecord = new AgentTaskRecord();
      record.task = fuzzyMatch;
      record.date = date;
      return record;
    }
    return null;
  }

  private static detectConflict(date: Date, startMinute: number, endMinute: number, excludeTaskId: string): string {
    const tasks: Array<Task> = taskStore.getTask(date.getFullYear(), date.getMonth() + 1, date.getDate());
    for (let index: number = 0; index < tasks.length; index++) {
      const task: Task = tasks[index];
      if (excludeTaskId.length > 0 && task.getId() === excludeTaskId) {
        continue;
      }
      const busyStart: number = task.getBeginHour() * 60 + task.getBeginMinute();
      const busyEnd: number = task.getEndHour() * 60 + task.getEndMinute();
      if (TaskOperationService.isOverlap(startMinute, endMinute, busyStart, busyEnd)) {
        return '创建失败，与现有日程“' + task.getTitle() + '”时间冲突。';
      }
    }
    const courses = courseStore.getCoursesByDate(date);
    for (let index: number = 0; index < courses.length; index++) {
      const course = courses[index];
      const startBlock: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(course.getStartTimeText());
      const endBlock: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(course.getEndTimeText());
      if (startBlock === null || endBlock === null) {
        continue;
      }
      if (TaskOperationService.isOverlap(startMinute, endMinute, startBlock.startMinute, endBlock.startMinute)) {
        return '创建失败，与课程“' + course.getCourseName() + '”时间冲突。';
      }
    }
    return '';
  }

  private static isOverlap(startA: number, endA: number, startB: number, endB: number): boolean {
    return Math.max(startA, startB) < Math.min(endA, endB);
  }

  private static normalizeLocation(locationText: string): string {
    const value: string = locationText.trim();
    return value.length > 0 ? value : '待定';
  }

  private static normalizeDetail(detailText: string, title: string): string {
    const value: string = detailText.trim();
    return value.length > 0 ? value : title;
  }

  public static createTaskFromPayload(payloadText: string): AgentTaskOperationResult {
    const args: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(payloadText);
    return TaskOperationService.createTaskFromStructured(args);
  }

  public static updateTaskFromPayload(payloadText: string): AgentTaskOperationResult {
    const args: AgentScheduleUpdatePayload = AgentJsonHelper.parseScheduleUpdatePayload(payloadText);
    return TaskOperationService.updateTaskFromStructured(args);
  }

  public static deleteTaskFromPayload(payloadText: string): AgentTaskOperationResult {
    const args: AgentScheduleDeletePayload = AgentJsonHelper.parseScheduleDeletePayload(payloadText);
    return TaskOperationService.deleteTaskFromStructured(args);
  }

  public static listUpdateCandidatesFromPayload(payloadText: string): Array<AgentTaskCandidateOption> {
    const args: AgentScheduleUpdatePayload = AgentJsonHelper.parseScheduleUpdatePayload(payloadText);
    return TaskOperationService.buildCandidateOptions(TaskOperationService.findTasksByLocator(args.locator));
  }

  public static listDeleteCandidatesFromPayload(payloadText: string): Array<AgentTaskCandidateOption> {
    const args: AgentScheduleDeletePayload = AgentJsonHelper.parseScheduleDeletePayload(payloadText);
    return TaskOperationService.buildCandidateOptions(TaskOperationService.findTasksByLocator(args.locator));
  }

  public static updateTaskFromPayloadWithTaskIds(payloadText: string, taskIdList: Array<string>): AgentTaskOperationResult {
    const args: AgentScheduleUpdatePayload = AgentJsonHelper.parseScheduleUpdatePayload(payloadText);
    return TaskOperationService.updateTasksFromStructured(args, taskIdList);
  }

  public static deleteTaskFromPayloadWithTaskIds(payloadText: string, taskIdList: Array<string>): AgentTaskOperationResult {
    const args: AgentScheduleDeletePayload = AgentJsonHelper.parseScheduleDeletePayload(payloadText);
    return TaskOperationService.deleteTasksFromStructured(args, taskIdList);
  }

  private static createTaskFromStructured(args: AgentScheduleCreatePayload): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    AgentLogger.info(TaskOperationService.LOG_SCH_CREATE,
      'create start title=' + args.title.trim() + ' date=' + args.time.resolvedDate.trim() +
      ' start=' + args.time.startDateTime.trim() + ' end=' + args.time.endDateTime.trim() +
      ' location=' + args.location.trim() + ' category=' + args.category.trim() +
      ' reminder=' + (args.reminder.enabled ? args.reminder.minutesBefore.toString() : 'off') +
      ' missing=' + args.missingFields.join(','));
    if (args.needsFollowUp || args.missingFields.length > 0) {
      result.userText = '创建失败，信息仍不完整。';
      return result;
    }
    if (args.location.trim().length === 0) {
      result.userText = '创建失败，缺少地点信息。';
      return result;
    }
    if (args.category.trim().length === 0) {
      result.userText = '创建失败，缺少日程类型。';
      return result;
    }
    const dateText: string = args.time.resolvedDate.trim().length > 0 ? args.time.resolvedDate :
      args.time.startDateTime.trim().substring(0, 10);
    const startTime: string = TaskOperationService.extractTimePart(args.time.startDateTime);
    const endTime: string = TaskOperationService.extractTimePart(args.time.endDateTime);
    if (dateText.trim().length === 0 || startTime.trim().length === 0 || endTime.trim().length === 0) {
      result.userText = '创建失败，时间信息仍不完整。';
      return result;
    }
    const legacyArgs: AgentCreateTaskArgs = new AgentCreateTaskArgs();
    legacyArgs.title = args.title;
    legacyArgs.date = dateText;
    legacyArgs.startTime = startTime;
    legacyArgs.endTime = endTime;
    legacyArgs.location = args.location;
    legacyArgs.detail = args.note;
    const legacyResult: AgentTaskOperationResult = TaskOperationService.createTask(legacyArgs);
    if (!legacyResult.success) {
      AgentLogger.warn(TaskOperationService.LOG_SCH_CREATE, 'create failed at legacyCreate reason=' + legacyResult.userText);
      return legacyResult;
    }
    const record: AgentTaskRecord | null = TaskOperationService.findTask(dateText, args.title);
    if (record !== null) {
      record.task.setTaskType(TaskOperationService.resolveTaskTypeByCategory(args.category, args.title + ' ' + args.note));
      record.task.setRemindTime(TaskOperationService.buildReminderList(args.reminder));
      const updateSuccess: boolean = taskStore.updateTask(record.date.getFullYear(), record.date.getMonth() + 1, record.date.getDate(), record.task);
      if (!updateSuccess) {
        legacyResult.success = false;
        legacyResult.userText = '创建失败，日程附加信息写入失败。';
        AgentLogger.error(TaskOperationService.LOG_SCH_CREATE,
          'create failed at attachWrite taskId=' + record.task.getId() + ' date=' + AgentTimeHelper.formatDate(record.date));
        return legacyResult;
      }
    }
    legacyResult.affectedCount = 1;
    AgentLogger.info(TaskOperationService.LOG_SCH_CREATE, 'create success taskId=' + legacyResult.taskId + ' date=' + legacyResult.taskDate);
    return legacyResult;
  }

  private static updateTaskFromStructured(args: AgentScheduleUpdatePayload): AgentTaskOperationResult {
    return TaskOperationService.updateTasksFromStructured(args, []);
  }

  private static updateTasksFromStructured(args: AgentScheduleUpdatePayload, taskIdList: Array<string>): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    AgentLogger.info(TaskOperationService.LOG_SCH_UPDATE,
      'update start locatorTitle=' + args.locator.titleKeywords.join(',') + ' locatorLoc=' + args.locator.locationKeywords.join(',') +
      ' locatorNote=' + args.locator.noteKeywords.join(',') + ' locatorCategory=' + args.locator.category.trim() +
      ' locatorReminder=' + args.locator.reminderMinutes.toString() +
      ' locatorDate=' + args.locator.time.resolvedDate.trim() + ' locatorStart=' + args.locator.time.startDateTime.trim() +
      ' locatorEnd=' + args.locator.time.endDateTime.trim() +
      ' changeTitle=' + args.changes.title.trim() + ' changeLoc=' + args.changes.location.trim() +
      ' changeNoteLen=' + args.changes.note.trim().length.toString() +
      ' changeCategory=' + args.changes.category.trim() +
      ' changeReminder=' + (args.changes.reminder.enabled ? args.changes.reminder.minutesBefore.toString() : 'no') +
      ' changeDate=' + args.changes.time.resolvedDate.trim() + ' changeStart=' + args.changes.time.startDateTime.trim() +
      ' changeEnd=' + args.changes.time.endDateTime.trim() +
      ' pickedIds=' + taskIdList.length.toString());
    if (args.needsFollowUp || args.missingFields.length > 0) {
      result.userText = '修改失败，信息仍不完整。';
      return result;
    }
    if (!TaskOperationService.hasEffectiveChanges(args.changes)) {
      result.userText = '修改失败，未识别到新的修改内容。';
      AgentLogger.warn(TaskOperationService.LOG_SCH_UPDATE, 'update aborted reason=no_effective_changes');
      return result;
    }
    const records: Array<AgentTaskRecord> = TaskOperationService.filterSelectedRecords(TaskOperationService.findTasksByLocator(args.locator), taskIdList);
    AgentLogger.info(TaskOperationService.LOG_SCH_MATCH, 'update matched candidates=' + records.length.toString());
    if (records.length === 0) {
      result.userText = '未找到要修改的日程，请提供更准确的标题、备注、地点或时间。';
      return result;
    }
    let affectedCount: number = 0;
    let focusTaskId: string = '';
    let focusTaskDate: string = '';
    for (let index: number = 0; index < records.length; index++) {
      const singleResult: AgentTaskOperationResult = TaskOperationService.updateSingleRecord(records[index], args.changes);
      if (!singleResult.success) {
        return singleResult;
      }
      if (focusTaskId.length === 0) {
        focusTaskId = singleResult.taskId;
        focusTaskDate = singleResult.taskDate;
      }
      affectedCount++;
    }
    result.success = true;
    result.taskId = focusTaskId;
    result.taskDate = focusTaskDate;
    result.affectedCount = affectedCount;
    result.userText = affectedCount > 1 ? '修改成功，已更新 ' + affectedCount.toString() + ' 个日程。' : '修改成功，已更新对应日程。';
    AgentLogger.info(TaskOperationService.LOG_SCH_UPDATE,
      'update success affected=' + affectedCount.toString() + ' focusTaskId=' + result.taskId + ' date=' + result.taskDate);
    TaskOperationService.notifyReloadTask();
    return result;
  }

  private static updateSingleRecord(record: AgentTaskRecord, changes: AgentScheduleUpdateChangesPayload): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    const targetDate: Date = TaskOperationService.resolveStructuredDate(record.date, changes.time);
    const startMinute: number = TaskOperationService.resolveStructuredStartMinute(record.task, changes.time);
    const endMinute: number = TaskOperationService.resolveStructuredEndMinute(record.task, changes.time);
    if (startMinute < 0 || endMinute < 0) {
      result.userText = '修改失败，时间格式不正确。';
      return result;
    }
    if (endMinute <= startMinute) {
      result.userText = '修改失败，结束时间需要晚于开始时间。';
      return result;
    }
    const shouldCheckConflict: boolean = !AgentTimeHelper.isSameDate(record.date, targetDate) ||
      startMinute !== record.task.getBeginHour() * 60 + record.task.getBeginMinute() ||
      endMinute !== record.task.getEndHour() * 60 + record.task.getEndMinute();
    if (shouldCheckConflict) {
      const conflictText: string = TaskOperationService.detectConflict(targetDate, startMinute, endMinute, record.task.getId());
      if (conflictText.length > 0) {
        result.userText = conflictText.replace('创建失败', '修改失败');
        return result;
      }
    }
    const updatedTask: Task = TaskOperationService.copyTask(record.task);
    if (changes.title.trim().length > 0) {
      updatedTask.setTitle(changes.title.trim());
    }
    updatedTask.setSelectedDate(targetDate);
    updatedTask.setBeginHour(Math.floor(startMinute / 60));
    updatedTask.setBeginMinute(startMinute % 60);
    updatedTask.setEndHour(Math.floor(endMinute / 60));
    updatedTask.setEndMinute(endMinute % 60);
    if (changes.location.trim().length > 0) {
      updatedTask.setLocation(changes.location.trim());
    }
    if (changes.note.trim().length > 0) {
      updatedTask.setDetail(changes.note.trim());
    }
    if (changes.category.trim().length > 0) {
      updatedTask.setTaskType(TaskOperationService.resolveTaskTypeByCategory(changes.category, updatedTask.getTitle() + ' ' + updatedTask.getDetail()));
    }
    if (changes.reminder.enabled || changes.reminder.minutesBefore >= 0) {
      updatedTask.setRemindTime(TaskOperationService.buildReminderList(changes.reminder));
    }
    if (AgentTimeHelper.isSameDate(record.date, targetDate)) {
      const success: boolean = taskStore.updateTask(targetDate.getFullYear(), targetDate.getMonth() + 1, targetDate.getDate(), updatedTask);
      if (!success) {
        result.userText = '修改失败，未能写入日程。';
        return result;
      }
    } else {
      const deleted: boolean = taskStore.deleteTask(record.date.getFullYear(), record.date.getMonth() + 1, record.date.getDate(), record.task);
      if (!deleted) {
        result.userText = '修改失败，旧日程删除失败。';
        return result;
      }
      updatedTask.setId('');
      const addSuccess: boolean = taskStore.addTask(targetDate.getFullYear(), targetDate.getMonth() + 1, targetDate.getDate(), updatedTask);
      if (!addSuccess) {
        result.userText = '修改失败，新日程写入失败。';
        return result;
      }
    }
    result.success = true;
    result.taskId = updatedTask.getId();
    result.taskDate = AgentTimeHelper.formatDate(targetDate);
    result.affectedCount = 1;
    return result;
  }

  private static deleteTaskFromStructured(args: AgentScheduleDeletePayload): AgentTaskOperationResult {
    return TaskOperationService.deleteTasksFromStructured(args, []);
  }

  private static deleteTasksFromStructured(args: AgentScheduleDeletePayload, taskIdList: Array<string>): AgentTaskOperationResult {
    const result: AgentTaskOperationResult = new AgentTaskOperationResult();
    AgentLogger.info(TaskOperationService.LOG_SCH_DELETE,
      'delete start locatorTitle=' + args.locator.titleKeywords.join(',') + ' locatorLoc=' + args.locator.locationKeywords.join(',') +
      ' locatorNote=' + args.locator.noteKeywords.join(',') + ' locatorCategory=' + args.locator.category.trim() +
      ' locatorReminder=' + args.locator.reminderMinutes.toString() +
      ' locatorDate=' + args.locator.time.resolvedDate.trim() + ' locatorStart=' + args.locator.time.startDateTime.trim() +
      ' locatorEnd=' + args.locator.time.endDateTime.trim() +
      ' pickedIds=' + taskIdList.length.toString());
    if (args.needsFollowUp || args.missingFields.length > 0) {
      result.userText = '删除失败，信息仍不完整。';
      return result;
    }
    const records: Array<AgentTaskRecord> = TaskOperationService.filterSelectedRecords(TaskOperationService.findTasksByLocator(args.locator), taskIdList);
    AgentLogger.info(TaskOperationService.LOG_SCH_MATCH, 'delete matched candidates=' + records.length.toString());
    if (records.length === 0) {
      result.userText = '未找到要删除的日程。';
      return result;
    }
    let deletedCount: number = 0;
    let taskDate: string = '';
    for (let index: number = 0; index < records.length; index++) {
      const record: AgentTaskRecord = records[index];
      const success: boolean = taskStore.deleteTask(record.date.getFullYear(), record.date.getMonth() + 1, record.date.getDate(), record.task);
      if (!success) {
        result.userText = '删除失败，请稍后再试。';
        return result;
      }
      if (taskDate.length === 0) {
        taskDate = AgentTimeHelper.formatDate(record.date);
      }
      deletedCount++;
    }
    result.success = true;
    result.taskDate = taskDate;
    result.affectedCount = deletedCount;
    result.userText = deletedCount > 1 ? '删除成功，已删除 ' + deletedCount.toString() + ' 个日程。' : '删除成功，已更新日程列表。';
    AgentLogger.info(TaskOperationService.LOG_SCH_DELETE,
      'delete success affected=' + deletedCount.toString() + ' date=' + result.taskDate);
    TaskOperationService.notifyReloadTask();
    return result;
  }

  private static findTaskByLocator(locator: AgentScheduleLocatorPayload): AgentTaskRecord | null {
    const records: Array<AgentTaskRecord> = TaskOperationService.findTasksByLocator(locator);
    return records.length > 0 ? records[0] : null;
  }

  private static findTasksByLocator(locator: AgentScheduleLocatorPayload): Array<AgentTaskRecord> {
    const result: Array<AgentTaskRecord> = [];
    const dateList: Array<Date> = TaskOperationService.resolveLocatorDates(locator.time);
    const titleKeywords: Array<string> = TaskOperationService.cleanScheduleKeywordList(locator.titleKeywords);
    const locationKeywords: Array<string> = TaskOperationService.cleanLocationKeywordList(locator.locationKeywords);
    const noteKeywords: Array<string> = TaskOperationService.cleanScheduleKeywordList(locator.noteKeywords);
    const categoryText: string = locator.category.trim();
    const reminderMinutes: number = locator.reminderMinutes;
    AgentLogger.info(TaskOperationService.LOG_SCH_MATCH,
      'match start dates=' + dateList.length.toString() +
      ' title=' + titleKeywords.join(',') + ' loc=' + locationKeywords.join(',') +
      ' note=' + noteKeywords.join(',') + ' category=' + categoryText +
      ' reminder=' + reminderMinutes.toString() +
      ' date=' + locator.time.resolvedDate.trim() + ' start=' + locator.time.startDateTime.trim() +
      ' end=' + locator.time.endDateTime.trim());
    for (let dateIndex: number = 0; dateIndex < dateList.length; dateIndex++) {
      const date: Date = dateList[dateIndex];
      const tasks: Array<Task> = taskStore.getTask(date.getFullYear(), date.getMonth() + 1, date.getDate());
      for (let index: number = 0; index < tasks.length; index++) {
        const task: Task = tasks[index];
        const titleText: string = task.getTitle().toLowerCase();
        const locationText: string = task.getLocation().toLowerCase();
        const detailText: string = task.getDetail().toLowerCase();
        if (!TaskOperationService.matchKeywords(titleText, titleKeywords)) {
          continue;
        }
        if (!TaskOperationService.matchKeywords(locationText, locationKeywords)) {
          continue;
        }
        if (!TaskOperationService.matchKeywords(detailText, noteKeywords)) {
          continue;
        }
        if (categoryText.length > 0 && !TaskOperationService.matchTaskCategory(task, categoryText)) {
          continue;
        }
        if (reminderMinutes >= 0 && !TaskOperationService.matchTaskReminder(task, reminderMinutes)) {
          continue;
        }
        if (!TaskOperationService.matchTaskTimeWindow(task, locator.time)) {
          continue;
        }
        const record: AgentTaskRecord = new AgentTaskRecord();
        record.task = task;
        record.date = date;
        result.push(record);
      }
    }
    if (result.length > 0) {
      AgentLogger.info(TaskOperationService.LOG_SCH_MATCH, 'match done count=' + result.length.toString());
    } else {
      AgentLogger.warn(TaskOperationService.LOG_SCH_MATCH, 'match done count=0');
    }
    return result;
  }

  private static buildCandidateOptions(records: Array<AgentTaskRecord>): Array<AgentTaskCandidateOption> {
    const result: Array<AgentTaskCandidateOption> = [];
    for (let index: number = 0; index < records.length; index++) {
      const item: AgentTaskCandidateOption = new AgentTaskCandidateOption();
      item.taskId = records[index].task.getId();
      item.taskDate = AgentTimeHelper.formatDate(records[index].date);
      item.summaryText = TaskOperationService.describeTaskRecord(records[index]);
      result.push(item);
    }
    return result;
  }

  private static filterSelectedRecords(records: Array<AgentTaskRecord>, taskIdList: Array<string>): Array<AgentTaskRecord> {
    if (taskIdList.length === 0) {
      return records;
    }
    const result: Array<AgentTaskRecord> = [];
    for (let index: number = 0; index < records.length; index++) {
      if (taskIdList.indexOf(records[index].task.getId()) >= 0) {
        result.push(records[index]);
      }
    }
    return result;
  }

  private static hasTimeChange(changes: AgentScheduleUpdateChangesPayload): boolean {
    return changes.time.resolvedDate.trim().length > 0 || changes.time.startDateTime.trim().length > 0 || changes.time.endDateTime.trim().length > 0;
  }

  private static hasEffectiveChanges(changes: AgentScheduleUpdateChangesPayload): boolean {
    if (changes.title.trim().length > 0) {
      return true;
    }
    if (changes.location.trim().length > 0) {
      return true;
    }
    if (changes.note.trim().length > 0) {
      return true;
    }
    if (changes.category.trim().length > 0) {
      return true;
    }
    if (changes.reminder.enabled || changes.reminder.minutesBefore >= 0) {
      return true;
    }
    return TaskOperationService.hasTimeChange(changes);
  }

  private static describeTaskRecord(record: AgentTaskRecord): string {
    const beginTime: string = AgentTimeHelper.minuteToText(record.task.getBeginHour() * 60 + record.task.getBeginMinute());
    const endTime: string = AgentTimeHelper.minuteToText(record.task.getEndHour() * 60 + record.task.getEndMinute());
    const locationText: string = record.task.getLocation().trim().length > 0 ? '，地点：' + record.task.getLocation().trim() : '';
    return AgentTimeHelper.formatDate(record.date) + ' ' + beginTime + '-' + endTime + ' ' + record.task.getTitle() + locationText;
  }

  private static matchTaskCategory(task: Task, categoryText: string): boolean {
    const normalizedText: string = categoryText.trim();
    if (normalizedText.length === 0) {
      return true;
    }
    const taskTypeText: string = task.getTaskType().toString();
    if (taskTypeText === normalizedText) {
      return true;
    }
    if (normalizedText === '工作' && taskTypeText === 'Work') {
      return true;
    }
    if (normalizedText === '生活' && taskTypeText === 'life') {
      return true;
    }
    if (normalizedText === '娱乐' && taskTypeText === 'Entertainment') {
      return true;
    }
    if (normalizedText === '自律' && taskTypeText === 'Self_discipline') {
      return true;
    }
    return false;
  }

  private static matchTaskReminder(task: Task, reminderMinutes: number): boolean {
    const remindList: Array<RemindTime> = task.getRemindTime();
    for (let index: number = 0; index < remindList.length; index++) {
      if (remindList[index].toMinutes() === reminderMinutes) {
        return true;
      }
    }
    return false;
  }

  private static matchTaskTimeWindow(task: Task, time: AgentTimePayload): boolean {
    const startMinute: number = TaskOperationService.extractStartMinute(time);
    const endMinute: number = TaskOperationService.extractEndMinute(time);
    if (startMinute < 0 && endMinute < 0) {
      return true;
    }
    const taskStartMinute: number = task.getBeginHour() * 60 + task.getBeginMinute();
    const taskEndMinute: number = task.getEndHour() * 60 + task.getEndMinute();
    let effectiveStartMinute: number = startMinute >= 0 ? startMinute : 0;
    let effectiveEndMinute: number = endMinute >= 0 ? endMinute : 24 * 60;
    if (effectiveEndMinute <= effectiveStartMinute && endMinute >= 0) {
      effectiveEndMinute = Math.min(24 * 60, effectiveStartMinute + 1);
    }
    return taskStartMinute < effectiveEndMinute && taskEndMinute > effectiveStartMinute;
  }

  private static hasFuzzyTimeText(time: AgentTimePayload): boolean {
    const sourceText: string = time.originalText.trim();
    if (sourceText.length === 0) {
      return false;
    }
    return sourceText.indexOf('点多') >= 0 || sourceText.indexOf('左右') >= 0 || sourceText.indexOf('附近') >= 0 ||
      sourceText.indexOf('前后') >= 0 || sourceText.indexOf('之间') >= 0;
  }

  private static extractStartMinute(time: AgentTimePayload): number {
    if (time.startDateTime.trim().length >= 16) {
      return TaskOperationService.extractMinute(time.startDateTime.substring(11, 16));
    }
    return -1;
  }

  private static extractEndMinute(time: AgentTimePayload): number {
    if (time.endDateTime.trim().length >= 16) {
      return TaskOperationService.extractMinute(time.endDateTime.substring(11, 16));
    }
    const startMinute: number = TaskOperationService.extractStartMinute(time);
    if (startMinute >= 0 && TaskOperationService.hasFuzzyTimeText(time)) {
      return Math.min(startMinute + 60, 24 * 60);
    }
    return -1;
  }

  private static resolveLocatorDates(time: AgentTimePayload): Array<Date> {
    if (!TaskOperationService.hasConcreteDate(time)) {
      return TaskOperationService.buildDefaultLocatorDates();
    }
    const result: Array<Date> = [];
    const startDate: Date = TaskOperationService.resolveLocatorDate(time);
    let endDate: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    if (time.endDateTime.trim().length >= 10) {
      const parsed: Date | null = AgentTimeHelper.parseDateText(time.endDateTime.substring(0, 10));
      if (parsed !== null) {
        endDate = parsed;
      }
    }
    if (endDate.getTime() < startDate.getTime()) {
      endDate = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    }
    const cursor: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    while (cursor.getTime() <= endDate.getTime()) {
      result.push(new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate()));
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  private static hasConcreteDate(time: AgentTimePayload): boolean {
    if (time.resolvedDate.trim().length > 0) {
      return true;
    }
    if (time.originalText.trim().length > 0) {
      return TaskOperationService.containsConcreteDateHint(time.originalText);
    }
    return time.startDateTime.trim().length >= 10 || time.endDateTime.trim().length >= 10;
  }

  private static containsConcreteDateHint(text: string): boolean {
    const value: string = text.trim();
    if (value.length === 0) {
      return false;
    }
    return /(今天|明天|后天|昨天|前天|大后天|大前天|本周|这周|下周|上周|周[一二三四五六日天]|星期[一二三四五六日天]|\d{4}[-\/]\d{1,2}[-\/]\d{1,2}|\d{1,2}月\d{1,2}日|\d{1,2}号)/.test(value);
  }

  private static buildDefaultLocatorDates(): Array<Date> {
    const result: Array<Date> = [];
    const today: Date = AgentTimeHelper.cloneDateOnly(new Date());
    const startDate: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 365);
    const endDate: Date = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 365);
    const cursor: Date = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    while (cursor.getTime() <= endDate.getTime()) {
      result.push(new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate()));
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  private static resolveLocatorDate(time: AgentTimePayload): Date {
    if (time.resolvedDate.trim().length > 0) {
      const parsed: Date | null = AgentTimeHelper.parseDateText(time.resolvedDate);
      if (parsed !== null) {
        return parsed;
      }
    }
    if (time.startDateTime.trim().length >= 10) {
      const parsed: Date | null = AgentTimeHelper.parseDateText(time.startDateTime.substring(0, 10));
      if (parsed !== null) {
        return parsed;
      }
    }
    return AgentTimeHelper.cloneDateOnly(new Date());
  }

  private static resolveStructuredDate(originDate: Date, time: AgentTimePayload): Date {
    if (time.resolvedDate.trim().length > 0) {
      const parsedResolvedDate: Date | null = AgentTimeHelper.parseDateText(time.resolvedDate);
      if (parsedResolvedDate !== null) {
        return parsedResolvedDate;
      }
    }
    if (time.startDateTime.trim().length >= 10) {
      const parsedStartDate: Date | null = AgentTimeHelper.parseDateText(time.startDateTime.substring(0, 10));
      if (parsedStartDate !== null) {
        return parsedStartDate;
      }
    }
    return new Date(originDate.getFullYear(), originDate.getMonth(), originDate.getDate());
  }

  private static resolveStructuredStartMinute(task: Task, time: AgentTimePayload): number {
    if (time.startDateTime.trim().length >= 16) {
      return TaskOperationService.extractMinute(time.startDateTime.substring(11, 16));
    }
    return task.getBeginHour() * 60 + task.getBeginMinute();
  }

  private static resolveStructuredEndMinute(task: Task, time: AgentTimePayload): number {
    if (time.endDateTime.trim().length >= 16) {
      return TaskOperationService.extractMinute(time.endDateTime.substring(11, 16));
    }
    return task.getEndHour() * 60 + task.getEndMinute();
  }

  private static extractMinute(timeText: string): number {
    const parsed: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(timeText);
    if (parsed === null) {
      return -1;
    }
    return parsed.startMinute;
  }

  private static extractTimePart(dateTimeText: string): string {
    if (dateTimeText.trim().length >= 16) {
      return dateTimeText.substring(11, 16);
    }
    return '';
  }

  private static buildReminderList(reminder: AgentReminderPayload): Array<RemindTime> {
    const list: Array<RemindTime> = [];
    if (!reminder.enabled || reminder.minutesBefore < 0) {
      return list;
    }
    if (reminder.minutesBefore < 60) {
      list.push(new RemindTime(reminder.minutesBefore, '分钟', true));
      return list;
    }
    if (reminder.minutesBefore % 60 === 0 && reminder.minutesBefore < 1440) {
      list.push(new RemindTime(Math.trunc(reminder.minutesBefore / 60), '小时', true));
      return list;
    }
    list.push(new RemindTime(Math.trunc(reminder.minutesBefore / 1440), '天', true));
    return list;
  }

  private static resolveTaskTypeByCategory(category: string, text: string): TaskType {
    if (category === '工作') {
      return TaskType.Work;
    }
    if (category === '生活') {
      return TaskType.life;
    }
    if (category === '娱乐') {
      return TaskType.Entertainment;
    }
    if (category === '自律') {
      return TaskType.Self_discipline;
    }
    return TaskOperationService.inferTaskType(text);
  }

  private static matchKeywords(content: string, keywords: Array<string>): boolean {
    for (let index: number = 0; index < keywords.length; index++) {
      const keyword: string = keywords[index].trim().toLowerCase();
      if (keyword.length === 0) {
        continue;
      }
      if (!TaskOperationService.matchesLooseKeyword(content, keyword)) {
        return false;
      }
    }
    return true;
  }

  private static matchesLooseKeyword(content: string, keyword: string): boolean {
    if (content.indexOf(keyword) >= 0) {
      return true;
    }
    const compactContent: string = TaskOperationService.compactComparableText(content);
    const compactKeyword: string = TaskOperationService.compactComparableText(keyword);
    if (compactKeyword.length === 0) {
      return true;
    }
    if (compactContent.indexOf(compactKeyword) >= 0) {
      return true;
    }
    return TaskOperationService.isOrderedSubsequence(compactContent, compactKeyword);
  }

  private static compactComparableText(text: string): string {
    return text.toLowerCase().replace(/[\s\-_,，。；;：:“”"'（）()【】\[\]]+/g, '');
  }

  private static isOrderedSubsequence(content: string, keyword: string): boolean {
    let contentIndex: number = 0;
    for (let index: number = 0; index < keyword.length; index++) {
      const charText: string = keyword.substring(index, index + 1);
      contentIndex = content.indexOf(charText, contentIndex);
      if (contentIndex < 0) {
        return false;
      }
      contentIndex++;
    }
    return keyword.length > 0;
  }

  private static cleanScheduleKeywordList(keywords: Array<string>): Array<string> {
    const result: Array<string> = [];
    for (let index: number = 0; index < keywords.length; index++) {
      let keyword: string = keywords[index].trim();
      if (keyword.length === 0) {
        continue;
      }
      keyword = keyword.replace(/仍缺少[:：].*$/g, '').replace(/类型为.*日程$/g, '').replace(/请求的补充/g, '')
        .replace(/的?(?:日程|事项|行程).*$/g, '').trim();
      if (/^(在|地点在|地点为|地点是|都在|统一在)/.test(keyword)) {
        continue;
      }
      if (keyword.indexOf('图书馆') >= 0 || keyword.indexOf('食堂') >= 0 || keyword.indexOf('操场') >= 0 ||
        keyword.indexOf('宿舍') >= 0 || keyword.indexOf('教室') >= 0 || keyword.indexOf('楼') >= 0) {
        continue;
      }
      if (keyword.length === 0) {
        continue;
      }
      if (result.indexOf(keyword) < 0) {
        result.push(keyword);
      }
    }
    return result;
  }

  private static cleanLocationKeywordList(keywords: Array<string>): Array<string> {
    const result: Array<string> = [];
    for (let index: number = 0; index < keywords.length; index++) {
      let keyword: string = keywords[index].trim();
      if (keyword.length === 0) {
        continue;
      }
      keyword = keyword.replace(/^(在|地点在|地点为|地点是|都在|统一在)/g, '').replace(/的?(?:日程|事项|行程).*$/g, '')
        .replace(/[、，,.;；。]+$/g, '').trim();
      if (keyword.length === 0) {
        continue;
      }
      if (result.indexOf(keyword) < 0) {
        result.push(keyword);
      }
    }
    return result;
  }

  private static inferTaskType(text: string): TaskType {
    const normalizedText: string = text.toLowerCase();
    if (normalizedText.indexOf('复习') >= 0 || normalizedText.indexOf('自习') >= 0 || normalizedText.indexOf('学习') >= 0 ||
      normalizedText.indexOf('背单词') >= 0 || normalizedText.indexOf('锻炼') >= 0) {
      return TaskType.Self_discipline;
    }
    if (normalizedText.indexOf('聚餐') >= 0 || normalizedText.indexOf('吃饭') >= 0 || normalizedText.indexOf('生活') >= 0 ||
      normalizedText.indexOf('取快递') >= 0 || normalizedText.indexOf('买东西') >= 0) {
      return TaskType.life;
    }
    if (normalizedText.indexOf('玩') >= 0 || normalizedText.indexOf('电影') >= 0 || normalizedText.indexOf('散步') >= 0 ||
      normalizedText.indexOf('看展') >= 0 || normalizedText.indexOf('风景') >= 0) {
      return TaskType.Entertainment;
    }
    return TaskType.Work;
  }
}
