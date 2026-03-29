// [课程导入] 课程对象与序列化定义。
export interface CoursePlain {
  id: string;
  courseName: string;
  teacherName: string;
  classroom: string;
  dayOfWeek: number;
  startSection: number;
  endSection: number;
  weekIndexes: Array<number>;
  rawWeekText: string;
  sourceSystem: string;
  termLabel: string;
  importTime: string;
  // [课程时间] 持久化课程起止时间，旧数据缺失时会按节次自动补齐。
  startTimeText?: string;
  endTimeText?: string;
}

@Observed
export class Course {
  private id: string;
  private courseName: string;
  private teacherName: string;
  private classroom: string;
  private dayOfWeek: number;
  private startSection: number;
  private endSection: number;
  private weekIndexes: Array<number>;
  private rawWeekText: string;
  private sourceSystem: string;
  private termLabel: string;
  private importTime: Date;
  // [课程时间] 由节次映射得到的开始/结束时间，用于应用内课程区与桌面卡片展示。
  private startTimeText: string;
  private endTimeText: string;

  constructor();
  constructor(id: string, courseName: string, teacherName: string, classroom: string, dayOfWeek: number,
    startSection: number, endSection: number, weekIndexes: Array<number>, rawWeekText: string,
    sourceSystem: string, termLabel: string, importTime: Date, startTimeText?: string, endTimeText?: string);
  constructor(id?: string, courseName?: string, teacherName?: string, classroom?: string, dayOfWeek?: number,
    startSection?: number, endSection?: number, weekIndexes?: Array<number>, rawWeekText?: string,
    sourceSystem?: string, termLabel?: string, importTime?: Date, startTimeText?: string, endTimeText?: string) {
    this.id = id ?? '';
    this.courseName = courseName ?? '';
    this.teacherName = teacherName ?? '';
    this.classroom = classroom ?? '';
    this.dayOfWeek = dayOfWeek ?? 1;
    this.startSection = startSection ?? 1;
    this.endSection = endSection ?? 2;
    this.weekIndexes = weekIndexes ?? [];
    this.rawWeekText = rawWeekText ?? '';
    this.sourceSystem = sourceSystem ?? 'NUIST_JWXT';
    this.termLabel = termLabel ?? '';
    this.importTime = importTime ?? new Date();
    this.startTimeText = (startTimeText ?? '').trim().length > 0 ? (startTimeText ?? '') :
      Course.getSectionStartTime(this.startSection);
    this.endTimeText = (endTimeText ?? '').trim().length > 0 ? (endTimeText ?? '') :
      Course.getSectionEndTime(this.endSection);
  }

  public toPlainObject(): CoursePlain {
    return {
      id: this.getId(),
      courseName: this.getCourseName(),
      teacherName: this.getTeacherName(),
      classroom: this.getClassroom(),
      dayOfWeek: this.getDayOfWeek(),
      startSection: this.getStartSection(),
      endSection: this.getEndSection(),
      weekIndexes: this.getWeekIndexes(),
      rawWeekText: this.getRawWeekText(),
      sourceSystem: this.getSourceSystem(),
      termLabel: this.getTermLabel(),
      importTime: this.getImportTime().toISOString(),
      startTimeText: this.getStartTimeText(),
      endTimeText: this.getEndTimeText()
    };
  }

  public static fromPlainObject(obj: CoursePlain): Course {
    return new Course(
      obj.id,
      obj.courseName,
      obj.teacherName,
      obj.classroom,
      obj.dayOfWeek,
      obj.startSection,
      obj.endSection,
      obj.weekIndexes ?? [],
      obj.rawWeekText,
      obj.sourceSystem,
      obj.termLabel,
      new Date(obj.importTime),
      obj.startTimeText,
      obj.endTimeText
    );
  }

  // [课程时间] 第 1-11 节的固定作息表。
  public static getSectionStartTime(section: number): string {
    switch (section) {
      case 1: return '08:00';
      case 2: return '08:55';
      case 3: return '10:10';
      case 4: return '11:05';
      case 5: return '13:45';
      case 6: return '14:40';
      case 7: return '15:55';
      case 8: return '16:50';
      case 9: return '18:45';
      case 10: return '19:40';
      case 11: return '20:35';
      default: return '';
    }
  }

  public static getSectionEndTime(section: number): string {
    switch (section) {
      case 1: return '08:45';
      case 2: return '09:40';
      case 3: return '10:55';
      case 4: return '11:50';
      case 5: return '14:30';
      case 6: return '15:25';
      case 7: return '16:40';
      case 8: return '17:35';
      case 9: return '19:30';
      case 10: return '20:25';
      case 11: return '21:20';
      default: return '';
    }
  }

  public setId(id: string): void { this.id = id; }
  public getId(): string { return this.id; }

  public setCourseName(courseName: string): void { this.courseName = courseName; }
  public getCourseName(): string { return this.courseName; }

  public setTeacherName(teacherName: string): void { this.teacherName = teacherName; }
  public getTeacherName(): string { return this.teacherName; }

  public setClassroom(classroom: string): void { this.classroom = classroom; }
  public getClassroom(): string { return this.classroom; }

  public setDayOfWeek(dayOfWeek: number): void { this.dayOfWeek = dayOfWeek; }
  public getDayOfWeek(): number { return this.dayOfWeek; }

  public setStartSection(startSection: number): void {
    this.startSection = startSection;
    this.startTimeText = Course.getSectionStartTime(this.startSection);
  }
  public getStartSection(): number { return this.startSection; }

  public setEndSection(endSection: number): void {
    this.endSection = endSection;
    this.endTimeText = Course.getSectionEndTime(this.endSection);
  }
  public getEndSection(): number { return this.endSection; }

  public setWeekIndexes(weekIndexes: Array<number>): void { this.weekIndexes = weekIndexes; }
  public getWeekIndexes(): Array<number> { return this.weekIndexes; }

  public setRawWeekText(rawWeekText: string): void { this.rawWeekText = rawWeekText; }
  public getRawWeekText(): string { return this.rawWeekText; }

  public setSourceSystem(sourceSystem: string): void { this.sourceSystem = sourceSystem; }
  public getSourceSystem(): string { return this.sourceSystem; }

  public setTermLabel(termLabel: string): void { this.termLabel = termLabel; }
  public getTermLabel(): string { return this.termLabel; }

  public setImportTime(importTime: Date): void { this.importTime = importTime; }
  public getImportTime(): Date { return this.importTime; }

  public setStartTimeText(startTimeText: string): void { this.startTimeText = startTimeText; }
  public getStartTimeText(): string { return this.startTimeText; }

  public setEndTimeText(endTimeText: string): void { this.endTimeText = endTimeText; }
  public getEndTimeText(): string { return this.endTimeText; }

  public getTimeRangeText(): string {
    if (this.startTimeText.length === 0 || this.endTimeText.length === 0) {
      return '';
    }
    return this.startTimeText + '-' + this.endTimeText;
  }

  public getSectionRangeText(): string {
    return '第' + this.getStartSection().toString() + '-' + this.getEndSection().toString() + '节';
  }

  public isActiveInWeek(weekIndex: number): boolean {
    if (this.weekIndexes.length === 0) {
      return true;
    }
    return this.weekIndexes.indexOf(weekIndex) >= 0;
  }
}
