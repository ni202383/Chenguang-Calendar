import { BasicConstant } from "../../../Constants/BasicConstant";
import { BreakpointConstant } from "../../../Constants/BreakpointConstant";
import {
  addTransparency,
  currentDateDiff,
  heightOffsetInTaskTable, timeDiff, timeToString,widthOffsetInTaskTable } from '../../../Utils/ViewUtils'
import { Task } from "../../Model/DailyTask";
import { taskStore } from "../../Model/TaskStore";
import { DailyTaskTimeRange, TaskTimeRange } from "../../Model/TaskTimeRange";
import { JSON } from "@kit.ArkTS";
import { TaskType } from "../../Model/Enum";
import { hex2rgb } from "@keke/color-picker";

@Component
export struct TaskListGrid {
  year: number = new Date().getFullYear();
  month: number = new Date().getMonth() + 1;
  day: number = new Date().getDate();
  private currentDate : Date = new Date(this.year,this.month - 1,this.day);
  private timeList: Array<string> = [];
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('themeColor') themeColor: string = '';
  private currentHour: number = new Date().getHours();
  private currentMinute: number = new Date().getMinutes();
  @State currentTimeString: string = timeToString(this.currentHour, this.currentMinute);
  isWeeklyTaskTableMode: boolean = true;
  isDailyTaskTableMode: boolean = false;
  @Prop totalTableWidth : number;
  @State dailyTaskTimeRange: DailyTaskTimeRange = new DailyTaskTimeRange();
  @State taskTimeRange : Array<TaskTimeRange> = [];
  @State weeklyTaskTimeRangeList: Array<DailyTaskTimeRange> = [];
  @StorageLink('reloadTask') @Watch('updateTaskGrid') reloadTask : boolean = false;
  private timeId : number = 0;
  private dayString = ['日','一','二','三','四','五','六'];

  aboutToAppear(): void {
    this.currentDate = new Date(this.year,this.month - 1,this.day);
    this.timeList = [];
    for (let i = 0; i <= 24; ++i) {
      this.timeList.push(`${i.toString().padStart(2, '0')}:00`);
    }
    this.updateTaskGrid();

    this.timeId = setInterval(() => {
      const now = new Date();
      this.currentHour = now.getHours();
      this.currentMinute = now.getMinutes();
      this.currentTimeString = timeToString(this.currentHour, this.currentMinute);
    },1000);
    this.weeklyTaskTimeRangeList = this.weeklyTaskTimeRangeList.map((item) => {
      let dailyTaskTimeRange = new DailyTaskTimeRange();
      dailyTaskTimeRange.year = item.year;
      dailyTaskTimeRange.month = item.month;
      dailyTaskTimeRange.day = item.day;
      dailyTaskTimeRange.taskTimeRange = item.taskTimeRange;
      return dailyTaskTimeRange;
    });
    if(this.isDailyTaskTableMode && !this.isWeeklyTaskTableMode){
      this.taskTimeRange = this.dailyTaskTimeRange.taskTimeRange;
    }
  }

  aboutToDisappear(): void {
    if (this.timeId) {
      clearInterval(this.timeId);
      this.timeId = 0;
    }
  }

  updateTaskGrid(){
    if (this.isWeeklyTaskTableMode) {
      this.getWeeklyTaskTimeRange(this.year, this.month, this.day);
    } else if (this.isDailyTaskTableMode) {
      this.getDailyTaskTimeRange(this.year, this.month, this.day);
      this.taskTimeRange = this.dailyTaskTimeRange.taskTimeRange;
    }
  }

  getTaskTimeRange(task: Task): TaskTimeRange {
    let beginHour = task.getBeginHour();
    let beginMinute = task.getBeginMinute();
    let endHour = task.getEndHour();
    let endMinute = task.getEndMinute();
    let beginHeightOffset = heightOffsetInTaskTable(timeToString(beginHour, beginMinute));
    let endHeightOffset = heightOffsetInTaskTable(timeToString(endHour, endMinute));
    let taskTimeRange = new TaskTimeRange(beginHeightOffset, endHeightOffset, task.getTitle(), task.getTaskType());
    return taskTimeRange;
  }

  getDailyTaskTimeRange(year: number, month: number, day: number) {
    let taskList: Array<Task> = taskStore.getTask(year, month, day);
    let taskTimeRangeList: Array<TaskTimeRange> = [];
    for (const task of taskList) {
      let taskTimeRange = this.getTaskTimeRange(task);
      taskTimeRangeList.push(taskTimeRange);
    }
    this.dailyTaskTimeRange = new DailyTaskTimeRange(year, month, day, taskTimeRangeList);
    console.log(`今天的日程对象为:${JSON.stringify(this.dailyTaskTimeRange)}`);
  }

  getWeeklyTaskTimeRange(year: number, month: number, day: number) {
    // 创建临时数组来收集数据，避免直接修改状态变量
    let tempWeeklyTaskTimeRangeList: Array<DailyTaskTimeRange> = [];
    
    let dayInCurrentWeek = new Date(year, month - 1, day);
    let week = dayInCurrentWeek.getDay();
    
    // 处理当前日期之前的日期
    for (let i = 0; i < week; ++i) {
      let day_ = day - (week - i);
      let newDate = new Date(year, month - 1, day_);
      let taskList: Array<Task> = taskStore.getTask(newDate.getFullYear(), newDate.getMonth() + 1, newDate.getDate());
      let taskTimeRangeList: Array<TaskTimeRange> = [];
      
      for (const task of taskList) {
        let taskTimeRange = this.getTaskTimeRange(task);
        taskTimeRangeList.push(taskTimeRange);
      }
      
      let dailyTaskTimeRange = new DailyTaskTimeRange(newDate.getFullYear(), newDate.getMonth() + 1, newDate.getDate(), taskTimeRangeList);
      tempWeeklyTaskTimeRangeList.push(dailyTaskTimeRange);
    }

    // 处理当前日期
    let taskList: Array<Task> = taskStore.getTask(year, month, day);
    let taskTimeRangeList: Array<TaskTimeRange> = [];
    
    for (const task of taskList) {
      let taskTimeRange = this.getTaskTimeRange(task);
      taskTimeRangeList.push(taskTimeRange);
    }
    
    let dailyTaskTimeRange = new DailyTaskTimeRange(year, month, day, taskTimeRangeList);
    tempWeeklyTaskTimeRangeList.push(dailyTaskTimeRange);

    // 处理当前日期之后的日期
    for (let i = week + 1; i <= 6; ++i) {
      let day_ = day - (week - i);
      let newDate = new Date(year, month - 1, day_);
      let taskList: Array<Task> = taskStore.getTask(newDate.getFullYear(), newDate.getMonth() + 1, newDate.getDate());
      let taskTimeRangeList: Array<TaskTimeRange> = [];
      
      for (const task of taskList) {
        let taskTimeRange = this.getTaskTimeRange(task);
        taskTimeRangeList.push(taskTimeRange);
      }
      
      let dailyTaskTimeRange = new DailyTaskTimeRange(newDate.getFullYear(), newDate.getMonth() + 1, newDate.getDate(), taskTimeRangeList);
      tempWeeklyTaskTimeRangeList.push(dailyTaskTimeRange);
    }
    
    // 一次性重新赋值状态变量，触发UI刷新
    this.weeklyTaskTimeRangeList = [...tempWeeklyTaskTimeRangeList];
  }

  build() {
    RelativeContainer() {
      Row() {
        Text(this.currentTimeString)
          .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : 15)
          .fontColor(this.themeColor)

        Divider()
          .vertical(false)
          .strokeWidth(0.5)
          .color(this.themeColor)
          .margin({ left: 10, right: 10 })
      }
      .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : 15)
      .width(BasicConstant.FULL_WIDTH)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .alignRules({
        top: { anchor: '__container__', align: VerticalAlign.Top },
        left: { anchor: '__container__', align: HorizontalAlign.Start }
      })
      .offset({
        y: heightOffsetInTaskTable(this.currentTimeString) + (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 50 : 47.5)
      })

      RelativeContainer(){
        if(this.isDailyTaskTableMode){
          ForEach(this.taskTimeRange, (item: TaskTimeRange) => {
            TaskColumn({
              taskTimeRange : item,
              offsetX : 2,
              taskColumnWidth : this.totalTableWidth / (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 4 : 1.2)
            })
              .offset({
                x : (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 8 : 23) + 2
              })
          }, (item: TaskTimeRange) => JSON.stringify(item))
        } else if(this.isWeeklyTaskTableMode){
          ForEach(this.weeklyTaskTimeRangeList,(item : DailyTaskTimeRange) => {
            DailyTaskColumn({
              dailyTaskTimeRange : item,
              taskColumnWidth : this.totalTableWidth / 7,
              offsetX : widthOffsetInTaskTable(new Date(item.year,item.month - 1,item.day).getDay(),this.totalTableWidth / 7)
            })
          },(item : DailyTaskTimeRange) => JSON.stringify(item.taskTimeRange))
        }
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .backgroundColor(Color.Transparent)
      .padding({
        left: 26,
        top: 55
      })

      List({ space: this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 20 : 15 }) {
        if(this.isWeeklyTaskTableMode && !this.isDailyTaskTableMode){
          ListItem(){
            Row(){
              ForEach(this.dayString,(item : string) => {
                Text(item)
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 12 : 16)
                  .fontColor($r('app.color.gray_deep'))
              },(item : string) => item)
            }
            .margin({left : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 34 : 48})
            .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? '88%' :
              this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? '92.5%' : '95.5%')
            .height(BasicConstant.FULL_HEIGHT)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.SpaceAround)
          }
          .width(BasicConstant.FULL_WIDTH)
          .height(30)
          .align(Alignment.Start)
          .margin({bottom : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 0 : 2.5})
        } else if(!this.isWeeklyTaskTableMode && this.isDailyTaskTableMode){
          ListItem(){
            Row(){
              Text(`${currentDateDiff(this.currentDate)},星期${this.dayString[this.currentDate.getDay()]}`)
                .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 12 : 16)
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(BasicConstant.FULL_HEIGHT)
            .alignItems(VerticalAlign.Center)
            .justifyContent(FlexAlign.Center)
          }
          .width(BasicConstant.FULL_WIDTH)
          .height(30)
          .margin({bottom : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 0 : 2.5})
        }

        ForEach(this.timeList, (item: string) => {
          ListItem() {
            Row() {
              if (timeDiff(this.currentTimeString, item) >= 30) {
                Text(item)
                  .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : 15)
                  .fontColor($r('app.color.gray_deep'))
              } else {
                Text()
                  .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : 15)
                  .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 25 : 38)
              }

              Divider()
                .vertical(false)
                .strokeWidth(0.5)
                .color($r('app.color.gray_deep'))
                .margin({ left: 10, right: 10 })
            }
            .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : 15)
            .width(BasicConstant.FULL_WIDTH)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center)

          }
          .width(BasicConstant.FULL_WIDTH)
        }, (item: string) => item)
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(BasicConstant.FULL_HEIGHT)
      .lanes(1)
      .alignListItem(ListItemAlign.Center)
      .scrollBar(BarState.Off)

    }
    .width(BasicConstant.FULL_WIDTH)
    .height(825)
    .backgroundColor(Color.White)
    .borderRadius(20)
    .padding(15)
    .clickEffect({
      level : ClickEffectLevel.LIGHT,
      scale : 0.9
    })
  }
}

@Component
struct DailyTaskColumn{

  @ObjectLink dailyTaskTimeRange : DailyTaskTimeRange;
  @State taskTimeRange : Array<TaskTimeRange> = this.dailyTaskTimeRange.taskTimeRange;
  taskColumnWidth : number = 300;
  offsetX : number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;

  build() {
    RelativeContainer(){
      ForEach(this.taskTimeRange, (item: TaskTimeRange) => {
        TaskColumn({
          taskTimeRange : item,
          offsetX : this.offsetX,
          taskColumnWidth : this.taskColumnWidth
        })
      }, (item: TaskTimeRange) => JSON.stringify(item))
    }
    .width(this.taskColumnWidth)
    .height(720)
    .alignRules({
      left : {anchor : '__container__',align : HorizontalAlign.Start},
      top : {anchor : '__container__',align : VerticalAlign.Top}
    })
    .offset({
      x : (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 8 : 23) + this.offsetX
    })
  }
}

@Component
export struct TaskColumn{

  @ObjectLink taskTimeRange : TaskTimeRange;
  private taskTypeColorMap: Record<TaskType, string> = {
    [TaskType.Work]: "#E31818",
    [TaskType.Entertainment]: "#AB1AC2",
    [TaskType.life]: "#58EF1A",
    [TaskType.Self_discipline]: "#22E7D0"
  }
  taskColumnWidth : number = 300;
  offsetX : number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;

  aboutToAppear(): void {
    console.log(`任务主题:${this.taskTimeRange.taskTheme} 任务竖直偏移:${this.taskTimeRange.beginHeightOffset}`);
  }

  build() {
    Column() {
      Text(this.taskTimeRange.taskTheme)
        .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 10 : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? 15 : 20)
        .fontColor(Color.Black)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines((this.taskTimeRange.endHeightOffset - this.taskTimeRange.beginHeightOffset) / 10)
    }
    .width(this.taskColumnWidth)
    .height(this.taskTimeRange.endHeightOffset - this.taskTimeRange.beginHeightOffset)
    .backgroundColor(addTransparency(hex2rgb(this.taskTypeColorMap[this.taskTimeRange.taskType]), 0.3))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .alignRules({
      left: { anchor: '__container__', align: HorizontalAlign.Start },
      top: { anchor: '__container__', align: VerticalAlign.Top }
    })
    .offset({
      // x : (this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ? 8 : 23) + this.offsetX,
      y : this.taskTimeRange.beginHeightOffset
    })
  }
}