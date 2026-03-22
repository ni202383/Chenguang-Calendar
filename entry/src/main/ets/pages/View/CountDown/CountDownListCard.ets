import { BasicConstant } from "../../../Constants/BasicConstant";
import { backgroundImageList } from "../../../data/backgroundImageList";
import { EventCountDown } from "../../Model/EventCountDown"

@Extend(Text) function TextStyle(index: number) {
  .fontSize(35)
  .fontWeight(FontWeight.Bold)
  .fontColor(index == 0 ? Color.Black : Color.White)
  .opacity(index == 0 ? 1 : 0.8)
}

@Component
export struct CountDownListCard {
  @ObjectLink eventCountDown: EventCountDown;

  @State private remainText: string = '';

  private secondTimer?: number;
  private midnightTimeout?: number;
  private dailyTimer?: number;

  private stopTimers(): void {
    if (this.secondTimer !== undefined) {
      clearInterval(this.secondTimer);
      this.secondTimer = undefined;
    }
    if (this.midnightTimeout !== undefined) {
      clearTimeout(this.midnightTimeout);
      this.midnightTimeout = undefined;
    }
    if (this.dailyTimer !== undefined) {
      clearInterval(this.dailyTimer);
      this.dailyTimer = undefined;
    }
  }

  // 计算“整年整月整日”差值（只用于显示 Y/M/D，不走毫秒换算）
  private diffYMD(from: Date, to: Date): [number,number,number] {
    // 保证 from <= to
    let start = new Date(from.getFullYear(), from.getMonth(), from.getDate());
    let end = new Date(to.getFullYear(), to.getMonth(), to.getDate());

    if (start.getTime() > end.getTime()) {
      return [0,0,0];
    }

    let years = end.getFullYear() - start.getFullYear();
    let months = end.getMonth() - start.getMonth();
    let days = end.getDate() - start.getDate();

    if (days < 0) {
      // 借一个月
      months -= 1;
      const prevMonthEnd = new Date(end.getFullYear(), end.getMonth(), 0); // end上个月最后一天
      days += prevMonthEnd.getDate();
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }
    if (years < 0) {
      return [0,0,0];
    }
    return [ years, months, days ];
  }

  private diffHMS(diffMs: number): [number,number,number] {
    const totalSec = Math.max(0, Math.floor(diffMs / 1000));
    const hours = Math.floor(totalSec / 3600);
    const minutes = Math.floor((totalSec % 3600) / 60);
    const seconds = totalSec % 60;
    return [ hours, minutes, seconds ];
  }

  private formatRemainText(now: Date, target: Date): string {
    const nowMs = now.getTime();
    const targetMs = target.getTime();
    let diffMs = targetMs - nowMs;
    let hours = 0;
    let minutes = 0;
    let seconds = 0;
    let years = 0;
    let months = 0;
    let days = 0;

    if (diffMs <= 0) return '已到达';

    // 是否进入 1 天以内：用毫秒判断最准确
    const oneDayMs = 24 * 60 * 60 * 1000;
    if (diffMs < oneDayMs) {
      const time = this.diffHMS(diffMs);
      hours = time[0];
      minutes = time[1];
      seconds = time[2];
      // <1天：只显示 时分秒（不用冒号）
      // 0小时就不显示小时，分钟/秒同理
      let s = '';
      if (hours > 0) s += `${hours}时`;
      if (minutes > 0) s += `${minutes}分`;
      // 秒建议始终显示，体验更像倒计时
      s += `${seconds}秒`;
      return s;
    }

    // >=1天：显示 Y/M/D 的层级（并且 0 不显示）
    const time = this.diffYMD(now, target);
    years = time[0];
    months = time[1];
    days = time[2];

    if (years >= 1) {
      // >=1年：显示 年月日（都用剩余量）
      let s = `${years}年`;
      // months/days 可能为0，按你的规则：0就不显示
      if (months > 0) s += `${months}月`;
      if (days > 0) s += `${days}日`;
      // 如果刚好整年（months=days=0），至少显示“X年”
      return s;
    }

    if (months >= 1) {
      // >=1月 <1年：显示 月日
      let s = `${months}月`;
      if (days > 0) s += `${days}日`;
      return s;
    }

    // >=1天 <1月：显示 日
    // days 在 diffYMD 里可能为0（比如刚好整月/整年已在上面处理）
    const d = Math.max(1, days); // 到这里至少 >=1天，避免显示“0日”
    return `${d}日`;
  }

  private updateRemainText(): void {
    const now = new Date();
    const target = this.eventCountDown.targetDate;
    this.remainText = this.formatRemainText(now, target);
  }

  private startTimers(): void {
    this.stopTimers();
    this.updateRemainText();

    const nowMs = Date.now();
    const targetMs = this.eventCountDown.targetDate.getTime();
    const diffMs = targetMs - nowMs;

    if (diffMs <= 0) return;

    const oneDayMs = 24 * 60 * 60 * 1000;

    // <1天：秒级更新
    if (diffMs < oneDayMs) {
      this.secondTimer = setInterval(() => {
        this.updateRemainText();
      }, 1000) as number;
      return;
    }

    // >=1天：到下一个午夜更新一次，然后每天更新
    const now = new Date();
    const nextMidnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 0, 0, 0, 0);
    const delay = Math.max(0, nextMidnight.getTime() - now.getTime() + 50);

    this.midnightTimeout = setTimeout(() => {
      this.updateRemainText();
      this.dailyTimer = setInterval(() => {
        this.updateRemainText();
      }, oneDayMs) as number;
    }, delay) as number;
  }

  aboutToAppear(): void {
    this.startTimers();
  }

  aboutToDisappear(): void {
    this.stopTimers();
  }

  build() {
    RelativeContainer() {
      Image(this.eventCountDown.imageIndex == 0 ? null : backgroundImageList[this.eventCountDown.imageIndex])
        .objectFit(ImageFit.Cover)
        .borderRadius(20)

      Column() {
        Text(`距离${this.eventCountDown.eventName}还有`)
          .TextStyle(this.eventCountDown.imageIndex)
          .textAlign(TextAlign.Center)

        Text(this.remainText)
          .TextStyle(this.eventCountDown.imageIndex)
      }
      .alignRules({
        middle : {anchor : '__container__',align : HorizontalAlign.Center},
        center : {anchor : '__container__',align : VerticalAlign.Center}
      })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .borderRadius(20)
    .backgroundColor(Color.White)
    .clickEffect({
      level : ClickEffectLevel.LIGHT,
      scale : 0.9
    })
  }
}
