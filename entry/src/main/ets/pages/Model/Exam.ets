// [考试导入] 考试对象与序列化定义。
export interface ExamPlain {
  id: string;
  courseName: string;
  teacherName: string;
  classroom: string;
  startTime: string;
  endTime: string;
  rawTimeText: string;
  termLabel: string;
  sourceSystem: string;
  importTime: string;
}

@Observed
export class Exam {
  private id: string;
  private courseName: string;
  private teacherName: string;
  private classroom: string;
  private startTime: string;
  private endTime: string;
  private rawTimeText: string;
  private termLabel: string;
  private sourceSystem: string;
  private importTime: Date;

  constructor();
  constructor(id: string, courseName: string, teacherName: string, classroom: string, startTime: string,
    endTime: string, rawTimeText: string, termLabel: string, sourceSystem: string, importTime: Date);
  constructor(id?: string, courseName?: string, teacherName?: string, classroom?: string, startTime?: string,
    endTime?: string, rawTimeText?: string, termLabel?: string, sourceSystem?: string, importTime?: Date) {
    this.id = id ?? '';
    this.courseName = courseName ?? '';
    this.teacherName = teacherName ?? '';
    this.classroom = classroom ?? '';
    this.startTime = startTime ?? '';
    this.endTime = endTime ?? '';
    this.rawTimeText = rawTimeText ?? '';
    this.termLabel = termLabel ?? '';
    this.sourceSystem = sourceSystem ?? 'NUIST_JWXT';
    this.importTime = importTime ?? new Date();
  }

  public toPlainObject(): ExamPlain {
    return {
      id: this.getId(),
      courseName: this.getCourseName(),
      teacherName: this.getTeacherName(),
      classroom: this.getClassroom(),
      startTime: this.getStartTime(),
      endTime: this.getEndTime(),
      rawTimeText: this.getRawTimeText(),
      termLabel: this.getTermLabel(),
      sourceSystem: this.getSourceSystem(),
      importTime: this.getImportTime().toISOString()
    };
  }

  public static fromPlainObject(obj: ExamPlain): Exam {
    return new Exam(
      obj.id,
      obj.courseName,
      obj.teacherName,
      obj.classroom,
      obj.startTime,
      obj.endTime,
      obj.rawTimeText,
      obj.termLabel,
      obj.sourceSystem,
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

  public setStartTime(startTime: string): void { this.startTime = startTime; }
  public getStartTime(): string { return this.startTime; }

  public setEndTime(endTime: string): void { this.endTime = endTime; }
  public getEndTime(): string { return this.endTime; }

  public setRawTimeText(rawTimeText: string): void { this.rawTimeText = rawTimeText; }
  public getRawTimeText(): string { return this.rawTimeText; }

  public setTermLabel(termLabel: string): void { this.termLabel = termLabel; }
  public getTermLabel(): string { return this.termLabel; }

  public setSourceSystem(sourceSystem: string): void { this.sourceSystem = sourceSystem; }
  public getSourceSystem(): string { return this.sourceSystem; }

  public setImportTime(importTime: Date): void { this.importTime = importTime; }
  public getImportTime(): Date { return this.importTime; }
}
