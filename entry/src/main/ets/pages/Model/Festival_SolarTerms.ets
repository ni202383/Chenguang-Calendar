export class Festival_SolarTerms{
  private _name: string;

  public get name(): string {
    return this._name;
  }

  private _date: string;

  public get date(): string {
    return this._date;
  }

  private _week: string;

  public get week(): string {
    return this._week;
  }

  constructor();
  constructor(name : string,date : string,week : string);
  constructor(name ?: string,date ?: string,week ?: string) {
    this._name = name ?? '';
    this._date = date ?? '';
    this._week = week ?? '';
  }
}