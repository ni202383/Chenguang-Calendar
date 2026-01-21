import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant";
import { BasicConstant } from "../../../Constants/BasicConstant";
import { Task } from "../../Model/DailyTask";
import { TaskType } from "../../Model/Enum";

@Component
export struct DailyTaskListItem {
  @ObjectLink task: Task;
  private workColor: string = '#E31818';
  private lifeColor: string = '#58EF1A';
  private entertainmentColor: string = '#AB1AC2';
  private self_disciplineColor: string = '#22E7D0';
  @Link currentYear: number;
  @Link currentMonth: number;
  @Link selectedDay: number;
  isMonth : boolean = true;
  isDay : boolean = false;

  @Styles
  columnStyle(){
    .width(BasicConstant.FULL_WIDTH)
    .borderRadius(ViewArkUIConstant.TASK_LIST_ITEM_WHOLE_BORDER_RADIUS)
    .backgroundColor(Color.White)
    .padding(ViewArkUIConstant.TASK_LIST_ITEM_WHOLE_PADDING)
  }

  build() {//日程列表卡片的ArkUI
    Column({ space: ViewArkUIConstant.TASK_LIST_ITEM_WHOLE_COLUMN_GAP_SPACE }) {
      Row() {
        Text(this.task.getTitle())
          .fontSize(ViewArkUIConstant.TASK_LIST_ITEM_TITLE_FONT_SIZE)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .width(ViewArkUIConstant.TASK_LIST_ITEM_TITLE_WIDTH_PERCENTAGE)
          .maxLines(ViewArkUIConstant.TASK_LIST_ITEM_TITLE_MAX_LINES)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Column() {
          Text(this.task.getTaskType() == TaskType.Work ? '工作' :
            this.task.getTaskType() == TaskType.Entertainment ? '娱乐' :
              this.task.getTaskType() == TaskType.life ? '生活' : '自律')
            .fontSize(ViewArkUIConstant.TASK_LIST_ITEM_TASK_TYPE_FONT_SIZE)
            .fontColor(Color.White)
        }
        .width(ViewArkUIConstant.TASK_LIST_ITEM_TASK_TYPE_COLUMN_WIDTH_PERCENTAGE)
        .height(ViewArkUIConstant.TASK_LIST_ITEM_TASK_TYPE_COLUMN_HEIGHT)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .borderRadius(ViewArkUIConstant.TASK_LIST_ITEM_TASK_TYPE_COLUMN_BORDER_RADIUS)
        .backgroundColor(this.task.getTaskType() == TaskType.Work ? this.workColor :
          this.task.getTaskType() == TaskType.Entertainment ? this.entertainmentColor :
            this.task.getTaskType() == TaskType.life ? this.lifeColor : this.self_disciplineColor
        )
      }
      .width(ViewArkUIConstant.TASK_LIST_ITEM_TOP_WIDTH_PERCENTAGE)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row({ space: ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_ROW_GAP_SPACE }) {
        Column({ space: ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_LEFT_COLUMN_GAP_SPACE }) {
          Text(`${this.currentYear}年${this.currentMonth}月${this.selectedDay}日`)
            .fontSize(this.isMonth && !this.isDay ? ViewArkUIConstant.TASK_LIST_ITEM_DATE_FONT_SIZE : 14)
            .fontColor(Color.Black)
          Text(`开始时间:${this.task.getBeginHour().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')
          } : ${this.task.getBeginMinute().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')}`)
            .fontSize(this.isMonth && !this.isDay ? ViewArkUIConstant.TASK_LIST_ITEM_BEGIN_END_TIME_FONT_SIZE : 14)
            .fontColor(Color.Black)
          Text(`结束时间:${this.task.getEndHour().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')
          } : ${this.task.getEndMinute().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')}`)
            .fontSize(this.isMonth && !this.isDay ? ViewArkUIConstant.TASK_LIST_ITEM_BEGIN_END_TIME_FONT_SIZE : 14)
            .fontColor(Color.Black)
        }
        .width(ViewArkUIConstant.TASK_LIST_ITEM_TASK_TIME_WIDTH_PERCENTAGE)
        .height(BasicConstant.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column({ space: ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_RIGHT_COLUMN_GAP_SPACE }) {
          Text(`在${this.task.getLocation()}`)
            .width(ViewArkUIConstant.TASK_LIST_ITEM_LOCATION_FONT_WIDTH_PERCENTAGE)
            .fontSize(this.isMonth && !this.isDay ? ViewArkUIConstant.TASK_LIST_ITEM_LOCATION_FONT_SIZE : 14)
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Bold)

          Text(this.task.getDetail())
            .fontSize(this.isMonth && !this.isDay ? ViewArkUIConstant.TASK_LIST_ITEM_DETAIL_FONT_SIZE : 14)
            .maxLines(ViewArkUIConstant.TASK_LIST_ITEM_DETAIL_MAX_LINES)
            .fontColor(Color.Black)
            .width(ViewArkUIConstant.TASK_LIST_ITEM_DETAIL_WIDTH_PERCENTAGE)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width(ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_RIGHT_COLUMN_WIDTH_PERCENTAGE)
        .height(BasicConstant.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .flexGrow(ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_RIGHT_COLUMN_FLEX_GROW)

      }
      .width(BasicConstant.FULL_WIDTH)
      .height(ViewArkUIConstant.TASK_LIST_ITEM_BOTTOM_ROW_HEIGHT_PERCENTAGE)
      .alignItems(VerticalAlign.Center)

    }
    .columnStyle()
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
  }
}