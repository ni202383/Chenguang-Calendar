import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { addTransparency,
  currentDateDiff,
  hexToRgb, number2CharacterInLunarMonth, number2characterInWeek } from "../../Utils/ViewUtils";
import { DailyInfo } from "../Model/DailyInfo";
import { PerWeekInfo } from "../Model/PerWeekInfo";
import { WeekDataSource } from "../ViewModel/DataSource/WeekDataSource";
import { router } from "@kit.ArkUI";
import { DailyTaskList } from "./DailyTask/DailyTaskList";
import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";

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

  build() {
    Column({space : ViewArkUIConstant.COMPONENT_GAP_SPACE}){
      Grid() {
        ForEach(this.perWeekInfo.getWeekData(), (item: DailyInfo, index: number) => {
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

      if(this.currentDailyInfo.getFestival().length > 0){
        Row({space : ViewArkUIConstant.FESTIVAL_ROW_GAP_SPACE}){
          Column({space : ViewArkUIConstant.FESTIVAL_ROW_COLUMN_SPACE}){
            Circle()
              .width(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_SM :
                  this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_MD :
                    ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_WIDTH_LG
              )
              .height(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_SM :
                  this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_MD :
                    ViewArkUIConstant.FESTIVAL_ROW_COLUMN_CIRCLE_HEIGHT_LG
              )
              .stroke(this.themeColor)
              .fill(this.themeColor)

            Text(`全天`)
              .fontSize(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_SM :
                  this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_MD :
                    ViewArkUIConstant.FESTIVAL_ROW_COLUMN_TEXT_FONT_SIZE_LG
              )
              .fontColor(Color.Black)

          }
          // .width(30)

          ForEach(this.currentDailyInfo.getFestival(),(item : string) => {
            Text(item)
              .fontSize(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_SM :
                  this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_MD :
                    ViewArkUIConstant.FESTIVAL_ROW_TEXT_FONT_SIZE_LG
              )
              .fontColor(Color.Black)

          },(item : string) => item)
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          ViewArkUIConstant.FESTIVAL_ROW_HEIGHT_LG : ViewArkUIConstant.FESTIVAL_ROW_HEIGHT_OTHER)
        .alignItems(VerticalAlign.Center)
        .borderRadius(ViewArkUIConstant.FESTIVAL_ROW_BORDER_RADIUS)
        .padding(ViewArkUIConstant.FESTIVAL_ROW_PADDING)
        .backgroundColor(Color.White)

      }

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
          ViewArkUIConstant.ALMANAC_HEIGHT_SM : ViewArkUIConstant.ALMANAC_HEIGHT_OTHER)
        .backgroundColor(Color.White)
        .borderRadius(ViewArkUIConstant.ALMANAC_BORDER_RADIUS)
        .padding(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          ViewArkUIConstant.ALMANAC_PADDING_SM : ViewArkUIConstant.ALMANAC_PADDING_OTHER)
      }

      Text('日程')
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          ViewArkUIConstant.DAILY_SCHEDULE_TITLE_FONT_SIZE_SM : ViewArkUIConstant.DAILY_SCHEDULE_TITLE_FONT_SIZE_OTHER)
        .fontWeight(FontWeight.Bold)
      DailyTaskList({
        currentYear : this.currentYear,
        currentMonth : this.currentMonth,
        selectedDay : this.selectedDay,
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
  }
}