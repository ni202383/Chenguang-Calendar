export class SolarTermsDetailInfo{
  private _image : Resource;

  public get image() :Resource {
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

  private _solarDateRange: string;

  public get solarDateRange(): string {
    return this._solarDateRange;
  }

  private _briefIntroduction: string;

  public get briefIntroduction(): string {
    return this._briefIntroduction;
  }

  private _meaning: string;

  public get meaning(): string {
    return this._meaning;
  }

  private _naturalAttributes: NaturalAttribute;

  public get naturalAttributes(): NaturalAttribute {
    return this._naturalAttributes;
  }

  private _customs: string;

  public get customs(): string {
    return this._customs;
  }
  constructor();
  constructor(image : Resource,name : string,EnglishName : string,solarDateRange : string,briefIntroduction : string,
    meaning : string, naturalAttributes : NaturalAttribute,customs : string);
  constructor(image ?: Resource,name ?: string,EnglishName ?: string,solarDateRange ?: string,briefIntroduction ?: string,
    meaning ?: string, naturalAttributes ?: NaturalAttribute,customs ?: string) {
    this._image = image ?? $r('app.media.background');
    this._name = name ?? '';
    this._EnglishName = EnglishName ?? '';
    this._solarDateRange = solarDateRange ?? '';
    this._briefIntroduction = briefIntroduction ?? '';
    this._meaning = meaning ?? '';
    this._naturalAttributes = naturalAttributes ?? new NaturalAttribute();
    this._customs = customs ?? '';
  }
}

export class NaturalAttribute{
  private _climateFeatures: string;

  public get climateFeatures(): string {
    return this._climateFeatures;
  }

  private _phenology: string;

  public get phenology(): string {
    return this._phenology;
  }
  constructor();
  constructor(climateFeatures : string,phenology : string);
  constructor(climateFeatures ?: string,phenology ?: string) {
    this._climateFeatures = climateFeatures ?? '';
    this._phenology = phenology ?? '';
  }
}