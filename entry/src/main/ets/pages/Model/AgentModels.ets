export enum AgentSender {
  User = 'user',
  Assistant = 'assistant',
  System = 'system'
}

export enum AgentMessageStatus {
  Idle = 'idle',
  Thinking = 'thinking',
  Streaming = 'streaming',
  Done = 'done',
  Error = 'error'
}

export enum AgentActionName {
  CreateTask = 'create_task',
  UpdateTask = 'update_task',
  DeleteTask = 'delete_task',
  CreateCountDown = 'create_countdown',
  DeleteCountDown = 'delete_countdown',
  JumpToDate = 'jump_to_date',
  OpenPage = 'open_page',
  SetShowAlmanac = 'set_show_almanac',
  SetThemeColor = 'set_theme_color',
  SetBottomAddTaskButton = 'set_bottom_add_task_button',
  SetHoldingHandMode = 'set_holding_hand_mode'
}

@Observed
export class AgentChatMessage {
  id: string = '';
  sender: AgentSender = AgentSender.Assistant;
  text: string = '';
  status: AgentMessageStatus = AgentMessageStatus.Idle;
  createdAt: number = 0;

  constructor(id: string = '', sender: AgentSender = AgentSender.Assistant, text: string = '',
    status: AgentMessageStatus = AgentMessageStatus.Idle, createdAt: number = 0) {
    this.id = id;
    this.sender = sender;
    this.text = text;
    this.status = status;
    this.createdAt = createdAt;
  }
}

export class AgentHistoryMessage {
  role: string = '';
  content: string = '';
}

export class AgentPlanRequest {
  sessionId: string = '';
  userMessage: string = '';
  nowIso: string = '';
  timezone: string = 'Asia/Shanghai';
  recentMessages: Array<AgentHistoryMessage> = [];
}

export class AgentConversationControl {
  followUpNeeded: boolean = false;
  followUpQuestion: string = '';
  reason: string = '';
}

export class AgentIntentMeta {
  language: string = 'zh-CN';
  now: string = '';
  timezone: string = 'Asia/Shanghai';
}

export class AgentIntent {
  domain: string = '';
  action: string = '';
  confidence: number = 0;
  payloadText: string = '{}';
}

export class AgentPlanResult {
  success: boolean = false;
  requestType: string = 'query';
  intents: Array<AgentIntent> = [];
  conversationControl: AgentConversationControl = new AgentConversationControl();
  meta: AgentIntentMeta = new AgentIntentMeta();
  modelHint: string = '';

  public hasDomain(domain: string): boolean {
    for (let index: number = 0; index < this.intents.length; index++) {
      if (this.intents[index].domain === domain) {
        return true;
      }
    }
    return false;
  }

  public hasActionIntent(): boolean {
    for (let index: number = 0; index < this.intents.length; index++) {
      const intent: AgentIntent = this.intents[index];
      if (intent.action === 'create' || intent.action === 'update' || intent.action === 'delete') {
        return true;
      }
    }
    return false;
  }

  public needsCampusData(): boolean {
    return this.hasDomain('campus');
  }

  public needsLocalData(): boolean {
    for (let index: number = 0; index < this.intents.length; index++) {
      const domain: string = this.intents[index].domain;
      if (domain === 'course' || domain === 'schedule' || domain === 'almanac' || domain === 'festival' ||
        domain === 'solarTerm' || domain === 'countdown') {
        return true;
      }
    }
    return false;
  }

  public needsFinalAnswer(): boolean {
    return this.requestType !== 'modify';
  }
}

export class AgentChatRequest {
  sessionId: string = '';
  userMessage: string = '';
  nowIso: string = '';
  timezone: string = 'Asia/Shanghai';
  recentMessages: Array<AgentHistoryMessage> = [];
  intentJson: string = '';
  localReferenceJson: string = '';
  actionSummaryText: string = '';
}

export class AgentSocketFrame {
  type: string = '';
  text: string = '';
  message: string = '';
  code: string = '';
  sessionId: string = '';
  time: string = '';
}

export class AgentPendingAction {
  active: boolean = false;
  name: string = '';
  argumentsText: string = '';
  description: string = '';
}

export class AgentUiCommand {
  toastText: string = '';
  rootTabIndex: number = -1;
  openPagePath: string = '';
  calendarDate: string = '';
  calendarViewType: string = '';
  focusTaskId: string = '';
  focusCountDownId: string = '';
}

export class AgentExecutionResult {
  success: boolean = false;
  needConfirm: boolean = false;
  actionName: string = '';
  userText: string = '';
  uiCommand: AgentUiCommand = new AgentUiCommand();
}

export class AgentNowContext {
  iso: string = '';
  dateText: string = '';
  timeText: string = '';
  weekdayText: string = '';
  hour: number = 0;
  minute: number = 0;
}

export class AgentTimePayload {
  originalText: string = '';
  resolvedDate: string = '';
  startDateTime: string = '';
  endDateTime: string = '';
  timePeriod: string = '';
  precision: string = '';
  isRelative: boolean = false;
}

export class AgentStringList {
  items: Array<string> = [];
}

export class AgentCourseFilterPayload {
  courseNameKeywords: Array<string> = [];
  teacherName: string = '';
  locationKeywords: Array<string> = [];
  weekType: string = '';
  weekdayText: string = '';
  weekIndex: number = 0;
}

export class AgentCourseQueryPayload {
  queryKind: string = '';
  time: AgentTimePayload = new AgentTimePayload();
  filters: AgentCourseFilterPayload = new AgentCourseFilterPayload();
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentTaskContextItem {
  id: string = '';
  title: string = '';
  date: string = '';
  startTime: string = '';
  endTime: string = '';
  location: string = '';
  detail: string = '';
  taskType: string = '';
  statusText: string = '';
}

export class AgentCourseContextItem {
  id: string = '';
  courseName: string = '';
  teacherName: string = '';
  classroom: string = '';
  date: string = '';
  weekText: string = '';
  startTime: string = '';
  endTime: string = '';
  sectionText: string = '';
  statusText: string = '';
}

export class AgentDateContextItem {
  date: string = '';
  weekText: string = '';
  lunarDateText: string = '';
  festivalText: string = '';
  otherFestivalText: string = '';
  solarTermText: string = '';
}

export class AgentAlmanacTimeContextItem {
  shiChenText: string = '';
  beginTime: string = '';
  endTime: string = '';
  jiOrXiong: string = '';
  yiText: string = '';
  jiText: string = '';
  chongText: string = '';
  shaText: string = '';
  luckyDirection: string = '';
  godOfWealth: string = '';
}

export class AgentAlmanacContextItem {
  date: string = '';
  lunarYearText: string = '';
  lunarMonthText: string = '';
  lunarDayText: string = '';
  yiText: string = '';
  jiText: string = '';
  ganZhiText: string = '';
  shengXiaoText: string = '';
  chongShaText: string = '';
  jiShenText: string = '';
  xiongShaText: string = '';
  caiPositionText: string = '';
  xiPositionText: string = '';
  fuPositionText: string = '';
  luckyDirectionText: string = '';
  godOfWealthText: string = '';
  wuxingText: string = '';
  taiShenText: string = '';
  pengZuText: string = '';
  twelveZhiXingText: string = '';
  auspiciousHours: Array<AgentAlmanacTimeContextItem> = [];
}

export class AgentFestivalContextItem {
  targetName: string = '';
  dateText: string = '';
  countdownDays: number = 0;
  detailText: string = '';
}

export class AgentSolarTermContextItem {
  targetName: string = '';
  dateText: string = '';
  countdownDays: number = 0;
  detailText: string = '';
}

export class AgentCountDownContextItem {
  id: string = '';
  title: string = '';
  targetDate: string = '';
  targetDateTime: string = '';
  detail: string = '';
  statusText: string = '';
  isExpired: boolean = false;
  daysRemaining: number = 0;
}

export class AgentScheduleSlot {
  startTime: string = '';
  endTime: string = '';
  label: string = '';
}

export class AgentScheduleDayAnalysis {
  date: string = '';
  busyText: string = '';
  freeText: string = '';
  summaryText: string = '';
  freeSlots: Array<AgentScheduleSlot> = [];
}

export class AgentSettingsContext {
  showAlmanac: boolean = true;
  themeColor: string = '#EA5C2E';
  bottomAddTaskButtonEnabled: boolean = true;
  holdingHandModeEnabled: boolean = true;
}

export class AgentLocalContext {
  now: AgentNowContext = new AgentNowContext();
  tasks: Array<AgentTaskContextItem> = [];
  courses: Array<AgentCourseContextItem> = [];
  dateItems: Array<AgentDateContextItem> = [];
  almanacItems: Array<AgentAlmanacContextItem> = [];
  festivals: Array<AgentFestivalContextItem> = [];
  solarTerms: Array<AgentSolarTermContextItem> = [];
  countdowns: Array<AgentCountDownContextItem> = [];
  scheduleDays: Array<AgentScheduleDayAnalysis> = [];
  settings: AgentSettingsContext = new AgentSettingsContext();
  hintText: string = '';

  public toJsonText(): string {
    return JSON.stringify(this);
  }
}

export class AgentScheduleFilterPayload {
  titleKeywords: Array<string> = [];
  locationKeywords: Array<string> = [];
  noteKeywords: Array<string> = [];
  category: string = '';
  reminderMinutes: number = -1;
}

export class AgentScheduleQueryPayload {
  queryKind: string = '';
  time: AgentTimePayload = new AgentTimePayload();
  includeFreeTime: boolean = false;
  filters: AgentScheduleFilterPayload = new AgentScheduleFilterPayload();
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentReminderPayload {
  enabled: boolean = false;
  minutesBefore: number = -1;
}

export class AgentScheduleCreatePayload {
  title: string = '';
  time: AgentTimePayload = new AgentTimePayload();
  location: string = '';
  note: string = '';
  isAllDay: boolean = false;
  reminder: AgentReminderPayload = new AgentReminderPayload();
  category: string = '';
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentScheduleLocatorPayload {
  titleKeywords: Array<string> = [];
  locationKeywords: Array<string> = [];
  noteKeywords: Array<string> = [];
  category: string = '';
  reminderMinutes: number = -1;
  time: AgentTimePayload = new AgentTimePayload();
}

export class AgentScheduleUpdateChangesPayload {
  title: string = '';
  time: AgentTimePayload = new AgentTimePayload();
  location: string = '';
  note: string = '';
  isAllDay: boolean = false;
  reminder: AgentReminderPayload = new AgentReminderPayload();
  category: string = '';
}

export class AgentScheduleUpdatePayload {
  locator: AgentScheduleLocatorPayload = new AgentScheduleLocatorPayload();
  changes: AgentScheduleUpdateChangesPayload = new AgentScheduleUpdateChangesPayload();
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentScheduleDeletePayload {
  locator: AgentScheduleLocatorPayload = new AgentScheduleLocatorPayload();
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentAlmanacQueryPayload {
  queryKind: string = '';
  time: AgentTimePayload = new AgentTimePayload();
  focus: Array<string> = [];
}

export class AgentFestivalQueryPayload {
  queryKind: string = '';
  targetName: string = '';
  time: AgentTimePayload = new AgentTimePayload();
}

export class AgentSolarTermQueryPayload {
  queryKind: string = '';
  targetName: string = '';
  time: AgentTimePayload = new AgentTimePayload();
}

export class AgentCampusTimeRange {
  startDate: string = '';
  endDate: string = '';
}

export class AgentCampusQueryPayload {
  queryKind: string = '';
  schoolPart: string = '';
  collegeName: string = '';
  teacherName: string = '';
  timeRange: AgentCampusTimeRange = new AgentCampusTimeRange();
  keywords: Array<string> = [];
  articleType: string = '';
  sourceName: string = '';
  retrievalQuery: string = '';
}

export class AgentCountDownQueryPayload {
  queryKind: string = '';
  targetName: string = '';
  includeExpired: boolean = false;
}

export class AgentCountDownCreatePayload {
  title: string = '';
  targetDateTime: string = '';
  detail: string = '';
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentCountDownDeletePayload {
  title: string = '';
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentDirectChatPayload {
  topic: string = '';
  needsInternalData: boolean = false;
}


export class AgentCreateTaskArgs {
  title: string = '';
  date: string = '';
  startTime: string = '';
  endTime: string = '';
  location: string = '';
  detail: string = '';
}

export class AgentTaskQueryArgs {
  date: string = '';
  title: string = '';
}

export class AgentTaskPatchArgs {
  title: string = '';
  date: string = '';
  startTime: string = '';
  endTime: string = '';
  location: string = '';
  detail: string = '';
}

export class AgentUpdateTaskArgs {
  query: AgentTaskQueryArgs = new AgentTaskQueryArgs();
  patch: AgentTaskPatchArgs = new AgentTaskPatchArgs();
}

export class AgentDeleteTaskArgs {
  date: string = '';
  title: string = '';
}

export class AgentTaskOperationResult {
  success: boolean = false;
  taskId: string = '';
  taskDate: string = '';
  userText: string = '';
  affectedCount: number = 0;
}

export class AgentTaskCandidateOption {
  taskId: string = '';
  taskDate: string = '';
  summaryText: string = '';
}

export class AgentPendingTaskSelection {
  active: boolean = false;
  action: string = '';
  payloadText: string = '';
  allowMultiple: boolean = false;
  candidates: Array<AgentTaskCandidateOption> = [];
}

export class AgentCreateCountDownArgs {
  title: string = '';
  targetDate: string = '';
  detail: string = '';
}

export class AgentDeleteCountDownArgs {
  title: string = '';
}

export class AgentJumpToDateArgs {
  date: string = '';
  viewType: string = 'day';
}

export class AgentOpenPageArgs {
  page: string = '';
}

export class AgentSetShowAlmanacArgs {
  show: boolean = true;
}

export class AgentSetThemeColorArgs {
  mode: string = '';
  value: string = '';
}

export class AgentSettingsUpdatePayload {
  settingKey: string = '';
  enabled: boolean = true;
  colorMode: string = '';
  colorValue: string = '';
  missingFields: Array<string> = [];
  needsFollowUp: boolean = false;
}

export class AgentCountDownOperationResult {
  success: boolean = false;
  countDownId: string = '';
  userText: string = '';
}
