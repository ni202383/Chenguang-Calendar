import { router } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import {
  AgentChatMessage,
  AgentCourseQueryPayload,
  AgentExecutionResult,
  AgentIntent,
  AgentMessageStatus,
  AgentPendingAction,
  AgentPendingTaskSelection,
  AgentPlanResult,
  AgentScheduleCreatePayload,
  AgentScheduleDeletePayload,
  AgentScheduleQueryPayload,
  AgentScheduleUpdatePayload,
  AgentSender,
  AgentSettingsUpdatePayload,
  AgentTaskCandidateOption,
  AgentTaskOperationResult,
  AgentTimePayload,
  AgentUiCommand
} from '../../Model/AgentModels';
import { AgentActionExecutor } from '../../Service/AgentActionExecutor';
import { AgentGatewayService, AgentStreamListener } from '../../Service/AgentGatewayService';
import { TaskOperationService } from '../../Service/TaskOperationService';
import { AgentJsonHelper } from '../../Service/AgentJsonHelper';
import { AgentLocalContextService } from '../../Service/AgentLocalContextService';
import { AgentLogger } from '../../Service/AgentLogger';
import { AgentSettingService } from '../../Service/AgentSettingService';
import { AgentMessageBubble } from './AgentMessageBubble';
import { AgentUiBridge } from '../../../Utils/AgentUiBridge';
import { hdsMaterial, HdsNavigation, HdsNavigationTitleMode, ScrollEffectType } from '@kit.UIDesignKit';
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';

@Component
export struct AgentChatPage {
  private readonly logScope: string = 'AgentChatPage';
  private static readonly LOG_FLOW: string = 'FLOW';
  private static readonly LOG_FOLLOWUP: string = 'FOLLOWUP';
  private static readonly LOG_PLAN: string = 'GW.PLAN';
  private static readonly LOG_EXEC: string = 'EXEC';
  private static readonly LOG_ANSWER: string = 'GW.ANSWER';
  private turnCounter: number = 0;
  private currentTurnId: string = '';

  private beginTurn(content: string): void {
    this.turnCounter += 1;
    this.currentTurnId = Date.now().toString() + '-' + this.turnCounter.toString();
    AgentLogger.info(AgentChatPage.LOG_FLOW,
      'turn=' + this.currentTurnId + ' session=' + this.sessionId + ' userLen=' + content.length.toString() +
      ' pendingFollowUp=' + (this.pendingCreateFollowUpActive ? '1' : '0') +
      ' history=' + this.messages.length.toString());
  }

  private log(scope: string, message: string): void {
    const prefix: string = this.currentTurnId.trim().length > 0 ? ('turn=' + this.currentTurnId + ' ') : '';
    AgentLogger.info(scope, prefix + message);
  }
  private readonly taskFocusDurationMs: number = 6000;
  private readonly countDownFocusDurationMs: number = 6000;

  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp('bottomStatusBarHeight') bottomStatusBarHeight: number = 0;
  @StorageProp('themeColor') themeColor: string = '#EA5C2E';

  @State private sessionId: string = '';
  @State private messages: Array<AgentChatMessage> = [];
  @State private inputText: string = '';
  @State private isSending: boolean = false;
  @State private pendingAction: AgentPendingAction = new AgentPendingAction();
  @State private pendingTaskSelection: AgentPendingTaskSelection = new AgentPendingTaskSelection();
  @State private pendingCreateFollowUpActive: boolean = false;
  @State private pendingCreateFollowUpPayloadTexts: Array<string> = [];
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;

  private scroller: Scroller = new Scroller();
  private taskFocusTimer?: number;
  private countDownFocusTimer?: number;

  aboutToAppear(): void {
    if (this.sessionId.length === 0) {
      this.sessionId = 'session-' + new Date().getTime().toString();
    }
    if (this.messages.length === 0) {
      this.appendMessage(AgentSender.Assistant,
        '你好，我是辰光。你可以问我日程、课程、黄历、节日和倒计时，也可以直接让我执行操作。',
        AgentMessageStatus.Done);
    }
    this.scrollToBottom();
  }

  aboutToDisappear(): void {
    if (this.taskFocusTimer !== undefined) {
      clearTimeout(this.taskFocusTimer);
      this.taskFocusTimer = undefined;
    }
    if (this.countDownFocusTimer !== undefined) {
      clearTimeout(this.countDownFocusTimer);
      this.countDownFocusTimer = undefined;
    }
  }

  private buildMessageId(): string {
    const randomSuffix: string = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    return new Date().getTime().toString() + '-' + randomSuffix;
  }

  private appendMessage(sender: AgentSender, text: string, status: AgentMessageStatus): AgentChatMessage {
    const displayText: string = sender === AgentSender.Assistant ? this.normalizeAssistantDisplayText(text) : text;
    const message: AgentChatMessage = new AgentChatMessage(this.buildMessageId(), sender, displayText, status, new Date().getTime());
    this.messages.push(message);
    this.scrollToBottom();
    return message;
  }

  private normalizeAssistantDisplayText(text: string): string {
    let normalized: string = text.replace(/\r/g, '');
    normalized = normalized.replace(/```+/g, '');
    normalized = normalized.replace(/`+/g, '');
    normalized = normalized.replace(/^#{1,6}\s*/gm, '');
    normalized = normalized.replace(/\*\*(.*?)\*\*/g, '$1');
    normalized = normalized.replace(/__(.*?)__/g, '$1');
    normalized = normalized.replace(/\*(.*?)\*/g, '$1');
    normalized = normalized.replace(/_(.*?)_/g, '$1');
    normalized = normalized.replace(/\*+/g, '');
    normalized = normalized.replace(/^[ \t]*[-*]\s+/gm, '• ');
    normalized = normalized.replace(/\n{3,}/g, '\n\n');
    return normalized;
  }

  private removeMessageById(messageId: string): void {
    const nextList: Array<AgentChatMessage> = [];
    for (let index: number = 0; index < this.messages.length; index++) {
      const item: AgentChatMessage = this.messages[index];
      if (item.id !== messageId) {
        nextList.push(item);
      }
    }
    this.messages = nextList;
    this.scrollToBottom();
  }

  private scrollToBottom(): void {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 80);
  }

  private bottomInset(): number {
    return 100 + this.getUIContext().px2vp(this.bottomStatusBarHeight);
  }

  private topInset(): number {
    return 12 + this.getUIContext().px2vp(this.topStatusBarHeight);
  }

  private async submitInput(): Promise<void> {
    const content: string = this.inputText.trim();
    if (content.length === 0) {
      return;
    }
    if (this.isSending) {
      this.getUIContext().getPromptAction().showToast({ message: '辰光正在处理上一条消息，请稍等。' });
      return;
    }
    this.beginTurn(content);
    this.inputText = '';
    this.appendMessage(AgentSender.User, content, AgentMessageStatus.Done);

    const handledSelection: boolean = await this.handlePendingTaskSelectionInput(content);
    if (handledSelection) {
      this.log(AgentChatPage.LOG_FLOW, 'handled pendingTaskSelection');
      return;
    }
    const handled: boolean = await this.handlePendingActionInput(content);
    if (handled) {
      this.log(AgentChatPage.LOG_FLOW, 'handled pendingAction');
      return;
    }
    if (this.handlePendingCreateFollowUpCancel(content)) {
      this.log(AgentChatPage.LOG_FOLLOWUP, 'followUp cancelled by user');
      return;
    }
    const plannerContent: string = this.buildPlannerContent(content);
    await this.handleNormalConversation(content, plannerContent);
  }

  private async handlePendingTaskSelectionInput(content: string): Promise<boolean> {
    if (!this.pendingTaskSelection.active) {
      return false;
    }
    const normalized: string = content.trim();
    if (normalized === '取消') {
      this.pendingTaskSelection = new AgentPendingTaskSelection();
      this.appendMessage(AgentSender.Assistant, '已取消本次日程选择。', AgentMessageStatus.Done);
      return true;
    }
    const selectedTaskIds: Array<string> = this.parseSelectedCandidateIds(normalized, this.pendingTaskSelection.candidates, this.pendingTaskSelection.allowMultiple);
    if (selectedTaskIds.length === 0) {
      this.appendMessage(AgentSender.Assistant, '请直接回复候选序号，例如“1”或“1,2”，也可以回复“取消”。', AgentMessageStatus.Done);
      return true;
    }
    this.isSending = true;
    const pending: AgentPendingTaskSelection = this.pendingTaskSelection;
    this.pendingTaskSelection = new AgentPendingTaskSelection();
    try {
      let result: AgentTaskOperationResult = new AgentTaskOperationResult();
      if (pending.action === 'update') {
        result = TaskOperationService.updateTaskFromPayloadWithTaskIds(pending.payloadText, selectedTaskIds);
      } else {
        result = TaskOperationService.deleteTaskFromPayloadWithTaskIds(pending.payloadText, selectedTaskIds);
      }
      this.appendMessage(AgentSender.Assistant, result.userText, result.success ? AgentMessageStatus.Done : AgentMessageStatus.Error);
      if (result.success) {
        const command: AgentUiCommand = new AgentUiCommand();
        command.rootTabIndex = 0;
        command.calendarDate = result.taskDate;
        command.calendarViewType = 'day';
        if (pending.action === 'update') {
          command.toastText = result.affectedCount > 1 ? '日程批量修改成功' : '日程修改成功';
          command.focusTaskId = result.taskId;
        } else {
          command.toastText = result.affectedCount > 1 ? '日程批量删除成功' : '日程删除成功';
        }
        this.applyUiCommand(command);
      }
    } catch (error) {
      const err: Error = error as Error;
      AgentLogger.error(this.logScope, 'pending task selection failed: ' + err.message);
      this.appendMessage(AgentSender.Assistant, '处理日程选择时发生错误，请稍后再试。', AgentMessageStatus.Error);
    } finally {
      this.isSending = false;
      this.scrollToBottom();
    }
    return true;
  }

  private handlePendingCreateFollowUpCancel(content: string): boolean {
    const normalized: string = content.trim();
    if (!this.pendingCreateFollowUpActive) {
      return false;
    }
    if (normalized !== '取消' && normalized !== '算了' && normalized !== '不用了') {
      return false;
    }
    this.clearPendingCreateFollowUp();
    this.appendMessage(AgentSender.Assistant, '已取消本次补充创建日程。', AgentMessageStatus.Done);
    return true;
  }

  private isLikelyNewIndependentRequest(content: string): boolean {
    const normalized: string = content.trim();
    if (normalized.length === 0) {
      return false;
    }
    if (normalized.length <= 8 && !normalized.includes('帮我') && !normalized.includes('请') && !normalized.includes('查询') &&
      !normalized.includes('修改') && !normalized.includes('删除') && !normalized.includes('创建') && !normalized.includes('添加')) {
      return false;
    }
    const hasActionCue: boolean = normalized.includes('帮我') || normalized.includes('请') || normalized.includes('查询') ||
      normalized.includes('查看') || normalized.includes('看看') || normalized.includes('总结') || normalized.includes('汇总') ||
      normalized.includes('列出') || normalized.includes('显示') || normalized.includes('修改') || normalized.includes('调整') ||
      normalized.includes('删除') || normalized.includes('移除') || normalized.includes('创建') || normalized.includes('新建') ||
      normalized.includes('添加') || normalized.includes('安排') || normalized.includes('有没有') || normalized.includes('有无') ||
      normalized.includes('打开') || normalized.includes('关闭');
    if (!hasActionCue) {
      return false;
    }
    const looksLikeSimpleSupplement: boolean = normalized.startsWith('地点') || normalized.startsWith('在') ||
      normalized.startsWith('主题') || normalized.startsWith('类型') || normalized.startsWith('提醒') ||
      normalized.startsWith('备注') || normalized.startsWith('详情') || normalized.startsWith('日期') ||
      normalized.startsWith('开始时间') || normalized.startsWith('结束时间') || normalized.startsWith('改成') ||
      normalized.startsWith('改为') || normalized.startsWith('改到') || normalized.startsWith('推迟到') ||
      normalized.startsWith('提前到') || normalized.startsWith('后天') || normalized.startsWith('明天') ||
      normalized.startsWith('今天') || normalized.startsWith('本周') || normalized.startsWith('下周');
    const containsSupplementCue: boolean = normalized.indexOf('地点') >= 0 || normalized.indexOf('类型') >= 0 ||
      normalized.indexOf('提醒') >= 0 || normalized.indexOf('备注') >= 0 || normalized.indexOf('详情') >= 0 ||
      normalized.indexOf('开始时间') >= 0 || normalized.indexOf('结束时间') >= 0 || normalized.indexOf('改成') >= 0 ||
      normalized.indexOf('改为') >= 0 || normalized.indexOf('改到') >= 0 || normalized.indexOf('推迟到') >= 0 ||
      normalized.indexOf('提前到') >= 0;
    if (containsSupplementCue && !normalized.startsWith('帮我') && !normalized.startsWith('请') && !normalized.startsWith('查询') &&
      !normalized.startsWith('查看') && !normalized.startsWith('删除') && !normalized.startsWith('修改') && !normalized.startsWith('创建')) {
      return false;
    }
    return !looksLikeSimpleSupplement;
  }

  private buildPlannerContent(content: string): string {
    if (!this.pendingCreateFollowUpActive || this.pendingCreateFollowUpPayloadTexts.length === 0) {
      return content;
    }
    const summaryText: string = this.buildPendingCreateFollowUpSummary(this.pendingCreateFollowUpPayloadTexts);
    let merged: string = '系统上下文：当前有未完成的创建日程补充任务。\n';
    merged += '请同时遵守以下规则：\n';
    merged += '1. 如果本轮消息补充了待创建日程的信息，请继续输出对应的 schedule.create intent，只提取本轮新增或修正的字段。\n';
    merged += '2. 如果本轮消息里还包含新的查询、修改、设置或校园问题，也必须照常输出这些 intent，不能漏掉。\n';
    merged += '3. 如果本轮消息与待创建日程无关，就不要为了补充而强行输出 schedule.create。\n';
    merged += '4. 不要把待补充项摘要当成新的用户请求。\n';
    if (summaryText.trim().length > 0) {
      merged += '当前待补充项：\n' + summaryText + '\n';
    }
    merged += '【原始用户消息】' + content;
    return merged;
  }

  private buildPendingCreateFollowUpSummary(payloadTexts: Array<string>): string {
    const lines: Array<string> = [];
    for (let index: number = 0; index < payloadTexts.length; index++) {
      const payload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(payloadTexts[index]);
      const labels: Array<string> = [];
      for (let fieldIndex: number = 0; fieldIndex < payload.missingFields.length; fieldIndex++) {
        const label: string = this.describePendingCreateField(payload.missingFields[fieldIndex]);
        if (label.trim().length > 0 && labels.indexOf(label) < 0) {
          labels.push(label);
        }
      }
      const prefix: string = '第' + (index + 1).toString() + '个日程';
      if (labels.length === 0) {
        lines.push(prefix + '已确认：' + this.describePendingCreateSnapshot(payload));
      } else {
        lines.push(prefix + '仍缺少：' + labels.join('、'));
      }
    }
    return lines.join('\n');
  }

  private describePendingCreateField(field: string): string {
    if (field === 'title') {
      return '主题';
    }
    if (field === 'date') {
      return '日期';
    }
    if (field === 'startDateTime') {
      return '开始时间';
    }
    if (field === 'endDateTime') {
      return '结束时间';
    }
    if (field === 'location') {
      return '地点';
    }
    if (field === 'category') {
      return '类型';
    }
    return field;
  }

  private describePendingCreateSnapshot(payload: AgentScheduleCreatePayload): string {
    const parts: Array<string> = [];
    if (payload.title.trim().length > 0) {
      parts.push('主题=' + payload.title.trim());
    }
    if (payload.time.resolvedDate.trim().length > 0) {
      parts.push('日期=' + payload.time.resolvedDate.trim());
    }
    if (payload.time.startDateTime.trim().length >= 16) {
      parts.push('开始=' + payload.time.startDateTime.substring(11, 16));
    }
    if (payload.time.endDateTime.trim().length >= 16) {
      parts.push('结束=' + payload.time.endDateTime.substring(11, 16));
    }
    if (payload.location.trim().length > 0) {
      parts.push('地点=' + payload.location.trim());
    }
    if (payload.category.trim().length > 0) {
      parts.push('类型=' + payload.category.trim());
    }
    return parts.length > 0 ? parts.join('；') : '必要信息';
  }

  private rememberPendingCreateFollowUp(plan: AgentPlanResult): void {
    const payloadTexts: Array<string> = this.extractPendingCreateFollowUpPayloads(plan);
    this.pendingCreateFollowUpActive = payloadTexts.length > 0;
    this.pendingCreateFollowUpPayloadTexts = payloadTexts;
  }

  private extractPendingCreateFollowUpPayloads(plan: AgentPlanResult): Array<string> {
    const result: Array<string> = [];
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain !== 'schedule' || intent.action !== 'create') {
        continue;
      }
      const payload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(intent.payloadText);
      if (payload.needsFollowUp) {
        result.push(JSON.stringify(payload));
      }
    }
    return result;
  }

  private mergePendingCreateFollowUpPlan(plan: AgentPlanResult, previousPayloadTexts: Array<string>): AgentPlanResult {
    if (previousPayloadTexts.length === 0) {
      return plan;
    }
    const previousPayloads: Array<AgentScheduleCreatePayload> = [];
    for (let index: number = 0; index < previousPayloadTexts.length; index++) {
      previousPayloads.push(AgentJsonHelper.parseScheduleCreatePayload(previousPayloadTexts[index]));
    }
    const createIntentIndexes: Array<number> = [];
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain === 'schedule' && intent.action === 'create') {
        createIntentIndexes.push(index);
      }
    }
    if (createIntentIndexes.length === 0) {
      return plan;
    }
    for (let index: number = 0; index < previousPayloads.length; index++) {
      if (index < createIntentIndexes.length) {
        const targetIntentIndex: number = createIntentIndexes[index];
        const deltaPayload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(
          plan.intents[targetIntentIndex].payloadText
        );
        const mergedPayload: AgentScheduleCreatePayload = this.mergeScheduleCreatePayload(previousPayloads[index], deltaPayload);
        plan.intents[targetIntentIndex].payloadText = JSON.stringify(mergedPayload);
        continue;
      }
      const intent: AgentIntent = new AgentIntent();
      intent.domain = 'schedule';
      intent.action = 'create';
      intent.confidence = 0.99;
      intent.payloadText = JSON.stringify(previousPayloads[index]);
      plan.intents.push(intent);
    }
    plan.requestType = this.inferRequestTypeByIntents(plan.intents);
    return plan;
  }

  private planTouchesScheduleCreate(plan: AgentPlanResult): boolean {
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain === 'schedule' && intent.action === 'create') {
        return true;
      }
    }
    return false;
  }

  private restorePendingCreateFollowUp(payloadTexts: Array<string>): void {
    this.pendingCreateFollowUpActive = payloadTexts.length > 0;
    this.pendingCreateFollowUpPayloadTexts = payloadTexts.slice(0);
  }

  private refreshPendingCreateConversationControl(plan: AgentPlanResult): void {
    const payloadList: Array<AgentScheduleCreatePayload> = [];
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain !== 'schedule' || intent.action !== 'create') {
        continue;
      }
      const payload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(intent.payloadText);
      if (!payload.needsFollowUp || payload.missingFields.length === 0) {
        continue;
      }
      payloadList.push(payload);
    }
    if (payloadList.length === 0) {
      plan.conversationControl.followUpNeeded = false;
      plan.conversationControl.followUpQuestion = '';
      plan.conversationControl.reason = '';
      return;
    }
    plan.conversationControl.followUpNeeded = true;
    plan.conversationControl.followUpQuestion = this.buildPendingCreateFollowUpQuestion(payloadList);
    plan.conversationControl.reason = 'missing_fields';
  }

  private buildPendingCreateFollowUpQuestion(payloadList: Array<AgentScheduleCreatePayload>): string {
    if (payloadList.length === 0) {
      return '';
    }
    if (payloadList.length === 1) {
      if (payloadList[0].missingFields.length === 0) {
        return '这个日程上一次创建时发生了冲突。你可以修改日期、开始时间、结束时间、地点、主题或类型，我继续帮你创建。';
      }
      return '请补充这个日程的' + this.joinChineseLabels(this.collectPendingFieldLabels(payloadList[0])) + '。';
    }
    const lines: Array<string> = [];
    lines.push('还有 ' + payloadList.length.toString() + ' 个日程信息不完整：');
    for (let index: number = 0; index < payloadList.length; index++) {
      lines.push((index + 1).toString() + '. 需要补充' + this.joinChineseLabels(this.collectPendingFieldLabels(payloadList[index])) + '。');
    }
    lines.push('请尽量按顺序一次补充完整。');
    return lines.join('\n');
  }

  private collectPendingFieldLabels(payload: AgentScheduleCreatePayload): Array<string> {
    const labels: Array<string> = [];
    for (let index: number = 0; index < payload.missingFields.length; index++) {
      const label: string = this.describePendingCreateField(payload.missingFields[index]);
      if (label.trim().length > 0 && labels.indexOf(label) < 0) {
        labels.push(label);
      }
    }
    if (labels.length === 0) {
      labels.push('必要信息');
    }
    return labels;
  }

  private joinChineseLabels(labels: Array<string>): string {
    if (labels.length === 0) {
      return '必要信息';
    }
    if (labels.length === 1) {
      return labels[0];
    }
    if (labels.length === 2) {
      return labels[0] + '和' + labels[1];
    }
    return labels.slice(0, labels.length - 1).join('、') + '和' + labels[labels.length - 1];
  }

  private mergeScheduleCreatePayload(basePayload: AgentScheduleCreatePayload, deltaPayload: AgentScheduleCreatePayload): AgentScheduleCreatePayload {
    const merged: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(JSON.stringify(basePayload));
    if (this.isMeaningfulFollowUpTitle(deltaPayload.title)) {
      merged.title = deltaPayload.title.trim();
    }
    merged.time = this.mergeTimePayload(basePayload.time, deltaPayload.time);
    if (deltaPayload.location.trim().length > 0) {
      merged.location = deltaPayload.location.trim();
    }
    if (deltaPayload.note.trim().length > 0) {
      merged.note = deltaPayload.note.trim();
    }
    if (deltaPayload.category.trim().length > 0) {
      merged.category = deltaPayload.category.trim();
    }
    if (deltaPayload.reminder.enabled && deltaPayload.reminder.minutesBefore >= 0) {
      merged.reminder = deltaPayload.reminder;
    }
    merged.isAllDay = deltaPayload.isAllDay || basePayload.isAllDay;
    merged.missingFields = [];
    if (merged.title.trim().length === 0) {
      merged.missingFields.push('title');
    }
    if (merged.time.resolvedDate.trim().length === 0) {
      merged.missingFields.push('date');
    }
    if (merged.time.startDateTime.trim().length === 0) {
      merged.missingFields.push('startDateTime');
    }
    if (merged.time.endDateTime.trim().length === 0) {
      merged.missingFields.push('endDateTime');
    }
    if (merged.location.trim().length === 0) {
      merged.missingFields.push('location');
    }
    if (merged.category.trim().length === 0) {
      merged.missingFields.push('category');
    }
    merged.needsFollowUp = merged.missingFields.length > 0;
    return merged;
  }

  private mergeTimePayload(baseTime: AgentTimePayload, deltaTime: AgentTimePayload): AgentTimePayload {
    const merged: AgentTimePayload = new AgentTimePayload();
    const allowTimeOverwrite: boolean = this.followUpTextContainsTime(deltaTime.originalText);
    merged.originalText = deltaTime.originalText.trim().length > 0 ? deltaTime.originalText : baseTime.originalText;
    merged.resolvedDate = (deltaTime.resolvedDate.trim().length > 0 && (baseTime.resolvedDate.trim().length === 0 || allowTimeOverwrite)) ?
      deltaTime.resolvedDate : baseTime.resolvedDate;
    merged.startDateTime = (deltaTime.startDateTime.trim().length > 0 && (baseTime.startDateTime.trim().length === 0 || allowTimeOverwrite)) ?
      deltaTime.startDateTime : baseTime.startDateTime;
    merged.endDateTime = (deltaTime.endDateTime.trim().length > 0 && (baseTime.endDateTime.trim().length === 0 || allowTimeOverwrite)) ?
      deltaTime.endDateTime : baseTime.endDateTime;
    if (deltaTime.resolvedDate.trim().length > 0) {
      if (merged.startDateTime.trim().length >= 16 &&
        (baseTime.resolvedDate.trim().length === 0 || allowTimeOverwrite) &&
        deltaTime.startDateTime.trim().length === 0) {
        merged.startDateTime = this.replaceDatePart(merged.startDateTime, deltaTime.resolvedDate.trim());
      }
      if (merged.endDateTime.trim().length >= 16 &&
        (baseTime.resolvedDate.trim().length === 0 || allowTimeOverwrite) &&
        deltaTime.endDateTime.trim().length === 0) {
        merged.endDateTime = this.replaceDatePart(merged.endDateTime, deltaTime.resolvedDate.trim());
      }
    }
    merged.timePeriod = (deltaTime.timePeriod.trim().length > 0 && (baseTime.timePeriod.trim().length === 0 || allowTimeOverwrite)) ?
      deltaTime.timePeriod : baseTime.timePeriod;
    merged.precision = deltaTime.precision.trim().length > 0 ? deltaTime.precision : baseTime.precision;
    merged.isRelative = deltaTime.isRelative || baseTime.isRelative;
    return merged;
  }

  private replaceDatePart(dateTimeText: string, dateText: string): string {
    if (dateTimeText.trim().length < 16 || dateText.trim().length < 10) {
      return dateTimeText;
    }
    return dateText.trim().substring(0, 10) + dateTimeText.trim().substring(10);
  }

  private isMeaningfulFollowUpTitle(title: string): boolean {
    const value: string = title.trim();
    if (value.length === 0) {
      return false;
    }
    if (value === '请求的补充' || value === '补充' || value === '这个日程' || value === '该日程') {
      return false;
    }
    return !value.startsWith('第') || value.indexOf('个日程') < 0;
  }

  private followUpTextContainsTime(text: string): boolean {
    const value: string = text.trim();
    if (value.length === 0) {
      return false;
    }
    const matchTime: boolean = /\d{1,2}[:点时]\d{0,2}|上午|下午|晚上|中午|凌晨|早上|今天|明天|后天|昨天|本周|这周|下周|周[一二三四五六日天]/.test(value);
    return matchTime;
  }

  private clearPendingCreateFollowUp(): void {
    this.pendingCreateFollowUpActive = false;
    this.pendingCreateFollowUpPayloadTexts = [];
  }

  private async handlePendingActionInput(content: string): Promise<boolean> {
    if (!this.pendingAction.active) {
      return false;
    }
    const normalized: string = content.trim();
    if (normalized === '取消') {
      this.pendingAction = new AgentPendingAction();
      this.appendMessage(AgentSender.Assistant, '已取消本次删除操作。', AgentMessageStatus.Done);
      return true;
    }
    if (normalized !== '确认删除') {
      this.appendMessage(AgentSender.Assistant, '当前有待确认的删除操作，请回复“确认删除”或“取消”。',
        AgentMessageStatus.Done);
      return true;
    }

    this.isSending = true;
    const pending: AgentPendingAction = this.pendingAction;
    this.pendingAction = new AgentPendingAction();
    try {
      const hostContext: common.Context = this.getUIContext().getHostContext() as common.Context;
      const result: AgentExecutionResult = await AgentActionExecutor.executeConfirmed(pending.name, pending.argumentsText,
        hostContext);
      if (result.userText.trim().length > 0) {
        this.appendMessage(AgentSender.Assistant, result.userText, result.success ? AgentMessageStatus.Done :
          AgentMessageStatus.Error);
      }
      this.applyUiCommand(result.uiCommand);
    } catch (error) {
      const err: Error = error as Error;
      AgentLogger.error(this.logScope, 'confirm execute failed: ' + err.message);
      this.appendMessage(AgentSender.Assistant, '删除操作执行失败，请稍后再试。', AgentMessageStatus.Error);
    } finally {
      this.isSending = false;
      this.scrollToBottom();
    }
    return true;
  }

  private async handleNormalConversation(content: string, plannerContent: string): Promise<void> {
    this.isSending = true;
    const assistantMessage: AgentChatMessage = this.appendMessage(AgentSender.Assistant, '正在思考…', AgentMessageStatus.Thinking);
    let plan: AgentPlanResult = new AgentPlanResult();
    let streamErrorHandled: boolean = false;
    try {
      const previousPendingCreatePayloadTexts: Array<string> = this.pendingCreateFollowUpPayloadTexts.slice(0);
      const hadPendingCreate: boolean = this.pendingCreateFollowUpActive && previousPendingCreatePayloadTexts.length > 0;
      this.log(AgentChatPage.LOG_PLAN,
        'plan start userLen=' + content.length.toString() + ' plannerLen=' + plannerContent.length.toString() +
        ' pendingCreate=' + previousPendingCreatePayloadTexts.length.toString() +
        ' history=' + this.messages.length.toString());
      plan = await AgentGatewayService.plan(plannerContent, this.sessionId, this.messages);
      const touchedPendingCreate: boolean = hadPendingCreate && this.planTouchesScheduleCreate(plan);
      if (touchedPendingCreate) {
        plan = this.mergePendingCreateFollowUpPlan(plan, previousPendingCreatePayloadTexts);
      }
      this.refreshPendingCreateConversationControl(plan);
      this.log(AgentChatPage.LOG_PLAN, 'plan done requestType=' + plan.requestType + ' intentCount=' + plan.intents.length.toString() +
        ' followUp=' + (plan.conversationControl.followUpNeeded ? '1' : '0'));
      for (let index: number = 0; index < plan.intents.length; index++) {
        const intent: AgentIntent = plan.intents[index];
        this.log(AgentChatPage.LOG_PLAN,
          'intent[' + index.toString() + ']=' + intent.domain + '.' + intent.action +
          ' conf=' + intent.confidence.toFixed(2) + ' payloadLen=' + intent.payloadText.length.toString());
      }
      const readyPlan: AgentPlanResult = this.buildReadyPlan(plan);
      this.clearPendingCreateFollowUp();
      const followUpQuestion: string = plan.conversationControl.followUpQuestion.trim().length > 0 ?
        plan.conversationControl.followUpQuestion : '请再补充一点信息，我才能继续处理。';
      this.log(AgentChatPage.LOG_EXEC, 'local execute start intentCount=' + readyPlan.intents.length.toString());
      const actionSummaryText: string = await this.executeLocalIntents(readyPlan);
      const deterministicReplyText: string = AgentLocalContextService.buildDeterministicReply(readyPlan);
      this.log(AgentChatPage.LOG_EXEC,
        'local execute done actionLen=' + actionSummaryText.length.toString() + ' deterministicLen=' +
        deterministicReplyText.length.toString());
      if (plan.conversationControl.followUpNeeded) {
        this.rememberPendingCreateFollowUp(plan);
        if (this.pendingCreateFollowUpPayloadTexts.length > 0) {
          this.log(AgentChatPage.LOG_FOLLOWUP, 'followUp needed pendingCreate=' + this.pendingCreateFollowUpPayloadTexts.length.toString());
          const localReplyText: string = this.composeReplyText(actionSummaryText, deterministicReplyText, followUpQuestion);
          assistantMessage.text = this.normalizeAssistantDisplayText(localReplyText.length > 0 ? localReplyText : followUpQuestion);
          assistantMessage.status = AgentMessageStatus.Done;
          return;
        }
      }
      const retryQuestion: string = this.rememberRetryableCreatePlan(readyPlan, actionSummaryText);
      if (retryQuestion.trim().length > 0) {
        this.log(AgentChatPage.LOG_FOLLOWUP, 'retryable create kept pending=' + this.pendingCreateFollowUpPayloadTexts.length.toString());
        assistantMessage.text = this.normalizeAssistantDisplayText(this.composeReplyText(actionSummaryText, deterministicReplyText, retryQuestion));
        assistantMessage.status = AgentMessageStatus.Done;
        return;
      }

      if (hadPendingCreate && !touchedPendingCreate) {
        this.restorePendingCreateFollowUp(previousPendingCreatePayloadTexts);
      }

      if (!readyPlan.needsFinalAnswer()) {
        assistantMessage.text = this.normalizeAssistantDisplayText(actionSummaryText.length > 0 ? actionSummaryText : '操作已完成。');
        assistantMessage.status = AgentMessageStatus.Done;
        return;
      }
      if (deterministicReplyText.trim().length > 0 && !this.hasUnsupportedQueryIntent(readyPlan)) {
        assistantMessage.text = this.normalizeAssistantDisplayText(this.composeReplyText(actionSummaryText, deterministicReplyText, ''));
        assistantMessage.status = AgentMessageStatus.Done;
        return;
      }

      let contextText: string = '';
      if (readyPlan.needsLocalData()) {
        const localContext = AgentLocalContextService.buildContext(readyPlan, content);
        contextText = localContext.toJsonText();
      }
      this.log(AgentChatPage.LOG_ANSWER,
        'stream start needsLocal=' + (readyPlan.needsLocalData() ? '1' : '0') +
        ' localJsonLen=' + contextText.length.toString());
      const listener: AgentStreamListener = new AgentStreamListener();
      listener.onReady = () => {
        this.log(AgentChatPage.LOG_ANSWER, 'stream ready');
      };
      listener.onThinking = (messageText: string) => {
        if (assistantMessage.text.length === 0 || assistantMessage.status === AgentMessageStatus.Thinking) {
          assistantMessage.text = this.normalizeAssistantDisplayText(messageText);
          assistantMessage.status = AgentMessageStatus.Thinking;
          this.scrollToBottom();
        }
      };
      listener.onChunk = (text: string) => {
        if (assistantMessage.status !== AgentMessageStatus.Streaming) {
          assistantMessage.text = '';
        }
        assistantMessage.text = this.normalizeAssistantDisplayText(assistantMessage.text + text);
        assistantMessage.status = AgentMessageStatus.Streaming;
        this.scrollToBottom();
      };
      listener.onError = (messageText: string) => {
        streamErrorHandled = true;
        assistantMessage.text = this.normalizeAssistantDisplayText(messageText);
        assistantMessage.status = AgentMessageStatus.Error;
        this.scrollToBottom();
      };
      listener.onDone = () => {
        this.log(AgentChatPage.LOG_ANSWER, 'stream done');
      };
      await AgentGatewayService.chatStream(content, this.sessionId, this.messages, JSON.stringify(readyPlan), contextText,
        actionSummaryText, listener);
      if (assistantMessage.status !== AgentMessageStatus.Error) {
        assistantMessage.status = AgentMessageStatus.Done;
      }
      if (assistantMessage.text.trim().length === 0 && !streamErrorHandled) {
        assistantMessage.text = this.normalizeAssistantDisplayText(actionSummaryText.length > 0 ? actionSummaryText : '抱歉，我这次没有获得有效回复，请再试一次。');
        assistantMessage.status = actionSummaryText.length > 0 ? AgentMessageStatus.Done : AgentMessageStatus.Error;
      }
    } catch (error) {
      const err: Error = error as Error;
      AgentLogger.error(this.logScope, 'conversation failed: ' + err.message);
      if (!streamErrorHandled) {
        assistantMessage.text = this.normalizeAssistantDisplayText('请求失败，请检查网关服务或稍后再试。');
        assistantMessage.status = AgentMessageStatus.Error;
      }
    } finally {
      this.isSending = false;
      this.scrollToBottom();
    }
  }

  private rememberRetryableCreatePlan(plan: AgentPlanResult, actionSummaryText: string): string {
    if (actionSummaryText.indexOf('创建失败') < 0) {
      return '';
    }
    const payloadTexts: Array<string> = [];
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain !== 'schedule' || intent.action !== 'create') {
        continue;
      }
      const payload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(intent.payloadText);
      if (payload.missingFields.length === 0) {
        payload.needsFollowUp = false;
        payloadTexts.push(JSON.stringify(payload));
      }
    }
    if (payloadTexts.length === 0) {
      return '';
    }
    this.pendingCreateFollowUpActive = true;
    this.pendingCreateFollowUpPayloadTexts = payloadTexts;
    return payloadTexts.length === 1 ?
      '当前创建没有成功。你可以改一下日期、开始时间、结束时间、地点、主题或类型，我继续帮你创建。' :
      '有部分日程还没成功创建。你可以继续逐个修改日期、开始时间、结束时间、地点、主题或类型，我继续帮你创建。';
  }

  private composeReplyText(actionSummaryText: string, deterministicReplyText: string, followUpQuestion: string): string {
    const parts: Array<string> = [];
    if (actionSummaryText.trim().length > 0) {
      parts.push(actionSummaryText.trim());
    }
    if (deterministicReplyText.trim().length > 0) {
      parts.push(deterministicReplyText.trim());
    }
    if (followUpQuestion.trim().length > 0) {
      parts.push(followUpQuestion.trim());
    }
    return this.normalizeAssistantDisplayText(parts.join('\n\n'));
  }

  private buildReadyPlan(sourcePlan: AgentPlanResult): AgentPlanResult {
    const readyPlan: AgentPlanResult = new AgentPlanResult();
    readyPlan.success = sourcePlan.success;
    readyPlan.requestType = this.inferRequestTypeByIntents(sourcePlan.intents);
    readyPlan.modelHint = sourcePlan.modelHint;
    readyPlan.meta = sourcePlan.meta;
    readyPlan.conversationControl.followUpNeeded = false;
    readyPlan.conversationControl.followUpQuestion = '';
    readyPlan.conversationControl.reason = '';
    for (let index: number = 0; index < sourcePlan.intents.length; index++) {
      const intent: AgentIntent = sourcePlan.intents[index];
      if (!this.isIntentPendingFollowUp(intent)) {
        readyPlan.intents.push(intent);
      }
    }
    readyPlan.requestType = this.inferRequestTypeByIntents(readyPlan.intents);
    return readyPlan;
  }

  private inferRequestTypeByIntents(intents: Array<AgentIntent>): string {
    let hasQuery: boolean = false;
    let hasModify: boolean = false;
    for (let index: number = 0; index < intents.length; index++) {
      const intent: AgentIntent = intents[index];
      if (intent.action === 'create' || intent.action === 'update' || intent.action === 'delete') {
        hasModify = true;
      } else {
        hasQuery = true;
      }
    }
    if (hasQuery && hasModify) {
      return 'mixed';
    }
    if (hasModify) {
      return 'modify';
    }
    return 'query';
  }

  private isIntentPendingFollowUp(intent: AgentIntent): boolean {
    if (intent.domain === 'course' && intent.action === 'query') {
      const payload: AgentCourseQueryPayload = AgentJsonHelper.parseCourseQueryPayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    if (intent.domain === 'schedule' && intent.action === 'query') {
      const payload: AgentScheduleQueryPayload = AgentJsonHelper.parseScheduleQueryPayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    if (intent.domain === 'schedule' && intent.action === 'create') {
      const payload: AgentScheduleCreatePayload = AgentJsonHelper.parseScheduleCreatePayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    if (intent.domain === 'schedule' && intent.action === 'update') {
      const payload: AgentScheduleUpdatePayload = AgentJsonHelper.parseScheduleUpdatePayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    if (intent.domain === 'schedule' && intent.action === 'delete') {
      const payload: AgentScheduleDeletePayload = AgentJsonHelper.parseScheduleDeletePayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    if (intent.domain === 'settings' && intent.action === 'update') {
      const payload: AgentSettingsUpdatePayload = AgentJsonHelper.parseSettingsUpdatePayload(intent.payloadText);
      return payload.needsFollowUp;
    }
    return false;
  }

  private hasUnsupportedQueryIntent(plan: AgentPlanResult): boolean {
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.action !== 'query') {
        continue;
      }
      if (intent.domain !== 'course' && intent.domain !== 'schedule') {
        return true;
      }
    }
    return false;
  }


  private async executeLocalIntents(plan: AgentPlanResult): Promise<string> {
    const lines: Array<string> = [];
    const appContext: common.Context = this.getUIContext().getHostContext() as common.Context;
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain === 'schedule') {
        if (intent.action === 'create') {
          const result = TaskOperationService.createTaskFromPayload(intent.payloadText);
          lines.push(result.userText);
          if (result.success) {
            const command: AgentUiCommand = new AgentUiCommand();
            command.toastText = '日程创建成功';
            command.rootTabIndex = 0;
            command.calendarDate = result.taskDate;
            command.calendarViewType = 'day';
            command.focusTaskId = result.taskId;
            this.applyUiCommand(command);
          }
          continue;
        }
        if (intent.action === 'update') {
          const selectionPrompt: string = this.prepareTaskSelectionIfNeeded(intent, '修改');
          if (selectionPrompt.trim().length > 0) {
            lines.push(selectionPrompt);
            continue;
          }
          const result = TaskOperationService.updateTaskFromPayload(intent.payloadText);
          lines.push(result.userText);
          if (result.success) {
            const command: AgentUiCommand = new AgentUiCommand();
            command.toastText = result.affectedCount > 1 ? '日程批量修改成功' : '日程修改成功';
            command.rootTabIndex = 0;
            command.calendarDate = result.taskDate;
            command.calendarViewType = 'day';
            command.focusTaskId = result.taskId;
            this.applyUiCommand(command);
          }
          continue;
        }
        if (intent.action === 'delete') {
          const selectionPrompt: string = this.prepareTaskSelectionIfNeeded(intent, '删除');
          if (selectionPrompt.trim().length > 0) {
            lines.push(selectionPrompt);
            continue;
          }
          const result = TaskOperationService.deleteTaskFromPayload(intent.payloadText);
          lines.push(result.userText);
          if (result.success) {
            const command: AgentUiCommand = new AgentUiCommand();
            command.toastText = result.affectedCount > 1 ? '日程批量删除成功' : '日程删除成功';
            command.rootTabIndex = 0;
            command.calendarDate = result.taskDate;
            command.calendarViewType = 'day';
            this.applyUiCommand(command);
          }
          continue;
        }
      }
      if (intent.domain === 'settings' && intent.action === 'update') {
        const result: AgentExecutionResult = await this.executeSettingIntent(intent, appContext);
        if (result.userText.trim().length > 0) {
          lines.push(result.userText);
        }
        if (result.success) {
          this.applyUiCommand(result.uiCommand);
        }
      }
    }
    return lines.join('\n');
  }

  private prepareTaskSelectionIfNeeded(intent: AgentIntent, actionText: string): string {
    let candidates: Array<AgentTaskCandidateOption> = [];
    if (intent.action === 'update') {
      candidates = TaskOperationService.listUpdateCandidatesFromPayload(intent.payloadText);
    } else if (intent.action === 'delete') {
      candidates = TaskOperationService.listDeleteCandidatesFromPayload(intent.payloadText);
    }
    if (candidates.length <= 1) {
      return '';
    }
    if (candidates.length > 8) {
      return '匹配到的日程太多了，共 ' + candidates.length.toString() + ' 个。请再补充更准确的标题、地点、时间、备注或类型。';
    }
    if (this.pendingTaskSelection.active) {
      return '当前还有一个待选择的日程操作，请先完成上一条选择。';
    }
    const pending: AgentPendingTaskSelection = new AgentPendingTaskSelection();
    pending.active = true;
    pending.action = intent.action;
    pending.payloadText = intent.payloadText;
    pending.allowMultiple = true;
    pending.candidates = candidates;
    this.pendingTaskSelection = pending;
    return this.buildTaskCandidatePrompt(candidates, actionText);
  }

  private buildTaskCandidatePrompt(candidates: Array<AgentTaskCandidateOption>, actionText: string): string {
    const lines: Array<string> = [];
    lines.push('找到了多个可供' + actionText + '的日程，请回复序号。');
    for (let index: number = 0; index < candidates.length; index++) {
      lines.push((index + 1).toString() + '. ' + candidates[index].summaryText);
    }
    lines.push('可回复单个序号，也可回复多个序号（如 1,2），回复“取消”可放弃。');
    return lines.join('\n');
  }

  private parseSelectedCandidateIds(content: string, candidates: Array<AgentTaskCandidateOption>, allowMultiple: boolean): Array<string> {
    const normalized: string = content.replace(/，/g, ',').replace(/\s+/g, ',');
    const parts: Array<string> = normalized.split(',');
    const result: Array<string> = [];
    for (let index: number = 0; index < parts.length; index++) {
      const item: string = parts[index].trim();
      if (item.length === 0) {
        continue;
      }
      const value: number = Number(item);
      if (!Number.isFinite(value)) {
        return [];
      }
      const candidateIndex: number = Math.trunc(value) - 1;
      if (candidateIndex < 0 || candidateIndex >= candidates.length) {
        return [];
      }
      const taskId: string = candidates[candidateIndex].taskId;
      if (result.indexOf(taskId) < 0) {
        result.push(taskId);
      }
      if (!allowMultiple && result.length > 1) {
        return [];
      }
    }
    return result;
  }

  private async executeSettingIntent(intent: AgentIntent, context: common.Context): Promise<AgentExecutionResult> {
    const payload: AgentSettingsUpdatePayload = AgentJsonHelper.parseSettingsUpdatePayload(intent.payloadText);
    if (payload.settingKey === 'show_almanac') {
      return await AgentSettingService.setShowAlmanac(payload.enabled, context);
    }
    if (payload.settingKey === 'bottom_add_task_button') {
      return await AgentSettingService.setBottomAddTaskButtonEnabled(payload.enabled);
    }
    if (payload.settingKey === 'holding_hand_mode') {
      return await AgentSettingService.setHoldingHandModeEnabled(payload.enabled);
    }
    if (payload.settingKey === 'theme_color') {
      return await AgentSettingService.setThemeColor(payload.colorMode, payload.colorValue, context);
    }
    const result: AgentExecutionResult = new AgentExecutionResult();
    result.userText = '暂不支持该设置操作。';
    return result;
  }

  private applyUiCommand(command: AgentUiCommand): void {
    if (command.toastText.trim().length > 0) {
      this.getUIContext().getPromptAction().showToast({ message: command.toastText });
    }
    const jumpDelay: number = command.rootTabIndex >= 0 ? 80 : 0;
    if (command.rootTabIndex >= 0) {
      AgentUiBridge.switchRootTab(command.rootTabIndex);
    }
    if (command.calendarDate.trim().length > 0) {
      const targetDateText: string = command.calendarDate;
      const targetViewType: string = command.calendarViewType.trim().length > 0 ? command.calendarViewType : 'day';
      setTimeout(() => {
        AgentUiBridge.jumpCalendar(targetDateText, targetViewType);
      }, jumpDelay);
    }
    if (command.focusTaskId.trim().length > 0) {
      const focusTaskId: string = command.focusTaskId;
      setTimeout(() => {
        AgentUiBridge.focusTask(focusTaskId);
        this.scheduleTaskFocusClear();
      }, jumpDelay + 120);
    }
    if (command.focusCountDownId.trim().length > 0) {
      const focusCountDownId: string = command.focusCountDownId;
      setTimeout(() => {
        AgentUiBridge.focusCountDown(focusCountDownId);
        this.scheduleCountDownFocusClear();
      }, 80);
    }
    if (command.openPagePath.trim().length > 0) {
      this.getUIContext().getRouter().pushUrl({ url: command.openPagePath }, router.RouterMode.Standard);
    }
  }

  private scheduleTaskFocusClear(): void {
    if (this.taskFocusTimer !== undefined) {
      clearTimeout(this.taskFocusTimer);
    }
    this.taskFocusTimer = setTimeout(() => {
      AgentUiBridge.clearTaskFocus();
      this.taskFocusTimer = undefined;
    }, this.taskFocusDurationMs) as number;
  }

  private scheduleCountDownFocusClear(): void {
    if (this.countDownFocusTimer !== undefined) {
      clearTimeout(this.countDownFocusTimer);
    }
    this.countDownFocusTimer = setTimeout(() => {
      AgentUiBridge.clearCountDownFocus();
      this.countDownFocusTimer = undefined;
    }, this.countDownFocusDurationMs) as number;
  }

  @Builder
  private headerBuilder() {
    Column({ space: 4 }) {
      Text('辰光')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
      Text('问我日程、课程、黄历、节日，也可以直接让我执行操作')
        .fontSize(13)
        .fontColor('#7A7A7A')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({ left: 16, right: 16, top: this.topInset(), bottom: 10 })
    .backgroundColor('rgba(255,255,255,0.96)')
  }

  @Builder
  private inputBuilder() {
    Column({ space: 10 }) {
      if (this.pendingAction.active) {
        Row() {
          Text('当前有待确认的删除操作，请回复“确认删除”或“取消”。')
            .fontSize(12)
            .fontColor(this.themeColor)
            .width('100%')
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('rgba(255,245,230,0.95)')
        .borderRadius(12)
      }

      Row({ space: 10 }) {
        TextArea({ text: this.inputText, placeholder: '输入你想问辰光的问题' })
          .layoutWeight(1)
          .maxLines(3)
          .maxLength(1000)
          .fontSize(16)
          .backgroundColor('rgba(245,246,250,1)')
          .borderRadius(18)
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .onChange((value: string) => {
            this.inputText = value;
          })

        Button(this.isSending ? '处理中' : '发送')
          .type(ButtonType.Capsule)
          .width(82)
          .height(40)
          .fontSize(16)
          .fontColor(Color.White)
          .backgroundColor(this.isSending ? '#BDBDBD' : this.themeColor)
          .enabled(!this.isSending)
          .onClick(() => {
            this.submitInput();
          })
      }
      .width('100%')
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .height(140)
    .padding({ left: 12, right: 12,top : 5})
    .backgroundColor('rgba(255,255,255,0.5)')
  }

  build() {
    RelativeContainer(){
      Column() {
        Scroll(this.scroller) {
          Column({ space: 6 }) {
            ForEach(this.messages, (item: AgentChatMessage) => {
              AgentMessageBubble({ message: item })
            }, (item: AgentChatMessage) => item.id)
          }
          .width('100%')
          .padding({ top: 10, bottom: 20 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#F5F7FB')
        .align(Alignment.Top)
        .padding({top : 100})

        this.inputBuilder()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F7FB')

      HdsNavigation(){}
      .width('100%')
      .height('100%')
      .mode(NavigationMode.Stack)
      .padding({top : this.getUIContext().px2vp(this.topStatusBarHeight)})
      .hitTestBehavior(HitTestMode.Transparent)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM],[LayoutSafeAreaEdge.TOP])
      .titleBar({
        style : {
          scrollEffectOpts : {
            enableScrollEffect : false,
            scrollEffectType : ScrollEffectType.GRADIENT_BLUR,
          },
          systemMaterialEffect : {
            materialType : hdsMaterial.MaterialType.ADAPTIVE,
            materialLevel : hdsMaterial.MaterialLevel.ADAPTIVE
          }
        },
        content : {
          title : {
            mainTitle : '辰光智能体',
            mainTitleSize : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 35 :
              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? 30 : 25,
            subTitle : '可以问我日程、课程、黄历、节日、校园通知和新闻、学院通知等等，也可以让我直接执行操作',
          },
        },
        enableHoverMode : true,
      })
      .titleMode(HdsNavigationTitleMode.MINI)
      .hideBackButton(true)

      Column(){}
      .width('100%')
      .height(this.getUIContext().px2vp(this.topStatusBarHeight))
      .alignRules({
        left : {anchor : '__container__',align : HorizontalAlign.Start},
        top : {anchor : '__container__',align : VerticalAlign.Top}
      })
      .backgroundColor('rgba(240,240,240,0.82)')
      .backdropBlur(11)
    }
  }
}