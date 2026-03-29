import { Exam } from '../Model/Exam';

export interface ExamDomRowSnapshot {
  text: string;
  cells: Array<string>;
}

export interface ExamPageSnapshot {
  url: string;
  title: string;
  text: string;
  html: string;
  termLabel: string;
  apiRowJsonList: Array<string>;
  domRows: Array<ExamDomRowSnapshot>;
  apiLogText: string;
}

export interface ExamParseResult {
  exams: Array<Exam>;
  termLabel: string;
  message: string;
}

interface ExamCandidate {
  courseName: string;
  teacherName: string;
  classroom: string;
  startTime: string;
  endTime: string;
  rawTimeText: string;
}

interface DateTimePair {
  startTime: string;
  endTime: string;
  rawTimeText: string;
}

export class NuistExamImportService {
  public static readonly LOGIN_URL: string =
    'https://jwxt.nuist.edu.cn/jwapp/sys/emaphome/portal/index.do?forceCas=1';

  public static normalizeRunJavaScriptResult(rawResult: string): string {
    const trimmed: string = rawResult.trim();
    if (trimmed.length === 0 || trimmed === 'null' || trimmed === 'undefined') {
      return '';
    }
    if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
      try {
        return JSON.parse(trimmed) as string;
      } catch (error) {
        console.error('[NuistExamImportService] normalizeRunJavaScriptResult parse quote failed: ' + JSON.stringify(error));
        return trimmed;
      }
    }
    return trimmed;
  }

  public static parseExamPageSnapshot(rawText: string): ExamPageSnapshot {
    const firstPassText: string = NuistExamImportService.normalizeRunJavaScriptResult(rawText);
    const maybeInnerJson: string = NuistExamImportService.tryExtractInnerJsonText(firstPassText);
    if (maybeInnerJson.length > 0) {
      return JSON.parse(maybeInnerJson) as ExamPageSnapshot;
    }
    return JSON.parse(firstPassText) as ExamPageSnapshot;
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

  public static isExamPageUrl(url: string): boolean {
    const lowerUrl: string = url.toLowerCase();
    return lowerUrl.indexOf('studentwdksapapp') >= 0 || lowerUrl.indexOf('wdksap') >= 0 ||
      lowerUrl.indexOf('ksap') >= 0 || lowerUrl.indexOf('kaoshi') >= 0;
  }

  public static canTryOpenExamEntry(url: string): boolean {
    if (url.trim().length === 0) {
      return false;
    }
    if (url.indexOf('/authserver/login') >= 0) {
      return false;
    }
    return url.indexOf('jwxt.nuist.edu.cn') >= 0;
  }

  public static parseSnapshot(snapshot: ExamPageSnapshot): ExamParseResult {
    const logs: Array<string> = [];
    logs.push('url=' + snapshot.url);
    logs.push('title=' + snapshot.title);
    logs.push('termLabel=' + snapshot.termLabel);
    logs.push('apiRowJsonList=' + snapshot.apiRowJsonList.length.toString());
    logs.push('domRows=' + snapshot.domRows.length.toString());
    logs.push('apiLogText=' + snapshot.apiLogText);
    if (snapshot.apiRowJsonList.length > 0) {
      logs.push('apiRowSample=' + snapshot.apiRowJsonList[0].slice(0, 260));
    }
    if (snapshot.domRows.length > 0) {
      logs.push('domRowSample=' + snapshot.domRows[0].text.slice(0, 260));
    }

    let candidates: Array<ExamCandidate> = NuistExamImportService.parseFromApiRows(snapshot.apiRowJsonList, logs);
    if (candidates.length === 0) {
      candidates = NuistExamImportService.parseFromDomRows(snapshot.domRows, logs);
    }
    if (candidates.length === 0) {
      candidates = NuistExamImportService.parseFromPlainText(snapshot.text, logs);
    }

    const termLabel: string = snapshot.termLabel.trim().length > 0 ? snapshot.termLabel :
      NuistExamImportService.extractTermLabel(snapshot.text, snapshot.html);
    const exams: Array<Exam> = NuistExamImportService.buildExamList(candidates, termLabel, logs);
    if (exams.length === 0) {
      console.error('[NuistExamImportService] 导入失败：' + logs.join(' | '));
      return {
        exams: [],
        termLabel: termLabel,
        message: '未识别到本学期考试安排。请把控制台里 [ExamImport] 与 [NuistExamImportService] 日志发给我继续收紧规则。'
      };
    }
    console.info('[NuistExamImportService] 导入成功：' + logs.join(' | '));
    return {
      exams: exams,
      termLabel: termLabel,
      message: '本学期考试安排解析成功，共识别 ' + exams.length.toString() + ' 条考试记录。'
    };
  }

  private static parseFromApiRows(rowList: Array<string>, logs: Array<string>): Array<ExamCandidate> {
    const candidates: Array<ExamCandidate> = [];
    for (let index = 0; index < rowList.length; index++) {
      const rowText: string = rowList[index];
      const candidate: ExamCandidate = NuistExamImportService.buildCandidateFromJsonText(rowText);
      if (candidate.courseName.length > 0 && candidate.startTime.length > 0) {
        candidates.push(candidate);
      }
    }
    logs.push('parseFromApiRows=' + candidates.length.toString());
    return candidates;
  }

  private static parseFromDomRows(domRows: Array<ExamDomRowSnapshot>, logs: Array<string>): Array<ExamCandidate> {
    const candidates: Array<ExamCandidate> = [];
    for (let index = 0; index < domRows.length; index++) {
      const row: ExamDomRowSnapshot = domRows[index];
      const candidate: ExamCandidate = NuistExamImportService.buildCandidateFromCells(row.cells, row.text);
      if (candidate.courseName.length > 0 && candidate.startTime.length > 0) {
        candidates.push(candidate);
      }
    }
    logs.push('parseFromDomRows=' + candidates.length.toString());
    return candidates;
  }

  private static parseFromPlainText(text: string, logs: Array<string>): Array<ExamCandidate> {
    const candidates: Array<ExamCandidate> = [];
    const blockList: Array<string> = text.split(/(?:\n\s*\n)+/).map((item: string) => item.trim()).filter((item: string) => item.length > 0);
    for (let index = 0; index < blockList.length; index++) {
      const block: string = blockList[index];
      const dateTimePair: DateTimePair = NuistExamImportService.extractDateTimePair(block);
      if (dateTimePair.startTime.length === 0) {
        continue;
      }
      const courseName: string = NuistExamImportService.extractCourseNameFromText(block);
      if (courseName.length === 0) {
        continue;
      }
      candidates.push({
        courseName: courseName,
        teacherName: NuistExamImportService.extractTeacherFromText([], block),
        classroom: NuistExamImportService.extractClassroomFromText(block),
        startTime: dateTimePair.startTime,
        endTime: dateTimePair.endTime,
        rawTimeText: dateTimePair.rawTimeText
      });
    }
    logs.push('parseFromPlainText=' + candidates.length.toString());
    return candidates;
  }

  private static buildCandidateFromJsonText(rowText: string): ExamCandidate {
    const courseName: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['KCM', 'KCMC', 'KCMC_DISPLAY', 'KSMC', 'KSMC_DISPLAY', 'KCAP', '课程名称', 'courseName', 'COURSE_NAME']);
    const teacherName: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['SKJS', 'JSXM', 'ZJJS', 'XM', '主讲教师', '教师', 'teacherName']);
    const classroom: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['KCDD', 'KCDD_DISPLAY', 'JASMC', 'JXLDM_DISPLAY', 'KSCDDM', 'KSCDDM_DISPLAY', '考场', '考试地点', '地点', 'location']);
    const dateTimePair: DateTimePair = NuistExamImportService.buildDateTimePairFromJsonText(rowText);
    const fallbackCourse: string = courseName.length > 0 ? courseName : NuistExamImportService.extractCourseNameFromText(rowText);
    const fallbackTeacher: string = teacherName.length > 0 ? teacherName : NuistExamImportService.extractTeacherFromText([], rowText);
    const fallbackClassroom: string = classroom.length > 0 ? classroom : NuistExamImportService.extractClassroomFromText(rowText);
    return {
      courseName: fallbackCourse,
      teacherName: fallbackTeacher,
      classroom: fallbackClassroom,
      startTime: dateTimePair.startTime,
      endTime: dateTimePair.endTime,
      rawTimeText: dateTimePair.rawTimeText
    };
  }

  private static buildCandidateFromCells(cells: Array<string>, rowText: string): ExamCandidate {
    const text: string = rowText.trim().length > 0 ? rowText : cells.join(' ');
    const dateTimePair: DateTimePair = NuistExamImportService.extractDateTimePair(text);
    const classroom: string = NuistExamImportService.extractClassroomFromText(text);
    const teacherName: string = NuistExamImportService.extractTeacherFromText(cells, text);
    const courseName: string = NuistExamImportService.extractCourseNameFromCells(cells, text);
    return {
      courseName: courseName,
      teacherName: teacherName,
      classroom: classroom,
      startTime: dateTimePair.startTime,
      endTime: dateTimePair.endTime,
      rawTimeText: dateTimePair.rawTimeText
    };
  }

  private static buildDateTimePairFromJsonText(rowText: string): DateTimePair {
    const startRaw: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['KSSJ', 'KSSJ_DISPLAY', '开始时间', 'startTime', 'START_TIME']);
    const endRaw: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['JSSJ', 'JSSJ_DISPLAY', '结束时间', 'endTime', 'END_TIME']);
    const dateRaw: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['KSRQ', 'KSRQ_DISPLAY', '考试日期', 'date', 'DATE']);
    const fallbackRaw: string = NuistExamImportService.pickFirstJsonValue(rowText,
      ['KSSJMC', 'TIME_TEXT', '安排说明', 'KSAPMC']);
    return NuistExamImportService.normalizeDateTimePair(dateRaw, startRaw, endRaw, fallbackRaw.length > 0 ? fallbackRaw : rowText);
  }

  private static normalizeDateTimePair(dateRaw: string, startRaw: string, endRaw: string, fallbackRaw: string): DateTimePair {
    const mergedDateText: string = dateRaw.trim();
    const startText: string = startRaw.trim();
    const endText: string = endRaw.trim();
    const rawTimeText: string = [mergedDateText, startText, endText, fallbackRaw.trim()]
      .filter((item: string) => item.length > 0).join(' ');

    if (NuistExamImportService.looksLikeFullDateTime(startText)) {
      const normalizedStart: string = NuistExamImportService.normalizeDateTimeString(startText);
      const normalizedEnd: string = NuistExamImportService.looksLikeFullDateTime(endText) ?
        NuistExamImportService.normalizeDateTimeString(endText) :
        NuistExamImportService.combineDateAndTime(normalizedStart.slice(0, 10), endText);
      return {
        startTime: normalizedStart,
        endTime: normalizedEnd.length > 0 ? normalizedEnd : normalizedStart,
        rawTimeText: rawTimeText
      };
    }

    if (mergedDateText.length > 0 && NuistExamImportService.looksLikeDate(mergedDateText)) {
      const normalizedDate: string = NuistExamImportService.normalizeDateString(mergedDateText);
      const normalizedStart: string = NuistExamImportService.combineDateAndTime(normalizedDate, startText);
      const normalizedEnd: string = NuistExamImportService.combineDateAndTime(normalizedDate, endText);
      return {
        startTime: normalizedStart,
        endTime: normalizedEnd.length > 0 ? normalizedEnd : normalizedStart,
        rawTimeText: rawTimeText
      };
    }

    return NuistExamImportService.extractDateTimePair([dateRaw, startRaw, endRaw, fallbackRaw].join(' '));
  }

  private static extractDateTimePair(text: string): DateTimePair {
    const normalizedText: string = text.replace(/年/g, '-').replace(/月/g, '-').replace(/日/g, ' ')
      .replace(/\//g, '-').replace(/：/g, ':').replace(/至/g, '-').replace(/—/g, '-');
    const fullMatches: Array<string> = normalizedText.match(/\d{4}-\d{1,2}-\d{1,2}\s*\d{1,2}:\d{2}/g) ?? [];
    if (fullMatches.length >= 2) {
      return {
        startTime: NuistExamImportService.normalizeDateTimeString(fullMatches[0]),
        endTime: NuistExamImportService.normalizeDateTimeString(fullMatches[1]),
        rawTimeText: fullMatches[0] + ' - ' + fullMatches[1]
      };
    }
    if (fullMatches.length === 1) {
      return {
        startTime: NuistExamImportService.normalizeDateTimeString(fullMatches[0]),
        endTime: NuistExamImportService.normalizeDateTimeString(fullMatches[0]),
        rawTimeText: fullMatches[0]
      };
    }
    const dateMatch: RegExpMatchArray | null = normalizedText.match(/\d{4}-\d{1,2}-\d{1,2}/);
    const timeMatches: Array<string> = normalizedText.match(/\d{1,2}:\d{2}/g) ?? [];
    if (dateMatch !== null && dateMatch.length > 0 && timeMatches.length > 0) {
      const normalizedDate: string = NuistExamImportService.normalizeDateString(dateMatch[0]);
      const startTime: string = NuistExamImportService.combineDateAndTime(normalizedDate, timeMatches[0]);
      const endTime: string = timeMatches.length >= 2 ?
        NuistExamImportService.combineDateAndTime(normalizedDate, timeMatches[1]) : startTime;
      return {
        startTime: startTime,
        endTime: endTime,
        rawTimeText: normalizedDate + ' ' + timeMatches.join('-')
      };
    }
    return { startTime: '', endTime: '', rawTimeText: '' };
  }

  private static extractCourseNameFromCells(cells: Array<string>, rowText: string): string {
    let best: string = '';
    for (let index = 0; index < cells.length; index++) {
      const cellText: string = cells[index].trim();
      if (cellText.length === 0) {
        continue;
      }
      if (NuistExamImportService.looksLikeDateTimeText(cellText) || NuistExamImportService.looksLikeClassroom(cellText) ||
        NuistExamImportService.looksLikeTeacher(cellText) || NuistExamImportService.looksLikeNoise(cellText)) {
        continue;
      }
      if (cellText.length > best.length) {
        best = cellText;
      }
    }
    if (best.length > 0) {
      return best;
    }
    return NuistExamImportService.extractCourseNameFromText(rowText);
  }

  private static extractCourseNameFromText(text: string): string {
    const cleaned: string = text.replace(/[{}\[\]"]+/g, ' ').replace(/[:,]/g, ' ');
    const lines: Array<string> = cleaned.split(/\s+/).map((item: string) => item.trim()).filter((item: string) => item.length > 0);
    let best: string = '';
    for (let index = 0; index < lines.length; index++) {
      const line: string = lines[index];
      if (NuistExamImportService.looksLikeDateTimeText(line) || NuistExamImportService.looksLikeClassroom(line) ||
        NuistExamImportService.looksLikeTeacher(line) || NuistExamImportService.looksLikeNoise(line)) {
        continue;
      }
      if (line.length > best.length) {
        best = line;
      }
    }
    return best;
  }

  private static extractTeacherFromText(cells: Array<string>, text: string): string {
    for (let index = 0; index < cells.length; index++) {
      if (NuistExamImportService.looksLikeTeacher(cells[index])) {
        return cells[index].trim();
      }
    }
    const match: RegExpMatchArray | null = text.match(/(?:教师|主讲教师|监考教师)[:：]?\s*([\u4e00-\u9fa5]{2,6})/);
    if (match !== null && match.length >= 2) {
      return match[1].trim();
    }
    return '';
  }

  private static extractClassroomFromText(text: string): string {
    const lines: Array<string> = text.split(/\s+/).map((item: string) => item.trim()).filter((item: string) => item.length > 0);
    for (let index = 0; index < lines.length; index++) {
      if (NuistExamImportService.looksLikeClassroom(lines[index])) {
        return lines[index];
      }
    }
    const match: RegExpMatchArray | null = text.match(/(?:地点|考场|教室)[:：]?\s*([^\s]+)/);
    if (match !== null && match.length >= 2) {
      return match[1].trim();
    }
    return '';
  }

  private static looksLikeTeacher(text: string): boolean {
    const trimmed: string = text.trim();
    if (trimmed.length < 2 || trimmed.length > 10) {
      return false;
    }
    if (trimmed.indexOf('教师') >= 0 || trimmed.indexOf('老师') >= 0) {
      return true;
    }
    return /^[\u4e00-\u9fa5]{2,6}$/.test(trimmed);
  }

  private static looksLikeClassroom(text: string): boolean {
    const trimmed: string = text.trim();
    return /(?:楼|室|教|馆|机房|实验|阶梯|考场)/.test(trimmed) || /[A-Za-z]\d{2,}/.test(trimmed);
  }

  private static looksLikeDateTimeText(text: string): boolean {
    return NuistExamImportService.extractDateTimePair(text).startTime.length > 0;
  }

  private static looksLikeNoise(text: string): boolean {
    const trimmed: string = text.trim();
    if (trimmed.length === 0) {
      return true;
    }
    return trimmed === '考试安排' || trimmed === '我的考试安排' || trimmed === '序号' || trimmed === '课程' ||
      trimmed === '教师' || trimmed === '地点' || trimmed === '考试地点' || trimmed === '考试时间' ||
      trimmed === '监考' || trimmed === '查看';
  }

  private static pickFirstJsonValue(rowText: string, keys: Array<string>): string {
    for (let index = 0; index < keys.length; index++) {
      const value: string = NuistExamImportService.extractJsonValue(rowText, keys[index]);
      if (value.length > 0 && value !== 'null' && value !== 'undefined') {
        return value;
      }
    }
    return '';
  }

  private static extractJsonValue(rowText: string, key: string): string {
    const escapedKey: string = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    const stringPattern: RegExp = new RegExp('"' + escapedKey + '"\\s*:\\s*"([^"\\\\]*(?:\\\\.[^"\\\\]*)*)"');
    const stringMatch: RegExpMatchArray | null = rowText.match(stringPattern);
    if (stringMatch !== null && stringMatch.length >= 2) {
      return stringMatch[1].replace(/\\"/g, '"').replace(/\\\\/g, '\\').trim();
    }
    const plainPattern: RegExp = new RegExp('"' + escapedKey + '"\\s*:\\s*([^,}]+)');
    const plainMatch: RegExpMatchArray | null = rowText.match(plainPattern);
    if (plainMatch !== null && plainMatch.length >= 2) {
      return plainMatch[1].replace(/["']/g, '').trim();
    }
    return '';
  }

  private static buildExamList(candidates: Array<ExamCandidate>, termLabel: string, logs: Array<string>): Array<Exam> {
    const result: Array<Exam> = [];
    const dedupe: Set<string> = new Set<string>();
    for (let index = 0; index < candidates.length; index++) {
      const item: ExamCandidate = candidates[index];
      if (item.courseName.trim().length === 0 || item.startTime.trim().length === 0) {
        continue;
      }
      const dedupeKey: string = item.courseName + '|' + item.startTime + '|' + item.classroom;
      if (dedupe.has(dedupeKey)) {
        continue;
      }
      dedupe.add(dedupeKey);
      result.push(new Exam(
        'exam_' + index.toString() + '_' + new Date().getTime().toString(),
        item.courseName,
        item.teacherName,
        item.classroom,
        item.startTime,
        item.endTime.length > 0 ? item.endTime : item.startTime,
        item.rawTimeText,
        termLabel,
        'NUIST_JWXT',
        new Date()
      ));
    }
    logs.push('candidateCount=' + candidates.length.toString());
    logs.push('examCount=' + result.length.toString());
    return result;
  }

  private static extractTermLabel(text: string, html: string): string {
    const mergedText: string = text + ' ' + html;
    const match: RegExpMatchArray | null = mergedText.match(/\d{4}-\d{4}-\d学期/);
    if (match !== null && match.length > 0) {
      return match[0];
    }
    return '';
  }

  private static looksLikeFullDateTime(text: string): boolean {
    return /\d{4}[-/]\d{1,2}[-/]\d{1,2}\s*\d{1,2}:\d{2}/.test(text.trim());
  }

  private static looksLikeDate(text: string): boolean {
    return /\d{4}[-/]\d{1,2}[-/]\d{1,2}/.test(text.trim());
  }

  private static normalizeDateString(text: string): string {
    const match: RegExpMatchArray | null = text.match(/(\d{4})[-/](\d{1,2})[-/](\d{1,2})/);
    if (match === null || match.length < 4) {
      return '';
    }
    return match[1] + '-' + match[2].padStart(2, '0') + '-' + match[3].padStart(2, '0');
  }

  private static combineDateAndTime(dateText: string, timeText: string): string {
    if (dateText.length === 0) {
      return '';
    }
    const timeMatch: RegExpMatchArray | null = timeText.match(/(\d{1,2}):(\d{2})/);
    if (timeMatch === null || timeMatch.length < 3) {
      return dateText + ' 00:00';
    }
    return dateText + ' ' + timeMatch[1].padStart(2, '0') + ':' + timeMatch[2].padStart(2, '0');
  }

  private static normalizeDateTimeString(text: string): string {
    const match: RegExpMatchArray | null = text.match(/(\d{4})[-/](\d{1,2})[-/](\d{1,2})\s*(\d{1,2}):(\d{2})/);
    if (match === null || match.length < 6) {
      return '';
    }
    return match[1] + '-' + match[2].padStart(2, '0') + '-' + match[3].padStart(2, '0') + ' ' +
      match[4].padStart(2, '0') + ':' + match[5].padStart(2, '0');
  }
}
