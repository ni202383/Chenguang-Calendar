import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { PerDayInfo } from "../Model/PerDayInfo";
import { DayDataSource } from "../ViewModel/DataSource/DayDataSource";
import { DailyTaskList } from "./DailyTask/DailyTaskList";

@Component
export struct DayView {
  @Consume('currentYearInDayView') currentYear: number = new Date().getFullYear();
  @Consume('currentMonthInDayView') currentMonth: number = new Date().getMonth() + 1;
  @Consume('currentDayInDayView') currentDay: number = new Date().getDate();
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  private dayDataSource: DayDataSource = new DayDataSource(this.currentYear, this.currentMonth, this.currentDay)
  private swiperController : SwiperController = new SwiperController();
  @Link @Watch('ChangeToSpecifiedIndex') currentIndex: number;
  private preIndex : number = this.dayDataSource.getInitialIndex();

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

  build() {
    Column() {
      Swiper(this.swiperController) {
        LazyForEach(this.dayDataSource, (item: PerDayInfo) => {
          Scroll() {
            Column(){
              DailyTaskList({
                currentYear: this.currentYear,
                currentMonth: this.currentMonth,
                selectedDay: this.currentDay,
                task: item.getTask()
              })
            }
            .width(BasicConstant.FULL_WIDTH)
            .justifyContent(FlexAlign.Start)
            .margin({bottom : ViewArkUIConstant.DAY_VIEW_MARGIN_BOTTOM})

          }
          .width(BasicConstant.FULL_WIDTH)
          .height(BasicConstant.FULL_HEIGHT)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Auto)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.Top)

        }, (item: PerDayInfo) => `${item.getYear()}-${item.getMonth()}-${item.getDay()}`)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .autoPlay(ViewArkUIConstant.SWIPER_IS_AUTOPLAY)
      .loop(ViewArkUIConstant.SWIPER_IS_LOOP)
      .indicator(ViewArkUIConstant.SWIPER_IS_INDICATOR)
      .index(this.dayDataSource.getInitialIndex())
      .itemSpace(ViewArkUIConstant.SWIPER_ITEM_SPACE)
      .onAnimationStart((fromIndex : number,toIndex : number) => {
        const dayInfo = this.dayDataSource.getData(toIndex);
        this.currentYear = dayInfo.getYear();
        this.currentMonth = dayInfo.getMonth();
        this.currentDay = dayInfo.getDay();
        this.currentIndex = toIndex;
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .id('adjustSheetDialog')
  }
}