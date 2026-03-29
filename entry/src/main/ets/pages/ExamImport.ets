import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { BasicConstant } from '../Constants/BasicConstant';
import { BreakpointConstant } from '../Constants/BreakpointConstant';
import { ButtonModifier } from './Model/AttributeModifier';
import { examStore } from './Model/ExamStore';
import { ExamPageSnapshot, ExamParseResult, NuistExamImportService } from './Service/NuistExamImportService';

interface OpenResult {
  status: string;
  log: string;
  targetUrl: string;
}

@Entry
@Component
struct ExamImport {
  // [考试导入] 登录后自动进入“我的考试安排”，抓取当前学期考试安排并在成功后自动返回。
  private controller: webview.WebviewController = new webview.WebviewController();
  private openPollTimerId: number = -1;
  private importPollTimerId: number = -1;
  private inspectPollTimerId: number = -1;
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('themeColor') themeColor: string = '#EA5C2E';
  private readonly initialWebSrc: string = NuistExamImportService.LOGIN_URL;
  @State currentUrl: string = NuistExamImportService.LOGIN_URL;
  @State statusText: string = '请登录南信大统一认证。登录成功后会自动进入“我的考试安排”并导入。';
  @State isOpening: boolean = false;
  @State isImporting: boolean = false;
  @State lastResultText: string = '';
  @State hasAutoOpenStarted: boolean = false;
  @State hasAutoImportStarted: boolean = false;

  private clearOpenPollTimer(): void {
    if (this.openPollTimerId >= 0) {
      clearTimeout(this.openPollTimerId);
      this.openPollTimerId = -1;
    }
  }

  private clearImportPollTimer(): void {
    if (this.importPollTimerId >= 0) {
      clearTimeout(this.importPollTimerId);
      this.importPollTimerId = -1;
    }
  }

  private clearInspectPollTimer(): void {
    if (this.inspectPollTimerId >= 0) {
      clearTimeout(this.inspectPollTimerId);
      this.inspectPollTimerId = -1;
    }
  }

  private openPortal(): void {
    try {
      this.hasAutoOpenStarted = false;
      this.hasAutoImportStarted = false;
      this.clearOpenPollTimer();
      this.clearImportPollTimer();
      this.clearInspectPollTimer();
      this.controller.loadUrl(NuistExamImportService.LOGIN_URL);
      this.statusText = '请登录南信大统一认证。登录成功后会自动进入“我的考试安排”并导入。';
      console.info('[ExamImport] 已重新打开南信大统一认证入口');
    } catch (error) {
      console.error('[ExamImport] openPortal failed: ' + JSON.stringify(error));
      this.statusText = '重新打开教务入口失败，请稍后重试。';
    }
  }

  private tryAutoOpenExamPage(url: string): void {
    if (this.hasAutoOpenStarted || this.isOpening || !NuistExamImportService.canTryOpenExamEntry(url)) {
      return;
    }
    if (NuistExamImportService.isExamPageUrl(url)) {
      return;
    }
    this.hasAutoOpenStarted = true;
    this.isOpening = true;
    this.statusText = '正在进入“我的考试安排”...';
    try {
      this.controller.runJavaScript(this.buildOpenExamModuleScript(), (error, result) => {
        if (error) {
          this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'run open script error: ' + error.message);
          return;
        }
        console.info('[ExamImport] startOpenExamModule result=' + result);
        this.pollOpenResult(0);
      });
    } catch (error) {
      this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'start open exam module failed: ' + JSON.stringify(error));
    }
  }

  private buildOpenExamModuleScript(): string {
    return [
      '(function(){',
      '  window.__nuistExamOpenResult = "";',
      '  (function(){',
      '    var logs = [];',
      '    function pushLog(text){ logs.push(String(text)); }',
      '    function textOf(node){ return String(node.innerText || node.textContent || "").replace(/\s+/g, " ").trim(); }',
      '    function findTarget(){',
      '      var nodes = Array.prototype.slice.call(document.querySelectorAll("*"));',
      '      for (var index = 0; index < nodes.length; index++) {',
      '        var text = textOf(nodes[index]);',
      '        if (text === "我的考试安排" || text === "考试安排" || text.indexOf("考试安排") >= 0) {',
      '          return nodes[index];',
      '        }',
      '      }',
      '      return null;',
      '    }',
      '    function clickTarget(node){',
      '      if (!node) { return false; }',
      '      try { node.click(); } catch (error) {}',
      '      try { node.dispatchEvent(new MouseEvent("click", { bubbles: true, cancelable: true, view: window })); } catch (error) {}',
      '      return true;',
      '    }',
      '    var retry = 0;',
      '    var timer = window.setInterval(function(){',
      '      retry += 1;',
      '      var target = findTarget();',
      '      if (target) {',
      '        var href = String(target.getAttribute && target.getAttribute("href") || "");',
      '        pushLog("target found text=" + textOf(target));',
      '        clickTarget(target);',
      '        window.clearInterval(timer);',
      '        window.__nuistExamOpenResult = JSON.stringify({ status: "ready", log: logs.join(" | "), targetUrl: href });',
      '        return;',
      '      }',
      '      pushLog("retry=" + retry + ", target not found");',
      '      if (retry >= 12) {',
      '        window.clearInterval(timer);',
      '        window.__nuistExamOpenResult = JSON.stringify({ status: "failed", log: logs.join(" | "), targetUrl: "" });',
      '      }',
      '    }, 400);',
      '  })();',
      '  return "STARTED";',
      '})()'
    ].join('');
  }

  private pollOpenResult(retry: number): void {
    this.clearOpenPollTimer();
    try {
      this.controller.runJavaScript('window.__nuistExamOpenResult || ""', (error, result) => {
        if (error) {
          this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'pollOpenResult error: ' + error.message);
          return;
        }
        const normalized: string = NuistExamImportService.normalizeRunJavaScriptResult(result);
        console.info('[ExamImport] pollOpenResult retry=' + retry.toString() + ', resultLength=' + normalized.length.toString());
        if (normalized.length === 0) {
          if (retry >= 14) {
            this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'pollOpenResult empty timeout');
            return;
          }
          this.openPollTimerId = setTimeout(() => this.pollOpenResult(retry + 1), 500) as number;
          return;
        }
        let openResult: OpenResult;
        try {
          openResult = JSON.parse(normalized) as OpenResult;
        } catch (parseError) {
          this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'parse open result failed: ' + JSON.stringify(parseError));
          return;
        }
        console.info('[ExamImport] openResult status=' + openResult.status + ', log=' + openResult.log);
        this.isOpening = false;
        if (openResult.status !== 'ready') {
          this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', openResult.log);
          return;
        }
        this.statusText = '已打开我的考试安排，正在读取本学期考试数据...';
        this.waitExamPageAndImport(0);
      });
    } catch (error) {
      this.finishOpenWithFailure('自动进入我的考试安排失败，请重试。', 'pollOpenResult failed: ' + JSON.stringify(error));
    }
  }

  private finishOpenWithFailure(message: string, logs: string): void {
    this.isOpening = false;
    this.statusText = message;
    console.error('[ExamImport] ' + logs);
  }


  private waitExamPageAndImport(retry: number): void {
    this.clearInspectPollTimer();
    if (this.hasAutoImportStarted || this.isImporting) {
      return;
    }
    try {
      this.controller.runJavaScript(this.buildInspectExamPageScript(), (error, result) => {
        if (error) {
          console.error('[ExamImport] waitExamPageAndImport error: ' + error.message);
          return;
        }
        const normalized: string = NuistExamImportService.normalizeRunJavaScriptResult(result);
        console.info('[ExamImport] waitExamPageAndImport retry=' + retry.toString() + ', result=' + normalized);
        if (normalized === '1') {
          this.hasAutoImportStarted = true;
          this.startImportTask();
          return;
        }
        if (retry >= 12) {
          return;
        }
        this.inspectPollTimerId = setTimeout(() => this.waitExamPageAndImport(retry + 1), 500) as number;
      });
    } catch (error) {
      console.error('[ExamImport] waitExamPageAndImport failed: ' + JSON.stringify(error));
    }
  }

  private tryAutoImportWhenExamPage(url: string): void {
    if (this.hasAutoImportStarted || this.isImporting) {
      return;
    }
    if (url.indexOf('/authserver/login') >= 0) {
      return;
    }
    if (url.indexOf('/emaphome/portal/') >= 0) {
      return;
    }
    if (url.indexOf('jwxt.nuist.edu.cn') < 0) {
      return;
    }
    try {
      this.controller.runJavaScript(this.buildInspectExamPageScript(), (error, result) => {
        if (error) {
          console.error('[ExamImport] inspect exam page failed: ' + error.message);
          return;
        }
        const normalized: string = NuistExamImportService.normalizeRunJavaScriptResult(result);
        if (normalized !== '1') {
          return;
        }
        this.hasAutoImportStarted = true;
        this.startImportTask();
      });
    } catch (error) {
      console.error('[ExamImport] tryAutoImportWhenExamPage failed: ' + JSON.stringify(error));
    }
  }

  private buildInspectExamPageScript(): string {
    return [
      '(function(){',
      '  var title = String(document.title || "");',
      '  var text = document.body ? String(document.body.innerText || "") : "";',
      '  if (title.indexOf("考试安排") >= 0 || text.indexOf("考试安排") >= 0 || text.indexOf("我的考试安排") >= 0) {',
      '    return "1";',
      '  }',
      '  return "0";',
      '})()'
    ].join('');
  }

  private startImportTask(): void {
    if (this.isImporting) {
      return;
    }
    this.isImporting = true;
    this.statusText = '正在导入本学期考试安排...';
    this.clearImportPollTimer();
    try {
      this.controller.runJavaScript(this.buildImportScript(), (error, result) => {
        if (error) {
          this.finishImportWithFailure('导入考试安排失败，请重试。', 'run import script error: ' + error.message);
          return;
        }
        console.info('[ExamImport] beginImportTask script result=' + result);
        this.pollImportResult(0);
      });
    } catch (error) {
      this.finishImportWithFailure('导入考试安排失败，请重试。', 'startImportTask failed: ' + JSON.stringify(error));
    }
  }

  private buildImportScript(): string {
    return [
      '(function(){',
      '  window.__nuistExamImportResult = "";',
      '  (async function(){',
      '    var logs = [];',
      '    function pushLog(text){ logs.push(String(text)); }',
      '    function wait(ms){ return new Promise(function(resolve){ setTimeout(resolve, ms); }); }',
      '    function safeParse(text){ try { return JSON.parse(text); } catch (error) { pushLog("safeParseFailed=" + String(error)); return null; } }',
      '    function pickRows(payload){',
      '      if (!payload || !payload.datas) { return []; }',
      '      var dataKeys = Object.keys(payload.datas);',
      '      for (var keyIndex = 0; keyIndex < dataKeys.length; keyIndex++) {',
      '        var block = payload.datas[dataKeys[keyIndex]];',
      '        if (block && Array.isArray(block.rows)) { return block.rows; }',
      '      }',
      '      return [];',
      '    }',
      '    function rowSample(rows){',
      '      if (!rows || rows.length === 0) { return ""; }',
      '      try { return JSON.stringify(rows[0]); } catch (error) { return ""; }',
      '    }',
      '    function isConfigUrl(url){',
      '      var lower = String(url || "").toLowerCase();',
      '      return lower.indexOf("cxxtcs.do") >= 0 || lower.indexOf("xtcs") >= 0;',
      '    }',
      '    function scoreRows(url, rows, payloadText){',
      '      if (!rows || rows.length === 0) { return -100; }',
      '      if (isConfigUrl(url)) { return -100; }',
      '      var sample = rowSample(rows);',
      '      var merged = sample + " " + String(payloadText || "") + " " + String(url || "");',
      '      var score = rows.length;',
      '      if (merged.indexOf("考试") >= 0) { score += 30; }',
      '      if (merged.indexOf("KSRQ") >= 0 || merged.indexOf("KSSJ") >= 0 || merged.indexOf("JSSJ") >= 0) { score += 40; }',
      '      if (merged.indexOf("KCM") >= 0 || merged.indexOf("KCMC") >= 0 || merged.indexOf("课程") >= 0) { score += 30; }',
      '      if (String(url || "").toLowerCase().indexOf("wdksap") >= 0) { score += 20; }',
      '      if (merged.indexOf("CSSM") >= 0 && merged.indexOf("CSZA") >= 0) { score -= 60; }',
      '      return score;',
      '    }',
      '    function captureRows(url, rows, payloadText){',
      '      var score = scoreRows(url, rows, payloadText);',
      '      if (score < 0) { return; }',
      '      var payloadList = Array.isArray(window.__nuistExamCapturedPayloads) ? window.__nuistExamCapturedPayloads : [];',
      '      payloadList.push({ url: String(url || ""), score: score, rows: rows });',
      '      window.__nuistExamCapturedPayloads = payloadList;',
      '      pushLog("captured rows=" + rows.length + ", score=" + score + ", url=" + String(url || ""));',
      '    }',
      '    function bestCapturedRows(){',
      '      var payloadList = Array.isArray(window.__nuistExamCapturedPayloads) ? window.__nuistExamCapturedPayloads : [];',
      '      var best = null;',
      '      for (var index = 0; index < payloadList.length; index++) {',
      '        var item = payloadList[index];',
      '        if (!item || !Array.isArray(item.rows) || item.rows.length === 0) { continue; }',
      '        if (best === null || Number(item.score || 0) > Number(best.score || 0)) { best = item; }',
      '      }',
      '      return best;',
      '    }',
      '    function installHook(){',
      '      if (window.__nuistExamHookInstalled) { return; }',
      '      window.__nuistExamHookInstalled = true;',
      '      window.__nuistExamCapturedPayloads = window.__nuistExamCapturedPayloads || [];',
      '      var originalFetch = window.fetch;',
      '      if (typeof originalFetch === "function") {',
      '        window.fetch = function(){',
      '          var requestUrl = arguments.length > 0 ? String(arguments[0]) : "";',
      '          return originalFetch.apply(this, arguments).then(function(response){',
      '            try {',
      '              response.clone().text().then(function(text){',
      '                var payload = safeParse(text);',
      '                var rows = pickRows(payload);',
      '                captureRows(requestUrl, rows, text);',
      '              });',
      '            } catch (error) { pushLog("fetchHookFailed=" + String(error)); }',
      '            return response;',
      '          });',
      '        };',
      '      }',
      '      var originalOpen = XMLHttpRequest.prototype.open;',
      '      var originalSend = XMLHttpRequest.prototype.send;',
      '      XMLHttpRequest.prototype.open = function(method, url){ this.__nuistExamRequestUrl = String(url || ""); return originalOpen.apply(this, arguments); };',
      '      XMLHttpRequest.prototype.send = function(){',
      '        this.addEventListener("load", function(){',
      '          try {',
      '            var requestUrl = String(this.__nuistExamRequestUrl || "");',
      '            var payload = safeParse(String(this.responseText || ""));',
      '            var rows = pickRows(payload);',
      '            captureRows(requestUrl, rows, String(this.responseText || ""));',
      '          } catch (error) { pushLog("xhrHookFailed=" + String(error)); }',
      '        });',
      '        return originalSend.apply(this, arguments);',
      '      };',
      '      pushLog("hook installed");',
      '    }',
      '    function textOf(node){ return String(node.innerText || node.textContent || "").replace(/\s+/g, " ").trim(); }',
      '    function collectDomRows(){',
      '      var rows = [];',
      '      var selectors = ["table tr", ".el-table__row", ".vxe-body--row", ".datagrid-row", ".ant-table-row", ".ivu-table-row"];',
      '      for (var s = 0; s < selectors.length; s++) {',
      '        var nodes = Array.prototype.slice.call(document.querySelectorAll(selectors[s]));',
      '        for (var i = 0; i < nodes.length; i++) {',
      '          var cellNodes = Array.prototype.slice.call(nodes[i].querySelectorAll("th,td,.cell,span,div"));',
      '          var cells = [];',
      '          for (var j = 0; j < cellNodes.length; j++) {',
      '            var cellText = textOf(cellNodes[j]);',
      '            if (cellText.length > 0 && cells.indexOf(cellText) < 0) { cells.push(cellText); }',
      '          }',
      '          var rowText = textOf(nodes[i]);',
      '          if ((cells.length >= 2 || rowText.indexOf("考试") >= 0) && rowText.length > 0) {',
      '            rows.push({ text: rowText, cells: cells });',
      '          }',
      '        }',
      '      }',
      '      return rows.slice(0, 200);',
      '    }',
      '    function detectTermLabel(){',
      '      var bodyText = document.body ? String(document.body.innerText || "") : "";',
      '      var match = bodyText.match(/\d{4}-\d{4}-\d学期/);',
      '      return match ? match[0] : "";',
      '    }',
      '    try {',
      '      installHook();',
      '      var domRows = [];',
      '      for (var retry = 0; retry < 8; retry++) {',
      '        domRows = collectDomRows();',
      '        var bestPayload = bestCapturedRows();',
      '        var capturedCount = bestPayload && Array.isArray(bestPayload.rows) ? bestPayload.rows.length : 0;',
      '        pushLog("retry=" + retry + ", domRows=" + domRows.length + ", capturedRows=" + capturedCount);',
      '        if (domRows.length > 0 || capturedCount > 0) {',
      '          break;',
      '        }',
      '        await wait(450);',
      '      }',
      '      window.__nuistExamImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: document.body ? String(document.body.innerHTML || "") : "",',
      '        termLabel: detectTermLabel(),',
      '        apiRowJsonList: (function(){ var bestPayload = bestCapturedRows(); if (!bestPayload || !Array.isArray(bestPayload.rows)) { return []; } var result = []; for (var rowIndex = 0; rowIndex < bestPayload.rows.length; rowIndex++) { try { result.push(JSON.stringify(bestPayload.rows[rowIndex])); } catch (error) {} } return result; })(),',
      '        domRows: domRows,',
      '        apiLogText: logs.join(" | ")',
      '      });',
      '    } catch (error) {',
      '      pushLog("importTaskFailed=" + String(error));',
      '      window.__nuistExamImportResult = JSON.stringify({',
      '        url: location.href,',
      '        title: document.title || "",',
      '        text: document.body ? String(document.body.innerText || "") : "",',
      '        html: document.body ? String(document.body.innerHTML || "") : "",',
      '        termLabel: "",',
      '        apiRowJsonList: [],',
      '        domRows: [],',
      '        apiLogText: logs.join(" | ")',
      '      });',
      '    }',
      '  })();',
      '  return "STARTED";',
      '})()'
    ].join('');
  }

  private pollImportResult(retry: number): void {
    this.clearImportPollTimer();
    try {
      this.controller.runJavaScript('window.__nuistExamImportResult || ""', (error, result) => {
        if (error) {
          this.finishImportWithFailure('导入考试安排失败，请重试。', 'pollImportResult error: ' + error.message);
          return;
        }
        const normalized: string = NuistExamImportService.normalizeRunJavaScriptResult(result);
        console.info('[ExamImport] pollImportResult retry=' + retry.toString() + ', resultLength=' + normalized.length.toString());
        if (normalized.length === 0) {
          if (retry >= 14) {
            this.finishImportWithFailure('导入考试安排失败，请重试。', 'pollImportResult empty timeout');
            return;
          }
          this.importPollTimerId = setTimeout(() => this.pollImportResult(retry + 1), 500) as number;
          return;
        }
        let snapshot: ExamPageSnapshot;
        try {
          snapshot = NuistExamImportService.parseExamPageSnapshot(normalized);
        } catch (parseError) {
          this.finishImportWithFailure('导入考试安排失败，请重试。', 'parse snapshot failed: ' + JSON.stringify(parseError));
          return;
        }
        console.info('[ExamImport] snapshot url=' + snapshot.url + ', termLabel=' + snapshot.termLabel +
          ', apiRowJsonList=' + snapshot.apiRowJsonList.length.toString() + ', domRows=' + snapshot.domRows.length.toString() +
          ', apiLogLength=' + snapshot.apiLogText.length.toString());
        const parseResult: ExamParseResult = NuistExamImportService.parseSnapshot(snapshot);
        if (parseResult.exams.length === 0) {
          this.finishImportWithFailure(parseResult.message, 'import logs=' + snapshot.apiLogText);
          promptAction.showToast({ message: parseResult.message });
          return;
        }
        this.persistParseResult(parseResult, snapshot.url);
      });
    } catch (error) {
      this.finishImportWithFailure('导入考试安排失败，请重试。', 'pollImportResult failed: ' + JSON.stringify(error));
    }
  }

  private persistParseResult(parseResult: ExamParseResult, sourcePageUrl: string): void {
    (async () => {
      try {
        await examStore.replaceAllAndFlush(parseResult.exams, parseResult.termLabel, sourcePageUrl);
        AppStorage.setOrCreate('isExportExamSchedule', examStore.hasImportedExam());
        this.lastResultText = '已导入 ' + parseResult.exams.length.toString() + ' 条考试记录';
        this.statusText = parseResult.message;
        this.isImporting = false;
        promptAction.showToast({ message: parseResult.message });
        this.backAfterImportSuccess();
      } catch (error) {
        this.finishImportWithFailure('写入本地考试库失败，请重试。', 'save exam store failed: ' + (error as Error).message);
      }
    })();
  }

  private backAfterImportSuccess(): void {
    setTimeout(() => {
      this.getUIContext().getRouter().back();
    }, 250);
  }

  private finishImportWithFailure(message: string, logs: string): void {
    this.isImporting = false;
    this.statusText = message;
    console.error('[ExamImport] ' + logs);
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
          this.clearOpenPollTimer();
          this.clearImportPollTimer();
      this.clearInspectPollTimer();
          this.getUIContext().getRouter().back();
        })

        Column({ space: 4 }) {
          Text('导入南信大考试安排')
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
        .backgroundColor(Color.White)
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .onPageEnd((event) => {
          if (event && event.url) {
            this.currentUrl = event.url;
            console.info('[ExamImport] onPageEnd url=' + event.url);
            this.tryAutoOpenExamPage(event.url);
            this.tryAutoImportWhenExamPage(event.url);
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

        Button(this.isImporting ? '正在导入...' : '导入本学期考试安排')
          .layoutWeight(1)
          .backgroundColor(this.themeColor)
          .fontColor(Color.White)
          .enabled(!this.isImporting)
          .onClick(() => {
            if (!NuistExamImportService.isExamPageUrl(this.currentUrl)) {
              this.tryAutoOpenExamPage(this.currentUrl);
              this.waitExamPageAndImport(0);
            } else {
              this.startImportTask();
            }
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
