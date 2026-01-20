// 主页面：周任务时间范围列表
import { TaskTimeRange } from '../model/TaskTimeRange';
import { TaskTimeRangeItem } from '../component/TaskTimeRangeItem';

@Entry
@Component
struct WeeklyTaskPage {
  @State weeklyTaskTimeRangeList: TaskTimeRange[] = [];
  @State newTaskName: string = '';

  aboutToAppear() {
    this.initializeSampleData();
  }

  build() {
    Column() {
      // 标题和统计
      this.buildHeader()
      
      // 添加新任务区域
      this.buildAddTaskSection()
      
      // 任务列表
      this.buildTaskList()
    }
    .padding(16)
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // 构建头部统计信息
  @Builder
  buildHeader() {
    Row() {
      Column() {
        Text('周任务时间安排')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Text(`总任务数: ${this.weeklyTaskTimeRangeList.length} | 已完成: ${this.getCompletedCount()} | 进行中: ${this.getInProgressCount()}`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Button('清空')
        .type(ButtonType.Normal)
        .backgroundColor('#DC3545')
        .fontColor(Color.White)
        .onClick(() => {
          this.clearAllTasks();
        })
    }
    .margin({ bottom: 20 })
  }

  // 构建添加任务区域
  @Builder
  buildAddTaskSection() {
    Row() {
      TextInput({ placeholder: '输入任务名称...', text: this.newTaskName })
        .onChange((value: string) => {
          this.newTaskName = value;
        })
        .layoutWeight(1)
        .height(40)

      Button('添加任务')
        .type(ButtonType.Normal)
        .backgroundColor('#28A745')
        .fontColor(Color.White)
        .margin({ left: 10 })
        .onClick(() => {
          this.addNewTask();
        })
    }
    .margin({ bottom: 20 })
  }

  // 构建任务列表
  @Builder
  buildTaskList() {
    if (this.weeklyTaskTimeRangeList.length === 0) {
      this.buildEmptyState()
    } else {
      Scroll() {
        Column() {
          ForEach(this.weeklyTaskTimeRangeList, (item: TaskTimeRange, index: number) => {
            TaskTimeRangeItem({ taskItem: item, index: index })
          }, (item: TaskTimeRange) => item.id)
        }
      }
      .layoutWeight(1)
    }
  }

  // 构建空状态
  @Builder
  buildEmptyState() {
    Column() {
      Image($r('app.media.ic_empty_tasks'))
        .width(120)
        .height(120)
        .margin({ bottom: 16 })
      
      Text('暂无任务安排')
        .fontSize(18)
        .fontColor('#999999')
        .margin({ bottom: 8 })
      
      Text('点击上方"添加任务"按钮开始安排您的周任务')
        .fontSize(14)
        .fontColor('#999999')
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 初始化示例数据
  private initializeSampleData(): void {
    const now = new Date();
    
    // 添加一些示例任务
    this.weeklyTaskTimeRangeList.push(
      new TaskTimeRange(
        'task1',
        '晨间会议',
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 9, 0),
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 10, 0)
      )
    );

    this.weeklyTaskTimeRangeList.push(
      new TaskTimeRange(
        'task2', 
        '项目开发',
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 10, 30),
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 12, 0)
      )
    );

    this.weeklyTaskTimeRangeList.push(
      new TaskTimeRange(
        'task3',
        '代码审查',
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 14, 0),
        new Date(now.getFullYear(), now.getMonth(), now.getDate(), 15, 30)
      )
    );
  }

  // 添加新任务
  private addNewTask(): void {
    if (this.newTaskName.trim() === '') {
      console.log('任务名称不能为空');
      return;
    }

    const now = new Date();
    const newTask = new TaskTimeRange(
      `task_${Date.now()}`,
      this.newTaskName.trim(),
      new Date(now.getFullYear(), now.getMonth(), now.getDate(), 16, 0),
      new Date(now.getFullYear(), now.getMonth(), now.getDate(), 17, 0)
    );

    this.weeklyTaskTimeRangeList.push(newTask);
    this.newTaskName = '';
    
    console.log(`添加新任务: ${newTask.taskName}`);
  }

  // 清空所有任务
  private clearAllTasks(): void {
    this.weeklyTaskTimeRangeList = [];
    console.log('已清空所有任务');
  }

  // 获取已完成任务数量
  private getCompletedCount(): number {
    return this.weeklyTaskTimeRangeList.filter(task => task.isCompleted).length;
  }

  // 获取进行中任务数量
  private getInProgressCount(): number {
    return this.weeklyTaskTimeRangeList.filter(task => !task.isCompleted).length;
  }
}