import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BasicConstant } from '../Constants/BasicConstant';
import { BreakpointConstant } from '../Constants/BreakpointConstant';
import { ButtonModifier } from './Model/AttributeModifier';
import { courseStore } from './Model/CourseStore';
import { TodayCourseWidgetHelper } from '../Utils/TodayCourseWidgetHelper'; // [课程卡片] 导入成功后自动同步刷新今日课程卡片。
import { CoursePageSnapshot, CourseParseResult, NuistCourseImportService } from './Service/NuistCourseImportService';

interface PrepareResult {
  status: string;
  selectedLabel: string;
  log: string;
}

@Entry
@Component
struct CourseImport {
  // [课程导入] 先自动切到“理实一体”，再按与理论课相同的接口模式获取当前页对应课表数据。
  private controller: webview.WebviewController = new webview.WebviewController();
  private importPollTimerId: number = -1;
  private preparePollTimerId: number = -1;
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('themeColor') themeColor: string = '#EA5C2E';
  // [课程导入] Web 的初始 src 保持稳定，避免 onPageEnd 更新 currentUrl 后触发重复重建导致页面黑屏。
  private readonly initialWebSrc: string = NuistCourseImportService.LOGIN_URL;
  @State currentUrl: string = NuistCourseImportService.LOGIN_URL;
  @State statusText: string = '请登录南信大统一认证。登录成功后会自动进入“我的课表”并切换到“理实一体”后导入。';
  @State isImporting: boolean = false;
  @State isPreparing: boolean = false;
  @State lastResultText: string = '';
  @State hasAutoRedirectTried: boolean = false;
  @State hasAutoPrepareStarted: boolean = false;

  private openPortal(): void {
    try {
      this.hasAutoRedirectTried = false;
      this.hasAutoPrepareStarted = false;
      this.clearPreparePollTimer();
      this.clearImportPollTimer();
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

  private startPrepareAndImport(): void {
    if (this.isPreparing || this.isImporting) {
      return;
    }
    if (!NuistCourseImportService.isCoursePageUrl(this.currentUrl)) {
      if (NuistCourseImportService.canTryOpenCoursePage(this.currentUrl)) {
        this.statusText = '正在进入课表页，进入后会自动切换到理实一体并导入...';
        console.info('[CourseImport] 当前不在课表页，准备自动跳转，currentUrl=' + this.currentUrl);
        this.openCoursePage();
      } else {
        this.statusText = '请先完成统一认证登录。';
        promptAction.showToast({ message: '请先登录教务系统' });
      }
      return;
    }

    this.isPreparing = true;
    this.statusText = '正在切换到“理实一体”课表...';
    this.clearPreparePollTimer();
    try {
      this.controller.runJavaScript(this.buildPrepareScript(), (error, result) => {
        if (error) {
          this.finishPrepareWithFailure('切换理实一体课表失败，请重试。', 'startPrepareAndImport error: ' + error.message);
          return;
        }
        console.info('[CourseImport] startPrepareAndImport result=' + result);
        this.pollPrepareResult(0);
      });
    } catch (error) {
      this.finishPrepareWithFailure('切换理实一体课表失败，请重试。', 'startPrepareAndImport failed: ' + JSON.stringify(error));
    }
  }

  private buildPrepareScript(): string {
    return [
      '(function(){',
      '  window.__nuistCoursePrepareResult = "";',
      '  window.__nuistCourseCapturedRows = window.__nuistCourseCapturedRows || [];',
      '  window.__nuistCourseCapturedSource = window.__nuistCourseCapturedSource || "";',
      '  window.__nuistCourseCapturedPayloadTexts = window.__nuistCourseCapturedPayloadTexts || [];',
      '  window.__nuistCourseCapturedLog = window.__nuistCourseCapturedLog || "";',
      '  (function(){',
      '    var logs = [];',
      '    function pushLog(text){',
      '      logs.push(String(text));',
      '      window.__nuistCourseCapturedLog = logs.join(" | ");',
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
      '    function captureRows(url, rows, payloadText){',
      '      if (!rows || rows.length === undefined || rows.length === 0) {',
      '        return;',
      '      }',
      '      var source = String(url || "");',
      '      var payloadTextSafe = String(payloadText || "");',
      '      var currentRows = Array.isArray(window.__nuistCourseCapturedRows) ? window.__nuistCourseCapturedRows : [];',
      '      var shouldReplace = currentRows.length === 0 || rows.length > currentRows.length;',
      '      if (source.indexOf("cxxszhxqkb") >= 0) {',
      '        shouldReplace = true;',
      '      }',
      '      if (payloadTextSafe.length > 0) {',
      '        var payloadList = Array.isArray(window.__nuistCourseCapturedPayloadTexts) ? window.__nuistCourseCapturedPayloadTexts : [];',
      '        payloadList.push({ url: source, text: payloadTextSafe.slice(0, 20000) });',
      '        if (payloadList.length > 8) {',
      '          payloadList = payloadList.slice(payloadList.length - 8);',
      '        }',
      '        window.__nuistCourseCapturedPayloadTexts = payloadList;',
      '      }',
      '      if (shouldReplace) {',
      '        window.__nuistCourseCapturedRows = rows;',
      '        window.__nuistCourseCapturedSource = source;',
      '        try {',
      '          pushLog("captured rows=" + rows.length + ", url=" + source + ", firstKeys=" + Object.keys(rows[0]).join(","));',
      '        } catch (error) {',
      '          pushLog("captured rows=" + rows.length + ", url=" + source);',
      '        }',
      '      }',
      '    }',
      '    function installHook(){',
      '      if (window.__nuistCourseHookInstalled) {',
      '        return;',
      '      }',
      '      window.__nuistCourseHookInstalled = true;',
      '      var originalFetch = window.fetch;',
      '      if (typeof originalFetch === "function") {',
      '        window.fetch = function(){',
      '          var requestUrl = arguments.length > 0 ? String(arguments[0]) : "";',
      '          return originalFetch.apply(this, arguments).then(function(response){',
      '            try {',
      '              var cloned = response.clone();',
      '              cloned.text().then(function(text){',
      '                var payload = safeParse(text);',
      '                var rows = pickRows(payload);',
      '                if (requestUrl.indexOf("/jwapp/sys/wdkb/modules/xskcb/") >= 0) {',
      '                  captureRows(requestUrl, rows, text);',
      '                }',
      '              });',
      '            } catch (error) {',
      '              pushLog("fetch hook failed=" + String(error));',
      '            }',
      '            return response;',
      '          });',
      '        };',
      '      }',
      '      var originalOpen = XMLHttpRequest.prototype.open;',
      '      var originalSend = XMLHttpRequest.prototype.send;',
      '      XMLHttpRequest.prototype.open = function(method, url){',
      '        this.__nuistRequestUrl = String(url || "");',
      '        return originalOpen.apply(this, arguments);',
      '      };',
      '      XMLHttpRequest.prototype.send = function(){',
      '        this.addEventListener("load", function(){',
      '          try {',
      '            var requestUrl = String(this.__nuistRequestUrl || "");',
      '            if (requestUrl.indexOf("/jwapp/sys/wdkb/modules/xskcb/") < 0) {',
      '              return;',
      '            }',
      '            var payload = safeParse(String(this.responseText || ""));',
      '            var rows = pickRows(payload);',
      '            captureRows(requestUrl, rows, String(this.responseText || ""));',
      '          } catch (error) {',
      '            pushLog("xhr hook failed=" + String(error));',
      '          }',
      '        });',
      '        return originalSend.apply(this, arguments);',
      '      };',
      '      pushLog("hook installed");',
      '    }',
      '    function textOf(node){',
      '      return String(node.innerText || node.textContent || "").replace(/\s+/g, " ").trim();',
      '    }',
      '    function findTarget(){',
      '      var nodes = Array.prototype.slice.call(document.querySelectorAll("*"));',
      '      for (var index = 0; index < nodes.length; index++) {',
      '        var text = textOf(nodes[index]);',
      '        if (text === "理实一体") {',
      '          return nodes[index];',
      '        }',
      '      }',
      '      return null;',
      '    }',
      '    function clickTarget(node){',
      '      try {',
      '        if (!node) {',
      '          return false;',
      '        }',
      '        node.click();',
      '        try {',
      '          node.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true, view: window }));',
      '        } catch (error) {}',
      '        return true;',
      '      } catch (error) {',
      '        pushLog("click failed=" + String(error));',
      '        return false;',
      '      }',
      '    }',
      '    function finish(status, selectedLabel){',
      '      window.__nuistCoursePrepareResult = JSON.stringify({',
      '        status: status,',
      '        selectedLabel: selectedLabel,',
      '        log: logs.join(" | ")',
      '      });',
      '    }',
      '    try {',
      '      installHook();',
      '      var retry = 0;',
      '      function tick(){',
      '        var target = findTarget();',
      '        if (target) {',
      '          if (clickTarget(target)) {',
      '            pushLog("clicked 理实一体");',
      '          }',
      '        } else {',
      '          pushLog("retry=" + retry + ", 理实一体按钮未找到");',
      '        }',
      '        var capturedRows = Array.isArray(window.__nuistCourseCapturedRows) ? window.__nuistCourseCapturedRows : [];',
      '        if (capturedRows.length > 0) {',
      '          finish("ready", "理实一体");',
      '          return;',
      '        }',
      '        retry += 1;',
      '        if (retry >= 12) {',
      '          finish("failed", target ? "理实一体" : "", logs.join(" | "));',
      '          return;',
      '        }',
      '        setTimeout(tick, 700);',
      '      }',
      '      setTimeout(tick, 600);',
      '    } catch (error) {',
      '      finish("failed", "", logs.join(" | ") + " | prepare failed=" + String(error));',
      '    }',
      '  })();',
      '  return "STARTED";',
      '})()'
    ].join('');
  }

  private pollPrepareResult(retryCount: number): void {
    this.clearPreparePollTimer();
    this.preparePollTimerId = setTimeout(() => {
      this.readPrepareResult(retryCount);
    }, 500);
  }

  private readPrepareResult(retryCount: number): void {
    try {
      this.controller.runJavaScript('window.__nuistCoursePrepareResult ? String(window.__nuistCoursePrepareResult) : ""',
        (error, result) => {
          if (error) {
            this.finishPrepareWithFailure('读取理实一体切换结果失败，请重试。', 'readPrepareResult error: ' + error.message);
            return;
          }
          const normalized: string = NuistCourseImportService.normalizeRunJavaScriptResult(result);
          console.info('[CourseImport] pollPrepareResult retry=' + retryCount.toString() + ', resultLength=' +
            normalized.length.toString());
          if (normalized.length === 0) {
            if (retryCount >= 12) {
              this.finishPrepareWithFailure('切换理实一体课表超时，请重试。', 'prepare timeout');
              return;
            }
            this.pollPrepareResult(retryCount + 1);
            return;
          }
          this.handlePrepareResult(normalized);
        });
    } catch (error) {
      this.finishPrepareWithFailure('读取理实一体切换结果失败，请重试。', 'pollPrepareResult failed: ' + JSON.stringify(error));
    }
  }

  private handlePrepareResult(rawResult: string): void {
    try {
      const normalized: string = NuistCourseImportService.normalizeRunJavaScriptResult(rawResult);
      const prepareResult: PrepareResult = JSON.parse(normalized) as PrepareResult;
      console.info('[CourseImport] prepareResult status=' + prepareResult.status + ', selectedLabel=' +
        prepareResult.selectedLabel + ', log=' + prepareResult.log);
      if (prepareResult.status !== 'ready' || prepareResult.selectedLabel !== '理实一体') {
        this.finishPrepareWithFailure('自动切换到理实一体课表失败，请重试。', prepareResult.log);
        return;
      }
      this.isPreparing = false;
      this.statusText = '已切换到理实一体课表，正在导入本学期课程...';
      this.beginImportTask();
    } catch (error) {
      this.finishPrepareWithFailure('解析理实一体切换结果失败，请重试。', 'handlePrepareResult failed: ' + JSON.stringify(error));
    }
  }

  private finishPrepareWithFailure(message: string, logText: string): void {
    this.clearPreparePollTimer();
    this.isPreparing = false;
    this.statusText = message;
    this.lastResultText = message;
    console.error('[CourseImport] ' + logText);
  }

  private beginImportTask(): void {
    this.clearImportPollTimer();
    this.isImporting = true;
    this.statusText = '正在获取理实一体课表数据...';
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
              this.readImportLogsAndFail('课表获取超时，请检查是否已成功进入理实一体课表。');
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
        ', apiRowJsonList=' + snapshot.apiRowJsonList.length.toString() + ', detectedCurrentWeek=' +
        snapshot.detectedCurrentWeek.toString() + ', apiLogLength=' + snapshot.apiLogText.length.toString());
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
      .then(async () => {
        AppStorage.setOrCreate('isExportCourseSchedule', true);
        // [课程卡片] 课表重新导入成功后，立刻同步刷新桌面“今日课程”卡片，无需用户手动点刷新。
        await TodayCourseWidgetHelper.refreshAllForms(getContext(this));
        this.isImporting = false;
        this.lastResultText = '已导入 ' + parseResult.courses.length.toString() + ' 条课程记录';
        this.statusText = parseResult.message;
        console.info('[CourseImport] save success, courseCount=' + parseResult.courses.length.toString() +
          ', termLabel=' + parseResult.termLabel + ', termStartDate=' + parseResult.termStartDate);
        promptAction.showToast({ message: '本学期课表导入成功' });
        this.clearImportResultInPage();
        this.backAfterImportSuccess();
      })
      .catch((error: Error) => {
        this.finishImportWithFailure('写入本地课程库失败，请重试。', 'save store failed: ' + error.message);
        promptAction.showToast({ message: '课表保存失败' });
      });
  }

  private backAfterImportSuccess(): void {
    setTimeout(() => {
      this.getUIContext().getRouter().back();
    }, 200);
  }

  private finishImportWithFailure(message: string, logText: string): void {
    this.clearImportPollTimer();
    this.isImporting = false;
    this.statusText = message;
    this.lastResultText = message;
    console.error('[CourseImport] ' + logText);
  }

  private clearPreparePollTimer(): void {
    if (this.preparePollTimerId >= 0) {
      clearTimeout(this.preparePollTimerId);
      this.preparePollTimerId = -1;
    }
  }

  private clearImportPollTimer(): void {
    if (this.importPollTimerId >= 0) {
      clearTimeout(this.importPollTimerId);
      this.importPollTimerId = -1;
    }
  }

  private clearImportResultInPage(): void {
    try {
      this.controller.runJavaScript('window.__nuistCourseImportResult = ""; window.__nuistCourseImportLogs = ""; window.__nuistCoursePrepareResult = ""; "CLEARED"',
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
    if (!NuistCourseImportService.isCoursePageUrl(url)) {
      return;
    }
    if (this.hasAutoPrepareStarted || this.isPreparing || this.isImporting) {
      return;
    }
    this.hasAutoPrepareStarted = true;
    console.info('[CourseImport] 课表页已就绪，开始自动切换理实一体并导入');
    this.startPrepareAndImport();
  }

  private buildImportTaskScript(): string {
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
      '      return String(value).replace(/ /g, " ").trim();',
      '    }',
      '    function readField(row, names){',
      '      for (var i = 0; i < names.length; i++) {',
      '        var name = names[i];',
      '        if (row && Object.prototype.hasOwnProperty.call(row, name) && row[name] !== null && row[name] !== undefined) {',
      '          return row[name];',
      '        }',
      '      }',
      '      return "";',
      '    }',
      '    function readNumber(row, names){',
      '      var raw = readField(row, names);',
      '      var text = trimText(raw);',
      '      if (!text) {',
      '        return 0;',
      '      }',
      '      var num = Number(text);',
      '      if (isNaN(num)) {',
      '        return 0;',
      '      }',
      '      return num;',
      '    }',
      '    function detectWeekFromText(rawText){',
      '      var text = trimText(rawText);',
      '      if (!text) {',
      '        return 0;',
      '      }',
      '      var directMatch = text.match(/第\s*([0-9]{1,2})\s*周/);',
      '      if (directMatch && directMatch.length >= 2) {',
      '        return { week: Number(directMatch[1]), source: "text" };',
      '      }',
      '      var namedMatch = text.match(/(?:当前周|本周|当前教学周)[^0-9]{0,4}([0-9]{1,2})/);',
      '      if (namedMatch && namedMatch.length >= 2) {',
      '        return { week: Number(namedMatch[1]), source: "text" };',
      '      }',
      '      var zeroBasedMatch = text.match(/"(?:DQZC|dqzc|currentWeek|CURRENT_WEEK|weekNo|currWeek|DQJXZC|dqjxzc)"\s*:\s*"?([0-9]{1,2})"?/);',
      '      if (zeroBasedMatch && zeroBasedMatch.length >= 2) {',
      '        var zeroWeek = Number(zeroBasedMatch[1]);',
      '        if (!isNaN(zeroWeek)) {',
      '          return { week: zeroWeek + 1, source: "zeroBasedKey" };',
      '        }',
      '      }',
      '      return { week: 0, source: "" };',
      '    }',
      '    function detectCurrentWeek(){',
      '      var pageTextInfo = detectWeekFromText(document.body ? String(document.body.innerText || "") : "");',
      '      if (pageTextInfo.week > 0) {',
      '        return { week: pageTextInfo.week, source: "pageText:" + pageTextInfo.source };',
      '      }',
      '      var htmlWeekInfo = detectWeekFromText(document.body ? String(document.body.innerHTML || "") : "");',
      '      if (htmlWeekInfo.week > 0) {',
      '        return { week: htmlWeekInfo.week, source: "pageHtml:" + htmlWeekInfo.source };',
      '      }',
      '      var payloadList = Array.isArray(window.__nuistCourseCapturedPayloadTexts) ? window.__nuistCourseCapturedPayloadTexts : [];',
      '      for (var payloadIndex = 0; payloadIndex < payloadList.length; payloadIndex++) {',
      '        var payloadItem = payloadList[payloadIndex];',
      '        if (!payloadItem) {',
      '          continue;',
      '        }',
      '        var payloadWeekInfo = detectWeekFromText(payloadItem.text);',
      '        if (payloadWeekInfo.week > 0) {',
      '          return { week: payloadWeekInfo.week, source: "payload:" + String(payloadItem.url || "") + ":" + payloadWeekInfo.source };',
      '        }',
      '      }',
      '      return { week: 0, source: "" };',
      '    }',
      '    function canonicalizeRows(rows){',
      '      var result = [];',
      '      for (var index = 0; index < rows.length; index++) {',
      '        var row = rows[index];',
      '        if (!row || typeof row !== "object") {',
      '          continue;',
      '        }',
      '        var courseName = trimText(readField(row, ["KCM", "KCMC", "KCMC", "COURSE_NAME", "courseName", "KCMC_DISPLAY", "KCDM_DISPLAY"]));',
      '        var teacherName = trimText(readField(row, ["SKJS", "JSXM", "TEACHER_NAME", "teacherName", "SKJS_DISPLAY"]));',
      '        var classroom = trimText(readField(row, ["JASMC", "CDMC", "CLASSROOM", "classroom", "JASMC_DISPLAY", "CDMC_DISPLAY", "JXLDM_DISPLAY"]));',
      '        var meetingText = trimText(readField(row, ["YPSJDD", "PKSJ", "SJDD", "SKSJ", "SKSJMS", "SJDDMS", "meetingText"]));',
      '        var rawWeekText = trimText(readField(row, ["ZCMC", "SKSJ", "YPSJDD", "WEEK_TEXT", "weekText"]));',
      '        var weekBits = trimText(readField(row, ["SKZC", "WEEK_BITS", "weekBits"]));',
      '        var dayOfWeek = readNumber(row, ["SKXQ", "XQJ", "DAY_OF_WEEK", "dayOfWeek"]);',
      '        var startSection = readNumber(row, ["KSJC", "QSJC", "START_SECTION", "startSection"]);',
      '        var endSection = readNumber(row, ["JSJC", "ZSJC", "END_SECTION", "endSection"]);',
      '        if (!endSection) {',
      '          endSection = startSection;',
      '        }',
      '        result.push({',
      '          __COURSE_NAME: courseName,',
      '          __TEACHER_NAME: teacherName,',
      '          __CLASSROOM: classroom,',
      '          __MEETING_TEXT: meetingText,',
      '          __RAW_WEEK_TEXT: rawWeekText,',
      '          __WEEK_BITS: weekBits,',
      '          __DAY_OF_WEEK: dayOfWeek,',
      '          __START_SECTION: startSection,',
      '          __END_SECTION: endSection',
      '        });',
      '      }',
      '      return result;',
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
      '      var capturedRows = Array.isArray(window.__nuistCourseCapturedRows) ? window.__nuistCourseCapturedRows : [];',
      '      var capturedSource = String(window.__nuistCourseCapturedSource || "");',
      '      pushLog("capturedSource=" + capturedSource + ", capturedRows=" + capturedRows.length);',
      '      if (!capturedRows || capturedRows.length === 0) {',
      '        throw new Error("理实一体课表数据未捕获到");',
      '      }',
      '      var rows = canonicalizeRows(capturedRows);',
      '      pushLog("canonicalRows=" + rows.length);',
      '      var currentWeekInfo = detectCurrentWeek();',
      '      pushLog("detectedCurrentWeek=" + currentWeekInfo.week + ", source=" + currentWeekInfo.source);',
      '      if (rows.length > 0) {',
      '        try {',
      '          pushLog("canonicalFirstKeys=" + Object.keys(rows[0]).join(","));',
      '        } catch (error) {}',
      '      }',
      '      window.__nuistCourseImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: document.body ? String(document.body.innerHTML || "") : "",',
      '        tableCells: [],',
      '        pageBlocks: [],',
      '        apiTermCode: termCode,',
      '        apiTermLabel: termLabel,',
      '        semesterStartDate: semesterStartDate,',
      '        detectedCurrentWeek: currentWeekInfo.week,',
      '        detectedCurrentWeekSource: currentWeekInfo.source,',
      '        currentDateIso: new Date().toISOString(),',
      '        apiRowJsonList: rows,',
      '        apiLogText: logs.join(" | ")',
      '      });',
      '    } catch (error) {',
      '      pushLog("import task failed=" + String(error));',
      '      window.__nuistCourseImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: document.body ? String(document.body.innerHTML || "") : "",',
      '        tableCells: [],',
      '        pageBlocks: [],',
      '        apiTermCode: "",',
      '        apiTermLabel: "",',
      '        semesterStartDate: "",',
      '        detectedCurrentWeek: 0,',
      '        detectedCurrentWeekSource: "",',
      '        currentDateIso: new Date().toISOString(),',
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
          this.clearPreparePollTimer();
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

      Web({ src: this.initialWebSrc, controller: this.controller })
        .width(BasicConstant.FULL_WIDTH)
        .layoutWeight(1)
        // [课程导入] 显式设置白色背景，避免部分设备在深色模式/重组时出现黑底。
        .backgroundColor(Color.White)
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

        Button(this.isPreparing || this.isImporting ? '正在导入...' : '导入本学期课表')
          .layoutWeight(1)
          .backgroundColor(this.themeColor)
          .fontColor(Color.White)
          .enabled(!this.isPreparing && !this.isImporting)
          .onClick(() => {
            this.startPrepareAndImport();
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
