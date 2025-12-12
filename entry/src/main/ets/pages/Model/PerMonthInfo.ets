import { DailyInfo } from "./DailyInfo";

export class PerMonthInfo{
  private year : number;
  private month : number;
  private selectedDay : number;
  private monthData : Array<DailyInfo>;

  constructor();
  constructor(year : number,month : number,monthData : Array<DailyInfo>)
  constructor(year ?: number,month ?: number,monthData ?: Array<DailyInfo>) {
    this.year = year ?? new Date().getFullYear();
    this.month = month ?? new Date().getMonth() + 1;
    this.monthData = monthData ?? [];
    this.selectedDay = year == new Date().getFullYear() && month == new Date().getMonth() + 1 ? new Date().getDate() : 1;
  }

  public getYear(){
    return this.year;
  }

  public getMonth(){
    return this.month;
  }

  public getMonthData(){
    return this.monthData;
  }

  public setSelectedDay(selectedDay : number){
    this.selectedDay = selectedDay;
  }

  public getSelectedDay(){
    return this.selectedDay;
  }
}