import { BasicConstant } from "../../../Constants/BasicConstant"
import { dailyScheduleItemParamType, Task } from '../../Model/DailyTask'
import { CustomContentDialog, AlertDialog } from '@kit.ArkUI'
import { DialogSelectRemindTimePerList } from "./DialogSelectRemindTimePerList"
import { addTransparency, find, hexToRgb, isNormalTimeSchedule } from "../../../Utils/ViewUtils"
import { TaskType } from "../../Model/enum/TaskTypeEnum"
import { CustomButtonInRemindTimeDialog } from "./CustomButtonInRemindTimeDialog"
import { CustomListInRemindTimeDialog } from "./CustomListInRemindTimeDialog"
import { generateRemindTimeListInfo, RemindTime, sortRemindTimeList } from "../../Model/RemindTimeBase"
import { taskStore } from '../../Model/TaskStore'
import { BreakpointConstant } from "../../../Constants/BreakpointConstant"
import { updateScheduleReminders } from "../../../Utils/ReminderNotification"
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ViewArkUIConstant } from "../../../Constants/ArkUIConstant"


@Extend(Divider)
function dividerStyle() {
  .vertical(false)
  .color($r('app.color.backgroundcolor'))
  .strokeWidth(1)
  .width('95%')
}

@Extend(TextInput)
function textInputStyle(height: number) {
  .placeholderColor($r('app.color.gray_deeper'))
  .backgroundColor(Color.White)
  .width(BasicConstant.FULL_WIDTH)
  .height(height)
  .padding({
    top: 4,
    bottom: 4,
    left: 8,
    right: 8
  })
}

@Extend(Button)
function taskTypeStyle(color: string | Resource) { //任务类型按钮样式
  .width('45%')
  .height(30)
  .backgroundColor(color)
}

@Extend(Text)
function titleTextStylePerItem() {
  .fontSize(ViewArkUIConstant.TASK_DETAIL_TITLE_PER_ITEM_FONT_SIZE)
  .fontWeight(FontWeight.Bold)
}

@Component
export struct RealDailyScheduleWithoutScroll {
  isNewDailyTask: boolean = false;
  isUpdateDailyTask: boolean = false;
  @Link ensureUpdateDailyTask: boolean; //修改日程时点击确定按钮能够有动画的关闭
  @Link @Watch('deleteThisTask') isDeleteThisTask: boolean;
  @Link @Watch('saveThisTask') returnEnsureSave: boolean;
  @StorageProp('themeColor') themeColor: string = '';
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  // @StorageLink('selectedDateInMonthView') selectDateInMonthView: Date = new Date();
  @Prop newDailySchedule: Task = new Task();
  newDailySchedule_: Task = new Task();
  @StorageLink('isRenewDailySchedule') @Watch('updateDailySchedule') isRenewDailySchedule: boolean = false;
  @StorageLink('isChange') isChange: boolean = false; //用于点击新建日程的按钮后若没有做修改，就直接关闭，无是否保存的弹窗
  // @State selectedDate: Date = this.selectDateInMonthView;
  @Prop @Watch('updateDialogRemindTimeListState') isZero: boolean = true;
  @StorageLink('selectedRemindTimeNumber') selectedRemindTimeNumber: number = 0;
  @State DialogSelectRemindTimeList: Array<RemindTime> = generateRemindTimeListInfo();
  private workColor: string = '#E31818';
  private lifeColor: string = '#58EF1A';
  private entertainmentColor: string = '#AB1AC2';
  private self_disciplineColor: string = '#22E7D0';
  @State @Watch('isChangeDailyTask') selectedTaskTypeIndex: number =
    this.isNewDailyTask ? 0 : this.newDailySchedule.getTaskType() == TaskType.Work ? 0 :
      this.newDailySchedule.getTaskType() == TaskType.life ? 1 :
        this.newDailySchedule.getTaskType() == TaskType.Entertainment ? 2 : 3; //选择的任务类型下标
  @State isClickCustomRemindTime: boolean = false; //提醒时间滑动窗口是否点击自定义时间
  @State customRemindTimeList: Array<RemindTime> = []; //提醒时间滑动窗口自定义时间列表
  @State @Watch('isChangeDailyTask') remindTimeArray: Array<RemindTime> =
    this.newDailySchedule.getRemindTime(); //最终确定的提醒时间
  private deletingRemindTime: RemindTime = new RemindTime();
  @StorageLink('isCloseNewDailyTask') isCloseNewDailyTask: boolean = false; //新建日程点击确定按钮后到Index触发关闭新建日程弹窗
  @StorageLink('reloadTask') reloadTask: boolean = false; //新建任务时点击确认按钮符合要求就重新更新日程视图，显示日程
  @StorageLink('updated') updated: boolean = false;

  deleteThisTask() {
    if (this.isDeleteThisTask == true) {
      taskStore.deleteTask(
        this.newDailySchedule_.getSelectedDate().getFullYear(),
        this.newDailySchedule_.getSelectedDate().getMonth() + 1,
        this.newDailySchedule_.getSelectedDate().getDate(),
        this.newDailySchedule_
      )
      this.isDeleteThisTask = false;
      this.reloadTask = !this.reloadTask;
    }
  }

  updateDailySchedule() {
    if (this.isRenewDailySchedule == true) {
      this.newDailySchedule = new Task();
      this.isRenewDailySchedule = false;
    }
  }

  isChangeDailyTask() {
    this.isChange = true;
  }

  @Builder
  dialogSelectRemindTimeList() { //提醒时间选择弹窗
    Column() {
      Scroll() {
        Column() {
          ForEach(this.DialogSelectRemindTimeList, (item: RemindTime,
            index: number) => { //可供选择的时间列表
            DialogSelectRemindTimePerList({
              item: item,
              isZero: this.isZero,
              selectedRemindTimeNumber: this.selectedRemindTimeNumber,
              index: index
            })
          }, (item: RemindTime) => item.toString())

          Stack() { //自定义提醒时间开关
            Row() {
              Text('自定义')
                .fontSize(ViewArkUIConstant.ADD_TASK_REMINDER_TIME_FONT_SIZE)
              Image(this.isClickCustomRemindTime ? $r('app.media.chevron_up') : $r('app.media.chevron_down'))
                .width(ViewArkUIConstant.ADD_TASK_CUSTOMIZE_IMAGE_WIDTH)
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(ViewArkUIConstant.ADD_TASK_PER_REMINDER_ROW_HEIGHT)
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)

            Button()
              .width(BasicConstant.FULL_WIDTH)
              .backgroundColor(Color.Transparent)
              .borderRadius(ViewArkUIConstant.ADD_TASK_PER_REMINDER_BUTTON_BORDER_RADIUS)
              .onClick((event: ClickEvent) => {
                this.isClickCustomRemindTime = !this.isClickCustomRemindTime;
              })
          }

          if (this.isClickCustomRemindTime) {
            Divider().dividerStyle()

            ForEach(this.customRemindTimeList, (item: RemindTime,
              index: number) => { //自定义提醒时间列表
              CustomListInRemindTimeDialog({
                item: item,
                isZero: this.isZero,
                selectedRemindTimeNumber: this.selectedRemindTimeNumber
              })
            }, (item: RemindTime) => item.toString())

            Stack() {
              Row() {
                Text('点击添加自定义时间')
                  .fontSize(ViewArkUIConstant.ADD_TASK_REMINDER_TIME_FONT_SIZE)
                  .fontColor(this.themeColor)
              }
              .width(BasicConstant.FULL_WIDTH)
              .height(ViewArkUIConstant.ADD_TASK_PER_REMINDER_ROW_HEIGHT)
              .justifyContent(FlexAlign.Start)
              .alignItems(VerticalAlign.Center)

              CustomButtonInRemindTimeDialog({
                customRemindTimeList: this.customRemindTimeList,
                selectedRemindTimeNumber: this.selectedRemindTimeNumber,
                isZero: this.isZero
              })
            }
          }
        }
      }
      .width(BasicConstant.FULL_WIDTH)
      .height(ViewArkUIConstant.CUSTOMIZED_SELECT_REMIND_TIME_DIALOG_HEIGHT)
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(ViewArkUIConstant.CUSTOMIZED_SELECT_REMIND_TIME_DIALOG_HEIGHT)
  }

  @Builder
  taskTypeButton(type: string, color: string, index: number, taskType: TaskType) { //工作类型按钮
    Button(type)
      .fontSize(ViewArkUIConstant.ADD_TASK_TASK_TYPE_BUTTON_FONT_SIZE)
      .fontColor(this.selectedTaskTypeIndex == index ? color : Color.Black)
      .taskTypeStyle(this.selectedTaskTypeIndex == index ? addTransparency(hexToRgb(color),
        ViewArkUIConstant.ADD_TASK_TASK_TYPE_BUTTON_BACKGROUND_COLOR_TRANSPARENCY) : $r('app.color.backgroundcolor'))
      .onClick((event: ClickEvent) => {
        this.selectedTaskTypeIndex = index;
        this.newDailySchedule.setTaskType(taskType)
      })
  }

  updateDialogRemindTimeListState() { //更新在日程选择时的选择逻辑
    if (this.isZero == false) {
      this.DialogSelectRemindTimeList[ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX].setIsSelect(false);
    } else {
      if (this.selectedRemindTimeNumber != ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX) {
        for (let i = ViewArkUIConstant.ADD_TASK_NOTIFY_IMMEDIATELY_INDEX; i < this.DialogSelectRemindTimeList.length; ++i) {
          this.DialogSelectRemindTimeList[i].setIsSelect(false);
        }
        for (let i = ViewArkUIConstant.ADD_TASK_CUSTOMIZED_TIME_FIRST_INDEX; i < this.customRemindTimeList.length; ++i) {
          this.customRemindTimeList[i].setIsSelect(false);
        }
      } else {
        this.DialogSelectRemindTimeList[ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX].setIsSelect(true);
      }
    }
  }

  dialogListController: CustomDialogController = new CustomDialogController({
    //添加日程提醒控制器
    builder: CustomContentDialog({
      primaryTitle: '添加日程提醒',
      contentBuilder: () => {
        this.dialogSelectRemindTimeList();
      },
      buttons: [
        {
          value: '取消',
          fontColor: this.themeColor,
          action: () => {
            this.DialogSelectRemindTimeList[ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX].setIsSelect(true);
            for (let i = ViewArkUIConstant.ADD_TASK_NOTIFY_IMMEDIATELY_INDEX; i < this.DialogSelectRemindTimeList.length; ++i) {
              this.DialogSelectRemindTimeList[i].setIsSelect(false);
            }
            this.customRemindTimeList = [];
            this.isClickCustomRemindTime = false;
            this.isZero = true;
            this.selectedRemindTimeNumber = 0;
          }
        },
        {
          value: '确定',
          fontColor: this.themeColor,
          action: async () => {
            if (this.DialogSelectRemindTimeList[ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX].getIsSelect() == false) {
              for (let i = ViewArkUIConstant.ADD_TASK_NOTIFY_IMMEDIATELY_INDEX; i < this.DialogSelectRemindTimeList.length; ++i) {
                if (this.DialogSelectRemindTimeList[i].getIsSelect() == true) {
                  this.remindTimeArray.push(this.DialogSelectRemindTimeList[i]);
                }
              }
              for (let i = ViewArkUIConstant.ADD_TASK_CUSTOMIZED_TIME_FIRST_INDEX; i < this.customRemindTimeList.length; ++i) {
                if (this.customRemindTimeList[i].getIsSelect() == true) {
                  this.remindTimeArray.push(this.customRemindTimeList[i]);
                }
              }
              this.remindTimeArray = sortRemindTimeList(this.remindTimeArray);
              await updateScheduleReminders(
                this.newDailySchedule.getSelectedDate().getFullYear(),
                this.newDailySchedule.getSelectedDate().getMonth() + 1,
                this.newDailySchedule.getSelectedDate().getDate(),
                this.newDailySchedule.getBeginHour(),
                this.newDailySchedule.getBeginMinute(),
                this.newDailySchedule.getTitle(),
                this.remindTimeArray
              )

              this.DialogSelectRemindTimeList[ViewArkUIConstant.ADD_TASK_NONE_REMINDER_INDEX].setIsSelect(true);
              for (let i = ViewArkUIConstant.ADD_TASK_NOTIFY_IMMEDIATELY_INDEX; i < this.DialogSelectRemindTimeList.length; ++i) {
                this.DialogSelectRemindTimeList[i].setIsSelect(false);
              }
              this.customRemindTimeList = [];
              this.isClickCustomRemindTime = false;
              this.isZero = true;
              this.selectedRemindTimeNumber = 0;
            }
          }
        }
      ]
    })
  })
  deleteRemindTimeDialog: CustomDialogController = new CustomDialogController({
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
          let deleteIndex = find<RemindTime>(
            this.remindTimeArray,
            this.deletingRemindTime,
            (first: RemindTime, second: RemindTime) => {
              if (first.toMinutes() < second.toMinutes()) return ViewArkUIConstant.REMIND_TIME_SHORTER;
              else if (first.toMinutes() == second.toMinutes()) return ViewArkUIConstant.REMIND_TIME_EQUAL;
              else return ViewArkUIConstant.REMIND_TIME_BIGGER;
            }
          );

          if (deleteIndex >= 0) {
            const rt = this.remindTimeArray[deleteIndex];
            const reminderId = rt.getRemindTimeID();

            if (reminderId > 0) {
              reminderAgentManager.cancelReminder(reminderId)
                .then(() => {
                  console.info(`[deleteRemindTimeDialog] 取消系统提醒成功 id=${reminderId}`);
                })
                .catch((err: BusinessError) => {
                  if (err.code === ViewArkUIConstant.DELETE_REMIND_TIME_ERROR_CODE) {
                    console.info(
                      `[deleteRemindTimeDialog] 系统中已经没有这个提醒 id=${reminderId}，忽略`
                    );
                  } else {
                    console.error(
                      `[deleteRemindTimeDialog] 取消系统提醒失败 id=${reminderId}, code=${err.code}, msg=${err.message}`
                    );
                  }
                })
            }
          }
          this.remindTimeArray.splice(deleteIndex, 1);
        }
      }
    })
  })
  submitDailyTaskIncompleteDialogController: CustomDialogController = new CustomDialogController({
    builder: CustomContentDialog({
      primaryTitle: '日程信息不完整哦~',
      contentBuilder: () => {
        this.submitDailyTaskIncompleteDialogControllerText()
      },
      buttons: [
        {
          value: '确定',
          fontColor: this.themeColor,
          action: () => {
            this.submitDailyTaskIncompleteDialogController.close();
          }
        }
      ]
    })
  })

  @Builder
  submitDailyTaskIncompleteDialogControllerText() {
    Column() {
      Text('请完善好信息再保存哦~')
        .fontSize(ViewArkUIConstant.SUBMIT_TASK_REMINDER_TEXT_FONT_SIZE)
        .fontColor(Color.Black)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(ViewArkUIConstant.SUBMIT_TASK_REMINDER_TEXT_HEIGHT)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Styles
  columnStyle(){
    .width(BasicConstant.FULL_WIDTH)
    .borderRadius(ViewArkUIConstant.TASK_DETAIL_PER_COLUMN_BORDER_RADIUS)
    .backgroundColor(Color.White)
    .padding(ViewArkUIConstant.TASK_DETAIL_PER_COLUMN_PADDING)
  }

  @Builder
  dailyScheduleItem($$: dailyScheduleItemParamType) { //按钮弹窗
    Button() {
      Row() {
        Text($$.title)
          .fontSize(ViewArkUIConstant.ADD_TASK_TIME_SELECT_TEXT_FONT_SIZE)
          .fontColor($r('app.color.gray_deeper'))
        Row() {
          Text($$.timeDiscription)
            .fontSize(ViewArkUIConstant.ADD_TASK_TIME_SELECT_SELECTED_TIME_FONT_SIZE)
            .fontColor($r('app.color.gray_deeper'))
          Image($r('app.media.chevron_right'))
            .width(ViewArkUIConstant.ADD_TASK_TIME_SELECT_IMAGE_WIDTH)
        }
        .height(BasicConstant.FULL_HEIGHT)
      }
      .width(ViewArkUIConstant.ADD_TASK_TIME_SELECT_ROW_WIDTH_PERCENTAGE)
      .height(BasicConstant.FULL_HEIGHT)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(ViewArkUIConstant.ADD_TASK_TIME_SELECT_BUTTON_HEIGHT)
    .backgroundColor(Color.Transparent)
    .onClick((event: ClickEvent) => {
      $$.pickDialog();
    })
  }

  CalendarPickerDialog = () => {
    CalendarPickerDialog.show({
      selected: this.newDailySchedule.getSelectedDate(),
      onAccept: (value) => {
        this.newDailySchedule.setSelectedDate(value);
        this.isChange = true;
      },
      acceptButtonStyle: {
        fontColor: this.themeColor
      },
      cancelButtonStyle: {
        fontColor: this.themeColor
      }

    })
  }
  beginTimePickerDialog = () => {
    this.getUIContext().showTimePickerDialog({
      useMilitaryTime: ViewArkUIConstant.IS_USE_MILITARY_TIME,
      selectedTextStyle: {
        color: this.themeColor
      },
      acceptButtonStyle: {
        fontColor: this.themeColor
      },
      cancelButtonStyle: {
        fontColor: this.themeColor
      },
      onAccept: (value: TimePickerResult) => {
        this.newDailySchedule.setBeginHour(value.hour);
        this.newDailySchedule.setBeginMinute(value.minute);
        this.isChange = true;
      }
    })
  }
  endTimePickerDialog = () => {
    this.getUIContext().showTimePickerDialog({
      useMilitaryTime: ViewArkUIConstant.IS_USE_MILITARY_TIME,
      selectedTextStyle: {
        color: this.themeColor
      },
      acceptButtonStyle: {
        fontColor: this.themeColor
      },
      cancelButtonStyle: {
        fontColor: this.themeColor
      },
      start: new Date(this.newDailySchedule.getSelectedDate().getFullYear(),
        this.newDailySchedule.getSelectedDate().getMonth(),
        this.newDailySchedule.getSelectedDate().getDate(),
        this.newDailySchedule.getBeginHour(),
        this.newDailySchedule.getBeginMinute()
      ),
      onAccept: (value: TimePickerResult) => {
        this.newDailySchedule.setEndHour(value.hour);
        this.newDailySchedule.setEndMinute(value.minute);
        this.newDailySchedule.setIsSelectedEndTime(true);
      }
    })
  }

  saveThisTask() {
    if (this.isNewDailyTask) {
      taskStore.addTask(
        this.newDailySchedule.getSelectedDate().getFullYear(),
        this.newDailySchedule.getSelectedDate().getMonth() + 1,
        this.newDailySchedule.getSelectedDate().getDate(),
        this.newDailySchedule
      )
      this.newDailySchedule = new Task();
      this.isCloseNewDailyTask = true;
    } else if (this.isUpdateDailyTask) {
      if (taskStore.updateTask(
        this.newDailySchedule.getSelectedDate().getFullYear(),
        this.newDailySchedule.getSelectedDate().getMonth() + 1,
        this.newDailySchedule.getSelectedDate().getDate(),
        this.newDailySchedule
      )) {
        this.updated = !this.updated;
      } else {
        taskStore.addTask(
          this.newDailySchedule.getSelectedDate().getFullYear(),
          this.newDailySchedule.getSelectedDate().getMonth() + 1,
          this.newDailySchedule.getSelectedDate().getDate(),
          this.newDailySchedule
        )
        taskStore.deleteTask(
          this.newDailySchedule_.getSelectedDate().getFullYear(),
          this.newDailySchedule_.getSelectedDate().getMonth() + 1,
          this.newDailySchedule_.getSelectedDate().getDate(),
          this.newDailySchedule_
        )
      }
      this.ensureUpdateDailyTask = true; //返回到日程列表
    }
    this.reloadTask = !this.reloadTask

  } //点击返回键后弹出弹窗点击确定后更新日程

  build() {
    Column() {
      Column({ space: ViewArkUIConstant.TASK_DETAIL_WHOLE_COLUMN_GAP_SPACE }) {
        Text('日程信息')
          .titleTextStylePerItem()

        Column() {
          TextInput({ text: this.newDailySchedule.getTitle(), placeholder: '主题：' })
            .textInputStyle(ViewArkUIConstant.TASK_DETAIL_TEXT_INPUT_HEIGHT)
            .onChange((value) => {
              this.newDailySchedule.setTitle(value);
              this.isChange = true;
            })

          Divider().dividerStyle()

          this.dailyScheduleItem({
            title: '日期',
            timeDiscription: `${this.newDailySchedule.getSelectedDate().getFullYear()}年${
            this.newDailySchedule.getSelectedDate().getMonth() + 1}月${
            this.newDailySchedule.getSelectedDate().getDate()}日`,
            pickDialog: () => {
              this.CalendarPickerDialog();
            }
          })

          Divider().dividerStyle()

          this.dailyScheduleItem({
            title: '开始时间',
            timeDiscription: `${this.newDailySchedule.getBeginHour()
              .toString()
              .padStart(BasicConstant.MAX_LENGTH_TIME, '0')
            } : ${this.newDailySchedule.getBeginMinute().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')}`,
            pickDialog: () => {
              this.beginTimePickerDialog();
            }
          })

          Divider().dividerStyle()

          this.dailyScheduleItem({
            title: '结束时间',
            timeDiscription: `${this.newDailySchedule.getEndHour()
              .toString()
              .padStart(BasicConstant.MAX_LENGTH_TIME, '0')
            } : ${this.newDailySchedule.getEndMinute().toString().padStart(BasicConstant.MAX_LENGTH_TIME, '0')}`,
            pickDialog: () => {
              this.endTimePickerDialog();
            }
          })

          Divider().dividerStyle()


          TextInput({ text: this.newDailySchedule.getLocation(), placeholder: '地点：' })
            .textInputStyle(ViewArkUIConstant.TASK_DETAIL_TEXT_INPUT_HEIGHT)
            .onChange((value) => {
              this.newDailySchedule.setLocation(value);
              this.isChange = true;
            })

          Divider().dividerStyle()

          TextArea({ text: this.newDailySchedule.getDetail(), placeholder: '输入具体信息：' })
            .placeholderColor($r('app.color.gray_deeper'))
            .backgroundColor(Color.White)
            .width(BasicConstant.FULL_WIDTH)
            .height(ViewArkUIConstant.TASK_DETAIL_TEXT_AREA_HEIGHT)
            .padding(ViewArkUIConstant.TASK_DETAIL_TEXT_AREA_PADDING)
            .maxLines(ViewArkUIConstant.TASK_DETAIL_TEXT_AREA_MAX_LINES)
            .maxLength(ViewArkUIConstant.TASK_DETAIL_TEXT_AREA_MAX_LENGTH)
            .barState(BarState.On)
            .onChange((value) => {
              this.newDailySchedule.setDetail(value);
              this.isChange = true;
            })

          Divider().dividerStyle()

          Column() {
            Row({ space: ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_BUTTON_GAP_SPACE }) {
              this.taskTypeButton('工作', this.workColor, ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_WORK_INDEX,
                TaskType.Work)
              this.taskTypeButton('生活', this.lifeColor, ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_LIFE_INDEX,
                TaskType.life)
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(BasicConstant.HALF_HEIGHT)
            .justifyContent(FlexAlign.Center)

            Row({ space: ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_BUTTON_GAP_SPACE }) {
              this.taskTypeButton('娱乐', this.entertainmentColor,
                ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_ENTERTAINMENT_INDEX, TaskType.Entertainment)
              this.taskTypeButton('自律', this.self_disciplineColor,
                ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_SELF_DISCIPLINE_INDEX, TaskType.Self_discipline)
            }
            .width(BasicConstant.FULL_WIDTH)
            .height(BasicConstant.HALF_HEIGHT)
            .justifyContent(FlexAlign.Center)
          }
          .width(BasicConstant.FULL_WIDTH)
          .height(ViewArkUIConstant.TASK_DETAIL_TASK_TYPE_WHOLE_HEIGHT)

        }
        .columnStyle()

        Text('提醒')
          .titleTextStylePerItem()

        Column() {
          this.dailyScheduleItem({
            title: '提醒',
            timeDiscription: this.remindTimeArray.length == 0 ? '还未设置提醒~' :
              `已设置${this.remindTimeArray.length}次提醒`,
            pickDialog: () => {
              this.dialogListController.open();
            }
          })
        }
        .columnStyle()

        Text('已设置提醒')
          .titleTextStylePerItem()

        if (this.remindTimeArray.length == 0) {
          Column() {
            Image($r('app.media.empty_notification'))
              .width(BasicConstant.HALF_WIDTH)
          }
          .width(BasicConstant.FULL_WIDTH)
          .height(ViewArkUIConstant.TASK_DETAIL_NONE_SET_REMINDER_COLUMN_HEIGHT)
          .margin({ top: ViewArkUIConstant.TASK_DETAIL_NONE_SET_REMINDER_COLUMN_MARGIN_TOP })
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        } else {
          Column() {
            ForEach(this.remindTimeArray, (item: RemindTime, index: number) => {
              Row() {
                Text(item.getRemindTime() == 0 ? '立刻' : `${item.getRemindTime()}${item.getUnit()}前`)
                  .fontSize(ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_FONT_SIZE)
                Button({ type: ButtonType.Circle }) {
                  Image($r('app.media.delete'))
                    .width(ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_DELETE_IMAGE_WIDTH_PERCENTAGE)
                }
                .width(ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_DELETE_BUTTON_WIDTH)
                .backgroundColor(Color.White)
                .onClick((event: ClickEvent) => {
                  this.deletingRemindTime = item;
                  this.deleteRemindTimeDialog.open();
                })
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .height(ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_HEIGHT)
              .alignItems(VerticalAlign.Center)
              .width(BasicConstant.FULL_WIDTH)
              .padding({
                left: ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_PADDING_LEFT_RIGHT,
                right: ViewArkUIConstant.TASK_DETAIL_SET_REMINDER_PADDING_LEFT_RIGHT
              })

              if (index != this.remindTimeArray.length - 1) {
                Divider().dividerStyle()
              }
            }, (item: RemindTime) => item.toString())
          }
          .columnStyle()

        }

        Button('确定')
          .fontSize(ViewArkUIConstant.TASK_DETAIL_ENSURE_BUTTON_FONT_SIZE)
          .fontColor(Color.White)
          .backgroundColor(this.themeColor)
          .width(BasicConstant.FULL_WIDTH)
          .margin({ top: ViewArkUIConstant.TASK_DETAIL_ENSURE_BUTTON_MARGIN_TOP })
          .onClick((event: ClickEvent) => {
            this.newDailySchedule.setRemindTime(this.remindTimeArray);
            if (this.newDailySchedule.getTitle() == '' || this.newDailySchedule.getLocation() == '' ||
              !isNormalTimeSchedule(
                this.newDailySchedule.getBeginHour(),
                this.newDailySchedule.getBeginMinute(),
                this.newDailySchedule.getEndHour(),
                this.newDailySchedule.getEndMinute()
              ) || !isNormalTimeSchedule(
              new Date().getHours(),
              new Date().getMinutes(),
              this.newDailySchedule.getBeginHour(),
              this.newDailySchedule.getBeginMinute()
            )) {
              this.submitDailyTaskIncompleteDialogController.open();
            } else {
              this.saveThisTask();
            }
          })
      }
      .width(this.isUpdateDailyTask ? this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM ?
        BasicConstant.FULL_WIDTH : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ?
          BasicConstant.EIGHTY_PERCENTAGE : BasicConstant.SIXTY_PERCENTAGE : BasicConstant.FULL_WIDTH)
      .alignItems(HorizontalAlign.Start)
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: ViewArkUIConstant.TASK_DETAIL_WHOLE_MARGIN_BOTTOM })
  }
}

