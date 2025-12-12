import { fetchAlmanacData, number2CharacterInLunarMonth, number2characterInWeek } from './Utils/fetchAlmanacData'
import { cardDataClass } from './model/cardDataClass'

@Extend(GridCol)
function GridColBorderStyle() {
  .padding(2)
  .alignSelf(ItemAlign.Stretch)
}

@Entry
@Component
struct DateInfoCard {
  readonly title: string = 'Hello World';
  readonly actionType: string = 'router';
  readonly abilityName: string = 'EntryAbility';
  readonly message: string = 'add detail';
  readonly fullWidthPercent: string = '100%';
  readonly fullHeightPercent: string = '100%';
  @LocalStorageProp('isSubscribe') isSubscribe: boolean = true;
  private currentYear: number = new Date().getFullYear();
  private currentMonth: number = new Date().getMonth() + 1;
  private currentDay: number = new Date().getDate();
  private cardInfo: cardDataClass = fetchAlmanacData(this.currentYear, this.currentMonth, this.currentDay)
  private almanacYellow: string = '#C28109';
  private almanacRed: string = '#9D173C';

  @Builder
  AlmanacGridDetail<T>(key: string, value: T, fontColor: string = '#000000') {
    Flex({
      direction: FlexDirection.Column,
      justifyContent: FlexAlign.SpaceEvenly,
      alignItems: ItemAlign.Center,
    }) {
      Text(key)
        .fontSize(8)
        .fontColor($r('app.color.gray_deeper'))

      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.Center,
        alignItems: ItemAlign.Center
      }) {
        Text(`${value}`)
          .fontSize(10)
          .fontWeight(FontWeight.Bold)
          .fontColor(fontColor)
      }
      .width('100%')
      .height(15)

    }
    .width('100%')
    .height(25)
  }

  build() {
    FormLink({
      action: this.actionType,
      abilityName: this.abilityName,
      params: {
        message: this.message
      }
    }) {
      Column() {
        Row() {
          Column({ space: 5 }) {
            Text(`${this.currentYear}年${this.currentMonth}月${this.currentDay}日`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(Color.Black)

            if (this.cardInfo.getLunarMonth() < 0) {
              Text(`闰${number2CharacterInLunarMonth[Math.abs(this.cardInfo.getLunarMonth())]}月${this.cardInfo.getLunarText()}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bolder)
            } else {
              Text(`${number2CharacterInLunarMonth[this.cardInfo.getLunarMonth()]}月${this.cardInfo.getLunarText()}`)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
            }

            Text(`${this.cardInfo.getYearInGanzhi()}年 [${this.cardInfo.getYearInShengxiao()}] ${this.cardInfo.getMonthInGanzhi()}月 ${this.cardInfo.getDayInGanzhi()}日 星期${number2characterInWeek[new Date().getDay()]}`)
              .fontSize(10)
          }
          .width('50%')
          .height('100%')
          .padding(5)

          Column() {
            GridRow({
              columns: 2,
              direction: GridRowDirection.Row
            }) {
              GridCol() {
                this.AlmanacGridDetail<string>('财神位', this.cardInfo.getAlmanacData().getCaiPosition(),
                  this.almanacYellow)
              }
              .GridColBorderStyle()
              .border({
                width: {
                  left: 1,
                  right: 0.5,
                  top: 1,
                  bottom: 0.5
                },
                color: this.almanacYellow
              })

              GridCol() {
                this.AlmanacGridDetail<string>('喜神位', this.cardInfo.getAlmanacData().getXiPosition(),
                  this.almanacYellow)
              }
              .GridColBorderStyle()
              .border({
                width: {
                  left: 0.5,
                  right: 1,
                  top: 1,
                  bottom: 0.5
                },
                color: this.almanacYellow
              })
            }
            .width('95%')

            GridRow({
              columns: 2,
              direction: GridRowDirection.Row
            }) {
              GridCol() {
                this.AlmanacGridDetail<string>('福神位', this.cardInfo.getAlmanacData().getFuPosition(),
                  this.almanacYellow)
              }
              .GridColBorderStyle()
              .border({
                width: {
                  left: 1,
                  right: 0.5,
                  top: 0.5,
                  bottom: 1
                },
                color: this.almanacYellow
              })

              GridCol() {
                this.AlmanacGridDetail<string>('阳贵位', this.cardInfo.getAlmanacData().getYangGuiPosition(),
                  this.almanacYellow)
              }
              .GridColBorderStyle()
              .border({
                width: {
                  left: 0.5,
                  right: 1,
                  top: 0.5,
                  bottom: 1
                },
                color: this.almanacYellow
              })
            }
            .width('95%')

          }
          .width('50%')
          .height('100%')
          .padding(5)
        }
        .width(this.fullWidthPercent)
        .height('50%')
        .margin({ top: 5 })

        Row() {
          Column({ space: 8 }) {
            Row({ space: 5 }) {
              Stack() {
                Column()
                  .width(15)
                  .height(15)
                  .backgroundColor(this.almanacYellow)
                  .borderRadius(5)
                Text('宜')
                  .fontColor(Color.White)
                  .fontSize(12)
              }

              Text(this.cardInfo.getAlmanacData().getYi())
                .fontSize(11)
                .fontColor(this.almanacYellow)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })

            }
            .width('95%')

            Row({ space: 5 }) {
              Stack() {
                Column()
                  .width(15)
                  .height(15)
                  .backgroundColor(this.almanacRed)
                  .borderRadius(5)
                Text('忌')
                  .fontColor(Color.White)
                  .fontSize(12)
              }

              Text(this.cardInfo.getAlmanacData().getJi())
                .fontSize(11)
                .fontColor(Color.Black)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('95%')
          }
          .width(this.fullWidthPercent)
          .height(this.fullHeightPercent)
          .justifyContent(FlexAlign.Center)
          .alignItems(HorizontalAlign.Center)
        }
        .width(this.fullWidthPercent)
        .height('50%')
        .padding(5)

      }
      .width(this.fullWidthPercent)
      .height(this.fullHeightPercent)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }
}
