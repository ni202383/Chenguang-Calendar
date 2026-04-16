import { upper_bound } from '../../Utils/ViewUtils';
import { Task, TaskPlain } from './DailyTask';
import { common } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';

export class TaskStore {
  private static readonly PREF_NAME: string = 'task_store';
  private static readonly KEY_DATA: string = 'tasks_json';
  private static readonly LOG_PREFIX: string = '[CHENGGUANG_TASK_STORE]';

  private taskStore: Map<string, Array<Task>> = new Map<string, Array<Task>>();
  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;

  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, TaskStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk(): Promise<void> {
    if (this.pref === undefined) {
      return;
    }
    const json: string = await this.pref.get(TaskStore.KEY_DATA, '') as string;
    this.rebuildFromJsonText(json);
  }

  private ensureSyncPreferences(): boolean {
    if (this.pref !== undefined) {
      return true;
    }
    if (this.context === undefined) {
      console.error(TaskStore.LOG_PREFIX + ' context 未初始化，请先在 EntryAbility 中调用 taskStore.init(this.context)');
      return false;
    }
    try {
      this.pref = dataPreferences.getPreferencesSync(this.context, { name: TaskStore.PREF_NAME });
      return true;
    } catch (error) {
      const err: Error = error as Error;
      console.error(TaskStore.LOG_PREFIX + ' getPreferencesSync 失败: ' + err.message);
      return false;
    }
  }

  private rebuildFromJsonText(json: string): void {
    this.taskStore.clear();
    if (json.trim().length === 0) {
      console.info(TaskStore.LOG_PREFIX + ' load empty');
      return;
    }
    try {
      const objectMap: Record<string, Array<TaskPlain>> = JSON.parse(json) as Record<string, Array<TaskPlain>>;
      const keys: Array<string> = Object.keys(objectMap);
      for (let index: number = 0; index < keys.length; index++) {
        const dateKey: string = keys[index];
        const plainArray: Array<TaskPlain> = objectMap[dateKey] ?? [];
        const taskArray: Array<Task> = [];
        for (let taskIndex: number = 0; taskIndex < plainArray.length; taskIndex++) {
          taskArray.push(Task.fromPlainObject(plainArray[taskIndex]));
        }
        this.sortTaskArray(taskArray);
        this.taskStore.set(dateKey, taskArray);
      }
      this.restoreStaticNumber();
      console.info(TaskStore.LOG_PREFIX + ' load success');
    } catch (error) {
      const err: Error = error as Error;
      console.error(TaskStore.LOG_PREFIX + ' load 失败: ' + err.message);
      this.taskStore.clear();
    }
  }

  private restoreStaticNumber(): void {
    let maxIdNumber: number = 0;
    const valueArrays: Array<Array<Task>> = Array.from(this.taskStore.values());
    for (let index: number = 0; index < valueArrays.length; index++) {
      const taskArray: Array<Task> = valueArrays[index];
      for (let taskIndex: number = 0; taskIndex < taskArray.length; taskIndex++) {
        const taskId: string = taskArray[taskIndex].getId();
        if (taskId.length === 0) {
          continue;
        }
        const parts: Array<string> = taskId.split('-');
        if (parts.length === 0) {
          continue;
        }
        const lastPart: string = parts[parts.length - 1];
        const idNumber: number = Number(lastPart);
        if (!Number.isNaN(idNumber) && idNumber > maxIdNumber) {
          maxIdNumber = idNumber;
        }
      }
    }
    if (typeof Task.static_number === 'number') {
      Task.static_number = Math.max(Task.static_number, maxIdNumber + 1);
    }
  }

  private saveToDiskSync(): boolean {
    if (!this.ensureSyncPreferences()) {
      return false;
    }
    try {
      const keys: Array<string> = Array.from(this.taskStore.keys());
      let json: string = '{';
      for (let index: number = 0; index < keys.length; index++) {
        const key: string = keys[index];
        const sourceArray: Array<Task> = this.taskStore.get(key) ?? [];
        const plainArray: Array<TaskPlain> = [];
        for (let taskIndex: number = 0; taskIndex < sourceArray.length; taskIndex++) {
          plainArray.push(sourceArray[taskIndex].toPlainObject());
        }
        if (index > 0) {
          json += ',';
        }
        json += JSON.stringify(key) + ':' + JSON.stringify(plainArray);
      }
      json += '}';
      this.pref!.putSync(TaskStore.KEY_DATA, json);
      this.pref!.flushSync();
      console.info(TaskStore.LOG_PREFIX + ' save success');
      return true;
    } catch (error) {
      const err: Error = error as Error;
      console.error(TaskStore.LOG_PREFIX + ' save 失败: ' + err.message);
      return false;
    }
  }

  public dateToString(year: number, month: number, day: number): string {
    const yearText: string = year.toString();
    const monthText: string = month.toString().padStart(2, '0');
    const dayText: string = day.toString().padStart(2, '0');
    return yearText + '-' + monthText + '-' + dayText;
  }

  public updateTask(year: number, month: number, day: number, task: Task): boolean {
    const key: string = this.dateToString(year, month, day);
    const taskArray: Array<Task> = this.taskStore.get(key) ?? [];
    for (let index: number = 0; index < taskArray.length; index++) {
      if (taskArray[index].getId() === task.getId()) {
        taskArray[index] = task;
        this.sortTaskArray(taskArray);
        this.taskStore.set(key, taskArray);
        return this.saveToDiskSync();
      }
    }
    console.warn(TaskStore.LOG_PREFIX + ' update miss key=' + key + ' id=' + task.getId());
    return false;
  }

  public addTask(year: number, month: number, day: number, task: Task): boolean {
    const key: string = this.dateToString(year, month, day);
    const taskArray: Array<Task> = this.taskStore.get(key) ?? [];
    const index: number = upper_bound<Task>(taskArray, task, (first: Task, second: Task) => {
      return TaskStore.compareTask(first, second);
    });
    task.setId(key + '-' + Task.static_number.toString());
    Task.static_number += 1;
    taskArray.splice(index, 0, task);
    this.sortTaskArray(taskArray);
    this.taskStore.set(key, taskArray);
    return this.saveToDiskSync();
  }

  public getTask(year: number, month: number, day: number): Array<Task> {
    const key: string = this.dateToString(year, month, day);
    const sourceArray: Array<Task> = this.taskStore.get(key) ?? [];
    const result: Array<Task> = [];
    for (let index: number = 0; index < sourceArray.length; index++) {
      result.push(sourceArray[index]);
    }
    return result;
  }

  public deleteTask(year: number, month: number, day: number, task: Task): boolean {
    const key: string = this.dateToString(year, month, day);
    const taskArray: Array<Task> = this.taskStore.get(key) ?? [];
    for (let index: number = 0; index < taskArray.length; index++) {
      if (taskArray[index].getId() === task.getId()) {
        taskArray.splice(index, 1);
        if (taskArray.length === 0) {
          this.taskStore.delete(key);
        } else {
          this.taskStore.set(key, taskArray);
        }
        return this.saveToDiskSync();
      }
    }
    console.warn(TaskStore.LOG_PREFIX + ' delete miss key=' + key + ' id=' + task.getId());
    return false;
  }

  private sortTaskArray(taskArray: Array<Task>): void {
    taskArray.sort((first: Task, second: Task) => {
      return TaskStore.compareTask(first, second);
    });
  }

  private static compareTask(first: Task, second: Task): number {
    const firstMinute: number = first.getBeginHour() * 60 + first.getBeginMinute();
    const secondMinute: number = second.getBeginHour() * 60 + second.getBeginMinute();
    if (firstMinute < secondMinute) {
      return -1;
    }
    if (firstMinute > secondMinute) {
      return 1;
    }
    const firstEndMinute: number = first.getEndHour() * 60 + first.getEndMinute();
    const secondEndMinute: number = second.getEndHour() * 60 + second.getEndMinute();
    if (firstEndMinute < secondEndMinute) {
      return -1;
    }
    if (firstEndMinute > secondEndMinute) {
      return 1;
    }
    return first.getTitle().localeCompare(second.getTitle(), 'zh-Hans-CN');
  }
}

export let taskStore: TaskStore = new TaskStore();
