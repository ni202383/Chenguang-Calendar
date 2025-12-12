import { PerWeekInfo } from '../../Model/PerWeekInfo';
import {fetchWeekData} from '../WeekViewData'

export class WeekDataSource implements IDataSource {
  private baseYear: number;
  private baseMonth: number;
  private baseDay: number;

  // 总周数（随便给大点，左右滑很多年都不越界）
  private readonly count: number = 48000;
  private readonly initialIndex: number = 24000;

  // ✅ 周缓存：避免重复算同一周
  private weekCache: Map<string, PerWeekInfo> = new Map();

  constructor(year: number, month: number, day: number) {
    this.baseYear = year;
    this.baseMonth = month;
    this.baseDay = day;
  }

  public getInitialIndex(): number {
    return this.initialIndex;
  }

  totalCount(): number {
    return this.count;
  }

  getData(index: number): PerWeekInfo {
    // index == initialIndex 这一项 → 就是「包含 baseYear/baseMonth/baseDay 的那一周」
    const offsetWeeks: number = index - this.initialIndex;

    // 以当前选中日期为基准
    const baseDate = new Date(this.baseYear, this.baseMonth - 1, this.baseDay);
    const targetDate = new Date(baseDate);
    // 每滑动一页 → ±7 天
    targetDate.setDate(targetDate.getDate() + offsetWeeks * 7);

    const targetYear = targetDate.getFullYear();
    const targetMonth = targetDate.getMonth() + 1;
    const targetDay = targetDate.getDate();

    const key = `${targetYear}-${targetMonth}-${targetDay}`;

    let weekInfo = this.weekCache.get(key);
    if (!weekInfo) {
      // 只在第一次真正计算这一周
      const weekData = fetchWeekData(targetYear, targetMonth, targetDay);
      weekInfo = new PerWeekInfo(targetYear, targetMonth, targetDay, weekData);
      this.weekCache.set(key, weekInfo);
    }

    return weekInfo;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    // 如果以后周数据会变，可以在这里手动调用 listener.onDataReloaded() 之类
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {}
}
