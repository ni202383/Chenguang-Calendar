export class AgentGatewayConfig {
  public static readonly BASE_HTTP_URL: string = 'http://118.195.201.59:18080';
  public static readonly PLAN_PATH: string = '/v1/assistant/intent';
  public static readonly CHAT_WS_URL: string = 'ws://118.195.201.59:18080/v1/assistant/answer-stream';
  public static readonly TOKEN: string = 'Chengguang_calendar_token_NuIsT';
  public static readonly AUTHORIZATION: string = 'Bearer ' + AgentGatewayConfig.TOKEN;
  public static readonly TIME_ZONE: string = 'Asia/Shanghai';
}
