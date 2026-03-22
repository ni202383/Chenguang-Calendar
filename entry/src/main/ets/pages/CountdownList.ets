import { BasicConstant } from '../Constants/BasicConstant'
import { BreakpointConstant } from '../Constants/BreakpointConstant'
import { ButtonModifier } from './Model/AttributeModifier';
import { countDownStore } from './Model/CountDownStore'
import { EventCountDown } from './Model/EventCountDown';
import { CountDownListCard } from './View/CountDown/CountDownListCard';
import { WidgetAddHelper } from './Model/WidgetAddHelper';
import { common } from '@kit.AbilityKit';

@Extend(Button)
function ListItemEndCircleStyle() {
  .width(45)
  .height(45)
  .type(ButtonType.Circle)
}

@Entry
@Component
struct CountdownList {
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @State countDownList: Array<EventCountDown> = [];
  @StorageProp('themeColor') themeColor: string = '';

  aboutToAppear(): void {
    this.countDownList = countDownStore.getAll();
  }

  @Builder
  ListItemEnd(id: string, index: number) {
    Button() {
      Image($r('app.media.delete_white'))
        .width('75%')
    }
    .ListItemEndCircleStyle()
    .backgroundColor(Color.Red)
    .margin({ left: 15 })
    .onClick((event: ClickEvent) => {
      this.getUIContext().animateTo({
        curve: Curve.EaseInOut,
        duration: 300
      }, () => {
        countDownStore.deleteCountDownById(id);
        this.countDownList.splice(index, 1);
      })
    })
  }

  @Builder
  ListItemStart(text: string,id : string) {
    Column() {
      Column() {
        TextArea({ text: text })
          .maxLines(10)
          .textOverflow(TextOverflow.Ellipsis)
          .height('100%')
          .backgroundColor(Color.White)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(110)
      .backgroundColor(Color.White)
      .padding(10)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Button('添加至桌面')
        .fontColor(Color.White)
        .backgroundColor(this.themeColor)
        .width('90%')
        .height(30)
        .onClick((event: ClickEvent) => {
          WidgetAddHelper.openManagerAndRefreshPreview(this.getUIContext().getHostContext() as common.Context, id);
        })
    }
    .width(200)
    .height(150)
    .borderRadius(20)
    .backgroundColor(Color.White)
    .margin({ right: 15 })
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    RelativeContainer() {
      if (this.countDownList.length == 0) {
        Column({ space: 20 }) {
          Image($r('app.media.empty_page'))
            .width('40%')

          Text('页面空空如也')
            .fontSize(25)
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(BasicConstant.FULL_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Scroll() {
          List({ space: 10 }) {
            ForEach(this.countDownList, (item: EventCountDown, index: number) => {
              ListItem() {
                CountDownListCard({ eventCountDown: item })
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(150)
              .swipeAction({
                start : this.ListItemStart(item.eventDetail == '' ? '您未写详细信息哦~' : item.eventDetail,item.getId()),
                end: this.ListItemEnd(item.getId(), index),
                edgeEffect: SwipeEdgeEffect.Spring
              })
            }, (item: EventCountDown) => JSON.stringify(item))
          }
          .width(BasicConstant.FULL_WIDTH)
          .height('auto')
          .padding({ left: 15, right: 15 })
          .lanes(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 1 :
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? 2 : 3)
          .listDirection(Axis.Vertical)
          .divider(null)
          .edgeEffect(EdgeEffect.Spring)
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(BasicConstant.FULL_HEIGHT)
        .scrollBar(BarState.Off)
        .align(Alignment.Top)
        .edgeEffect(EdgeEffect.Spring)
        .padding({ top: 80 + this.getUIContext().px2vp(this.topStatusBarHeight) })
        .alignRules({
          top: { anchor: '__container__', align: VerticalAlign.Top },
        })
      }

      Row() {
        Row({ space: 10 }) {
          Button() {
            Image($r('app.media.return'))
              .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
              .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
          }
          .attributeModifier(new ButtonModifier(
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
            'rgba(232,232,232,0.3)'
          ))
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })

          Text('倒计时')
            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 25)
            .fontWeight(FontWeight.Bold)
        }
        .height(BasicConstant.FULL_HEIGHT)
        .alignItems(VerticalAlign.Center)
        .padding({ left: 15 })
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(90)
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center)
      .padding({ top: this.getUIContext().px2vp(this.topStatusBarHeight) })
      .backgroundColor('rgba(255,255,255,0.1)')
      .backgroundBlurStyle(BlurStyle.Thin)
      .alignRules({
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        top: { anchor: '__container__', align: VerticalAlign.Top }
      })

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .backgroundColor($r('app.color.backgroundcolor'))
  }
}
