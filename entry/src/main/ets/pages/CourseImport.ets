import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BasicConstant } from '../Constants/BasicConstant';
import { BreakpointConstant } from '../Constants/BreakpointConstant';
import { ButtonModifier } from './Model/AttributeModifier';
import { courseStore } from './Model/CourseStore';
import { CoursePageSnapshot, CourseParseResult, NuistCourseImportService } from './Service/NuistCourseImportService';

@Entry
@Component
struct CourseImport {
  // [课程导入] Web 仍负责登录，但真正的课表获取改成调用课表模块自身接口，避免单纯抓 DOM 失败。
  private controller: webview.WebviewController = new webview.WebviewController();
  private importPollTimerId: number = -1;
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('themeColor') themeColor: string = '#EA5C2E';
  @State currentUrl: string = NuistCourseImportService.LOGIN_URL;
  @State statusText: string = '请登录南信大统一认证。登录成功后会自动尝试跳转到“我的课表”页面。';
  @State isImporting: boolean = false;
  @State lastResultText: string = '';
  @State hasAutoRedirectTried: boolean = false;
  @State pendingImportAfterRedirect: boolean = false;

  private openPortal(): void {
    try {
      this.hasAutoRedirectTried = false;
      this.pendingImportAfterRedirect = false;
      this.controller.loadUrl(NuistCourseImportService.LOGIN_URL);
      console.info('[CourseImport] 已重新打开南信大统一认证入口');
    } catch (error) {
      console.error('[CourseImport] openPortal failed: ' + JSON.stringify(error));
      this.statusText = '重新打开教务入口失败，请稍后重试。';
    }
  }

  private openCoursePage(): void {
    try {
      this.controller.loadUrl(NuistCourseImportService.COURSE_PAGE_URL);
      console.info('[CourseImport] 已主动打开课表页：' + NuistCourseImportService.COURSE_PAGE_URL);
    } catch (error) {
      console.error('[CourseImport] openCoursePage failed: ' + JSON.stringify(error));
    }
  }

  private startImportFromCurrentPage(): void {
    if (this.isImporting) {
      return;
    }

    if (!NuistCourseImportService.isCoursePageUrl(this.currentUrl)) {
      if (NuistCourseImportService.canTryOpenCoursePage(this.currentUrl)) {
        this.pendingImportAfterRedirect = true;
        this.statusText = '正在进入课表页，进入后会自动导入本学期课表...';
        console.info('[CourseImport] 当前不在课表页，准备自动跳转后导入，currentUrl=' + this.currentUrl);
        this.openCoursePage();
      } else {
        this.statusText = '请先完成统一认证登录，进入教务系统后再导入。';
        promptAction.showToast({ message: '请先登录教务系统' });
      }
      return;
    }

    this.beginImportTask();
  }

  private beginImportTask(): void {
    this.clearImportPollTimer();
    this.isImporting = true;
    this.statusText = '正在获取当前学期、学期开始日期和课程数据...';
    console.info('[CourseImport] beginImportTask, currentUrl=' + this.currentUrl);
    try {
      this.controller.runJavaScript(this.buildImportTaskScript(), (error, result) => {
        if (error) {
          this.finishImportWithFailure('启动课表获取任务失败，请重试。', 'runJavaScript callback error: ' + error.message);
          promptAction.showToast({ message: '启动导入失败' });
          return;
        }
        console.info('[CourseImport] beginImportTask script result=' + result);
        this.pollImportResult(0);
      });
    } catch (error) {
      this.finishImportWithFailure('触发课表获取失败，请重试。', 'runJavaScript failed: ' + JSON.stringify(error));
      promptAction.showToast({ message: '触发导入失败' });
    }
  }

  private pollImportResult(retryCount: number): void {
    this.clearImportPollTimer();
    this.importPollTimerId = setTimeout(() => {
      this.readImportResult(retryCount);
    }, 500);
  }

  private readImportResult(retryCount: number): void {
    try {
      this.controller.runJavaScript('window.__nuistCourseImportResult ? String(window.__nuistCourseImportResult) : ""',
        (error, result) => {
          if (error) {
            this.finishImportWithFailure('读取课表导入结果失败，请重试。', 'readImportResult error: ' + error.message);
            return;
          }
          const normalized: string = NuistCourseImportService.normalizeRunJavaScriptResult(result);
          console.info('[CourseImport] pollImportResult retry=' + retryCount.toString() + ', resultLength=' +
            normalized.length.toString());
          if (normalized.length === 0) {
            if (retryCount >= 24) {
              this.readImportLogsAndFail('课表获取超时，请检查是否已成功进入课表页。');
              return;
            }
            this.pollImportResult(retryCount + 1);
            return;
          }
          this.handleSnapshotResult(normalized);
        });
    } catch (error) {
      this.finishImportWithFailure('轮询课表导入结果失败，请重试。', 'pollImportResult failed: ' + JSON.stringify(error));
    }
  }

  private readImportLogsAndFail(message: string): void {
    try {
      this.controller.runJavaScript('window.__nuistCourseImportLogs ? String(window.__nuistCourseImportLogs) : ""',
        (error, result) => {
          const normalizedLog: string = NuistCourseImportService.normalizeRunJavaScriptResult(result);
          if (error) {
            this.finishImportWithFailure(message, 'readImportLogs error: ' + error.message);
            return;
          }
          this.finishImportWithFailure(message, 'import logs=' + normalizedLog);
        });
    } catch (error) {
      this.finishImportWithFailure(message, 'readImportLogs failed: ' + JSON.stringify(error));
    }
  }

  private handleSnapshotResult(rawResult: string): void {
    try {
      const snapshot: CoursePageSnapshot = NuistCourseImportService.parseCoursePageSnapshot(rawResult);
      console.info('[CourseImport] snapshot url=' + snapshot.url + ', apiTermCode=' + snapshot.apiTermCode +
        ', apiRowJsonList=' + snapshot.apiRowJsonList.length.toString() + ', apiLogLength=' + snapshot.apiLogText.length.toString());
      const parseResult: CourseParseResult = NuistCourseImportService.parseSnapshot(snapshot);
      this.persistParseResult(parseResult, snapshot.url);
    } catch (error) {
      this.readImportLogsAndFail('解析课表接口返回值失败，请重试。');
      console.error('[CourseImport] parse snapshot failed: ' + JSON.stringify(error));
      promptAction.showToast({ message: '课表解析失败' });
    }
  }

  private persistParseResult(parseResult: CourseParseResult, sourceUrl: string): void {
    if (parseResult.courses.length === 0) {
      this.isImporting = false;
      this.statusText = parseResult.message;
      this.lastResultText = parseResult.message;
      promptAction.showToast({ message: '未识别到本学期课程' });
      return;
    }

    courseStore.replaceAllAndFlush(parseResult.courses, parseResult.termLabel, parseResult.termStartDate, sourceUrl)
      .then(() => {
        AppStorage.setOrCreate('isExportCourseSchedule', true);
        this.isImporting = false;
        this.lastResultText = '已导入 ' + parseResult.courses.length.toString() + ' 条课程记录';
        this.statusText = parseResult.message;
        console.info('[CourseImport] save success, courseCount=' + parseResult.courses.length.toString() +
          ', termLabel=' + parseResult.termLabel + ', termStartDate=' + parseResult.termStartDate);
        promptAction.showToast({ message: '本学期课表导入成功' });
        this.clearImportResultInPage();
      })
      .catch((error: Error) => {
        this.finishImportWithFailure('写入本地课程库失败，请重试。', 'save store failed: ' + error.message);
        promptAction.showToast({ message: '课表保存失败' });
      });
  }

  private finishImportWithFailure(message: string, logText: string): void {
    this.clearImportPollTimer();
    this.isImporting = false;
    this.statusText = message;
    this.lastResultText = message;
    console.error('[CourseImport] ' + logText);
  }

  private clearImportPollTimer(): void {
    if (this.importPollTimerId >= 0) {
      clearTimeout(this.importPollTimerId);
      this.importPollTimerId = -1;
    }
  }

  private clearImportResultInPage(): void {
    try {
      this.controller.runJavaScript('window.__nuistCourseImportResult = ""; window.__nuistCourseImportLogs = ""; "CLEARED"',
        (error, result) => {
          if (error) {
            console.error('[CourseImport] clearImportResultInPage error: ' + error.message);
            return;
          }
          console.info('[CourseImport] clearImportResultInPage result=' + result);
        });
    } catch (error) {
      console.error('[CourseImport] clearImportResultInPage failed: ' + JSON.stringify(error));
    }
  }

  private tryAutoRedirectToCoursePage(url: string): void {
    if (this.hasAutoRedirectTried) {
      return;
    }
    if (!NuistCourseImportService.shouldAutoRedirectToCoursePage(url)) {
      return;
    }
    this.hasAutoRedirectTried = true;
    this.statusText = '登录成功，正在自动进入“我的课表”页面...';
    console.info('[CourseImport] tryAutoRedirectToCoursePage, currentUrl=' + url);
    this.openCoursePage();
  }

  private handleCoursePageReady(url: string): void {
    if (!this.pendingImportAfterRedirect) {
      return;
    }
    if (!NuistCourseImportService.isCoursePageUrl(url)) {
      return;
    }
    this.pendingImportAfterRedirect = false;
    console.info('[CourseImport] 课表页已就绪，开始自动导入');
    this.beginImportTask();
  }

  private buildImportTaskScript(): string {
    // [课程导入] 这里改成“在网页上下文中异步请求课表模块接口，然后把结果挂到 window 上供应用轮询读取”。
    return [
      '(function(){',
      '  window.__nuistCourseImportResult = "";',
      '  window.__nuistCourseImportLogs = "bootstrap";',
      '  (async function(){',
      '    var logs = [];',
      '    function pushLog(text){',
      '      logs.push(String(text));',
      '      window.__nuistCourseImportLogs = logs.join(" | ");',
      '    }',
      '    function safeParse(text){',
      '      try {',
      '        return JSON.parse(text);',
      '      } catch (error) {',
      '        pushLog("safeParse failed=" + String(error));',
      '        return null;',
      '      }',
      '    }',
      '    function pickRows(payload){',
      '      if (!payload || !payload.datas) {',
      '        return [];',
      '      }',
      '      for (var key in payload.datas) {',
      '        if (!Object.prototype.hasOwnProperty.call(payload.datas, key)) {',
      '          continue;',
      '        }',
      '        var block = payload.datas[key];',
      '        if (block && block.rows && block.rows.length !== undefined) {',
      '          return block.rows;',
      '        }',
      '      }',
      '      return [];',
      '    }',
      '    function postForm(url, body){',
      '      return fetch(url, {',
      '        method: "POST",',
      '        credentials: "include",',
      '        headers: {',
      '          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",',
      '          "Accept": "application/json, text/javascript, */*; q=0.01",',
      '          "X-Requested-With": "XMLHttpRequest"',
      '        },',
      '        body: body',
      '      }).then(function(response){',
      '        return response.text().then(function(text){',
      '          pushLog("POST " + url + " status=" + response.status + " len=" + text.length);',
      '          return { status: response.status, text: text };',
      '        });',
      '      });',
      '    }',
      '    function readFirstRow(payload){',
      '      var rows = pickRows(payload);',
      '      if (!rows || rows.length === 0) {',
      '        return null;',
      '      }',
      '      return rows[0];',
      '    }',
      '    function trimText(value){',
      '      if (value === null || value === undefined) {',
      '        return "";',
      '      }',
      '      return String(value).replace(/\\u00a0/g, " ").trim();',
      '    }',
      '    try {',
      '      var origin = location.origin;',
      '      pushLog("origin=" + origin);',
      '      pushLog("href=" + location.href);',
      '      var termResponse = await postForm(origin + "/jwapp/sys/wdkb/modules/jshkcb/dqxnxq.do", "");',
      '      var termPayload = safeParse(termResponse.text);',
      '      var termRow = readFirstRow(termPayload);',
      '      if (!termRow) {',
      '        throw new Error("未获取到当前学期信息");',
      '      }',
      '      var termCode = trimText(termRow.DM || termRow.XNXQDM || termRow.code);',
      '      var termLabel = trimText(termRow.MC || termRow.XNXQDM_DISPLAY || termRow.DISPLAY || termCode);',
      '      if (!termCode) {',
      '        throw new Error("当前学期代码为空");',
      '      }',
      '      pushLog("termCode=" + termCode + ", termLabel=" + termLabel);',
      '      var termParts = termCode.split("-");',
      '      var semesterStartDate = "";',
      '      if (termParts.length >= 3) {',
      '        var yearBody = "XN=" + encodeURIComponent(termParts[0] + "-" + termParts[1]) + "&XQ=" + encodeURIComponent(termParts[2]);',
      '        var termInfoResponse = await postForm(origin + "/jwapp/sys/wdkb/modules/jshkcb/cxjcs.do", yearBody);',
      '        var termInfoPayload = safeParse(termInfoResponse.text);',
      '        var termInfoRow = readFirstRow(termInfoPayload);',
      '        if (termInfoRow) {',
      '          semesterStartDate = trimText(termInfoRow.XQKSRQ || termInfoRow.KSRQ || termInfoRow.START_DATE);',
      '        }',
      '      }',
      '      pushLog("semesterStartDate=" + semesterStartDate);',
      '      function collectEntries(node, path, result, depth){',
      '        if (depth > 4 || node === null || node === undefined) {',
      '          return;',
      '        }',
      '        if (Array.isArray(node)) {',
      '          for (var arrIndex = 0; arrIndex < node.length; arrIndex++) {',
      '            collectEntries(node[arrIndex], path + "[" + arrIndex + "]", result, depth + 1);',
      '          }',
      '          return;',
      '        }',
      '        if (typeof node === "object") {',
      '          for (var key in node) {',
      '            if (!Object.prototype.hasOwnProperty.call(node, key)) {',
      '              continue;',
      '            }',
      '            var value = node[key];',
      '            var nextPath = path ? (path + "." + key) : key;',
      '            if (value === null || value === undefined) {',
      '              continue;',
      '            }',
      '            if (typeof value === "string" || typeof value === "number" || typeof value === "boolean") {',
      '              result.push({ key: nextPath, value: trimText(value) });',
      '            } else {',
      '              collectEntries(value, nextPath, result, depth + 1);',
      '            }',
      '          }',
      '        }',
      '      }',
      '      function keyLike(path, patterns){',
      '        var upper = String(path || "").toUpperCase();',
      '        for (var patternIndex = 0; patternIndex < patterns.length; patternIndex++) {',
      '          if (upper.indexOf(patterns[patternIndex]) >= 0) {',
      '            return true;',
      '          }',
      '        }',
      '        return false;',
      '      }',
      '      function pickByKey(entries, patterns){',
      '        for (var entryIndex = 0; entryIndex < entries.length; entryIndex++) {',
      '          var entry = entries[entryIndex];',
      '          if (keyLike(entry.key, patterns) && trimText(entry.value)) {',
      '            return trimText(entry.value);',
      '          }',
      '        }',
      '        return "";',
      '      }',
      '      function looksLikeScheduleText(value){',
      '        return /(?:星期|周)[一二三四五六日天]/.test(value) || /\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节/.test(value) || /(单双周|单周|双周)/.test(value);',
      '      }',
      '      function looksLikeWeekText(value){',
      '        return /\d{1,2}\s*(?:-|—|至)\s*\d{1,2}\s*周/.test(value) || /(单双周|单周|双周)/.test(value);',
      '      }',
      '      function looksLikeCourseName(value){',
      '        if (!value || value.length < 2 || value.length > 40) {',
      '          return false;',
      '        }',
      '        if (looksLikeScheduleText(value)) {',
      '          return false;',
      '        }',
      '        if (/(教室|地点|实验|机房|课表|学期|周次)/.test(value)) {',
      '          return false;',
      '        }',
      '        return /[\u4E00-\u9FA5A-Za-z]{2,}/.test(value);',
      '      }',
      '      function looksLikeClassroom(value){',
      '        return /(教|楼|室|实验|机房|A\d|B\d|C\d|D\d|N\d|S\d)/.test(value);',
      '      }',
      '      function parseWeekday(text){',
      '        var normalized = trimText(text).replace(/星期/g, "周");',
      '        if (normalized.indexOf("周一") >= 0) { return 1; }',
      '        if (normalized.indexOf("周二") >= 0) { return 2; }',
      '        if (normalized.indexOf("周三") >= 0) { return 3; }',
      '        if (normalized.indexOf("周四") >= 0) { return 4; }',
      '        if (normalized.indexOf("周五") >= 0) { return 5; }',
      '        if (normalized.indexOf("周六") >= 0) { return 6; }',
      '        if (normalized.indexOf("周日") >= 0 || normalized.indexOf("周天") >= 0) { return 7; }',
      '        return 0;',
      '      }',
      '      function parseSectionRange(text){',
      '        var match = String(text || "").match(/(\d{1,2})\s*[\-~—至]\s*(\d{1,2})\s*节/);',
      '        if (match && match.length >= 3) {',
      '          return { startSection: Number(match[1]), endSection: Number(match[2]) };',
      '        }',
      '        var singleMatch = String(text || "").match(/第?(\d{1,2})节/);',
      '        if (singleMatch && singleMatch.length >= 2) {',
      '          return { startSection: Number(singleMatch[1]), endSection: Number(singleMatch[1]) };',
      '        }',
      '        return { startSection: 0, endSection: 0 };',
      '      }',
      '      function parseWeekText(text){',
      '        var match = String(text || "").match(/((?:第?\s*\d{1,2}\s*[\-~—至]?\s*\d{0,2}\s*周|\d{1,2}\s*周|单双周|单周|双周|,)+)/);',
      '        return match && match.length >= 2 ? trimText(match[1]).replace(/\s+/g, "") : "";',
      '      }',
      '      function extractClassroomFromSchedule(text){',
      '        var match = String(text || "").match(/\d{1,2}\s*[\-~—至]\s*\d{1,2}\s*节\s*(.+)$/);',
      '        return match && match.length >= 2 ? trimText(match[1]) : "";',
      '      }',
      '      function buildNormalizedRows(row, sourceName){',
      '        var entries = [];',
      '        collectEntries(row, "", entries, 0);',
      '        var courseName = pickByKey(entries, ["KCMC", "KCM", "COURSENAME", "课程"]) || "";',
      '        if (!courseName) {',
      '          for (var valueIndex = 0; valueIndex < entries.length; valueIndex++) {',
      '            var textValue = trimText(entries[valueIndex].value);',
      '            if (looksLikeCourseName(textValue)) {',
      '              courseName = textValue;',
      '              break;',
      '            }',
      '          }',
      '        }',
      '        var teacherName = pickByKey(entries, ["SKJS", "JSXM", "TEACHER", "教师"]);',
      '        var classroom = pickByKey(entries, ["JASMC", "CDMC", "JXLMC", "CLASSROOM", "ROOM", "地点", "教室"]);',
      '        var meetingText = pickByKey(entries, ["YPSJDD", "PKSJ", "SJDD", "SKSJ", "WEEKINFO", "周次"]);',
      '        if (!meetingText) {',
      '          for (var meetIndex = 0; meetIndex < entries.length; meetIndex++) {',
      '            var scheduleValue = trimText(entries[meetIndex].value);',
      '            if (looksLikeScheduleText(scheduleValue)) {',
      '              meetingText = scheduleValue;',
      '              break;',
      '            }',
      '          }',
      '        }',
      '        if (!classroom) {',
      '          classroom = extractClassroomFromSchedule(meetingText);',
      '        }',
      '        var dayOfWeek = Number(pickByKey(entries, ["SKXQ", "XQJ", "WEEKDAY", "XQ"]) || 0);',
      '        if (!(dayOfWeek >= 1 && dayOfWeek <= 7)) {',
      '          dayOfWeek = parseWeekday(meetingText);',
      '        }',
      '        var sectionRange = parseSectionRange(meetingText);',
      '        var startSection = Number(pickByKey(entries, ["KSJC", "KSJCDM", "QSJC", "STARTSECTION"]) || sectionRange.startSection || 0);',
      '        var endSection = Number(pickByKey(entries, ["JSJC", "JSJCDM", "ZSJC", "ENDSECTION"]) || sectionRange.endSection || startSection || 0);',
      '        var rawWeekText = pickByKey(entries, ["ZCMC", "SKZC", "WEEK", "周次"]) || parseWeekText(meetingText);',
      '        var normalizedRow = {',
      '          __IMPORT_SOURCE: sourceName,',
      '          __COURSE_NAME: courseName,',
      '          __TEACHER_NAME: teacherName,',
      '          __CLASSROOM: classroom,',
      '          __MEETING_TEXT: meetingText,',
      '          __DAY_OF_WEEK: dayOfWeek,',
      '          __START_SECTION: startSection,',
      '          __END_SECTION: endSection,',
      '          __RAW_WEEK_TEXT: rawWeekText,',
      '          __RAW_JSON_KEYS: Object.keys(row).join(","),',
      '          __STRING_DUMP: entries.map(function(item){ return item.value; }).join(" || ")',
      '        };',
      '        var finalRow = Object.assign({}, row, normalizedRow);',
      '        if (!finalRow.__COURSE_NAME || !finalRow.__MEETING_TEXT) {',
      '          pushLog("normalized weak row keys=" + finalRow.__RAW_JSON_KEYS);',
      '        }',
      '        return [finalRow];',
      '      }',
      '      var apiRowJsonList = [];',
      '      var requestBodies = [',
      '        { sourceName: "xskcb", path: "/jwapp/sys/wdkb/modules/xskcb/xskcb.do", body: "XNXQDM=" + encodeURIComponent(termCode) },',
      '        { sourceName: "xsllsykb", path: "/jwapp/sys/wdkb/modules/xskcb/xsllsykb.do", body: "XNXQDM=" + encodeURIComponent(termCode) },',
      '        { sourceName: "xsllsykb_week1", path: "/jwapp/sys/wdkb/modules/xskcb/xsllsykb.do", body: "XNXQDM=" + encodeURIComponent(termCode) + "&SKZC=1" }',
      '      ];',
      '      for (var index = 0; index < requestBodies.length; index++) {',
      '        var requestItem = requestBodies[index];',
      '        var courseResponse = await postForm(origin + requestItem.path, requestItem.body);',
      '        var coursePayload = safeParse(courseResponse.text);',
      '        var rows = pickRows(coursePayload);',
      '        pushLog(requestItem.sourceName + " rows=" + rows.length);',
      '        if (rows.length > 0) {',
      '          try {',
      '            pushLog(requestItem.sourceName + " firstKeys=" + Object.keys(rows[0]).join(","));',
      '          } catch (error) {',
      '            pushLog(requestItem.sourceName + " firstKeysFailed=" + String(error));',
      '          }',
      '        }',
      '        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) {',
      '          var row = rows[rowIndex];',
      '          var normalizedRows = buildNormalizedRows(row, requestItem.sourceName);',
      '          for (var normalizedIndex = 0; normalizedIndex < normalizedRows.length; normalizedIndex++) {',
      '            apiRowJsonList.push(JSON.stringify(normalizedRows[normalizedIndex]));',
      '          }',
      '        }',
      '      }',
      '      window.__nuistCourseImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: "",',
      '        tableCells: [],',
      '        pageBlocks: [],',
      '        apiTermCode: termCode,',
      '        apiTermLabel: termLabel,',
      '        semesterStartDate: semesterStartDate,',
      '        apiRowJsonList: apiRowJsonList,',
      '        apiLogText: logs.join(" | ")',
      '      });',
      '    } catch (error) {',
      '      pushLog("import task failed=" + String(error));',
      '      window.__nuistCourseImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: "",',
      '        tableCells: [],',
      '        pageBlocks: [],',
      '        apiTermCode: "",',
      '        apiTermLabel: "",',
      '        semesterStartDate: "",',
      '        apiRowJsonList: [],',
      '        apiLogText: logs.join(" | ")',
      '      });',
      '    }',
      '  })();',
      '  return "STARTED";',
      '})()'
    ].join('');
  }

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        Button() {
          Text('←')
            .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 24 : 20)
            .fontColor(Color.Black)
        }
        .attributeModifier(new ButtonModifier(
          this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
          this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
          $r('app.color.background_gray')
        ))
        .onClick(() => {
          this.clearImportPollTimer();
          this.getUIContext().getRouter().back();
        })

        Column({ space: 4 }) {
          Text('导入南信大课表')
            .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 22 : 26)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Black)
          Text(this.statusText)
            .fontSize(12)
            .fontColor($r('app.color.gray_deep'))
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width(BasicConstant.FULL_WIDTH)
      .padding({ top: this.getUIContext().px2vp(this.topStatusBarHeight) })

      if (this.lastResultText.length > 0) {
        Text(this.lastResultText)
          .fontSize(13)
          .fontColor(this.themeColor)
          .width(BasicConstant.FULL_WIDTH)
      }

      Web({ src: this.currentUrl, controller: this.controller })
        .width(BasicConstant.FULL_WIDTH)
        .layoutWeight(1)
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageEnd((event) => {
          if (event && event.url) {
            this.currentUrl = event.url;
            console.info('[CourseImport] onPageEnd url=' + event.url);
            this.tryAutoRedirectToCoursePage(event.url);
            this.handleCoursePageReady(event.url);
          }
        })

      Row({ space: 10 }) {
        Button('重新打开教务门户')
          .layoutWeight(1)
          .backgroundColor(Color.White)
          .fontColor(this.themeColor)
          .border({ width: 1, color: this.themeColor, radius: 18 })
          .onClick(() => {
            this.openPortal();
          })

        Button(this.isImporting ? '正在导入...' : '导入本学期课表')
          .layoutWeight(1)
          .backgroundColor(this.themeColor)
          .fontColor(Color.White)
          .enabled(!this.isImporting)
          .onClick(() => {
            this.startImportFromCurrentPage();
          })
      }
      .width(BasicConstant.FULL_WIDTH)
      .padding({ bottom: 8 })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding({ left: 16, right: 16, bottom: 12 })
    .backgroundColor(Color.White)
  }
}
