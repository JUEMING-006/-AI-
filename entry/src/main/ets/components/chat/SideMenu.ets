// 侧边栏面板 — Kimi风格对话历史 + 功能入口
// 纯面板组件，父组件控制位置(translate)和宽度
import { RouteNames } from '../../common/Constants';
import { ChatFontSize, ChatRadius, KimiGradient } from '../../common/DesignTokens';
import { chatStore } from '../../stores/ChatStore';
import { userStore } from '../../stores/UserStore';
import { Conversation, ConversationGroup, getConversationGroup } from '../../models/ChatModel';

// 侧边栏菜单项接口
interface SideMenuItem {
  label: string;
  icon: Resource;
  route: string;
}

const FEATURE_ENTRIES: SideMenuItem[] = [
  { label: '院校库', icon: $r('sys.symbol.building'), route: RouteNames.COLLEGE_DETAIL },
  { label: '志愿填报', icon: $r('sys.symbol.bookmark'), route: RouteNames.VOLUNTEER_RESULT },
  { label: '学习计划', icon: $r('sys.symbol.calendar'), route: RouteNames.STUDY_PLAN },
  { label: '政策资讯', icon: $r('sys.symbol.doc'), route: RouteNames.POLICY_DETAIL },
];

@ComponentV2
export struct SideMenu {
  @Param onClose: () => void = () => {};
  @Param onNavigate: (route: string) => void = () => {};
  @Local safeAreaTop: number = 0;

  aboutToAppear(): void {
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
  }

  private getGroupedConversations(): Map<ConversationGroup, Conversation[]> {
    const grouped: Map<ConversationGroup, Conversation[]> = new Map();
    for (const conversation of chatStore.conversations) {
      const group: ConversationGroup = getConversationGroup(conversation);
      let list: Conversation[] | undefined = grouped.get(group);
      if (list === undefined) {
        list = [];
        grouped.set(group, list);
      }
      list.push(conversation);
    }
    return grouped;
  }

  private getGroupOrder(): ConversationGroup[] {
    return [ConversationGroup.TODAY, ConversationGroup.YESTERDAY, ConversationGroup.WEEK, ConversationGroup.EARLIER];
  }

  build() {
    Column() {
      // 顶部用户区（含新建对话按钮）
      this.userHeader()

      // 原有功能入口
      this.featureEntries()

      // 分隔线
      Divider()
        .color($r('app.color.moon_divider'))
        .strokeWidth(0.5)
        .margin({ left: 16, right: 16, top: 2, bottom: 2 })

      // 历史对话列表（可滚动）
      this.conversationHistoryList()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.moon_bg_content'))
    .padding({ top: this.safeAreaTop })
  }

  // 顶部用户区
  @Builder
  userHeader() {
    Row({ space: 12 }) {
      // 头像（品牌蓝圆形）
      Column() {
        Text('JM')
          .fontSize(16)
          .fontColor('#FFFFFF')
          .fontWeight(FontWeight.Medium)
      }
      .width(48)
      .height(48)
      .borderRadius(24)
      .linearGradient({
        angle: KimiGradient.ANGLE,
        colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
      })
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text('觉明同学')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.moon_text_primary'))

          Text('VIP')
            .fontSize(10)
            .fontColor('#FFFFFF')
            .fontWeight(FontWeight.Bold)
            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
            .borderRadius(8)
            .linearGradient({
              angle: KimiGradient.ANGLE,
              colors: [[KimiGradient.START_COLOR, 0.0], [KimiGradient.END_COLOR, 1.0]]
            })
        }

        Text(userStore.signature || '点击设置签名')
          .fontSize(12)
          .fontColor($r('app.color.moon_text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)

      Blank()
    }
    .width('100%')
    .height(72)
    .padding({ left: 20, right: 20 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      this.onNavigate(RouteNames.SETTING);
      this.onClose();
    })
  }

  // 历史对话列表
  @Builder
  conversationHistoryList() {
    if (chatStore.conversations.length === 0) {
      Column() {
        Text('暂无对话历史')
          .fontSize(13)
          .fontColor($r('app.color.moon_text_hint'))
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    } else {
      Scroll() {
        Column() {
          ForEach(this.getGroupOrder(), (group: ConversationGroup) => {
            if (this.getGroupedConversations().has(group)) {
              Text(group)
                .fontSize(ChatFontSize.TIME_GROUP)
                .fontColor($r('app.color.moon_text_hint'))
                .margin({ left: 20, top: 6, bottom: 4 })

              ForEach(this.getGroupedConversations().get(group)!, (conversation: Conversation) => {
                this.conversationItem(conversation)
              }, (conversation: Conversation) => conversation.id)
            }
          }, (group: ConversationGroup) => group)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Start)
    }
  }

  // 单个对话项
  @Builder
  conversationItem(conversation: Conversation) {
    Row() {
      Text(conversation.title)
        .fontSize(14)
        .fontColor(chatStore.currentConversation === conversation
          ? $r('app.color.brand_primary')
          : $r('app.color.moon_text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)

      if (chatStore.currentConversation === conversation) {
        Button() {
          SymbolGlyph($r('sys.symbol.trash'))
            .fontSize(14)
            .fontColor([$r('app.color.moon_text_hint')])
        }
        .type(ButtonType.Circle)
        .width(28)
        .height(28)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          chatStore.deleteConversation(conversation);
        })
      }
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 12 })
    .margin({ left: 12, right: 12 })
    .borderRadius(ChatRadius.MENU_ITEM)
    .backgroundColor(chatStore.currentConversation === conversation
      ? $r('app.color.moon_selected_bg')
      : Color.Transparent)
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      chatStore.switchConversation(conversation);
      this.onClose();
    })
  }

  // 功能入口
  @Builder
  featureEntries() {
    Column() {
      ForEach(FEATURE_ENTRIES, (item: SideMenuItem) => {
        Row({ space: 12 }) {
          SymbolGlyph(item.icon)
            .fontSize(18)
            .fontColor([$r('app.color.moon_text_secondary')])

          Text(item.label)
            .fontSize(14)
            .fontColor($r('app.color.moon_text_primary'))
        }
        .width('100%')
        .height(44)
        .padding({ left: 16, right: 16 })
        .margin({ left: 12, right: 12, bottom: 6 })
        .borderRadius(ChatRadius.MENU_ITEM)
        .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
        .backgroundEffect({
          radius: 30,
          saturation: 2.0,
          brightness: 1.05,
          color: '#30FFFFFF'
        })
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.onNavigate(item.route);
          this.onClose();
        })
      }, (item: SideMenuItem) => item.route)
    }
    .width('100%')
  }
}
