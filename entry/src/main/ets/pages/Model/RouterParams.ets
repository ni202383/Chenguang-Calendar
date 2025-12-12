import { ordinaryAlmanacOfDay } from "./LunarCalendar";

export class RouterToAlmanacParams{
  private currentYear : number;
  private currentMonth : number;
  private currentDay : number;
  private ordinaryAlmanac : ordinaryAlmanacOfDay;

  constructor();

  constructor(currentYear: number,currentMonth : number,currentDay : number,ordinaryAlmanac : ordinaryAlmanacOfDay);

  constructor(currentYear ?: number,currentMonth ?: number,currentDay ?: number,ordinaryAlmanac ?: ordinaryAlmanacOfDay) {
    this.currentYear = currentYear ?? new Date().getFullYear();
    this.currentMonth = currentMonth ?? new Date().getMonth() + 1;
    this.currentDay = currentDay ?? new Date().getDate();
    this.ordinaryAlmanac = ordinaryAlmanac ?? new ordinaryAlmanacOfDay();
  }

  public getCurrentYear(){
    return this.currentYear;
  }
  public getCurrentMonth(){
    return this.currentMonth;
  }
  public getCurrentDay(){
    return this.currentDay;
  }
  public getOrdinaryAlmanac(){
    return this.ordinaryAlmanac;
  }
}