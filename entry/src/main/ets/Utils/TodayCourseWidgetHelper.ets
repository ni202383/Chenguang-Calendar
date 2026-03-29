import { common } from '@kit.AbilityKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import dataPreferences from '@ohos.data.preferences';
import { Course } from '../pages/Model/Course';
import { courseStore } from '../pages/Model/CourseStore';
import { CourseWidgetFormIdStore } from './CourseWidgetFormIdStore';
import { CourseStatusHelper, CourseStatusInfo } from './CourseStatusHelper';

export interface TodayCourseWidgetLine {
  courseName: string;
  classroom: string;
  timeRangeText: string;
  sectionRangeText: string;
  color: string;
  statusText: string;
  statusColor: string;
}

export interface TodayCourseWidgetFormData {
  title: string;
  dateText: string;
  weekText: string;
  emptyText: string;
  courseCount: number;
  updatedAtText: string;
  coursesJson: string;
  themeColor: string;
}

// [课程卡片] 统一封装今日课程卡片的取数、渲染数据组装与批量刷新。
export class TodayCourseWidgetHelper {
  // [课程卡片] 单独持久化主题色，避免 FormExtensionAbility 直接读取 AppStorage 失效。
  private static readonly PREF_NAME: string = 'today_course_widget_store';
  private static readonly KEY_THEME_COLOR: string = 'themeColor';

  static buildFormData(context: common.Context): TodayCourseWidgetFormData {
    courseStore.bindContext(context);
    const today: Date = new Date();
    const courses: Array<Course> = courseStore.getCoursesByDate(today);
    const widgetLines: Array<TodayCourseWidgetLine> = [];
    const themeColor: string = TodayCourseWidgetHelper.resolveThemeColor(context);
    for (let index = 0; index < courses.length; index++) {
      const course: Course = courses[index];
      widgetLines.push(TodayCourseWidgetHelper.buildWidgetLine(course, today, themeColor));
    }
    return {
      title: '今日课程',
      dateText: TodayCourseWidgetHelper.formatDateText(today),
      weekText: TodayCourseWidgetHelper.resolveWeekText(today),
      emptyText: courses.length === 0 ? '今日无课程' : '',
      courseCount: courses.length,
      updatedAtText: '已更新，时间：' + TodayCourseWidgetHelper.formatClockText(new Date()),
      coursesJson: JSON.stringify(widgetLines),
      themeColor: themeColor
    };
  }

  static async refreshAllForms(context: common.Context): Promise<void> {
    const formIds: Array<string> = CourseWidgetFormIdStore.getAllFormIds(context);
    if (formIds.length === 0) {
      return;
    }
    const formData: TodayCourseWidgetFormData = TodayCourseWidgetHelper.buildFormData(context);
    for (let index = 0; index < formIds.length; index++) {
      const formId: string = formIds[index];
      try {
        await formProvider.updateForm(formId, formBindingData.createFormBindingData(formData));
      } catch (error) {
        const err: Error = error as Error;
        console.error('[TodayCourseWidgetHelper] refreshAllForms failed: ' + err.message);
      }
    }
  }

  static async refreshOneForm(context: common.Context, formId: string): Promise<void> {
    const formData: TodayCourseWidgetFormData = TodayCourseWidgetHelper.buildFormData(context);
    await formProvider.updateForm(formId, formBindingData.createFormBindingData(formData));
  }

  // [课程卡片] 应用内主题色变化时写入共享偏好，供卡片刷新时读取。
  static persistThemeColor(context: common.Context, themeColor: string): void {
    try {
      const pref: dataPreferences.Preferences = dataPreferences.getPreferencesSync(context,
        { name: TodayCourseWidgetHelper.PREF_NAME });
      pref.putSync(TodayCourseWidgetHelper.KEY_THEME_COLOR, themeColor);
      pref.flushSync();
    } catch (error) {
      console.error('[TodayCourseWidgetHelper] persistThemeColor failed: ' + (error as Error).message);
    }
  }

  private static resolveThemeColor(context: common.Context): string {
    try {
      const pref: dataPreferences.Preferences = dataPreferences.getPreferencesSync(context,
        { name: TodayCourseWidgetHelper.PREF_NAME });
      const color: string = String(pref.getSync(TodayCourseWidgetHelper.KEY_THEME_COLOR, '#EA5C2E') ?? '#EA5C2E');
      if (color.trim().length > 0) {
        return color;
      }
    } catch (error) {
      console.error('[TodayCourseWidgetHelper] resolveThemeColor failed: ' + (error as Error).message);
    }
    return '#EA5C2E';
  }


  private static resolveWeekText(date: Date): string {
    const weekText: string = courseStore.getAcademicWeekTextByDate(date);
    if (weekText.trim().length > 0) {
      return weekText;
    }
    return '教学周待更新';
  }

  private static buildWidgetLine(course: Course, date: Date, themeColor: string): TodayCourseWidgetLine {
    const status: CourseStatusInfo = CourseStatusHelper.getCourseStatus(course, date, themeColor);
    return {
      courseName: course.getCourseName(),
      classroom: course.getClassroom(),
      timeRangeText: course.getTimeRangeText(),
      sectionRangeText: course.getSectionRangeText(),
      color: courseStore.getCourseBorderColor(course.getCourseName()),
      statusText: status.text,
      statusColor: status.color
    };
  }

  private static formatDateText(date: Date): string {
    const labels: Array<string> = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return (date.getMonth() + 1).toString() + '月' + date.getDate().toString() + '日 ' + labels[date.getDay()];
  }

  // [课程卡片] 显示到秒，便于用户直观看到刷新按钮是否立即生效。
  private static formatClockText(date: Date): string {
    const hour: string = date.getHours().toString().padStart(2, '0');
    const minute: string = date.getMinutes().toString().padStart(2, '0');
    const second: string = date.getSeconds().toString().padStart(2, '0');
    return hour + ':' + minute + ':' + second;
  }
}
