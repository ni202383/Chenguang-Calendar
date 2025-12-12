import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

const PREF_NAME: string = 'entry_bool_pref'; // 随便起，但保持唯一
const KEY_IS_SOMETHING: string = 'isSubscribe'; // 和 AppStorage 的 key 一样

// 写入 boolean
export async function saveToPrefs(ctx: common.Context, value: boolean) {
  const prefs = await dataPreferences.getPreferences(ctx, PREF_NAME);
  await prefs.put(KEY_IS_SOMETHING, value);
  await prefs.flush(); // 落盘
}

// 读取 boolean（给 FormExtensionAbility 用）
export async function loadFromPrefs(ctx: common.Context): Promise<boolean> {
  const prefs = await dataPreferences.getPreferences(ctx, PREF_NAME);
  const v = await prefs.get(KEY_IS_SOMETHING, false); // 默认 false
  return v as boolean;
}
