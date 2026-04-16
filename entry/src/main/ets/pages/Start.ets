import { StartCalendar } from './StartCalendar';
import { AgentChatPage } from './View/Agent/AgentChatPage';
import { CourseSchedule } from './View/CourseSchedule';
import {HdsTabs,HdsTabsController,hdsMaterial} from '@kit.UIDesignKit'

@Entry
@Component
struct Start {
  private hdsTabsController : HdsTabsController = new HdsTabsController();
  @State currentIndex : number = 0;
  @StorageProp('themeColor') themeColor : string = '';
  @StorageLink('agentRootTabVersion') @Watch('handleAgentRootTabChange') agentRootTabVersion: number = 0;
  @StorageProp('agentRootTabIndex') agentRootTabIndex: number = 0;


  handleAgentRootTabChange(): void {
    if (this.currentIndex === this.agentRootTabIndex) {
      return;
    }
    this.getUIContext().animateTo({
      curve: Curve.Smooth,
      duration: 400
    }, () => {
      this.hdsTabsController.changeIndex(this.agentRootTabIndex);
      this.currentIndex = this.agentRootTabIndex;
    })
  }

  @Builder bottomBar(pic : Resource,text : string,index : number){
    Column(){
      Image(pic)
        .height(20)
        .objectFit(ImageFit.Auto)
        .fillColor(this.currentIndex == index ? this.themeColor : Color.Gray)

      Text(text)
        .fontSize(12)
        .fontColor(this.currentIndex == index ? this.themeColor : Color.Gray)
    }
    .height('90%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.getUIContext().animateTo({
        curve : Curve.Smooth,
        duration :500
      },() => {
        this.hdsTabsController.changeIndex(index);
        this.currentIndex = index;
      })
    })
  }

  build() {
    RelativeContainer() {

      HdsTabs({
        controller : this.hdsTabsController,
      }){
        TabContent(){
          StartCalendar();
        }
        .tabBar(this.bottomBar($r('app.media.calendar'),'日历',0))

        TabContent(){
          CourseSchedule();
        }
        .tabBar(this.bottomBar($r('app.media.course_schedule'),'课程表',1))

        TabContent(){
          AgentChatPage();
        }
        .tabBar(this.bottomBar($r('app.media.ai_chat_icon'),'智能对话',2))
      }
      .width('100%')
      .height('100%')
      .barOverlap(true)
      .vertical(false)
      .barPosition(BarPosition.End)
      .barFloatingStyle({
        barBottomMargin : 28,
        adaptToHandedness : true,
        systemMaterialEffect : {
          materialType : hdsMaterial.MaterialType.ADAPTIVE,
          materialLevel : hdsMaterial.MaterialLevel.ADAPTIVE
        },
        lightColor : this.themeColor
      })
      .onChange((index) => {
        this.currentIndex = index;
      })
      .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.TOP,SafeAreaEdge.BOTTOM])
    }
    .height('100%')
    .width('100%')
  }
}