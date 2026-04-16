import {
  AgentAlmanacQueryPayload,
  AgentCampusQueryPayload,
  AgentCampusTimeRange,
  AgentChatRequest,
  AgentConversationControl,
  AgentCourseFilterPayload,
  AgentCourseQueryPayload,
  AgentCreateCountDownArgs,
  AgentCreateTaskArgs,
  AgentDeleteCountDownArgs,
  AgentDeleteTaskArgs,
  AgentDirectChatPayload,
  AgentFestivalQueryPayload,
  AgentHistoryMessage,
  AgentIntent,
  AgentIntentMeta,
  AgentJumpToDateArgs,
  AgentOpenPageArgs,
  AgentPlanRequest,
  AgentPlanResult,
  AgentReminderPayload,
  AgentSetShowAlmanacArgs,
  AgentSetThemeColorArgs,
  AgentScheduleCreatePayload,
  AgentScheduleDeletePayload,
  AgentScheduleFilterPayload,
  AgentScheduleLocatorPayload,
  AgentScheduleQueryPayload,
  AgentScheduleUpdateChangesPayload,
  AgentScheduleUpdatePayload,
  AgentSettingsUpdatePayload,
  AgentSocketFrame,
  AgentSolarTermQueryPayload,
  AgentTaskPatchArgs,
  AgentTaskQueryArgs,
  AgentTimePayload,
  AgentUpdateTaskArgs
} from '../Model/AgentModels';

class AgentRecentMessageInput {
  sender: string = '';
  text: string = '';
}

export class AgentJsonHelper {
  public static stringifyPlanRequest(request: AgentPlanRequest): string {
    return JSON.stringify(request);
  }

  public static stringifyChatRequest(request: AgentChatRequest): string {
    return JSON.stringify(request);
  }

  public static parsePlanResult(text: string): AgentPlanResult {
    const result: AgentPlanResult = new AgentPlanResult();
    result.success = AgentJsonHelper.extractBooleanValue(text, 'success', false);
    result.requestType = AgentJsonHelper.extractStringValue(text, 'requestType', 'query');
    result.modelHint = AgentJsonHelper.extractStringValue(text, 'modelHint', '');
    result.conversationControl = AgentJsonHelper.parseConversationControlText(
      AgentJsonHelper.extractObjectText(text, 'conversationControl')
    );
    result.meta = AgentJsonHelper.parseMetaText(AgentJsonHelper.extractObjectText(text, 'meta'));
    result.intents = AgentJsonHelper.parseIntentListText(AgentJsonHelper.extractArrayText(text, 'intents'));
    return result;
  }

  public static parseSocketFrame(text: string): AgentSocketFrame {
    const frame: AgentSocketFrame = new AgentSocketFrame();
    const raw: AgentSocketFrame | null = AgentJsonHelper.parseJsonObject<AgentSocketFrame>(text);
    if (raw === null) {
      return frame;
    }
    frame.type = AgentJsonHelper.normalizeString(raw.type);
    frame.text = AgentJsonHelper.normalizeString(raw.text);
    frame.message = AgentJsonHelper.normalizeString(raw.message);
    frame.code = AgentJsonHelper.normalizeString(raw.code);
    frame.sessionId = AgentJsonHelper.normalizeString(raw.sessionId);
    frame.time = AgentJsonHelper.normalizeString(raw.time);
    return frame;
  }

  public static parseCourseQueryPayload(text: string): AgentCourseQueryPayload {
    const payload: AgentCourseQueryPayload = new AgentCourseQueryPayload();
    const raw: AgentCourseQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentCourseQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'list_courses');
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    payload.filters = AgentJsonHelper.copyCourseFilterPayload(raw.filters);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static parseScheduleQueryPayload(text: string): AgentScheduleQueryPayload {
    const payload: AgentScheduleQueryPayload = new AgentScheduleQueryPayload();
    const raw: AgentScheduleQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentScheduleQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'list_schedule');
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    payload.includeFreeTime = raw.includeFreeTime;
    payload.filters = AgentJsonHelper.copyScheduleFilterPayload(raw.filters);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static parseScheduleCreatePayload(text: string): AgentScheduleCreatePayload {
    const payload: AgentScheduleCreatePayload = new AgentScheduleCreatePayload();
    const raw: AgentScheduleCreatePayload | null = AgentJsonHelper.parseJsonObject<AgentScheduleCreatePayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.title = AgentJsonHelper.normalizeString(raw.title);
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    payload.location = AgentJsonHelper.normalizeString(raw.location);
    payload.note = AgentJsonHelper.normalizeString(raw.note);
    payload.isAllDay = raw.isAllDay;
    payload.reminder = AgentJsonHelper.copyReminderPayload(raw.reminder);
    payload.category = AgentJsonHelper.normalizeString(raw.category);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static parseScheduleUpdatePayload(text: string): AgentScheduleUpdatePayload {
    const payload: AgentScheduleUpdatePayload = new AgentScheduleUpdatePayload();
    const raw: AgentScheduleUpdatePayload | null = AgentJsonHelper.parseJsonObject<AgentScheduleUpdatePayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.locator = AgentJsonHelper.copyScheduleLocatorPayload(raw.locator);
    payload.changes = AgentJsonHelper.copyScheduleUpdateChangesPayload(raw.changes);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static parseScheduleDeletePayload(text: string): AgentScheduleDeletePayload {
    const payload: AgentScheduleDeletePayload = new AgentScheduleDeletePayload();
    const raw: AgentScheduleDeletePayload | null = AgentJsonHelper.parseJsonObject<AgentScheduleDeletePayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.locator = AgentJsonHelper.copyScheduleLocatorPayload(raw.locator);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static parseAlmanacQueryPayload(text: string): AgentAlmanacQueryPayload {
    const payload: AgentAlmanacQueryPayload = new AgentAlmanacQueryPayload();
    const raw: AgentAlmanacQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentAlmanacQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'interpret');
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    payload.focus = AgentJsonHelper.copyStringArray(raw.focus);
    return payload;
  }

  public static parseFestivalQueryPayload(text: string): AgentFestivalQueryPayload {
    const payload: AgentFestivalQueryPayload = new AgentFestivalQueryPayload();
    const raw: AgentFestivalQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentFestivalQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'today_festivals');
    payload.targetName = AgentJsonHelper.normalizeString(raw.targetName);
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    return payload;
  }

  public static parseSolarTermQueryPayload(text: string): AgentSolarTermQueryPayload {
    const payload: AgentSolarTermQueryPayload = new AgentSolarTermQueryPayload();
    const raw: AgentSolarTermQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentSolarTermQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'today_solar_term');
    payload.targetName = AgentJsonHelper.normalizeString(raw.targetName);
    payload.time = AgentJsonHelper.copyTimePayload(raw.time);
    return payload;
  }

  public static parseCampusQueryPayload(text: string): AgentCampusQueryPayload {
    const payload: AgentCampusQueryPayload = new AgentCampusQueryPayload();
    const raw: AgentCampusQueryPayload | null = AgentJsonHelper.parseJsonObject<AgentCampusQueryPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.queryKind = AgentJsonHelper.normalizeString(raw.queryKind, 'general_campus_query');
    payload.schoolPart = AgentJsonHelper.normalizeString(raw.schoolPart);
    payload.collegeName = AgentJsonHelper.normalizeString(raw.collegeName);
    payload.teacherName = AgentJsonHelper.normalizeString(raw.teacherName);
    payload.timeRange = AgentJsonHelper.copyCampusTimeRange(raw.timeRange);
    payload.keywords = AgentJsonHelper.copyStringArray(raw.keywords);
    payload.articleType = AgentJsonHelper.normalizeString(raw.articleType);
    payload.sourceName = AgentJsonHelper.normalizeString(raw.sourceName);
    payload.retrievalQuery = AgentJsonHelper.normalizeString(raw.retrievalQuery);
    return payload;
  }

  public static parseDirectChatPayload(text: string): AgentDirectChatPayload {
    const payload: AgentDirectChatPayload = new AgentDirectChatPayload();
    const raw: AgentDirectChatPayload | null = AgentJsonHelper.parseJsonObject<AgentDirectChatPayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.topic = AgentJsonHelper.normalizeString(raw.topic);
    payload.needsInternalData = raw.needsInternalData;
    return payload;
  }

  public static parseCreateTaskArgs(text: string): AgentCreateTaskArgs {
    const args: AgentCreateTaskArgs = new AgentCreateTaskArgs();
    const raw: AgentCreateTaskArgs | null = AgentJsonHelper.parseJsonObject<AgentCreateTaskArgs>(text);
    if (raw === null) {
      return args;
    }
    args.title = AgentJsonHelper.normalizeString(raw.title);
    args.date = AgentJsonHelper.normalizeString(raw.date);
    args.startTime = AgentJsonHelper.normalizeString(raw.startTime);
    args.endTime = AgentJsonHelper.normalizeString(raw.endTime);
    args.location = AgentJsonHelper.normalizeString(raw.location);
    args.detail = AgentJsonHelper.normalizeString(raw.detail);
    return args;
  }

  public static parseUpdateTaskArgs(text: string): AgentUpdateTaskArgs {
    const args: AgentUpdateTaskArgs = new AgentUpdateTaskArgs();
    const raw: AgentUpdateTaskArgs | null = AgentJsonHelper.parseJsonObject<AgentUpdateTaskArgs>(text);
    if (raw === null) {
      return args;
    }
    args.query = AgentJsonHelper.copyTaskQueryArgs(raw.query);
    args.patch = AgentJsonHelper.copyTaskPatchArgs(raw.patch);
    return args;
  }

  public static parseDeleteTaskArgs(text: string): AgentDeleteTaskArgs {
    const args: AgentDeleteTaskArgs = new AgentDeleteTaskArgs();
    const raw: AgentDeleteTaskArgs | null = AgentJsonHelper.parseJsonObject<AgentDeleteTaskArgs>(text);
    if (raw === null) {
      return args;
    }
    args.date = AgentJsonHelper.normalizeString(raw.date);
    args.title = AgentJsonHelper.normalizeString(raw.title);
    return args;
  }

  public static parseCreateCountDownArgs(text: string): AgentCreateCountDownArgs {
    const args: AgentCreateCountDownArgs = new AgentCreateCountDownArgs();
    const raw: AgentCreateCountDownArgs | null = AgentJsonHelper.parseJsonObject<AgentCreateCountDownArgs>(text);
    if (raw === null) {
      return args;
    }
    args.title = AgentJsonHelper.normalizeString(raw.title);
    args.targetDate = AgentJsonHelper.normalizeString(raw.targetDate);
    args.detail = AgentJsonHelper.normalizeString(raw.detail);
    return args;
  }

  public static parseDeleteCountDownArgs(text: string): AgentDeleteCountDownArgs {
    const args: AgentDeleteCountDownArgs = new AgentDeleteCountDownArgs();
    const raw: AgentDeleteCountDownArgs | null = AgentJsonHelper.parseJsonObject<AgentDeleteCountDownArgs>(text);
    if (raw === null) {
      return args;
    }
    args.title = AgentJsonHelper.normalizeString(raw.title);
    return args;
  }

  public static parseCountDownCreatePayload(text: string): AgentCreateCountDownArgs {
    return AgentJsonHelper.parseCreateCountDownArgs(text);
  }

  public static parseCountDownDeletePayload(text: string): AgentDeleteCountDownArgs {
    return AgentJsonHelper.parseDeleteCountDownArgs(text);
  }

  public static parseJumpToDateArgs(text: string): AgentJumpToDateArgs {
    const args: AgentJumpToDateArgs = new AgentJumpToDateArgs();
    const raw: AgentJumpToDateArgs | null = AgentJsonHelper.parseJsonObject<AgentJumpToDateArgs>(text);
    if (raw === null) {
      return args;
    }
    args.date = AgentJsonHelper.normalizeString(raw.date);
    args.viewType = AgentJsonHelper.normalizeString(raw.viewType, 'day');
    return args;
  }

  public static parseOpenPageArgs(text: string): AgentOpenPageArgs {
    const args: AgentOpenPageArgs = new AgentOpenPageArgs();
    const raw: AgentOpenPageArgs | null = AgentJsonHelper.parseJsonObject<AgentOpenPageArgs>(text);
    if (raw === null) {
      return args;
    }
    args.page = AgentJsonHelper.normalizeString(raw.page);
    return args;
  }

  public static parseSetShowAlmanacArgs(text: string): AgentSetShowAlmanacArgs {
    const args: AgentSetShowAlmanacArgs = new AgentSetShowAlmanacArgs();
    const raw: AgentSetShowAlmanacArgs | null = AgentJsonHelper.parseJsonObject<AgentSetShowAlmanacArgs>(text);
    if (raw === null) {
      return args;
    }
    args.show = raw.show;
    return args;
  }

  public static parseSetThemeColorArgs(text: string): AgentSetThemeColorArgs {
    const args: AgentSetThemeColorArgs = new AgentSetThemeColorArgs();
    const raw: AgentSetThemeColorArgs | null = AgentJsonHelper.parseJsonObject<AgentSetThemeColorArgs>(text);
    if (raw === null) {
      return args;
    }
    args.mode = AgentJsonHelper.normalizeString(raw.mode);
    args.value = AgentJsonHelper.normalizeString(raw.value);
    return args;
  }


  public static parseSettingsUpdatePayload(text: string): AgentSettingsUpdatePayload {
    const payload: AgentSettingsUpdatePayload = new AgentSettingsUpdatePayload();
    const raw: AgentSettingsUpdatePayload | null = AgentJsonHelper.parseJsonObject<AgentSettingsUpdatePayload>(text);
    if (raw === null) {
      return payload;
    }
    payload.settingKey = AgentJsonHelper.normalizeString(raw.settingKey);
    payload.enabled = raw.enabled;
    payload.colorMode = AgentJsonHelper.normalizeString(raw.colorMode);
    payload.colorValue = AgentJsonHelper.normalizeString(raw.colorValue);
    payload.missingFields = AgentJsonHelper.copyStringArray(raw.missingFields);
    payload.needsFollowUp = raw.needsFollowUp;
    return payload;
  }

  public static buildRecentMessages(messages: Array<AgentRecentMessageInput>): Array<AgentHistoryMessage> {
    const result: Array<AgentHistoryMessage> = [];
    for (let index: number = 0; index < messages.length; index++) {
      const item: AgentRecentMessageInput = messages[index];
      const history: AgentHistoryMessage = new AgentHistoryMessage();
      history.role = item.sender === 'user' ? 'user' : 'assistant';
      history.content = item.text;
      result.push(history);
    }
    return result;
  }

  private static parseJsonObject<T>(text: string): T | null {
    if (text.trim().length === 0) {
      return null;
    }
    try {
      return JSON.parse(text) as T;
    } catch (_error) {
      return null;
    }
  }

  private static normalizeString(value: string | null | undefined, fallback: string = ''): string {
    return value !== undefined && value !== null ? value : fallback;
  }

  private static copyStringArray(source: Array<string> | null | undefined): Array<string> {
    const result: Array<string> = [];
    if (source === undefined || source === null) {
      return result;
    }
    for (let index: number = 0; index < source.length; index++) {
      const item: string = source[index];
      if (item !== undefined && item !== null) {
        result.push(item);
      }
    }
    return result;
  }

  private static copyTimePayload(source: AgentTimePayload | null | undefined): AgentTimePayload {
    const payload: AgentTimePayload = new AgentTimePayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.originalText = AgentJsonHelper.normalizeString(source.originalText);
    payload.resolvedDate = AgentJsonHelper.normalizeString(source.resolvedDate);
    payload.startDateTime = AgentJsonHelper.normalizeString(source.startDateTime);
    payload.endDateTime = AgentJsonHelper.normalizeString(source.endDateTime);
    payload.timePeriod = AgentJsonHelper.normalizeString(source.timePeriod);
    payload.precision = AgentJsonHelper.normalizeString(source.precision);
    payload.isRelative = source.isRelative;
    return payload;
  }

  private static copyCourseFilterPayload(source: AgentCourseFilterPayload | null | undefined): AgentCourseFilterPayload {
    const payload: AgentCourseFilterPayload = new AgentCourseFilterPayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.courseNameKeywords = AgentJsonHelper.copyStringArray(source.courseNameKeywords);
    payload.teacherName = AgentJsonHelper.normalizeString(source.teacherName);
    payload.locationKeywords = AgentJsonHelper.copyStringArray(source.locationKeywords);
    payload.weekType = AgentJsonHelper.normalizeString(source.weekType);
    payload.weekdayText = AgentJsonHelper.normalizeString(source.weekdayText);
    payload.weekIndex = source.weekIndex;
    return payload;
  }

  private static copyScheduleFilterPayload(source: AgentScheduleFilterPayload | null | undefined): AgentScheduleFilterPayload {
    const payload: AgentScheduleFilterPayload = new AgentScheduleFilterPayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.titleKeywords = AgentJsonHelper.copyStringArray(source.titleKeywords);
    payload.locationKeywords = AgentJsonHelper.copyStringArray(source.locationKeywords);
    payload.noteKeywords = AgentJsonHelper.copyStringArray(source.noteKeywords);
    payload.category = AgentJsonHelper.normalizeString(source.category);
    payload.reminderMinutes = source.reminderMinutes ?? -1;
    return payload;
  }

  private static copyReminderPayload(source: AgentReminderPayload | null | undefined): AgentReminderPayload {
    const payload: AgentReminderPayload = new AgentReminderPayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.enabled = source.enabled;
    payload.minutesBefore = source.minutesBefore;
    return payload;
  }

  private static copyScheduleLocatorPayload(source: AgentScheduleLocatorPayload | null | undefined): AgentScheduleLocatorPayload {
    const payload: AgentScheduleLocatorPayload = new AgentScheduleLocatorPayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.titleKeywords = AgentJsonHelper.copyStringArray(source.titleKeywords);
    payload.locationKeywords = AgentJsonHelper.copyStringArray(source.locationKeywords);
    payload.noteKeywords = AgentJsonHelper.copyStringArray(source.noteKeywords);
    payload.category = AgentJsonHelper.normalizeString(source.category);
    payload.reminderMinutes = source.reminderMinutes ?? -1;
    payload.time = AgentJsonHelper.copyTimePayload(source.time);
    return payload;
  }

  private static copyScheduleUpdateChangesPayload(source: AgentScheduleUpdateChangesPayload | null | undefined): AgentScheduleUpdateChangesPayload {
    const payload: AgentScheduleUpdateChangesPayload = new AgentScheduleUpdateChangesPayload();
    if (source === undefined || source === null) {
      return payload;
    }
    payload.title = AgentJsonHelper.normalizeString(source.title);
    payload.time = AgentJsonHelper.copyTimePayload(source.time);
    payload.location = AgentJsonHelper.normalizeString(source.location);
    payload.note = AgentJsonHelper.normalizeString(source.note);
    payload.isAllDay = source.isAllDay;
    payload.reminder = AgentJsonHelper.copyReminderPayload(source.reminder);
    payload.category = AgentJsonHelper.normalizeString(source.category);
    return payload;
  }

  private static copyCampusTimeRange(source: AgentCampusTimeRange | null | undefined): AgentCampusTimeRange {
    const range: AgentCampusTimeRange = new AgentCampusTimeRange();
    if (source === undefined || source === null) {
      return range;
    }
    range.startDate = AgentJsonHelper.normalizeString(source.startDate);
    range.endDate = AgentJsonHelper.normalizeString(source.endDate);
    return range;
  }

  private static copyTaskQueryArgs(source: AgentTaskQueryArgs | null | undefined): AgentTaskQueryArgs {
    const args: AgentTaskQueryArgs = new AgentTaskQueryArgs();
    if (source === undefined || source === null) {
      return args;
    }
    args.date = AgentJsonHelper.normalizeString(source.date);
    args.title = AgentJsonHelper.normalizeString(source.title);
    return args;
  }

  private static copyTaskPatchArgs(source: AgentTaskPatchArgs | null | undefined): AgentTaskPatchArgs {
    const args: AgentTaskPatchArgs = new AgentTaskPatchArgs();
    if (source === undefined || source === null) {
      return args;
    }
    args.title = AgentJsonHelper.normalizeString(source.title);
    args.date = AgentJsonHelper.normalizeString(source.date);
    args.startTime = AgentJsonHelper.normalizeString(source.startTime);
    args.endTime = AgentJsonHelper.normalizeString(source.endTime);
    args.location = AgentJsonHelper.normalizeString(source.location);
    args.detail = AgentJsonHelper.normalizeString(source.detail);
    return args;
  }

  private static parseConversationControlText(text: string): AgentConversationControl {
    const control: AgentConversationControl = new AgentConversationControl();
    const raw: AgentConversationControl | null = AgentJsonHelper.parseJsonObject<AgentConversationControl>(text);
    if (raw === null) {
      return control;
    }
    control.followUpNeeded = raw.followUpNeeded;
    control.followUpQuestion = AgentJsonHelper.normalizeString(raw.followUpQuestion);
    control.reason = AgentJsonHelper.normalizeString(raw.reason);
    return control;
  }

  private static parseMetaText(text: string): AgentIntentMeta {
    const meta: AgentIntentMeta = new AgentIntentMeta();
    const raw: AgentIntentMeta | null = AgentJsonHelper.parseJsonObject<AgentIntentMeta>(text);
    if (raw === null) {
      return meta;
    }
    meta.language = AgentJsonHelper.normalizeString(raw.language, 'zh-CN');
    meta.now = AgentJsonHelper.normalizeString(raw.now);
    meta.timezone = AgentJsonHelper.normalizeString(raw.timezone, 'Asia/Shanghai');
    return meta;
  }

  private static parseIntentListText(arrayText: string): Array<AgentIntent> {
    const result: Array<AgentIntent> = [];
    const objectTexts: Array<string> = AgentJsonHelper.splitTopLevelObjects(arrayText);
    for (let index: number = 0; index < objectTexts.length; index++) {
      const objectText: string = objectTexts[index];
      const intent: AgentIntent = new AgentIntent();
      intent.domain = AgentJsonHelper.extractStringValue(objectText, 'domain', '');
      intent.action = AgentJsonHelper.extractStringValue(objectText, 'action', 'query');
      intent.confidence = AgentJsonHelper.extractNumberValue(objectText, 'confidence', 0);
      const payloadText: string = AgentJsonHelper.extractObjectText(objectText, 'payload');
      intent.payloadText = payloadText.length > 0 ? payloadText : '{}';
      result.push(intent);
    }
    return result;
  }

  private static extractStringValue(text: string, key: string, fallback: string): string {
    const valueText: string = AgentJsonHelper.extractSimpleValueText(text, key);
    if (valueText.length < 2) {
      return fallback;
    }
    if (!valueText.startsWith('"') || !valueText.endsWith('"')) {
      return fallback;
    }
    try {
      const parsed: string | null = JSON.parse(valueText) as string | null;
      return parsed !== null ? parsed : fallback;
    } catch (_error) {
      return fallback;
    }
  }

  private static extractBooleanValue(text: string, key: string, fallback: boolean): boolean {
    const valueText: string = AgentJsonHelper.extractSimpleValueText(text, key);
    if (valueText === 'true') {
      return true;
    }
    if (valueText === 'false') {
      return false;
    }
    return fallback;
  }

  private static extractNumberValue(text: string, key: string, fallback: number): number {
    const valueText: string = AgentJsonHelper.extractSimpleValueText(text, key);
    if (valueText.length === 0) {
      return fallback;
    }
    const value: number = Number(valueText);
    return Number.isFinite(value) ? value : fallback;
  }

  private static extractObjectText(text: string, key: string): string {
    return AgentJsonHelper.extractStructuredValueText(text, key, '{', '}');
  }

  private static extractArrayText(text: string, key: string): string {
    return AgentJsonHelper.extractStructuredValueText(text, key, '[', ']');
  }

  private static extractSimpleValueText(text: string, key: string): string {
    const keyToken: string = '"' + key + '"';
    const keyIndex: number = text.indexOf(keyToken);
    if (keyIndex < 0) {
      return '';
    }
    const colonIndex: number = text.indexOf(':', keyIndex + keyToken.length);
    if (colonIndex < 0) {
      return '';
    }
    const valueStart: number = AgentJsonHelper.skipSpace(text, colonIndex + 1);
    if (valueStart >= text.length) {
      return '';
    }
    const firstChar: string = text.charAt(valueStart);
    if (firstChar === '{' || firstChar === '[') {
      return '';
    }
    if (firstChar === '"') {
      const endIndex: number = AgentJsonHelper.findStringEnd(text, valueStart);
      if (endIndex < 0) {
        return '';
      }
      return text.substring(valueStart, endIndex + 1);
    }
    let cursor: number = valueStart;
    while (cursor < text.length) {
      const current: string = text.charAt(cursor);
      if (current === ',' || current === '}' || current === ']') {
        break;
      }
      cursor++;
    }
    return text.substring(valueStart, cursor).trim();
  }

  private static extractStructuredValueText(text: string, key: string, openChar: string, closeChar: string): string {
    const keyToken: string = '"' + key + '"';
    const keyIndex: number = text.indexOf(keyToken);
    if (keyIndex < 0) {
      return '';
    }
    const colonIndex: number = text.indexOf(':', keyIndex + keyToken.length);
    if (colonIndex < 0) {
      return '';
    }
    const valueStart: number = AgentJsonHelper.skipSpace(text, colonIndex + 1);
    if (valueStart >= text.length || text.charAt(valueStart) !== openChar) {
      return '';
    }
    const endIndex: number = AgentJsonHelper.findMatchingBracket(text, valueStart, openChar, closeChar);
    if (endIndex < 0) {
      return '';
    }
    return text.substring(valueStart, endIndex + 1);
  }

  private static skipSpace(text: string, startIndex: number): number {
    let cursor: number = startIndex;
    while (cursor < text.length) {
      const char: string = text.charAt(cursor);
      if (char !== ' ' && char !== '\n' && char !== '\r' && char !== '\t') {
        break;
      }
      cursor++;
    }
    return cursor;
  }

  private static findStringEnd(text: string, startIndex: number): number {
    let escaped: boolean = false;
    for (let index: number = startIndex + 1; index < text.length; index++) {
      const char: string = text.charAt(index);
      if (escaped) {
        escaped = false;
        continue;
      }
      if (char === '\\') {
        escaped = true;
        continue;
      }
      if (char === '"') {
        return index;
      }
    }
    return -1;
  }

  private static findMatchingBracket(text: string, startIndex: number, openChar: string, closeChar: string): number {
    let depth: number = 0;
    let inString: boolean = false;
    let escaped: boolean = false;
    for (let index: number = startIndex; index < text.length; index++) {
      const char: string = text.charAt(index);
      if (inString) {
        if (escaped) {
          escaped = false;
          continue;
        }
        if (char === '\\') {
          escaped = true;
          continue;
        }
        if (char === '"') {
          inString = false;
        }
        continue;
      }
      if (char === '"') {
        inString = true;
        continue;
      }
      if (char === openChar) {
        depth++;
        continue;
      }
      if (char === closeChar) {
        depth--;
        if (depth === 0) {
          return index;
        }
      }
    }
    return -1;
  }

  private static splitTopLevelObjects(arrayText: string): Array<string> {
    const result: Array<string> = [];
    if (arrayText.length < 2 || arrayText.charAt(0) !== '[') {
      return result;
    }
    let depth: number = 0;
    let startIndex: number = -1;
    let inString: boolean = false;
    let escaped: boolean = false;
    for (let index: number = 0; index < arrayText.length; index++) {
      const char: string = arrayText.charAt(index);
      if (inString) {
        if (escaped) {
          escaped = false;
          continue;
        }
        if (char === '\\') {
          escaped = true;
          continue;
        }
        if (char === '"') {
          inString = false;
        }
        continue;
      }
      if (char === '"') {
        inString = true;
        continue;
      }
      if (char === '{') {
        if (depth === 0) {
          startIndex = index;
        }
        depth++;
        continue;
      }
      if (char === '}') {
        depth--;
        if (depth === 0 && startIndex >= 0) {
          result.push(arrayText.substring(startIndex, index + 1));
          startIndex = -1;
        }
      }
    }
    return result;
  }
}
