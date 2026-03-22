import { common } from '@kit.AbilityKit';
import dataPreferences from '@ohos.data.preferences';
import { Course, CoursePlain } from './Course';

interface CourseStoreSnapshot {
  courses: Array<CoursePlain>;
  termLabel: string;
  termStartDate: string;
  lastSyncTime: string;
  sourcePageUrl: string;
}

// [课程导入] 独立课程仓库，避免和普通日程直接耦合。
export class CourseStore {
  private static readonly PREF_NAME: string = 'course_store';
  private static readonly KEY_DATA: string = 'course_store_snapshot';
  // [课程颜色] 预置 35 种边框色，尽量让不同课程在一学期内拿到不同颜色。
  private static readonly COURSE_COLOR_PALETTE: Array<string> = [
    '#7E57C2', '#5C6BC0', '#42A5F5', '#29B6F6', '#26C6DA', '#26A69A', '#66BB6A', '#9CCC65', '#D4E157',
    '#FFCA28', '#FFA726', '#FF8A65', '#EF5350', '#EC407A', '#AB47BC', '#8D6E63', '#78909C', '#3F51B5',
    '#1E88E5', '#00ACC1', '#00897B', '#43A047', '#7CB342', '#C0CA33', '#FDD835', '#FB8C00', '#F4511E',
    '#E53935', '#D81B60', '#8E24AA', '#6D4C41', '#546E7A', '#3949AB', '#039BE5', '#00838F'
  ];
  private context?: common.UIAbilityContext;
  private pref?: dataPreferences.Preferences;
  private courseList: Array<Course> = [];
  private termLabel: string = '';
  private termStartDate: string = '';
  private lastSyncTime: string = '';
  private sourcePageUrl: string = '';
  private courseColorMap: Map<string, string> = new Map<string, string>();

  // [启动恢复] 允许 EntryAbility 在异步初始化完成前先注入 context，
  // 这样首页首次渲染时也能通过 getPreferencesSync 直接读到已导入的课表数据。
  public bindContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    this.pref = await dataPreferences.getPreferences(context, CourseStore.PREF_NAME);
    await this.loadFromDisk();
  }

  private async loadFromDisk(): Promise<void> {
    if (!this.pref) {
      return;
    }
    const json = await this.pref.get(CourseStore.KEY_DATA, '') as string;
    if (!json || json.trim().length === 0) {
      this.courseList = [];
      this.courseColorMap.clear();
      return;
    }
    try {
      const snapshot = JSON.parse(json) as CourseStoreSnapshot;
      this.courseList = (snapshot.courses ?? []).map(item => Course.fromPlainObject(item));
      this.termLabel = snapshot.termLabel ?? '';
      this.termStartDate = snapshot.termStartDate ?? '';
      this.lastSyncTime = snapshot.lastSyncTime ?? '';
      this.sourcePageUrl = snapshot.sourcePageUrl ?? '';
      this.sortInMemory();
      this.rebuildCourseColorMap();
    } catch (error) {
      console.error('[CourseStore] loadFromDisk failed: ' + (error as Error).message);
      this.courseList = [];
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
      this.pref = dataPreferences.getPreferencesSync(this.context, { name: CourseStore.PREF_NAME });
      return true;
    } catch (error) {
      console.error('[CourseStore] getPreferencesSync failed: ' + (error as Error).message);
      return false;
    }
  }

  private async saveToDisk(): Promise<void> {
    try {
      if (!this.pref) {
        if (!this.context) {
          return;
        }
        this.pref = await dataPreferences.getPreferences(this.context, CourseStore.PREF_NAME);
      }
      const snapshot: CourseStoreSnapshot = {
        courses: this.courseList.map(item => item.toPlainObject()),
        termLabel: this.termLabel,
        termStartDate: this.termStartDate,
        lastSyncTime: this.lastSyncTime,
        sourcePageUrl: this.sourcePageUrl
      };
      await this.pref!.put(CourseStore.KEY_DATA, JSON.stringify(snapshot));
      await this.pref!.flush();
    } catch (error) {
      console.error('[CourseStore] saveToDisk failed: ' + (error as Error).message);
    }
  }

  public async replaceAllAndFlush(courses: Array<Course>, termLabel: string, termStartDate: string,
    sourcePageUrl: string): Promise<void> {
    this.courseList = courses;
    this.termLabel = termLabel;
    this.termStartDate = termStartDate;
    this.lastSyncTime = new Date().toISOString();
    this.sourcePageUrl = sourcePageUrl;
    this.sortInMemory();
    this.rebuildCourseColorMap();
    await this.saveToDisk();
  }

  public getAll(): Array<Course> {
    if (!this.ensureSyncPref()) {
      return [];
    }
    try {
      const json = this.pref!.getSync(CourseStore.KEY_DATA, '') as string;
      if (!json || json.trim().length === 0) {
        this.courseList = [];
        this.courseColorMap.clear();
        return [];
      }
      const snapshot = JSON.parse(json) as CourseStoreSnapshot;
      this.courseList = (snapshot.courses ?? []).map(item => Course.fromPlainObject(item));
      this.termLabel = snapshot.termLabel ?? '';
      this.termStartDate = snapshot.termStartDate ?? '';
      this.lastSyncTime = snapshot.lastSyncTime ?? '';
      this.sourcePageUrl = snapshot.sourcePageUrl ?? '';
      this.sortInMemory();
      this.rebuildCourseColorMap();
      return this.courseList;
    } catch (error) {
      console.error('[CourseStore] getAll failed: ' + (error as Error).message);
      return [];
    }
  }

  public hasImportedCourse(): boolean {
    return this.getAll().length > 0;
  }

  public getTermLabel(): string {
    this.getAll();
    return this.termLabel;
  }

  public getTermStartDate(): string {
    this.getAll();
    return this.termStartDate;
  }

  public getLastSyncTime(): string {
    this.getAll();
    return this.lastSyncTime;
  }

  public getSourcePageUrl(): string {
    this.getAll();
    return this.sourcePageUrl;
  }

  public canResolveDateCourses(): boolean {
    return this.getTermStartDate().trim().length > 0;
  }

  public getCoursesByDate(date: Date): Array<Course> {
    const courses = this.getAll();
    if (courses.length === 0 || !this.canResolveDateCourses()) {
      return [];
    }
    const weekIndex = this.resolveWeekIndex(date);
    const dayOfWeek = this.resolveDayOfWeek(date);
    return courses.filter(item => item.getDayOfWeek() === dayOfWeek && item.isActiveInWeek(weekIndex))
      .sort((first: Course, second: Course) => first.getStartSection() - second.getStartSection());
  }

  public getCoursesBetween(startDate: Date, endDate: Date): Array<Course> {
    const result: Array<Course> = [];
    const cursor = new Date(startDate.getFullYear(), startDate.getMonth(), startDate.getDate());
    const last = new Date(endDate.getFullYear(), endDate.getMonth(), endDate.getDate());
    while (cursor.getTime() <= last.getTime()) {
      const dayCourses = this.getCoursesByDate(cursor);
      for (let i = 0; i < dayCourses.length; i++) {
        result.push(dayCourses[i]);
      }
      cursor.setDate(cursor.getDate() + 1);
    }
    return result;
  }

  public getWeeklyCourses(anchorDate: Date): Map<string, Array<Course>> {
    const weekMap: Map<string, Array<Course>> = new Map();
    const monday = this.getMonday(anchorDate);
    for (let offset = 0; offset < 7; offset++) {
      const currentDate = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + offset);
      weekMap.set(this.dateToKey(currentDate), this.getCoursesByDate(currentDate));
    }
    return weekMap;
  }

  public getBriefCourseList(limit: number): Array<Course> {
    return this.getAll().slice(0, Math.max(limit, 0));
  }

  private resolveWeekIndex(date: Date): number {
    const monday = this.getMonday(date);
    const termStartMonday = new Date(this.termStartDate);
    const diff = monday.getTime() - termStartMonday.getTime();
    return Math.floor(diff / (7 * 24 * 60 * 60 * 1000)) + 1;
  }

  private resolveDayOfWeek(date: Date): number {
    const day = date.getDay();
    return day === 0 ? 7 : day;
  }

  private getMonday(date: Date): Date {
    const current = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const day = current.getDay();
    const diff = day === 0 ? -6 : 1 - day;
    current.setDate(current.getDate() + diff);
    return current;
  }

  private dateToKey(date: Date): string {
    const year = date.getFullYear().toString();
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    return year + '-' + month + '-' + day;
  }

  // [课程颜色] 同名课程固定同色；先按课程名哈希排序，再顺序分配调色板，尽量避免同学期重复色。
  public getCourseBorderColor(courseName: string): string {
    if (this.courseColorMap.size === 0) {
      this.rebuildCourseColorMap();
    }
    const normalizedName: string = courseName.trim();
    if (normalizedName.length === 0) {
      return CourseStore.COURSE_COLOR_PALETTE[0];
    }
    const color: string | undefined = this.courseColorMap.get(normalizedName);
    if (color !== undefined) {
      return color;
    }
    const fallbackIndex: number = this.hashCourseName(normalizedName) % CourseStore.COURSE_COLOR_PALETTE.length;
    return CourseStore.COURSE_COLOR_PALETTE[fallbackIndex];
  }

  private rebuildCourseColorMap(): void {
    this.courseColorMap.clear();
    const uniqueCourseNames: Array<string> = [];
    for (let index = 0; index < this.courseList.length; index++) {
      const courseName: string = this.courseList[index].getCourseName().trim();
      if (courseName.length === 0 || uniqueCourseNames.indexOf(courseName) >= 0) {
        continue;
      }
      uniqueCourseNames.push(courseName);
    }
    uniqueCourseNames.sort((first: string, second: string) => {
      const firstHash: number = this.hashCourseName(first);
      const secondHash: number = this.hashCourseName(second);
      if (firstHash !== secondHash) {
        return firstHash - secondHash;
      }
      return first.localeCompare(second);
    });
    for (let index = 0; index < uniqueCourseNames.length; index++) {
      const paletteIndex: number = index % CourseStore.COURSE_COLOR_PALETTE.length;
      this.courseColorMap.set(uniqueCourseNames[index], CourseStore.COURSE_COLOR_PALETTE[paletteIndex]);
    }
  }

  private hashCourseName(courseName: string): number {
    let hash: number = 0;
    for (let index = 0; index < courseName.length; index++) {
      hash = (hash * 131 + courseName.charCodeAt(index)) % 2147483647;
    }
    return hash;
  }

  private sortInMemory(): void {
    this.courseList.sort((first: Course, second: Course) => {
      if (first.getDayOfWeek() !== second.getDayOfWeek()) {
        return first.getDayOfWeek() - second.getDayOfWeek();
      }
      if (first.getStartSection() !== second.getStartSection()) {
        return first.getStartSection() - second.getStartSection();
      }
      return first.getCourseName().localeCompare(second.getCourseName());
    });
  }
}

export const courseStore: CourseStore = new CourseStore();
