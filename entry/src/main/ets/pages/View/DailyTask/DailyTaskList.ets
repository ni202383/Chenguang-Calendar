import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant";
import { BasicConstant } from "../../../Constants/BasicConstant";
import { BreakpointConstant } from "../../../Constants/BreakpointConstant";
import { Task } from "../../Model/DailyTask";
import { taskStore } from "../../Model/TaskStore";
import { DailyTaskListItem } from "./DailyTaskListItem";

@Component
export struct DailyTaskList { //月视图日程列表
  @Link @Watch('updateTask') currentYear: number;
  @Link @Watch('updateTask') currentMonth: number;
  @Link @Watch('updateTask') selectedDay: number;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @State task: Array<Task> = [];
  @StorageLink('reloadTask') @Watch('updateTask') reloadTask: boolean = false;
  @StorageLink('showDetail') showDetail: boolean = false; //用于实现一镜到底动画
  @State selectedTask: Task = new Task();
  @StorageProp('wholeIndex') wholeIndex : number = 1;
  isMonth: boolean = true;
  isDay: boolean = false;

  updateTask() {
    this.task = taskStore.getTask(this.currentYear, this.currentMonth, this.selectedDay);
  }

  aboutToAppear(): void {
    this.task = taskStore.getTask(this.currentYear, this.currentMonth, this.selectedDay);
  }

  build() {
    Column() {
      if (this.task.length === 0) { //如果没有日程，就用图片代替
        Column() {
          Column() {
            Image($r('app.media.empty_dailyTask'))
              .width(BasicConstant.HALF_WIDTH)
          }
          .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM
            ? BasicConstant.FULL_WIDTH : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD
              ? BasicConstant.EIGHTY_PERCENTAGE : BasicConstant.HALF_WIDTH)
          .height(BasicConstant.FULL_HEIGHT)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)

        }
        .width(BasicConstant.FULL_WIDTH)
        .height(ViewArkUIConstant.TASK_LIST_NONE_IMAGE_HEIGHT)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

      } else {
        Grid() {
          ForEach(this.task, (item: Task) => {
            GridItem() {
              DailyTaskListItem({
                currentYear: this.currentYear,
                currentMonth: this.currentMonth,
                selectedDay: this.selectedDay,
                task: item,
                isMonth: this.isMonth,
                isDay: this.isDay
              })
            }
            .height(ViewArkUIConstant.TASK_LIST_ITEM_HEIGHT)
            .geometryTransition(item.getId() + this.wholeIndex.toString())
            .onClick((event: ClickEvent) => {
              AppStorage.setOrCreate('clickedTask', item);
              this.getUIContext().animateTo({
                duration: BasicConstant.ANIMATION_DURATION_LONG,
                curve: Curve.EaseInOut
              }, () => {
                this.showDetail = true;
              })
            })
            .clickEffect({
              level: ClickEffectLevel.LIGHT,
              scale: 0.9
            })
          }, (item: Task) => JSON.stringify(item))
        }
        .width(BasicConstant.FULL_WIDTH)
        .columnsTemplate(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
          '1fr' : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
            '1fr 1fr' : '1fr 1fr 1fr'
        )
        .rowsGap(ViewArkUIConstant.TASK_LIST_ITEM_ROWS_GAP)
        .columnsGap(ViewArkUIConstant.TASK_LIST_ITEM_COLUMNS_GAP)
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .justifyContent(FlexAlign.Start)
  }
}