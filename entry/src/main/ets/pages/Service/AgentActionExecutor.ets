import { common } from '@kit.AbilityKit';
import {
  AgentActionName,
  AgentCountDownOperationResult,
  AgentCreateCountDownArgs,
  AgentCreateTaskArgs,
  AgentDeleteCountDownArgs,
  AgentDeleteTaskArgs,
  AgentExecutionResult,
  AgentJumpToDateArgs,
  AgentOpenPageArgs,
  AgentSetShowAlmanacArgs,
  AgentSetThemeColorArgs,
  AgentTaskOperationResult,
  AgentUpdateTaskArgs
} from '../Model/AgentModels';
import { AgentJsonHelper } from './AgentJsonHelper';
import { AgentLogger } from './AgentLogger';
import { AgentSettingService } from './AgentSettingService';
import { CountDownOperationService } from './CountDownOperationService';
import { TaskOperationService } from './TaskOperationService';

export class AgentActionExecutor {
  private static readonly SCOPE: string = 'AgentActionExecutor';

  public static async prepareOrExecute(name: string, argumentsText: string, context: common.Context): Promise<AgentExecutionResult> {
    AgentLogger.info(AgentActionExecutor.SCOPE, 'prepareOrExecute name=' + name);
    if (name === AgentActionName.DeleteTask) {
      const args: AgentDeleteTaskArgs = AgentJsonHelper.parseDeleteTaskArgs(argumentsText);
      const result: AgentExecutionResult = new AgentExecutionResult();
      result.needConfirm = true;
      result.userText = '如果确认删除 ' + TaskOperationService.describeDeleteTarget(args) + '，请回复“确认删除”，回复“取消”可终止本次操作。';
      return result;
    }
    if (name === AgentActionName.DeleteCountDown) {
      const args: AgentDeleteCountDownArgs = AgentJsonHelper.parseDeleteCountDownArgs(argumentsText);
      const result: AgentExecutionResult = new AgentExecutionResult();
      result.needConfirm = true;
      result.userText = '如果确认删除 ' + CountDownOperationService.describeDeleteTarget(args) + '，请回复“确认删除”，回复“取消”可终止本次操作。';
      return result;
    }
    return await AgentActionExecutor.executeNow(name, argumentsText, context);
  }

  public static async executeConfirmed(name: string, argumentsText: string, context: common.Context): Promise<AgentExecutionResult> {
    AgentLogger.info(AgentActionExecutor.SCOPE, 'executeConfirmed name=' + name);
    return await AgentActionExecutor.executeNow(name, argumentsText, context);
  }

  private static async executeNow(name: string, argumentsText: string, context: common.Context): Promise<AgentExecutionResult> {
    if (name === AgentActionName.CreateTask) {
      return AgentActionExecutor.handleCreateTask(argumentsText);
    }
    if (name === AgentActionName.UpdateTask) {
      return AgentActionExecutor.handleUpdateTask(argumentsText);
    }
    if (name === AgentActionName.DeleteTask) {
      return AgentActionExecutor.handleDeleteTask(argumentsText);
    }
    if (name === AgentActionName.CreateCountDown) {
      return await AgentActionExecutor.handleCreateCountDown(argumentsText);
    }
    if (name === AgentActionName.DeleteCountDown) {
      return AgentActionExecutor.handleDeleteCountDown(argumentsText);
    }
    if (name === AgentActionName.JumpToDate) {
      return AgentActionExecutor.handleJumpToDate(argumentsText);
    }
    if (name === AgentActionName.OpenPage) {
      return AgentActionExecutor.handleOpenPage(argumentsText);
    }
    if (name === AgentActionName.SetShowAlmanac) {
      return await AgentActionExecutor.handleSetShowAlmanac(argumentsText, context);
    }
    if (name === AgentActionName.SetThemeColor) {
      return await AgentActionExecutor.handleSetThemeColor(argumentsText, context);
    }
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.userText = '暂不支持该操作。';
    return result;
  }

  private static handleCreateTask(argumentsText: string): AgentExecutionResult {
    const args: AgentCreateTaskArgs = AgentJsonHelper.parseCreateTaskArgs(argumentsText);
    const taskResult: AgentTaskOperationResult = TaskOperationService.createTask(args);
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.success = taskResult.success;
    result.userText = taskResult.userText;
    if (taskResult.success) {
      result.uiCommand.toastText = '日程创建成功';
      result.uiCommand.rootTabIndex = 0;
      result.uiCommand.calendarDate = taskResult.taskDate;
      result.uiCommand.calendarViewType = 'day';
      result.uiCommand.focusTaskId = taskResult.taskId;
    }
    return result;
  }

  private static handleUpdateTask(argumentsText: string): AgentExecutionResult {
    const args: AgentUpdateTaskArgs = AgentJsonHelper.parseUpdateTaskArgs(argumentsText);
    const taskResult: AgentTaskOperationResult = TaskOperationService.updateTask(args);
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.success = taskResult.success;
    result.userText = taskResult.userText;
    if (taskResult.success) {
      result.uiCommand.toastText = '日程修改成功';
      result.uiCommand.rootTabIndex = 0;
      result.uiCommand.calendarDate = taskResult.taskDate;
      result.uiCommand.calendarViewType = 'day';
      result.uiCommand.focusTaskId = taskResult.taskId;
    }
    return result;
  }

  private static handleDeleteTask(argumentsText: string): AgentExecutionResult {
    const args: AgentDeleteTaskArgs = AgentJsonHelper.parseDeleteTaskArgs(argumentsText);
    const taskResult: AgentTaskOperationResult = TaskOperationService.deleteTask(args);
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.success = taskResult.success;
    result.userText = taskResult.userText;
    if (taskResult.success) {
      result.uiCommand.toastText = '日程删除成功';
      result.uiCommand.rootTabIndex = 0;
      result.uiCommand.calendarDate = taskResult.taskDate;
      result.uiCommand.calendarViewType = 'day';
    }
    return result;
  }

  private static async handleCreateCountDown(argumentsText: string): Promise<AgentExecutionResult> {
    const args: AgentCreateCountDownArgs = AgentJsonHelper.parseCreateCountDownArgs(argumentsText);
    const countDownResult: AgentCountDownOperationResult = await CountDownOperationService.createCountDown(args);
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.success = countDownResult.success;
    result.userText = countDownResult.userText;
    if (countDownResult.success) {
      result.uiCommand.toastText = '倒计时创建成功';
      result.uiCommand.openPagePath = 'pages/CountdownList';
      result.uiCommand.focusCountDownId = countDownResult.countDownId;
    }
    return result;
  }

  private static handleDeleteCountDown(argumentsText: string): AgentExecutionResult {
    const args: AgentDeleteCountDownArgs = AgentJsonHelper.parseDeleteCountDownArgs(argumentsText);
    const countDownResult: AgentCountDownOperationResult = CountDownOperationService.deleteCountDown(args);
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.success = countDownResult.success;
    result.userText = countDownResult.userText;
    if (countDownResult.success) {
      result.uiCommand.toastText = '倒计时删除成功';
      result.uiCommand.openPagePath = 'pages/CountdownList';
    }
    return result;
  }

  private static handleJumpToDate(argumentsText: string): AgentExecutionResult {
    const args: AgentJumpToDateArgs = AgentJsonHelper.parseJumpToDateArgs(argumentsText);
    const result: AgentExecutionResult = new AgentExecutionResult();
    if (args.date.trim().length === 0) {
      result.userText = '跳转失败，缺少日期。';
      return result;
    }
    result.success = true;
    result.userText = '已为你切换页面。';
    result.uiCommand.toastText = '正在跳转';
    result.uiCommand.rootTabIndex = 0;
    result.uiCommand.calendarDate = args.date;
    result.uiCommand.calendarViewType = args.viewType;
    return result;
  }

  private static handleOpenPage(argumentsText: string): AgentExecutionResult {
    const args: AgentOpenPageArgs = AgentJsonHelper.parseOpenPageArgs(argumentsText);
    const result: AgentExecutionResult = new AgentExecutionResult();
    if (args.page === 'calendar') {
      result.success = true;
      result.userText = '已打开日历页。';
      result.uiCommand.rootTabIndex = 0;
      result.uiCommand.toastText = '已打开日历页';
      return result;
    }
    if (args.page === 'course') {
      result.success = true;
      result.userText = '已打开课表页。';
      result.uiCommand.rootTabIndex = 1;
      result.uiCommand.toastText = '已打开课表页';
      return result;
    }
    if (args.page === 'agent_chat') {
      result.success = true;
      result.userText = '已回到智能对话页。';
      result.uiCommand.rootTabIndex = 2;
      result.uiCommand.toastText = '已回到智能对话页';
      return result;
    }
    if (args.page === 'settings') {
      result.success = true;
      result.userText = '已打开设置页。';
      result.uiCommand.openPagePath = 'pages/Settings';
      result.uiCommand.toastText = '已打开设置页';
      return result;
    }
    if (args.page === 'course_import') {
      result.success = true;
      result.userText = '已打开课表导入页。';
      result.uiCommand.openPagePath = 'pages/CourseImport';
      result.uiCommand.toastText = '已打开课表导入页';
      return result;
    }
    if (args.page === 'countdown_list') {
      result.success = true;
      result.userText = '已打开倒计时列表。';
      result.uiCommand.openPagePath = 'pages/CountdownList';
      result.uiCommand.toastText = '已打开倒计时列表';
      return result;
    }
    result.userText = '暂不支持打开该页面。';
    return result;
  }

  private static async handleSetShowAlmanac(argumentsText: string, context: common.Context): Promise<AgentExecutionResult> {
    const args: AgentSetShowAlmanacArgs = AgentJsonHelper.parseSetShowAlmanacArgs(argumentsText);
    return await AgentSettingService.setShowAlmanac(args.show, context);
  }

  private static async handleSetThemeColor(argumentsText: string, context: common.Context): Promise<AgentExecutionResult> {
    const args: AgentSetThemeColorArgs = AgentJsonHelper.parseSetThemeColorArgs(argumentsText);
    return await AgentSettingService.setThemeColor(args.mode, args.value, context);
  }
}
