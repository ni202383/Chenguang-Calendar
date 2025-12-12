import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant";
import { BasicConstant } from "../../../Constants/BasicConstant";
import { Task } from "../../Model/DailyTask";
import { RemindTime } from "../../Model/RemindTimeBase";

@Extend(Divider)
function dividerStyle() {
  .vertical(ViewArkUIConstant.ADD_TASK_REMINDER_DIVIDE_IS_VERTICAL)
  .color($r('app.color.backgroundcolor'))
  .strokeWidth(ViewArkUIConstant.ADD_TASK_REMINDER_DIVIDE_STROKE_WIDTH)
  .width(ViewArkUIConstant.ADD_TASK_REMINDER_DIVIDE_WIDTH_PERCENTAGE)
}

@Component
export struct DialogSelectRemindTimePerList{

  @ObjectLink item : RemindTime;
  @StorageProp('themeColor') themeColor : string = '';
  @Link isZero : boolean;
  @Link selectedRemindTimeNumber : number;
  @Prop index : number = 0;
  @StorageLink('newDailySchedule') newDailySchedule : Task = new Task();

  build() {
    Column() {
      Stack(){
        Row() {
          Text(this.index == ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX ? '无' :
            this.index == ViewArkUIConstant.ADD_TASK_NOTIFY_IMMEDIATELY_INDEX ? '立刻' :
              this.item.toString() + '前')
            .fontSize(ViewArkUIConstant.ADD_TASK_REMINDER_TIME_FONT_SIZE)
          Radio({
            value: this.item.toString(),
            group: this.item.toString(),
            indicatorType: RadioIndicatorType.TICK
          })
            .radioStyle({
              checkedBackgroundColor: this.themeColor
            })
            .checked(this.item.getIsSelect())

        }
        .width(BasicConstant.FULL_WIDTH)
        .height(ViewArkUIConstant.ADD_TASK_PER_REMINDER_ROW_HEIGHT)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceBetween)

        Button()
          .width(BasicConstant.FULL_WIDTH)
          .backgroundColor(Color.Transparent)
          .borderRadius(ViewArkUIConstant.ADD_TASK_PER_REMINDER_BUTTON_BORDER_RADIUS)
          .onClick((event : ClickEvent) => {
            if(this.index > 0){
              if(this.item.getIsSelect() == false){
                this.isZero = false;
                this.selectedRemindTimeNumber++;
              } else {
                this.selectedRemindTimeNumber--;
                if(this.selectedRemindTimeNumber == 0){
                  this.isZero = true;
                }
              }
              this.item.setIsSelect(!this.item.getIsSelect());
            } else {
              if(this.item.getIsSelect() == false){
                this.isZero = true;
                this.selectedRemindTimeNumber = 0;
                this.item.setIsSelect(!this.item.getIsSelect());
              }
            }
          })

      }
      .width(BasicConstant.FULL_WIDTH)

      Divider().dividerStyle()
    }
    .width(BasicConstant.FULL_WIDTH)
  }
}