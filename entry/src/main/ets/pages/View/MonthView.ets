import { BasicConstant } from '../../Constants/BasicConstant';
import { PerMonthInfo } from '../Model/PerMonthInfo';
import { MonthDataSource } from '../ViewModel/DataSource/MonthDataSource';
import { BreakpointConstant } from '../../Constants/BreakpointConstant';
import { DailySchedule } from './DailyTask/NewDailyScheduleView';
import { MonthViewDetail } from './MonthViewDetail';
import { ViewArkUIConstant } from '../../Constants/ArkUIConstant';

@Builder
export function dailySchedule() {
  DailySchedule();
}

@Component
export struct MonthView {
  @Consume('currentYearInMonthView') currentYear: number = new Date().getFullYear();
  @Consume('currentMonthInMonthView') currentMonth: number = new Date().getMonth() + 1;
  @Consume('selectedDayInMonthView') selectedDay : number = this.currentYear ==
  new Date().getFullYear() && this.currentMonth == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  @StorageProp('screenWidth') screenWidth: number = 200;
  private monthDataSource: MonthDataSource = new MonthDataSource(this.currentYear, this.currentMonth);
  private swiperController: SwiperController = new SwiperController();
  @Consume('currentIndexInMonthView') @Watch('ChangeToSpecifiedIndex') currentIndex: number;//当前轮播图的索引
  private preIndex : number = this.monthDataSource.getInitialIndex();
  private weekArray: Array<string> = ['日', '一', '二', '三', '四', '五', '六'];
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;

  aboutToAppear(): void {
    this.preIndex = this.currentIndex;
  }

  ChangeToSpecifiedIndex(){//跳转到特定的索引对应的月份的视图
    if(Math.abs(this.preIndex - this.currentIndex) > 5){
      this.swiperController.changeIndex(this.currentIndex,false);
    } else {
      this.swiperController.changeIndex(this.currentIndex,true);
    }
    this.preIndex = this.currentIndex;
  }

  build() {
    Column() {
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
      .justifyContent(FlexAlign.SpaceAround)

      Scroll() {
        Swiper(this.swiperController) {
          LazyForEach(this.monthDataSource, (item_: PerMonthInfo, index: number) => {
            MonthViewDetail({perMonthInfo : item_})
          }, (item: PerMonthInfo) => `${item.getYear()}-${item.getMonth()}`)
        }
        .width(BasicConstant.FULL_WIDTH)
        .autoPlay(ViewArkUIConstant.SWIPER_IS_AUTOPLAY)
        .loop(ViewArkUIConstant.SWIPER_IS_LOOP)
        .indicator(ViewArkUIConstant.SWIPER_IS_INDICATOR)
        .index(this.monthDataSource.getInitialIndex())
        .itemSpace(ViewArkUIConstant.SWIPER_ITEM_SPACE)
        .margin({bottom : ViewArkUIConstant.SWIPER_MARGIN_BOTTOM})
        .onAnimationStart((fromIndex: number,toIndex : number) => {
          const currentInfo = this.monthDataSource.getData(toIndex);
          this.currentYear = currentInfo.getYear();
          this.currentMonth = currentInfo.getMonth();
          this.currentIndex = toIndex;
        })
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .layoutWeight(ViewArkUIConstant.SCROLL_LAYOUT_WEIGHT) // 添加权重，让Scroll占据剩余空间
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto) // 显示滚动条便于调试
      .edgeEffect(EdgeEffect.Spring) // 添加边缘效果
      .align(Alignment.Top) //让scroll里面的元素从最上面开始排
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    // .margin({ bottom: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 700 : 150 })
    .id('adjustSheetDialog')
  }
}