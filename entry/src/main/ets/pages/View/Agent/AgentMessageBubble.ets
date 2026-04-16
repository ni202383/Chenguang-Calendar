import { AgentChatMessage, AgentMessageStatus, AgentSender } from '../../Model/AgentModels';

@Component
export struct AgentMessageBubble {
  @ObjectLink message: AgentChatMessage;
  @StorageProp('themeColor') themeColor: string = '#EA5C2E';

  @Builder
  private avatar(text: string, isUser: boolean) {
    Text(text)
      .fontSize(14)
      .fontWeight(FontWeight.Bold)
      .fontColor(isUser ? Color.White : this.themeColor)
      .width(34)
      .height(34)
      .textAlign(TextAlign.Center)
      .backgroundColor(isUser ? this.themeColor : 'rgba(229,229,229,0.85)')
      .borderRadius(17)
      .padding({ top: 7 })
  }

  private bubbleBackground(): string {
    if (this.message.sender === AgentSender.User) {
      return this.themeColor;
    }
    if (this.message.status === AgentMessageStatus.Error) {
      return 'rgba(255,235,238,1)';
    }
    return 'rgba(255,255,255,0.96)';
  }

  private bubbleFontColor(): ResourceColor {
    if (this.message.sender === AgentSender.User) {
      return Color.White;
    }
    if (this.message.status === AgentMessageStatus.Error) {
      return Color.Red;
    }
    return Color.Black;
  }

  private displayText(): string {
    if (this.message.text.trim().length > 0) {
      return this.message.text;
    }
    if (this.message.sender === AgentSender.Assistant && this.message.status === AgentMessageStatus.Thinking) {
      return this.message.text.length > 0 ? this.message.text : '辰光正在思考…';
    }
    if (this.message.sender === AgentSender.Assistant && this.message.status === AgentMessageStatus.Streaming) {
      return '辰光正在整理回答…';
    }
    return '';
  }

  build() {
    Row({ space: 10 }) {
      if (this.message.sender !== AgentSender.User) {
        this.avatar('辰', false);
      }
      Column() {
        Text(this.displayText())
          .fontSize(16)
          .fontColor(this.bubbleFontColor())
          .lineHeight(24)
          .textAlign(TextAlign.Start)
          .width('100%')
      }
      .width('78%')
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      .backgroundColor(this.bubbleBackground())
      .borderRadius(18)
      .shadow({ radius: 8, color: '#12000000', offsetX: 0, offsetY: 2 })

      if (this.message.sender === AgentSender.User) {
        this.avatar('我', true);
      }
    }
    .width('100%')
    .justifyContent(this.message.sender === AgentSender.User ? FlexAlign.End : FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
    .padding({ left: 12, right: 12, top: 4, bottom: 4 })
  }
}
