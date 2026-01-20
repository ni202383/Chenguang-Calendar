export class FestivalDetailInfo{
  private _image: Resource;

  public get image(): Resource {
    return this._image;
  }

  private _name: string;

  public get name(): string {
    return this._name;
  }

  private _EnglishName: string;

  public get EnglishName(): string {
    return this._EnglishName;
  }

  private _simpleIntroduction: string;

  public get simpleIntroduction(): string {
    return this._simpleIntroduction;
  }

  private _fullDescription: string;

  public get fullDescription(): string {
    return this._fullDescription;
  }

  private _origin: FestivalOrigin;

  public get origin(): FestivalOrigin {
    return this._origin;
  }

  private _custom: Array<FestivalCustom>;

  public get custom(): Array<FestivalCustom> {
    return this._custom;
  }

  private _culturalSignificance: string;

  public get culturalSignificance(): string {
    return this._culturalSignificance;
  }
  constructor();
  constructor(image : Resource,name : string,EnglishName : string,simpleIntroduction : string,
  fullDescription : string,origin : FestivalOrigin,custom : Array<FestivalCustom>,culturalSignificance : string);
  constructor(image ?: Resource,name ?: string,EnglishName ?: string,simpleIntroduction ?: string,
    fullDescription ?: string,origin ?: FestivalOrigin,custom ?: Array<FestivalCustom>,culturalSignificance ?: string) {
    this._image = image ?? $r('app.media.background')
    this._name = name ?? '';
    this._EnglishName = EnglishName ?? '';
    this._simpleIntroduction = simpleIntroduction ?? '';
    this._fullDescription = fullDescription ?? '';
    this._origin = origin ?? new FestivalOrigin();
    this._custom = custom ?? [];
    this._culturalSignificance = culturalSignificance ?? '';
  }

}

export class FestivalOrigin{
  private _originPeriod: string;

  public get originPeriod(): string {
    return this._originPeriod;
  }

  private _originStory: string;

  public get originStory(): string {
    return this._originStory;
  }

  private _originBackground: string;

  public get originBackground(): string {
    return this._originBackground;
  }

  private _keyFigures: Array<string>;

  public get keyFigures(): Array<string> {
    return this._keyFigures;
  }
  constructor();
  constructor(originPeriod : string,originStory : string,originBackground : string,keyFigures : Array<string>);
  constructor(originPeriod ?: string,originStory ?: string,originBackground ?: string,keyFigures ?: Array<string>) {
    this._originPeriod = originPeriod ?? '';
    this._originStory = originStory ?? '';
    this._originBackground = originBackground ?? '';
    this._keyFigures = keyFigures ?? [];
  }
}

export class FestivalCustom{
  private _customName: string;

  public get customName(): string {
    return this._customName;
  }

  private _customIntroduction: string;

  public get customIntroduction(): string {
    return this._customIntroduction;
  }
  constructor();
  constructor(customName : string,customIntroduction : string);
  constructor(customName ?: string,customIntroduction ?: string) {
    this._customName = customName ?? '';
    this._customIntroduction = customIntroduction ?? '';
  }

}