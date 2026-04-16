import { common } from '@kit.AbilityKit';
import { formBindingData, formProvider } from '@kit.FormKit';
import { FormIdStore } from '../../Utils/FormIdStore';
import { TodayCourseWidgetHelper } from '../../Utils/TodayCourseWidgetHelper';
import { AgentExecutionResult } from '../Model/AgentModels';
import { AgentLogger } from './AgentLogger';

class ThemeColorPreset {
  name: string = '';
  hex: string = '';
}

export class AgentSettingService {
  private static readonly SCOPE: string = 'AgentSettingService';

  public static async setShowAlmanac(show: boolean, context: common.Context): Promise<AgentExecutionResult> {
    const result: AgentExecutionResult = new AgentExecutionResult();
    AppStorage.setOrCreate('isSubscribe', show);
    await AgentSettingService.refreshAlmanacForms(context, show);
    result.success = true;
    result.userText = show ? '已开启黄历显示。' : '已关闭黄历显示。';
    result.uiCommand.toastText = result.userText;
    AgentLogger.info(AgentSettingService.SCOPE, 'setShowAlmanac=' + show.toString());
    return result;
  }

  public static async setThemeColor(mode: string, value: string, context: common.Context): Promise<AgentExecutionResult> {
    const result: AgentExecutionResult = new AgentExecutionResult();
    const resolvedColor: string = AgentSettingService.resolveThemeColor(mode, value);
    if (resolvedColor.length === 0) {
      result.userText = '无法切换成该主题色，请提供常见颜色名称或十六进制颜色。';
      return result;
    }
    AppStorage.setOrCreate('themeColor', resolvedColor);
    TodayCourseWidgetHelper.persistThemeColor(context, resolvedColor);
    await TodayCourseWidgetHelper.refreshAllForms(context);
    result.success = true;
    result.userText = '主题色已切换为 ' + resolvedColor + '。';
    result.uiCommand.toastText = '主题色切换成功';
    AgentLogger.info(AgentSettingService.SCOPE, 'setThemeColor=' + resolvedColor);
    return result;
  }


  public static async setBottomAddTaskButtonEnabled(enabled: boolean): Promise<AgentExecutionResult> {
    const result: AgentExecutionResult = new AgentExecutionResult();
    AppStorage.setOrCreate('isSetChangingNewTaskButton', enabled);
    result.success = true;
    result.userText = enabled ? '已开启底部添加日程按钮。' : '已关闭底部添加日程按钮。';
    result.uiCommand.toastText = result.userText;
    AgentLogger.info(AgentSettingService.SCOPE, 'setBottomAddTaskButtonEnabled=' + enabled.toString());
    return result;
  }

  public static async setHoldingHandModeEnabled(enabled: boolean): Promise<AgentExecutionResult> {
    const result: AgentExecutionResult = new AgentExecutionResult();
    AppStorage.setOrCreate('changingNewTaskButtonHandingStatus', enabled);
    AppStorage.setOrCreate('currentHandingStatusString', '智感握姿');
    result.success = true;
    result.userText = enabled ? '已开启智感握姿功能。' : '已关闭智感握姿功能。';
    result.uiCommand.toastText = result.userText;
    AgentLogger.info(AgentSettingService.SCOPE, 'setHoldingHandModeEnabled=' + enabled.toString());
    return result;
  }

  public static resolveThemeColor(mode: string, value: string): string {
    const normalizedMode: string = mode.trim().toLowerCase();
    const normalizedValue: string = value.trim();
    if (normalizedMode === 'hex') {
      if (/^#[0-9a-fA-F]{6}$/.test(normalizedValue)) {
        return normalizedValue.toUpperCase();
      }
      return '';
    }
    const presetList: Array<ThemeColorPreset> = AgentSettingService.buildPresetList();
    const lowerName: string = normalizedValue.toLowerCase();
    for (let index: number = 0; index < presetList.length; index++) {
      const item: ThemeColorPreset = presetList[index];
      if (item.name === lowerName) {
        return item.hex;
      }
    }
    return '';
  }

  private static async refreshAlmanacForms(context: common.Context, isSubscribe: boolean): Promise<void> {
    const formIds: Array<string> = await FormIdStore.getAllFormIds(context);
    if (formIds.length === 0) {
      return;
    }
    const dataMap: Map<string, boolean> = new Map<string, boolean>();
    dataMap.set('isSubscribe', isSubscribe);
    const formData = formBindingData.createFormBindingData(dataMap);
    for (let index: number = 0; index < formIds.length; index++) {
      const formId: string = formIds[index];
      try {
        await formProvider.updateForm(formId, formData);
      } catch (error) {
        const err: Error = error as Error;
        AgentLogger.error(AgentSettingService.SCOPE, 'refreshAlmanacForms failed: ' + err.message);
      }
    }
  }

  private static buildPresetList(): Array<ThemeColorPreset> {
    const list: Array<ThemeColorPreset> = [];
    list.push(AgentSettingService.preset('红色', '#E53935'));
    list.push(AgentSettingService.preset('red', '#E53935'));
    list.push(AgentSettingService.preset('橙色', '#FB8C00'));
    list.push(AgentSettingService.preset('orange', '#FB8C00'));
    list.push(AgentSettingService.preset('黄色', '#FDD835'));
    list.push(AgentSettingService.preset('yellow', '#FDD835'));
    list.push(AgentSettingService.preset('绿色', '#43A047'));
    list.push(AgentSettingService.preset('green', '#43A047'));
    list.push(AgentSettingService.preset('蓝色', '#1E88E5'));
    list.push(AgentSettingService.preset('blue', '#1E88E5'));
    list.push(AgentSettingService.preset('青色', '#00ACC1'));
    list.push(AgentSettingService.preset('cyan', '#00ACC1'));
    list.push(AgentSettingService.preset('紫色', '#8E24AA'));
    list.push(AgentSettingService.preset('purple', '#8E24AA'));
    list.push(AgentSettingService.preset('粉色', '#D81B60'));
    list.push(AgentSettingService.preset('pink', '#D81B60'));
    list.push(AgentSettingService.preset('灰色', '#546E7A'));
    list.push(AgentSettingService.preset('gray', '#546E7A'));
    list.push(AgentSettingService.preset('grey', '#546E7A'));
    return list;
  }

  private static preset(name: string, hex: string): ThemeColorPreset {
    const preset: ThemeColorPreset = new ThemeColorPreset();
    preset.name = name.toLowerCase();
    preset.hex = hex;
    return preset;
  }
}
