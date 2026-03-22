import { BasicConstant } from '../../../Constants/BasicConstant';
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';
import { Course } from '../../Model/Course';
import { courseStore } from '../../Model/CourseStore';

function formatSectionRange(course: Course): string {
  return '第' + course.getStartSection().toString() + '-' + course.getEndSection().toString() + '节';
}

function formatDateLabel(date: Date): string {
  const month = (date.getMonth() + 1).toString();
  const day = date.getDate().toString();
  const labels: Array<string> = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  const dayOfWeek = date.getDay() === 0 ? 6 : date.getDay() - 1;
  return month + '/' + day + ' ' + labels[dayOfWeek];
}

@Component
struct CourseCard {
  @Prop course: Course;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;

  private getCourseColor(): string {
    // [课程颜色] 同名课程走同一个颜色映射，边框色由 CourseStore 统一分配。
    return courseStore.getCourseBorderColor(this.course.getCourseName());
  }

  build() {
    Column({ space: 6 }) {
      Text(this.course.getCourseName())
        .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 15 : 18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getCourseColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(formatSectionRange(this.course))
        .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
        .fontColor($r('app.color.gray_deep'))

      if (this.course.getClassroom().trim().length > 0) {
        Text(this.course.getClassroom())
          .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
          .fontColor($r('app.color.gray_deep'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.course.getTeacherName().trim().length > 0) {
        Text(this.course.getTeacherName())
          .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
          .fontColor($r('app.color.gray_deep'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .padding(12)
    .backgroundColor(Color.White)
    // [课程颜色] 只改课程卡片边框颜色与圆角，不动其余 UI。
    .border({ width: 1, color: this.getCourseColor(), radius: 1 })
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct TodayCourseList {
  @Prop targetDate: Date;

  // 修改说明：ArkTS 的 build() 中不再定义局部变量，改为成员方法获取当天课程。
  private getTodayCourses(): Array<Course> {
    return courseStore.getCoursesByDate(this.targetDate);
  }

  build() {
    Column({ space: 10 }) {
      if (this.getTodayCourses().length === 0) {
        Text(courseStore.canResolveDateCourses() ? '当天没有课程' : '已导入课程，但当前页未识别到学期起始周信息')
          .fontSize(14)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach(this.getTodayCourses(), (course: Course) => {
          CourseCard({ course: course })
        }, (course: Course) => course.getId())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct WeekCourseList {
  @Prop anchorDate: Date;

  // 修改说明：ArkTS 的 build() 中不再定义局部变量，周一日期改为成员方法计算。
  private getWeekStartDate(): Date {
    let monday: Date = new Date(this.anchorDate.getFullYear(), this.anchorDate.getMonth(), this.anchorDate.getDate());
    let day: number = monday.getDay();
    let diff: number = day === 0 ? -6 : 1 - day;
    monday.setDate(monday.getDate() + diff);
    return monday;
  }

  // 修改说明：按偏移量获取某一天的日期，避免在 build() 内声明临时变量。
  private getDateByOffset(offset: number): Date {
    return new Date(this.getWeekStartDate().getFullYear(), this.getWeekStartDate().getMonth(),
      this.getWeekStartDate().getDate() + offset);
  }

  // 修改说明：按偏移量获取课程列表，避免在 build() 内声明临时变量。
  private getCoursesByOffset(offset: number): Array<Course> {
    return courseStore.getCoursesByDate(this.getDateByOffset(offset));
  }

  // 修改说明：抽成 @Builder，避免在 ForEach 回调中定义局部变量。
  @Builder
  private buildWeekDayCourses(offset: number) {
    Column({ space: 8 }) {
      Text(formatDateLabel(this.getDateByOffset(offset)))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
      if (this.getCoursesByOffset(offset).length === 0) {
        Text('无课程')
          .fontSize(13)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach(this.getCoursesByOffset(offset), (course: Course) => {
          CourseCard({ course: course })
        }, (course: Course) => course.getId())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 12 }) {
      if (!courseStore.canResolveDateCourses()) {
        Text('已导入课程，但当前页未识别到学期起始周信息')
          .fontSize(14)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach([0, 1, 2, 3, 4, 5, 6], (offset: number) => {
          this.buildWeekDayCourses(offset)
        }, (offset: number) => offset.toString())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct ImportedCourseBrief {
  @Prop limit: number = 5;

  // 修改说明：ArkTS 的 build() 中不再定义局部变量，改为成员方法获取课程摘要。
  private getBriefCourses(): Array<Course> {
    return courseStore.getBriefCourseList(this.limit);
  }

  build() {
    Column({ space: 10 }) {
      if (this.getBriefCourses().length === 0) {
        Text('暂无已导入课程')
          .fontSize(14)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach(this.getBriefCourses(), (course: Course) => {
          CourseCard({ course: course })
        }, (course: Course) => course.getId())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }
}
