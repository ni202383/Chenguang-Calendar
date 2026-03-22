import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant";
import { BasicConstant } from "../../../Constants/BasicConstant";
import { EventCountDown } from "../../Model/EventCountDown";
import {backgroundImageList} from '../../../data/backgroundImageList'
import { CustomContentDialog } from "@ohos.arkui.advanced.Dialog";
import {countDownStore} from '../../Model/CountDownStore'
import { WidgetAddHelper } from "../../Model/WidgetAddHelper";
import { common } from "@kit.AbilityKit";

@Extend(Text)
function titleTextStylePerItem() {
  .fontSize(ViewArkUIConstant.TASK_DETAIL_TITLE_PER_ITEM_FONT_SIZE)
  .fontWeight(FontWeight.Bold)
}

@Extend(TextInput)
function textInputStyle() {
  .placeholderColor($r('app.color.gray_deeper'))
  .backgroundColor('rgba(255,255,255,0)')
  .width(BasicConstant.FULL_WIDTH)
  .height(35)
  .padding({
    top: 4,
    bottom: 4,
    left: 8,
    right: 8
  })
}

class ButtonRowType{
  text : string = '';
  time : string = '';
}

@Extend(Button) function ensureButtonType(backgroundColor : string){
  .width('47%')
  .height(45)
  .backgroundColor(backgroundColor)
  .fontColor(Color.White)
}

@Component
export struct NewCountDown{
  @State newCountDown : EventCountDown = new EventCountDown();
  @StorageLink('isChange') isChange : boolean = false;
  @StorageProp('themeColor') themeColor : string = '';
  @State imageIndex : number = 0;
  @StorageLink('isCloseNewDailyTask') isCloseNewDailyTask: boolean = false;
  private savedId : string = '';

  @Builder buttonRow($$ : ButtonRowType){
    Row(){
      Text($$.text)
        .fontSize(16)
        .fontColor($r('app.color.gray_deeper'))
      Row(){
        Text($$.time)
          .fontSize(14)
          .fontColor($r('app.color.gray_deeper'))
        Image($r('app.media.chevron_right'))
          .width(40)
      }
      .height(BasicConstant.FULL_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .width('95%')
    .height(BasicConstant.FULL_HEIGHT)
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(VerticalAlign.Center)
  }

  CalendarPickerDialog = () => {
    CalendarPickerDialog.show({
      selected : this.newCountDown.targetDate,
      onAccept : (value) => {
        this.newCountDown.targetDate = value;
        this.isChange = true;
      },
      acceptButtonStyle : {
        fontColor : this.themeColor
      },
      cancelButtonStyle : {
        fontColor : this.themeColor
      },
      backgroundColor : 'rgba(255,255,255,0.3)',
      backgroundBlurStyle : BlurStyle.Thin
    })
  }

  timePickerDialog = () => {
    this.getUIContext().showTimePickerDialog({
      useMilitaryTime : true,
      format : TimePickerFormat.HOUR_MINUTE_SECOND,
      selected : new Date(),
      selectedTextStyle: {
        color: this.themeColor
      },
      acceptButtonStyle: {
        fontColor: this.themeColor
      },
      cancelButtonStyle: {
        fontColor: this.themeColor
      },
      onAccept : (value : TimePickerResult) => {
        this.newCountDown.targetDate.setHours(value.hour);
        this.newCountDown.targetDate.setMinutes(value.minute);
        this.newCountDown.targetDate.setSeconds(value.second);
        this.isChange = true;
        this.newCountDown.hourMinuteSecondIsUsed = true;
      },
      backgroundColor : 'rgba(255,255,255,0.3)',
      backgroundBlurStyle : BlurStyle.Thin
    })
  }

  submitCountDownIncompleteDialogController : CustomDialogController = new CustomDialogController({
    builder : CustomContentDialog({
      primaryTitle : '信息不完整哦~',
      contentBuilder : () => {
        this.submitCountDownIncompleteDialogText();
      },
      buttons : [
        {
          value : '确定',
          fontColor : this.themeColor,
          action : () => {
            this.submitCountDownIncompleteDialogController.close();
          }
        }
      ]
    }),
    backgroundColor :' rgba(255,255,255,0.3)',
    backgroundBlurStyle : BlurStyle.Thin
  })

  @Builder submitCountDownIncompleteDialogText(){
    Column(){
      Text('请完善好信息再保存哦~')
        .fontSize(15)
        .fontColor(Color.Black)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(30)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  async saveNewCountDown(){
    if(this.newCountDown.eventName == '' || this.newCountDown.targetDate <= new Date()){
      this.submitCountDownIncompleteDialogController.open();
    } else {
      this.newCountDown.imageIndex = this.imageIndex;
      countDownStore.addCountDown(this.newCountDown);
      this.isChange = false;
      this.savedId = await countDownStore.addCountDownAndFlush(this.newCountDown);
      this.getUIContext().animateTo({
        curve : Curve.EaseInOut,
        duration : 300
      },() => {
        this.isCloseNewDailyTask = true;
        this.isCloseNewDailyTask = false;
      })
      this.getUIContext().getPromptAction().showToast({ message: '保存成功！' });
      this.newCountDown = new EventCountDown();
    }
  }

  build() {
    Scroll(){
      Column({space : 15}){
        Text('倒计时信息')
          .titleTextStylePerItem()

        List({space : 5}){
          ListItem(){
            TextInput({text : this.newCountDown.eventName,placeholder : '请输入事件名称：'})
              .textInputStyle()
              .onChange((value) => {
                this.newCountDown.eventName = value;
                this.isChange = true;
              })
          }

          ListItem(){
            TextArea({text : this.newCountDown.eventDetail,placeholder : '可输入事件的详细安排：'})
              .placeholderColor($r('app.color.gray_deeper'))
              .backgroundColor('rgba(255,255,255,0)')
              .width(BasicConstant.FULL_WIDTH)
              .height(100)
              .padding(8)
              .maxLines(8)
              .maxLength(160)
              .barState(BarState.On)
              .onChange((value) => {
                this.newCountDown.eventDetail = value;
                this.isChange = true;
              })
          }

          ListItem(){
            Button({type : ButtonType.Capsule}){
              this.buttonRow({
                text : '点击选择年月日',
                time : `${this.newCountDown.targetDate.getFullYear()}年${this.newCountDown.targetDate.getMonth() + 1}月${this.newCountDown.targetDate.getDate()}日`
              })
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(45)
            .backgroundColor(Color.Transparent)
            .onClick((event: ClickEvent) => {
              this.CalendarPickerDialog();
            })
          }

          ListItem(){
            Button({type : ButtonType.Capsule}){
              this.buttonRow({
                text : '点击选择时分秒（可选）',
                time : `${this.newCountDown.targetDate.getHours()}时${this.newCountDown.targetDate.getMinutes()}分${this.newCountDown.targetDate.getSeconds()}秒`
              })
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(45)
            .backgroundColor(Color.Transparent)
            .onClick((event : ClickEvent) => {
              this.timePickerDialog();
            })
          }
        }
        .width(BasicConstant.FULL_WIDTH)
        .lanes(1)
        .divider({
          strokeWidth : 1,
          color : $r('app.color.background_gray')
        })
        .backgroundColor(Color.Transparent)

        Text('选择图片装扮倒计时卡片')
          .titleTextStylePerItem()

        List(){
          ForEach(backgroundImageList,(item : Resource,index : number) => {
            ListItem(){
              Image(item)
                .height('95%')
                .shadow({
                  radius : 20,
                  color : this.imageIndex == index ? this.themeColor : Color.Transparent,
                  type : ShadowType.COLOR,
                  offsetX : 0,
                  offsetY : 0
                })
                .onClick((event : ClickEvent) => {
                  this.isChange = true;
                  this.imageIndex = index;
                  this.newCountDown.image = item;
                  this.newCountDown.imageIndex = index;
                })
            }
            .height(BasicConstant.FULL_HEIGHT)
            .margin({left : 10})
          },(item : Resource) => JSON.stringify(item))
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(100)
        .listDirection(Axis.Horizontal)
        .divider(null)
        .backgroundColor(Color.Transparent)

        // Row(){
        //   Text('置顶')
        //     .fontSize(15)
        //     .fontColor($r('app.color.gray_deeper'))
        //   Toggle({
        //     type : ToggleType.Switch,
        //     isOn : this.newCountDown.isImportant
        //   })
        //     .selectedColor(this.themeColor)
        //     .switchPointColor(Color.White)
        //     .onChange((isOn : boolean) => {
        //       this.newCountDown.isImportant = isOn;
        //       this.isChange = true;
        //     })
        // }
        // .width(BasicConstant.FULL_WIDTH)
        // .height(55)
        // .backgroundColor('rgba(229, 229, 229, 0.40)')
        // .justifyContent(FlexAlign.SpaceBetween)
        // .alignItems(VerticalAlign.Center)
        // .padding(10)
        // .borderRadius(20)

        Row({space : 10}){
          Button('仅保存')
            .ensureButtonType(this.themeColor)
            .onClick((event : ClickEvent) => {
              this.saveNewCountDown();
            })

          Button('生成桌面小卡片')
            .ensureButtonType(this.themeColor)
            .onClick((event : ClickEvent) => {
              this.saveNewCountDown();
              WidgetAddHelper.openManagerAndRefreshPreview(this.getUIContext().getHostContext() as common.Context, this.savedId);
            })
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(45)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .margin({top : 130})
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .backgroundColor(Color.Transparent)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .backgroundColor(Color.Transparent)
  }
}
