import { MediaQuery } from '../Utils/MediaQuery'
import { BreakpointConstant } from '../Constants/BreakpointConstant'
import { BasicConstant } from '../Constants/BasicConstant'
import { MonthView } from './View/MonthView'
import { MonthDataSource } from './ViewModel/DataSource/MonthDataSource';
import display from '@ohos.display';
import { DialogHub, InfSheet } from '@hadss/dialoghub'
import { DailySchedule } from './View/DailyTask/NewDailyScheduleView';
import { Task } from './Model/DailyTask';
import { AlertDialog, LengthUnit, router } from '@kit.ArkUI'
import { WeekDataSource } from './ViewModel/DataSource/WeekDataSource';
import { WeekView } from './View/WeekView';
import { DayDataSource } from './ViewModel/DataSource/DayDataSource';
import { DayView } from './View/DayView';
import { YearDataSource } from './ViewModel/DataSource/YearDataSource';
import { YearView } from './View/YearView';
import { DailyTaskItemDetail } from './View/DailyTask/DailyTaskItemDetail';
import { StartArkUISizeConstant, ViewArkUIConstant } from '../Constants/ArkUIConstant';
import { motion } from '@kit.MultimodalAwarenessKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { FestivalInfo } from './View/FestivalInfo'
import { SolarTermsInfo } from './View/SolarTermsInfo';
import { AgentTimeHelper } from './Service/AgentTimeHelper';
import {hdsMaterial,HdsTabs,HdsTabsController,HdsNavigation, ScrollEffectType,
  HdsNavigationMenuContentOptions,
  HdsNavigationTitleMode,
  HdsNavigationMenuItemOptions} from '@kit.UIDesignKit'

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

@Component
export struct StartCalendar {
  @State @Watch('updateTaskList') @Watch('updateTabsIndex') currentIndex: number = 1;//tabs组件的编号
  @StorageLink('reloadTask') reloadTask: boolean = false;//重新加载每日日程的信号量
  private mediaQuery = new MediaQuery();//一多开发媒体查询工具类对象
  private hdsTabsController : HdsTabsController = new HdsTabsController();
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
  @State @Watch('isShowTodayButton') currentIndexInYearView: number = this.yearDataSource.getInitialIndex();
  @State @Watch('isShowTodayButton') currentIndexInWeekView: number = this.weekDataSource.getInitialIndex();
  @Provide selectedDayInWeekView: number = this.currentYearInWeekView == new Date().getFullYear() &&
    this.currentMonthInWeekView == new Date().getMonth() + 1 ? new Date().getDate() :
    this.weekDataSource.getData(this.currentIndexInWeekView)
      .getWeekData()[new Date().getDay()]
      .getDay()
  @Provide('currentIndexInMonthView') @Watch('isShowTodayButton') currentIndexInMonthView: number = this.monthDataSource.getInitialIndex();
  @State @Watch('isShowTodayButton') currentIndexInDayView: number = this.dayDataSource.getInitialIndex();
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
  @StorageLink('currentHandingStatusString') currentHandingStatusString : string = '智感握姿';
  private callback : Callback<motion.HoldingHandStatus> = (handingStatus : motion.HoldingHandStatus) => {
    this.currentHandingStatus = handingStatus;
    switch (this.currentHandingStatus){
      case motion.HoldingHandStatus.NOT_HELD:
        this.currentHandingStatusString = '智感握姿（当前状态：无握持）';
        break;
      case motion.HoldingHandStatus.LEFT_HAND_HELD:
        this.currentHandingStatusString = '智感握姿（当前状态：左手握持）';
        break;
      case motion.HoldingHandStatus.RIGHT_HAND_HELD:
        this.currentHandingStatusString = '智感握姿（当前状态：右手握持）';
        break;
      case motion.HoldingHandStatus.BOTH_HANDS_HELD:
        this.currentHandingStatusString = '智感握姿（当前状态：双手握持）';
        break;
      default :
        this.currentHandingStatusString = '智感握姿（当前设备不支持智感握姿）';
        break;
    }
  }
  @StorageProp('isSetChangingNewTaskButton') isSetChangingNewTaskButton : boolean = true;
  @StorageProp('changingNewTaskButtonHandingStatus') @Watch('updateBottomNewTaskButtonHandingStatus')
  changingNewTaskButtonHandingStatus : boolean = true;
  @StorageLink('isShowFestivalDetail') isShowFestivalDetail : boolean = false;
  @StorageProp('screenWidth') screenWidth : number = 200;
  @StorageLink('isShowSolarTermsDetail') isShowSolarTermsDetail : boolean = false;
  @StorageLink('returnEnsureSave') returnEnsureSave : boolean = false;
  @StorageLink('agentCalendarJumpVersion') @Watch('handleAgentCalendarJump') agentCalendarJumpVersion: number = 0;
  @StorageProp('agentCalendarJumpDate') agentCalendarJumpDate: string = '';
  @StorageProp('agentCalendarJumpViewType') agentCalendarJumpViewType: string = 'day';
  private readonly dayBaseDate: Date = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
  private readonly weekBaseDate: Date = new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate());
  private readonly monthBaseDate: Date = new Date(new Date().getFullYear(), new Date().getMonth(), 1);
  private currentMenuValueArray : Array<HdsNavigationMenuItemOptions> = [{
    content : {
      label : 'add',
      icon : $r('app.media.plus'),
      action : () => {
        this.isChange = false;
        this.adjustSheetDialog?.show();
      }
    }
  },{
    content : {
      label : 'setting',
      icon : $r('app.media.setting'),
      action : () => {
        this.getUIContext().getRouter().pushUrl({
          url : 'pages/Settings'
        },() => {
          console.error('无法跳转到设置页');
        })
      }
    },
  }]
  private otherMenuValueArray : Array<HdsNavigationMenuItemOptions> = [
    {
      content : {
        label : 'current',
        icon : $r('app.media.today'),
        action : () => {
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
        }
      }
    },{
    content : {
      label : 'add',
      icon : $r('app.media.plus'),
      action : () => {
        this.isChange = false;
        this.adjustSheetDialog?.show();
      }
    }
  },{
    content : {
      label : 'setting',
      icon : $r('app.media.setting'),
      action : () => {
        this.getUIContext().getRouter().pushUrl({
          url : 'pages/Settings'
        },() => {
          console.error('无法跳转到设置页');
        })
      }
    },
  }
  ]

  @State menuValueArray : Array<HdsNavigationMenuItemOptions> = [];

  handleAgentCalendarJump(): void {
    const targetDate: Date | null = AgentTimeHelper.parseDateText(this.agentCalendarJumpDate);
    if (targetDate === null) {
      return;
    }
    if (this.agentCalendarJumpViewType === 'month') {
      this.currentIndex = StartArkUISizeConstant.TABS_INDEX_MONTH;
      this.currentYearInMonthView = targetDate.getFullYear();
      this.currentMonthInMonthView = targetDate.getMonth() + 1;
      this.selectedDayInMonthView = targetDate.getDate();
      this.selectedDateInMonthView = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate());
      this.currentIndexInMonthView = this.monthDataSource.getInitialIndex() +
        AgentTimeHelper.monthOffset(this.monthBaseDate, targetDate);
      AppStorage.setOrCreate('wholeIndex', this.currentIndex);
      return;
    }
    if (this.agentCalendarJumpViewType === 'week') {
      this.currentIndex = StartArkUISizeConstant.TABS_INDEX_WEEK;
      this.currentYearInWeekView = targetDate.getFullYear();
      this.currentMonthInWeekView = targetDate.getMonth() + 1;
      this.selectedDayInWeekView = targetDate.getDate();
      this.currentIndexInWeekView = this.weekDataSource.getInitialIndex() +
        Math.floor(AgentTimeHelper.daysBetween(AgentTimeHelper.mondayOf(this.weekBaseDate),
          AgentTimeHelper.mondayOf(targetDate)) / 7);
      AppStorage.setOrCreate('wholeIndex', this.currentIndex);
      return;
    }
    this.currentIndex = StartArkUISizeConstant.TABS_INDEX_DAY;
    this.currentYearInDayView = targetDate.getFullYear();
    this.currentMonthInDayView = targetDate.getMonth() + 1;
    this.currentDayInDayView = targetDate.getDate();
    this.currentIndexInDayView = this.dayDataSource.getInitialIndex() + AgentTimeHelper.daysBetween(this.dayBaseDate,
      targetDate);
    AppStorage.setOrCreate('wholeIndex', this.currentIndex);
  }

  updateBottomNewTaskButtonHandingStatus(){
    try {
      if(this.changingNewTaskButtonHandingStatus){
        motion.on('holdingHandChanged',this.callback);
      } else {
        motion.off('holdingHandChanged');
        this.currentHandingStatus = motion.HoldingHandStatus.NOT_HELD;
        this.currentHandingStatusString = '智感握姿';
      }
    }catch (err){
      let error = err as BusinessError;
      console.error("Failed on and err code is " + error.code);
    }
  }

  updateTabsIndex(){
    this.hdsTabsController.changeIndex(this.currentIndex);
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
    this.menuValueArray = this.currentMenuValueArray;
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
      .setStyle({ 
        detents: [800], 
        backgroundColor: 'rgba(255,255,255,0.3)', // 添加透明度效果
        blurStyle : BlurStyle.Thin,
      })
      .setConfig({
        enableOutsideInteractive: true,
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

  returnFromThisTask : CustomDialogController = new CustomDialogController({//在本页面点击返回按钮后的确认弹窗
    builder : AlertDialog({
      primaryTitle: '确定保存返回嘛？',
      primaryButton: {
        fontColor: this.themeColor,
        value: '取消',
      },
      secondaryButton: {
        value: '确定',
        fontColor: this.themeColor,
        action: () => {
          this.getUIContext().animateTo({
            duration : BasicConstant.ANIMATION_DURATION_LONG,
            curve : Curve.EaseInOut
          },() => {
            this.returnEnsureSave = !this.returnEnsureSave;
            this.showDetail = false;
          })
        }
      }
    })
  })

  onBackPress(): boolean | void {
    if(this.isShowFestivalDetail){
      this.getUIContext().animateTo({
        curve : Curve.EaseInOut,
        duration : 300
      },() => {
        this.isShowFestivalDetail = !this.isShowFestivalDetail;
      })
      return true;
    } else if(this.isShowSolarTermsDetail){
      this.getUIContext().animateTo({
        curve : Curve.EaseInOut,
        duration : 300
      },() => {
        this.isShowSolarTermsDetail = !this.isShowSolarTermsDetail;
      })
      return true;
    } else if(this.showDetail){
      this.returnFromThisTask.open();
      return true;
    } else {
      return false;
    }
  }

  aboutToDisappear(): void {
    this.mediaQuery.unRegister();
  }

  offsetLeftBorder($$: number): string {//用于动态的计算tabs组件上面白色小方块的偏移量，点哪里就有移到哪里
    let offset: number = 0;
    if (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG) {
      offset = 25 + 12.5 * $$;
    } else {
      offset = 25 * $$;
    }
    return `${offset}%`;
  }

  @Builder
  tabsBuilder(text: string, index: number) {//tabsBar组件内容
    Column() {
      Text(text)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 22 : 18)
        .fontColor(this.currentIndex == index ? this.themeColor : Color.Black)
    }
    .height(36)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  mainTitle() : string{
    if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_MONTH) {
      return this.currentYearInMonthView == new Date().getFullYear() ? `${this.currentMonthInMonthView
      }月` : `${this.currentYearInMonthView}年${this.currentMonthInMonthView}月`
    } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_WEEK) {
      return this.currentYearInWeekView == new Date().getFullYear() ? `${this.currentMonthInWeekView
      }月` : `${this.currentYearInWeekView}年${this.currentMonthInWeekView}月`
    } else if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_DAY) {
      return this.currentYearInDayView == new Date().getFullYear() ? `${this.currentMonthInDayView
      }月${this.currentDayInDayView}日` : `${this.currentYearInDayView}年${this.currentMonthInDayView
      }月${this.currentDayInDayView}日`
    } else {
      return `${this.currentYearInYearView}年`
    }
  }

  isShowTodayButton(){
    if (this.currentIndex == StartArkUISizeConstant.TABS_INDEX_MONTH &&
      (this.currentIndexInMonthView != this.monthDataSource.getInitialIndex()) ||
      this.currentIndex == StartArkUISizeConstant.TABS_INDEX_WEEK &&
        (this.currentIndexInWeekView != this.weekDataSource.getInitialIndex()) ||
      this.currentIndex == StartArkUISizeConstant.TABS_INDEX_DAY &&
        (this.currentIndexInDayView != this.dayDataSource.getInitialIndex()) ||
      this.currentIndex == StartArkUISizeConstant.TABS_INDEX_YEAR &&
        (this.currentIndexInYearView != this.yearDataSource.getInitialIndex())
    ){
      this.menuValueArray = this.currentMenuValueArray;
    } else {
      this.menuValueArray = this.otherMenuValueArray;
    }
  }

  private menu : HdsNavigationMenuContentOptions = {
    value : this.otherMenuValueArray
  }

  build() {
    RelativeContainer() {
      HdsTabs({
        controller: this.hdsTabsController,
        index : 1
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
      .width(BasicConstant.FULL_WIDTH)
      .barHeight(40)
      .layoutWeight(1)
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .barFloatingStyle({
        barBottomMargin : 670,
        adaptToHandedness : true,
        systemMaterialEffect : {
          materialType : hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel : hdsMaterial.MaterialLevel.ADAPTIVE
        },
        lightColor : this.themeColor
      })
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP])
      .onAnimationStart((fromIndex : number,toIndex : number) => {
        this.currentIndex = toIndex;
        AppStorage.setOrCreate('wholeIndex',this.currentIndex);
      })

      HdsNavigation(){}
      .width('100%')
      .height('100%')
      .mode(NavigationMode.Stack)
      .padding({top : this.getUIContext().px2vp(this.topStatusBarHeight)})
      .hitTestBehavior(HitTestMode.Transparent)
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM],[LayoutSafeAreaEdge.TOP])
      .titleBar({
        style : {
          scrollEffectOpts : {
            enableScrollEffect : false,
            scrollEffectType : ScrollEffectType.GRADIENT_BLUR,
          },
          systemMaterialEffect : {
            materialType : hdsMaterial.MaterialType.ADAPTIVE,
            materialLevel : hdsMaterial.MaterialLevel.ADAPTIVE
          }
        },
        content : {
          title : {
            mainTitle : this.mainTitle(),
            mainTitleSize : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 35 :
              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? 30 : 25,
          },
          menu : this.menu
        },
        enableHoverMode : true,
      })
      .titleMode(HdsNavigationTitleMode.MINI)
      .hideBackButton(true)

      Column(){}
      .width('100%')
      .height(this.getUIContext().px2vp(this.topStatusBarHeight))
      .alignRules({
        left : {anchor : '__container__',align : HorizontalAlign.Start},
        top : {anchor : '__container__',align : VerticalAlign.Top}
      })
      .backgroundColor('rgba(240,240,240,0.82)')
      .backdropBlur(11)

      if(this.isSetChangingNewTaskButton && this.currentIndex != 0){
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

      if(this.isShowFestivalDetail){
        FestivalInfo()
          .geometryTransition('showFestivalDetail')
      }

      if(this.isShowSolarTermsDetail){
        SolarTermsInfo()
          .geometryTransition('showSolarTermsDetail')
      }

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding({
      left: StartArkUISizeConstant.START_WHOLE_PADDING_LEFT,
      right: StartArkUISizeConstant.START_WHOLE_PADDING_RIGHT,
    })
    .backgroundColor($r('app.color.backgroundcolor'))
    .id('adjustSheetDialog')
  }
}