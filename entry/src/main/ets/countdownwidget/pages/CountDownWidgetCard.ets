import { backgroundImageList } from '../../data/backgroundImageList';

@Extend(Text)
function CdTextStyle(imageIndex: number) {
  .fontSize(20)
  .fontWeight(FontWeight.Bold)
  .fontColor(imageIndex == 0 ? Color.Black : Color.White)
  .opacity(imageIndex == 0 ? 1 : 0.85)
}

@Extend(Text)
function CdRemainStyle(imageIndex: number) {
  .fontSize(32)
  .fontWeight(FontWeight.Bold)
  .fontColor(imageIndex == 0 ? Color.Black : Color.White)
  .opacity(imageIndex == 0 ? 1 : 0.85)
}

@Entry
@Component
struct CountDownWidgetCard {
  @LocalStorageProp('eventName') eventName: string = '倒计时';
  @LocalStorageProp('imageIndex') imageIndex: number = 0;

  // 新增：由 FormExtensionAbility 下发
  @LocalStorageProp('targetTime') targetTime: number = 0;
  @LocalStorageProp('hourMinuteSecondIsUsed') hourMinuteSecondIsUsed: boolean = false;

  private formatRemain(nowMs: number, targetMs: number): string {
    if (targetMs <= 0) return '未绑定';
    const diff = targetMs - nowMs;
    if (diff <= 0) return '已到达';

    const oneDayMs = 24 * 60 * 60 * 1000;
    if (diff < oneDayMs) {
      const totalSec = Math.floor(diff / 1000);
      const h = Math.floor(totalSec / 3600);
      const m = Math.floor((totalSec % 3600) / 60);
      const s = totalSec % 60;

      let str = '';
      if (h > 0) str += `${h}时`;
      if (m > 0) str += `${m}分`;

      // 桌面端建议不显示秒；如果你坚持，且用户选了时分秒，则显示秒
      if (this.hourMinuteSecondIsUsed) str += `${s}秒`;

      // 防止出现空串
      if (str.length === 0) str = `${s}秒`;
      return str;
    }

    const days = Math.floor(diff / oneDayMs);
    return `${days}天`;
  }

  build() {
    FormLink({
      action: 'router',
      abilityName: 'EntryAbility',
      params: {}
    }) {
      RelativeContainer() {
        Image(this.imageIndex == 0 ? null : backgroundImageList[this.imageIndex])
          .objectFit(ImageFit.Cover)
          .borderRadius(16)

        Column({ space: 6 }) {
          Text(`距离${this.eventName}还有`)
            .CdTextStyle(this.imageIndex)
            .textAlign(TextAlign.Center)

          Text(this.formatRemain(Date.now(), this.targetTime))
            .CdRemainStyle(this.imageIndex)
            .textAlign(TextAlign.Center)
        }
        .padding(12)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
      }
      .width('100%')
      .height('100%')
      .borderRadius(16)
      .clip(true)
      .backgroundColor(Color.White)
    }
  }
}
