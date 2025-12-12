import { DailyInfoBase } from "./DailyInfoBase";

export class PerMonthInfoInYearView{
  private month : number;
  private dailyInfo : Array<DailyInfoBase>;

  constructor();
  constructor(month : number,dailyInfo : Array<DailyInfoBase>);
  constructor(month ?: number,dailyInfo ?: Array<DailyInfoBase>) {
    this.month = month ?? new Date().getMonth() + 1;
    this.dailyInfo = dailyInfo ?? [];
  }

  public getMonth(){
    return this.month;
  }

  public getDailyInfo(){
    return this.dailyInfo;
  }
}