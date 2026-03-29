import { BasicConstant } from '../../Constants/BasicConstant'
import { BreakpointConstant } from '../../Constants/BreakpointConstant'
import { router } from '@kit.ArkUI'
import { Course } from '../Model/Course';
import { courseStore } from '../Model/CourseStore';

class CourseScheduleTimeSlot {
  private startSection: number;
  private endSection: number;

  constructor(startSection: number, endSection: number) {
    this.startSection = startSection;
    this.endSection = endSection;
  }

  public getStartSection(): number {
    return this.startSection;
  }

  public getEndSection(): number {
    return this.endSection;
  }

  public getSectionCount(): number {
    return this.endSection - this.startSection + 1;
  }

  public getSectionText(): string {
    return this.startSection === this.endSection ?
      this.startSection.toString() + '节' :
      this.startSection.toString() + '-' + this.endSection.toString() + '节';
  }

  public getTimeRangeText(): string {
    return Course.getSectionStartTime(this.startSection) + '-' + Course.getSectionEndTime(this.endSection);
  }
}

class CourseScheduleWeekPageData {
  private mondayDate: Date;
  private readonly weekLabels: Array<string> = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  private coursesByDayOffset: Map<number, Array<Course>> = new Map<number, Array<Course>>();

  constructor(anchorDate: Date) {
    this.mondayDate = this.getMonday(anchorDate);
    this.buildCourseCache();
  }

  private getMonday(date: Date): Date {
    const monday = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const day = monday.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    monday.setDate(monday.getDate() + diff);
    return monday;
  }

  private buildCourseCache(): void {
    for (let offset = 0; offset < 7; offset++) {
      this.coursesByDayOffset.set(offset, courseStore.getCoursesByDate(this.getDateByOffset(offset)));
    }
  }

  public getKey(): string {
    return this.getDateKey(this.mondayDate);
  }

  public getAcademicWeekText(): string {
    const weekIndex = courseStore.getAcademicWeekByDate(this.mondayDate);
    return weekIndex > 0 ? '第' + weekIndex.toString() + '周' : '课表';
  }

  public getDateByOffset(offset: number): Date {
    return new Date(this.mondayDate.getFullYear(), this.mondayDate.getMonth(), this.mondayDate.getDate() + offset);
  }

  public getDateTextByOffset(offset: number): string {
    const date = this.getDateByOffset(offset);
    return (date.getMonth() + 1).toString() + '/' + date.getDate().toString();
  }

  public getWeekLabelByOffset(offset: number): string {
    return this.weekLabels[offset];
  }

  public getCoursesByOffset(offset: number): Array<Course> {
    const courses = this.coursesByDayOffset.get(offset);
    return courses !== undefined ? courses : [];
  }

  private getDateKey(date: Date): string {
    const year = date.getFullYear().toString();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return year + '-' + month + '-' + day;
  }
}

class CourseScheduleDataSource implements IDataSource {
  private readonly count: number = 48000;
  private readonly initialIndex: number = 24000;
  private baseDate: Date;
  private pageCache: Map<string, CourseScheduleWeekPageData> = new Map<string, CourseScheduleWeekPageData>();

  constructor(baseDate: Date) {
    this.baseDate = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate());
  }

  public getInitialIndex(): number {
    return this.initialIndex;
  }

  totalCount(): number {
    return this.count;
  }

  getData(index: number): CourseScheduleWeekPageData {
    const offsetWeeks = index - this.initialIndex;
    const targetDate = new Date(this.baseDate.getFullYear(), this.baseDate.getMonth(),
      this.baseDate.getDate() + offsetWeeks * 7);
    const pageData = new CourseScheduleWeekPageData(targetDate);
    const cacheKey = pageData.getKey();
    const cacheValue = this.pageCache.get(cacheKey);
    if (cacheValue !== undefined) {
      return cacheValue;
    }
    this.pageCache.set(cacheKey, pageData);
    return pageData;
  }

  registerDataChangeListener(_listener: DataChangeListener): void {
  }

  unregisterDataChangeListener(_listener: DataChangeListener): void {
  }
}

function normalizeHexColor(color: string): string {
  const trimmed = color.trim();
  if (trimmed.length === 7 && trimmed.charAt(0) === '#') {
    return trimmed;
  }
  if (trimmed.length === 4 && trimmed.charAt(0) === '#') {
    return '#' + trimmed.charAt(1) + trimmed.charAt(1) + trimmed.charAt(2) + trimmed.charAt(2) +
      trimmed.charAt(3) + trimmed.charAt(3);
  }
  return '#EA5C2E';
}

function parseHexChannel(color: string, start: number): number {
  const value = color.slice(start, start + 2);
  const parsed = Number.parseInt(value, 16);
  return Number.isNaN(parsed) ? 0 : parsed;
}

function buildLightCourseColor(color: string): string {
  const hexColor = normalizeHexColor(color);
  const red = parseHexChannel(hexColor, 1);
  const green = parseHexChannel(hexColor, 3);
  const blue = parseHexChannel(hexColor, 5);
  return 'rgba(' + red.toString() + ',' + green.toString() + ',' + blue.toString() + ',0.16)';
}

@Component
struct CourseScheduleWeekPage {
  @Prop pageData: CourseScheduleWeekPageData;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('themeColor') themeColor: string = '#EA5C2E';

  private readonly dayOffsets: Array<number> = [0, 1, 2, 3, 4, 5, 6];
  private readonly sectionIndexes: Array<number> = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  private readonly timeSlots: Array<CourseScheduleTimeSlot> = [
    new CourseScheduleTimeSlot(1, 2),
    new CourseScheduleTimeSlot(3, 4),
    new CourseScheduleTimeSlot(5, 6),
    new CourseScheduleTimeSlot(7, 8),
    new CourseScheduleTimeSlot(9, 10),
    new CourseScheduleTimeSlot(11, 11)
  ];

  private getWeekTitleFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 24 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 22 : 20;
  }

  private getHeaderDateFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 16 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 15 : 13;
  }

  private getHeaderWeekFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 16 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 15 : 13;
  }

  private getTimeSectionFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 12 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 11 : 10;
  }

  private getTimeRangeFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 11 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 10 : 9;
  }

  private getCourseNameFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 12 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 11 : 10;
  }

  private getCourseInfoFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 11 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 10 : 9;
  }

  private getSectionHeight(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 64 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 58 : 52;
  }

  private getHeaderHeight(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 60 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 56 : 52;
  }

  private getTimeColumnWidth(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 41 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 38 : 34;
  }

  private getTableHeight(): number {
    return this.getSectionHeight() * 11;
  }

  private isTodayByOffset(offset: number): boolean {
    const date = this.pageData.getDateByOffset(offset);
    const today = new Date();
    return date.getFullYear() === today.getFullYear() && date.getMonth() === today.getMonth() &&
      date.getDate() === today.getDate();
  }

  private getCourseColor(course: Course): string {
    return courseStore.getCourseBorderColor(course.getCourseName());
  }

  private getCourseBackgroundColor(course: Course, offset: number): string {
    return this.isTodayByOffset(offset) ? this.getCourseColor(course) : buildLightCourseColor(this.getCourseColor(course));
  }

  private getCourseTextColor(course: Course, offset: number): string {
    return this.isTodayByOffset(offset) ? '#FFFFFF' : this.getCourseColor(course);
  }

  private getCourseTop(course: Course): number {
    return (course.getStartSection() - 1) * this.getSectionHeight() + 2;
  }

  private getCourseHeight(course: Course): number {
    return (course.getEndSection() - course.getStartSection() + 1) * this.getSectionHeight() - 4;
  }

  private getCourseMaxLines(course: Course): number {
    return course.getEndSection() - course.getStartSection() + 1 >= 3 ? 3 : 2;
  }

  @Builder
  private buildWeekHeader(offset: number) {
    Column({ space: 2 }) {
      Text(this.pageData.getDateTextByOffset(offset))
        .fontSize(this.getHeaderDateFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isTodayByOffset(offset) ? this.themeColor : Color.Black)

      Text(this.pageData.getWeekLabelByOffset(offset))
        .fontSize(this.getHeaderWeekFontSize())
        .fontWeight(FontWeight.Medium)
        .fontColor(this.isTodayByOffset(offset) ? this.themeColor : $r('app.color.gray_deep'))
    }
    .layoutWeight(1)
    .height(this.getHeaderHeight())
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  private buildTimeSlot(slot: CourseScheduleTimeSlot) {
    Column({ space: 1 }) {
      Text(slot.getSectionText())
        .fontSize(this.getTimeSectionFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)

      Text(slot.getTimeRangeText())
        .fontSize(this.getTimeRangeFontSize())
        .fontColor($r('app.color.gray_deep'))
        .textAlign(TextAlign.Center)
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(slot.getSectionCount() * this.getSectionHeight())
    .padding({ left: 2, right: 2 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .border({
      width: { top: 1, right: 1, bottom: 1, left: 1 },
      color: '#EAEAEA'
    })
    .backgroundColor(Color.White)
  }

  @Builder
  private buildDayBackground() {
    Column() {
      ForEach(this.sectionIndexes, (_section: number, index: number) => {
        Row() {}
          .width(BasicConstant.FULL_WIDTH)
          .height(this.getSectionHeight())
          .border({
            width: { top: index === 0 ? 1 : 0, right: 1, bottom: 1, left: 1 },
            color: '#EAEAEA'
          })
          .backgroundColor(Color.White)
      }, (section: number) => section.toString())
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(this.getTableHeight())
  }

  @Builder
  private buildCourseBlock(course: Course, offset: number) {
    Column({ space: 2 }) {
      Text(course.getCourseName())
        .fontSize(this.getCourseNameFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCourseTextColor(course, offset))
        .maxLines(4)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (course.getClassroom().trim().length > 0) {
        Text(course.getClassroom())
          .fontSize(this.getCourseInfoFontSize())
          .fontColor(this.getCourseTextColor(course, offset))
          // .maxLines(1)
          // .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (course.getTeacherName().trim().length > 0) {
        Text(course.getTeacherName())
          .fontSize(this.getCourseInfoFontSize())
          .fontColor(this.getCourseTextColor(course, offset))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(this.getCourseHeight(course))
    .padding({ left: 6, right: 6, top: 6, bottom: 6 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.getCourseBackgroundColor(course, offset))
    .borderRadius(10)
    .position({ x: 0, y: this.getCourseTop(course) })
  }

  @Builder
  private buildDayColumn(offset: number) {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildDayBackground()
      ForEach(this.pageData.getCoursesByOffset(offset), (course: Course) => {
        this.buildCourseBlock(course, offset)
      }, (course: Course) => course.getId())
    }
    .layoutWeight(1)
    .height(this.getTableHeight())
  }

  build() {
    Scroll() {
      Column({ space: 3 }) {
        Text(this.pageData.getAcademicWeekText())
          .width(BasicConstant.FULL_WIDTH)
          .textAlign(TextAlign.Center)
          .fontSize(this.getWeekTitleFontSize())
          .fontWeight(FontWeight.Bold)
          .fontColor(this.themeColor)
          .margin({ top: 5 })

        Row({ space: 2 }) {
          Blank()
            .width(this.getTimeColumnWidth())
            .height(this.getHeaderHeight())

          ForEach(this.dayOffsets, (offset: number) => {
            this.buildWeekHeader(offset)
          }, (offset: number) => offset.toString())
        }
        .width(BasicConstant.FULL_WIDTH)
        .alignItems(VerticalAlign.Center)

        Row({ space: 2 }) {
          Column() {
            ForEach(this.timeSlots, (slot: CourseScheduleTimeSlot) => {
              this.buildTimeSlot(slot)
            }, (slot: CourseScheduleTimeSlot) => slot.getStartSection().toString())
          }
          .width(this.getTimeColumnWidth())
          .height(this.getTableHeight())

          ForEach(this.dayOffsets, (offset: number) => {
            this.buildDayColumn(offset)
          }, (offset: number) => offset.toString())
        }
        .width(BasicConstant.FULL_WIDTH)
        .alignItems(VerticalAlign.Top)
      }
      .width(BasicConstant.FULL_WIDTH)
      .padding({ left: 0, right: 0, top: 6, bottom: 70 })
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }
}

@Component
export struct CourseSchedule {
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;
  @StorageProp('themeColor') themeColor: string = '#EA5C2E';
  @StorageProp('isExportCourseSchedule') isExportCourseSchedule: boolean = false;

  private swiperController: SwiperController = new SwiperController();
  private courseScheduleDataSource: CourseScheduleDataSource = new CourseScheduleDataSource(new Date());

  private hasImportedCourseSchedule(): boolean {
    return this.isExportCourseSchedule || courseStore.hasImportedCourse();
  }

  private canDisplayCourseSchedule(): boolean {
    return this.hasImportedCourseSchedule() && courseStore.canResolveDateCourses();
  }

  private getEmptyTitleFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 22 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 20 : 18;
  }

  private getEmptyDescFontSize(): number {
    return this.currentBreakpoint === BreakpointConstant.BREAKPOINT_LG ? 16 :
      this.currentBreakpoint === BreakpointConstant.BREAKPOINT_MD ? 15 : 14;
  }

  @Builder
  private buildEmptyState(title: string, description: string, showImportButton: boolean) {
    Column({ space: 12 }) {
      Text(title)
        .fontSize(this.getEmptyTitleFontSize())
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)

      Text(description)
        .fontSize(this.getEmptyDescFontSize())
        .fontColor($r('app.color.gray_deep'))
        .textAlign(TextAlign.Center)

      if (showImportButton) {
        Button('一键导入课程表（南信大）')
          .type(ButtonType.Capsule)
          .backgroundColor(this.themeColor)
          .fontColor('#FFFFFF')
          .margin({ top: 4 })
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({
              url: 'pages/CourseImport'
            }, router.RouterMode.Standard);
          })
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .padding({ left: 24, right: 24, bottom: 60 })
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  build() {
    Column() {
      if (!this.hasImportedCourseSchedule()) {
        this.buildEmptyState('还没有课程表', '先导入课程数据后，这里会显示按周滑动的课程表。', true)
      } else if (!this.canDisplayCourseSchedule()) {
        this.buildEmptyState('暂时无法生成课表', '已导入课程，但当前数据里没有识别到学期起始周信息。', false)
      } else {
        Swiper(this.swiperController) {
          LazyForEach(this.courseScheduleDataSource, (item: CourseScheduleWeekPageData) => {
            CourseScheduleWeekPage({ pageData: item })
          }, (item: CourseScheduleWeekPageData) => item.getKey())
        }
        .width(BasicConstant.FULL_WIDTH)
        .height(BasicConstant.FULL_HEIGHT)
        .autoPlay(false)
        .loop(false)
        .indicator(false)
        .index(this.courseScheduleDataSource.getInitialIndex())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .backgroundColor($r('app.color.backgroundcolor'))
  }
}
