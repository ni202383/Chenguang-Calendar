import { StartCalendar } from './StartCalendar';
import { AgentChatPage } from './View/Agent/AgentChatPage';
import { CourseSchedule } from './View/CourseSchedule';

@Entry
@Component
struct Start {
  private tabsController : TabsController = new TabsController();
  @State currentIndex : number = 0;
  @StorageProp('themeColor') themeColor : string = '';

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
    .width('33%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.getUIContext().animateTo({
        curve : Curve.Smooth,
        duration :500
      },() => {
        this.tabsController.changeIndex(index);
        this.currentIndex = index;
      })
    })
  }

  build() {
    RelativeContainer() {
      Tabs({
        controller : this.tabsController,
      }){
        TabContent(){
          StartCalendar();
        }

        TabContent(){
          CourseSchedule();
        }

        TabContent(){
          AgentChatPage();
        }
      }
      .barWidth(0)
      .barHeight(0)
      .width('100%')
      .height('100%')
      .onChange((index) => {
        this.currentIndex = index;
      })

      Row(){
        this.bottomBar($r('app.media.calendar'),'日历',0)
        this.bottomBar($r('app.media.course_schedule'),'课程表',1)
        this.bottomBar($r('app.media.ai_chat_icon'),'智能对话',2)
      }
      .width('60%')
      .height(50)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.SpaceEvenly)
      .backgroundColor('rgba(255, 255, 255, 0.80)')
      .borderRadius(30)
      .borderColor('#3fbcbcbc')
      .borderWidth(1)
      .clickEffect({
        level : ClickEffectLevel.LIGHT
      })
      .alignRules({
        middle : {anchor : '__container__',align : HorizontalAlign.Center},
        bottom : {anchor : '__container__',align : VerticalAlign.Bottom}
      })
      .offset({y : -40})
      .shadow({
        radius : 20,
        type : ShadowType.COLOR,
        color : '#3faeaeae'
      })
    }
    .height('100%')
    .width('100%')
  }
}