import { Task } from "../../Model/DailyTask";
import { PerDayInfo } from "../../Model/PerDayInfo";
import { taskStore } from "../../Model/TaskStore";

export class DayDataSource implements IDataSource{
  private baseYear : number;
  private baseMonth : number;
  private baseDay : number;

  private readonly count: number = 48000 * 7;
  private readonly initialIndex: number = 24000 * 7;

  constructor(year : number,month : number,day : number) {
    this.baseYear = year;
    this.baseMonth = month;
    this.baseDay = day;
  }

  private dayCache : Map<string,PerDayInfo> = new Map();

  public getInitialIndex(){
    return this.initialIndex;
  }

  totalCount(): number {
    return this.count;
  }

  getData(index: number): PerDayInfo {
    let offsetDay = index - this.initialIndex;
    let targetDate = new Date(this.baseYear,this.baseMonth - 1,this.baseDay + offsetDay);
    let targetYear = targetDate.getFullYear();
    let targetMonth = targetDate.getMonth() + 1;
    let targetDay = targetDate.getDate();

    let key = `${targetYear}-${targetMonth}-${targetDay}`;
    let dayInfo = this.dayCache.get(key);
    if(!dayInfo){
      let dailyTask = taskStore.getTask(targetYear,targetMonth,targetDay);
      dayInfo = new PerDayInfo(targetYear,targetMonth,targetDay,dailyTask);
      this.dayCache.set(key,dayInfo);
    }
    return dayInfo;
  }

  registerDataChangeListener(listener: DataChangeListener): void {

  }

  unregisterDataChangeListener(listener: DataChangeListener): void {

  }

}