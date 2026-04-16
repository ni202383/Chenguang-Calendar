import { http, webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { AgentGatewayConfig } from './AgentGatewayConfig';
import { AgentJsonHelper } from './AgentJsonHelper';
import { AgentLogger } from './AgentLogger';
import { AgentTimeHelper } from './AgentTimeHelper';
import {
  AgentChatMessage,
  AgentChatRequest,
  AgentHistoryMessage,
  AgentMessageStatus,
  AgentPlanRequest,
  AgentPlanResult,
  AgentSocketFrame,
  AgentSender
} from '../Model/AgentModels';

export class AgentStreamListener {
  onReady: () => void = () => {};
  onThinking: (message: string) => void = (_message: string) => {};
  onChunk: (text: string) => void = (_text: string) => {};
  onDone: () => void = () => {};
  onError: (message: string) => void = (_message: string) => {};
}

export class AgentGatewayService {
  private static readonly SCOPE: string = 'AgentGatewayService';
  private static readonly LOG_PLAN: string = 'GW.PLAN';
  private static readonly LOG_STREAM: string = 'GW.STREAM';
  private static readonly HTTP_TIMEOUT_MS: number = 600000;
  private static readonly SOCKET_IDLE_TIMEOUT_MS: number = 600000;

  public static async plan(message: string, sessionId: string, history: Array<AgentChatMessage>): Promise<AgentPlanResult> {
    const request = http.createHttp();
    const planRequest: AgentPlanRequest = new AgentPlanRequest();
    planRequest.userMessage = message;
    planRequest.sessionId = sessionId;
    planRequest.timezone = AgentGatewayConfig.TIME_ZONE;
    planRequest.nowIso = AgentTimeHelper.formatIsoOffset(new Date());
    planRequest.recentMessages = AgentGatewayService.buildHistory(history);
    AgentLogger.info(AgentGatewayService.LOG_PLAN,
      'plan request start session=' + sessionId + ' userLen=' + message.length.toString() +
      ' history=' + planRequest.recentMessages.length.toString());
    try {
      const response = await request.request(AgentGatewayConfig.BASE_HTTP_URL + AgentGatewayConfig.PLAN_PATH, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json',
          'Authorization': AgentGatewayConfig.AUTHORIZATION
        },
        readTimeout: AgentGatewayService.HTTP_TIMEOUT_MS,
        connectTimeout: AgentGatewayService.HTTP_TIMEOUT_MS,
        extraData: AgentJsonHelper.stringifyPlanRequest(planRequest),
        expectDataType: http.HttpDataType.STRING
      });
      const rawText: string = String(response.result);
      if (Number(response.responseCode) !== 200) {
        throw new Error('plan request failed: ' + Number(response.responseCode).toString() + ' ' + rawText);
      }
      const preview: string = rawText.length > 800 ? rawText.substring(0, 800) : rawText;
      AgentLogger.info(AgentGatewayService.LOG_PLAN,
        'plan request done code=' + Number(response.responseCode).toString() + ' textLen=' + rawText.length.toString() +
        ' preview=' + preview);
      return AgentJsonHelper.parsePlanResult(rawText);
    } finally {
      request.destroy();
    }
  }

  public static async chatStream(message: string, sessionId: string, history: Array<AgentChatMessage>,
    intentJson: string, localReferenceJson: string, actionSummaryText: string,
    listener: AgentStreamListener): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const socket: webSocket.WebSocket = webSocket.createWebSocket();
      const chatRequest: AgentChatRequest = new AgentChatRequest();
      chatRequest.userMessage = message;
      chatRequest.sessionId = sessionId;
      chatRequest.timezone = AgentGatewayConfig.TIME_ZONE;
      chatRequest.nowIso = AgentTimeHelper.formatIsoOffset(new Date());
      chatRequest.recentMessages = AgentGatewayService.buildHistory(history);
      chatRequest.intentJson = intentJson;
      chatRequest.localReferenceJson = localReferenceJson;
      chatRequest.actionSummaryText = actionSummaryText;
      const payloadText: string = AgentJsonHelper.stringifyChatRequest(chatRequest);
      const wsUrl: string = AgentGatewayConfig.CHAT_WS_URL + '?token=' + encodeURIComponent(AgentGatewayConfig.TOKEN);
      let settled: boolean = false;
      let doneReceived: boolean = false;
      let timeoutId: number | undefined = undefined;

      const clearTimer = (): void => {
        if (timeoutId !== undefined) {
          clearTimeout(timeoutId);
          timeoutId = undefined;
        }
      };

      const finishResolve = (): void => {
        clearTimer();
        if (!settled) {
          settled = true;
          resolve();
        }
      };

      const finishReject = (messageText: string): void => {
        clearTimer();
        if (!settled) {
          settled = true;
          reject(new Error(messageText));
        }
      };

      const resetTimer = (): void => {
        clearTimer();
        timeoutId = setTimeout(() => {
          listener.onError('响应超时，请稍后再试。');
          try {
            socket.close();
          } catch (_error) {
          }
          finishReject('socket timeout');
        }, AgentGatewayService.SOCKET_IDLE_TIMEOUT_MS) as number;
      };

      resetTimer();
      socket.on('open', () => {
        AgentLogger.info(AgentGatewayService.LOG_STREAM, 'websocket open');
        listener.onReady();
        resetTimer();
        socket.send(payloadText);
      });
      socket.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
        if (settled) {
          return;
        }
        if (err && err.code !== 0) {
          listener.onError('WebSocket 接收失败。');
          finishReject('socket message error');
          return;
        }
        resetTimer();
        const text: string = AgentGatewayService.readSocketText(value);
        if (text.trim().length === 0) {
          return;
        }
        const frame: AgentSocketFrame = AgentJsonHelper.parseSocketFrame(text);
        if (frame.type === 'ready') {
          return;
        }
        if (frame.type === 'thinking') {
          listener.onThinking(frame.message);
          return;
        }
        if (frame.type === 'answer') {
          listener.onChunk(frame.text);
          return;
        }
        if (frame.type === 'done') {
          doneReceived = true;
          listener.onDone();
          try {
            socket.close();
          } catch (_error) {
          }
          finishResolve();
          return;
        }
        if (frame.type === 'error') {
          const messageText: string = frame.message.trim().length > 0 ? frame.message : '智能体服务异常。';
          listener.onError(messageText);
          try {
            socket.close();
          } catch (_error) {
          }
          finishReject(messageText);
        }
      });
      socket.on('close', (_err: BusinessError, _result: webSocket.CloseResult) => {
        AgentLogger.info(AgentGatewayService.LOG_STREAM, 'websocket close');
        if (doneReceived) {
          finishResolve();
          return;
        }
        if (!settled) {
          finishReject('websocket closed');
        }
      });
      socket.on('error', (_err: BusinessError) => {
        if (settled) {
          return;
        }
        listener.onError('WebSocket 连接失败。');
        finishReject('websocket error');
      });
      socket.connect(wsUrl);
    });
  }

  private static buildHistory(history: Array<AgentChatMessage>): Array<AgentHistoryMessage> {
    const filtered: Array<AgentChatMessage> = [];
    for (let index: number = 0; index < history.length; index++) {
      const item: AgentChatMessage = history[index];
      if (item.text.trim().length === 0) {
        continue;
      }
      if (item.status === AgentMessageStatus.Thinking || item.status === AgentMessageStatus.Error) {
        continue;
      }
      filtered.push(item);
    }
    const result: Array<AgentHistoryMessage> = [];
    const limit: number = filtered.length > 10 ? 10 : filtered.length;
    const startIndex: number = filtered.length - limit;
    for (let index: number = startIndex; index < filtered.length; index++) {
      const item: AgentChatMessage = filtered[index];
      const entry: AgentHistoryMessage = new AgentHistoryMessage();
      entry.role = item.sender === AgentSender.User ? 'user' : 'assistant';
      entry.content = item.text.trim();
      result.push(entry);
    }
    return result;
  }

  private static readSocketText(value: string | ArrayBuffer): string {
    if (typeof value === 'string') {
      return value;
    }
    return '';
  }
}
