import { PerMonthInfo } from "../../Model/PerMonthInfo";
import { fetchMonthData } from "../MonthViewData";

export class MonthDataSource implements IDataSource{
  private baseYear : number;
  private baseMonth : number;
  private Count : number = 12000;
  private initialIndex : number = 6000;
  private monthCache: Map<string, PerMonthInfo> = new Map();

  constructor(currentYear : number,currentMonth : number) {
    this.baseYear = currentYear;
    this.baseMonth = currentMonth;
  }

  public getInitialIndex(){
    return this.initialIndex;
  }

  totalCount(): number {
    return this.Count;
  }

  getData(index: number): PerMonthInfo {
    const totalOffset = index - this.initialIndex + (this.baseYear * 12 + this.baseMonth - 1);
    const targetYear = Math.floor(totalOffset / 12);
    const targetMonth = (totalOffset % 12 + 12) % 12 + 1;

    const key = `${targetYear}-${targetMonth}`;

    let monthInfo = this.monthCache.get(key);
    if (!monthInfo) {
      //只在第一次真正计算
      const data = fetchMonthData(targetYear, targetMonth);
      monthInfo = new PerMonthInfo(targetYear, targetMonth, data);
      this.monthCache.set(key, monthInfo);
    }

    return monthInfo;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {}

}