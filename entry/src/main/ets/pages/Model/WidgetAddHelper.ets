import { formBindingData, formProvider } from '@kit.FormKit';
import { Want, common } from '@kit.AbilityKit';
import { countDownWidgetBindStore } from './CountDownWidgetBindStore';
import { countDownStore } from './CountDownStore';

interface CountDownFormData {
  eventName: string;
  imageIndex: number;
  targetTime: number;
  hourMinuteSecondIsUsed: boolean;
}

export class WidgetAddHelper {
  /**
   * 应用内拉起“卡片管理”并确保预览卡片显示当前选择的倒计时内容。
   * 适用于：列表右滑“添加至桌面”、新建倒计时页“生成桌面小卡片”等场景。
   */
  static openManagerAndRefreshPreview(ctx: common.Context, countDownId: string): void {
    // 1) pending 更新成当前点击的对象（供 onAddForm / onCastToNormalForm 绑定使用）
    countDownWidgetBindStore.setPending(ctx, countDownId);

    // 2) 强制刷新“预览 formId”，解决：取消后再次打开仍显示旧预览的问题
    const previewFormId: string = countDownWidgetBindStore.getPreviewFormId(ctx);
    if (previewFormId.length > 0) {
      const cd = countDownStore.getById(countDownId);
      if (cd !== null) {
        const data: CountDownFormData = {
          eventName: cd.eventName,
          imageIndex: cd.imageIndex,
          targetTime: cd.targetDate.getTime(),
          hourMinuteSecondIsUsed: cd.hourMinuteSecondIsUsed
        };
        try {
          formProvider.updateForm(previewFormId, formBindingData.createFormBindingData(data));
        } catch (_) {
          // 预览 form 可能已经被系统销毁，忽略即可
        }
      }
    }

    // 3) 打开卡片管理（customize 加 nonce，避免系统复用旧参数导致预览不变）
    const want: Want = {
      bundleName: "com.example.chenguangCalendar",
      abilityName: 'EntryFormAbilityDate',
      parameters: {
        'ohos.extra.param.key.form_dimension': 2,
        'ohos.extra.param.key.form_name': 'CountDownWidget', // 与 form_config 中 name 保持一致
        'ohos.extra.param.key.module_name': 'entry',
        'ohos.extra.param.key.form_customize': JSON.stringify({
          countDownId: countDownId,
          nonce: Date.now()
        })
      }
    };

    // API 18+ 才支持；为了避免某些设备/模拟器不支持导致应用闪退，这里兜底捕获
    try {
      formProvider.openFormManager(want);
    } catch (e) {
      console.error('[WidgetAddHelper] openFormManager failed: ' + (e as Error).message);
    }
  }
}
