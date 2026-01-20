// TaskTimeRangeItem子组件
import { TaskTimeRange } from '../model/TaskTimeRange';

@Component
export struct TaskTimeRangeItem {
  @ObjectLink taskItem: TaskTimeRange;
  private index: number;

  build() {
    Row() {
      // 左侧：任务索引和状态
      Column() {
        Text(`#${this.index + 1}`)
          .fontSize(12)
          .fontColor('#666666')
        
        Checkbox()
          .select(this.taskItem.isCompleted)
          .onChange((value: boolean) => {
            this.taskItem.isCompleted = value;
          })
      }
      .width(60)
      .alignItems(HorizontalAlign.Start)

      // 中间：任务详情
      Column() {
        Text(this.taskItem.taskName)
          .fontSize(16)
          .fontWeight(this.taskItem.isCompleted ? FontWeight.Normal : FontWeight.Medium)
          .decoration({ type: this.taskItem.isCompleted ? TextDecorationType.LineThrough : TextDecorationType.None })
          .fontColor(this.taskItem.isCompleted ? '#999999' : '#333333')
        
        Text(this.taskItem.getTimeDisplay())
          .fontSize(12)
          .fontColor('#666666')
        
        Text(`时长: ${this.taskItem.getDuration()}分钟 | 优先级: ${this.getPriorityText()}`)
          .fontSize(10)
          .fontColor('#888888')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      // 右侧：操作按钮
      Column() {
        Button('编辑')
          .type(ButtonType.Normal)
          .backgroundColor('#007DFF')
          .fontColor(Color.White)
          .fontSize(12)
          .height(24)
          .onClick(() => {
            this.showEditDialog();
          })
      }
      .width(80)
      .alignItems(HorizontalAlign.End)
    }
    .padding(12)
    .borderRadius(8)
    .backgroundColor(this.getCardBackgroundColor())
    .margin({ top: 8, bottom: 8 })
    .width('100%')
  }

  // 获取优先级文本
  private getPriorityText(): string {
    const priorityMap = {
      1: '低',
      2: '中', 
      3: '高'
    };
    return priorityMap[this.taskItem.priority] || '未知';
  }

  // 获取卡片背景色
  private getCardBackgroundColor(): string {
    if (this.taskItem.isCompleted) {
      return '#F0F0F0';
    }
    
    const priorityColors = {
      1: '#F8F9FA', // 低优先级
      2: '#FFF3CD', // 中优先级  
      3: '#F8D7DA'  // 高优先级
    };
    return priorityColors[this.taskItem.priority] || '#F8F9FA';
  }

  // 显示编辑对话框
  private showEditDialog(): void {
    // 这里可以添加编辑对话框的实现
    console.log(`编辑任务: ${this.taskItem.taskName}`);
  }
}