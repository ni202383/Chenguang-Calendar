export interface EventCountDownPlain {
  id: string;
  targetDate: string;      // ISO string
  eventName: string;
  eventDetail: string;
  imageIndex: number;      // -1 表示未选
  isImportant: boolean;
  hourMinuteSecondIsUsed : boolean;
  createdAt: string;       // ISO string
}

@Observed
export class EventCountDown {
  private id: string;
  private _targetDate: Date;

  public set targetDate(value: Date) {
    this._targetDate = value;
  }
  public get targetDate(): Date {
    return this._targetDate;
  }

  private _eventName: string;
  public set eventName(value: string) {
    this._eventName = value;
  }
  public get eventName(): string {
    return this._eventName;
  }

  private _eventDetail: string;
  public set eventDetail(value: string) {
    this._eventDetail = value;
  }
  public get eventDetail(): string {
    return this._eventDetail;
  }

  private _image: Resource;
  public set image(value: Resource) {
    this._image = value;
  }
  public get image(): Resource {
    return this._image;
  }

  // 用于持久化保存图片选择（Resource 无法直接 JSON）
  private _imageIndex: number = -1;
  public set imageIndex(value: number) {
    this._imageIndex = value;
  }
  public get imageIndex(): number {
    return this._imageIndex;
  }

  private createdAtTime: Date;
  private _hourMinuteSecondIsUsed : boolean;
  public set hourMinuteSecondIsUsed(value : boolean){
    this._hourMinuteSecondIsUsed = value;
  }
  public get hourMinuteSecondIsUsed(){
    return this._hourMinuteSecondIsUsed;
  }

  private _isImportant: boolean;
  public set isImportant(value: boolean) {
    this._isImportant = value;
  }
  public get isImportant(): boolean {
    return this._isImportant;
  }

  constructor();
  constructor(eventName?: string, eventDetail?: string, image?: Resource, isImportant?: boolean,
    targetDate?: Date,hourMinuteSecondIsUsed ?: boolean) {
    this._eventName = eventName ?? '';
    this._eventDetail = eventDetail ?? '';
    this._image = image ?? $r('app.media.noBackgroundImage');
    this._isImportant = isImportant ?? false;
    this._targetDate = targetDate ?? new Date();
    this._hourMinuteSecondIsUsed = hourMinuteSecondIsUsed ?? false;
    this.createdAtTime = new Date();
    this.id = this.createdAtTime.getTime().toString();
  }

  // ------- 关键：让 Store 能找到/更新/删除同一条数据 -------
  public getId(): string {
    return this.id;
  }
  public setId(id: string) {
    this.id = id;
  }

  public getCreatedAtTime(): Date {
    return this.createdAtTime;
  }
  public setCreatedAtTime(d: Date) {
    this.createdAtTime = d;
  }

  // ------- 序列化 / 反序列化（像 Task.toPlainObject/fromPlainObject） -------
  public toPlainObject(): EventCountDownPlain {
    return {
      id: this.getId(),
      targetDate: this.targetDate.toISOString(),
      eventName: this.eventName,
      eventDetail: this.eventDetail,
      imageIndex: this.imageIndex,
      isImportant: this.isImportant,
      hourMinuteSecondIsUsed : this.hourMinuteSecondIsUsed,
      createdAt: this.getCreatedAtTime().toISOString()
    }
  }

  public static fromPlainObject(obj: EventCountDownPlain): EventCountDown {
    const cd = new EventCountDown();
    cd.setId(obj.id);
    cd.targetDate = new Date(obj.targetDate);
    cd.eventName = obj.eventName;
    cd.eventDetail = obj.eventDetail;
    cd.imageIndex = typeof obj.imageIndex === 'number' ? obj.imageIndex : -1;
    cd.isImportant = !!obj.isImportant;
    cd.hourMinuteSecondIsUsed = obj.hourMinuteSecondIsUsed;
    cd.setCreatedAtTime(new Date(obj.createdAt));
    // cd.image 由 UI 用 backgroundImageList[cd.imageIndex] 进行恢复
    return cd;
  }
}