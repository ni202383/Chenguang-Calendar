@Component
export struct AgentChatPage{
  build() {
    RelativeContainer(){
      Column(){
        Text('智能对话系统')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height('100%')
  }
}