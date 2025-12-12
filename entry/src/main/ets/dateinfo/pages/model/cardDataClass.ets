import { cardAlmanacData } from "./cardAlmanacData";

export class cardDataClass {
  private year: number;
  private month: number;
  private day: number;
  private lunarYear: number;
  private lunarMonth: number;
  private lunarDay: number;
  private lunarText : string;
  private festival: Array<string>;
  private otherFestival: Array<string>;
  private almanacData: cardAlmanacData;
  private yearInGanzhi: string;
  private monthInGanzhi: string;
  private dayInGanzhi: string;
  private yearInShengxiao: string;

  constructor();

  constructor(year: number, month: number, day: number, lunarYear: number, lunarMonth: number, lunarDay: number,lunarText : string,
    festival: Array<string>, otherFestival: Array<string>, almanacData: cardAlmanacData,
    yearInGanzhi: string, monthInGanzhi: string, dayInGanzhi: string, yearInShengxiao: string);

  constructor(year ?: number, month ?: number, day ?: number, lunarYear ?: number, lunarMonth ?: number,
    lunarDay ?: number,lunarText ?: string, festival ?: Array<string>, otherFestival ?: Array<string>, almanacData ?: cardAlmanacData,
    yearInGanzhi ?: string, monthInGanzhi ?: string, dayInGanzhi ?: string, yearInShengxiao ?: string) {
    this.year = year ?? new Date().getFullYear();
    this.month = month ?? new Date().getMonth() + 1;
    this.day = day ?? new Date().getDate();
    this.lunarYear = lunarYear ?? 0;
    this.lunarMonth = lunarMonth ?? 0;
    this.lunarDay = lunarDay ?? 0;
    this.lunarText = lunarText ?? '';
    this.festival = festival ?? [];
    this.otherFestival = otherFestival ?? [];
    this.almanacData = almanacData ?? new cardAlmanacData();
    this.yearInGanzhi = yearInGanzhi ?? '';
    this.monthInGanzhi = monthInGanzhi ?? '';
    this.dayInGanzhi = dayInGanzhi ?? '';
    this.yearInShengxiao = yearInShengxiao ?? '';
  }

  public getMonth() {
    return this.month;
  }

  public getYear() {
    return this.year;
  }

  public getDay() {
    return this.day;
  }

  public getLunarYear(){
    return this.lunarYear;
  }

  public getLunarMonth(){
    return this.lunarMonth
  }

  public getLunarDay(){
    return this.lunarDay;
  }

  public getLunarText(){
    return this.lunarText;
  }

  public getFestival() {
    return this.festival;
  }

  public getOtherFestival() {
    return this.otherFestival;
  }

  public getAlmanacData() {
    return this.almanacData;
  }

  public getYearInGanzhi() {
    return this.yearInGanzhi;
  }

  public getMonthInGanzhi() {
    return this.monthInGanzhi;
  }

  public getDayInGanzhi() {
    return this.dayInGanzhi;
  }

  public getYearInShengxiao() {
    return this.yearInShengxiao;
  }
}