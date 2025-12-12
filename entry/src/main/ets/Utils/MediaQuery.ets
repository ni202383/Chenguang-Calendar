import {mediaquery} from '@kit.ArkUI'
import {BreakpointConstant} from '../Constants/BreakpointConstant'

export class MediaQuery{
  private widthListenerSM : mediaquery.MediaQueryListener;
  private widthListenerMD : mediaquery.MediaQueryListener;
  private widthListenerLG : mediaquery.MediaQueryListener;
  private currentBreakpoint : string;

  constructor() {
    this.widthListenerSM = mediaquery.matchMediaSync(BreakpointConstant.BREAKPOINT_SM_VALUE_RANGE);
    this.widthListenerMD = mediaquery.matchMediaSync(BreakpointConstant.BREAKPOINT_MD_VALUE_RANGE);
    this.widthListenerLG = mediaquery.matchMediaSync(BreakpointConstant.BREAKPOINT_LG_VALUE_RANGE);
    this.currentBreakpoint = BreakpointConstant.BREAKPOINT_SM;
    AppStorage.setOrCreate(BreakpointConstant.CURRENT_BREAKPOINT,this.currentBreakpoint);
  }

  private updateCurrentBreakpoint(breakpoint : string){
    if(this.currentBreakpoint !== breakpoint){
      AppStorage.setOrCreate(BreakpointConstant.CURRENT_BREAKPOINT,breakpoint);
      this.currentBreakpoint = breakpoint;
    }
  }

  private isBreakpointSM = (mediaQueryResult : mediaquery.MediaQueryResult) => {
    if(mediaQueryResult.matches){
      this.updateCurrentBreakpoint(BreakpointConstant.BREAKPOINT_SM);
    }
  }

  private isBreakpointMD = (mediaQueryResult : mediaquery.MediaQueryResult) => {
    if(mediaQueryResult.matches){
      this.updateCurrentBreakpoint(BreakpointConstant.BREAKPOINT_MD);
    }
  }

  private isBreakpointLG = (mediaQueryResult : mediaquery.MediaQueryResult) => {
    if(mediaQueryResult.matches){
      this.updateCurrentBreakpoint(BreakpointConstant.BREAKPOINT_LG);
    }
  }

  public Register(){
    this.widthListenerSM.on('change',this.isBreakpointSM);
    this.widthListenerMD.on('change',this.isBreakpointMD);
    this.widthListenerLG.on('change',this.isBreakpointLG);
  }

  public unRegister(){
    this.widthListenerSM.off('change',this.isBreakpointSM);
    this.widthListenerMD.off('change',this.isBreakpointMD);
    this.widthListenerLG.off('change',this.isBreakpointLG);
  }

}