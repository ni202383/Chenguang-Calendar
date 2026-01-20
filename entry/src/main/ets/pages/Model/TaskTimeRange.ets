import { TaskType } from "./enum/TaskTypeEnum";

@Observed
export class TaskTimeRange{
  private _beginHeightOffset: number;

  public get beginHeightOffset(): number {
    return this._beginHeightOffset;
  }

  private _endHeightOffset: number;

  public get endHeightOffset(): number {
    return this._endHeightOffset;
  }

  private _taskTheme: string;

  public get taskTheme(): string {
    return this._taskTheme;
  }

  private _taskType: TaskType;

  public get taskType(): TaskType {
    return this._taskType;
  }
  constructor();
  constructor(beginHeightOffset : number,endHeightOffset : number,taskTheme : string,taskType : TaskType);
  constructor(beginHeightOffset ?: number,endHeightOffset ?: number,taskTheme ?: string,taskType ?: TaskType) {
    this._beginHeightOffset = beginHeightOffset ?? -1;
    this._endHeightOffset = endHeightOffset ?? -1;
    this._taskTheme = taskTheme ?? '';
    this._taskType = taskType ?? TaskType.Work;
  }
}

@Observed
export class DailyTaskTimeRange{
  private _year: number;

  public set year(value: number) {
    this._year = value;
  }

  public get year(): number {
    return this._year;
  }

  private _month: number;

  public set month(value: number) {
    this._month = value;
  }

  public get month(): number {
    return this._month;
  }

  private _day: number;

  public set day(value: number) {
    this._day = value;
  }

  public get day(): number {
    return this._day;
  }

  private _taskTimeRange: Array<TaskTimeRange>;

  public set taskTimeRange(value: Array<TaskTimeRange>) {
    this._taskTimeRange = value;
  }

  public get taskTimeRange(): Array<TaskTimeRange> {
    return this._taskTimeRange;
  }
  constructor();
  constructor(year : number,month : number,day : number,taskTimeRange : Array<TaskTimeRange>);
  constructor(year ?: number,month ?: number,day ?: number,taskTimeRange ?: Array<TaskTimeRange>) {
    this._year = year ?? new Date().getFullYear();
    this._month = month ?? new Date().getMonth() + 1;
    this._day = day ?? new Date().getDate();
    this._taskTimeRange = taskTimeRange ?? [];
  }
}