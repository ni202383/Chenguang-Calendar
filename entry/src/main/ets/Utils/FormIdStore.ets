import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREFERENCES_NAME = 'my_widget_store';
const KEY_FORM_IDS = 'form_ids_key';

export class FormIdStore {
  // 获取 Preferences 实例
  private static async getStore(context: common.Context): Promise<preferences.Preferences> {
    return await preferences.getPreferences(context, PREFERENCES_NAME);
  }

  // 1. 添加 formId (当用户添加小组件时调用)
  static async addFormId(context: common.Context, formId: string) {
    try {
      const store = await FormIdStore.getStore(context);
      // 获取当前列表，如果没有则为空数组
      // 注意：Preferences 不支持直接存 Set，建议存 JSON 字符串以保证兼容性
      const currentStr = await store.get(KEY_FORM_IDS, '[]') as string;
      const idList: string[] = JSON.parse(currentStr);

      if (!idList.includes(formId)) {
        idList.push(formId);
        await store.put(KEY_FORM_IDS, JSON.stringify(idList));
        await store.flush(); // 必须调用 flush 写入磁盘
        console.info(`[FormIdStore] Added formId: ${formId}`);
      }
    } catch (err) {
      console.error(`[FormIdStore] Failed to add formId: ${err}`);
    }
  }

  // 2. 移除 formId (当用户删除小组件时调用)
  static async removeFormId(context: common.Context, formId: string) {
    try {
      const store = await FormIdStore.getStore(context);
      const currentStr = await store.get(KEY_FORM_IDS, '[]') as string;
      let idList: string[] = JSON.parse(currentStr);

      if (idList.includes(formId)) {
        idList = idList.filter(id => id !== formId);
        await store.put(KEY_FORM_IDS, JSON.stringify(idList));
        await store.flush();
        console.info(`[FormIdStore] Removed formId: ${formId}`);
      }
    } catch (err) {
      console.error(`[FormIdStore] Failed to remove formId: ${err}`);
    }
  }

  // 3. 获取所有 formId (用于批量更新)
  static async getAllFormIds(context: common.Context): Promise<string[]> {
    try {
      const store = await FormIdStore.getStore(context);
      const currentStr = await store.get(KEY_FORM_IDS, '[]') as string;
      return JSON.parse(currentStr);
    } catch (err) {
      console.error(`[FormIdStore] Failed to get formIds: ${err}`);
      return [];
    }
  }
}