export class TaiSuiPosition {
  private yearTaiSuiPosition: string;
  private monthTaiSuiPosition: string;
  private dayTaiSuiPosition: string;

  constructor();

  constructor(yearTaiSuiPosition: string, monthTaiSuiPosition: string, dayTaiSuiPosition: string);

  constructor(yearTaiSuiPosition ?: string, monthTaiSuiPosition ?: string, dayTaiSuiPosition ?: string) {
    this.yearTaiSuiPosition = yearTaiSuiPosition ?? '';
    this.monthTaiSuiPosition = monthTaiSuiPosition ?? '';
    this.dayTaiSuiPosition = dayTaiSuiPosition ?? '';
  }

  public getYearTaiSuiPosition() {
    return this.yearTaiSuiPosition;
  }

  public getMonthTaiSuiPosition() {
    return this.monthTaiSuiPosition;
  }

  public getDayTaiSuiPosition() {
    return this.dayTaiSuiPosition;
  }
}

export class JiShengPosition {
  private XiPosition: string;
  private YangGuiPosition: string;
  private YinGuiPosition: string;
  private FuPosition: string;
  private CaiPosition: string;

  constructor();

  constructor(XiPosition: string, YangGuiPosition: string, YinGuiPosition: string, FuPosition: string,
    CaiPosition: string);

  constructor(XiPosition ?: string, YangGuiPosition ?: string, YinGuiPosition ?: string, FuPosition ?: string,
    CaiPosition ?: string) {
    this.XiPosition = XiPosition ?? '';
    this.YangGuiPosition = YangGuiPosition ?? '';
    this.YinGuiPosition = YinGuiPosition ?? '';
    this.FuPosition = FuPosition ?? '';
    this.CaiPosition = CaiPosition ?? '';
  }

  public getXiPosition() {
    return this.XiPosition;
  }

  public getYangGuiPosition() {
    return this.YangGuiPosition;
  }

  public getYinGuiPosition() {
    return this.YinGuiPosition;
  }

  public getFuPosition() {
    return this.FuPosition;
  }

  public getCaiPosition() {
    return this.CaiPosition;
  }
}

export class ordinaryAlmanacOfDay {
  private lunarYear: number;
  private lunarMonth: number;
  private lunarDay: number;
  private Yi: string;
  private Ji: string;
  private yearInGanZhi: string;
  private monthInGanZhi: string;
  private dayInGanZhi: string;
  private yearInShengXiao: string;

  constructor();

  constructor(lunarYear: number, lunarMonth: number, lunarDay: number, Yi: string, Ji: string,
    yearInGanZhi: string, monthInGanZhi: string, dayInGanZhi: string, yearInShengXiao: string);

  constructor(lunarYear ?: number, lunarMonth ?: number, lunarDay ?: number, Yi ?: string, Ji ?: string,
    yearInGanZhi ?: string, monthInGanZhi ?: string, dayInGanZhi ?: string, yearInShengXiao ?: string) {
    this.lunarYear = lunarYear ?? new Date().getFullYear();
    this.lunarMonth = lunarMonth ?? new Date().getMonth() + 1;
    this.lunarDay = lunarDay ?? new Date().getDate();
    this.Yi = Yi ?? '';
    this.Ji = Ji ?? '';
    this.yearInGanZhi = yearInGanZhi ?? '';
    this.monthInGanZhi = monthInGanZhi ?? '';
    this.dayInGanZhi = dayInGanZhi ?? '';
    this.yearInShengXiao = yearInShengXiao ?? '';
  }

  public getLunarYear() {
    return this.lunarYear;
  }

  public getLunarMonth() {
    return this.lunarMonth;
  }

  public getLunarDay() {
    return this.lunarDay;
  }

  public getYi() {
    return this.Yi;
  }

  public getJi() {
    return this.Ji;
  }

  public getYearInGanZhi() {
    return this.yearInGanZhi;
  }

  public getMonthInGanZhi() {
    return this.monthInGanZhi;
  }

  public getDayInGanZhi() {
    return this.dayInGanZhi;
  }

  public getYearInShengXiao() {
    return this.yearInShengXiao;
  }
}

export class almanacOfDay {
  private jiShengPosition: JiShengPosition;
  private dayTaiPosition: string;
  private taisuiPosition: TaiSuiPosition;
  private Chong: string;
  private Sha: string;
  private JiSheng: string;
  private XiongSha: string;
  private twelveZhiXing: string;
  private timeOfCurrentDay: Array<almanacOfTime>;
  private PengZuGan: string;
  private PengZuZhi: string;

  constructor();

  constructor(jiShengPosition: JiShengPosition, taiPosition: string,
    taisuiPosition: TaiSuiPosition, Chong: string, Sha: string, JiSheng: string,
    XiongSha: string, twelveZhiXing: string, timeOfCurrentDay: Array<almanacOfTime>,
    PengZuGan: string, PengZuZhi: string);

  constructor(jiShengPosition ?: JiShengPosition, taiPosition ?: string,
    taisuiPosition ?: TaiSuiPosition, Chong ?: string, Sha ?: string, JiSheng ?: string,
    XiongSha ?: string, twelveZhiXing ?: string, timeOfCurrentDay ?: Array<almanacOfTime>,
    PengZuGan ?: string, PengZuZhi ?: string) {
    this.jiShengPosition = jiShengPosition ?? new JiShengPosition();
    this.dayTaiPosition = taiPosition ?? '';
    this.taisuiPosition = taisuiPosition ?? new TaiSuiPosition();
    this.Chong = Chong ?? '';
    this.Sha = Sha ?? '';
    this.JiSheng = JiSheng ?? '';
    this.XiongSha = XiongSha ?? '';
    this.twelveZhiXing = twelveZhiXing ?? '';
    this.timeOfCurrentDay = timeOfCurrentDay ?? [new almanacOfTime()];;
    this.PengZuGan = PengZuGan ?? '';
    this.PengZuZhi = PengZuZhi ?? '';
  }

  public getJiShengPosition() {
    return this.jiShengPosition;
  }

  public getDayTaiPosition() {
    return this.dayTaiPosition;
  }

  public getTaisuiPosition() {
    return this.taisuiPosition;
  }

  public getChong() {
    return this.Chong;
  }

  public getSha() {
    return this.Sha;
  }

  public getJiSheng() {
    return this.JiSheng;
  }

  public getXiongSha() {
    return this.XiongSha;
  }

  public getTwelveZhiXing() {
    return this.twelveZhiXing;
  }

  public getTimeOfCurrentDay() {
    return this.timeOfCurrentDay;
  }

  public getPengZuGan() {
    return this.PengZuGan;
  }

  public getPengZuZhi() {
    return this.PengZuZhi;
  }
}

export class almanacOfTime {
  private time: string; //时辰
  private beginTime : Date;
  private endTime : Date;
  private beginTimeString: string;
  private endTimeString : string;
  private timeInGanZhi: string;
  private Chong: string;
  private Sha: string;
  private jiShengPosition: JiShengPosition;
  private Yi: string;
  private Ji: string;
  private JiOrXiong: string;

  constructor();

  constructor(time: string, beginTime : Date, endTime : Date, beginTimeString: string, endTimeString : string, timeInGanZhi: string, Chong: string, Sha: string,
    jiShengPosition: JiShengPosition, Yi: string, Ji: string, JiOrXiong: string)

  constructor(time ?: string, beginTime ?: Date, endTime ?: Date, beginTimeString ?: string, endTimeString ?: string, timeInGanZhi ?: string, Chong ?: string, Sha ?: string,
    jiShengPosition ?: JiShengPosition, Yi ?: string, Ji ?: string, JiOrXiong ?: string) {
    this.time = time ?? '';
    this.beginTime = beginTime ?? new Date();
    this.endTime = endTime ?? new Date();
    this.beginTimeString = beginTimeString ?? '';
    this.endTimeString = endTimeString ?? '';
    this.timeInGanZhi = timeInGanZhi ?? '';
    this.JiOrXiong = JiOrXiong ?? '';
    this.Chong = Chong ?? '';
    this.Sha = Sha ?? '';
    this.jiShengPosition = jiShengPosition ?? new JiShengPosition();
    this.Yi = Yi ?? '';
    this.Ji = Ji ?? '';
  }

  public getTime() {
    return this.time;
  }

  public getBeginTime(){
    return this.beginTime;
  }

  public getEndTime(){
    return this.endTime;
  }

  public getBeginTimeString(){
    return this.beginTimeString;
  }

  public getEndTimeString(){
    return this.endTimeString;
  }

  public getTimeInGanZhi() {
    return this.timeInGanZhi;
  }

  public getChong() {
    return this.Chong;
  }

  public getSha() {
    return this.Sha;
  }

  public getJiShengPosition() {
    return this.jiShengPosition;
  }

  public getYi() {
    return this.Yi;
  }

  public getJi() {
    return this.Ji;
  }

  public getJiOrXiong() {
    return this.JiOrXiong;
  }
}