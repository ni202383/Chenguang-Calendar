import { Course } from '../Model/Course';

export interface CourseTableCellSnapshot {
  tableIndex: number;
  rowIndex: number;
  colIndex: number;
  rowSpan: number;
  colSpan: number;
  text: string;
  className: string;
}

export interface CourseBlockSnapshot {
  text: string;
  className: string;
  tagName: string;
}

export interface CoursePageSnapshot {
  url: string;
  title: string;
  text: string;
  html: string;
  tableCells: Array<CourseTableCellSnapshot>;
  pageBlocks: Array<CourseBlockSnapshot>;
  apiTermCode: string;
  apiTermLabel: string;
  semesterStartDate: string;
  apiRowJsonList: Array<string>;
  apiLogText: string;
}

export interface CourseParseResult {
  courses: Array<Course>;
  termLabel: string;
  termStartDate: string;
  message: string;
}

interface JsonCandidate {
  courseName: string;
  teacherName: string;
  classroom: string;
  dayOfWeek: number;
  startSection: number;
  endSection: number;
  rawWeekText: string;
  weekIndexes: Array<number>;
}

interface SectionRange {
  startSection: number;
  endSection: number;
}

export class NuistCourseImportService {
  public static readonly LOGIN_URL: string =
    'https://jwxt.nuist.edu.cn/jwapp/sys/emaphome/portal/index.do?forceCas=1';
  public static readonly COURSE_PAGE_URL: string =
    'https://jwxt.nuist.edu.cn/jwapp/sys/wdkb/*default/index.do?THEME=green&EMAP_LANG=zh';

  public static isCoursePageUrl(url: string): boolean {
    return url.indexOf('/jwapp/sys/wdkb/') >= 0;
  }

  public static canTryOpenCoursePage(url: string): boolean {
    if (url.trim().length === 0) {
      return false;
    }
    if (NuistCourseImportService.isCoursePageUrl(url)) {
      return true;
    }
    if (url.indexOf('jwxt.nuist.edu.cn') >= 0 && url.indexOf('/authserver/login') < 0) {
      return true;
    }
    return false;
  }

  public static shouldAutoRedirectToCoursePage(url: string): boolean {
    if (NuistCourseImportService.isCoursePageUrl(url)) {
      return false;
    }
    if (url.indexOf('/authserver/login') >= 0) {
      return false;
    }
    if (url.indexOf('jwxt.nuist.edu.cn') >= 0) {
      return true;
    }
    return false;
  }

  public static normalizeRunJavaScriptResult(rawResult: string): string {
    const trimmed: string = rawResult.trim();
    if (trimmed.length === 0 || trimmed === 'null' || trimmed === 'undefined') {
      return '';
    }
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      try {
        return JSON.parse(trimmed) as string;
      } catch (error) {
        console.error('[NuistCourseImportService] normalizeRunJavaScriptResult parse quote failed: ' + JSON.stringify(error));
        return trimmed;
      }
    }
    return trimmed;
  }

  public static parseCoursePageSnapshot(rawText: string): CoursePageSnapshot {
    const firstPassText: string = NuistCourseImportService.normalizeRunJavaScriptResult(rawText);
    const maybeInnerJson: string = NuistCourseImportService.tryExtractInnerJsonText(firstPassText);
    if (maybeInnerJson.length > 0) {
      return JSON.parse(maybeInnerJson) as CoursePageSnapshot;
    }
    return JSON.parse(firstPassText) as CoursePageSnapshot;
  }

  private static tryExtractInnerJsonText(rawText: string): string {
    try {
      const firstParsed: string = JSON.parse(rawText) as string;
      if (firstParsed.startsWith('{') && firstParsed.endsWith('}')) {
        return firstParsed;
      }
    } catch (error) {
      return '';
    }
    return '';
  }

  public static parseSnapshot(snapshot: CoursePageSnapshot): CourseParseResult {
    const logs: Array<string> = [];
    logs.push('url=' + snapshot.url);
    logs.push('title=' + snapshot.title);
    logs.push('apiTermCode=' + snapshot.apiTermCode);
    logs.push('apiTermLabel=' + snapshot.apiTermLabel);
    logs.push('semesterStartDate=' + snapshot.semesterStartDate);
    logs.push('apiRowJsonList=' + snapshot.apiRowJsonList.length.toString());
    logs.push('apiLogText=' + snapshot.apiLogText);

    if (snapshot.apiRowJsonList.length > 0) {
      logs.push('apiRowSample=' + snapshot.apiRowJsonList[0].slice(0, 260));
    }
    let candidates: Array<JsonCandidate> = NuistCourseImportService.parseFromApiRowJsonList(snapshot.apiRowJsonList, logs);
    if (candidates.length === 0) {
      candidates = NuistCourseImportService.parseFromRawJsonHeuristic(snapshot.apiRowJsonList, logs);
    }
    if (candidates.length === 0) {
      candidates = NuistCourseImportService.parseFromPlainText(snapshot.text, logs);
    }

    const termLabel: string = snapshot.apiTermLabel.trim().length > 0 ? snapshot.apiTermLabel :
      NuistCourseImportService.extractTermLabel(snapshot.text, snapshot.html);
    const termStartDate: string = NuistCourseImportService.normalizeSemesterStartDate(snapshot.semesterStartDate);
    const courses: Array<Course> = NuistCourseImportService.buildCourseList(candidates, termLabel, logs);
    if (courses.length === 0) {
      console.error('[NuistCourseImportService] 导入失败：' + logs.join(' | '));
      return {
        courses: [],
        termLabel: termLabel,
        termStartDate: termStartDate,
        message: '本学期课表接口未返回可识别课程。请把控制台里 [CourseImport] 与 [NuistCourseImportService] 日志发给我继续收紧规则。'
      };
    }

    console.info('[NuistCourseImportService] 导入成功：' + logs.join(' | '));
    return {
      courses: courses,
      termLabel: termLabel,
      termStartDate: termStartDate,
      message: '本学期课表解析成功，共识别 ' + courses.length.toString() + ' 条课程记录。'
    };
  }

  private static normalizeSemesterStartDate(rawValue: string): string {
    const normalized: string = rawValue.trim();
    if (normalized.length === 0) {
      return '';
    }
    const match: RegExpMatchArray | null = normalized.match(/^(\d{4}-\d{2}-\d{2})/);
    if (match !== null && match.length >= 2) {
      const datePart: string = match[1];
      const date: Date = new Date(datePart);
      const day: number = date.getDay();
      const diff: number = day === 0 ? -6 : 1 - day;
      date.setDate(date.getDate() + diff);
      // [南信大课表] cxjcs 返回的是学期起始周口径，和教学课表首周存在 1 周偏移，这里顺延到课表首周。
      date.setDate(date.getDate() - 14);
      const year: string = date.getFullYear().toString();
      const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
      const dayText: string = date.getDate().toString().padStart(2, '0');
      return year + '-' + month + '-' + dayText;
    }
    return normalized;
  }

  private static buildCourseList(candidates: Array<JsonCandidate>, termLabel: string,
    logs: Array<string>): Array<Course> {
    const result: Array<Course> = [];
    const dedupe: Set<string> = new Set<string>();
    const timeSeed: string = new Date().getTime().toString();
    for (let index = 0; index < candidates.length; index++) {
      const item: JsonCandidate = candidates[index];
      if (item.courseName.trim().length === 0 || item.dayOfWeek < 1 || item.dayOfWeek > 7 ||
        item.startSection <= 0 || item.endSection < item.startSection) {
        continue;
      }
      const key: string = [
        item.courseName.trim(), item.teacherName.trim(), item.classroom.trim(), item.dayOfWeek.toString(),
        item.startSection.toString(), item.endSection.toString(), item.weekIndexes.join(',')
      ].join('|');
      if (dedupe.has(key)) {
        continue;
      }
      dedupe.add(key);
      result.push(new Course(
        'course-' + timeSeed + '-' + index.toString(),
        item.courseName.trim(),
        item.teacherName.trim(),
        item.classroom.trim(),
        item.dayOfWeek,
        item.startSection,
        item.endSection,
        item.weekIndexes,
        item.rawWeekText,
        'NUIST_JWXT',
        termLabel,
        new Date()
      ));
    }
    logs.push('candidateCount=' + candidates.length.toString());
    logs.push('courseCount=' + result.length.toString());
    return result;
  }

  private static parseFromApiRowJsonList(apiRowJsonList: Array<string>, logs: Array<string>): Array<JsonCandidate> {
    const result: Array<JsonCandidate> = [];
    for (let index = 0; index < apiRowJsonList.length; index++) {
      const rowJson: string = apiRowJsonList[index];
      const parsedFromMeeting: Array<JsonCandidate> = NuistCourseImportService.parseMeetingCandidatesFromRowJson(rowJson);
      if (parsedFromMeeting.length > 0) {
        for (let meetingIndex = 0; meetingIndex < parsedFromMeeting.length; meetingIndex++) {
          result.push(parsedFromMeeting[meetingIndex]);
        }
        continue;
      }
      const parsedSingle: JsonCandidate = NuistCourseImportService.parseSingleCandidateFromRowJson(rowJson);
      if (parsedSingle.courseName.trim().length > 0) {
        result.push(parsedSingle);
      }
    }
    logs.push('parseFromApiRowJsonList=' + result.length.toString());
    return result;
  }

  private static parseMeetingCandidatesFromRowJson(rowJson: string): Array<JsonCandidate> {
    const result: Array<JsonCandidate> = [];
    const meetingText: string = NuistCourseImportService.readStringValue(rowJson,
      ['__MEETING_TEXT', 'YPSJDD', 'PKSJ', 'SJDD', 'SKSJ', 'SKSJMS', 'SJDDMS', 'PKSJMS', 'meetingText']);
    if (meetingText.trim().length === 0) {
      return result;
    }
    const courseName: string = NuistCourseImportService.readStringValue(rowJson,
      ['__COURSE_NAME', 'KCM', 'KCMC', 'KCMC_DISPLAY', 'KCDM_DISPLAY', 'courseName', 'course_name', '课程名']);
    if (courseName.trim().length === 0) {
      return result;
    }
    const teacherName: string = NuistCourseImportService.readStringValue(rowJson,
      ['__TEACHER_NAME', 'SKJS', 'JSXM', 'JSXM_DISPLAY', 'teacherName', 'teacher_name', '教师']);
    const fallbackRoom: string = NuistCourseImportService.buildClassroomFromRowJson(rowJson);
    const segments: Array<string> = NuistCourseImportService.splitMeetingText(meetingText);
    for (let index = 0; index < segments.length; index++) {
      const segment: string = segments[index];
      const match: RegExpMatchArray | null = segment.match(/([0-9,\-单双周至]+)\s*星期([一二三四五六日天])\s*(\d{1,2})\s*[\-~—至]\s*(\d{1,2})\s*节\s*(.*)$/);
      if (match === null || match.length < 6) {
        continue;
      }
      const rawWeekText: string = match[1].trim();
      const dayText: string = '星期' + match[2];
      const classroom: string = match[5].trim().length > 0 ? match[5].trim() : fallbackRoom;
      result.push({
        courseName: courseName,
        teacherName: teacherName,
        classroom: classroom,
        dayOfWeek: NuistCourseImportService.normalizeDayOfWeek(dayText),
        startSection: Number(match[3]),
        endSection: Number(match[4]),
        rawWeekText: rawWeekText,
        weekIndexes: NuistCourseImportService.parseWeekIndexes(rawWeekText, segment)
      });
    }
    return result;
  }

  private static splitMeetingText(meetingText: string): Array<string> {
    const normalized: string = NuistCourseImportService.normalizeText(meetingText).replace(/，/g, ',');
    const matches: Array<string> = [];
    const regex: RegExp = /([0-9,\-单双周至]+\s*星期[一二三四五六日天]\s*\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节\s*[^,\n]+)/g;
    let match: RegExpExecArray | null = regex.exec(normalized);
    while (match !== null) {
      matches.push(match[1]);
      match = regex.exec(normalized);
    }
    if (matches.length > 0) {
      return matches;
    }
    return new Array<string>(normalized);
  }

  private static parseSingleCandidateFromRowJson(rowJson: string): JsonCandidate {
    const courseName: string = NuistCourseImportService.readStringValue(rowJson,
      ['__COURSE_NAME', 'KCM', 'KCMC', 'KCMC_DISPLAY', 'KCDM_DISPLAY', 'courseName', 'course_name', '课程名']);
    if (courseName.trim().length === 0) {
      return NuistCourseImportService.emptyCandidate();
    }
    const teacherName: string = NuistCourseImportService.readStringValue(rowJson,
      ['__TEACHER_NAME', 'SKJS', 'JSXM', 'JSXM_DISPLAY', 'teacherName', 'teacher_name', '教师']);
    const classroom: string = NuistCourseImportService.buildClassroomFromRowJson(rowJson);
    const dayOfWeek: number = NuistCourseImportService.readWeekdayValue(rowJson,
      ['__DAY_OF_WEEK', 'SKXQ', 'XQJ', 'XQ', 'XQMC', 'SKXQ_DISPLAY', 'weekDay', 'weekday', '星期']);
    const startSection: number = NuistCourseImportService.readNumberValue(rowJson,
      ['__START_SECTION', 'KSJC', 'KSJCDM', 'QSJC', 'startSection', '开始节次']);
    const endSection: number = NuistCourseImportService.readNumberValue(rowJson,
      ['__END_SECTION', 'JSJC', 'JSJCDM', 'ZSJC', 'endSection', '结束节次']);
    const rawWeekText: string = NuistCourseImportService.readStringValue(rowJson,
      ['__RAW_WEEK_TEXT', 'ZCMC', 'SKSJ', 'YPSJDD', 'weekText', '周次']);
    let weekIndexes: Array<number> = [];
    const skzcValue: string = NuistCourseImportService.readStringValue(rowJson, ['__WEEK_BITS', 'SKZC', 'weekBits']);
    if (skzcValue.trim().length > 0) {
      weekIndexes = NuistCourseImportService.parseWeekIndexesFromBitString(skzcValue);
    }
    if (weekIndexes.length === 0) {
      weekIndexes = NuistCourseImportService.parseWeekIndexes(rawWeekText, rowJson);
    }
    return {
      courseName: courseName,
      teacherName: teacherName,
      classroom: classroom,
      dayOfWeek: dayOfWeek,
      startSection: startSection,
      endSection: endSection > 0 ? endSection : startSection,
      rawWeekText: rawWeekText,
      weekIndexes: weekIndexes
    };
  }

  private static buildClassroomFromRowJson(rowJson: string): string {
    const room: string = NuistCourseImportService.readStringValue(rowJson,
      ['__CLASSROOM', 'JASMC', 'CDMC', 'JASMC_DISPLAY', 'CDMC_DISPLAY', 'classroom', '教室']);
    if (room.trim().length > 0) {
      return room;
    }
    const building: string = NuistCourseImportService.readStringValue(rowJson,
      ['JXLDM_DISPLAY', 'JXLMC', 'JXLMC_DISPLAY', '教学楼']);
    const place: string = NuistCourseImportService.readStringValue(rowJson,
      ['JASDM', 'CDDM', 'JASDM_DISPLAY', 'CDDM_DISPLAY', 'roomCode']);
    return (building + ' ' + place).trim();
  }


  private static parseFromRawJsonHeuristic(apiRowJsonList: Array<string>, logs: Array<string>): Array<JsonCandidate> {
    const result: Array<JsonCandidate> = [];
    for (let index = 0; index < apiRowJsonList.length; index++) {
      const candidate: JsonCandidate = NuistCourseImportService.parseGenericCandidateFromRowJson(apiRowJsonList[index]);
      if (candidate.courseName.trim().length > 0 && candidate.dayOfWeek > 0 && candidate.startSection > 0) {
        result.push(candidate);
      }
    }
    logs.push('parseFromRawJsonHeuristic=' + result.length.toString());
    return result;
  }

  private static parseGenericCandidateFromRowJson(rowJson: string): JsonCandidate {
    const values: Array<string> = NuistCourseImportService.extractAllJsonStringValues(rowJson);
    const courseName: string = NuistCourseImportService.pickCourseNameFromValues(values);
    if (courseName.length === 0) {
      return NuistCourseImportService.emptyCandidate();
    }
    const teacherName: string = NuistCourseImportService.pickTeacherNameFromValues(values);
    const meetingText: string = NuistCourseImportService.pickMeetingTextFromValues(values, rowJson);
    const classroom: string = NuistCourseImportService.pickClassroomFromValues(values, rowJson, meetingText);
    const sectionRange: SectionRange = NuistCourseImportService.parseSectionRange(meetingText.length > 0 ? meetingText : rowJson);
    const rawWeekText: string = NuistCourseImportService.pickWeekTextFromValues(values, rowJson, meetingText);
    const weekIndexes: Array<number> = NuistCourseImportService.parseWeekIndexes(rawWeekText, meetingText.length > 0 ? meetingText : rowJson);
    return {
      courseName: courseName,
      teacherName: teacherName,
      classroom: classroom,
      dayOfWeek: NuistCourseImportService.normalizeDayOfWeek(meetingText.length > 0 ? meetingText : rowJson),
      startSection: sectionRange.startSection,
      endSection: sectionRange.endSection,
      rawWeekText: rawWeekText,
      weekIndexes: weekIndexes
    };
  }

  private static extractAllJsonStringValues(rowJson: string): Array<string> {
    const result: Array<string> = [];
    const regex: RegExp = /:\s*"([^\"]*)"/g;
    let match: RegExpExecArray | null = regex.exec(rowJson);
    while (match !== null) {
      const value: string = NuistCourseImportService.decodeUnicode(match[1]).trim();
      if (value.length > 0) {
        result.push(value);
      }
      match = regex.exec(rowJson);
    }
    return result;
  }

  private static pickCourseNameFromValues(values: Array<string>): string {
    for (let index = 0; index < values.length; index++) {
      const value: string = values[index].trim();
      if (value.length < 2 || value.length > 40) {
        continue;
      }
      if (NuistCourseImportService.looksLikeScheduleText(value) ||
        NuistCourseImportService.looksLikeTeacherName(value) ||
        NuistCourseImportService.looksLikeClassroom(value)) {
        continue;
      }
      if (/[\u4E00-\u9FA5A-Za-z]{2,}/.test(value)) {
        return value;
      }
    }
    return '';
  }

  private static pickTeacherNameFromValues(values: Array<string>): string {
    for (let index = 0; index < values.length; index++) {
      const value: string = values[index].trim();
      if (NuistCourseImportService.looksLikeTeacherName(value)) {
        return value.replace(/教师|老师/g, '').replace(/[:：]/g, '').trim();
      }
    }
    return '';
  }

  private static pickMeetingTextFromValues(values: Array<string>, rowJson: string): string {
    for (let index = 0; index < values.length; index++) {
      const value: string = values[index].trim();
      if (NuistCourseImportService.looksLikeScheduleText(value)) {
        return value;
      }
    }
    const merged: string = NuistCourseImportService.decodeUnicode(rowJson);
    const match: RegExpMatchArray | null = merged.match(/([0-9,\-单双周第至\s]*(?:星期|周)[一二三四五六日天][^\"]{0,60}?\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节[^\"]{0,40})/);
    if (match !== null && match.length >= 2) {
      return match[1];
    }
    return '';
  }

  private static pickWeekTextFromValues(values: Array<string>, rowJson: string, meetingText: string): string {
    for (let index = 0; index < values.length; index++) {
      const value: string = values[index].trim();
      if (NuistCourseImportService.looksLikeWeekText(value)) {
        return value;
      }
    }
    const fromMeeting: string = NuistCourseImportService.readWeekTextFromTextBlock(meetingText);
    if (fromMeeting.length > 0) {
      return fromMeeting;
    }
    return NuistCourseImportService.readWeekTextFromTextBlock(NuistCourseImportService.decodeUnicode(rowJson));
  }

  private static pickClassroomFromValues(values: Array<string>, rowJson: string, meetingText: string): string {
    for (let index = 0; index < values.length; index++) {
      const value: string = values[index].trim();
      if (NuistCourseImportService.looksLikeClassroom(value)) {
        if (meetingText.length === 0 || meetingText.indexOf(value) < 0 || value.length >= 4) {
          return value;
        }
      }
    }
    const meetingRoom: string = NuistCourseImportService.extractClassroomFromMeetingText(meetingText);
    if (meetingRoom.length > 0) {
      return meetingRoom;
    }
    const decoded: string = NuistCourseImportService.decodeUnicode(rowJson);
    const match: RegExpMatchArray | null = decoded.match(/(?:教室|地点|上课地点)["\\:：\s]*([^",}{]{2,30})/);
    if (match !== null && match.length >= 2) {
      return match[1].trim();
    }
    return '';
  }

  private static extractClassroomFromMeetingText(meetingText: string): string {
    const normalized: string = NuistCourseImportService.normalizeText(meetingText);
    const match: RegExpMatchArray | null = normalized.match(/\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节\s*(.+)$/);
    if (match !== null && match.length >= 2) {
      return match[1].trim();
    }
    return '';
  }

  private static looksLikeScheduleText(value: string): boolean {
    return /(?:星期|周)[一二三四五六日天]/.test(value) ||
      /\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节/.test(value) ||
      /(?:单双周|单周|双周)/.test(value);
  }

  private static looksLikeWeekText(value: string): boolean {
    return /\d{1,2}\s*(?:-|—|至)\s*\d{1,2}\s*周/.test(value) ||
      /(?:单双周|单周|双周)/.test(value) ||
      /(?:^|,)(\d{1,2})(?:,|$)/.test(value);
  }

  private static looksLikeTeacherName(value: string): boolean {
    if (/(?:教师|老师)/.test(value)) {
      return true;
    }
    return /^[\u4E00-\u9FA5·]{2,4}$/.test(value);
  }

  private static looksLikeClassroom(value: string): boolean {
    return /(教|楼|室|实验|机房|A\d|B\d|C\d|D\d|N\d|S\d)/.test(value);
  }

  private static parseWeekIndexesFromBitString(text: string): Array<number> {
    const normalized: string = text.trim();
    const result: Array<number> = [];
    if (!/^[01]{1,40}$/.test(normalized)) {
      return result;
    }
    for (let index = 0; index < normalized.length; index++) {
      if (normalized.charAt(index) === '1') {
        result.push(index + 1);
      }
    }
    return result;
  }

  private static parseFromPlainText(text: string, logs: Array<string>): Array<JsonCandidate> {
    const result: Array<JsonCandidate> = [];
    const normalized: string = NuistCourseImportService.normalizeText(text);
    const lines: Array<string> = normalized.split('\n').map((item: string) => item.trim()).filter((item: string) => {
      return item.length > 0;
    });
    for (let index = 0; index < lines.length; index++) {
      const mergedLine: string = index + 3 < lines.length ?
        lines[index] + ' ' + lines[index + 1] + ' ' + lines[index + 2] + ' ' + lines[index + 3] : lines[index];
      const parsedCandidate: JsonCandidate = NuistCourseImportService.parseCourseTextBlock(mergedLine, 0, 0, 0, false);
      if (parsedCandidate.courseName.trim().length === 0) {
        continue;
      }
      if (parsedCandidate.dayOfWeek === 0 || parsedCandidate.startSection === 0) {
        continue;
      }
      result.push(parsedCandidate);
    }
    logs.push('parseFromPlainText=' + result.length.toString());
    return result;
  }

  private static parseCourseTextBlock(text: string, defaultDayOfWeek: number, defaultStartSection: number,
    defaultEndSection: number, needWeekInfo: boolean): JsonCandidate {
    const normalized: string = NuistCourseImportService.normalizeText(text);
    const lines: Array<string> = normalized.split('\n').map((item: string) => item.trim()).filter((item: string) => {
      return item.length > 0;
    });
    const rawWeekText: string = NuistCourseImportService.readWeekTextFromTextBlock(normalized);
    if (needWeekInfo && rawWeekText.length === 0 && lines.length <= 1) {
      return NuistCourseImportService.emptyCandidate();
    }
    const sectionRange: SectionRange = NuistCourseImportService.parseSectionRange(normalized);
    const dayOfWeek: number = NuistCourseImportService.normalizeDayOfWeek(normalized);
    const courseName: string = NuistCourseImportService.readCourseNameFromLines(lines);
    if (courseName.length === 0) {
      return NuistCourseImportService.emptyCandidate();
    }
    const teacherName: string = NuistCourseImportService.readTeacherFromTextBlock(normalized, lines);
    const classroom: string = NuistCourseImportService.readClassroomFromTextBlock(normalized, lines);
    const resolvedDay: number = dayOfWeek > 0 ? dayOfWeek : defaultDayOfWeek;
    const resolvedStart: number = sectionRange.startSection > 0 ? sectionRange.startSection : defaultStartSection;
    const resolvedEnd: number = sectionRange.endSection > 0 ? sectionRange.endSection : defaultEndSection;
    return {
      courseName: courseName,
      teacherName: teacherName,
      classroom: classroom,
      dayOfWeek: resolvedDay,
      startSection: resolvedStart,
      endSection: resolvedEnd > 0 ? resolvedEnd : resolvedStart,
      rawWeekText: rawWeekText,
      weekIndexes: NuistCourseImportService.parseWeekIndexes(rawWeekText, normalized)
    };
  }

  private static emptyCandidate(): JsonCandidate {
    return {
      courseName: '',
      teacherName: '',
      classroom: '',
      dayOfWeek: 0,
      startSection: 0,
      endSection: 0,
      rawWeekText: '',
      weekIndexes: new Array<number>()
    };
  }

  private static extractTermLabel(text: string, html: string): string {
    const merged: string = text + '\n' + html;
    const match: RegExpMatchArray | null = merged.match(/(20\d{2}\s*[-—]\s*20\d{2}\s*学年\s*第?[一二三四1-4]\s*学期)/);
    if (match !== null && match.length >= 2) {
      return match[1].replace(/\s+/g, '');
    }
    return '当前学期';
  }

  private static parseSectionRange(text: string): SectionRange {
    const normalized: string = NuistCourseImportService.normalizeText(text);
    let match: RegExpMatchArray | null = normalized.match(/第?\s*(\d{1,2})\s*[\-~—至]\s*(\d{1,2})\s*节?/);
    if (match !== null && match.length >= 3) {
      return {
        startSection: Number(match[1]),
        endSection: Number(match[2])
      };
    }
    match = normalized.match(/^\s*(\d{1,2})\s*$/);
    if (match !== null && match.length >= 2) {
      return {
        startSection: Number(match[1]),
        endSection: Number(match[1])
      };
    }
    match = normalized.match(/第?\s*(\d{1,2})\s*节/);
    if (match !== null && match.length >= 2) {
      return {
        startSection: Number(match[1]),
        endSection: Number(match[1])
      };
    }
    return {
      startSection: 0,
      endSection: 0
    };
  }

  private static readCourseNameFromLines(lines: Array<string>): string {
    for (let index = 0; index < lines.length; index++) {
      const line: string = lines[index];
      if (line.length < 2 || line.length > 40) {
        continue;
      }
      if (NuistCourseImportService.readWeekTextFromTextBlock(line).length > 0) {
        continue;
      }
      if (NuistCourseImportService.normalizeDayOfWeek(line) > 0) {
        continue;
      }
      if (NuistCourseImportService.parseSectionRange(line).startSection > 0) {
        continue;
      }
      if (line.indexOf('教师') >= 0 || line.indexOf('老师') >= 0 || line.indexOf('教室') >= 0 || line.indexOf('地点') >= 0) {
        continue;
      }
      if ((line.indexOf('课表') >= 0 || line.indexOf('课程') >= 0) && line.length <= 6) {
        continue;
      }
      return line;
    }
    return '';
  }

  private static readTeacherFromTextBlock(text: string, lines: Array<string>): string {
    let match: RegExpMatchArray | null = text.match(/(?:教师|老师)[:：]?\s*([\u4E00-\u9FA5A-Za-z·]{2,20})/);
    if (match !== null && match.length >= 2) {
      return match[1];
    }
    for (let index = 0; index < lines.length; index++) {
      const line: string = lines[index];
      if (line.indexOf('教师') >= 0 || line.indexOf('老师') >= 0) {
        const normalized: string = line.replace('教师', '').replace('老师', '').replace(':', '').replace('：', '').trim();
        return normalized;
      }
    }
    return '';
  }

  private static readClassroomFromTextBlock(text: string, lines: Array<string>): string {
    let match: RegExpMatchArray | null = text.match(/(?:教室|地点|上课地点)[:：]?\s*([^\n]{2,40})/);
    if (match !== null && match.length >= 2) {
      return match[1].trim();
    }
    for (let index = 0; index < lines.length; index++) {
      const line: string = lines[index];
      if (line.indexOf('教室') >= 0 || line.indexOf('地点') >= 0 || line.indexOf('楼') >= 0 || line.indexOf('室') >= 0 ||
        line.indexOf('实验') >= 0 || line.indexOf('机房') >= 0) {
        if (NuistCourseImportService.readWeekTextFromTextBlock(line).length === 0 &&
          NuistCourseImportService.parseSectionRange(line).startSection === 0) {
          return line.replace('教室', '').replace('地点', '').replace(':', '').replace('：', '').trim();
        }
      }
    }
    return '';
  }

  private static readStringValue(fragment: string, aliases: Array<string>): string {
    for (let index = 0; index < aliases.length; index++) {
      const alias: string = aliases[index].replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const patterns: Array<RegExp> = [
        new RegExp('"' + alias + '"\\s*:\\s*"([^\"]*)"'),
        new RegExp(alias + '\\s*[:=]\\s*"([^\"]*)"')
      ];
      for (let patternIndex = 0; patternIndex < patterns.length; patternIndex++) {
        const match: RegExpMatchArray | null = fragment.match(patterns[patternIndex]);
        if (match !== null && match.length >= 2) {
          return NuistCourseImportService.decodeUnicode(match[1]);
        }
      }
    }
    return '';
  }

  private static decodeUnicode(text: string): string {
    return text.replace(/\\u([0-9a-fA-F]{4})/g, (fullMatch: string, code: string): string => {
      return String.fromCharCode(parseInt(code, 16));
    });
  }

  private static readNumberValue(fragment: string, aliases: Array<string>): number {
    for (let index = 0; index < aliases.length; index++) {
      const alias: string = aliases[index].replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
      const patterns: Array<RegExp> = [
        new RegExp('"' + alias + '"\\s*:\\s*(\\d{1,2})'),
        new RegExp(alias + '\\s*[:=]\\s*(\\d{1,2})')
      ];
      for (let patternIndex = 0; patternIndex < patterns.length; patternIndex++) {
        const match: RegExpMatchArray | null = fragment.match(patterns[patternIndex]);
        if (match !== null && match.length >= 2) {
          return Number(match[1]);
        }
      }
    }
    return 0;
  }

  private static readWeekdayValue(fragment: string, aliases: Array<string>): number {
    const numeric: number = NuistCourseImportService.readNumberValue(fragment, aliases);
    if (numeric >= 1 && numeric <= 7) {
      return numeric;
    }
    const text: string = NuistCourseImportService.readStringValue(fragment, aliases);
    return NuistCourseImportService.normalizeDayOfWeek(text);
  }

  private static normalizeDayOfWeek(text: string): number {
    const normalized: string = NuistCourseImportService.normalizeText(text).replace(/星期/g, '周');
    if (normalized.indexOf('周一') >= 0) {
      return 1;
    }
    if (normalized.indexOf('周二') >= 0) {
      return 2;
    }
    if (normalized.indexOf('周三') >= 0) {
      return 3;
    }
    if (normalized.indexOf('周四') >= 0) {
      return 4;
    }
    if (normalized.indexOf('周五') >= 0) {
      return 5;
    }
    if (normalized.indexOf('周六') >= 0) {
      return 6;
    }
    if (normalized.indexOf('周日') >= 0 || normalized.indexOf('周天') >= 0) {
      return 7;
    }
    return 0;
  }

  private static readWeekTextFromTextBlock(text: string): string {
    const match: RegExpMatchArray | null = text.match(/((?:第?\s*\d{1,2}\s*[\-~—至]?\s*\d{0,2}\s*周|\d{1,2}\s*周|单双周|单周|双周|,)+)/);
    if (match !== null && match.length >= 2) {
      return match[1].replace(/\s+/g, '');
    }
    return '';
  }

  private static parseWeekIndexes(rawWeekText: string, fallbackText: string): Array<number> {
    const sourceText: string = rawWeekText.trim().length > 0 ? rawWeekText : fallbackText;
    const normalized: string = sourceText.replace(/\s+/g, '').replace(/，/g, ',').replace(/至/g, '-');
    const result: Array<number> = [];
    const shortRangeMatch: RegExpMatchArray | null = normalized.match(/^(\d{1,2})-(\d{1,2})(单双周|单周|双周)?$/);
    if (shortRangeMatch !== null && shortRangeMatch.length >= 3) {
      const shortStart: number = Number(shortRangeMatch[1]);
      const shortEnd: number = Number(shortRangeMatch[2]);
      const shortMode: string = shortRangeMatch.length >= 4 ? shortRangeMatch[3] : '';
      NuistCourseImportService.appendWeekRange(result, shortStart, shortEnd, shortMode);
      result.sort((first: number, second: number) => first - second);
      return result;
    }
    const rangeRegex: RegExp = /(\d{1,2})(?:-(\d{1,2}))?周(单双周|单周|双周)?/g;
    let rangeMatch: RegExpExecArray | null = rangeRegex.exec(normalized);
    while (rangeMatch !== null) {
      const start: number = Number(rangeMatch[1]);
      const end: number = rangeMatch[2] ? Number(rangeMatch[2]) : start;
      const mode: string = rangeMatch.length >= 4 ? rangeMatch[3] : '';
      NuistCourseImportService.appendWeekRange(result, start, end, mode);
      rangeMatch = rangeRegex.exec(normalized);
    }
    const plainNumberRegex: RegExp = /(?:^|,)(\d{1,2})(?:,|$)/g;
    let numberMatch: RegExpExecArray | null = plainNumberRegex.exec(normalized);
    while (numberMatch !== null) {
      const weekIndex: number = Number(numberMatch[1]);
      if (result.indexOf(weekIndex) < 0) {
        result.push(weekIndex);
      }
      numberMatch = plainNumberRegex.exec(normalized);
    }
    result.sort((first: number, second: number) => first - second);
    return result;
  }

  private static appendWeekRange(result: Array<number>, start: number, end: number, mode: string): void {
    for (let value = start; value <= end; value++) {
      if (mode === '单周' && value % 2 === 0) {
        continue;
      }
      if (mode === '双周' && value % 2 !== 0) {
        continue;
      }
      if (result.indexOf(value) < 0) {
        result.push(value);
      }
    }
  }

  private static normalizeText(text: string): string {
    return text.replace(/\u00a0/g, ' ').replace(/\r/g, '\n').replace(/\t/g, ' ').replace(/\n+/g, '\n').trim();
  }
}
