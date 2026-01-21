import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { PerWeekInfo } from "../Model/PerWeekInfo";
import { WeekDataSource } from "../ViewModel/DataSource/WeekDataSource";
import {WeekViewDetail } from "./WeekViewDetail";
import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";

@Component
export struct WeekView {
  @Consume('currentYearInWeekView') currentYear: number = new Date().getFullYear();
  @Consume('currentMonthInWeekView') currentMonth: number = new Date().getMonth() + 1;
  @Consume('selectedDayInWeekView') selectedDay: number = this.currentYear == new Date().getFullYear() &&
    this.currentMonth == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  private swiperController: SwiperController = new SwiperController();
  private weekDataSource: WeekDataSource = new WeekDataSource(this.currentYear, this.currentMonth, this.selectedDay)
  private weekArray: Array<string> = ['日', '一', '二', '三', '四', '五', '六'];
  @Link @Watch('ChangeToSpecifiedIndex') currentIndex: number;
  private preIndex : number = this.weekDataSource.getInitialIndex();
  @StorageProp('screenWidth') screenWidth: number = 200;
  @State @Watch('rowCompensateY') yOffset : number = 0;
  private viewSize: number = Math.floor((this.screenWidth - 30) / 7); //用于计算每个窗口中圆形框的尺寸
  private viewSizeHeightMD = this.viewSize / 2;
  private holdDistance: number = this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize : this.viewSizeHeightMD;

  aboutToAppear(): void {
    this.preIndex = this.currentIndex;
  }

  ChangeToSpecifiedIndex(){
    if(Math.abs(this.preIndex - this.currentIndex) > 5){
      this.swiperController.changeIndex(this.currentIndex,false);
    } else {
      this.swiperController.changeIndex(this.currentIndex,true);
    }
    this.preIndex = this.currentIndex;
  }

  rowCompensateY(){
    return Math.max(this.yOffset - this.holdDistance,0);
  }

  build() {
    Stack({alignContent : Alignment.Top}) {
      Row() {
        ForEach(this.weekArray, (item: string, index: number) => {
          Text(item)
            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
            ViewArkUIConstant.WEEK_ARRAY_FONTSIZE_SM : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD
              ? ViewArkUIConstant.WEEK_ARRAY_FONTSIZE_MD : ViewArkUIConstant.WEEK_ARRAY_FONTSIZE_LG)
            .fontColor(index == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX ||
              index == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX ? $r('app.color.gray_deep') : Color.Black)
        }, (item: string) => item)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(ViewArkUIConstant.WEEK_ARRAY_HEIGHT)
      .backgroundColor($r('app.color.backgroundcolor'))
      .zIndex(10)
      .justifyContent(FlexAlign.SpaceAround)
      .translate({x : 0,y : -this.rowCompensateY()})

      Scroll() {
        Swiper(this.swiperController) {
          LazyForEach(this.weekDataSource, (item_: PerWeekInfo, index: number) => {
            WeekViewDetail({ perWeekInfo: item_ })
          }, (item: PerWeekInfo) => `${item.getYear()}-${item.getMonth()}-${item.getSelectedDay()}`)
        }
        .width(BasicConstant.FULL_WIDTH)
        .autoPlay(false)
        .loop(false)
        .indicator(false)
        .index(this.weekDataSource.getInitialIndex())
        .itemSpace(ViewArkUIConstant.SWIPER_ITEM_SPACE)
        .margin({ bottom : ViewArkUIConstant.SWIPER_MARGIN_BOTTOM })
        .onAnimationStart((fromIndex : number,toIndex : number) => {
          const currentInfo = this.weekDataSource.getData(toIndex);
          this.currentYear = currentInfo.getYear();
          this.currentMonth = currentInfo.getMonth();
          this.currentIndex = toIndex;
        })
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .layoutWeight(ViewArkUIConstant.SCROLL_LAYOUT_WEIGHT) // 添加权重，让Scroll占据剩余空间
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off) // 显示滚动条便于调试
      .edgeEffect(EdgeEffect.Spring) // 添加边缘效果
      .padding({top : ViewArkUIConstant.WEEK_ARRAY_HEIGHT})
      .align(Alignment.Top)
      .onDidScroll((_x : number,y : number) => {
        this.yOffset += y;
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    // .margin({ bottom: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 700 : 150 })
    .id('adjustSheetDialog')
  }
}