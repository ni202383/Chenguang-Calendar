import { upper_bound } from "../../Utils/ViewUtils";
import { Task, TaskPlain } from "./DailyTask";
import { common } from "@kit.AbilityKit";
import dataPreferences from '@ohos.data.preferences';

export class TaskStore {
  private taskStore: Map<string, Array<Task>> = new Map<string, Array<Task>>();
  private static readonly PREF_NAME: string = 'task_store';
  private static readonly KEY_DATA: string = 'tasks_json';
  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;

  /**
   * 必须在应用启动时调用一次
   * 例如在 EntryAbility.onCreate 里：
   *   await taskStore.init(this.context);
   */
  public async init(context: common.UIAbilityContext) {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, TaskStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk() {
    if (!this.pref) {
      return;
    }
    const json = await this.pref.get(TaskStore.KEY_DATA, '') as string;
    if (!json || json.trim().length === 0) {
      return;
    }

    try {
      // { [dateKey: string]: TaskPlain[] }
      const obj = JSON.parse(json) as Record<string, TaskPlain[]>;
      this.taskStore.clear();
      Object.entries(obj).forEach((entry) => {
        const dateKey = entry[0];
        const plainArray = entry[1];
        const tasks = plainArray.map(p => Task.fromPlainObject(p));
        this.taskStore.set(dateKey, tasks);
      });
      // 恢复 Task.static_number，避免 ID 冲突
      let maxIdNum = 0;
      for (const entry of this.taskStore) {
        const arr = entry[1];
        for (const task of arr) {
          const id = task.getId();
          if (!id) continue;
          const parts = id.split('-');
          const last = parts[parts.length - 1];
          const n = Number(last);
          if (!Number.isNaN(n)) {
            maxIdNum = Math.max(maxIdNum, n);
          }
        }
      }
      if (typeof Task.static_number === 'number') {
        Task.static_number = Math.max(Task.static_number, maxIdNum + 1);
      }

      console.info('[TaskStore] loadFromDisk success');
    } catch (e) {
      console.error('[TaskStore] loadFromDisk JSON 解析失败: ' + (e as Error).message);
    }
  }

  // 把 this.taskStore 序列化为 JSON -> 写入 Preferences
  private async saveToDisk() {
    try {
      if (!this.pref) {
        if (!this.context) return;
        this.pref = await dataPreferences.getPreferences(this.context, TaskStore.PREF_NAME);
      }
      const obj: Record<string, TaskPlain[]> = {};
      for (const entry of this.taskStore.entries()) {
        const key = entry[0];
        const taskArray = entry[1];
        obj[key] = taskArray.map(task => task.toPlainObject());
      }

      const json = JSON.stringify(obj);
      await this.pref!.put(TaskStore.KEY_DATA, json);
      await this.pref!.flush();
      console.info('[TaskStore] saveToDisk success');
    } catch (e) {
      console.error('[TaskStore] saveToDisk 失败: ' + (e as Error).message);
    }
  }

  public dateToString(year: number, month: number, day: number): string {
    let yearString = year.toString();
    let monthString = month.toString().padStart(2, '0');
    let dayString = day.toString().padStart(2, '0');
    return `${yearString}-${monthString}-${dayString}`;
  }

  public updateTask(year: number, month: number, day: number, task: Task): boolean {
    let key = this.dateToString(year, month, day);
    let taskArray = this.taskStore.get(key) ?? [];
    for (let i = 0; i < taskArray.length; ++i) {
      if (taskArray[i].getId() == task.getId()) {
        taskArray[i] = task;
        this.taskStore.set(key, taskArray);
        this.saveToDisk();
        return true;
      }
    }
    return false;
  }

  public addTask(year: number, month: number, day: number, task: Task) {
    let key = this.dateToString(year, month, day);
    let taskArray = this.taskStore.get(key) ?? [];
    let index = upper_bound<Task>(
      taskArray,
      task,
      (first: Task, second: Task) => {
        if (first.getBeginHour() < second.getBeginHour()) return -1; else if (first.getBeginHour() >
        second.getBeginHour()) return 1; else {
          if (first.getBeginMinute() > second.getBeginMinute()) return 1; else if (first.getBeginMinute() <
          second.getBeginMinute()) return -1; else return 0;
        }
      }
    )
    task.setId(`${key}-${Task.static_number}`);
    Task.static_number++;
    taskArray.splice(index, 0, task);
    this.taskStore.set(key, taskArray);
    this.saveToDisk();

  }

  public getTask(year: number, month: number, day: number): Array<Task> {
    const key = this.dateToString(year, month, day);

    // 1. 先保证有 Preferences 实例（用同步接口）
    if (!this.pref) {
      if (!this.context) {
        console.error('[TaskStore] context 未初始化，请先在 EntryAbility 中调用 taskStore.init(this.context)');
        return [];
      }
      try {
        // API 10+ 支持 getPreferencesSync
        this.pref = dataPreferences.getPreferencesSync(this.context, { name: TaskStore.PREF_NAME });
      } catch (e) {
        console.error('[TaskStore] getPreferencesSync 失败: ' + (e as Error).message);
        return [];
      }
    }

    try {
      // 2. 从磁盘把整份 JSON 读出来（同步）
      const json = this.pref.getSync(TaskStore.KEY_DATA, '') as string;
      if (!json || json.trim().length === 0) {
        // 没有任何数据，直接返回空
        this.taskStore.clear();
        return [];
      }

      // 3. 解析 JSON -> { [dateKey: string]: TaskPlain[] }
      const obj = JSON.parse(json) as Record<string, TaskPlain[]>;
      // 4. 重新构建内存里的 taskStore
      this.taskStore.clear();
      Object.entries(obj).forEach((entry) => {
        const dateKey = entry[0];
        const plainArray = entry[1];
        const tasks = plainArray.map(p => Task.fromPlainObject(p));
        this.taskStore.set(dateKey, tasks);
      });

      // 5. 返回指定日期的任务数组
      return this.taskStore.get(key) ?? [];
    } catch (e) {
      console.error('[TaskStore] getTask 从磁盘读取失败: ' + (e as Error).message);
      return [];
    }
  }

  public deleteTask(year: number, month: number, day: number, task: Task): boolean {
    let key = this.dateToString(year, month, day);
    let taskArray = this.taskStore.get(key) ?? [];
    let flag = false;
    if (taskArray.length == 0) {
      return false;
    } else {
      for (let i = 0; i < taskArray.length; ++i) {
        if (taskArray[i].getId() == task.getId()) {
          taskArray.splice(i, 1);
          flag = true;
          break;
        }
      }
      if (flag) {
        this.taskStore.set(key, taskArray);
        this.saveToDisk();
        return true;
      } else {
        return false;
      }
    }
  }
}

export let taskStore: TaskStore = new TaskStore();