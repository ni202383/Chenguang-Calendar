import { MediaQuery } from '../Utils/MediaQuery'
import { BreakpointConstant } from '../Constants/BreakpointConstant'
import { BasicConstant } from '../Constants/BasicConstant'
import { MonthView } from './View/MonthView'
import { MonthDataSource } from './ViewModel/DataSource/MonthDataSource';
import display from '@ohos.display';
import { DialogHub, InfSheet } from '@hadss/dialoghub'
import { DailySchedule } from './View/DailyTask/NewDailyScheduleView';
import { Task } from './Model/DailyTask';
import { AlertDialog, router } from '@kit.ArkUI'
import { WeekDataSource } from './ViewModel/DataSource/WeekDataSource';
import { WeekView } from './View/WeekView';
import { DayDataSource } from './ViewModel/DataSource/DayDataSource';
import { DayView } from './View/DayView';
import { YearDataSource } from './ViewModel/DataSource/YearDataSource';
import { YearView } from './View/YearView';
import { DailyTaskItemDetail } from './View/DailyTask/DailyTaskItemDetail';
import { StartArkUISizeConstant, ViewArkUIConstant } from '../Constants/ArkUIConstant';
import {motion} from '@kit.MultimodalAwarenessKit'
import {BusinessError} from '@kit.BasicServicesKit'

@Builder
export function dailySchedule() {
  DailySchedule() //新建任务界面
}

@Extend(Text) function topDateText(currentBreakpoint : string,fontSizeSM : number,fontSizeMD : number,fontSizeLG : number){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? fontSizeLG :
    currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? fontSizeMD : fontSizeSM)
  .fontWeight(FontWeight.Bold)
  .fontColor(Color.Black)
}

@Entry
@Component
struct Start {
  @State @Watch('updateTaskList') @Watch('updateTabsIndex') currentIndex: number = 1;//tabs组件的编号
  @StorageLink('reloadTask') reloadTask: boolean = false;//重新加载每日日程的信号量
  private mediaQuery = new MediaQuery();//一多开发媒体查询工具类对象
  private tabsController = new TabsController();
  @StorageLink(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageLink('themeColor') themeColor: string = '#EA5C2E';
  /*
  * 年、月、周、日视图的year,month,day独立
  * 所以下面是单独定义的，用于在本页面显示当前的年月日
   */
  @Provide currentYearInYearView: number = new Date().getFullYear();
  @Provide currentYearInMonthView: number = new Date().getFullYear();
  @Provide currentMonthInMonthView: number = new Date().getMonth() + 1;
  @Provide selectedDayInMonthView: number = this.currentYearInMonthView == new Date().getFullYear() &&
    this.currentMonthInMonthView == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  @StorageProp('selectedDateInMonthView') selectedDateInMonthView: Date =
    new Date(this.currentYearInMonthView, this.currentMonthInMonthView - 1, this.selectedDayInMonthView);
  @Provide currentYearInWeekView: number = new Date().getFullYear();
  @Provide currentMonthInWeekView: number = new Date().getMonth() + 1;
  @Provide currentYearInDayView: number = new Date().getFullYear();
  @Provide currentMonthInDayView: number = new Date().getMonth() + 1;
  @Provide currentDayInDayView: number = new Date().getDate();
  /*
  * 继承自IDataSource，用于实现懒加载
   */
  private yearDataSource = new YearDataSource(this.currentYearInYearView);
  private monthDataSource = new MonthDataSource(this.currentYearInMonthView, this.currentMonthInMonthView);
  private weekDataSource =
    new WeekDataSource(this.currentYearInWeekView, this.currentMonthInWeekView, new Date().getDate());
  private dayDataSource =
    new DayDataSource(this.currentYearInDayView, this.currentMonthInDayView, this.currentDayInDayView);
  /*
  * 各个视图中的来自Swiper中的index
   */
  @State currentIndexInYearView: number = this.yearDataSource.getInitialIndex();
  @State currentIndexInWeekView: number = this.weekDataSource.getInitialIndex();
  @Provide selectedDayInWeekView: number = this.currentYearInWeekView == new Date().getFullYear() &&
    this.currentMonthInWeekView == new Date().getMonth() + 1 ? new Date().getDate() :
    this.weekDataSource.getData(this.currentIndexInWeekView)
      .getWeekData()[new Date().getDay()]
      .getDay()
  @Provide('currentIndexInMonthView') currentIndexInMonthView: number = this.monthDataSource.getInitialIndex();
  @State currentIndexInDayView: number = this.dayDataSource.getInitialIndex();
  adjustSheetDialog ?: InfSheet;//新建日程弹窗
  @StorageLink('selectedRemindTimeNumber') selectedRemindTimeNumber: number = 0;//新建日程中选择的提醒数目
  @State ensureCloseNewTaskDialog: boolean = false; //新建日程想关闭时使用
  @StorageLink('isCloseNewDailyTask') @Watch('closeNewDailyTaskDialog') isCloseNewDailyTask: boolean =
    false; //新建日程点击确定按钮时使用
  @StorageLink('isChange') isChange: boolean = false; //用于点击新建日程的按钮后若没有做修改，就直接关闭，无是否保存的弹窗
  @StorageLink('isRenewDailySchedule') isRenewDailySchedule: boolean = false;//是否重置新建任务窗口中的内容
  /*
  * 由于app适配了顶部的沉浸显示，需要padding一下
   */
  @StorageProp('topStatusBarHeight') topStatusBarHeight : number = 0;//顶部状态栏高度
  @StorageProp('bottomStatusBarHeight') bottomStatusBarHeight : number = 0;//底部状态栏高度
  @StorageLink('showDetail') showDetail : boolean = false;
  @StorageProp('clickedTask') clickedTask : Task = new Task();
  @State currentHandingStatus : motion.HoldingHandStatus = motion.HoldingHandStatus.NOT_HELD;
  private callback : Callback<motion.HoldingHandStatus> = (handingStatus : motion.HoldingHandStatus) => {
    this.currentHandingStatus = handingStatus;
  }
  @StorageProp('isSetChangingNewTaskButton') isSetChangingNewTaskButton : boolean = true;
  @StorageProp('changingNewTaskButtonHandingStatus') @Watch('updateBottomNewTaskButtonHandingStatus')
  changingNewTaskButtonHandingStatus : boolean = true;

  updateBottomNewTaskButtonHandingStatus(){
    try {
      if(this.changingNewTaskButtonHandingStatus){
        motion.on('holdingHandChanged',this.callback);
      } else {
        motion.off('holdingHandChanged');
        this.currentHandingStatus = motion.HoldingHandStatus.NOT_HELD;
      }
    }catch (err){
      let error = err as BusinessError;
      console.error("Failed on and err code is " + error.code);
    }
  }

  updateTabsIndex(){
    this.tabsController.changeIndex(this.currentIndex);
  }

  updateTaskList() {
    this.reloadTask = !this.reloadTask;//刷新日程
  }

  closeNewDailyTaskDialog() {//关闭新建日程窗口
    if (this.isCloseNewDailyTask == true) {
      this.adjustSheetDialog?.dismiss();
    }
  }

  dialogEnsureSaveNewTaskController: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      primaryTitle: '是否保存',
      content: '是否保存新建任务？',
      primaryButton: {
        value: '取消',
        fontColor: this.themeColor,
        action: () => {
          this.dialogEnsureSaveNewTaskController.close();
        }
      },
      secondaryButton: {
        value: '不保存',
        fontColor: Color.Red,
        action: () => {
          this.ensureCloseNewTaskDialog = true;
          this.isRenewDailySchedule = true;
          this.dialogEnsureSaveNewTaskController.close();
          this.adjustSheetDialog?.dismiss();
        }
      }
    })
  })

  aboutToAppear() {
    this.mediaQuery.Register();
    DialogHub.init(this.getUIContext())
    try {
      let defaultDisplay = display.getDefaultDisplaySync();
      let screenWidth = this.getUIContext().px2vp(defaultDisplay.width);
      let screenHeight = this.getUIContext().px2vp(defaultDisplay.height);
      AppStorage.setOrCreate('screenWidth', screenWidth);
      AppStorage.setOrCreate('screenHeight', screenHeight);
    } catch (error) {
      console.log(`an error has occured,display error`)
    }
    this.adjustSheetDialog = DialogHub.getSheet()//新建任务弹窗的初始化
      .setContent(wrapBuilder(dailySchedule))
      .setStyle({ detents: [800], backgroundColor: $r('app.color.backgroundcolor') })
      .setConfig({
        enableOutsideInteractive: false,
        scrollSizeMode: ScrollSizeMode.CONTINUOUS,
      })
      .setComponentTargetId('adjustSheetDialog')
      .setLifeCycleListener({
        onWillDismiss: () => {
          let flag = false;
          if (this.isChange == false) {
            return true;
          }
          // console.log(`点击关闭：${JSON.stringify(this.newDailySchedule)}`)
          if (this.ensureCloseNewTaskDialog || this.isCloseNewDailyTask) {
            if (this.ensureCloseNewTaskDialog == true) {
              this.ensureCloseNewTaskDialog = false;
            }
            if (this.isCloseNewDailyTask == true) {
              flag = true;
              this.isCloseNewDailyTask = false;
            }
            return true;
          }
          if (flag === false) {
            this.dialogEnsureSaveNewTaskController.open();
          }
          return false;
        }
      })
      .build()
    if(this.changingNewTaskButtonHandingStatus){
      try{
        motion.on('holdingHandChanged',this.callback);
        console.log(`currentHandingStatus:begin}`);
      }catch (err) {
        let error = err as BusinessError;
        console.error("Failed on and err code is " + error.code);
      }
    }
  }

  aboutToDisappear(): void {
    this.mediaQuery.unRegister();
  }

  offsetLeftBorder($$: number): string {//用于动态的计算tabs组件上面白色小方块的偏移量，点哪里就有移到哪里
    let offset: number = 0;
    if (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG) {
      offset = StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_X_OFFSET_BASIC_DISTANCE +
        StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_X_OFFSET_MULTI * $$;
    } else {
      offset = StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_X_OFFSET_BASIC_DISTANCE * $$;
    }
    return `${offset}%`;
  }

  @Builder
  tabsBuilder(text: string, index: number) {//tabsBar组件内容
    Column() {
      Text(text)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 20 : 15)
        .fontColor(this.currentIndex == index ? this.themeColor : Color.Black)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(36)
    .borderRadius(20)
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .animation({
      duration : 500
    })
  }

  build() {
    RelativeContainer() {
      Column() {
      } //tabs移动灰色背景
      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? BasicConstant.HALF_WIDTH :
        BasicConstant.FULL_WIDTH)
      .height(StartArkUISizeConstant.TABS_GRAY_BACKGROUND_HEIGHT)
      .backgroundColor($r('app.color.background_gray'))
      .borderRadius(StartArkUISizeConstant.TABS_GRAY_BACKGROUND_BORDER_RADIUS)
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        middle: { anchor: '__container__', align: HorizontalAlign.Center }
      })
      .offset({ y: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
        StartArkUISizeConstant.TABS_GRAY_BACKGROUND_Y_OFFSET_LG : StartArkUISizeConstant.TABS_GRAY_BACKGROUND_Y_OFFSET_OTHER})

      Column() {
      } //tabs移动白色块
      .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? BasicConstant.ONE_EIGHTH
        : BasicConstant.ONE_QUARTER)
      .height(StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_HEIGHT)
      .borderRadius(StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_BORDER_RADIUS)
      .backgroundColor(Color.White)
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .offset({
        x: this.offsetLeftBorder(this.currentIndex),
        y: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_Y_OFFSET_LG :
          StartArkUISizeConstant.TABS_MOVING_WHITE_BLOCK_Y_OFFSET_OTHER
      })
      .animation({
        duration: BasicConstant.ANIMATION_DURATION_LONG,
        tempo: BasicConstant.ANIMATION_SPEED_FASTER,
        curve: Curve.Linear,
        playMode: PlayMode.Normal
      })

      Column() {
        Row() {//顶部年月日的显示以及三个按钮：今，加号和设置
          if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_MONTH) {
            Text(this.currentYearInMonthView == new Date().getFullYear() ? `${this.currentMonthInMonthView
            }月` : `${this.currentYearInMonthView}年${this.currentMonthInMonthView}月`)
              .topDateText(this.currentBreakpoint,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_SM,
                StartArkUISizeConstant.TOP_DATE_FONT_SIZE_MD,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_LG)
          } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_WEEK) {
            Text(this.currentYearInWeekView == new Date().getFullYear() ? `${this.currentMonthInWeekView
            }月` : `${this.currentYearInWeekView}年${this.currentMonthInWeekView}月`)
              .topDateText(this.currentBreakpoint,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_SM,
                StartArkUISizeConstant.TOP_DATE_FONT_SIZE_MD,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_LG)
          } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_DAY) {
            Text(this.currentYearInDayView == new Date().getFullYear() ? `${this.currentMonthInDayView
            }月${this.currentDayInDayView}日` : `${this.currentYearInDayView}年${this.currentMonthInDayView
            }月${this.currentDayInDayView}日`)
              .topDateText(this.currentBreakpoint,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_SM,
                StartArkUISizeConstant.TOP_DATE_FONT_SIZE_MD,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_LG)
          } else {
            Text(`${this.currentYearInYearView}年`)
              .topDateText(this.currentBreakpoint,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_SM,
                StartArkUISizeConstant.TOP_DATE_FONT_SIZE_MD,StartArkUISizeConstant.TOP_DATE_FONT_SIZE_LG)
          }

          Row({space : StartArkUISizeConstant.THREE_BUTTON_GAP_SPACE}) {
            Column() {
              if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_MONTH &&
                (this.currentIndexInMonthView != this.monthDataSource.getInitialIndex()) ||
                this.currentIndex == StartArkUISizeConstant.TABS_INDEX_WEEK &&
                  (this.currentIndexInWeekView != this.weekDataSource.getInitialIndex()) ||
                this.currentIndex == StartArkUISizeConstant.TABS_INDEX_DAY &&
                  (this.currentIndexInDayView != this.dayDataSource.getInitialIndex()) ||
                this.currentIndex == StartArkUISizeConstant.TABS_INDEX_YEAR &&
                  (this.currentIndexInYearView != this.yearDataSource.getInitialIndex())
              ) {
                Button('今')
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
                    StartArkUISizeConstant.BUTTON_TODAY_FONTSIZE_SM : StartArkUISizeConstant.BUTTON_TODAY_FONTSIZE_OTHER)
                  .fontColor(this.themeColor)
                  .type(ButtonType.Circle)
                  .backgroundColor($r('app.color.background_gray'))
                  .width(BasicConstant.NINETY_FIVE_PERCENT)
                  .height(BasicConstant.NINETY_FIVE_PERCENT)
                  .onClick((event: ClickEvent) => {
                      if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_MONTH) {
                        this.currentIndexInMonthView = this.monthDataSource.getInitialIndex();
                        this.currentYearInMonthView = new Date().getFullYear();
                        this.currentMonthInMonthView = new Date().getMonth() + 1;
                        this.selectedDayInMonthView = new Date().getDate();
                      } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_WEEK) {
                        this.currentIndexInWeekView = this.weekDataSource.getInitialIndex();
                        this.currentYearInWeekView = new Date().getFullYear();
                        this.currentMonthInWeekView = new Date().getMonth() + 1;
                        this.selectedDayInWeekView = new Date().getDate();
                      } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_DAY) {
                        this.currentIndexInDayView = this.dayDataSource.getInitialIndex();
                        this.currentYearInDayView = new Date().getFullYear();
                        this.currentMonthInDayView = new Date().getMonth() + 1;
                        this.currentDayInDayView = new Date().getDate();
                      } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_YEAR) {
                        this.currentIndexInYearView = this.yearDataSource.getInitialIndex();
                        this.currentYearInYearView = new Date().getFullYear();
                      }
                  })
              }
            }
            .width(BasicConstant.THIRTY_PERCENT)
            .height(BasicConstant.FULL_HEIGHT)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Button(){
                Image($r('app.media.plus'))
                  .width(StartArkUISizeConstant.PLUS_IMAGE_WIDTH)
              }
                .type(ButtonType.Circle)
                .backgroundColor($r('app.color.background_gray'))
                .width(BasicConstant.NINETY_FIVE_PERCENT)
                .height(BasicConstant.NINETY_FIVE_PERCENT)
                .onClick((event: ClickEvent) => {
                  this.isChange = false;
                  this.adjustSheetDialog?.show(); //点击从下往上弹出新建任务窗口
                })
            }
            .width(BasicConstant.THIRTY_PERCENT)
            .height(BasicConstant.FULL_HEIGHT)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            Column() {
              Button(){
                Image($r('app.media.setting'))
                  .width(StartArkUISizeConstant.SETTING_IMAGE_WIDTH)
              }
                .type(ButtonType.Circle)
                .backgroundColor($r('app.color.background_gray'))
                .width(BasicConstant.NINETY_FIVE_PERCENT)
                .height(BasicConstant.NINETY_FIVE_PERCENT)
                .onClick((event: ClickEvent) => {
                  this.getUIContext().getRouter().pushUrl({
                    url : 'pages/Settings'
                  },router.RouterMode.Standard,(err) => {
                    if(err){
                      console.log('跳转设置失败');
                    }
                  })
                })
            }
            .width(BasicConstant.THIRTY_PERCENT)
            .height(BasicConstant.FULL_HEIGHT)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

          }
          .height(BasicConstant.FULL_HEIGHT)
          .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
            StartArkUISizeConstant.THREE_START_BUTTON_ROW_WIDTH_SM : StartArkUISizeConstant.THREE_START_BUTTON_ROW_WIDTH_OTHER)
          .justifyContent(FlexAlign.SpaceBetween)

        }
        .width(BasicConstant.FULL_WIDTH)
        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          StartArkUISizeConstant.START_TITLE_BAR_HEIGHT_LG : StartArkUISizeConstant.START_TITLE_BAR_HEIGHT_OTHER)
        .justifyContent(FlexAlign.SpaceBetween)

        Tabs({
          barPosition: BarPosition.Start,
          index: StartArkUISizeConstant.TABS_BEGGING_INDEX,
          controller: this.tabsController
        }) {
          TabContent() {
            YearView({
              currentIndex: this.currentIndexInYearView,
              currentIndexInTotalPage: this.currentIndex,
              currentYearInMonthView : this.currentYearInMonthView,
              currentMonthInMonthView : this.currentMonthInMonthView
            })
          }
          .tabBar(this.tabsBuilder('年', StartArkUISizeConstant.TABS_INDEX_YEAR))

          TabContent() {
            MonthView()
          }
          .tabBar(this.tabsBuilder('月', StartArkUISizeConstant.TABS_INDEX_MONTH))

          TabContent() {
            WeekView({ currentIndex: this.currentIndexInWeekView })
          }
          .tabBar(this.tabsBuilder('周', StartArkUISizeConstant.TABS_INDEX_WEEK))

          TabContent() {
            DayView({ currentIndex: this.currentIndexInDayView })
          }
          .tabBar(this.tabsBuilder('日', StartArkUISizeConstant.TABS_INDEX_DAY))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .width(BasicConstant.FULL_WIDTH)
        .barWidth(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? BasicConstant.HALF_WIDTH :
          BasicConstant.FULL_WIDTH)
        .margin({ top: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
          StartArkUISizeConstant.TABS_MARGIN_TOP_LG : StartArkUISizeConstant.TABS_MARGIN_TOP_OTHER })
        .scrollable(false)
        .onAnimationStart((fromIndex : number,toIndex : number) => {
          this.currentIndex = toIndex;
        })
        .animationCurve(Curve.Smooth)
        .animationDuration(BasicConstant.ANIMATION_DURATION_SHORT)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)

      if(this.isSetChangingNewTaskButton){
        Button(){
          Image($r('app.media.plus_white'))
            .width('85%')
        }
        .type(ButtonType.Circle)
        .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_SM :
          this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_MD :
            ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_LG)
        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_SM :
          this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_MD :
            ViewArkUIConstant.BOTTOM_BUTTON_WIDTH_HEIGHT_LG)
        .backgroundColor(this.themeColor)
        .alignRules({
          bottom : {anchor : '__container__',align : VerticalAlign.Bottom},
          right : {anchor : '__container__',align : HorizontalAlign.End}
        })
        .offset({
          x : this.currentHandingStatus == motion.HoldingHandStatus.LEFT_HAND_HELD ?
            ViewArkUIConstant.BOTTOM_BUTTON_X_LEFT_HAND_OFFSET : this.currentHandingStatus ==
            motion.HoldingHandStatus.RIGHT_HAND_HELD ? ViewArkUIConstant.BOTTOM_BUTTON_X_RIGHT_HAND_OFFSET :
              ViewArkUIConstant.BOTTOM_BUTTON_X_OTHER_AND_DEFAULT_OFFSET,
          y : ViewArkUIConstant.BOTTOM_BUTTON_Y_OFFSET
        })
        .onClick((event : ClickEvent) => {
          this.adjustSheetDialog?.show();
        })
        .animation({
          curve : Curve.EaseInOut,
          duration : BasicConstant.ANIMATION_DURATION_SHORT
        })
      }

      if (this.showDetail) {
        DailyTaskItemDetail({ task: this.clickedTask, showDetail: this.showDetail })
      }

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding({
      left: StartArkUISizeConstant.START_WHOLE_PADDING_LEFT,
      right: StartArkUISizeConstant.START_WHOLE_PADDING_RIGHT,
      top : this.getUIContext().px2vp(this.topStatusBarHeight)
    })
    .backgroundColor($r('app.color.backgroundcolor'))
    .id('adjustSheetDialog')
  }
}