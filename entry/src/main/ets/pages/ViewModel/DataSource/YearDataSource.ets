import { PerYearInfo } from "../../Model/PerYearInfo";
import { fetchYearData } from "../YearViewData";

export class YearDataSource implements IDataSource{

  private baseYear : number;

  private count : number = 1000;
  private initialIndex : number = 500;

  constructor(year : number) {
    this.baseYear = year;
  }

  private YearCache : Map<number,PerYearInfo> = new Map();

  public getInitialIndex(){
    return this.initialIndex;
  }

  totalCount(): number {
    return this.count;
  }

  getData(index: number): PerYearInfo {
    const offsetYear = index - this.initialIndex;
    const key = this.baseYear + offsetYear;
    let yearInfo = this.YearCache.get(key);
    if(!yearInfo){
      yearInfo = fetchYearData(this.baseYear + offsetYear);
      this.YearCache.set(key,yearInfo);
    }
    return yearInfo;
  }

  registerDataChangeListener(listener: DataChangeListener): void {}

  unregisterDataChangeListener(listener: DataChangeListener): void {}

}