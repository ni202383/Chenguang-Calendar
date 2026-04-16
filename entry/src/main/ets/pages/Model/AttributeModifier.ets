export class ButtonModifier implements AttributeModifier<ButtonAttribute> {
  private width : number;
  private height : number;
  private backgroundColor : Resource | string;
  constructor(width : number,height : number) {
    this.width = width;
    this.height = height;
    this.backgroundColor = '#ffcbcbcb';
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance
      .height(this.height)
      .width(this.width)
      .backgroundColor(this.backgroundColor)
      .backgroundBlurStyle(BlurStyle.Thin)
      .type(ButtonType.Circle)
  }

  applyPressedAttribute(instance: ButtonAttribute): void {
    instance.backgroundColor('rgba(0, 0, 0, 0.10)')
  }
}