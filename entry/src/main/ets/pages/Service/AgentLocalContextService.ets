import { Task } from '../Model/DailyTask';
import { RemindTime } from '../Model/RemindTimeBase';
import { Course } from '../Model/Course';
import { taskStore } from '../Model/TaskStore';
import { courseStore } from '../Model/CourseStore';
import { fetchDayDateInfo } from '../ViewModel/DayDateInfo';
import { fetchOrdinaryAlmanacData } from '../ViewModel/OrdinaryAlmanacData';
import { fetchAlmanac } from '../ViewModel/AlmanacData';
import { fetchFestivalDetailInfo, fetchSolarTermsDetailInfo } from '../ViewModel/FestivalOrSolarTermsData';
import {
  AgentAlmanacContextItem,
  AgentAlmanacQueryPayload,
  AgentAlmanacTimeContextItem,
  AgentCourseContextItem,
  AgentCourseFilterPayload,
  AgentCourseQueryPayload,
  AgentDateContextItem,
  AgentFestivalContextItem,
  AgentFestivalQueryPayload,
  AgentIntent,
  AgentLocalContext,
  AgentNowContext,
  AgentPlanResult,
  AgentScheduleDayAnalysis,
  AgentScheduleFilterPayload,
  AgentScheduleQueryPayload,
  AgentScheduleSlot,
  AgentSettingsContext,
  AgentSolarTermContextItem,
  AgentSolarTermQueryPayload,
  AgentTaskContextItem,
  AgentTimePayload
} from '../Model/AgentModels';
import { FestivalDetailInfo } from '../Model/FestivalDetailInfo';
import { SolarTermsDetailInfo } from '../Model/SolarTermsDetailInfo';
import { AgentJsonHelper } from './AgentJsonHelper';
import { AgentLogger } from './AgentLogger';
import { AgentTimeBlock, AgentTimeHelper } from './AgentTimeHelper';

class AgentLocalDateRange {
  startDate: Date = new Date();
  endDate: Date = new Date();
}

class AgentCourseRecordLocal {
  course: Course = new Course();
  date: Date = new Date();
}

class AgentTaskRecordLocal {
  task: Task = new Task();
  date: Date = new Date();
}

export class AgentLocalContextService {
  private static readonly SCOPE: string = 'AgentLocalContextService';
  private static readonly MAX_ITEM_COUNT: number = 12;

  public static buildContext(plan: AgentPlanResult, userMessage: string): AgentLocalContext {
    const context: AgentLocalContext = new AgentLocalContext();
    context.now = AgentLocalContextService.buildNowContext();
    context.settings = AgentLocalContextService.buildSettingsContext();
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain === 'course' && intent.action === 'query') {
        AgentLocalContextService.fillCourseContext(context, AgentJsonHelper.parseCourseQueryPayload(intent.payloadText));
        continue;
      }
      if (intent.domain === 'schedule' && intent.action === 'query') {
        AgentLocalContextService.fillScheduleQueryContext(context, AgentJsonHelper.parseScheduleQueryPayload(intent.payloadText));
        continue;
      }
      if (intent.domain === 'almanac' && intent.action === 'query') {
        AgentLocalContextService.fillAlmanacContext(context, AgentJsonHelper.parseAlmanacQueryPayload(intent.payloadText));
        continue;
      }
      if (intent.domain === 'festival' && intent.action === 'query') {
        AgentLocalContextService.fillFestivalContext(context, AgentJsonHelper.parseFestivalQueryPayload(intent.payloadText));
        continue;
      }
      if (intent.domain === 'solarTerm' && intent.action === 'query') {
        AgentLocalContextService.fillSolarTermContext(context, AgentJsonHelper.parseSolarTermQueryPayload(intent.payloadText));
      }
    }
    context.hintText = '当前时间为 ' + context.now.timeText + '，请优先依据提供的本地真实数据回答。';
    AgentLogger.info(AgentLocalContextService.SCOPE,
      'context built tasks=' + context.tasks.length.toString() +
      ' courses=' + context.courses.length.toString() +
      ' almanac=' + context.almanacItems.length.toString() +
      ' festivals=' + context.festivals.length.toString() +
      ' solarTerms=' + context.solarTerms.length.toString());
    return context;
  }


  public static buildDeterministicReply(plan: AgentPlanResult): string {
    const lines: Array<string> = [];
    for (let index: number = 0; index < plan.intents.length; index++) {
      const intent: AgentIntent = plan.intents[index];
      if (intent.domain === 'course' && intent.action === 'query') {
        const payload: AgentCourseQueryPayload = AgentJsonHelper.parseCourseQueryPayload(intent.payloadText);
        if (!payload.needsFollowUp) {
          const line: string = AgentLocalContextService.buildCourseDeterministicReply(payload);
          if (line.trim().length > 0) {
            lines.push(line);
          }
        }
        continue;
      }
      if (intent.domain === 'schedule' && intent.action === 'query') {
        const payload: AgentScheduleQueryPayload = AgentJsonHelper.parseScheduleQueryPayload(intent.payloadText);
        if (!payload.needsFollowUp) {
          const line: string = AgentLocalContextService.buildScheduleDeterministicReply(payload);
          if (line.trim().length > 0) {
            lines.push(line);
          }
        }
      }
    }
    return lines.join('\n');
  }

  private static buildCourseDeterministicReply(payload: AgentCourseQueryPayload): string {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveCourseDateRange(payload.time);
    const records: Array<AgentCourseRecordLocal> = AgentLocalContextService.filterCourses(AgentLocalContextService.loadCourseRecords(range), payload);
    const items: Array<AgentCourseContextItem> = [];
    for (let index: number = 0; index < records.length && items.length < AgentLocalContextService.MAX_ITEM_COUNT; index++) {
      items.push(AgentLocalContextService.createCourseItem(records[index].course, records[index].date));
    }
    const label: string = AgentLocalContextService.buildRangeLabel(payload.time, range.startDate, range.endDate);
    if (payload.queryKind === 'has_course') {
      if (records.length === 0) {
        return label + '没有课程。';
      }
      return label + '有课程，共 ' + records.length.toString() + ' 节。' + AgentLocalContextService.joinCourseSummaries(items);
    }
    if (payload.queryKind === 'next_course') {
      if (items.length === 0) {
        return label + '没有查到下一节符合条件的课程。';
      }
      return '下一节课是：' + AgentLocalContextService.describeCourseItem(items[0]) + '。';
    }
    if (records.length === 0) {
      return label + '没有查到符合条件的课程。';
    }
    return label + '共查到 ' + records.length.toString() + ' 节课程：' + AgentLocalContextService.joinCourseSummaries(items);
  }

  private static buildScheduleDeterministicReply(payload: AgentScheduleQueryPayload): string {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveScheduleDateRange(payload.time);
    const records: Array<AgentTaskRecordLocal> = AgentLocalContextService.filterTasks(AgentLocalContextService.loadTaskRecords(range), payload);
    const items: Array<AgentTaskContextItem> = [];
    for (let index: number = 0; index < records.length && items.length < AgentLocalContextService.MAX_ITEM_COUNT; index++) {
      items.push(AgentLocalContextService.createTaskItem(records[index].task, records[index].date));
    }
    const label: string = AgentLocalContextService.buildRangeLabel(payload.time, range.startDate, range.endDate);
    if (payload.queryKind === 'free_time' || payload.includeFreeTime) {
      const analysisList: Array<AgentScheduleDayAnalysis> = AgentLocalContextService.buildScheduleRangeAnalyses(
        AgentLocalContextService.resolveScheduleDateRange(payload.time), payload.time
      );
      if (analysisList.length === 0) {
        return '没有足够长的空闲时段。';
      }
      const textList: Array<string> = [];
      for (let index: number = 0; index < analysisList.length; index++) {
        textList.push(analysisList[index].summaryText);
      }
      return textList.join('；');
    }
    if (payload.queryKind === 'has_schedule') {
      if (records.length === 0) {
        return label + '没有日程。';
      }
      return label + '有日程，共 ' + records.length.toString() + ' 个。' + AgentLocalContextService.joinTaskSummaries(items);
    }
    if (records.length === 0) {
      return label + '没有查到符合条件的日程。';
    }
    return label + '共查到 ' + records.length.toString() + ' 个日程：' + AgentLocalContextService.joinTaskSummaries(items);
  }

  private static buildRangeLabel(time: AgentTimePayload, startDate: Date, endDate: Date): string {
    const originalText: string = time.originalText.trim();
    if (originalText.length > 0 && originalText.length <= 16) {
      return originalText;
    }
    if (!AgentLocalContextService.hasConcreteDate(time)) {
      return '全部范围内';
    }
    const today: Date = AgentTimeHelper.cloneDateOnly(new Date());
    if (AgentTimeHelper.isSameDate(startDate, endDate)) {
      if (AgentTimeHelper.isSameDate(startDate, today)) {
        return '今天';
      }
      return AgentTimeHelper.formatDate(startDate);
    }
    return AgentTimeHelper.formatDate(startDate) + '到' + AgentTimeHelper.formatDate(endDate);
  }

  private static joinCourseSummaries(items: Array<AgentCourseContextItem>): string {
    const parts: Array<string> = [];
    for (let index: number = 0; index < items.length; index++) {
      parts.push(AgentLocalContextService.describeCourseItem(items[index]));
    }
    return parts.join('；');
  }

  private static describeCourseItem(item: AgentCourseContextItem): string {
    let result: string = item.date + ' ' + item.startTime + '-' + item.endTime + ' ' + item.courseName;
    if (item.teacherName.trim().length > 0) {
      result += '（' + item.teacherName.trim() + '）';
    }
    if (item.classroom.trim().length > 0) {
      result += ' @' + item.classroom.trim();
    }
    return result;
  }

  private static joinTaskSummaries(items: Array<AgentTaskContextItem>): string {
    const parts: Array<string> = [];
    for (let index: number = 0; index < items.length; index++) {
      parts.push(AgentLocalContextService.describeTaskItem(items[index]));
    }
    return parts.join('；');
  }

  private static describeTaskItem(item: AgentTaskContextItem): string {
    let result: string = item.date + ' ' + item.startTime + '-' + item.endTime + ' ' + item.title;
    if (item.location.trim().length > 0) {
      result += ' @' + item.location.trim();
    }
    return result;
  }

  private static buildSettingsContext(): AgentSettingsContext {
    const settings: AgentSettingsContext = new AgentSettingsContext();
    settings.showAlmanac = Boolean(AppStorage.get('isSubscribe') ?? true);
    settings.themeColor = String(AppStorage.get('themeColor') ?? '#EA5C2E');
    settings.bottomAddTaskButtonEnabled = Boolean(AppStorage.get('isSetChangingNewTaskButton') ?? true);
    settings.holdingHandModeEnabled = Boolean(AppStorage.get('changingNewTaskButtonHandingStatus') ?? true);
    return settings;
  }

  private static buildNowContext(): AgentNowContext {
    const now: Date = new Date();
    const context: AgentNowContext = new AgentNowContext();
    context.iso = now.toISOString();
    context.dateText = AgentTimeHelper.formatDate(now);
    context.timeText = AgentTimeHelper.formatTime(now);
    context.weekdayText = AgentTimeHelper.formatWeekday(now);
    context.hour = now.getHours();
    context.minute = now.getMinutes();
    return context;
  }

  private static fillCourseContext(context: AgentLocalContext, payload: AgentCourseQueryPayload): void {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveCourseDateRange(payload.time);
    const records: Array<AgentCourseRecordLocal> = AgentLocalContextService.loadCourseRecords(range);
    const filtered: Array<AgentCourseRecordLocal> = AgentLocalContextService.filterCourses(records, payload);
    const courseDateList: Array<Date> = [];
    for (let index: number = 0; index < filtered.length; index++) {
      courseDateList.push(filtered[index].date);
    }
    AgentLocalContextService.appendRecordDates(context, courseDateList);
    if (filtered.length === 0) {
      AgentLocalContextService.appendDateInfo(context, range.startDate);
      return;
    }
    for (let index: number = 0; index < filtered.length && context.courses.length < AgentLocalContextService.MAX_ITEM_COUNT; index++) {
      const record: AgentCourseRecordLocal = filtered[index];
      context.courses.push(AgentLocalContextService.createCourseItem(record.course, record.date));
    }
  }

  private static fillScheduleQueryContext(context: AgentLocalContext, payload: AgentScheduleQueryPayload): void {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveScheduleDateRange(payload.time);
    const records: Array<AgentTaskRecordLocal> = AgentLocalContextService.loadTaskRecords(range);
    const filteredTasks: Array<AgentTaskRecordLocal> = AgentLocalContextService.filterTasks(records, payload);
    const taskDateList: Array<Date> = [];
    for (let index: number = 0; index < filteredTasks.length; index++) {
      taskDateList.push(filteredTasks[index].date);
    }
    AgentLocalContextService.appendRecordDates(context, taskDateList);
    if (filteredTasks.length === 0) {
      AgentLocalContextService.appendDateInfo(context, range.startDate);
    }
    for (let index: number = 0; index < filteredTasks.length && context.tasks.length < AgentLocalContextService.MAX_ITEM_COUNT; index++) {
      const record: AgentTaskRecordLocal = filteredTasks[index];
      context.tasks.push(AgentLocalContextService.createTaskItem(record.task, record.date));
    }
    if (payload.queryKind === 'free_time' || payload.includeFreeTime) {
      const analysisList: Array<AgentScheduleDayAnalysis> = AgentLocalContextService.buildScheduleRangeAnalyses(range, payload.time);
      for (let index: number = 0; index < analysisList.length; index++) {
        context.scheduleDays.push(analysisList[index]);
      }
    }
  }

  private static fillAlmanacContext(context: AgentLocalContext, payload: AgentAlmanacQueryPayload): void {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveDateRange(payload.time);
    const cursor: Date = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    while (cursor.getTime() <= range.endDate.getTime() && context.almanacItems.length < AgentLocalContextService.MAX_ITEM_COUNT) {
      const date: Date = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate());
      AgentLocalContextService.appendDateInfo(context, date);
      const ordinary = fetchOrdinaryAlmanacData(date.getFullYear(), date.getMonth() + 1, date.getDate());
      const almanac = fetchAlmanac(date.getFullYear(), date.getMonth() + 1, date.getDate());
      const item: AgentAlmanacContextItem = new AgentAlmanacContextItem();
      item.date = AgentTimeHelper.formatDate(date);
      item.lunarYearText = ordinary.getLunarYear().toString();
      item.lunarMonthText = ordinary.getLunarMonth().toString();
      item.lunarDayText = ordinary.getLunarDay().toString();
      item.yiText = ordinary.getYi();
      item.jiText = ordinary.getJi();
      item.ganZhiText = ordinary.getYearInGanZhi() + ' ' + ordinary.getMonthInGanZhi() + ' ' + ordinary.getDayInGanZhi();
      item.shengXiaoText = ordinary.getYearInShengXiao();
      item.chongShaText = almanac.getChong() + ' ' + almanac.getSha();
      item.jiShenText = almanac.getJiSheng();
      item.xiongShaText = almanac.getXiongSha();
      item.caiPositionText = almanac.getJiShengPosition().getCaiPosition();
      item.xiPositionText = almanac.getJiShengPosition().getXiPosition();
      item.fuPositionText = almanac.getJiShengPosition().getFuPosition();
      item.luckyDirectionText = almanac.getJiShengPosition().getXiPosition();
      item.godOfWealthText = almanac.getJiShengPosition().getCaiPosition();
      item.wuxingText = almanac.getTwelveZhiXing();
      item.taiShenText = almanac.getDayTaiPosition() + '；年太岁：' + almanac.getTaisuiPosition().getYearTaiSuiPosition() +
        '；月太岁：' + almanac.getTaisuiPosition().getMonthTaiSuiPosition() + '；日太岁：' + almanac.getTaisuiPosition().getDayTaiSuiPosition();
      item.pengZuText = almanac.getPengZuGan() + ' ' + almanac.getPengZuZhi();
      item.twelveZhiXingText = almanac.getTwelveZhiXing();
      const timeList = almanac.getTimeOfCurrentDay();
      for (let index: number = 0; index < timeList.length; index++) {
        const timeItem = timeList[index];
        const contextItem: AgentAlmanacTimeContextItem = new AgentAlmanacTimeContextItem();
        contextItem.shiChenText = timeItem.getTime();
        contextItem.beginTime = timeItem.getBeginTimeString();
        contextItem.endTime = timeItem.getEndTimeString();
        contextItem.jiOrXiong = timeItem.getJiOrXiong();
        contextItem.yiText = timeItem.getYi();
        contextItem.jiText = timeItem.getJi();
        contextItem.chongText = timeItem.getChong();
        contextItem.shaText = timeItem.getSha();
        contextItem.luckyDirection = timeItem.getJiShengPosition().getXiPosition();
        contextItem.godOfWealth = timeItem.getJiShengPosition().getCaiPosition();
        item.auspiciousHours.push(contextItem);
      }
      context.almanacItems.push(item);
      cursor.setDate(cursor.getDate() + 1);
    }
  }

  private static fillFestivalContext(context: AgentLocalContext, payload: AgentFestivalQueryPayload): void {
    const baseDate: Date = AgentLocalContextService.resolvePrimaryDate(payload.time);
    AgentLocalContextService.appendDateInfo(context, baseDate);
    if (payload.queryKind === 'today_festivals') {
      const hasConcreteToday: boolean = payload.time.resolvedDate.trim().length > 0 || payload.time.startDateTime.trim().length > 0 ||
        payload.time.endDateTime.trim().length > 0;
      if (!hasConcreteToday && payload.targetName.trim().length === 0) {
        const upcomingFestivals: Array<AgentFestivalContextItem> = AgentLocalContextService.findUpcomingFestivals(baseDate, 8);
        for (let index: number = 0; index < upcomingFestivals.length; index++) {
          context.festivals.push(upcomingFestivals[index]);
        }
        return;
      }
      const info = fetchDayDateInfo(baseDate.getFullYear(), baseDate.getMonth() + 1, baseDate.getDate(), true, true);
      const allFestivalNames: Array<string> = [];
      const festivalList: Array<string> = info.getFestival();
      const otherFestivalList: Array<string> = info.getOtherFestival();
      for (let index: number = 0; index < festivalList.length; index++) {
        allFestivalNames.push(festivalList[index]);
      }
      for (let index: number = 0; index < otherFestivalList.length; index++) {
        allFestivalNames.push(otherFestivalList[index]);
      }
      for (let index: number = 0; index < allFestivalNames.length; index++) {
        context.festivals.push(AgentLocalContextService.buildFestivalItem(allFestivalNames[index], baseDate, 0));
      }
      return;
    }
    if (payload.targetName.trim().length === 0) {
      const upcomingFestivals: Array<AgentFestivalContextItem> = AgentLocalContextService.findUpcomingFestivals(baseDate, 8);
      for (let index: number = 0; index < upcomingFestivals.length; index++) {
        context.festivals.push(upcomingFestivals[index]);
      }
      return;
    }
    const nextDate: Date | null = AgentLocalContextService.findNextFestivalDate(payload.targetName.trim(), baseDate);
    if (nextDate === null) {
      return;
    }
    const diff: number = AgentTimeHelper.daysBetween(baseDate, nextDate);
    context.festivals.push(AgentLocalContextService.buildFestivalItem(payload.targetName.trim(), nextDate, diff));
  }

  private static fillSolarTermContext(context: AgentLocalContext, payload: AgentSolarTermQueryPayload): void {
    const baseDate: Date = AgentLocalContextService.resolvePrimaryDate(payload.time);
    AgentLocalContextService.appendDateInfo(context, baseDate);
    if (payload.queryKind === 'today_solar_term') {
      const info = fetchDayDateInfo(baseDate.getFullYear(), baseDate.getMonth() + 1, baseDate.getDate(), true, true);
      if (info.getSolarTerm().trim().length > 0) {
        context.solarTerms.push(AgentLocalContextService.buildSolarTermItem(info.getSolarTerm(), baseDate, 0));
      }
      return;
    }
    const targetName: string = payload.targetName.trim();
    if (targetName.length > 0) {
      const nextDate: Date | null = AgentLocalContextService.findNextSolarTermDate(targetName, baseDate);
      if (nextDate !== null) {
        const diff: number = AgentTimeHelper.daysBetween(baseDate, nextDate);
        context.solarTerms.push(AgentLocalContextService.buildSolarTermItem(targetName, nextDate, diff));
      }
      return;
    }
    if (payload.queryKind === 'next_solar_term') {
      const nextFound: AgentSolarTermContextItem | null = AgentLocalContextService.findNextSolarTerm(baseDate);
      if (nextFound !== null) {
        context.solarTerms.push(nextFound);
      }
      return;
    }
    const upcomingSolarTerms: Array<AgentSolarTermContextItem> = AgentLocalContextService.findUpcomingSolarTerms(baseDate, 6);
    for (let index: number = 0; index < upcomingSolarTerms.length; index++) {
      context.solarTerms.push(upcomingSolarTerms[index]);
    }
  }

  private static appendDateInfo(context: AgentLocalContext, date: Date): void {
    const dateText: string = AgentTimeHelper.formatDate(date);
    for (let index: number = 0; index < context.dateItems.length; index++) {
      if (context.dateItems[index].date === dateText) {
        return;
      }
    }
    const dailyInfo = fetchDayDateInfo(date.getFullYear(), date.getMonth() + 1, date.getDate(), true, true);
    const item: AgentDateContextItem = new AgentDateContextItem();
    item.date = dateText;
    item.weekText = AgentTimeHelper.formatWeekday(date);
    item.lunarDateText = dailyInfo.getLunarDateText();
    item.festivalText = dailyInfo.getFestival().join('、');
    item.otherFestivalText = dailyInfo.getOtherFestival().join('、');
    item.solarTermText = dailyInfo.getSolarTerm();
    context.dateItems.push(item);
  }

  private static resolvePrimaryDate(time: AgentTimePayload): Date {
    if (time.resolvedDate.trim().length > 0) {
      const parsedDate: Date | null = AgentTimeHelper.parseDateText(time.resolvedDate);
      if (parsedDate !== null) {
        return parsedDate;
      }
    }
    if (time.startDateTime.trim().length >= 10) {
      const parsedText: string = time.startDateTime.substring(0, 10);
      const parsedDate: Date | null = AgentTimeHelper.parseDateText(parsedText);
      if (parsedDate !== null) {
        return parsedDate;
      }
    }
    return AgentTimeHelper.cloneDateOnly(new Date());
  }

  private static hasConcreteDate(time: AgentTimePayload): boolean {
    return time.resolvedDate.trim().length > 0 || time.startDateTime.trim().length >= 10 || time.endDateTime.trim().length >= 10;
  }

  private static resolveCourseDateRange(time: AgentTimePayload): AgentLocalDateRange {
    if (AgentLocalContextService.hasConcreteDate(time)) {
      return AgentLocalContextService.resolveDateRange(time);
    }
    return AgentLocalContextService.buildAllCourseRange();
  }

  private static resolveScheduleDateRange(time: AgentTimePayload): AgentLocalDateRange {
    if (AgentLocalContextService.hasConcreteDate(time)) {
      return AgentLocalContextService.resolveDateRange(time);
    }
    return AgentLocalContextService.buildAllTaskRange();
  }

  private static buildAllCourseRange(): AgentLocalDateRange {
    const range: AgentLocalDateRange = new AgentLocalDateRange();
    const allCourses: Array<Course> = courseStore.getAll();
    const termStartText: string = courseStore.getTermStartDate();
    const parsedTermStart: Date | null = termStartText.trim().length > 0 ? AgentTimeHelper.parseDateText(termStartText.substring(0, 10)) : null;
    if (parsedTermStart === null || allCourses.length === 0) {
      const today: Date = AgentTimeHelper.cloneDateOnly(new Date());
      range.startDate = today;
      range.endDate = today;
      return range;
    }
    let maxWeekIndex: number = 1;
    for (let index: number = 0; index < allCourses.length; index++) {
      const weekIndexes: Array<number> = allCourses[index].getWeekIndexes();
      if (weekIndexes.length === 0 && maxWeekIndex < 20) {
        maxWeekIndex = 20;
      }
      for (let weekIndex: number = 0; weekIndex < weekIndexes.length; weekIndex++) {
        if (weekIndexes[weekIndex] > maxWeekIndex) {
          maxWeekIndex = weekIndexes[weekIndex];
        }
      }
    }
    range.startDate = parsedTermStart;
    range.endDate = new Date(parsedTermStart.getFullYear(), parsedTermStart.getMonth(),
      parsedTermStart.getDate() + Math.max(maxWeekIndex, 1) * 7 - 1);
    return range;
  }

  private static buildAllTaskRange(): AgentLocalDateRange {
    const range: AgentLocalDateRange = new AgentLocalDateRange();
    const today: Date = AgentTimeHelper.cloneDateOnly(new Date());
    range.startDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() - 365);
    range.endDate = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 365);
    return range;
  }

  private static resolveDateRange(time: AgentTimePayload): AgentLocalDateRange {
    const range: AgentLocalDateRange = new AgentLocalDateRange();
    range.startDate = AgentLocalContextService.resolvePrimaryDate(time);
    range.endDate = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    if (time.endDateTime.trim().length >= 10) {
      const parsedText: string = time.endDateTime.substring(0, 10);
      const parsedDate: Date | null = AgentTimeHelper.parseDateText(parsedText);
      if (parsedDate !== null) {
        range.endDate = parsedDate;
      }
    }
    if (range.endDate.getTime() < range.startDate.getTime()) {
      range.endDate = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    }
    return range;
  }

  private static appendRecordDates(context: AgentLocalContext, dateList: Array<Date>): void {
    for (let index: number = 0; index < dateList.length; index++) {
      AgentLocalContextService.appendDateInfo(context, dateList[index]);
    }
  }

  private static loadCourseRecords(range: AgentLocalDateRange): Array<AgentCourseRecordLocal> {
    const result: Array<AgentCourseRecordLocal> = [];
    const cursor: Date = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    while (cursor.getTime() <= range.endDate.getTime()) {
      const date: Date = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate());
      const courses: Array<Course> = courseStore.getCoursesByDate(date);
      for (let index: number = 0; index < courses.length; index++) {
        const record: AgentCourseRecordLocal = new AgentCourseRecordLocal();
        record.course = courses[index];
        record.date = date;
        result.push(record);
      }
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  private static loadTaskRecords(range: AgentLocalDateRange): Array<AgentTaskRecordLocal> {
    const result: Array<AgentTaskRecordLocal> = [];
    const cursor: Date = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    while (cursor.getTime() <= range.endDate.getTime()) {
      const date: Date = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate());
      const tasks: Array<Task> = taskStore.getTask(date.getFullYear(), date.getMonth() + 1, date.getDate());
      for (let index: number = 0; index < tasks.length; index++) {
        const record: AgentTaskRecordLocal = new AgentTaskRecordLocal();
        record.task = tasks[index];
        record.date = date;
        result.push(record);
      }
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  private static filterCourses(records: Array<AgentCourseRecordLocal>, payload: AgentCourseQueryPayload): Array<AgentCourseRecordLocal> {
    const filtered: Array<AgentCourseRecordLocal> = [];
    const now: Date = new Date();
    const currentMinute: number = now.getHours() * 60 + now.getMinutes();
    for (let index: number = 0; index < records.length; index++) {
      const record: AgentCourseRecordLocal = records[index];
      if (!AgentLocalContextService.matchCourseFilter(record, payload.filters)) {
        continue;
      }
      if (!AgentLocalContextService.matchCourseTimeWindow(record.course, record.date, payload.time)) {
        continue;
      }
      const startMinute: number = AgentLocalContextService.readMinute(record.course.getStartTimeText());
      const endMinute: number = AgentLocalContextService.readMinute(record.course.getEndTimeText());
      const today: boolean = AgentTimeHelper.isSameDate(record.date, now);
      if (payload.queryKind === 'list_remaining_courses' && today && endMinute <= currentMinute) {
        continue;
      }
      if (payload.queryKind === 'list_completed_courses' && today && endMinute > currentMinute) {
        continue;
      }
      if (payload.queryKind === 'next_course') {
        const recordMinute: number = record.date.getTime() + startMinute * 60 * 1000;
        if (recordMinute < now.getTime()) {
          continue;
        }
      }
      filtered.push(record);
    }
    filtered.sort((first: AgentCourseRecordLocal, second: AgentCourseRecordLocal) => {
      return AgentLocalContextService.compareCourseRecord(first, second);
    });
    if (payload.queryKind === 'next_course' && filtered.length > 1) {
      return [filtered[0]];
    }
    return filtered;
  }

  private static filterTasks(records: Array<AgentTaskRecordLocal>, payload: AgentScheduleQueryPayload): Array<AgentTaskRecordLocal> {
    const filtered: Array<AgentTaskRecordLocal> = [];
    const now: Date = new Date();
    const currentMinute: number = now.getHours() * 60 + now.getMinutes();
    for (let index: number = 0; index < records.length; index++) {
      const record: AgentTaskRecordLocal = records[index];
      if (!AgentLocalContextService.matchTaskFilter(record.task, payload.filters)) {
        continue;
      }
      if (!AgentLocalContextService.matchTaskTimeWindow(record.task, record.date, payload.time)) {
        continue;
      }
      const startMinute: number = record.task.getBeginHour() * 60 + record.task.getBeginMinute();
      const endMinute: number = record.task.getEndHour() * 60 + record.task.getEndMinute();
      const today: boolean = AgentTimeHelper.isSameDate(record.date, now);
      if (payload.queryKind === 'list_remaining_schedule' && today && endMinute <= currentMinute) {
        continue;
      }
      if (payload.queryKind === 'list_completed_schedule' && today && endMinute > currentMinute) {
        continue;
      }
      filtered.push(record);
    }
    filtered.sort((first: AgentTaskRecordLocal, second: AgentTaskRecordLocal) => {
      return AgentLocalContextService.compareTaskRecord(first, second);
    });
    return filtered;
  }

  private static compareCourseRecord(first: AgentCourseRecordLocal, second: AgentCourseRecordLocal): number {
    const firstValue: number = first.date.getTime() + AgentLocalContextService.readMinute(first.course.getStartTimeText()) * 60 * 1000;
    const secondValue: number = second.date.getTime() + AgentLocalContextService.readMinute(second.course.getStartTimeText()) * 60 * 1000;
    return firstValue - secondValue;
  }

  private static compareTaskRecord(first: AgentTaskRecordLocal, second: AgentTaskRecordLocal): number {
    const firstValue: number = first.date.getTime() + (first.task.getBeginHour() * 60 + first.task.getBeginMinute()) * 60 * 1000;
    const secondValue: number = second.date.getTime() + (second.task.getBeginHour() * 60 + second.task.getBeginMinute()) * 60 * 1000;
    return firstValue - secondValue;
  }

  private static matchCourseFilter(record: AgentCourseRecordLocal, filter: AgentCourseFilterPayload): boolean {
    const course: Course = record.course;
    const courseNameText: string = course.getCourseName().toLowerCase();
    const teacherText: string = course.getTeacherName().toLowerCase();
    const classroomText: string = course.getClassroom().toLowerCase();
    if (!AgentLocalContextService.matchKeywordList(courseNameText, filter.courseNameKeywords)) {
      return false;
    }
    if (filter.teacherName.trim().length > 0 && teacherText.indexOf(filter.teacherName.trim().toLowerCase()) < 0) {
      return false;
    }
    if (!AgentLocalContextService.matchKeywordList(classroomText, filter.locationKeywords)) {
      return false;
    }
    if (!AgentLocalContextService.matchWeekType(course, filter.weekType)) {
      return false;
    }
    if (filter.weekdayText.trim().length > 0 && AgentLocalContextService.resolveWeekdayText(record.date) !== filter.weekdayText.trim()) {
      return false;
    }
    if (filter.weekIndex > 0 && courseStore.getAcademicWeekByDate(record.date) !== filter.weekIndex) {
      return false;
    }
    return true;
  }

  private static matchCourseTimeWindow(course: Course, date: Date, time: AgentTimePayload): boolean {
    const startMinute: number = AgentLocalContextService.readMinute(course.getStartTimeText());
    const endMinute: number = AgentLocalContextService.readMinute(course.getEndTimeText());
    return AgentLocalContextService.matchMinuteWindow(date, startMinute, endMinute, time);
  }

  private static matchTaskTimeWindow(task: Task, date: Date, time: AgentTimePayload): boolean {
    const startMinute: number = task.getBeginHour() * 60 + task.getBeginMinute();
    const endMinute: number = task.getEndHour() * 60 + task.getEndMinute();
    return AgentLocalContextService.matchMinuteWindow(date, startMinute, endMinute, time);
  }

  private static matchMinuteWindow(date: Date, itemStartMinute: number, itemEndMinute: number, time: AgentTimePayload): boolean {
    const range: AgentLocalDateRange = AgentLocalContextService.resolveDateRange(time);
    if (date.getTime() < range.startDate.getTime() || date.getTime() > range.endDate.getTime()) {
      return false;
    }
    const queryStartMinute: number = AgentLocalContextService.extractStartMinute(time);
    const queryEndMinute: number = AgentLocalContextService.extractEndMinute(time);
    if (queryStartMinute < 0 && queryEndMinute < 0) {
      return true;
    }
    const effectiveStartMinute: number = queryStartMinute >= 0 ? queryStartMinute : 0;
    const effectiveEndMinute: number = queryEndMinute >= 0 ? queryEndMinute : 24 * 60;
    return itemStartMinute < effectiveEndMinute && itemEndMinute > effectiveStartMinute;
  }

  private static extractStartMinute(time: AgentTimePayload): number {
    if (time.startDateTime.trim().length >= 16) {
      return AgentLocalContextService.readMinute(time.startDateTime.substring(11, 16));
    }
    return -1;
  }

  private static extractEndMinute(time: AgentTimePayload): number {
    if (time.endDateTime.trim().length >= 16) {
      return AgentLocalContextService.readMinute(time.endDateTime.substring(11, 16));
    }
    return -1;
  }

  private static resolveWeekdayText(date: Date): string {
    return AgentTimeHelper.formatWeekday(date).trim();
  }

  private static matchWeekType(course: Course, weekType: string): boolean {
    const normalizedWeekType: string = weekType.trim().toLowerCase();
    if (normalizedWeekType.length === 0) {
      return true;
    }
    const indexes: Array<number> = course.getWeekIndexes();
    if (indexes.length === 0) {
      return true;
    }
    let hasOdd: boolean = false;
    let hasEven: boolean = false;
    for (let index: number = 0; index < indexes.length; index++) {
      const weekIndex: number = indexes[index];
      if (weekIndex % 2 === 0) {
        hasEven = true;
      } else {
        hasOdd = true;
      }
    }
    if (normalizedWeekType === 'odd' || normalizedWeekType === 'single' || normalizedWeekType === '单周') {
      return hasOdd && !hasEven;
    }
    if (normalizedWeekType === 'even' || normalizedWeekType === 'double' || normalizedWeekType === '双周') {
      return hasEven && !hasOdd;
    }
    return true;
  }

  private static matchTaskFilter(task: Task, filter: AgentScheduleFilterPayload): boolean {
    const titleText: string = task.getTitle().toLowerCase();
    const locationText: string = task.getLocation().toLowerCase();
    const detailText: string = task.getDetail().toLowerCase();
    if (!AgentLocalContextService.matchKeywordList(titleText, filter.titleKeywords)) {
      return false;
    }
    if (!AgentLocalContextService.matchKeywordList(locationText, filter.locationKeywords)) {
      return false;
    }
    if (!AgentLocalContextService.matchKeywordList(detailText, filter.noteKeywords)) {
      return false;
    }
    if (filter.category.trim().length > 0 && !AgentLocalContextService.matchTaskCategory(task, filter.category.trim())) {
      return false;
    }
    if (filter.reminderMinutes >= 0 && !AgentLocalContextService.matchTaskReminder(task, filter.reminderMinutes)) {
      return false;
    }
    return true;
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

  private static matchKeywordList(content: string, keywords: Array<string>): boolean {
    const normalizedContent: string = AgentLocalContextService.normalizeLocationLikeText(content);
    for (let index: number = 0; index < keywords.length; index++) {
      const keyword: string = keywords[index].trim().toLowerCase();
      if (keyword.length === 0) {
        continue;
      }
      const normalizedKeyword: string = AgentLocalContextService.normalizeLocationLikeText(keyword);
      if (content.indexOf(keyword) >= 0 || normalizedContent.indexOf(normalizedKeyword) >= 0) {
        continue;
      }
      return false;
    }
    return true;
  }

  private static normalizeLocationLikeText(text: string): string {
    let value: string = text.trim().toLowerCase();
    value = value.replace(/楼/g, '');
    value = value.replace(/教室/g, '');
    value = value.replace(/\s+/g, '');
    value = value.replace(/（/g, '(').replace(/）/g, ')');
    return value;
  }

  private static createCourseItem(course: Course, date: Date): AgentCourseContextItem {
    const item: AgentCourseContextItem = new AgentCourseContextItem();
    item.id = course.getId();
    item.courseName = course.getCourseName();
    item.teacherName = course.getTeacherName();
    item.classroom = course.getClassroom();
    item.date = AgentTimeHelper.formatDate(date);
    item.weekText = courseStore.getAcademicWeekTextByDate(date);
    item.startTime = course.getStartTimeText();
    item.endTime = course.getEndTimeText();
    item.sectionText = course.getSectionRangeText();
    item.statusText = AgentLocalContextService.buildCourseStatus(course, date);
    return item;
  }

  private static buildCourseStatus(course: Course, date: Date): string {
    const now: Date = new Date();
    if (!AgentTimeHelper.isSameDate(now, date)) {
      return '';
    }
    const currentMinute: number = now.getHours() * 60 + now.getMinutes();
    const startMinute: number = AgentLocalContextService.readMinute(course.getStartTimeText());
    const endMinute: number = AgentLocalContextService.readMinute(course.getEndTimeText());
    if (currentMinute < startMinute) {
      return '未开始';
    }
    if (currentMinute >= endMinute) {
      return '已结束';
    }
    return '进行中';
  }

  private static createTaskItem(task: Task, date: Date): AgentTaskContextItem {
    const item: AgentTaskContextItem = new AgentTaskContextItem();
    item.id = task.getId();
    item.title = task.getTitle();
    item.date = AgentTimeHelper.formatDate(date);
    item.startTime = AgentTimeHelper.minuteToText(task.getBeginHour() * 60 + task.getBeginMinute());
    item.endTime = AgentTimeHelper.minuteToText(task.getEndHour() * 60 + task.getEndMinute());
    item.location = task.getLocation();
    item.detail = task.getDetail();
    item.taskType = task.getTaskType().toString();
    item.statusText = AgentLocalContextService.buildTaskStatus(task, date);
    return item;
  }

  private static buildTaskStatus(task: Task, date: Date): string {
    const now: Date = new Date();
    if (!AgentTimeHelper.isSameDate(now, date)) {
      return '';
    }
    const currentMinute: number = now.getHours() * 60 + now.getMinutes();
    const startMinute: number = task.getBeginHour() * 60 + task.getBeginMinute();
    const endMinute: number = task.getEndHour() * 60 + task.getEndMinute();
    if (currentMinute < startMinute) {
      return '未开始';
    }
    if (currentMinute >= endMinute) {
      return '已结束';
    }
    return '进行中';
  }


  private static buildScheduleRangeAnalyses(range: AgentLocalDateRange, time: AgentTimePayload): Array<AgentScheduleDayAnalysis> {
    const result: Array<AgentScheduleDayAnalysis> = [];
    const cursor: Date = new Date(range.startDate.getFullYear(), range.startDate.getMonth(), range.startDate.getDate());
    while (cursor.getTime() <= range.endDate.getTime() && result.length < AgentLocalContextService.MAX_ITEM_COUNT) {
      const date: Date = new Date(cursor.getFullYear(), cursor.getMonth(), cursor.getDate());
      const tasks: Array<Task> = taskStore.getTask(date.getFullYear(), date.getMonth() + 1, date.getDate());
      const courses: Array<Course> = courseStore.getCoursesByDate(date);
      result.push(AgentLocalContextService.buildScheduleDayAnalysis(date, tasks, courses, time));
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  private static buildScheduleDayAnalysis(date: Date, tasks: Array<Task>, courses: Array<Course>,
    time: AgentTimePayload): AgentScheduleDayAnalysis {
    const analysis: AgentScheduleDayAnalysis = new AgentScheduleDayAnalysis();
    analysis.date = AgentTimeHelper.formatDate(date);
    const busyBlocks: Array<AgentTimeBlock> = [];
    for (let index: number = 0; index < tasks.length; index++) {
      const task: Task = tasks[index];
      const block: AgentTimeBlock = new AgentTimeBlock();
      block.startMinute = task.getBeginHour() * 60 + task.getBeginMinute();
      block.endMinute = task.getEndHour() * 60 + task.getEndMinute();
      block.label = '日程:' + task.getTitle();
      busyBlocks.push(block);
    }
    for (let index: number = 0; index < courses.length; index++) {
      const course: Course = courses[index];
      const block: AgentTimeBlock = new AgentTimeBlock();
      block.startMinute = AgentLocalContextService.readMinute(course.getStartTimeText());
      block.endMinute = AgentLocalContextService.readMinute(course.getEndTimeText());
      block.label = '课程:' + course.getCourseName();
      busyBlocks.push(block);
    }
    const mergedBusyBlocks: Array<AgentTimeBlock> = AgentTimeHelper.mergeBlocks(busyBlocks);
    const windowStartMinute: number = AgentLocalContextService.resolveAnalysisWindowStartMinute(date, time);
    const windowEndMinute: number = AgentLocalContextService.resolveAnalysisWindowEndMinute(date, time);
    analysis.busyText = AgentLocalContextService.buildBusyText(mergedBusyBlocks);
    analysis.freeSlots = AgentLocalContextService.buildFreeSlots(date, mergedBusyBlocks, windowStartMinute, windowEndMinute);
    analysis.freeText = AgentLocalContextService.buildFreeText(analysis.freeSlots);
    analysis.summaryText = analysis.freeText.length > 0 ? analysis.date + ' 的空闲时段：' + analysis.freeText : analysis.date + ' 没有明显空闲时段。';
    return analysis;
  }

  private static buildBusyText(blocks: Array<AgentTimeBlock>): string {
    if (blocks.length === 0) {
      return '暂无占用';
    }
    const texts: Array<string> = [];
    for (let index: number = 0; index < blocks.length; index++) {
      const block: AgentTimeBlock = blocks[index];
      texts.push(AgentTimeHelper.minuteToText(block.startMinute) + '-' + AgentTimeHelper.minuteToText(block.endMinute));
    }
    return texts.join('、');
  }

  private static buildFreeSlots(date: Date, busyBlocks: Array<AgentTimeBlock>, windowStartMinute: number,
    windowEndMinute: number): Array<AgentScheduleSlot> {
    const slots: Array<AgentScheduleSlot> = [];
    const mergedBusyBlocks: Array<AgentTimeBlock> = AgentTimeHelper.mergeBlocks(busyBlocks);
    let cursor: number = Math.max(0, windowStartMinute);
    if (AgentTimeHelper.isSameDate(date, new Date())) {
      cursor = Math.max(cursor, new Date().getHours() * 60 + new Date().getMinutes());
    }
    const effectiveWindowEnd: number = Math.min(24 * 60, Math.max(windowEndMinute, cursor));
    for (let index: number = 0; index < mergedBusyBlocks.length; index++) {
      const block: AgentTimeBlock = mergedBusyBlocks[index];
      if (block.endMinute <= cursor || block.startMinute >= effectiveWindowEnd) {
        continue;
      }
      const clippedBlockStart: number = Math.max(cursor, block.startMinute);
      const clippedBlockEnd: number = Math.min(effectiveWindowEnd, block.endMinute);
      if (clippedBlockStart > cursor) {
        const slot: AgentScheduleSlot = new AgentScheduleSlot();
        slot.startTime = AgentTimeHelper.minuteToText(cursor);
        slot.endTime = AgentTimeHelper.minuteToText(clippedBlockStart);
        slot.label = slot.startTime + '-' + slot.endTime;
        if (clippedBlockStart - cursor >= 30) {
          slots.push(slot);
        }
      }
      cursor = Math.max(cursor, clippedBlockEnd);
      if (cursor >= effectiveWindowEnd) {
        break;
      }
    }
    if (cursor < effectiveWindowEnd) {
      const slot: AgentScheduleSlot = new AgentScheduleSlot();
      slot.startTime = AgentTimeHelper.minuteToText(cursor);
      slot.endTime = effectiveWindowEnd >= 24 * 60 ? '24:00' : AgentTimeHelper.minuteToText(effectiveWindowEnd);
      slot.label = slot.startTime + '-' + slot.endTime;
      if (effectiveWindowEnd - cursor >= 30) {
        slots.push(slot);
      }
    }
    return slots;
  }

  private static resolveAnalysisWindowStartMinute(date: Date, time: AgentTimePayload): number {
    const explicitStartMinute: number = AgentLocalContextService.extractStartMinute(time);
    if (explicitStartMinute >= 0 && AgentLocalContextService.isTimeBoundaryOnDate(date, time.startDateTime)) {
      return explicitStartMinute;
    }
    return 0;
  }

  private static resolveAnalysisWindowEndMinute(date: Date, time: AgentTimePayload): number {
    const explicitEndMinute: number = AgentLocalContextService.extractEndMinute(time);
    if (explicitEndMinute >= 0 && AgentLocalContextService.isTimeBoundaryOnDate(date, time.endDateTime)) {
      return explicitEndMinute;
    }
    return 24 * 60;
  }

  private static isTimeBoundaryOnDate(date: Date, dateTimeText: string): boolean {
    const value: string = dateTimeText.trim();
    if (value.length < 10) {
      return false;
    }
    return AgentTimeHelper.formatDate(date) === value.substring(0, 10);
  }

  private static buildFreeText(freeSlots: Array<AgentScheduleSlot>): string {
    const texts: Array<string> = [];
    for (let index: number = 0; index < freeSlots.length; index++) {
      texts.push(freeSlots[index].label);
    }
    return texts.join('、');
  }

  private static buildFestivalItem(name: string, date: Date, countdownDays: number): AgentFestivalContextItem {
    const item: AgentFestivalContextItem = new AgentFestivalContextItem();
    item.targetName = name;
    item.dateText = AgentTimeHelper.formatDate(date);
    item.countdownDays = countdownDays;
    const detail: FestivalDetailInfo = fetchFestivalDetailInfo(name);
    if (detail.name.trim().length > 0) {
      item.detailText = detail.simpleIntroduction + ' ' + detail.fullDescription;
    }
    return item;
  }

  private static buildSolarTermItem(name: string, date: Date, countdownDays: number): AgentSolarTermContextItem {
    const item: AgentSolarTermContextItem = new AgentSolarTermContextItem();
    item.targetName = name;
    item.dateText = AgentTimeHelper.formatDate(date);
    item.countdownDays = countdownDays;
    const detail: SolarTermsDetailInfo = fetchSolarTermsDetailInfo(name);
    if (detail.name.trim().length > 0) {
      item.detailText = detail.briefIntroduction + ' ' + detail.meaning + ' ' + detail.customs;
    }
    return item;
  }

  private static findUpcomingFestivals(baseDate: Date, limit: number): Array<AgentFestivalContextItem> {
    const result: Array<AgentFestivalContextItem> = [];
    const seenNames: Array<string> = [];
    for (let offset: number = 0; offset < 370 && result.length < limit; offset++) {
      const currentDate: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
      const info = fetchDayDateInfo(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate(), true, true);
      const names: Array<string> = [];
      const festivalList: Array<string> = info.getFestival();
      const otherFestivalList: Array<string> = info.getOtherFestival();
      for (let index: number = 0; index < festivalList.length; index++) {
        names.push(festivalList[index]);
      }
      for (let index: number = 0; index < otherFestivalList.length; index++) {
        names.push(otherFestivalList[index]);
      }
      for (let index: number = 0; index < names.length && result.length < limit; index++) {
        const name: string = names[index].trim();
        if (name.length === 0 || seenNames.indexOf(name) >= 0) {
          continue;
        }
        seenNames.push(name);
        const diff: number = AgentTimeHelper.daysBetween(baseDate, currentDate);
        result.push(AgentLocalContextService.buildFestivalItem(name, currentDate, diff));
      }
    }
    return result;
  }

  private static findNextFestivalDate(targetName: string, baseDate: Date): Date | null {
    for (let offset: number = 0; offset < 370; offset++) {
      const currentDate: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
      const info = fetchDayDateInfo(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate(), true, true);
      if (AgentLocalContextService.hasFestival(info.getFestival(), targetName) ||
        AgentLocalContextService.hasFestival(info.getOtherFestival(), targetName)) {
        return currentDate;
      }
    }
    return null;
  }

  private static findUpcomingSolarTerms(baseDate: Date, limit: number): Array<AgentSolarTermContextItem> {
    const result: Array<AgentSolarTermContextItem> = [];
    const seenNames: Array<string> = [];
    for (let offset: number = 0; offset < 370 && result.length < limit; offset++) {
      const currentDate: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
      const info = fetchDayDateInfo(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate(), true, true);
      const name: string = info.getSolarTerm().trim();
      if (name.length === 0 || seenNames.indexOf(name) >= 0) {
        continue;
      }
      seenNames.push(name);
      const diff: number = AgentTimeHelper.daysBetween(baseDate, currentDate);
      result.push(AgentLocalContextService.buildSolarTermItem(name, currentDate, diff));
    }
    return result;
  }

  private static findNextSolarTermDate(targetName: string, baseDate: Date): Date | null {
    for (let offset: number = 0; offset < 370; offset++) {
      const currentDate: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
      const info = fetchDayDateInfo(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate(), true, true);
      if (info.getSolarTerm() === targetName) {
        return currentDate;
      }
    }
    return null;
  }

  private static findNextSolarTerm(baseDate: Date): AgentSolarTermContextItem | null {
    for (let offset: number = 0; offset < 370; offset++) {
      const currentDate: Date = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate() + offset);
      const info = fetchDayDateInfo(currentDate.getFullYear(), currentDate.getMonth() + 1, currentDate.getDate(), true, true);
      if (info.getSolarTerm().trim().length > 0) {
        const diff: number = AgentTimeHelper.daysBetween(baseDate, currentDate);
        return AgentLocalContextService.buildSolarTermItem(info.getSolarTerm(), currentDate, diff);
      }
    }
    return null;
  }

  private static hasFestival(list: Array<string>, targetName: string): boolean {
    for (let index: number = 0; index < list.length; index++) {
      if (list[index] === targetName) {
        return true;
      }
    }
    return false;
  }

  private static readMinute(timeText: string): number {
    const block: AgentTimeBlock | null = AgentTimeHelper.parseTimeText(timeText);
    if (block === null) {
      return 0;
    }
    return block.startMinute;
  }
}
