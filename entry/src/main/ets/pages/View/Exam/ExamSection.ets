import { BasicConstant } from '../../../Constants/BasicConstant';
import { BreakpointConstant } from '../../../Constants/BreakpointConstant';
import { Exam } from '../../Model/Exam';
import { examStore } from '../../Model/ExamStore';

function formatExamDateLabel(date: Date): string {
  const month: string = (date.getMonth() + 1).toString();
  const day: string = date.getDate().toString();
  const labels: Array<string> = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  const dayOfWeek: number = date.getDay() === 0 ? 6 : date.getDay() - 1;
  return month + '/' + day + ' ' + labels[dayOfWeek];
}

function formatExamTimeRange(exam: Exam): string {
  const start: string = exam.getStartTime().replace('T', ' ');
  const end: string = exam.getEndTime().replace('T', ' ');
  const startParts: Array<string> = start.split(' ');
  const endParts: Array<string> = end.split(' ');
  if (startParts.length >= 2 && endParts.length >= 2) {
    return startParts[0] + ' ' + startParts[1].slice(0, 5) + ' - ' + endParts[1].slice(0, 5);
  }
  return exam.getRawTimeText();
}

@Component
struct ExamCard {
  @Prop exam: Exam;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint: string = BreakpointConstant.BREAKPOINT_SM;

  private getExamColor(): string {
    return examStore.getExamBorderColor(this.exam.getCourseName());
  }

  build() {
    Column({ space: 6 }) {
      Text(this.exam.getCourseName())
        .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 15 : 18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getExamColor())
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      if (formatExamTimeRange(this.exam).trim().length > 0) {
        Text(formatExamTimeRange(this.exam))
          .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
          .fontColor($r('app.color.gray_deep'))
      }

      if (this.exam.getClassroom().trim().length > 0) {
        Text(this.exam.getClassroom())
          .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
          .fontColor($r('app.color.gray_deep'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }

      if (this.exam.getTeacherName().trim().length > 0) {
        Text(this.exam.getTeacherName())
          .fontSize(this.currentBreakpoint === BreakpointConstant.BREAKPOINT_SM ? 12 : 14)
          .fontColor($r('app.color.gray_deep'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .padding(12)
    .backgroundColor(Color.White)
    .border({ width: 1, color: this.getExamColor() })
    .borderRadius(20)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct TodayExamList {
  @Prop targetDate: Date;

  private getTodayExams(): Array<Exam> {
    return examStore.getExamsByDate(this.targetDate);
  }

  build() {
    Column({ space: 10 }) {
      if (this.getTodayExams().length === 0) {
        Text('当天没有考试')
          .fontSize(14)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach(this.getTodayExams(), (exam: Exam) => {
          ExamCard({ exam: exam })
        }, (exam: Exam) => exam.getId())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }
}

@Component
export struct WeekExamList {
  @Prop anchorDate: Date;

  private getWeekStartDate(): Date {
    let monday: Date = new Date(this.anchorDate.getFullYear(), this.anchorDate.getMonth(), this.anchorDate.getDate());
    let day: number = monday.getDay();
    let diff: number = day === 0 ? -6 : 1 - day;
    monday.setDate(monday.getDate() + diff);
    return monday;
  }

  private getDateByOffset(offset: number): Date {
    return new Date(this.getWeekStartDate().getFullYear(), this.getWeekStartDate().getMonth(),
      this.getWeekStartDate().getDate() + offset);
  }

  private getExamsByOffset(offset: number): Array<Exam> {
    return examStore.getExamsByDate(this.getDateByOffset(offset));
  }

  @Builder
  private buildWeekDayExams(offset: number) {
    Column({ space: 8 }) {
      Text(formatExamDateLabel(this.getDateByOffset(offset)))
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
      if (this.getExamsByOffset(offset).length === 0) {
        Text('无考试')
          .fontSize(13)
          .fontColor($r('app.color.gray_deep'))
      } else {
        ForEach(this.getExamsByOffset(offset), (exam: Exam) => {
          ExamCard({ exam: exam })
        }, (exam: Exam) => exam.getId())
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    Column({ space: 12 }) {
      ForEach([0, 1, 2, 3, 4, 5, 6], (offset: number) => {
        this.buildWeekDayExams(offset)
      }, (offset: number) => offset.toString())
    }
    .width(BasicConstant.FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
  }
}
