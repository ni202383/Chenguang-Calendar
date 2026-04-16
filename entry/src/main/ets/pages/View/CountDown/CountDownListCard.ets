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
  @StorageProp('agentFocusCountDownId') agentFocusCountDownId: string = '';
  @StorageProp('themeColor') themeColor: string = '#EA5C2E';

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

  private isFocused(): boolean {
    return this.eventCountDown.getId() == this.agentFocusCountDownId;
  }

  // 计算“整年整月整日”差值（只用于显示 Y/M/D，不走毫秒换算）
  private diffYMD(from: Date, to: Date): [number,number,number] {
    let start = new Date(from.getFullYear(), from.getMonth(), from.getDate());
    let end = new Date(to.getFullYear(), to.getMonth(), to.getDate());

    if (start.getTime() > end.getTime()) {
      return [0,0,0];
    }

    let years = end.getFullYear() - start.getFullYear();
    let months = end.getMonth() - start.getMonth();
    let days = end.getDate() - start.getDate();

    if (days < 0) {
      months -= 1;
      const prevMonthEnd = new Date(end.getFullYear(), end.getMonth(), 0);
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

    const oneDayMs = 24 * 60 * 60 * 1000;
    if (diffMs < oneDayMs) {
      const time = this.diffHMS(diffMs);
      hours = time[0];
      minutes = time[1];
      seconds = time[2];
      let s = '';
      if (hours > 0) s += `${hours}时`;
      if (minutes > 0) s += `${minutes}分`;
      s += `${seconds}秒`;
      return s;
    }

    const time = this.diffYMD(now, target);
    years = time[0];
    months = time[1];
    days = time[2];

    if (years >= 1) {
      let s = `${years}年`;
      if (months > 0) s += `${months}月`;
      if (days > 0) s += `${days}日`;
      return s;
    }

    if (months >= 1) {
      let s = `${months}月`;
      if (days > 0) s += `${days}日`;
      return s;
    }

    const d = Math.max(1, days);
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

    if (diffMs < oneDayMs) {
      this.secondTimer = setInterval(() => {
        this.updateRemainText();
      }, 1000) as number;
      return;
    }

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
    .backgroundColor(this.isFocused() ? 'rgba(255,249,196,0.95)' : Color.White)
    .border({
      width: this.isFocused() ? 2 : 0,
      color: this.isFocused() ? this.themeColor : Color.Transparent,
      radius: 20
    })
    .shadow({
      radius: this.isFocused() ? 14 : 0,
      color: this.isFocused() ? '#26EA5C2E' : Color.Transparent,
      offsetX: 0,
      offsetY: 3
    })
    .clickEffect({
      level : ClickEffectLevel.LIGHT,
      scale : 0.9
    })
  }
}
