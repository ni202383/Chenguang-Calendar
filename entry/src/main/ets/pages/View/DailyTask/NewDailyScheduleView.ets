import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';
import { BasicConstant } from '../../../Constants/BasicConstant'
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';
import { Task } from '../../Model/DailyTask'
import { NewCountDown } from '../CountDown/NewCountDown';
import { RealDailySchedule } from './RealDailySchedule'


@Component
export struct DailySchedule {
  @State ensureUpdateDailyTask : boolean = false;
  @State isDeleteThisTask : boolean = false;
  @State currentIndex : number = 0;
  @StorageProp('screenWidth') screenWidth : number = 200;
  private tabsController : TabsController = new TabsController();
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('themeColor') themeColor : string = '';

  @Builder tabsBuilder(text : string,index : number){
    Column(){
      Text(text)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 20 : 15)
        .fontColor(index == this.currentIndex ? this.themeColor : Color.Black)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(38)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(20)
    .backgroundColor(Color.Transparent)
    .offset({
      y : -8
    })
  }

  build() {
    Column({space : ViewArkUIConstant.NEW_DAILY_SCHEDULE_WHOLE_COLUMN_GAP_SPACE}) {
      Text('新建日程')
        .fontSize(ViewArkUIConstant.NEW_DAILY_SCHEDULE_FONT_SIZE)
        .fontWeight(FontWeight.Bold)

      Stack({alignContent : Alignment.TopStart}){
        Column(){}
        .width(BasicConstant.FULL_WIDTH)
        .height(40)
        .padding({left : 20,right : 20})
        .backgroundColor('rgba(229, 229, 229, 0.40)')
        .borderRadius(20)

        Column(){}
        .width(BasicConstant.HALF_WIDTH)
        .height(38)
        .backgroundColor('rgba(255,255,255,1)')
        .padding({left : 20,right : 20})
        .shadow({
          radius : 20,
          color : 'rgba(0,0,0,0.2)',
          type : ShadowType.COLOR,
          offsetX : 0,
          offsetY : 0
        })
        .borderRadius(20)
        .alignRules({
          left : {anchor : '__container__',align : HorizontalAlign.Start},
          top : {anchor : '__container__',align : VerticalAlign.Top}
        })
        .offset({
          x : this.currentIndex * 175
        })

        Tabs({
          barPosition : BarPosition.Start,
          index : 0,
          controller : this.tabsController
        }){
          TabContent(){
            RealDailySchedule()
          }
          .tabBar(this.tabsBuilder('日程',0))

          TabContent(){
            NewCountDown()
          }
          .tabBar(this.tabsBuilder('倒计时',1))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .width(BasicConstant.FULL_WIDTH)
        .barWidth(BasicConstant.FULL_WIDTH)
        .scrollable(true)
        .onAnimationStart((fromIndex : number,toIndex : number) => {
          this.getUIContext().animateTo({
            curve : Curve.EaseInOut,
            duration : 300
          },() => {
            this.currentIndex = toIndex;
          })
        })
        .animation({
          curve : Curve.EaseInOut,
          duration : 300
        })

      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding(ViewArkUIConstant.NEW_DAILY_SCHEDULE_WHOLE_COLUMN_PADDING)
    .alignItems(HorizontalAlign.Start)
  }
}