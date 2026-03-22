import { EventCountDown, EventCountDownPlain } from "./EventCountDown";
import { common } from "@kit.AbilityKit";
import dataPreferences from '@ohos.data.preferences';

export class CountDownStore {
  private countDownList: Array<EventCountDown> = [];
  private static readonly PREF_NAME: string = 'countdown_store';
  private static readonly KEY_DATA: string = 'countdown_json';

  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;

  /**
   * 必须在应用启动时调用一次
   * 例如在 EntryAbility.onCreate 里：
   *   await countDownStore.init(this.context);
   */
  public async init(context: common.UIAbilityContext) {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, CountDownStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk() {
    if (!this.pref) return;

    const json = await this.pref.get(CountDownStore.KEY_DATA, '') as string;
    if (!json || json.trim().length === 0) return;

    try {
      const arr = JSON.parse(json) as EventCountDownPlain[];
      this.countDownList = (arr ?? []).map(p => EventCountDown.fromPlainObject(p));
      this.sortInMemory();
      console.info('[CountDownStore] loadFromDisk success');
    } catch (e) {
      console.error('[CountDownStore] loadFromDisk JSON 解析失败: ' + (e as Error).message);
      this.countDownList = [];
    }
  }

  private async saveToDisk() {
    try {
      if (!this.pref) {
        if (!this.context) return;
        this.pref = await dataPreferences.getPreferences(this.context, CountDownStore.PREF_NAME);
      }
      const plainArr = this.countDownList.map(cd => cd.toPlainObject());
      const json = JSON.stringify(plainArr);
      await this.pref!.put(CountDownStore.KEY_DATA, json);
      await this.pref!.flush();
      console.info('[CountDownStore] saveToDisk success');
    } catch (e) {
      console.error('[CountDownStore] saveToDisk 失败: ' + (e as Error).message);
    }
  }

  public async addCountDownAndFlush(cd: EventCountDown): Promise<string> {
    if (!cd.getId() || cd.getId().trim().length === 0) {
      cd.setId(new Date().getTime().toString());
      cd.setCreatedAtTime(new Date());
    }
    this.countDownList.push(cd);
    this.sortInMemory();
    await this.saveToDisk();     // ✅关键：等待写盘完成
    return cd.getId();
  }


  // 像 TaskStore.getTask 那样：每次读取都同步从磁盘恢复一次，确保刷新可靠
  public getAll(): Array<EventCountDown> {
    if (!this.pref) {
      if (!this.context) {
        console.error('[CountDownStore] context 未初始化，请先在 EntryAbility 中调用 countDownStore.init(this.context)');
        return [];
      }
      try {
        this.pref = dataPreferences.getPreferencesSync(this.context, { name: CountDownStore.PREF_NAME });
      } catch (e) {
        console.error('[CountDownStore] getPreferencesSync 失败: ' + (e as Error).message);
        return [];
      }
    }

    try {
      const json = this.pref.getSync(CountDownStore.KEY_DATA, '') as string;
      if (!json || json.trim().length === 0) {
        this.countDownList = [];
        return [];
      }
      const arr = JSON.parse(json) as EventCountDownPlain[];
      this.countDownList = (arr ?? []).map(p => EventCountDown.fromPlainObject(p));
      this.sortInMemory();
      return this.countDownList;
    } catch (e) {
      console.error('[CountDownStore] getAll 从磁盘读取失败: ' + (e as Error).message);
      return [];
    }
  }

  public addCountDown(cd: EventCountDown): boolean {
    if (!cd.getId() || cd.getId().trim().length === 0) {
      cd.setId(new Date().getTime().toString());
      cd.setCreatedAtTime(new Date());
    }
    this.countDownList.push(cd);
    this.sortInMemory();
    this.saveToDisk();
    return true;
  }

  public updateCountDown(cd: EventCountDown): boolean {
    const id = cd.getId();
    if (!id) return false;

    for (let i = 0; i < this.countDownList.length; i++) {
      if (this.countDownList[i].getId() === id) {
        this.countDownList[i] = cd;
        this.sortInMemory();
        this.saveToDisk();
        return true;
      }
    }
    return false;
  }

  public deleteCountDownById(id: string): boolean {
    const before = this.countDownList.length;
    this.countDownList = this.countDownList.filter(x => x.getId() !== id);
    if (this.countDownList.length === before) return false;

    this.saveToDisk();
    return true;
  }

  public getById(id: string): EventCountDown | null {
    const list = this.getAll();
    for (let i = 0; i < list.length; i++) {
      if (list[i].getId() === id) return list[i];
    }
    return null;
  }


  private sortInMemory() {
    // 置顶优先，其次按目标时间升序，再按创建时间降序
    this.countDownList.sort((a, b) => {
      if (a.isImportant !== b.isImportant) return a.isImportant ? -1 : 1;
      const ta = a.targetDate.getTime();
      const tb = b.targetDate.getTime();
      if (ta !== tb) return ta - tb;
      return b.getCreatedAtTime().getTime() - a.getCreatedAtTime().getTime();
    });
  }
}

export let countDownStore: CountDownStore = new CountDownStore();