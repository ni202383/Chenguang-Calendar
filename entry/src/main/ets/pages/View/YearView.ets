import { ViewArkUIConstant } from "../../Constants/ArkUIConstant";
import { BasicConstant } from "../../Constants/BasicConstant";
import { BreakpointConstant } from "../../Constants/BreakpointConstant";
import { monthDiff } from "../../Utils/ViewUtils";
import { DailyInfoBase } from "../Model/DailyInfoBase";
import { PerMonthInfoInYearView } from "../Model/PerMonthInfoInYearView";
import { PerYearInfo } from "../Model/PerYearInfo";
import { YearDataSource } from "../ViewModel/DataSource/YearDataSource";

@Component
export struct YearView {
  @Consume('currentYearInYearView') currentYear: number = new Date().getFullYear();
  private yearDataSource = new YearDataSource(this.currentYear);
  private weekArray: Array<string> = ['日', '一', '二', '三', '四', '五', '六'];
  private swiperController : SwiperController = new SwiperController();
  @Link @Watch('ChangeToSpecifiedIndex') currentIndex: number;
  private preIndex : number = this.yearDataSource.getInitialIndex();//记录了在跳转到指定年份之前在那个索引，避免跳转动画卡壳
  @Link currentIndexInTotalPage : number;//Index.ets中tabs组件的索引，用于点击月份跳转到月视图
  @Consume('currentIndexInMonthView') currentIndexInMonthView : number;//月视图中的索引，用于在年视图中点击月份跳转到月视图后到达指定月份视图
  @StorageProp('themeColor') themeColor: string = '';
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('changeSwiperIndexInMonth') changeSwiperIndexInMonth : boolean = false;//信号量
  @StorageLink('changeTabsIndex') changeTabsIndex : boolean = false;//信号量
  @Link currentYearInMonthView : number;
  @Link currentMonthInMonthView : number;

  aboutToAppear(): void {
    this.preIndex = this.currentIndex;
  }

  ChangeToSpecifiedIndex(){//跳转到特定的索引对应的年份的视图
    if(Math.abs(this.preIndex - this.currentIndex) > 5){//跳转年份差距大于5年，为了防止卡壳，取消动画
      this.swiperController.changeIndex(this.currentIndex,false);
    } else {
      this.swiperController.changeIndex(this.currentIndex,true);
    }
    this.preIndex = this.currentIndex;
  }

  build() {
    Column() {
      Scroll() {
        Column({space : ViewArkUIConstant.YEAR_VIEW_GAP_SPACE}) {
          Row({ space: ViewArkUIConstant.YEAR_VIEW_LABEL_GAP_SPACE }) {
            Column()
              .width(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_LABEL_WIDTH_SM :
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_LABEL_WIDTH_MD :
                  ViewArkUIConstant.YEAR_VIEW_LABEL_WIDTH_LG
              )
              .height(ViewArkUIConstant.YEAR_VIEW_LABEL_HEIGHT)
              .backgroundColor(this.themeColor)
              .borderRadius(ViewArkUIConstant.YEAR_VIEW_LABEL_BORDER_RADIUS)

            Text('农历初一')
              .fontSize(
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_FLAG_FONT_SIZE_SM :
                this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_FLAG_FONT_SIZE_MD :
                  ViewArkUIConstant.YEAR_VIEW_FLAG_FONT_SIZE_LG
              )
              .fontColor(Color.Black)
          }
          .width(BasicConstant.FULL_WIDTH)
          .justifyContent(FlexAlign.Start)
          .margin({top : ViewArkUIConstant.YEAR_VIEW_FLAG_MARGIN_TOP})

          Swiper(this.swiperController) {
            LazyForEach(this.yearDataSource, (perYearInfo: PerYearInfo) => {
              Grid() {
                ForEach(perYearInfo.getMonthInfo(), (perMonthInfo: PerMonthInfoInYearView) => {
                  GridItem() {
                    Column({ space: ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_GAP_SPACE }) {
                      Text(`${perMonthInfo.getMonth()}月`)
                        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_MONTH_FONT_SIZE_SM :
                          this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_MONTH_FONT_SIZE_MD :
                            ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_MONTH_FONT_SIZE_LG
                        )
                        .fontWeight(FontWeight.Bold)
                        .fontColor(perYearInfo.getYear() == new Date().getFullYear() &&
                          perMonthInfo.getMonth() == new Date().getMonth() + 1 ?
                          this.themeColor : Color.Black)

                      Row() {
                        ForEach(this.weekArray, (item: string, index: number) => {
                          Text(item)
                            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_WEEK_ARRAY_FONT_SIZE_SM :
                              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_WEEK_ARRAY_FONT_SIZE_MD :
                                ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_WEEK_ARRAY_FONT_SIZE_LG
                            )
                            .fontColor(index == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX || index == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX ? $r('app.color.gray_deep') : Color.Black)
                        }, (item: string) => item)
                      }
                      .width(BasicConstant.FULL_WIDTH)
                      .justifyContent(FlexAlign.SpaceAround)

                      Grid() {
                        ForEach(perMonthInfo.getDailyInfo(), (dailyInfo: DailyInfoBase) => {
                          GridItem() {
                            Column() {
                              if (dailyInfo.getIsCurrentMonth()) {
                                if (perYearInfo.getYear() == new Date().getFullYear() &&
                                  perMonthInfo.getMonth() == new Date().getMonth() + 1 &&
                                  dailyInfo.getDay() == new Date().getDate()) {
                                  Stack({ alignContent: Alignment.Center }) {
                                    Circle()
                                      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_SM :
                                        this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_MD :
                                          ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_LG)
                                      .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_SM :
                                        this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_MD :
                                          ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_WIDTH_HEIGHT_LG)
                                      .fill(this.themeColor)
                                      .stroke(this.themeColor)
                                      .strokeWidth(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CIRCLE_STROKE_WIDTH)

                                    Text(dailyInfo.getDay().toString())
                                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_SM :
                                        this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_MD
                                          : ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_LG)
                                      .fontColor(Color.White)
                                      .fontWeight(FontWeight.Medium)
                                  }

                                } else {
                                  Text(dailyInfo.getDay().toString())
                                    .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_SM :
                                      this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_MD
                                        : ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_DAY_FONT_SIZE_LG)
                                    .fontColor(dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SUNDAY_INDEX || dailyInfo.getWeek() == ViewArkUIConstant.WEEK_ARRAY_SATURDAY_INDEX ?
                                      $r('app.color.gray_deep') : Color.Black)
                                    .fontWeight(FontWeight.Medium)
                                }

                                if (dailyInfo.getLunarDateText().endsWith('初一')) {
                                  Column()
                                    .width(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_FIRST_DAY_IN_LUNAR_MONTH_LABEL_WIDTH_PERCENTAGE)
                                    .height(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_FIRST_DAY_IN_LUNAR_MONTH_LABEL_HEIGHT)
                                    .borderRadius(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_FIRST_DAY_IN_LUNAR_MONTH_LABEL_BORDER_RADIUS)
                                    .backgroundColor(this.themeColor)
                                }
                              }
                            }
                          }
                          .width(BasicConstant.FULL_WIDTH)

                        }, (dailyInfo: DailyInfoBase) => `${dailyInfo.getDay()}-${dailyInfo.getIsCurrentMonth()}`)
                      }
                      .width(BasicConstant.FULL_WIDTH)
                      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr')
                      .rowsGap(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CALENDAR_ROW_GAP)
                      .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CALENDAR_HEIGHT_SM :
                        this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CALENDAR_HEIGHT_MD :
                          ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CALENDAR_HEIGHT_LG)

                    }
                    .width(BasicConstant.FULL_WIDTH)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width(BasicConstant.FULL_WIDTH)
                  .onClick((event : ClickEvent) => {
                      this.currentIndexInTotalPage = ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_CLICK_TARGET_TABS_INDEX;
                      const offsetMonths = monthDiff(new Date().getFullYear(),new Date().getMonth() + 1,perYearInfo.getYear(),perMonthInfo.getMonth());
                      this.currentYearInMonthView = perYearInfo.getYear();
                      this.currentMonthInMonthView = perMonthInfo.getMonth();
                      this.currentIndexInMonthView = BasicConstant.MONTH_DATASOURCE_INITIAL_INDEX - offsetMonths;
                  })

                }, (perMonthInfo: PerMonthInfoInYearView) => `${perMonthInfo.getMonth()}`)
              }
              .width(BasicConstant.FULL_WIDTH)
              .columnsTemplate(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
                '1fr 1fr 1fr 1fr' : '1fr 1fr 1fr')
              .columnsGap(ViewArkUIConstant.YEAR_VIEW_GRID_ITEM_COLUMNS_GAP)

            }, (perYearInfo: PerYearInfo) => perYearInfo.getYear().toString())
          }
          .width(BasicConstant.FULL_WIDTH)
          .margin({ bottom: ViewArkUIConstant.YEAR_VIEW_SWIPER_MARGIN_BOTTOM })
          .indicator(ViewArkUIConstant.SWIPER_IS_INDICATOR)
          .loop(ViewArkUIConstant.SWIPER_IS_LOOP)
          .autoPlay(ViewArkUIConstant.SWIPER_IS_AUTOPLAY)
          .index(this.yearDataSource.getInitialIndex())
          .onAnimationStart((fromIndex : number,toIndex : number) => {
            const nextYearInfo = this.yearDataSource.getData(toIndex);
            this.currentYear = nextYearInfo.getYear();
            this.currentIndex = toIndex;
          })
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(BasicConstant.FULL_HEIGHT)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring)

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
  }
}