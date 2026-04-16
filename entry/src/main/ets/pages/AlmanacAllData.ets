import { BasicConstant } from '../Constants/BasicConstant'
import { ordinaryAlmanacOfDay } from './Model/LunarCalendar'
import { number2characterInWeek, number2CharacterInLunarMonth } from '../Utils/ViewUtils'
import { fetchOrdinaryAlmanacData } from './ViewModel/OrdinaryAlmanacData';
import { BreakpointConstant } from '../Constants/BreakpointConstant'
import { AlmanacOfCurrentDay } from './View/Almanac/AlmanacOfCurrentDay'
import { AlmanacOfCurrentTimeInCurrentDay } from './View/Almanac/AlmanacOfCurrentTimeInCurrentDay'
import { ViewArkUIConstant } from '../Constants/ArkUIConstant';
import { ButtonModifier } from './Model/AttributeModifier';

@Extend(Column) function YiJiSquareStyle(currentBreakpoint : string,backgroundColor : string){
  .width(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_SQUARE_WIDTH_HEIGHT_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
  .height(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_SQUARE_WIDTH_HEIGHT_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
  .backgroundColor(backgroundColor)
  .borderRadius(ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_SQUARE_BORDER_RADIUS)
}

@Extend(Text) function YiJiTextStyle(currentBreakpoint : string,fontColor : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_TEXT_FONT_SIZE_OTHER)
  .fontColor(fontColor)
  .fontWeight(FontWeight.Medium)
  .width(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_TEXT_WIDTH_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_TEXT_WIDTH_OTHER)
}

@Entry
@Component
struct AlmanacAllData {
  private currentYear: number = new Date().getFullYear();
  private currentMonth: number = new Date().getMonth() + 1;
  private currentDay: number = new Date().getDate();
  private currentWeek: number = 1;
  private currentOrdinaryAlmanacOfDay: ordinaryAlmanacOfDay = new ordinaryAlmanacOfDay();
  private currentLunarText: string = '';
  @StorageProp('AlmanacYellow') almanacYellow: string = '';
  @StorageProp('AlmanacRed') almanacRed: string = '#D31319';
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp('windowLeftGap') windowLeftGap: number = 0;
  @StorageProp('windowRightGap') windowRightGap: number = 0;
  @StorageProp('bottomStatusBarHeight') bottomStatusBarHeight: number = 0;

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as Record<string, number | string>
    this.currentYear = params['currentYear'] as number;
    this.currentMonth = params['currentMonth'] as number;
    this.currentDay = params['currentDay'] as number;
    this.currentWeek = params['currentWeek'] as number;
    this.currentLunarText = params['currentLunarText'] as string;
    this.currentOrdinaryAlmanacOfDay = fetchOrdinaryAlmanacData(this.currentYear, this.currentMonth, this.currentDay);
  }

  build() {
    Column() {
      Column() {
        Row({ space: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_ROW_GAP_SPACE_LG : ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_ROW_GAP_SPACE_OTHER }) {
          Button() {
            Image($r('app.media.return'))
              .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
              .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
          }
          .attributeModifier(new ButtonModifier(
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40
          ))
          .onClick((event: ClickEvent) => {
            this.getUIContext().getRouter().back();
          })

          Text('黄历')
            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_FONT_SIZE_SM :
              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_FONT_SIZE_MD :
                ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_FONT_SIZE_LG)
            .fontWeight(FontWeight.Bold)
        }
        .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_WIDTH_LG :
          ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_WIDTH_OTHER)
        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_HEIGHT_LG :
          ViewArkUIConstant.ALMANAC_ALL_DATA_TITLE_HEIGHT_OTHER)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('rgba(255,255,255,0.3)')
        .backgroundBlurStyle(BlurStyle.Thin)

        Scroll() {
          Column() {
            if (this.currentBreakpoint !== BreakpointConstant.BREAKPOINT_LG) {
              Column({ space: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_GAP_SPACE_SM :
                ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_GAP_SPACE_OTHER }) {
                Text(`${this.currentYear}年${this.currentMonth}月${this.currentDay}日`)
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_SOLAR_DATE_FONT_SIZE_SM :
                    ViewArkUIConstant.ALMANAC_ALL_DATA_SOLAR_DATE_FONT_SIZE_OTHER)
                  .fontColor($r('app.color.gray_deeper'))
                if (this.currentOrdinaryAlmanacOfDay.getLunarMonth() < 0) {
                  Text(`闰${number2CharacterInLunarMonth[Math.abs(this.currentOrdinaryAlmanacOfDay.getLunarMonth())]}月${this.currentLunarText}`)
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_SM :
                      ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_OTHER)
                    .fontWeight(FontWeight.Bolder)
                } else {
                  Text(`${number2CharacterInLunarMonth[this.currentOrdinaryAlmanacOfDay.getLunarMonth()]}月${this.currentLunarText}`)
                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_SM :
                      ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_OTHER)
                    .fontWeight(FontWeight.Bolder)
                }
                Text(`${this.currentOrdinaryAlmanacOfDay.getYearInGanZhi()}年 [${this.currentOrdinaryAlmanacOfDay.getYearInShengXiao()}] ${this.currentOrdinaryAlmanacOfDay.getMonthInGanZhi()}月 ${this.currentOrdinaryAlmanacOfDay.getDayInGanZhi()}日 星期${number2characterInWeek[this.currentWeek]}`)
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.ALMANAC_ALL_DATA_GAN_ZHI_WEEK_FONT_SIZE_SM :
                    ViewArkUIConstant.ALMANAC_ALL_DATA_GAN_ZHI_WEEK_FONT_SIZE_OTHER)
                  .fontColor($r('app.color.gray_deeper'))
              }
              .alignItems(HorizontalAlign.Center)
              .width(BasicConstant.FULL_WIDTH)
              .margin({ top: ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_MARGIN_TOP })

              Column({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_GAP_SPACE }) {
                Row({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_GAP_SPACE }) {
                  Stack() {
                    Column()
                      .YiJiSquareStyle(this.currentBreakpoint,this.almanacYellow)
                    Text('宜')
                      .fontColor(Color.White)
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_OTHER)
                  }

                  Text(this.currentOrdinaryAlmanacOfDay.getYi())
                    .YiJiTextStyle(this.currentBreakpoint,this.almanacYellow)
                }
                .width(BasicConstant.FULL_WIDTH)
                .alignItems(VerticalAlign.Center)

                Row({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_GAP_SPACE }) {
                  Stack() {
                    Column()
                      .YiJiSquareStyle(this.currentBreakpoint,this.almanacRed)
                    Text('忌')
                      .fontColor(Color.White)
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_OTHER)
                  }

                  Text(this.currentOrdinaryAlmanacOfDay.getJi())
                    .YiJiTextStyle(this.currentBreakpoint,'#000000')
                }
                .width(BasicConstant.FULL_WIDTH)
                .alignItems(VerticalAlign.Center)

              }
              .width(BasicConstant.FULL_WIDTH)
              .justifyContent(FlexAlign.Center)
              .margin({
                top: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_MARGIN_TOP_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_MARGIN_TOP_OTHER,
                bottom: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_MARGIN_BOTTOM_SM : ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_MARGIN_BOTTOM_OTHER
              })
            } else {
              Row() {
                Column({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_GAP_SPACE_LG }) {
                  Text(`${this.currentYear}年${this.currentMonth}月${this.currentDay}日`)
                    .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_SOLAR_DATE_FONT_SIZE_LG)
                    .fontColor($r('app.color.gray_deeper'))
                  if (this.currentOrdinaryAlmanacOfDay.getLunarMonth() < 0) {
                    Text(`闰${number2CharacterInLunarMonth[Math.abs(this.currentOrdinaryAlmanacOfDay.getLunarMonth())]}月${this.currentLunarText}`)
                      .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_LG)
                      .fontWeight(FontWeight.Bolder)
                  } else {
                    Text(`${number2CharacterInLunarMonth[this.currentOrdinaryAlmanacOfDay.getLunarMonth()]}月${this.currentLunarText}`)
                      .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_LUNAR_TEXT_FONT_SIZE_LG)
                      .fontWeight(FontWeight.Bolder)
                  }
                  Text(`${this.currentOrdinaryAlmanacOfDay.getYearInGanZhi()}年 [${this.currentOrdinaryAlmanacOfDay.getYearInShengXiao()}] ${this.currentOrdinaryAlmanacOfDay.getMonthInGanZhi()}月 ${this.currentOrdinaryAlmanacOfDay.getDayInGanZhi()}日 星期${number2characterInWeek[this.currentWeek]}`)
                    .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_GAN_ZHI_WEEK_FONT_SIZE_LG)
                    .fontColor($r('app.color.gray_deeper'))
                }
                .width(BasicConstant.HALF_WIDTH)
                .height(BasicConstant.FULL_HEIGHT)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)

                Divider()
                  .vertical(ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_DIVIDE_DIRECTION_IS_VERTICAL)
                  .strokeWidth(ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_DIVIDE_STROKE_WIDTH)
                  .color('#CCCCCC')
                  .height(ViewArkUIConstant.ALMANAC_ALL_DATA_BASIC_INFO_DIVIDE_HEIGHT_PERCENTAGE)

                Column({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_COLUMN_GAP_SPACE_LG }) {
                  Row({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_ROW_GAP_SPACE_LG }) {
                    Stack() {
                      Column()
                        .YiJiSquareStyle(this.currentBreakpoint,this.almanacYellow)
                      Text('宜')
                        .fontColor(Color.White)
                        .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_LG)
                    }

                    Text(this.currentOrdinaryAlmanacOfDay.getYi())
                      .YiJiTextStyle(this.currentBreakpoint,this.almanacYellow)
                  }
                  .alignItems(VerticalAlign.Center)
                  .height('auto')

                  Row({ space: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_ROW_GAP_SPACE_LG }) {
                    Stack() {
                      Column()
                        .YiJiSquareStyle(this.currentBreakpoint,this.almanacRed)
                      Text('忌')
                        .fontColor(Color.White)
                        .fontSize(ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_FONT_SIZE_LG)
                    }

                    Text(this.currentOrdinaryAlmanacOfDay.getJi())
                      .YiJiTextStyle(this.currentBreakpoint,'#000000')
                  }
                  .alignItems(VerticalAlign.Center)
                  .height('auto')
                }
                .width(BasicConstant.HALF_WIDTH)
                .height(BasicConstant.FULL_HEIGHT)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Start)
                .padding({ left: ViewArkUIConstant.ALMANAC_ALL_DATA_YI_JI_PADDING_LEFT_LG })
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(ViewArkUIConstant.ALMANAC_ALL_DATA_TOP_HEIGHT_LG)
              .alignItems(VerticalAlign.Center)
              .margin({ bottom: ViewArkUIConstant.ALMANAC_ALL_DATA_TOP_MARGIN_BOTTOM_LG })
            }

            if (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ||
              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD) {
              Column() {
                AlmanacOfCurrentDay({
                  currentYear: this.currentYear,
                  currentMonth: this.currentMonth,
                  currentDay: this.currentDay
                })
                AlmanacOfCurrentTimeInCurrentDay({
                  currentYear: this.currentYear,
                  currentMonth: this.currentMonth,
                  currentDay: this.currentDay
                })
              }
              .width(BasicConstant.FULL_WIDTH)
              .alignItems(HorizontalAlign.Center)
            } else if (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG) {
              Row() {
                AlmanacOfCurrentDay({
                  currentYear: this.currentYear,
                  currentMonth: this.currentMonth,
                  currentDay: this.currentDay
                })
                AlmanacOfCurrentTimeInCurrentDay({
                  currentYear: this.currentYear,
                  currentMonth: this.currentMonth,
                  currentDay: this.currentDay
                })
              }
              .width(BasicConstant.FULL_WIDTH)
              .justifyContent(FlexAlign.Center)
              .alignItems(VerticalAlign.Center)
            }
          }
          .width(BasicConstant.FULL_WIDTH)
          .margin({bottom : ViewArkUIConstant.ALMANAC_ALL_DATA_WHOLE_PAGE_MARGIN_BOTTOM})
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(BasicConstant.FULL_HEIGHT)
        .layoutWeight(ViewArkUIConstant.ALMANAC_ALL_DATA_WHOLE_PAGE_LAYOUT_WEIGHT)
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.Top)
      }
      .width(ViewArkUIConstant.ALMANAC_ALL_DATA_WHOLE_PAGE_COLUMN_WIDTH_PERCENTAGE)
      .height(BasicConstant.FULL_HEIGHT)
      .alignItems(HorizontalAlign.Start)
      .padding({
        top: this.getUIContext().px2vp(this.topStatusBarHeight),
        bottom: this.getUIContext().px2vp(this.bottomStatusBarHeight)
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .alignItems(HorizontalAlign.Center)
  }
}