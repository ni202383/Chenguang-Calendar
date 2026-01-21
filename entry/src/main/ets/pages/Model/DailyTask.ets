import { TaskType } from "./Enum";
import { RemindTime, RemindTimePlain } from "./RemindTimeBase";

export interface TaskPlain {
  id: string;
  title: string;
  selectedDate: string;
  beginHour: number;
  beginMinute: number;
  endHour: number;
  endMinute: number;
  isSelectedEndTime : boolean;
  location: string;
  detail: string;
  remindTime: Array<RemindTimePlain>;
  taskType: TaskType;
}

@Observed
export class Task {
  private id: string;
  private title: string;
  private selectedDate: Date;
  private beginHour: number;
  private beginMinute: number;
  private endHour: number;
  private endMinute: number;
  private isSelectedEndTime : boolean;
  private location: string;
  private detail: string;
  private remindTime: Array<RemindTime>;
  private taskType: TaskType;
  static static_number : number = 0;

  constructor();

  constructor(id: string, title: string, selectedDate: Date, beginHour: number, beginMinute: number,
    endHour: number, endMinute: number,isSelectedEndTime : boolean, location: string, detail: string,
    remindTime: Array<RemindTime>, taskType: TaskType);

  constructor(id ?: string, title ?: string, selectedDate ?: Date, beginHour ?: number, beginMinute ?: number,
    endHour ?: number, endMinute ?: number,isSelectedEndTime ?: boolean, location ?: string, detail ?: string,
    remindTime ?: Array<RemindTime>, taskType ?: TaskType) {
    this.id = id ?? '';
    this.title = title ?? '';
    this.selectedDate = selectedDate ?? new Date();
    this.beginHour = beginHour ?? new Date().getHours();
    this.beginMinute = beginMinute ?? new Date().getMinutes();
    this.endHour = endHour ?? this.beginMinute >= 30 ? this.beginHour + 1 : this.beginHour;
    this.endMinute = endMinute ?? this.beginMinute >= 30 ? 0 : 30;
    this.isSelectedEndTime = isSelectedEndTime ?? false;
    this.location = location ?? '';
    this.detail = detail ?? '';
    this.remindTime = remindTime ?? [];
    this.taskType = taskType ?? TaskType.Work;
  }

  public toPlainObject(): TaskPlain {
    return {
      id: this.getId(),
      title: this.getTitle(),
      selectedDate: this.getSelectedDate().toISOString(),
      beginHour: this.getBeginHour(),
      beginMinute: this.getBeginMinute(),
      endHour: this.getEndHour(),
      endMinute: this.getEndMinute(),
      isSelectedEndTime : this.getIsSelectedEndTime(),
      location: this.getLocation(),
      detail: this.getDetail(),
      remindTime: this.getRemindTime().map(rt => rt.toPlainObject()),
      taskType: this.getTaskType()
    };
  }

  public static fromPlainObject(obj: TaskPlain): Task {
    const task = new Task();
    task.setId(obj.id);
    task.setTitle(obj.title);
    task.setSelectedDate(new Date(obj.selectedDate))
    task.setBeginHour(obj.beginHour);
    task.setBeginMinute(obj.beginMinute);
    task.setEndHour(obj.endHour);
    task.setEndMinute(obj.endMinute);
    task.setIsSelectedEndTime(obj.isSelectedEndTime)
    task.setLocation(obj.location);
    task.setDetail(obj.detail)
    task.setRemindTime(obj.remindTime.map(rt => RemindTime.fromPlainObject(rt)));
    task.setTaskType(obj.taskType)
    return task;
  }

  public setId(id: string) {
    this.id = id;
  }

  public getId() {
    return this.id;
  }

  public setTitle(title: string) {
    this.title = title;
  }

  public getTitle() {
    return this.title;
  }

  public setSelectedDate(selectedDate: Date) {
    this.selectedDate = selectedDate;
  }

  public getSelectedDate() {
    return this.selectedDate;
  }

  public setBeginHour(beginHour: number) {
    this.beginHour = beginHour;
  }

  public getBeginHour() {
    return this.beginHour;
  }

  public setBeginMinute(beginMinute: number) {
    this.beginMinute = beginMinute;
  }

  public getBeginMinute() {
    return this.beginMinute;
  }

  public setEndHour(endHour: number) {
    this.endHour = endHour;
  }

  public getEndHour() {
    return this.endHour;
  }

  public setEndMinute(endMinute: number) {
    this.endMinute = endMinute;
  }

  public getEndMinute() {
    return this.endMinute;
  }

  public setIsSelectedEndTime(isSelectedEndTime : boolean){
    this.isSelectedEndTime = isSelectedEndTime;
  }

  public getIsSelectedEndTime(){
    return this.isSelectedEndTime;
  }

  public setLocation(location: string) {
    this.location = location;
  }

  public getLocation() {
    return this.location;
  }

  public setDetail(detail: string) {
    this.detail = detail;
  }

  public getDetail() {
    return this.detail;
  }

  public setRemindTime(remindTime: Array<RemindTime>) {
    this.remindTime = remindTime;
  }

  public getRemindTime() {
    return this.remindTime;
  }

  public addRemindTime(remindTime: RemindTime) {
    this.remindTime.push(remindTime);
  }

  public setTaskType(taskType: TaskType) {
    this.taskType = taskType;
  }

  public getTaskType() {
    return this.taskType;
  }
}

export class dailyScheduleItemParamType {
  title: string = '';
  timeDiscription: string = '';
  pickDialog: () => void = () => {
  };
}