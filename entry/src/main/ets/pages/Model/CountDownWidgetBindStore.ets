import { preferences } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const PREF_NAME = 'countdown_widget_bind';
const KEY_BINDING = 'formId_to_countDownId_json';
const KEY_PENDING = 'pending_countDownId';
const KEY_PREVIEW_FORM_ID = 'preview_form_id';

export class CountDownWidgetBindStore {
  private getPrefs(ctx: common.Context): preferences.Preferences {
    return preferences.getPreferencesSync(ctx, { name: PREF_NAME });
  }

  private readMap(prefs: preferences.Preferences): Record<string, string> {
    const json = prefs.getSync(KEY_BINDING, '{}') as string;
    try { return JSON.parse(json) ?? {}; } catch { return {}; }
  }

  private writeMap(prefs: preferences.Preferences, map: Record<string, string>) {
    prefs.putSync(KEY_BINDING, JSON.stringify(map));
    prefs.flush(); // 记得刷盘
  }

  bind(ctx: common.Context, formId: string, countDownId: string) {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);
    map[formId] = countDownId;
    this.writeMap(prefs, map);
  }

  unbind(ctx: common.Context, formId: string) {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);

    const newMap: Record<string, string> = {};
    const keys = Object.keys(map);
    for (let i = 0; i < keys.length; i++) {
      const k = keys[i];
      if (k !== formId && map[k] && map[k].length > 0) {
        newMap[k] = map[k];
      }
    }
    this.writeMap(prefs, newMap);
  }

  getBoundCountDownId(ctx: common.Context, formId: string): string {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);
    return map[formId] ?? '';
  }

  getCountDownId(ctx: common.Context, formId: string): string | null {
    return this.getBoundCountDownId(ctx, formId);
  }

  setPending(ctx: common.Context, countDownId: string) {
    const prefs = this.getPrefs(ctx);
    prefs.putSync(KEY_PENDING, countDownId);
    prefs.flush();
  }

  takePending(ctx: common.Context): string {
    const prefs = this.getPrefs(ctx);
    const id = ((prefs.getSync(KEY_PENDING, '') as string) ?? '');
    if (id.length > 0) {
      prefs.putSync(KEY_PENDING, '');
      prefs.flush();
    }
    return id;
  }

  private tempKey(formId: string): string {
    return `temp:${formId}`;
  }

  cacheTemp(ctx: common.Context, formId: string, countDownId: string): void {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);
    map[this.tempKey(formId)] = countDownId;
    this.writeMap(prefs, map);
  }

  getTemp(ctx: common.Context, formId: string): string {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);
    return map[this.tempKey(formId)] ?? '';
  }

  clearTemp(ctx: common.Context, formId: string): void {
    const prefs = this.getPrefs(ctx);
    const map = this.readMap(prefs);

    // 不用 delete：重建对象
    const newMap: Record<string, string> = {};
    const keys = Object.keys(map);
    const tk = this.tempKey(formId);

    for (let i = 0; i < keys.length; i++) {
      const k = keys[i];
      if (k !== tk) newMap[k] = map[k];
    }
    this.writeMap(prefs, newMap);
  }

  // 如果你现在的 pending 是 takePending（会清空），建议再加一个 peekPending（不清空）
  peekPending(ctx: common.Context): string {
    const prefs = this.getPrefs(ctx);
    return ((prefs.getSync(KEY_PENDING, '') as string) ?? '');
  }


  setPreviewFormId(ctx: common.Context, formId: string): void {
    const prefs = this.getPrefs(ctx);
    prefs.putSync(KEY_PREVIEW_FORM_ID, formId);
    prefs.flush();
  }

  getPreviewFormId(ctx: common.Context): string {
    const prefs = this.getPrefs(ctx);
    return ((prefs.getSync(KEY_PREVIEW_FORM_ID, '') as string) ?? '');
  }

}

export const countDownWidgetBindStore = new CountDownWidgetBindStore();
