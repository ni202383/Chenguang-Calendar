import { PerMonthInfoInYearView } from "./PerMonthInfoInYearView";

export class PerYearInfo{
  private year : number;
  private monthInfo : Array<PerMonthInfoInYearView>;

  constructor();
  constructor(year : number,monthInfo : Array<PerMonthInfoInYearView>);
  constructor(year ?: number,monthInfo ?: Array<PerMonthInfoInYearView>) {
    this.year = year ?? new Date().getFullYear();
    this.monthInfo = monthInfo ?? [];
  }

  public getYear(){
    return this.year;
  }

  public getMonthInfo(){
    return this.monthInfo;
  }

}