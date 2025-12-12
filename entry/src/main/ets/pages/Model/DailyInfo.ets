import { Solar } from "lunar4oh";
import { ordinaryAlmanacOfDay } from "./LunarCalendar";

export class DailyInfo{
  private year: number;
  private month: number;
  private day: number;
  private week: number;
  private isCurrentMonth: boolean;
  private isSelected: boolean;
  private isSelectedAndAddThemeBackgroundColor: boolean;
  private lunarMonth: number;
  private lunarDate: ordinaryAlmanacOfDay;
  private lunarDateText: string;
  private Festival: Array<string>;
  private otherFestival: Array<string>;
  private solarTerm: string;

  constructor();

  constructor(year: number, month: number, day: number, week: number, isCurrentMonth: boolean,
    isSelected: boolean, isSelectedAndAddThemeBackgroundColor: boolean, lunarMonth: number,
    lunarDate: ordinaryAlmanacOfDay, lunarDateText: string, Festival: Array<string>, otherFestival: Array<string>,
    solarTerm: string);

  constructor(year ?: number, month ?: number, day ?: number, week ?: number, isCurrentMonth ?: boolean,
    isSelected ?: boolean, isSelectedAndAddThemeBackgroundColor ?: boolean, lunarMonth ?: number,
    lunarDate ?: ordinaryAlmanacOfDay, lunarDateText ?: string, Festival ?: Array<string>, otherFestival ?: Array<string>,
    solarTerm ?: string) {
    const currentYear = new Date().getFullYear();
    const currentMonth = new Date().getMonth() + 1;
    const currentDay = new Date().getDate();
    const solar = Solar.fromYmd(currentYear,currentMonth,currentDay);
    const currentLunarMonth = solar.getLunar().getMonth();
    this.year = year ?? currentYear;
    this.month = month ?? currentMonth;
    this.day = day ?? currentDay;
    this.week = week ?? new Date().getDay();
    this.isCurrentMonth = isCurrentMonth ?? true;
    this.isSelected = isSelected ?? false;
    this.isSelectedAndAddThemeBackgroundColor = isSelectedAndAddThemeBackgroundColor ?? false;
    this.lunarMonth = lunarMonth ?? currentLunarMonth;
    this.lunarDate = lunarDate ?? new ordinaryAlmanacOfDay();
    this.lunarDateText = lunarDateText ?? '';
    this.Festival = Festival ?? [''];
    this.otherFestival = otherFestival ?? [''];
    this.solarTerm = solarTerm ?? '';
  }

  public getYear() {
    return this.year;
  }

  public getMonth() {
    return this.month;
  }

  public getDay() {
    return this.day;
  }

  public getWeek() {
    return this.week;
  }

  public getIsSelected() {
    return this.isSelected;
  }

  public getIsSelectedAndAddThemeBackgroundColor() {
    return this.isSelectedAndAddThemeBackgroundColor;
  }

  public getLunarMonth() {
    return this.lunarMonth;
  }

  public getIsCurrentMonth() {
    return this.isCurrentMonth;
  }

  public getOrdinaryAlmanacOfDay() {
    return this.lunarDate;
  }

  public getLunarDateText() {
    return this.lunarDateText;
  }

  public getFestival() {
    return this.Festival;
  }

  public getOtherFestival() {
    return this.otherFestival;
  }

  public getSolarTerm() {
    return this.solarTerm;
  }

}