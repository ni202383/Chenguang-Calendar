import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { PerDayInfo } from "../Model/PerDayInfo";
import { DayDataSource } from "../ViewModel/DataSource/DayDataSource";
import { DailyTaskList } from "./DailyTask/DailyTaskList";
import { TaskListGrid } from "./DailyTask/TaskListGrid";
import { router } from "@kit.ArkUI"; // [课程导入] 跳转至课表导入页。
import { TodayCourseList } from "./Course/CourseSection"; // [课程导入] 今日课程展示组件。
import { TodayExamList } from "./Exam/ExamSection"; // [考试导入] 今日考试展示组件。
import { currentDateDiff } from "../../Utils/ViewUtils";
import { courseStore } from "../Model/CourseStore"; // [当前周显示] 读取已导入课表对应的教学周。

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
  @StorageProp('isExportCourseSchedule') isExportCourseSchedule : boolean = false;
  @StorageProp('isExportExamSchedule') isExportExamSchedule : boolean = false;
  @StorageProp('themeColor') themeColor : string = '';

  aboutToAppear(): void {
    this.currentYear = this.perDayInfo.getYear();
    this.currentMonth = this.perDayInfo.getMonth();
    this.currentDay = this.perDayInfo.getDay();
    console.log(`数据为:${this.currentYear}-${this.currentMonth}-${this.currentDay}`);
  }

  // [当前周显示] 顶部课程区展示当前教学周，位置放在标题与重新导入按钮之间。
  private getCurrentCourseWeekText(): string {
    // [当前周显示] 按当前查看的日期动态计算，不再固定显示“今天所在周”。
    return courseStore.getAcademicWeekTextByDate(new Date(this.currentYear, this.currentMonth - 1, this.currentDay));
  }
  build() {
    Scroll(){
      Column(){
        // [课程导入] 在日视图顶部直接展示今日课程，并提供重新导入入口。
        Row() {
          Row() {
            Text(`${currentDateDiff(new Date(this.currentYear, this.currentMonth - 1, this.currentDay))}的课程`)
              .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 18 : 25)
              .fontWeight(FontWeight.Bold)
          }
          .width('33%')
          .justifyContent(FlexAlign.Start)

          Row() {
            if (this.isExportCourseSchedule && this.getCurrentCourseWeekText().length > 0) {
              Text(this.getCurrentCourseWeekText())
                .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 18 : 25)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeColor)
            }
          }
          .width('34%')
          .justifyContent(FlexAlign.Center)

          Row() {
            if (this.isExportCourseSchedule) {
              Button('重新导入')
                .type(ButtonType.Capsule)
                .backgroundColor(Color.White)
                .fontColor(this.themeColor)
                .border({ width: 1, color: this.themeColor, radius: 20 })
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({
                    url: 'pages/CourseImport'
                  }, router.RouterMode.Standard);
                })
            }
          }
          .width('33%')
          .justifyContent(FlexAlign.End)
        }
        .width(BasicConstant.FULL_WIDTH)

        Column({ space: 10 }) {
          if(!this.isExportCourseSchedule){
            Button('一键导入课程表（南信大）')
              .type(ButtonType.Capsule)
              .backgroundColor(this.themeColor)
              .foregroundColor(Color.White)
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/CourseImport'
                }, router.RouterMode.Standard);
              })
          } else {
            TodayCourseList({
              targetDate: new Date(this.currentYear, this.currentMonth - 1, this.currentDay)
            })
          }
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(!this.isExportCourseSchedule ? 100 : 'auto')
        .margin({top : 10,bottom : 10})
        .justifyContent(FlexAlign.Center)

        // [考试导入] 在课程列表下方、日程上方展示当天考试，并提供重新导入入口。
        // Row() {
        //   Row() {
        //     Text(`${currentDateDiff(new Date(this.currentYear, this.currentMonth - 1, this.currentDay))}的考试`)
        //       .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 18 : 25)
        //       .fontWeight(FontWeight.Bold)
        //   }
        //   .width('66%')
        //   .justifyContent(FlexAlign.Start)
        //
        //   Row() {
        //     if (this.isExportExamSchedule) {
        //       Button('重新导入')
        //         .type(ButtonType.Capsule)
        //         .backgroundColor(Color.White)
        //         .fontColor(this.themeColor)
        //         .border({ width: 1, color: this.themeColor, radius: 20 })
        //         .onClick(() => {
        //           this.getUIContext().getRouter().pushUrl({
        //             url: 'pages/ExamImport'
        //           }, router.RouterMode.Standard);
        //         })
        //     }
        //   }
        //   .width('34%')
        //   .justifyContent(FlexAlign.End)
        // }
        // .width(BasicConstant.FULL_WIDTH)
        //
        // Column({ space: 10 }) {
        //   if(!this.isExportExamSchedule){
        //     Button('一键导入考试安排（南信大）')
        //       .type(ButtonType.Capsule)
        //       .backgroundColor(this.themeColor)
        //       .foregroundColor(Color.White)
        //       .onClick(() => {
        //         this.getUIContext().getRouter().pushUrl({
        //           url: 'pages/ExamImport'
        //         }, router.RouterMode.Standard);
        //       })
        //   } else {
        //     TodayExamList({
        //       targetDate: new Date(this.currentYear, this.currentMonth - 1, this.currentDay)
        //     })
        //   }
        // }
        // .width(BasicConstant.FULL_WIDTH)
        // .height(!this.isExportExamSchedule ? 100 : 'auto')
        // .margin({top : 10,bottom : 10})
        // .justifyContent(FlexAlign.Center)

        Row({space : 20}){
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
      .width(BasicConstant.FULL_WIDTH)
      .alignItems(HorizontalAlign.Center)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .scrollable(ScrollDirection.Vertical)
    .edgeEffect(EdgeEffect.Spring)

  }
}