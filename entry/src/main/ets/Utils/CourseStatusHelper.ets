import { Course } from '../pages/Model/Course';

export interface CourseStatusInfo {
  text: string;
  color: string;
}

export class CourseStatusHelper {
  private static readonly NOT_STARTED_TEXT: string = '未开始';
  private static readonly ONGOING_TEXT: string = '进行中';
  private static readonly FINISHED_TEXT: string = '已完成';

  private static readonly NOT_STARTED_COLOR: string = '#999999';
  private static readonly DEFAULT_ONGOING_COLOR: string = '#EA5C2E';
  private static readonly FINISHED_COLOR: string = '#2E8B57';

  static getCourseStatus(course: Course, courseDate: Date, ongoingColor?: string): CourseStatusInfo {
    const now: Date = new Date();
    const todayStart: Date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    const courseDayStart: Date = new Date(courseDate.getFullYear(), courseDate.getMonth(), courseDate.getDate(), 0, 0, 0,
      0);

    if (courseDayStart.getTime() < todayStart.getTime()) {
      return CourseStatusHelper.buildFinishedStatus();
    }
    if (courseDayStart.getTime() > todayStart.getTime()) {
      return CourseStatusHelper.buildNotStartedStatus();
    }

    const startDate: Date | null = CourseStatusHelper.parseCourseTime(courseDate, course.getStartTimeText());
    const endDate: Date | null = CourseStatusHelper.parseCourseTime(courseDate, course.getEndTimeText());
    if (startDate === null || endDate === null) {
      return CourseStatusHelper.buildNotStartedStatus();
    }

    if (now.getTime() < startDate.getTime()) {
      return CourseStatusHelper.buildNotStartedStatus();
    }
    if (now.getTime() > endDate.getTime()) {
      return CourseStatusHelper.buildFinishedStatus();
    }
    return CourseStatusHelper.buildOngoingStatus(ongoingColor);
  }

  private static parseCourseTime(courseDate: Date, timeText: string): Date | null {
    if (timeText.length < 5) {
      return null;
    }
    const hour: number = Number(timeText.substring(0, 2));
    const minute: number = Number(timeText.substring(3, 5));
    if (Number.isNaN(hour) || Number.isNaN(minute)) {
      return null;
    }
    return new Date(courseDate.getFullYear(), courseDate.getMonth(), courseDate.getDate(), hour, minute, 0, 0);
  }

  private static buildNotStartedStatus(): CourseStatusInfo {
    return {
      text: CourseStatusHelper.NOT_STARTED_TEXT,
      color: CourseStatusHelper.NOT_STARTED_COLOR
    };
  }

  private static buildOngoingStatus(ongoingColor?: string): CourseStatusInfo {
    return {
      text: CourseStatusHelper.ONGOING_TEXT,
      color: CourseStatusHelper.resolveOngoingColor(ongoingColor)
    };
  }

  private static buildFinishedStatus(): CourseStatusInfo {
    return {
      text: CourseStatusHelper.FINISHED_TEXT,
      color: CourseStatusHelper.FINISHED_COLOR
    };
  }

  private static resolveOngoingColor(ongoingColor?: string): string {
    if (ongoingColor !== undefined && ongoingColor.trim().length > 0) {
      return ongoingColor;
    }
    return CourseStatusHelper.DEFAULT_ONGOING_COLOR;
  }
}
