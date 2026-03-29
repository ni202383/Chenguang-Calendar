import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import {
  addTransparency,
  currentDateDiff,
  hexToRgb,
  number2CharacterInLunarMonth, number2characterInWeek } from "../../Utils/ViewUtils";
import { DailyInfo } from "../Model/DailyInfo";
import { PerMonthInfo } from "../Model/PerMonthInfo"
import { MonthDataSource } from "../ViewModel/DataSource/MonthDataSource";
import { router } from "@kit.ArkUI";
import { DailyTaskList } from "./DailyTask/DailyTaskList";
import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { SolarTermsDetailData } from "../../data/SolarTermsDetailData";
import { FestivalDetailData } from "../../data/FestivalDetailData";
import { TodayCourseList } from "./Course/CourseSection"; // [课程导入] 月视图中的课程列表组件。
import { TodayExamList } from "./Exam/ExamSection"; // [考试导入] 月视图中的考试列表组件。
import { courseStore } from "../Model/CourseStore"; // [当前周显示] 读取已导入课表对应的教学周。

@Extend(Circle) function allDayCircle(currentBreakpoint : string,themeColor : string){
  .width(
    currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_SM :
      currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_MD :
        ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_LG
  )
  .height(
    currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_SM :
      currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_MD :
        ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_LG
  )
  .stroke(themeColor)
  .fill(themeColor)
}

@Extend(Text) function allDayText(currentBreakpoint : string){
  .fontSize(
    currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_SM :
      currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_MD :
        ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_LG
  )
  .fontColor(Color.Black)
}

@Extend(Text) function festivalText(currentBreakpoint : string){
  .fontSize(
    currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_SM :
      currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_MD :
        ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_LG
  )
  .fontColor(Color.Black)
}

@Extend(Row) function festivalOrSolarTermRow(currentBreakpoint : string){
  .width(BasicConstant.FULL_WIDTH)
  .height(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
    ViewArkUIConstant.FESTIVAL_ROW_HEIGHT_LG : ViewArkUIConstant.FESTIVAL_ROW_HEIGHT_OTHER)
  .alignItems(VerticalAlign.Center)
  .borderRadius(ViewArkUIConstant.FESTIVAL_ROW_BORDER_RADIUS)
  .padding(ViewArkUIConstant.FESTIVAL_ROW_PADDING)
  .backgroundColor(Color.White)
}

@Extend(Column) function festivalOrSolarTermsDiff(currentBreakpoint : string){
  .width(BasicConstant.FULL_WIDTH)
  .height(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 70 : 60)
  .backgroundColor(Color.White)
  .borderRadius(20)
  .padding(15)
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Start)
}

@Extend(Text) function titleStyle(currentBreakpoint : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 18 : 25)
  .fontWeight(FontWeight.Bold)
}

@Component
export struct MonthViewDetail{
  perMonthInfo : PerMonthInfo = new PerMonthInfo();//传进来的每个月的数据对象
  @State currentYear: number = this.perMonthInfo.getYear();
  @State currentMonth: number = this.perMonthInfo.getMonth();
  @State @Watch('updateCurrentDailyInfo') selectedDay: number =
    this.currentYear == new Date().getFullYear() && this.currentMonth == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('themeColor') @Watch('themeColorChange') themeColor: string = '';
  @StorageProp('screenWidth') screenWidth: number = 200;
  @StorageProp('isSubscribe') isSubscribe: boolean = true;//是否订阅黄历
  @StorageProp('AlmanacYellow') AlmanacYellow: string = '#C28109';//黄历中的黄色
  @StorageProp('AlmanacRed') AlmanacRed: string = '#D31319';//黄历中的红色
  private viewSize: number = Math.floor((this.screenWidth - 30) / 7);//用于计算每个窗口中圆形框的尺寸
  private viewSizeHeightMD = this.viewSize / 2;
  private viewSizeHeightLG = this.viewSize / 2.5;
  private monthDataSource: MonthDataSource = new MonthDataSource(this.currentYear, this.currentMonth);
  @State currentDailyInfo: DailyInfo = this.monthDataSource.getData(6000).getMonthData()[0];
  private blackColorInOtherMonth: string = 'rgba(0,0,0,0.1)';
  private blackColorInWeekend: string = 'rgba(0,0,0,0.4)';
  private lunarTextColor = $r('app.color.gray_deeper');
  private lunarTextColorInOtherMonth = $r('app.string.gray_deeper_in_other_month')//不在本月份的农历字符串颜色
  private lunarTextColorInWeekend = $r('app.string.gray_deeper_in_weekend');//在本月周末的农历字符串颜色
  private themeColorInOtherMonth: string = 'rgba(234,92,46,0.1)';//给不在本月的主题颜色加上透明度
  private themeColorInWeekend: string = 'rgba(234,92,46,0.4)';//给本月周末的主题颜色加上透明度
  @State nearestFestivalDayDiff : number = 0;
  @Consume('currentIndexInMonthView') current_index : number;
  currentIndex: number = 6000;
  @StorageLink('isMoveToTargetDay') @Watch('moveToTargetDayFunction') isMoveToTargetDay : boolean = false;
  @StorageLink('isShowFestivalDetail') isShowFestivalDetail : boolean = false;
  @StorageLink('detailedFestivalName') detailedFestivalName : string = '';
  @StorageLink('isShowSolarTermsDetail') isShowSolarTermsDetail : boolean = false;
  @StorageLink('detailedSolarTermsName') detailedSolarTermsName : string = '';
  @StorageProp('isExportCourseSchedule') isExportCourseSchedule : boolean = false;
  @StorageProp('isExportExamSchedule') isExportExamSchedule : boolean = false;

  // [当前周显示] 顶部课程区展示当前教学周，位置放在标题与重新导入按钮之间。
  private getCurrentCourseWeekText(): string {
    // [当前周显示] 按当前选中的日期动态计算，切换月内日期后周数实时变化。
    return courseStore.getAcademicWeekTextByDate(new Date(this.currentYear, this.currentMonth - 1, this.selectedDay));
  }

  aboutToAppear(): void {
    this.currentYear = this.perMonthInfo.getYear();
    this.currentMonth = this.perMonthInfo.getMonth();
    this.selectedDay = this.perMonthInfo.getSelectedDay();
    for (let i = 0; i < this.perMonthInfo.getMonthData().length; ++i) {
      if (this.perMonthInfo.getMonthData()[i].getDay() === this.selectedDay) {
        this.currentDailyInfo = this.perMonthInfo.getMonthData()[i];
        break;
      }
    }
    this.themeColorChange();
  }

  moveToTargetDayFunction(){//用于从本月视图点击其他月份的GridItem是跳转到对应月份视图同时选中那一天
    this.selectedDay = AppStorage.get('moveToTargetDay') ?? this.selectedDay;
  }

  updateCurrentDailyInfo(): void {
    for (let i = 0; i < this.perMonthInfo.getMonthData().length; ++i) {
      let dailyInfo: DailyInfo = this.perMonthInfo.getMonthData()[i];
      if (dailyInfo.getYear() === this.currentYear && dailyInfo.getMonth() === this.currentMonth &&
        dailyInfo.getDay() === this.selectedDay) {
        this.currentDailyInfo = dailyInfo;
        break;
      }
    }
    this.currentYear = this.currentDailyInfo.getYear();
    this.currentMonth = this.currentDailyInfo.getMonth();
  }//更新当前选中的本月的那一天

  getLunarOrSolorItemOrFestival(dailyInfo: DailyInfo): string {
    if (dailyInfo.getFestival().length > 0) {
      return dailyInfo.getFestival()[0];
    } else if (dailyInfo.getSolarTerm() != '') {
      return dailyInfo.getSolarTerm();
    } else {
      return dailyInfo.getLunarDateText();
    }
  }

  themeColorType(dailyInfo: DailyInfo): string {
    if (!dailyInfo.getIsCurrentMonth()) return this.themeColorInOtherMonth; else if (dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX ||
      dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX) return this.themeColorInWeekend; else return this.themeColor;
  }

  themeColorChange(){
    let rgb : [number,number,number] = hexToRgb(this.themeColor);
    this.themeColorInWeekend = `rgba(${rgb[0]},${rgb[1]},${rgb[2]},0.4)`;
    this.themeColorInOtherMonth = `rgba(${rgb[0]},${rgb[1]},${rgb[2]},0.1)`;
  }

  lunarTextColorType(dailyInfo: DailyInfo) {
    if (!dailyInfo.getIsCurrentMonth()) return this.lunarTextColorInOtherMonth; else if (dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX ||
      dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX) return this.lunarTextColorInWeekend; else return this.lunarTextColor;
  }

  discoverNearestFestival() : [number,string[]] {
    let i = 0;
    for(;i < this.perMonthInfo.getMonthData().length;++i){
      let currentDay = this.perMonthInfo.getMonthData()[i];
      if(currentDay.getYear() === this.currentYear && currentDay.getMonth() === this.currentMonth &&
        currentDay.getDay() === this.selectedDay){
        break;
      }
    }
    let initialIndex = this.currentIndex;
    let k = 0;
    let cnt = 0;
    const maxIterations = 365; // 限制最大查找天数，避免无限循环
    
    while(cnt < maxIterations){
      const monthData = this.monthDataSource.getData(initialIndex + k)?.getMonthData();
      if (!monthData || i >= monthData.length) {
        break;
      }
      
      let dailyInfo = monthData[i];
      if(dailyInfo && dailyInfo.getFestival().length > 0){
        return [cnt,dailyInfo.getFestival()]
      } else {
        cnt++;
        if(i == monthData.length - 1){
          i = 0;
          k++;
        } else {
          i++;
        }
      }
    }
    return [999, []]; // 未找到时返回默认值
  }

  discoverNearestSolarTerms() : [number,string]{
    let i = 0;
    for(;i < this.perMonthInfo.getMonthData().length;++i){
      let currentDay = this.perMonthInfo.getMonthData()[i];
      if(currentDay.getYear() === this.currentYear && currentDay.getMonth() === this.currentMonth &&
        currentDay.getDay() === this.selectedDay){
        break;
      }
    }
    let initialIndex = this.currentIndex;
    let k = 0;
    let cnt = 0;
    const maxIterations = 365; // 限制最大查找天数，避免无限循环
    
    while(cnt < maxIterations){
      const monthData = this.monthDataSource.getData(initialIndex + k)?.getMonthData();
      if (!monthData || i >= monthData.length) {
        break;
      }
      
      let dailyInfo = monthData[i];
      if(dailyInfo && dailyInfo.getSolarTerm() != ''){
        return [cnt,dailyInfo.getSolarTerm()]
      } else {
        cnt++;
        if(i == monthData.length - 1){
          k++;
          i = 0;
        } else {
          i++;
        }
      }
    }
    return [999, '']; // 未找到时返回默认值
  }

  hasNearFestivalOrSolarTerms(){
    if((this.discoverNearestFestival()[0] != 0 && this.discoverNearestFestival()[0] <= 7) ||
      (this.discoverNearestSolarTerms()[0] != 0 && this.discoverNearestSolarTerms()[0] <= 7)){
      return true;
    }
    return false;
  }

  build() {
    Column({space : ViewArkUIConstant.COMPONENT_GAP_SPACE}) {
      Grid() {//本月视图
        ForEach(this.perMonthInfo.getMonthData(), (item: DailyInfo, index: number) => {
          GridItem() {
            Stack({ alignContent: Alignment.Center }) {
              if (item.getIsSelectedAndAddThemeBackgroundColor()) {//如果是今天的话，就是实心圆
                Circle()
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 5 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 5 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .fill(this.themeColor)
                  .stroke(this.themeColor)
                  .strokeWidth(ViewArkUIConstant.CIRCLE_STROKE_WIDTH)
              }

              if (item.getYear() == this.currentDailyInfo.getYear() &&//点击本月的某一天后圆形框转换到点击的那一天
                item.getMonth() == this.currentDailyInfo.getMonth() &&
                this.selectedDay == item.getDay()) {
                Circle()
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 5 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD:
                      this.viewSizeHeightLG)
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 5 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .fillOpacity(ViewArkUIConstant.CIRCLE_FILL_OPACITY)
                  .stroke(this.themeColor)
                  .strokeWidth(ViewArkUIConstant.CIRCLE_STROKE_WIDTH)
              }

              Column() {
                Text(item.getDay().toString())
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
                    ViewArkUIConstant.CALENDAR_VIEW_DAY_FONT_SIZE_LG :
                    ViewArkUIConstant.CALENDAR_VIEW_DAY_FONT_SIZE_OTHER)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(item.getIsSelectedAndAddThemeBackgroundColor() ? Color.White :
                    !item.getIsCurrentMonth() ? this.blackColorInOtherMonth :
                      item.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX ||
                        item.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX ? this.blackColorInWeekend : Color.Black)
                Text(`${this.getLunarOrSolorItemOrFestival(item)}`)
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
                    ViewArkUIConstant.CALENDAR_VIEW_LUNAR_TEXT_FONT_SIZE_LG :
                    ViewArkUIConstant.CALENDAR_VIEW_LUNAR_TEXT_FONT_SIZE_OTHER)
                  .fontColor(item.getIsSelectedAndAddThemeBackgroundColor() ? Color.White :
                    item.getFestival().length > 0 ? this.themeColorType(item) :
                      item.getSolarTerm() != '' ? this.themeColorType(item) :
                        this.lunarTextColorType(item))
                  .maxLines(ViewArkUIConstant.CALENDAR_VIEW_LUNAR_TEXT_MAX_LINES)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(BasicConstant.FULL_HEIGHT)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .gesture(GestureGroup(GestureMode.Exclusive,
                TapGesture({ count: ViewArkUIConstant.CALENDAR_VIEW_GRID_ITEM_CLICK_ONCE })
                  .onAction(() => {
                    this.getUIContext().animateTo({
                      curve : Curve.Smooth,
                      duration : BasicConstant.ANIMATION_DURATION_MEDIUM
                    },() => {
                      if (item.getYear() == this.currentYear && item.getMonth() == this.currentMonth) {
                        this.selectedDay = item.getDay();
                      } else {
                        const totalMonthInOtherMonth = item.getYear() * BasicConstant.MONTH_NUMBER_PER_YEAR + item.getMonth();
                        const totalMonthInCurrentMonth = new Date().getFullYear() *
                        BasicConstant.MONTH_NUMBER_PER_YEAR + new Date().getMonth() + 1;
                        const monthGap = totalMonthInOtherMonth - totalMonthInCurrentMonth;
                        this.current_index = this.monthDataSource.getInitialIndex() + monthGap;
                        AppStorage.setOrCreate('moveToTargetDay',item.getDay());
                        this.isMoveToTargetDay = !this.isMoveToTargetDay;
                      }
                    })

                  })
              ))
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(BasicConstant.FULL_HEIGHT)
          }
          .width(this.viewSize)
          .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize :
            this.viewSizeHeightMD)
        }, (item: DailyInfo) => `${item.getYear()}-${item.getMonth()}-${item.getDay()}`)
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')

      Row(){
        Row({ space: ViewArkUIConstant.DAY_DIFF_LUNAR_GAP_SPACE }) {
          Text(currentDateDiff(new Date(this.currentDailyInfo.getYear(), this.currentDailyInfo.getMonth() - 1, this.selectedDay)))
            .titleStyle(this.currentBreakpoint)
          if (this.currentDailyInfo.getLunarMonth() < 0) {
            Text(`农历闰${number2CharacterInLunarMonth[Math.abs(this.currentDailyInfo.getLunarMonth())]}月${this.currentDailyInfo.getLunarDateText()}`)
              .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.LUNAR_FONT_SIZE_SM : ViewArkUIConstant.LUNAR_FONT_SIZE_OTHER)
              .fontColor($r('app.color.gray_deeper'))
          } else {
            Text(`农历${number2CharacterInLunarMonth[this.currentDailyInfo.getLunarMonth()]}月${this.currentDailyInfo.getLunarDateText()}`)
              .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.LUNAR_FONT_SIZE_SM : ViewArkUIConstant.LUNAR_FONT_SIZE_OTHER)
              .fontColor($r('app.color.gray_deeper'))
          }
        }
        .height(BasicConstant.FULL_HEIGHT)
        .width('50%')
        .alignItems(VerticalAlign.Bottom)

        Row(){
          Text('我的倒计时')
            .fontSize(14)

          Image($r('app.media.right_arrow'))
            .height(18)
        }
        .width('30%')
        .height(BasicConstant.FULL_HEIGHT)
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Bottom)
        .onClick((event : ClickEvent) => {
          this.getUIContext().getRouter().pushUrl({
            url : 'pages/CountdownList'
          })
        })
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(30)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)


      if(this.currentDailyInfo.getSolarTerm() != ''){
        Row({space : ViewArkUIConstant.FESTIVAL_ROW_GAP_SPACE}){
          Column({space : ViewArkUIConstant.FESTIVAL_ROW_COLUMN_SPACE}){
            Circle()
              .allDayCircle(this.currentBreakpoint,this.themeColor)

            Text('全天')
              .allDayText(this.currentBreakpoint)
          }
          Text(this.currentDailyInfo.getSolarTerm())
            .festivalText(this.currentBreakpoint)
        }
        .festivalOrSolarTermRow(this.currentBreakpoint)
        .geometryTransition('showSolarTermsDetail')
        .onClick((event : ClickEvent) => {
          this.getUIContext().animateTo({
            curve : Curve.EaseInOut,
            duration : 300
          },() => {
            if(SolarTermsDetailData[this.currentDailyInfo.getSolarTerm()] != undefined){
              this.isShowSolarTermsDetail = !this.isShowSolarTermsDetail;
              this.detailedSolarTermsName = this.currentDailyInfo.getSolarTerm();
            }
          })
        })
        .clickEffect({
          level : ClickEffectLevel.LIGHT,
          scale : 0.8
        })
      }

      if(this.currentDailyInfo.getFestival().length > 0){
        Column({space : 10}){
          ForEach(this.currentDailyInfo.getFestival(),(item : string,index : number) => {
            Row({space : ViewArkUIConstant.FESTIVAL_ROW_GAP_SPACE}){
              Column({space : ViewArkUIConstant.FESTIVAL_ROW_COLUMN_SPACE}){
                Circle()
                  .allDayCircle(this.currentBreakpoint,this.themeColor)

                Text('全天')
                  .allDayText(this.currentBreakpoint)
              }
              Text(item)
                .festivalText(this.currentBreakpoint)

            }
            .festivalOrSolarTermRow(this.currentBreakpoint)
            .onClick((event : ClickEvent) => {
              this.getUIContext().animateTo({
                curve : Curve.EaseInOut,
                duration : 300
              },() => {
                if(FestivalDetailData[item] != undefined){
                  this.isShowFestivalDetail = !this.isShowFestivalDetail;
                  this.detailedFestivalName = item;
                }
              })
            })
            .geometryTransition('showFestivalDetail')
            .clickEffect({
              level : ClickEffectLevel.LIGHT,
              scale : 0.8
            })
          },(item : string) => item)
        }
      }


      List({space : 10}){
        if(this.hasNearFestivalOrSolarTerms()){
          ListItem(){
            Column({space : 10}){
              if(this.discoverNearestFestival()[0] != 0 && this.discoverNearestFestival()[0] <= 7){
                Text('节日预告')
                  .titleStyle(this.currentBreakpoint)

                Column(){
                  Text(){
                    Span('距离')
                    Span(this.discoverNearestFestival()[1].toString())
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.themeColor)
                    Span('仅剩')
                    Span(this.discoverNearestFestival()[0].toString())
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.themeColor)
                    Span('天')
                  }
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 15 : 20)
                }
                .festivalOrSolarTermsDiff(this.currentBreakpoint)
                .onClick((event : ClickEvent) => {
                  this.getUIContext().animateTo({
                    curve : Curve.EaseInOut,
                    duration : 300
                  },() => {
                    if(FestivalDetailData[this.discoverNearestFestival()[1][0]] != undefined){
                      this.isShowFestivalDetail = !this.isShowFestivalDetail;
                      this.detailedFestivalName = this.discoverNearestFestival()[1][0];
                    }
                  })
                })
                .geometryTransition('showFestivalDetail')
                .clickEffect({
                  level : ClickEffectLevel.LIGHT,
                  scale : 0.8
                })
              }

              if(this.discoverNearestSolarTerms()[0] != 0 && this.discoverNearestSolarTerms()[0] <= 7){
                Text('节气预告')
                  .titleStyle(this.currentBreakpoint)

                Column(){
                  Text(){
                    Span('距离节气：')
                    Span(this.discoverNearestSolarTerms()[1])
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.themeColor)
                    Span('还剩')
                    Span(this.discoverNearestSolarTerms()[0].toString())
                      .fontWeight(FontWeight.Bold)
                      .fontColor(this.themeColor)
                    Span('天')
                  }
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 15 : 20)
                }
                .festivalOrSolarTermsDiff(this.currentBreakpoint)
                .onClick((event : ClickEvent) => {
                  this.getUIContext().animateTo({
                    curve : Curve.EaseInOut,
                    duration : 300
                  },() => {
                    if(SolarTermsDetailData[this.discoverNearestSolarTerms()[1]] != undefined){
                      this.isShowSolarTermsDetail = !this.isShowSolarTermsDetail;
                      this.detailedSolarTermsName = this.discoverNearestSolarTerms()[1];
                    }
                  })
                })
                .geometryTransition('showSolarTermsDetail')
                .clickEffect({
                  level : ClickEffectLevel.LIGHT,
                  scale : 0.8
                })
              }
            }
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Start)
            .width(BasicConstant.FULL_WIDTH)
          }
          .width('97%')
        }

        ListItem(){
          if (this.isSubscribe) {
            Column({ space: ViewArkUIConstant.ALMANAC_COLUMN_GAP_SPACE }) {
              Row() {
                Column({ space: ViewArkUIConstant.ALMANAC_BASIC_INFO_GAP_SPACE }) {
                  Text(`${this.currentDailyInfo.getMonth()}月${this.currentDailyInfo.getDay()}日 星期${number2characterInWeek[this.currentDailyInfo.getWeek()]}`)
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                      ViewArkUIConstant.ALMANAC_BASIC_SOLAR_INFO_FONT_SIZE_SM :
                      ViewArkUIConstant.ALMANAC_BASIC_SOLAR_INFO_FONT_SIZE_OTHER)
                    .fontColor(Color.Black)
                  if (this.currentDailyInfo.getLunarMonth() < 0) {
                    Text(`闰${number2CharacterInLunarMonth[Math.abs(this.currentDailyInfo.getLunarMonth())]}月${this.currentDailyInfo.getLunarDateText()}`)
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_BASIC_LUNAR_TEXT_FONT_SIZE_SM :
                        ViewArkUIConstant.ALMANAC_BASIC_LUNAR_TEXT_FONT_SIZE_OTHER)
                      .fontColor(this.themeColor)
                      .fontWeight(FontWeight.Bold)
                  } else {
                    Text(`${number2CharacterInLunarMonth[this.currentDailyInfo.getLunarMonth()]}月${this.currentDailyInfo.getLunarDateText()}`)
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_BASIC_LUNAR_TEXT_FONT_SIZE_SM :
                        ViewArkUIConstant.ALMANAC_BASIC_LUNAR_TEXT_FONT_SIZE_OTHER)
                      .fontColor(this.themeColor)
                      .fontWeight(FontWeight.Bold)
                  }
                }
                .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.ALMANAC_BASIC_INFO_HEIGHT_SM : ViewArkUIConstant.ALMANAC_BASIC_INFO_HEIGHT_OTHER)
                .alignItems(HorizontalAlign.Start)

                Column({ space: ViewArkUIConstant.ALMANAC_GAN_ZHI_GAP_SPACE }) {
                  Column() {
                    Text('农历')
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_FONT_SIZE_SM :
                        ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_FONT_SIZE_OTHER)
                      .fontColor(this.themeColor)
                      .fontWeight(FontWeight.Medium)
                  }
                  .justifyContent(FlexAlign.Center)
                  .alignItems(HorizontalAlign.Center)
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_WIDTH_SM : ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_WIDTH_OTHER)
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_HEIGHT_SM: ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_HEIGHT_OTHER)
                  .borderRadius(ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_BORDER_RADIUS)
                  .backgroundColor(addTransparency(hexToRgb(this.themeColor),
                    ViewArkUIConstant.ALMANAC_GAN_ZHI_LUNAR_TRANSPARENCY))

                  Text(`${this.currentDailyInfo.getOrdinaryAlmanacOfDay()
                    .getMonthInGanZhi()}月 ${this.currentDailyInfo.getOrdinaryAlmanacOfDay()?.getDayInGanZhi()}日`)
                    .fontColor($r('app.color.gray_deeper'))
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                      ViewArkUIConstant.ALMANAC_GAN_ZHI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_GAN_ZHI_TEXT_FONT_SIZE_OTHER)
                  Text(`${this.currentDailyInfo.getOrdinaryAlmanacOfDay()
                    .getYearInGanZhi()}年[${this.currentDailyInfo.getOrdinaryAlmanacOfDay()?.getYearInShengXiao()}]`)
                    .fontColor($r('app.color.gray_deeper'))
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                      ViewArkUIConstant.ALMANAC_GAN_ZHI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_GAN_ZHI_TEXT_FONT_SIZE_OTHER)
                }
                .alignItems(HorizontalAlign.End)
                .height(ViewArkUIConstant.ALMANAC_GAN_ZHI_INFO_HEIGHT)
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.ALMANAC_TOP_HEIGHT_SM : ViewArkUIConstant.ALMANAC_TOP_HEIGHT_OTHER)
              .justifyContent(FlexAlign.SpaceBetween)
              .alignItems(VerticalAlign.Top)

              Row() {
                Column() {
                  Row({ space: ViewArkUIConstant.ALMANAC_YI_JI_GAP_SPACE }) {
                    Stack() {
                      Column()
                        .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_SM :
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
                        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_SM :
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
                        .backgroundColor(this.AlmanacYellow)
                        .borderRadius(ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_BORDER_RADIUS)
                      Text('宜')
                        .fontColor(Color.White)
                        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_YI_JI_FONT_SIZE_OTHER)
                    }

                    Text(this.currentDailyInfo.getOrdinaryAlmanacOfDay().getYi())
                      .fontColor(this.AlmanacYellow)
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_YI_JI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_YI_JI_TEXT_FONT_SIZE_OTHER)
                      .maxLines(ViewArkUIConstant.ALMANAC_YI_JI_TEXT_MAX_LINES)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width(BasicConstant.FULL_WIDTH)
                  .height(BasicConstant.HALF_HEIGHT)
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center)

                  Row({ space: ViewArkUIConstant.ALMANAC_YI_JI_GAP_SPACE }) {
                    Stack() {
                      Column()
                        .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_SM :
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
                        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_SM :
                          ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
                        .backgroundColor(this.AlmanacRed)
                        .borderRadius(ViewArkUIConstant.ALMANAC_YI_JI_SQUARE_BORDER_RADIUS)
                      Text('忌')
                        .fontColor(Color.White)
                        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.ALMANAC_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_YI_JI_FONT_SIZE_OTHER)
                    }

                    Text(this.currentDailyInfo.getOrdinaryAlmanacOfDay().getJi())
                      .fontColor($r('app.color.gray_deeper'))
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_YI_JI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_YI_JI_TEXT_FONT_SIZE_OTHER)
                      .maxLines(ViewArkUIConstant.ALMANAC_YI_JI_TEXT_MAX_LINES)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .width(BasicConstant.FULL_WIDTH)
                  .height(BasicConstant.HALF_HEIGHT)
                  .alignItems(VerticalAlign.Center)
                  .justifyContent(FlexAlign.Start)
                }
                .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.ALMANAC_YI_JI_WHOLE_WIDTH_PERCENTAGE_SM :
                  ViewArkUIConstant.ALMANAC_YI_JI_WHOLE_WIDTH_PERCENTAGE_OTHER)
                .height(BasicConstant.FULL_HEIGHT)

                Column() {
                  Button('查看详情')
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                      ViewArkUIConstant.ALMANAC_VIEW_DETAIL_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_VIEW_DETAIL_FONT_SIZE_OTHER)
                    .width(ViewArkUIConstant.ALMANAC_VIEW_DETAIL_BUTTON_WIDTH_PERCENTAGE)
                    .height(ViewArkUIConstant.ALMANAC_VIEW_DETAIL_BUTTON_HEIGHT_PERCENTAGE)
                    .backgroundColor(this.themeColor)
                    .onClick((event: ClickEvent) => {
                      this.getUIContext().getRouter().pushUrl({
                        url: 'pages/AlmanacAllData',
                        params: {
                          currentYear: this.currentYear,
                          currentMonth: this.currentMonth,
                          currentDay: this.currentDailyInfo.getDay(),
                          currentWeek: this.currentDailyInfo.getWeek(),
                          currentLunarText: this.currentDailyInfo.getLunarDateText()
                        }
                      }, router.RouterMode.Standard, (error) => {
                        if (error) {
                          console.log(`error message : ${error.message}`)
                        }
                      })
                    })
                    .clickEffect({
                      level : ClickEffectLevel.LIGHT,
                    })
                }
                .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.ALMANAC_VIEW_DETAIL_BUTTON_COLUMN_WIDTH_PERCENTAGE_SM :
                  ViewArkUIConstant.ALMANAC_VIEW_DETAIL_BUTTON_COLUMN_WIDTH_PERCENTAGE_OTHER)
                .height(BasicConstant.FULL_HEIGHT)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.End)
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.ALMANAC_BOTTOM_ROW_HEIGHT_SM : ViewArkUIConstant.ALMANAC_BOTTOM_ROW_HEIGHT_OTHER)
              .justifyContent(FlexAlign.Start)
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
              ViewArkUIConstant.ALMANAC_HEIGHT_SM : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
                ViewArkUIConstant.ALMANAC_HEIGHT_OTHER : 240)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(Color.White)
            .borderRadius(ViewArkUIConstant.ALMANAC_BORDER_RADIUS)
            .padding(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
              ViewArkUIConstant.ALMANAC_PADDING_SM : ViewArkUIConstant.ALMANAC_PADDING_OTHER)
          }
        }
        .width('97%')
      }
      .lanes(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG && this.hasNearFestivalOrSolarTerms() ? 2 : 1)
      .alignListItem(ListItemAlign.Start)

      // [课程导入] 月视图顶部展示当前选中日期的课程，并保留重新导入入口。
      Row() {
        Row() {
          Text(`${currentDateDiff(new Date(this.currentDailyInfo.getYear(), this.currentDailyInfo.getMonth() - 1,
            this.selectedDay))}的课程`)
            .titleStyle(this.currentBreakpoint)
        }
        .width('33%')
        .justifyContent(FlexAlign.Start)

        Row() {
          if (this.isExportCourseSchedule && this.getCurrentCourseWeekText().length > 0) {
            Text(this.getCurrentCourseWeekText())
              .titleStyle(this.currentBreakpoint)
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
                }, router.RouterMode.Standard,(err) => {
                  console.log('error')
                })
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
              }, router.RouterMode.Standard)
            })
        } else {
          TodayCourseList({
            targetDate: new Date(this.currentYear, this.currentMonth - 1, this.selectedDay)
          })
        }
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(!this.isExportCourseSchedule ? 100 : 'auto')
      .justifyContent(FlexAlign.Center)

      // [考试导入] 月视图在课程列表下方展示所选日期的考试安排。
      // Row() {
      //   Row() {
      //     Text(`${currentDateDiff(new Date(this.currentDailyInfo.getYear(), this.currentDailyInfo.getMonth() - 1,
      //       this.selectedDay))}的考试`)
      //       .titleStyle(this.currentBreakpoint)
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
      //           }, router.RouterMode.Standard,(err) => {
      //             console.log('error')
      //           })
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
      //         }, router.RouterMode.Standard)
      //       })
      //   } else {
      //     TodayExamList({
      //       targetDate: new Date(this.currentYear, this.currentMonth - 1, this.selectedDay)
      //     })
      //   }
      // }
      // .width(BasicConstant.FULL_WIDTH)
      // .height(!this.isExportExamSchedule ? 100 : 'auto')
      // .justifyContent(FlexAlign.Center)

      Text(`${currentDateDiff(new Date(this.currentDailyInfo.getYear(), this.currentDailyInfo.getMonth() - 1,
        this.selectedDay))}的日程`)
        .titleStyle(this.currentBreakpoint)
      DailyTaskList({
        currentYear: this.currentYear,
        currentMonth: this.currentMonth,
        selectedDay: this.selectedDay,
        isMonth : true,
        isDay : false
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}