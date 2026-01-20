import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { PerDayInfo } from "../Model/PerDayInfo";
import { DayDataSource } from "../ViewModel/DataSource/DayDataSource";
import { DailyTaskList } from "./DailyTask/DailyTaskList";
import { TaskListGrid } from "./DailyTask/TaskListGrid";

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
          DayViewDetail({perDayInfo : item})
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

@Component
struct DailyTaskGrid{
  @Prop dayInfo: PerDayInfo;

  build() {
    Scroll(){
      TaskListGrid({
        year : this.dayInfo.getYear(),
        month : this.dayInfo.getMonth(),
        day : this.dayInfo.getDay(),
        isWeeklyTaskTableMode : false,
        isDailyTaskTableMode : true,
        totalTableWidth : 150
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.Top)
    .margin({bottom : 50})
  }
}

@Component
struct DayViewDetail{
  perDayInfo : PerDayInfo = new PerDayInfo();
  @State currentYear : number = this.perDayInfo.getYear();
  @State currentMonth : number = this.perDayInfo.getMonth();
  @State currentDay : number = this.perDayInfo.getDay();
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  aboutToAppear(): void {
    this.currentYear = this.perDayInfo.getYear();
    this.currentMonth = this.perDayInfo.getMonth();
    this.currentDay = this.perDayInfo.getDay();
    console.log(`数据为:${this.currentYear}-${this.currentMonth}-${this.currentDay}`);
  }
  build() {
    Row({space : 10}){
      Scroll(){
        TaskListGrid({
          year : this.currentYear,
          month : this.currentMonth,
          day : this.currentDay,
          isWeeklyTaskTableMode : false,
          isDailyTaskTableMode : true,
          totalTableWidth : 150
        })
      }
      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? '18.5%' : '30%')
      .height(BasicConstant.FULL_HEIGHT)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)
      .margin({bottom : 50})


      Scroll(){
        Column(){
          DailyTaskList({
            currentYear : this.currentYear,
            currentMonth : this.currentMonth,
            selectedDay : this.currentDay,
            isMonth : false,
            isDay : true
          })
        }
      }
      .height(BasicConstant.FULL_HEIGHT)
      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? '78%' : '67%')
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
      .align(Alignment.Top)

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
  }
}