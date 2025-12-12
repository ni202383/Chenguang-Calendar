import { DailyInfo } from "./DailyInfo";

export class PerWeekInfo{
  private year : number;
  private month : number;
  private selectedDay : number;
  private weekData : Array<DailyInfo>;

  constructor();
  constructor(year : number,month : number,selectedDay : number,weekData : Array<DailyInfo>);
  constructor(year ?: number,month ?: number,selectedDay ?: number,weekData ?: Array<DailyInfo>) {
    this.year = year ?? 0;
    this.month = month ?? 0;
    this.selectedDay = selectedDay ?? 0;
    this.weekData = weekData ?? [];
  }

  public getYear(){
    return this.year;
  }

  public getMonth(){
    return this.month;
  }

  public getSelectedDay(){
    return this.selectedDay;
  }

  public getWeekData(){
    return this.weekData;
  }

}