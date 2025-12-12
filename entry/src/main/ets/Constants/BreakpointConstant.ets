export class BreakpointConstant{
  static readonly CURRENT_BREAKPOINT = 'currentBreakpoint';
  static readonly BREAKPOINT_SM : string = 'sm';
  static readonly BREAKPOINT_MD : string = 'md';
  static readonly BREAKPOINT_LG : string = 'lg';
  static readonly BREAKPOINT_VALUE_ARRAY : Array<string> = ['320vp','600vp','840vp'];
  static readonly BREAKPOINT_SM_VALUE_RANGE = '(320vp<=width<600vp)';
  static readonly BREAKPOINT_MD_VALUE_RANGE = '(600vp<=width<840vp)';
  static readonly BREAKPOINT_LG_VALUE_RANGE = '(840vp<=width)';
}