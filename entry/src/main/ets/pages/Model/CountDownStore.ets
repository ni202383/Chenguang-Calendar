import { EventCountDown, EventCountDownPlain } from './EventCountDown';
import { common } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';

export class CountDownStore {
  private static readonly PREF_NAME: string = 'countdown_store';
  private static readonly KEY_DATA: string = 'countdown_json';
  private static readonly LOG_PREFIX: string = '[CHENGGUANG_COUNTDOWN_STORE]';

  private countDownList: Array<EventCountDown> = [];
  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;

  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, CountDownStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk(): Promise<void> {
    if (this.pref === undefined) {
      return;
    }
    const json: string = await this.pref.get(CountDownStore.KEY_DATA, '') as string;
    this.rebuildFromJsonText(json);
  }

  private ensureSyncPreferences(): boolean {
    if (this.pref !== undefined) {
      return true;
    }
    if (this.context === undefined) {
      console.error(CountDownStore.LOG_PREFIX + ' context 未初始化，请先在 EntryAbility 中调用 countDownStore.init(this.context)');
      return false;
    }
    try {
      this.pref = dataPreferences.getPreferencesSync(this.context, { name: CountDownStore.PREF_NAME });
      return true;
    } catch (error) {
      const err: Error = error as Error;
      console.error(CountDownStore.LOG_PREFIX + ' getPreferencesSync 失败: ' + err.message);
      return false;
    }
  }

  private rebuildFromJsonText(json: string): void {
    if (json.trim().length === 0) {
      this.countDownList = [];
      console.info(CountDownStore.LOG_PREFIX + ' load empty');
      return;
    }
    try {
      const plainArray: Array<EventCountDownPlain> = JSON.parse(json) as Array<EventCountDownPlain>;
      const nextList: Array<EventCountDown> = [];
      for (let index: number = 0; index < plainArray.length; index++) {
        nextList.push(EventCountDown.fromPlainObject(plainArray[index]));
      }
      this.countDownList = nextList;
      this.sortInMemory();
      console.info(CountDownStore.LOG_PREFIX + ' load success');
    } catch (error) {
      const err: Error = error as Error;
      console.error(CountDownStore.LOG_PREFIX + ' load 失败: ' + err.message);
      this.countDownList = [];
    }
  }

  private saveToDiskSync(): boolean {
    if (!this.ensureSyncPreferences()) {
      return false;
    }
    try {
      const plainArray: Array<EventCountDownPlain> = [];
      for (let index: number = 0; index < this.countDownList.length; index++) {
        plainArray.push(this.countDownList[index].toPlainObject());
      }
      const json: string = JSON.stringify(plainArray);
      this.pref!.putSync(CountDownStore.KEY_DATA, json);
      this.pref!.flushSync();
      console.info(CountDownStore.LOG_PREFIX + ' save success');
      return true;
    } catch (error) {
      const err: Error = error as Error;
      console.error(CountDownStore.LOG_PREFIX + ' save 失败: ' + err.message);
      return false;
    }
  }

  public async addCountDownAndFlush(cd: EventCountDown): Promise<string> {
    this.getAll();
    if (cd.getId().trim().length === 0) {
      const now: Date = new Date();
      cd.setId(now.getTime().toString());
      cd.setCreatedAtTime(now);
    }
    this.countDownList.push(cd);
    this.sortInMemory();
    const saveSuccess: boolean = this.saveToDiskSync();
    if (!saveSuccess) {
      console.error(CountDownStore.LOG_PREFIX + ' addCountDownAndFlush 写盘失败 id=' + cd.getId());
      return '';
    }
    return cd.getId();
  }

  public getAll(): Array<EventCountDown> {
    if (!this.ensureSyncPreferences()) {
      return [];
    }
    try {
      const json: string = this.pref!.getSync(CountDownStore.KEY_DATA, '') as string;
      this.rebuildFromJsonText(json);
      return this.countDownList;
    } catch (error) {
      const err: Error = error as Error;
      console.error(CountDownStore.LOG_PREFIX + ' getAll 从磁盘读取失败: ' + err.message);
      return [];
    }
  }

  public addCountDown(cd: EventCountDown): boolean {
    this.getAll();
    if (cd.getId().trim().length === 0) {
      const now: Date = new Date();
      cd.setId(now.getTime().toString());
      cd.setCreatedAtTime(now);
    }
    this.countDownList.push(cd);
    this.sortInMemory();
    return this.saveToDiskSync();
  }

  public updateCountDown(cd: EventCountDown): boolean {
    this.getAll();
    const id: string = cd.getId();
    if (id.trim().length === 0) {
      return false;
    }
    for (let index: number = 0; index < this.countDownList.length; index++) {
      if (this.countDownList[index].getId() === id) {
        this.countDownList[index] = cd;
        this.sortInMemory();
        return this.saveToDiskSync();
      }
    }
    console.warn(CountDownStore.LOG_PREFIX + ' update miss id=' + id);
    return false;
  }

  public deleteCountDownById(id: string): boolean {
    this.getAll();
    let found: boolean = false;
    const nextList: Array<EventCountDown> = [];
    for (let index: number = 0; index < this.countDownList.length; index++) {
      const item: EventCountDown = this.countDownList[index];
      if (item.getId() === id) {
        found = true;
        continue;
      }
      nextList.push(item);
    }
    if (!found) {
      console.warn(CountDownStore.LOG_PREFIX + ' delete miss id=' + id);
      return false;
    }
    this.countDownList = nextList;
    return this.saveToDiskSync();
  }

  public getById(id: string): EventCountDown | null {
    const list: Array<EventCountDown> = this.getAll();
    for (let index: number = 0; index < list.length; index++) {
      if (list[index].getId() === id) {
        return list[index];
      }
    }
    return null;
  }

  private sortInMemory(): void {
    this.countDownList.sort((first: EventCountDown, second: EventCountDown) => {
      if (first.isImportant !== second.isImportant) {
        return first.isImportant ? -1 : 1;
      }
      const firstTargetTime: number = first.targetDate.getTime();
      const secondTargetTime: number = second.targetDate.getTime();
      if (firstTargetTime !== secondTargetTime) {
        return firstTargetTime - secondTargetTime;
      }
      return second.getCreatedAtTime().getTime() - first.getCreatedAtTime().getTime();
    });
  }
}

export let countDownStore: CountDownStore = new CountDownStore();
