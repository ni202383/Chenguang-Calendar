import { hilog } from '@kit.PerformanceAnalysisKit';

export class AgentLogger {
  public static readonly PREFIX: string = '[CHENGGUANG_AGENT]';
  private static readonly DOMAIN: number = 0xFF12;
  private static readonly TAG: string = 'ChengguangAgent';

  private static build(scope: string): string {
    return AgentLogger.PREFIX + '[' + scope + ']';
  }

  public static info(scope: string, message: string): void {
    hilog.info(AgentLogger.DOMAIN, AgentLogger.TAG, '%{public}s', AgentLogger.build(scope) + ' ' + message);
  }

  public static warn(scope: string, message: string): void {
    hilog.warn(AgentLogger.DOMAIN, AgentLogger.TAG, '%{public}s', AgentLogger.build(scope) + ' ' + message);
  }

  public static error(scope: string, message: string): void {
    hilog.error(AgentLogger.DOMAIN, AgentLogger.TAG, '%{public}s', AgentLogger.build(scope) + ' ' + message);
  }
}
