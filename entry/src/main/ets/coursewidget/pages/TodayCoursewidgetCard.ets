interface TodayCourseWidgetLine {
  courseName: string;
  classroom: string;
  timeRangeText: string;
  sectionRangeText: string;
  color: string;
  statusText: string;
  statusColor: string;
}

@Entry
@Component
struct TodayCourseWidgetCard {
  @LocalStorageProp('title') title: string = '今日课程';
  @LocalStorageProp('dateText') dateText: string = '';
  @LocalStorageProp('weekText') weekText: string = '';
  @LocalStorageProp('emptyText') emptyText: string = '今日无课程';
  @LocalStorageProp('courseCount') courseCount: number = 0;
  @LocalStorageProp('updatedAtText') updatedAtText: string = '';
  @LocalStorageProp('coursesJson') coursesJson: string = '[]';
  @LocalStorageProp('themeColor') themeColor: string = '#EA5C2E';

  private getCourseLines(): Array<TodayCourseWidgetLine> {
    try {
      return JSON.parse(this.coursesJson) as Array<TodayCourseWidgetLine>;
    } catch (error) {
      return [];
    }
  }

  private getCourseLine(index: number): TodayCourseWidgetLine {
    const list: Array<TodayCourseWidgetLine> = this.getCourseLines();
    if (index >= 0 && index < list.length) {
      return list[index];
    }
    return {
      courseName: '', classroom: '', timeRangeText: '', sectionRangeText: '', color: '#7E57C2', statusText: '', statusColor: '#999999'
    };
  }

  // [课程卡片] 即使首次 LocalStorage 数据未及时注入，也提供兜底日期文本，避免头部留白。
  private getSafeDateText(): string {
    if (this.dateText.trim().length > 0) {
      return this.dateText;
    }
    const date: Date = new Date();
    const labels: Array<string> = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return (date.getMonth() + 1).toString() + '月' + date.getDate().toString() + '日 ' + labels[date.getDay()];
  }

  // [课程卡片] 教学周默认不给空白，至少展示占位文本，便于判断刷新是否生效。
  private getSafeWeekText(): string {
    if (this.weekText.trim().length > 0) {
      return this.weekText;
    }
    return '教学周待更新';
  }

  private getSafeUpdatedAtText(): string {
    if (this.updatedAtText.trim().length > 0) {
      return this.updatedAtText;
    }
    const now: Date = new Date();
    const hour: string = now.getHours().toString().padStart(2, '0');
    const minute: string = now.getMinutes().toString().padStart(2, '0');
    return '已更新，时间：' + hour + ':' + minute;
  }

  @Builder
  private buildHeader() {
    Row() {
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#222222')

      Column({ space: 2 }) {
        Text(this.getSafeDateText())
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#333333')
          .textAlign(TextAlign.Center)
          .maxLines(1)
        Text(this.getSafeWeekText())
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColor)
          .textAlign(TextAlign.Center)
          .maxLines(1)
      }
      .width('33%')
      .alignItems(HorizontalAlign.Center)

      // [课程卡片] 按华为 ArkTS 卡片 message 主动刷新方式，使用 postCardAction 触发 onFormEvent。
      Button('刷新')
        .type(ButtonType.Capsule)
        .fontSize(12)
        .fontColor(this.themeColor)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: this.themeColor, radius: 20 })
        .padding({ left: 8, right: 8, top: 0, bottom: 0 })
        .height(28)
        .onClick(() => {
          postCardAction(this, {
            action: 'message',
            params: {
              message: 'refreshTodayCourse'
            }
          })
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildCourseItem(index: number) {
    Row({ space: 8 }) {
      Column() {}
        .width(4)
        .height(48)
        .backgroundColor(this.getCourseLine(index).color)
        .borderRadius(2)

      Column({ space: 2 }) {
        Text(this.getCourseLine(index).courseName)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getCourseLine(index).color)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.getCourseLine(index).timeRangeText + '  ' + this.getCourseLine(index).sectionRangeText)
          .fontSize(10)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })

        Text(this.getCourseLine(index).classroom)
          .fontSize(10)
          .fontColor('#666666')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.getCourseLine(index).statusText)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.getCourseLine(index).statusColor)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Column({ space: 8 }) {
      this.buildHeader()

      if (this.getCourseLines().length === 0) {
        Column({ space: 8 }) {
          Text(this.emptyText)
            .fontSize(14)
            .fontColor('#666666')
          Blank()
            .layoutWeight(1)
          Text(this.getSafeUpdatedAtText())
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        Column({ space: 8 }) {
          ForEach(this.getCourseLines(), (item: TodayCourseWidgetLine, index: number) => {
            this.buildCourseItem(index)
          }, (item: TodayCourseWidgetLine, index: number) => index.toString())

          Blank()
            .layoutWeight(1)

          Text(this.getSafeUpdatedAtText())
            .fontSize(10)
            .fontColor('#999999')
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .height('100%')
    .padding({ left: 12, right: 12, top: 14, bottom: 12 })
    .backgroundColor('rgba(255,255,255,0.8)')
  }
}
