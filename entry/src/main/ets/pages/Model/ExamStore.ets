import { common } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';
import { Exam, ExamPlain } from './Exam';

interface ExamStoreSnapshot {
  exams: Array<ExamPlain>;
  termLabel: string;
  lastSyncTime: string;
  sourcePageUrl: string;
}

// [考试导入] 独立考试仓库，避免和课程/日程直接耦合。
export class ExamStore {
  private static readonly PREF_NAME: string = 'exam_store';
  private static readonly KEY_DATA: string = 'exam_store_snapshot';
  // [考试颜色] 同名考试固定同色，保持与课程模块一致的识别体验。
  private static readonly EXAM_COLOR_PALETTE: Array<string> = [
    '#7E57C2', '#5C6BC0', '#42A5F5', '#29B6F6', '#26C6DA', '#26A69A', '#66BB6A', '#9CCC65', '#D4E157',
    '#FFCA28', '#FFA726', '#FF8A65', '#EF5350', '#EC407A', '#AB47BC', '#8D6E63', '#78909C', '#3F51B5',
    '#1E88E5', '#00ACC1', '#00897B', '#43A047', '#7CB342', '#C0CA33', '#FDD835', '#FB8C00', '#F4511E',
    '#E53935', '#D81B60', '#8E24AA', '#6D4C41', '#546E7A', '#3949AB', '#039BE5', '#00838F'
  ];
  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;
  private examList: Array<Exam> = [];
  private termLabel: string = '';
  private lastSyncTime: string = '';
  private sourcePageUrl: string = '';
  private examColorMap: Map<string, string> = new Map<string, string>();

  public bindContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, ExamStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk(): Promise<void> {
    if (!this.pref) {
      return;
    }
    const json = await this.pref.get(ExamStore.KEY_DATA, '') as string;
    if (!json || json.trim().length === 0) {
      this.examList = [];
      this.examColorMap.clear();
      return;
    }
    try {
      const snapshot = JSON.parse(json) as ExamStoreSnapshot;
      this.examList = (snapshot.exams ?? []).map((item: ExamPlain) => Exam.fromPlainObject(item));
      this.termLabel = snapshot.termLabel ?? '';
      this.lastSyncTime = snapshot.lastSyncTime ?? '';
      this.sourcePageUrl = snapshot.sourcePageUrl ?? '';
      this.sortInMemory();
      this.rebuildExamColorMap();
    } catch (error) {
      console.error('[ExamStore] loadFromDisk failed: ' + (error as Error).message);
      this.examList = [];
    }
  }

  private ensureSyncPref(): boolean {
    if (this.pref) {
      return true;
    }
    if (!this.context) {
      return false;
    }
    try {
      this.pref = dataPreferences.getPreferencesSync(this.context, { name: ExamStore.PREF_NAME });
      return true;
    } catch (error) {
      console.error('[ExamStore] getPreferencesSync failed: ' + (error as Error).message);
      return false;
    }
  }

  private async saveToDisk(): Promise<void> {
    try {
      if (!this.pref) {
        if (!this.context) {
          return;
        }
        this.pref = await dataPreferences.getPreferences(this.context, ExamStore.PREF_NAME);
      }
      const snapshot: ExamStoreSnapshot = {
        exams: this.examList.map((item: Exam) => item.toPlainObject()),
        termLabel: this.termLabel,
        lastSyncTime: this.lastSyncTime,
        sourcePageUrl: this.sourcePageUrl
      };
      await this.pref!.put(ExamStore.KEY_DATA, JSON.stringify(snapshot));
      await this.pref!.flush();
    } catch (error) {
      console.error('[ExamStore] saveToDisk failed: ' + (error as Error).message);
    }
  }

  public async replaceAllAndFlush(exams: Array<Exam>, termLabel: string, sourcePageUrl: string): Promise<void> {
    this.examList = exams;
    this.termLabel = termLabel;
    this.lastSyncTime = new Date().toISOString();
    this.sourcePageUrl = sourcePageUrl;
    this.sortInMemory();
    this.rebuildExamColorMap();
    await this.saveToDisk();
  }

  public getAll(): Array<Exam> {
    if (!this.ensureSyncPref()) {
      return [];
    }
    try {
      const json = this.pref!.getSync(ExamStore.KEY_DATA, '') as string;
      if (!json || json.trim().length === 0) {
        this.examList = [];
        this.examColorMap.clear();
        return [];
      }
      const snapshot = JSON.parse(json) as ExamStoreSnapshot;
      this.examList = (snapshot.exams ?? []).map((item: ExamPlain) => Exam.fromPlainObject(item));
      this.termLabel = snapshot.termLabel ?? '';
      this.lastSyncTime = snapshot.lastSyncTime ?? '';
      this.sourcePageUrl = snapshot.sourcePageUrl ?? '';
      this.sortInMemory();
      this.rebuildExamColorMap();
      return this.examList;
    } catch (error) {
      console.error('[ExamStore] getAll failed: ' + (error as Error).message);
      return [];
    }
  }

  public hasImportedExam(): boolean {
    return this.getAll().length > 0;
  }

  public getTermLabel(): string {
    this.getAll();
    return this.termLabel;
  }

  public getLastSyncTime(): string {
    this.getAll();
    return this.lastSyncTime;
  }

  public getSourcePageUrl(): string {
    this.getAll();
    return this.sourcePageUrl;
  }

  public getExamsByDate(date: Date): Array<Exam> {
    const targetDate: string = this.formatDate(date);
    return this.getAll().filter((item: Exam) => this.formatDate(new Date(item.getStartTime())) === targetDate);
  }

  public getExamsBetween(startDate: Date, endDate: Date): Array<Exam> {
    const startTime: number = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate()).getTime();
    const endTime: number = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate(), 23, 59, 59).getTime();
    return this.getAll().filter((item: Exam) => {
      const examTime: number = new Date(item.getStartTime()).getTime();
      return examTime >= startTime && examTime <= endTime;
    });
  }

  public getBriefExamList(limit: number): Array<Exam> {
    return this.getAll().slice(0, Math.max(limit, 0));
  }

  public getExamBorderColor(courseName: string): string {
    if (!this.examColorMap.has(courseName)) {
      this.rebuildExamColorMap();
    }
    return this.examColorMap.get(courseName) ?? ExamStore.EXAM_COLOR_PALETTE[0];
  }

  private sortInMemory(): void {
    this.examList.sort((first: Exam, second: Exam) => {
      const firstTime: number = new Date(first.getStartTime()).getTime();
      const secondTime: number = new Date(second.getStartTime()).getTime();
      if (firstTime !== secondTime) {
        return firstTime - secondTime;
      }
      return first.getCourseName().localeCompare(second.getCourseName());
    });
  }

  private rebuildExamColorMap(): void {
    this.examColorMap.clear();
    const uniqueNames: Array<string> = [];
    const seenNames: Set<string> = new Set<string>();
    const exams: Array<Exam> = this.getAllByMemory();
    for (let index = 0; index < exams.length; index++) {
      const courseName: string = exams[index].getCourseName().trim();
      if (courseName.length === 0 || seenNames.has(courseName)) {
        continue;
      }
      seenNames.add(courseName);
      uniqueNames.push(courseName);
    }
    uniqueNames.sort((first: string, second: string) => this.hashName(first) - this.hashName(second));
    for (let index = 0; index < uniqueNames.length; index++) {
      const paletteIndex: number = index % ExamStore.EXAM_COLOR_PALETTE.length;
      this.examColorMap.set(uniqueNames[index], ExamStore.EXAM_COLOR_PALETTE[paletteIndex]);
    }
  }

  private getAllByMemory(): Array<Exam> {
    return this.examList;
  }

  private hashName(text: string): number {
    let hash: number = 0;
    for (let index = 0; index < text.length; index++) {
      hash = (hash * 131 + text.charCodeAt(index)) >>> 0;
    }
    return hash;
  }

  private formatDate(date: Date): string {
    const year: string = date.getFullYear().toString();
    const month: string = (date.getMonth() + 1).toString().padStart(2, '0');
    const day: string = date.getDate().toString().padStart(2, '0');
    return year + '-' + month + '-' + day;
  }
}

export const examStore: ExamStore = new ExamStore();
