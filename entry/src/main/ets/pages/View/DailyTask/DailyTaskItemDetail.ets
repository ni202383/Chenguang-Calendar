import { BasicConstant } from '../../../Constants/BasicConstant'
import { Task } from '../../Model/DailyTask';
import { RealDailyScheduleWithoutScroll } from './RealDailyScheduleWithoutScroll';
import {AlertDialog} from '@kit.ArkUI'
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';
import { ViewArkUIConstant } from '../../../Constants/ArkUIConstant';

@Component
export struct DailyTaskItemDetail{
  @Prop task : Task;//传进来的日程数据
  @Link showDetail : boolean;
  @State @Watch('closePage') ensureUpdateDailyTask : boolean = false;//信号量，控制日程页面的关闭
  @StorageProp('themeColor') themeColor : string = '';
  @State isDeleteThisTask : boolean = false;
  @State returnEnsureSave : boolean = false;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('wholeIndex') wholeIndex : number = 1;

  closePage(){
    if(this.ensureUpdateDailyTask){
      this.getUIContext().animateTo({
        duration : BasicConstant.ANIMATION_DURATION_LONG,
        curve : Curve.EaseInOut
      },() => {
        this.showDetail = false;
        this.ensureUpdateDailyTask = false;
      })
    }
  }

  deleteThisTaskDialog: CustomDialogController = new CustomDialogController({//删除日程的确认弹窗
    builder: AlertDialog({
      primaryTitle: '确定删除嘛？',
      primaryButton: {
        fontColor: this.themeColor,
        value: '取消',
      },
      secondaryButton: {
        value: '确定',
        fontColor: this.themeColor,
        action: () => {
          this.ensureUpdateDailyTask = true;
          this.isDeleteThisTask = true;
        }
      }
    })
  })

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

  build() {//点击日程后的一镜到底之后的页面
    Column(){
      Scroll(){
        Column({space : ViewArkUIConstant.TASK_DETAIL_WHOLE_COLUMN_GAP_SPACE}){
          Row(){
            Button(){
              Image($r('app.media.return'))
                .width('75%')
            }
            .type(ButtonType.Circle)
            .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
              ViewArkUIConstant.TASK_DETAIL_RETURN_BUTTON_WIDTH_LG : ViewArkUIConstant.TASK_DETAIL_RETURN_BUTTON_WIDTH_OTHER)
            .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
              ViewArkUIConstant.TASK_DETAIL_RETURN_BUTTON_WIDTH_LG : ViewArkUIConstant.TASK_DETAIL_RETURN_BUTTON_WIDTH_OTHER)
            .backgroundColor($r('app.color.background_gray'))
            .onClick((event : ClickEvent) => {
              this.returnFromThisTask.open();
            })

            Button({ type: ButtonType.Circle }) {
              Image($r('app.media.delete'))
                .width(ViewArkUIConstant.TASK_DETAIL_DELETE_BUTTON_IMAGE_WIDTH_PERCENTAGE)
            }
            .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ?
              ViewArkUIConstant.TASK_DETAIL_DELETE_BUTTON_WIDTH_LG: ViewArkUIConstant.TASK_DETAIL_DELETE_BUTTON_WIDTH_OTHER)
            .backgroundColor($r('app.color.background_gray'))
            .onClick(() => {
              this.deleteThisTaskDialog.open();
            })
          }
          .width(BasicConstant.FULL_WIDTH)
          .justifyContent(FlexAlign.SpaceBetween)
          RealDailyScheduleWithoutScroll({//共用新建日程的组件
            newDailySchedule : this.task,
            isNewDailyTask : false,
            isUpdateDailyTask : true,
            ensureUpdateDailyTask : this.ensureUpdateDailyTask,
            newDailySchedule_ : this.task,
            isDeleteThisTask : this.isDeleteThisTask,
            returnEnsureSave : this.returnEnsureSave
          })
        }
        .width(BasicConstant.FULL_WIDTH)
        .alignItems(HorizontalAlign.Start)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.Auto)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .backgroundColor('rgba(255,255,255,0.3)')
    .backgroundBlurStyle(BlurStyle.Thin)
    .geometryTransition(this.task.getId() + this.wholeIndex.toString())
  }
}