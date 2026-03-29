import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { FormIdStore } from '../Utils/FormIdStore'
import { CourseWidgetFormIdStore } from '../Utils/CourseWidgetFormIdStore';
import { TodayCourseWidgetHelper, TodayCourseWidgetFormData } from '../Utils/TodayCourseWidgetHelper';
import { countDownStore } from '../pages/Model/CountDownStore'   // 按你项目真实路径改
import { countDownWidgetBindStore } from '../pages/Model/CountDownWidgetBindStore';
import { EventCountDown, EventCountDownPlain } from '../pages/Model/EventCountDown';
import dataPreferences from '@ohos.data.preferences';

interface CountDownFormData {
  eventName: string;
  imageIndex: number;
  targetTime: number;
  hourMinuteSecondIsUsed: boolean;
}


export default class EntryFormAbilityDate extends FormExtensionAbility {

  // [课程卡片] 不再依赖唯一 form_name；实际配置名可能是 TodayCourseWidgetCard 等。
  private isTodayCourseFormName(formName: string): boolean {
    const normalized: string = formName.toLowerCase();
    return normalized.indexOf('todaycourse') >= 0 || normalized.indexOf('coursewidget') >= 0 || normalized.indexOf('course') >= 0;
  }

  private isTodayCourseMessage(message: string): boolean {
    return message.indexOf('refreshTodayCourse') >= 0;
  }

  onAddForm(want: Want) {
    const formId: string = String(want.parameters?.['ohos.extra.param.key.form_identity'] ?? '');
    const temporary: boolean = Boolean(want.parameters?.['ohos.extra.param.key.form_temporary'] ?? false);
    const formName: string = String(want.parameters?.['ohos.extra.param.key.form_name'] ?? '');

    if (this.isTodayCourseFormName(formName)) {
      // [课程卡片] 今日课程卡片独立登记 formId，避免和倒计时卡片混淆。
      if (formId.length > 0) {
        CourseWidgetFormIdStore.addFormId(this.context, formId);
      }
      const courseData: TodayCourseWidgetFormData = TodayCourseWidgetHelper.buildFormData(this.context);
      return formBindingData.createFormBindingData(courseData);
    }

    if (formId.length > 0) FormIdStore.addFormId(this.context, formId);

    // parse customize
    const rawCustomize = want.parameters?.['ohos.extra.param.key.form_customize'];
    let customizeStr: string = '';
    if (typeof rawCustomize === 'string') {
      customizeStr = rawCustomize;
    } else if (Array.isArray(rawCustomize) && rawCustomize.length > 0) {
      customizeStr = String(rawCustomize[0]);
    }

    let customizeId: string = '';
    try {
      if (customizeStr.length > 0) customizeId = String(JSON.parse(customizeStr)?.countDownId ?? '');
    } catch (_) {
      customizeId = '';
    }

    const boundId: string = formId.length > 0 ? (countDownWidgetBindStore.getCountDownId(this.context, formId) ?? '') : '';
    let renderId: string = customizeId || boundId || countDownWidgetBindStore.peekPending(this.context) || '';

    if (temporary && formId.length > 0) {
      countDownWidgetBindStore.setPreviewFormId(this.context, formId);
    }

    if (temporary && formId.length > 0 && renderId.length > 0) {
      countDownWidgetBindStore.cacheTemp(this.context, formId, renderId);
    }

    // 某些系统/机型会直接创建 normal form（temporary=false），也兼容
    if (!temporary && formId.length > 0) {
      if (renderId.length === 0) renderId = countDownWidgetBindStore.takePending(this.context) || '';
      if (renderId.length > 0) countDownWidgetBindStore.bind(this.context, formId, renderId);
    }
    console.log(`onAddForm中:formId : ${formId},temporary:${temporary},renderId:${renderId},countDownStore.getById(renderId):${countDownStore.getById(renderId)}`)

    const data: CountDownFormData = this.buildBindingDataById(renderId);
    return formBindingData.createFormBindingData(data);
  }

  private static readonly CD_PREF_NAME: string = 'countdown_store';
  private static readonly CD_KEY_DATA: string = 'countdown_json';

  private getCountDownByIdFromDisk(id: string): EventCountDown | null {
    if (id.length === 0) return null;

    try {
      const pref = dataPreferences.getPreferencesSync(this.context, { name: EntryFormAbilityDate.CD_PREF_NAME });
      const json = (pref.getSync(EntryFormAbilityDate.CD_KEY_DATA, '') as string) ?? '';
      if (json.trim().length === 0) return null;

      const arr = JSON.parse(json) as EventCountDownPlain[];
      for (let i = 0; i < arr.length; i++) {
        if (arr[i].id === id) return EventCountDown.fromPlainObject(arr[i]);
      }
      return null;
    } catch (e) {
      console.error('[FormExt] getCountDownByIdFromDisk failed: ' + (e as Error).message);
      return null;
    }
  }

  onCastToNormalForm(formId: string) {
    const fid: string = String(formId ?? '');
    if (fid.length === 0) return;

    // 优先用 temp 缓存，其次 pending（再其次已绑定）
    let id: string = countDownWidgetBindStore.getTemp(this.context, fid) || '';
    if (id.length === 0) id = countDownWidgetBindStore.peekPending(this.context) || '';
    if (id.length === 0) id = (countDownWidgetBindStore.getCountDownId(this.context, fid) ?? '') || '';

    if (id.length === 0) return;

    countDownWidgetBindStore.bind(this.context, fid, id);
    countDownWidgetBindStore.clearTemp(this.context, fid);

    // 转常态后主动刷新一次，否则可能还在显示临时的默认数据
    const data: CountDownFormData = this.buildBindingDataById(id);
    formProvider.updateForm(fid, formBindingData.createFormBindingData(data));
  }

  private buildBindingDataById(id: string): CountDownFormData {
    const cd = this.getCountDownByIdFromDisk(id);
    if (cd === null) {
      return { eventName: '倒计时', imageIndex: 0, targetTime: 0, hourMinuteSecondIsUsed: false };
    }
    return {
      eventName: cd.eventName,
      imageIndex: cd.imageIndex,
      targetTime: cd.targetDate.getTime(),
      hourMinuteSecondIsUsed: cd.hourMinuteSecondIsUsed
    };
  }


  onUpdateForm(formId: string) {
    const fid: string = String(formId ?? '');
    if (CourseWidgetFormIdStore.hasFormId(this.context, fid)) {
      TodayCourseWidgetHelper.refreshOneForm(this.context, fid).catch((error: Error) => {
        console.error('[EntryFormAbilityDate] refresh today course widget failed: ' + error.message);
      });
      return;
    }
    const id: string = (countDownWidgetBindStore.getCountDownId(this.context, fid) ?? '') || '';
    const data: CountDownFormData = this.buildBindingDataById(id);
    formProvider.updateForm(fid, formBindingData.createFormBindingData(data));
  }

  onFormEvent(formId: string, message: string) {
    const fid: string = String(formId ?? '');
    const eventMessage: string = String(message ?? '');
    console.info('[EntryFormAbilityDate] onFormEvent fid=' + fid + ', message=' + eventMessage);
    // [课程卡片] 与应用内主题色更新保持一致：按钮触发后直接走 updateForm 主动刷新当前课程卡片。
    if (fid.length > 0 && (CourseWidgetFormIdStore.hasFormId(this.context, fid) || this.isTodayCourseMessage(eventMessage))) {
      if (!CourseWidgetFormIdStore.hasFormId(this.context, fid)) {
        CourseWidgetFormIdStore.addFormId(this.context, fid);
      }
      TodayCourseWidgetHelper.refreshOneForm(this.context, fid).then(() => {
        console.info('[EntryFormAbilityDate] refresh today course widget success: ' + fid);
      }).catch((error: Error) => {
        console.error('[EntryFormAbilityDate] onFormEvent refresh today course widget failed: ' + error.message);
      });
      return;
    }
  }

  onRemoveForm(formId: string) {
    FormIdStore.removeFormId(this.context, formId);
    CourseWidgetFormIdStore.removeFormId(this.context, formId);
    countDownWidgetBindStore.unbind(this.context, formId);
  }

  onAcquireFormState(want: Want) {
    return formInfo.FormState.READY;
  }

  // ========== 复制一份你列表卡片的 formatRemainText（无需定时器） ==========
  private diffYMD(from: Date, to: Date): [number, number, number] {
    let start = new Date(from.getFullYear(), from.getMonth(), from.getDate());
    let end = new Date(to.getFullYear(), to.getMonth(), to.getDate());

    if (start.getTime() > end.getTime()) return [0, 0, 0];

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
    if (years < 0) return [0, 0, 0];
    return [years, months, days];
  }

  private diffHMS(diffMs: number): [number, number, number] {
    const totalSec = Math.max(0, Math.floor(diffMs / 1000));
    const hours = Math.floor(totalSec / 3600);
    const minutes = Math.floor((totalSec % 3600) / 60);
    const seconds = totalSec % 60;
    return [hours, minutes, seconds];
  }

  private formatRemainText(now: Date, target: Date): string {
    const diffMs = target.getTime() - now.getTime();
    if (diffMs <= 0) return '已到达';

    const oneDayMs = 24 * 60 * 60 * 1000;
    if (diffMs < oneDayMs) {
      let h = this.diffHMS(diffMs)[0];
      let m = this.diffHMS(diffMs)[1];
      let s = this.diffHMS(diffMs)[2];
      let str = '';
      if (h > 0) str += `${h}时`;
      if (m > 0) str += `${m}分`;
      str += `${s}秒`;
      return str;
    }

    let y = this.diffYMD(now, target)[0];
    let mo = this.diffYMD(now, target)[1];
    let d0 = this.diffYMD(now, target)[2];
    if (y >= 1) {
      let str = `${y}年`;
      if (mo > 0) str += `${mo}月`;
      if (d0 > 0) str += `${d0}日`;
      return str;
    }
    if (mo >= 1) {
      let str = `${mo}月`;
      if (d0 > 0) str += `${d0}日`;
      return str;
    }
    const d = Math.max(1, d0);
    return `${d}日`;
  }
}
