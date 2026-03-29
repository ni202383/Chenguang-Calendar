import { common } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';

// [课程卡片] 单独管理今日课程卡片 formId，避免和倒计时/黄历卡片混用。
export class CourseWidgetFormIdStore {
  private static readonly PREF_NAME: string = 'course_widget_form_store';
  private static readonly KEY_FORM_IDS: string = 'course_widget_form_ids';

  private static getStore(context: common.Context): dataPreferences.Preferences {
    return dataPreferences.getPreferencesSync(context, { name: CourseWidgetFormIdStore.PREF_NAME });
  }

  static addFormId(context: common.Context, formId: string): void {
    try {
      const store = CourseWidgetFormIdStore.getStore(context);
      const current = String(store.getSync(CourseWidgetFormIdStore.KEY_FORM_IDS, '[]') ?? '[]');
      const idList = JSON.parse(current) as Array<string>;
      if (idList.indexOf(formId) >= 0) {
        return;
      }
      idList.push(formId);
      store.putSync(CourseWidgetFormIdStore.KEY_FORM_IDS, JSON.stringify(idList));
      store.flushSync();
    } catch (error) {
      console.error('[CourseWidgetFormIdStore] addFormId failed: ' + (error as Error).message);
    }
  }

  static removeFormId(context: common.Context, formId: string): void {
    try {
      const store = CourseWidgetFormIdStore.getStore(context);
      const current = String(store.getSync(CourseWidgetFormIdStore.KEY_FORM_IDS, '[]') ?? '[]');
      const idList = JSON.parse(current) as Array<string>;
      const nextList = idList.filter((id: string) => id !== formId);
      store.putSync(CourseWidgetFormIdStore.KEY_FORM_IDS, JSON.stringify(nextList));
      store.flushSync();
    } catch (error) {
      console.error('[CourseWidgetFormIdStore] removeFormId failed: ' + (error as Error).message);
    }
  }

  static getAllFormIds(context: common.Context): Array<string> {
    try {
      const store = CourseWidgetFormIdStore.getStore(context);
      const current = String(store.getSync(CourseWidgetFormIdStore.KEY_FORM_IDS, '[]') ?? '[]');
      return JSON.parse(current) as Array<string>;
    } catch (error) {
      console.error('[CourseWidgetFormIdStore] getAllFormIds failed: ' + (error as Error).message);
      return [];
    }
  }

  static hasFormId(context: common.Context, formId: string): boolean {
    return CourseWidgetFormIdStore.getAllFormIds(context).indexOf(formId) >= 0;
  }
}
