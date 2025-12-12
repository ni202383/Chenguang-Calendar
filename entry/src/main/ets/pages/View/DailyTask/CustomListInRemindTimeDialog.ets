import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant";
import { BasicConstant } from "../../../Constants/BasicConstant"
import { RemindTime } from "../../Model/RemindTimeBase";

@Extend(Divider)
function dividerStyle() {
  .vertical(false)
  .color($r('app.color.backgroundcolor'))
  .strokeWidth(ViewArkUIConstant.ADD_TASK_REMINDER_DIVIDE_STROKE_WIDTH)
  .width(ViewArkUIConstant.ADD_TASK_REMINDER_DIVIDE_WIDTH_PERCENTAGE)
}

@Component
export struct CustomListInRemindTimeDialog {
  @StorageProp('themeColor') themeColor: string = '';
  @ObjectLink item: RemindTime;
  @Link isZero: boolean;
  @Link selectedRemindTimeNumber: number;

  build() {
    Column() {
      Stack() {
        Row() {
          Text(`${this.item.getRemindTime()}${this.item.getUnit()}前`)
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
          .onClick((event: ClickEvent) => {
            if (this.item.getIsSelect() == false) {
              this.isZero = false;
              this.selectedRemindTimeNumber++;
            } else {
              this.selectedRemindTimeNumber--;
              if (this.selectedRemindTimeNumber == 0) {
                this.isZero = true;
              }
            }
            this.item.setIsSelect(!this.item.getIsSelect());
          })

      }
      .width(BasicConstant.FULL_WIDTH)

      Divider().dividerStyle()
    }
    .width(BasicConstant.FULL_WIDTH)
  }
}