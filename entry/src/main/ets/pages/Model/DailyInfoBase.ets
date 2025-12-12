export class DailyInfoBase{
  private day : number;
  private week : number;
  private isCurrentMonth : boolean;
  private lunarDateText : string;

  constructor();
  constructor(day : number,week : number,isCurrentMonth : boolean,lunarDateText : string);
  constructor(day ?: number,week ?: number,isCurrentMonth ?: boolean,lunarDateText ?: string) {
    this.day = day ?? new Date().getDate();
    this.week = week ?? new Date().getDay();
    this.isCurrentMonth = isCurrentMonth ?? false;
    this.lunarDateText = lunarDateText ?? '';
  }

  public getDay(){
    return this.day;
  }

  public getWeek(){
    return this.week;
  }

  public getIsCurrentMonth(){
    return this.isCurrentMonth;
  }

  public getLunarDateText(){
    return this.lunarDateText;
  }
}