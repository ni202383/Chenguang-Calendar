import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import {currentDateDiff, hexToRgb, number2CharacterInLunarMonth, number2characterInWeek } from "../../Utils/ViewUtils";
import { DailyInfo } from "../Model/DailyInfo";
import { PerWeekInfo } from "../Model/PerWeekInfo";
import { WeekDataSource } from "../ViewModel/DataSource/WeekDataSource";
import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { Festival_SolarTerms } from "../Model/Festival_SolarTerms";
import { TaskListGrid } from "./DailyTask/TaskListGrid";

@Extend(ListItem) function ListItemStyle() {
  .height(100)
  .width('98%')
  .padding(10)
  .backgroundColor(Color.White)
  .borderRadius(15)
}

@Component
export struct WeekViewDetail{
  perWeekInfo : PerWeekInfo = new PerWeekInfo();
  @State currentYear : number = this.perWeekInfo.getYear();
  @State currentMonth : number = this.perWeekInfo.getMonth();
  @State @Watch('updateCurrentDailyInfo') selectedDay : number = this.currentYear ==
  new Date().getFullYear() && this.currentMonth == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('screenWidth') screenWidth: number = 200;
  @StorageProp('isSubscribe') isSubscribe: boolean = true;
  @StorageProp('themeColor') @Watch('themeColorChange') themeColor : string = '';
  private blackColorInOtherMonth: string = 'rgba(0,0,0,0.1)';
  private blackColorInWeekend: string = 'rgba(0,0,0,0.4)';
  private lunarTextColor = $r('app.color.gray_deeper');
  private lunarTextColorInOtherMonth = $r('app.string.gray_deeper_in_other_month')
  private lunarTextColorInWeekend = $r('app.string.gray_deeper_in_weekend');
  private viewSize: number = Math.floor((this.screenWidth - 30) / 7);
  private viewSizeHeightMD = this.viewSize / 2;
  private viewSizeHeightLG = this.viewSize / 2.5;
  @State themeColorInOtherMonth: string = 'rgba(234,92,46,0.1)';
  @State themeColorInWeekend: string = 'rgba(234,92,46,0.4)';
  @StorageProp('AlmanacYellow') AlmanacYellow : string = '#C28109';
  @StorageProp('AlmanacRed') AlmanacRed : string = '#D31319';
  private weekDataSource : WeekDataSource = new WeekDataSource(this.currentYear,this.currentMonth,this.selectedDay)
  @State currentDailyInfo : DailyInfo = this.weekDataSource.getData(24000).getWeekData()[0];
  private festivalList : Array<Festival_SolarTerms> = [];
  private solarTermsList : Array<Festival_SolarTerms> = [];

  aboutToAppear(): void {
    this.currentYear = this.perWeekInfo.getYear();
    this.currentMonth = this.perWeekInfo.getMonth();
    this.selectedDay = this.perWeekInfo.getSelectedDay();
    for (let i = 0; i < this.perWeekInfo.getWeekData().length; ++i) {
      if (this.perWeekInfo.getWeekData()[i].getDay() === this.selectedDay) {
        this.currentDailyInfo = this.perWeekInfo.getWeekData()[i];
        break;
      }
    }
    this.themeColorChange();
    this.discoverAllFestivalThisWeek();
    this.discoverAllSolarTermsThisWeek();
  }

  discoverAllFestivalThisWeek(){
    this.festivalList = [];
    for(const dailyInfo of this.perWeekInfo.getWeekData()){
      if(dailyInfo.getFestival().length > 0){
        for(const festival of dailyInfo.getFestival()){
          this.festivalList.push(new Festival_SolarTerms(
            festival,
            `${dailyInfo.getYear()}年${dailyInfo.getMonth()}月${dailyInfo.getDay()}日`,
            `周${number2characterInWeek[dailyInfo.getWeek()]}`
          ))
        }
      }
    }
  }

  discoverAllSolarTermsThisWeek(){
    this.solarTermsList = [];
    for(const dailyInfo of this.perWeekInfo.getWeekData()){
      if(dailyInfo.getSolarTerm() != ''){
        this.solarTermsList.push(new Festival_SolarTerms(
          dailyInfo.getSolarTerm(),
          `${dailyInfo.getYear()}年${dailyInfo.getMonth()}月${dailyInfo.getDay()}日`,
          `周${number2characterInWeek[dailyInfo.getWeek()]}`
        ))
      }
    }
  }

  updateCurrentDailyInfo(): void {
    for (let i = 0; i < this.perWeekInfo.getWeekData().length; ++i) {
      let dailyInfo: DailyInfo = this.perWeekInfo.getWeekData()[i];
      if (dailyInfo.getYear() === this.currentYear && dailyInfo.getMonth() === this.currentMonth &&
        dailyInfo.getDay() === this.selectedDay) {
        this.currentDailyInfo = dailyInfo;
        break;
      }
    }
    this.currentYear = this.currentDailyInfo.getYear();
    this.currentMonth = this.currentDailyInfo.getMonth();
  }

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
    if (!dailyInfo.getIsCurrentMonth()) return this.themeColorInOtherMonth; else if (dailyInfo.getWeek() == 0 ||
      dailyInfo.getWeek() == 6) return this.themeColorInWeekend; else return this.themeColor;
  }

  themeColorChange(){
    let rgb : [number,number,number] = hexToRgb(this.themeColor);
    this.themeColorInWeekend = `rgba(${rgb[0]},${rgb[1]},${rgb[2]},0.4)`;
    this.themeColorInOtherMonth = `rgba(${rgb[0]},${rgb[1]},${rgb[2]},0.1)`;
  }

  lunarTextColorType(dailyInfo: DailyInfo) {
    if (!dailyInfo.getIsCurrentMonth()) return this.lunarTextColorInOtherMonth; else if (dailyInfo.getWeek() == 0 ||
      dailyInfo.getWeek() == 6) return this.lunarTextColorInWeekend; else return this.lunarTextColor;
  }

  @Builder noFestival_SolarTerms(text : string){
    Column(){
      Text(text)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 14 : 18)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder haveFestival_SolarTerms(list : Array<Festival_SolarTerms>){
    List({space : 5}){
      ForEach(list,(item : Festival_SolarTerms,index : number) => {
        ListItem(){
          Text(`${index + 1}.${item.name} ${item.date} ${item.week}`)
            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 14 : 18)
        }
      },(item : Festival_SolarTerms) => item.name)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .lanes(1)
    .divider({strokeWidth : 1})
  }

  build() {
    Column({space : ViewArkUIConstant.COMPONENT_GAP_SPACE}){
      Grid() {
        ForEach(this.perWeekInfo.getWeekData(), (item: DailyInfo) => {
          GridItem() {
            Stack({ alignContent: Alignment.Center }) {
              if (item.getIsSelectedAndAddThemeBackgroundColor()) {
                Circle()
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 2 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 2 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .fill(this.themeColor)
                  .stroke(this.themeColor)
                  .strokeWidth(ViewArkUIConstant.CIRCLE_STROKE_WIDTH)
              }

              if (item.getYear() == this.currentDailyInfo.getYear() &&
                item.getMonth() == this.currentDailyInfo.getMonth() &&
                this.selectedDay == item.getDay()) {
                Circle()
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 2 :
                    this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? this.viewSizeHeightMD :
                      this.viewSizeHeightLG)
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize - 2 :
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
                    if (item.getYear() == this.currentYear && item.getMonth() == this.currentMonth) {
                      this.getUIContext().animateTo({
                        curve : Curve.Smooth,
                        duration : BasicConstant.ANIMATION_DURATION_MEDIUM
                      },() => {
                        this.selectedDay = item.getDay();
                      })
                    }
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
      .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? this.viewSize :
        this.viewSizeHeightMD)

      Row({ space: ViewArkUIConstant.DAY_DIFF_LUNAR_GAP_SPACE }) {
        Text(currentDateDiff(new Date(this.currentDailyInfo.getYear(), this.currentDailyInfo.getMonth() - 1, this.selectedDay)))
          .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
            ViewArkUIConstant.DAY_DIFF_FONT_SIZE_SM : ViewArkUIConstant.DAY_DIFF_FONT_SIZE_OTHER)
          .fontWeight(FontWeight.Bold)
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
      .height(ViewArkUIConstant.DAY_DIFF_LUNAR_HEIGHT)
      .width(BasicConstant.FULL_WIDTH)
      .alignItems(VerticalAlign.Bottom)

      Text('本周节日和节气汇总')
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 18 : 25)
        .fontWeight(FontWeight.Bold)

      List({space : 10}){
        ListItem(){
          if(this.festivalList.length == 0){
            this.noFestival_SolarTerms('本周无主要节日')
          } else {
            this.haveFestival_SolarTerms(this.festivalList)
          }
        }
        .ListItemStyle()

        ListItem(){
          if(this.solarTermsList.length == 0){
            this.noFestival_SolarTerms('本周无主要节气')
          } else {
            this.haveFestival_SolarTerms(this.solarTermsList)
          }
        }
        .ListItemStyle()

      }
      .lanes(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 1 : 2)

      Text('本周日程')
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          ViewArkUIConstant.DAILY_SCHEDULE_TITLE_FONT_SIZE_SM : ViewArkUIConstant.DAILY_SCHEDULE_TITLE_FONT_SIZE_OTHER)
        .fontWeight(FontWeight.Bold)

      TaskListGrid({
        year : this.currentYear,
        month : this.currentMonth,
        day : this.selectedDay,
        isWeeklyTaskTableMode : true,
        isDailyTaskTableMode : false,
        totalTableWidth : this.screenWidth - (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 94 : 109),
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}