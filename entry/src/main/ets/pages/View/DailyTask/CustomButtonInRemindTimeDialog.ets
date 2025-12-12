import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';
import { BasicConstant } from '../../../Constants/BasicConstant';
import { Task } from '../../Model/DailyTask';
import { CustomDialogSelectedRemindTime, RemindTime } from '../../Model/RemindTimeBase';

@Component
export struct CustomButtonInRemindTimeDialog{

  @StorageProp('themeColor') themeColor : string = '';
  @Link customRemindTimeList : Array<RemindTime>;
  @Link selectedRemindTimeNumber : number;
  private temp : Array<RemindTime> = this.customRemindTimeList;
  @Link isZero : boolean;

  build() {
    Button()
      .width(BasicConstant.FULL_WIDTH)
      .backgroundColor(Color.Transparent)
      .borderRadius(ViewArkUIConstant.CUSTOMIZED_REMINDER_BUTTON_BORDER_RADIUS)
      .onClick(() => {
        this.getUIContext().showTextPickerDialog({
          range : CustomDialogSelectedRemindTime,
          selectedTextStyle : {color : this.themeColor,font : {size :
          ViewArkUIConstant.CUSTOMIZED_REMINDER_BUTTON_SELECTED_TEXT_STYLE_FONT_SIZE, weight : FontWeight.Medium}},
          acceptButtonStyle : {fontColor : this.themeColor },
          cancelButtonStyle : {fontColor : this.themeColor},
          canLoop : false,
          onAccept : (value : TextPickerResult) => {
            let unit = value.value[0];
            let num = Number.parseInt(value.value[1])
            this.selectedRemindTimeNumber++;
            let customRemindTime = new RemindTime(num,unit,true);
            customRemindTime.setRemindTimeID(customRemindTime.toMinutes())
            this.temp.push(customRemindTime);
            this.isZero = false;
            this.customRemindTimeList = this.temp;
          }
        })
      })
  }
}