export class cardAlmanacData {
  private Yi: string;
  private Ji: string;
  private caiPosition: string;
  private xiPosition: string;
  private fuPosition: string;
  private yangGuiPosition: string;

  constructor();

  constructor(Yi: string, Ji: string, caiShengPosition: string, xiShengPosition: string, fuShengPosition: string,
    yangGuiPosition: string);

  constructor(Yi?: string, Ji?: string, caiShengPosition?: string, xiShengPosition?: string, fuShengPosition?: string,
    yangGuiPosition?: string) {
    this.Yi = Yi ?? '';
    this.Ji = Ji ?? '';
    this.caiPosition = caiShengPosition ?? '';
    this.xiPosition = xiShengPosition ?? '';
    this.fuPosition = fuShengPosition ?? '';
    this.yangGuiPosition = yangGuiPosition ?? '';
  }

  public getYi() {
    return this.Yi;
  }

  public getJi() {
    return this.Ji;
  }

  public getXiPosition() {
    return this.xiPosition;
  }

  public getYangGuiPosition() {
    return this.yangGuiPosition;
  }

  public getFuPosition() {
    return this.fuPosition;
  }

  public getCaiPosition() {
    return this.caiPosition;
  }
}