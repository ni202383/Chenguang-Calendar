import { SolarTermsDetailInfo } from '../Model/SolarTermsDetailInfo';
import { SolarTermsDetailData } from '../../data/SolarTermsDetailData'
import { BasicConstant } from '../../Constants/BasicConstant';
import { BreakpointConstant } from '../../Constants/BreakpointConstant';
// import { FunctionController,FunctionComponent } from '@kit.AgentFrameworkKit'
import { common } from '@kit.AbilityKit'
import { hilog } from '@kit.PerformanceAnalysisKit';
import {BusinessError} from '@kit.BasicServicesKit'
import { ButtonModifier } from '../Model/AttributeModifier';

@Extend(Text) function titleFontStyle(currentBreakpoint : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 25 : 20)
  .fontWeight(FontWeight.Bold)
  .margin({top : 10})
}

@Extend(Text) function secondTitleFontStyle(currentBreakpoint : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 20 : 15)
  .fontWeight(FontWeight.Bold)
}

@Extend(Text) function contentFontStyle(currentBreakpoint : string){
  .fontSize(currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 20 : 15)
  .fontColor($r('app.color.gray_deeper'))
}

@Extend(Column) function contentColumnStyle(){
  .width(BasicConstant.FULL_WIDTH)
  .backgroundColor(Color.White)
  .borderRadius(20)
}

@Extend(Scroll) function scrollStyle(){
  .height(BasicConstant.FULL_HEIGHT)
  .scrollable(ScrollDirection.Vertical)
  .scrollBar(BarState.Off)
  .edgeEffect(EdgeEffect.Spring)
  .align(Alignment.Top)
  .borderRadius(20)
}

@Extend(Column) function contentInternalColumnStyle(){
  .width(BasicConstant.FULL_WIDTH)
  .alignItems(HorizontalAlign.Start)
  .justifyContent(FlexAlign.Start)
}

@Component
export struct SolarTermsInfo{
  @StorageProp('detailedSolarTermsName') @Watch('aboutToAppear') solarTermsName : string = '';
  @StorageLink('isShowSolarTermsDetail') isShowSolarTermsDetail : boolean = true;
  private solarTermsDetailInfo : SolarTermsDetailInfo = new SolarTermsDetailInfo();
  @StorageProp('topStatusBarHeight') topStatusBarHeight: number = 0;
  @StorageProp('bottomStatusBarHeight') bottomStatusBarHeight: number = 0;
  @StorageProp(BreakpointConstant.CURRENT_BREAKPOINT) currentBreakpoint : string = BreakpointConstant.BREAKPOINT_SM;
  @State isAgentSupport : boolean = false;
  // private controller : FunctionController = new FunctionController();
  private agentId : string = 'agent1ecc9bc0f8bb420f82b18a4320d8b8aa'

  aboutToAppear(): void {
    this.solarTermsDetailInfo = SolarTermsDetailData[this.solarTermsName];
    // this.checkAgentSupport();
    // this.initListeners();
  }

  // async checkAgentSupport() {
  //   try {
  //     let context = this.getUIContext()?.getHostContext() as common.UIAbilityContext;
  //     this.isAgentSupport = await this.controller.isAgentSupport(context, this.agentId)
  //   } catch (err) {
  //     hilog.error(0x0001, 'Agent', `err code: ${err.code}, message: ${err.message}`)
  //   }
  // }
  //
  // initListeners() {
  //   this.controller?.on('agentDialogOpened', this.onAgentOpenedCallback)
  //   this.controller?.on('agentDialogClosed', this.onAgentClosedCallback)
  // }
  // onAgentOpenedCallback = () => {
  //   hilog.info(0x0001, 'AgentExample', 'agent dialog opened callback')
  // }
  // onAgentClosedCallback = () => {
  //   hilog.info(0x0001, 'AgentExample', 'agent dialog closed callback')
  // }
  // aboutToDisappear() {
  //   this.controller?.off('agentDialogOpened')
  //   this.controller?.off('agentDialogClosed')
  // }

  @Builder briefRow(key : string,value : string){
    Row({space : 8}){
      Text(key)
        .secondTitleFontStyle(this.currentBreakpoint)
      Text(value)
        .contentFontStyle(this.currentBreakpoint)
    }
    .margin({bottom : 10})
  }

  @Builder paragraph(key : string,value : string){
    Column({space : 5}){
      Text(key)
        .secondTitleFontStyle(this.currentBreakpoint)
      Text(value)
        .contentFontStyle(this.currentBreakpoint)
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width(BasicConstant.FULL_WIDTH)
    .margin({bottom : 10})
  }

  @Builder content(){
    Column({space : 20}){
      Text('基本信息')
        .titleFontStyle(this.currentBreakpoint)

      Column({space : 5}){
        this.briefRow('名称',this.solarTermsDetailInfo.name)
        this.briefRow('英文名称',this.solarTermsDetailInfo.EnglishName)
        this.briefRow('所在公历日期',this.solarTermsDetailInfo.solarDateRange)
        this.paragraph('简介',this.solarTermsDetailInfo.briefIntroduction)
      }
      .contentInternalColumnStyle()

      this.paragraph('节气含义',this.solarTermsDetailInfo.meaning)

      Text('自然属性')
        .titleFontStyle(this.currentBreakpoint)

      Column(){
        this.paragraph('气候特征',this.solarTermsDetailInfo.naturalAttributes.climateFeatures)
        this.paragraph('物候特征',this.solarTermsDetailInfo.naturalAttributes.phenology)
      }
      .contentInternalColumnStyle()

      Text('习俗')
        .titleFontStyle(this.currentBreakpoint)

      this.paragraph('',this.solarTermsDetailInfo.customs)
    }
    .contentInternalColumnStyle()
    .padding({
      left : 10,
      right : 10
    })
  }

  onBackPress(): boolean | void {
    this.getUIContext().animateTo({
      curve : Curve.EaseInOut,
      duration : 400
    },() => {
      this.isShowSolarTermsDetail = !this.isShowSolarTermsDetail;
    })
  }

  build() {
    Column({space : 15}){
      Row(){
        Row({space : this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 15 : 10}){
          Button({type : ButtonType.Circle}){
            Image($r('app.media.return'))
              .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
              .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 20)
          }
          .attributeModifier(new ButtonModifier(
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40,
            this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 50 : 40
          ))
          .onClick((event: ClickEvent) => {
            this.getUIContext().animateTo({
              curve : Curve.EaseInOut,
              duration : 300
            },() => {
              this.isShowSolarTermsDetail = !this.isShowSolarTermsDetail;
            })
          })

          Text(this.solarTermsDetailInfo.name)
            .fontSize(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_LG ? 30 : 25)
            .fontWeight(FontWeight.Bold)
        }

        // FunctionComponent({
        //   agentId : this.agentId,
        //   onError: (err: BusinessError) => {
        //     hilog.error(0x0001, 'AgentExample', `err: ${JSON.stringify(err)}, message: ${err.message}`)
        //   },
        //   options : {
        //     queryText : `给我详细介绍一下${this.solarTermsDetailInfo.name}这个节气`,
        //   },
        //   controller : this.controller
        // })
      }
      .width(BasicConstant.FULL_WIDTH)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      if(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_SM){
        Scroll(){
          Column({space : 20}){
            Image(this.solarTermsDetailInfo.image)
              .width(BasicConstant.FULL_WIDTH)
              .borderRadius({
                topLeft : 20,
                topRight : 20
              })

            this.content()
          }
          .contentColumnStyle()
        }
        .width(BasicConstant.FULL_WIDTH)
        .scrollStyle()
        .margin({bottom : 55})

      } else {
        Row(){
          Scroll(){
            Image(this.solarTermsDetailInfo.image)
              .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? '45%' : '30%')
          }
          .height(BasicConstant.FULL_HEIGHT)
          .height(BasicConstant.FULL_HEIGHT)
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .padding({bottom : 10})

          Scroll(){
            Column(){
              this.content()
            }
            .contentColumnStyle()
          }
          .width(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? BasicConstant.HALF_WIDTH : '65%')
          .scrollStyle()

        }
        .width(BasicConstant.FULL_WIDTH)
        .height(this.currentBreakpoint == BreakpointConstant.BREAKPOINT_MD ? 710 : 620)
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
      }
    }
    .width(BasicConstant.FULL_WIDTH)
    .height(BasicConstant.FULL_HEIGHT)
    .backgroundColor($r('app.color.backgroundcolor'))
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .padding({top : this.getUIContext().px2vp(this.topStatusBarHeight)})
  }
}