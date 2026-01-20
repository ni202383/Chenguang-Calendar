// TaskTimeRange数据模型定义
@Observed
export class TaskTimeRange {
  id: string;
  taskName: string;
  startTime: Date;
  endTime: Date;
  isCompleted: boolean = false;
  priority: number = 1; // 1-低, 2-中, 3-高

  constructor(id: string, taskName: string, startTime: Date, endTime: Date) {
    this.id = id;
    this.taskName = taskName;
    this.startTime = startTime;
    this.endTime = endTime;
  }

  // 更新任务时间范围
  updateTimeRange(newStart: Date, newEnd: Date): void {
    this.startTime = newStart;
    this.endTime = newEnd;
  }

  // 更新任务名称
  updateTaskName(newName: string): void {
    this.taskName = newName;
  }

  // 切换完成状态
  toggleCompletion(): void {
    this.isCompleted = !this.isCompleted;
  }

  // 更新优先级
  updatePriority(newPriority: number): void {
    this.priority = newPriority;
  }

  // 获取任务时长（分钟）
  getDuration(): number {
    return (this.endTime.getTime() - this.startTime.getTime()) / (1000 * 60);
  }

  // 格式化时间显示
  getTimeDisplay(): string {
    return `${this.startTime.getHours().toString().padStart(2, '0')}:${this.startTime.getMinutes().toString().padStart(2, '0')} - ${this.endTime.getHours().toString().padStart(2, '0')}:${this.endTime.getMinutes().toString().padStart(2, '0')}`;
  }
}