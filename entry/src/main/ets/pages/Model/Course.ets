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

  constructor();
  constructor(id: string, courseName: string, teacherName: string, classroom: string, dayOfWeek: number,
    startSection: number, endSection: number, weekIndexes: Array<number>, rawWeekText: string,
    sourceSystem: string, termLabel: string, importTime: Date);
  constructor(id?: string, courseName?: string, teacherName?: string, classroom?: string, dayOfWeek?: number,
    startSection?: number, endSection?: number, weekIndexes?: Array<number>, rawWeekText?: string,
    sourceSystem?: string, termLabel?: string, importTime?: Date) {
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
      importTime: this.getImportTime().toISOString()
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
      new Date(obj.importTime)
    );
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

  public setStartSection(startSection: number): void { this.startSection = startSection; }
  public getStartSection(): number { return this.startSection; }

  public setEndSection(endSection: number): void { this.endSection = endSection; }
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

  public isActiveInWeek(weekIndex: number): boolean {
    if (this.weekIndexes.length === 0) {
      return true;
    }
    return this.weekIndexes.indexOf(weekIndex) >= 0;
  }
}
