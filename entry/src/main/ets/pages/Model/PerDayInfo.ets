import { Task } from "./DailyTask";

export class PerDayInfo{
  private year : number;
  private month : number;
  private day : number;
  private task : Array<Task>;

  constructor();
  constructor(year : number,month : number,day : number,task : Array<Task>);
  constructor(year ?: number,month ?: number,day ?: number,task ?: Array<Task>) {
    this.year = year ?? new Date().getFullYear();
    this.month = month ?? new Date().getMonth() + 1;
    this.day = day ?? new Date().getDate();
    this.task = task ?? [];
  }

  public getYear(){
    return this.year;
  }

  public getMonth(){
    return this.month;
  }

  public getDay(){
    return this.day;
  }

  public getTask(){
    return this.task;
  }
}