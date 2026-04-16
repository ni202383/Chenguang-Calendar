export class AgentUiBridge {
  private static nextVersion(key: string): number {
    const current: number = Number(AppStorage.get(key) ?? 0);
    const next: number = current + 1;
    AppStorage.setOrCreate(key, next);
    return next;
  }

  public static switchRootTab(index: number): void {
    AppStorage.setOrCreate('agentRootTabIndex', index);
    AgentUiBridge.nextVersion('agentRootTabVersion');
  }

  public static jumpCalendar(dateText: string, viewType: string): void {
    AppStorage.setOrCreate('agentCalendarJumpDate', dateText);
    AppStorage.setOrCreate('agentCalendarJumpViewType', viewType);
    AgentUiBridge.nextVersion('agentCalendarJumpVersion');
  }

  public static focusTask(taskId: string): void {
    AppStorage.setOrCreate('agentFocusTaskId', taskId);
    AgentUiBridge.nextVersion('agentFocusTaskVersion');
  }

  public static focusCountDown(countDownId: string): void {
    AppStorage.setOrCreate('agentFocusCountDownId', countDownId);
    AgentUiBridge.nextVersion('agentFocusCountDownVersion');
  }

  public static clearTaskFocus(): void {
    AppStorage.setOrCreate('agentFocusTaskId', '');
    AgentUiBridge.nextVersion('agentFocusTaskVersion');
  }

  public static clearCountDownFocus(): void {
    AppStorage.setOrCreate('agentFocusCountDownId', '');
    AgentUiBridge.nextVersion('agentFocusCountDownVersion');
  }
}
