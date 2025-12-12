import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';
import { BasicConstant } from '../../../Constants/BasicConstant'
import { BreakpointConstant } from '../../../Constants/BreakpointConstant'
import { almanacOfDay, almanacOfTime } from '../../Model/LunarCalendar'
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

@Extend(Column) function YiJiSquareStyle(currentBreakpoint : string,backgroundColor : string){
  .width(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.TIME_YI_JI_SQUARE_WIDTH_HEIGHT_SM : ViewArkUIConstant.TIME_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
  .height(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.TIME_YI_JI_SQUARE_WIDTH_HEIGHT_SM : ViewArkUIConstant.TIME_YI_JI_SQUARE_WIDTH_HEIGHT_OTHER)
  .borderRadius(ViewArkUIConstant.TIME_YI_JI_SQUARE_BORDER_RADIUS)
  .backgroundColor(backgroundColor)
}

@Extend(Text) function YiJiTextStyle(currentBreakpoint : string,fontColor : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
    ViewArkUIConstant.TIME_YI_JI_TEXT_FONT_SIZE_SM : ViewArkUIConstant.TIME_YI_JI_TEXT_FONT_SIZE_OTHER)
  .fontColor(fontColor)
  .width(currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.TIME_YI_JI_TEXT_WIDTH_SM :
    currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.TIME_YI_JI_TEXT_WIDTH_MD : ViewArkUIConstant.TIME_YI_JI_TEXT_WIDTH_LG)
}

class paramsType {
  key: string = '';
  value: string = '';
  fontColor: string = '#000000';
}

@Component
export struct AlmanacOfCurrentTimeInCurrentDay {
  @Prop currentYear: number;
  @Prop currentMonth: number;
  @Prop currentDay: number;
  private AlmanacData: almanacOfDay = new almanacOfDay();
  @State @Watch('updateSelectedAlmanacOfTime') currentIndexInAlmanacOfTime: number = 0;
  @State selectedAlmanacOfTime: almanacOfTime =
    this.AlmanacData.getTimeOfCurrentDay()[this.currentIndexInAlmanacOfTime];
  @StorageProp('AlmanacYellow') almanacYellow: string = '';
  @StorageProp('AlmanacRed') almanacRed: string = '#D31319';
  private blackColor = '#000000';
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;

  aboutToAppear(): void {
    this.AlmanacData = fetchAlmanac(this.currentYear, this.currentMonth, this.currentDay);
    this.selectedAlmanacOfTime = this.AlmanacData.getTimeOfCurrentDay()[this.currentIndexInAlmanacOfTime];
    for (let i = 0; i < this.AlmanacData.getTimeOfCurrentDay().length; ++i) {
      const startTime = this.AlmanacData.getTimeOfCurrentDay()[i].getBeginTime();
      const endTime = this.AlmanacData.getTimeOfCurrentDay()[i].getEndTime();
      if (new Date() >= startTime && new Date() <= endTime) {
        this.currentIndexInAlmanacOfTime = i;
        break;
      }
    }
  }

  updateSelectedAlmanacOfTime() {
    this.selectedAlmanacOfTime = this.AlmanacData.getTimeOfCurrentDay()[this.currentIndexInAlmanacOfTime];
  }

  @Builder
  AlmanacGridDetail($$: paramsType) {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceBetween,
      alignItems: ItemAlign.Center,
    }) {
      Text($$.key)
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
        Text(`${$$.value}`)
          .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
            ViewArkUIConstant.ALMANAC_GRID_VALUE_FONT_SIZE_SM : ViewArkUIConstant.ALMANAC_GRID_VALUE_FONT_SIZE_OTHER)
          .fontWeight(FontWeight.Bold)
          .fontColor($$.fontColor)
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
        columns: ViewArkUIConstant.TIME_ALMANAC_TOTAL_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          Column() {
            Row() {
              Column() {
                Text('时辰')
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_FONT_SIZE_SM : ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_FONT_SIZE_OTHER)
                  .fontColor(this.almanacYellow)
                Text('宜忌')
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_FONT_SIZE_SM : ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_FONT_SIZE_OTHER)
                  .fontColor(this.almanacYellow)
              }
              .height(BasicConstant.FULL_HEIGHT)
              .width(ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_WIDTH_PERCENTAGE)
              .alignItems(HorizontalAlign.Center)
              .justifyContent(FlexAlign.Center)
              .margin({ right: ViewArkUIConstant.TIME_ALMANAC_TOTAL_TITLE_MARGIN_RIGHT })

              Row({ space: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.TIME_ALMANAC_DETAIL_GAP_SPACE_SM : ViewArkUIConstant.TIME_ALMANAC_DETAIL_GAP_SPACE_OTHER }) {
                ForEach(this.AlmanacData.getTimeOfCurrentDay(), (item: almanacOfTime, index: number) => {
                  Column({ space: ViewArkUIConstant.TIME_ALMANAC_DETAIL_JI_XIONG_GAP_SPACE }) {
                    Text(item.getTimeInGanZhi())
                      .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.GAN_ZHI_TIME_FONT_SIZE_SM : ViewArkUIConstant.GAN_ZHI_TIME_FONT_SIZE_OTHER)
                      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                        ViewArkUIConstant.GAN_ZHI_TIME_WIDTH_SM : ViewArkUIConstant.GAN_ZHI_TIME_WIDTH_OTHER)
                      .fontColor(index == this.currentIndexInAlmanacOfTime ? this.almanacYellow : this.blackColor)
                    Stack() {
                      if (index == this.currentIndexInAlmanacOfTime) {
                        Circle()
                          .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                            ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_CIRCLE_WIDTH_HEIGHT_SM : ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_CIRCLE_WIDTH_HEIGHT_OTHER)
                          .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                            ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_CIRCLE_WIDTH_HEIGHT_SM : ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_CIRCLE_WIDTH_HEIGHT_OTHER)
                          .fill(this.almanacYellow)
                      }
                      Text(item.getJiOrXiong())
                        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_FONT_SIZE_SM : ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_FONT_SIZE_OTHER)
                        .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                          ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_WIDTH_SM : ViewArkUIConstant.GAN_ZHI_TIME_JI_XIONG_WIDTH_OTHER)
                        .fontColor(index == this.currentIndexInAlmanacOfTime ? Color.White : this.blackColor)
                    }
                  }
                  .onClick((event: ClickEvent) => {
                    this.currentIndexInAlmanacOfTime = index;
                  })
                }, (item: almanacOfTime) => item.getTime())
              }
              .margin({ left: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
                ViewArkUIConstant.GAN_ZHI_TIME_WHOLE_MARGIN_LEFT_MD : ViewArkUIConstant.GAN_ZHI_TIME_WHOLE_MARGIN_LEFT_OTHER })
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(ViewArkUIConstant.TIME_ALMANAC_TOP_TOP_HEIGHT)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Start)

            Text(`${this.selectedAlmanacOfTime.getTimeInGanZhi()}时 ${this.selectedAlmanacOfTime.getJiOrXiong()}${this.selectedAlmanacOfTime.getBeginTimeString()}-${this.selectedAlmanacOfTime.getEndTimeString()} 冲${this.selectedAlmanacOfTime.getChong()} 煞${this.selectedAlmanacOfTime.getSha()}`)
              .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                ViewArkUIConstant.TIME_ALMANAC_DETAIL_INFO_FONT_SIZE_SM : ViewArkUIConstant.TIME_ALMANAC_DETAIL_INFO_FONT_SIZE_OTHER)
              .fontColor(this.almanacYellow)
              .margin({
                top: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                  ViewArkUIConstant.TIME_ALMANAC_DETAIL_INFO_MARGIN_TOP_SM : ViewArkUIConstant.TIME_ALMANAC_DETAIL_INFO_MARGIN_TOP_OTHER,
                bottom: ViewArkUIConstant.TIME_ALMANAC_DETAIL_INFO_MARGIN_BOTTOM
              })
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .GridColBorderStyle()
      }

      GridRow({
        columns: ViewArkUIConstant.TIME_CHONG_SHA_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail({
            key: '时冲',
            value: this.selectedAlmanacOfTime.getChong(),
            fontColor: this.blackColor
          })
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail({
            key: '时煞',
            value: this.selectedAlmanacOfTime.getSha(),
            fontColor: this.blackColor
          })
        }
        .GridColBorderStyle()
      }

      GridRow({
        columns: ViewArkUIConstant.TIME_JI_SHEN_POSITION_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          this.AlmanacGridDetail({
            key: '财神位',
            value: this.selectedAlmanacOfTime.getJiShengPosition().getCaiPosition(),
            fontColor: this.almanacYellow
          })
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail({
            key: '喜神位',
            value: this.selectedAlmanacOfTime.getJiShengPosition().getXiPosition(),
            fontColor: this.almanacYellow
          })
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail({
            key: '福神位',
            value: this.selectedAlmanacOfTime.getJiShengPosition().getFuPosition(),
            fontColor: this.almanacYellow
          })
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail({
            key: '阳贵位',
            value: this.selectedAlmanacOfTime.getJiShengPosition().getYangGuiPosition(),
            fontColor: this.almanacYellow
          })
        }
        .GridColBorderStyle()

        GridCol() {
          this.AlmanacGridDetail({
            key: '阴贵位',
            value: this.selectedAlmanacOfTime.getJiShengPosition().getYinGuiPosition(),
            fontColor: this.blackColor
          })
        }
        .GridColBorderStyle()
      }

      GridRow({
        columns: ViewArkUIConstant.TIME_YI_JI_GRID_ROW_COLUMN_NUMS,
        direction: GridRowDirection.Row
      }) {
        GridCol() {
          Column({ space: ViewArkUIConstant.TIME_YI_JI_COLUMN_GAP_SPACE }) {
            Row({ space: ViewArkUIConstant.TIME_YI_JI_ROW_GAP_SPACE }) {
              Stack() {
                Column()
                  .YiJiSquareStyle(this.currentBreakpoint,this.almanacYellow)
                Text('宜')
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.TIME_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.TIME_YI_JI_FONT_SIZE_OTHER)
                  .fontColor(Color.White)
              }

              Text(this.selectedAlmanacOfTime.getYi())
                .YiJiTextStyle(this.currentBreakpoint,this.almanacYellow)
            }

            Row({ space: ViewArkUIConstant.TIME_YI_JI_ROW_GAP_SPACE }) {
              Stack() {
                Column()
                  .YiJiSquareStyle(this.currentBreakpoint,this.almanacRed)
                Text('忌')
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    ViewArkUIConstant.TIME_YI_JI_FONT_SIZE_SM : ViewArkUIConstant.TIME_YI_JI_FONT_SIZE_OTHER)
                  .fontColor(Color.White)
              }

              Text(this.selectedAlmanacOfTime.getJi())
                .YiJiTextStyle(this.currentBreakpoint,'#000000')
            }
          }
          .height(ViewArkUIConstant.TIME_YI_JI_WHOLE_HEIGHT)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Start)
        }
        .GridColBorderStyle()
      }
    }
    .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? BasicConstant.FULL_WIDTH :
      this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.DAY_ALMANAC_WIDTH_MD_PERCENTAGE :
        ViewArkUIConstant.DAY_ALMANAC_WIDTH_LG_PERCENTAGE)
    .border({
      width: {
        top: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM || this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
          ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH_HALF : ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        left: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH_HALF : ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        right: ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH,
        bottom: ViewArkUIConstant.ALMANAC_GRID_OUTSIDE_BORDER_WIDTH
      },
      color: this.almanacYellow
    })
  }
}