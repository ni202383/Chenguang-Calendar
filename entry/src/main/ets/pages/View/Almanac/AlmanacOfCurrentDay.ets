import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';
import { BasicConstant } from '../../../Constants/BasicConstant'
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';
import { almanacOfDay } from '../../Model/LunarCalendar';
import { fetchAlmanac } from '../../ViewModel/AlmanacData';

@Extend(GridCol)
function GridColBorderStyle() {
  .border({
    width: ViewArkUIConstant.ALMANAC_GRID_BORDER_WIDTH,
    color: '#DCA668'
  })
  .padding(ViewArkUIConstant.ALMANAC_GRID_PADDING)
  .alignSelf(ItemAlign.Stretch)
}

@Component
export struct AlmanacOfCurrentDay {
  private AlmanacData: almanacOfDay = new almanacOfDay();
  @Prop currentYear: number;
  @Prop currentMonth: number;
  @Prop currentDay: number;
  @StorageProp('AlmanacYellow') almanacYellow: string = '';
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;

  aboutToAppear(): void {
    this.AlmanacData = fetchAlmanac(this.currentYear, this.currentMonth, this.currentDay);
  }

  @Builder
  AlmanacGridDetail<T>(key: string, value: T, fontColor: string = '#000000') {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
    }) {
      Text(key)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          ViewArkUIConstant.ALMANAC_GRID_KEY_TEXT_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_GRID_KEY_TEXT_FONT_SIZE_OTHER)
        .fontColor($r('app.color.gray_deeper'))
        .margin({ bottom: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          ViewArkUIConstant.ALMANAC_GRID_KEY_MARGIN_BOTTOM_SM : ViewArkUIConstant.ALMANAC_GRID_KEY_MARGIN_BOTTOM_OTHER })
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Text(`${value}`)
          .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
            ViewArkUIConstant.ALMANAC_GRID_VALUE_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_GRID_VALUE_FONT_SIZE_OTHER)
          .fontWeight(FontWeight.Bold)
          .fontColor(fontColor)
      }
      .width(BasicConstant.FULL_WIDTH)
      .alignSelf(ItemAlign.Stretch)
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignSelf(ItemAlign.Stretch)
  }

  build() {
    Column() {
      GridRow({
        columns: ViewArkUIConstant.JI_SHEN_POSITION_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row,
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('财神位', this.AlmanacData.getJiShengPosition().getCaiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('喜神位', this.AlmanacData.getJiShengPosition().getXiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('福神位', this.AlmanacData.getJiShengPosition().getFuPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('阳贵位', this.AlmanacData.getJiShengPosition().getYangGuiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('阴贵位', this.AlmanacData.getJiShengPosition().getYinGuiPosition())
        }
        .GridColBorderStyle()
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(ViewArkUIConstant.JI_SHEN_POSITION_HEIGHT)

      GridRow({
        columns: ViewArkUIConstant.TAI_TWELVE_ZHI_XIN_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row,
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('今日胎神', this.AlmanacData.getDayTaiPosition(), this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('建除十二神', `${this.AlmanacData.getTwelveZhiXing()}日`, this.almanacYellow)
        }
        .GridColBorderStyle()
      }
      .width(BasicConstant.FULL_WIDTH)

      GridRow({
        columns: ViewArkUIConstant.DAY_CHONG_SHA_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('日冲', this.AlmanacData.getChong())
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('日煞', this.AlmanacData.getSha())
        }
        .GridColBorderStyle()
      }
      .width(BasicConstant.FULL_WIDTH)

      GridRow({
        columns: ViewArkUIConstant.JI_SHEN_XIONG_SHA_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('吉神宜趋', this.AlmanacData.getJiSheng(), this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('凶煞宜忌', this.AlmanacData.getXiongSha())
        }
        .GridColBorderStyle()
      }
      .width(BasicConstant.FULL_WIDTH)

      GridRow({
        columns: ViewArkUIConstant.TIAN_GAN_DI_ZHI_JI_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('天干百忌', this.AlmanacData.getPengZuGan())
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('地支百忌', this.AlmanacData.getPengZuZhi())
        }
        .GridColBorderStyle()
      }
      .width(BasicConstant.FULL_WIDTH)

      GridRow({
        columns: ViewArkUIConstant.TAI_SUI_DIRECTION_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail<string>('年太岁', this.AlmanacData.getTaisuiPosition().getYearTaiSuiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('月太岁', this.AlmanacData.getTaisuiPosition().getMonthTaiSuiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail<string>('日太岁', this.AlmanacData.getTaisuiPosition().getDayTaiSuiPosition(),
            this.almanacYellow)
        }
        .GridColBorderStyle()
      }
    }
    .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? BasicConstant.FULL_WIDTH : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
      ViewArkUIConstant.DAY_ALMANAC_WIDTH_MD_PERCENTAGE: ViewArkUIConstant.DAY_ALMANAC_WIDTH_LG_PERCENTAGE)
    .border({
      width: {
        bottom: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM || this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
          ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH_HALF : ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        right: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH_HALF :
          ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        top: ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        left: ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH
      },
      color: this.almanacYellow
    })
  }
}