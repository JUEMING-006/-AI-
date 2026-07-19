// AI 对话主页 — 叠层侧边栏 + 右滑手势 + 对话列表
// 首页叠在侧边栏上，右滑打开暴露侧边栏，点击首页弹回
import { promptAction, display } from '@kit.ArkUI';
import { AppColors, RouteNames } from '../../common/Constants';
import { chatStore } from '../../stores/ChatStore';
import { ChatService } from '../../services/ChatService';
import { ChatMessage, MessageRole } from '../../models/ChatModel';
import { PolicyInfo } from '../../models/PolicyModel';
import { policyService } from '../../services/PolicyService';
import { ChatTopBar } from '../../components/chat/ChatTopBar';
import { ChatInputBar } from '../../components/chat/ChatInputBar';
import { ChatMessageBubble } from '../../components/chat/ChatMessageBubble';
import { ThinkingProcess } from '../../components/chat/ThinkingProcess';
import { SuggestionCards } from '../../components/chat/SuggestionCards';
import { SourceReference } from '../../components/chat/SourceReference';
import { SideMenu } from '../../components/chat/SideMenu';
import { ModelDropdownCard } from '../../components/chat/ModelDropdownCard';

// 升本价值卡片数据
interface ValueCard {
  title: string;
  value: string;
  desc: string;
  color: string;
}

const VALUE_CARDS: ValueCard[] = [
  { title: '薪资提升', value: '+40%', desc: '本科平均薪资较专科提升约40%', color: AppColors.PRIMARY_COLOR },
  { title: '升学路径', value: '本科→研究生', desc: '升本后可继续深造考研', color: AppColors.SUCCESS_COLOR },
  { title: '成功案例', value: '85%', desc: '往届学员85%成功升入本科', color: AppColors.WARNING_COLOR },
  { title: '就业选择', value: '+60%', desc: '本科可投递岗位数量较专科增加约60%', color: '#007AFF' },
  { title: '考公资格', value: '可报考', desc: '本科学历可报考更多公务员岗位', color: '#34C759' },
  { title: '职称评定', value: '提前1-2年', desc: '本科毕业可更快评定中级职称', color: '#FF9500' }
];

// 功能特色标签
interface FeatureTag {
  icon: Resource;
  label: string;
  color: string;
  route: string; // 空字符串=创建对话，否则跳转对应页面
}

const FEATURE_TAGS: FeatureTag[] = [
  { icon: $r('sys.symbol.star'), label: '智能问答', color: '#0066FF', route: '' },
  { icon: $r('sys.symbol.building'), label: '院校推荐', color: '#FF9500', route: RouteNames.COLLEGE_DETAIL },
  { icon: $r('sys.symbol.bookmark'), label: '志愿填报', color: '#34C759', route: RouteNames.VOLUNTEER_RESULT },
  { icon: $r('sys.symbol.doc'), label: '政策解读', color: '#AF52DE', route: RouteNames.POLICY_DETAIL }
];

// 暴露的首页宽度（约侧边栏按钮宽度，侧边栏打开时可见的首页边条）
const EXPOSE_WIDTH: number = 50;



@ComponentV2
export struct ChatPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local sideMenuOpen: boolean = false;
  @Local modelSheetVisible: boolean = false;
  @Local scroller: Scroller = new Scroller();
  // 首页位移：0=关闭(首页满屏)，maxTranslate=打开(首页右移暴露侧边栏)
  @Local mainTranslate: number = 0;
  @Local safeAreaTop: number = 0;
  @Local policyList: PolicyInfo[] = [];
  // Logo 动画状态
  @Local logoScale: number = 1.0;
  @Local logoFloatY: number = 0;
  @Local logoRotate: number = 0;
  private logoTimerId: number = -1;
  // 屏幕宽度（运行时获取）
  private screenWidth: number = 360;

  aboutToAppear(): void {
    const displayInfo = display.getDefaultDisplaySync();
    this.screenWidth = px2vp(displayInfo.width);
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
    this.loadPolicies();
    this.startLogoAnimation();
  }

  aboutToDisappear(): void {
    if (this.logoTimerId !== -1) {
      clearInterval(this.logoTimerId);
      this.logoTimerId = -1;
    }
  }

  private startLogoAnimation(): void {
    const startTime = Date.now();
    this.logoTimerId = setInterval(() => {
      const t = (Date.now() - startTime) / 1000;
      this.logoScale = 1.0 + 0.2 * Math.sin(t * 2);
      this.logoFloatY = -8 * Math.sin(t * 1.5);
      this.logoRotate = 12 * Math.sin(t * 1.2);
    }, 50);
  }

  private async loadPolicies(): Promise<void> {
    try {
      this.policyList = await policyService.getPolicies('');
    } catch (_e) {
      this.policyList = [];
    }
  }

  // 最大位移 = 屏幕宽度 - 暴露宽度
  private getMaxTranslate(): number {
    return this.screenWidth - EXPOSE_WIDTH;
  }

  // 发送消息
  private onSend(content: string): void {
    ChatService.sendMessage(content);
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }

  // 点击建议问题
  private onSuggestionClick(suggestion: string): void {
    this.onSend(suggestion);
  }

  // 导航到原有功能页面
  private onNavigate(route: string): void {
    if (route.length > 0) {
      this.pathStack.pushPath({ name: route });
    }
  }

  // 切换侧边栏
  private toggleSidebar(): void {
    if (this.sideMenuOpen) {
      this.closeSidebar();
    } else {
      this.openSidebar();
    }
  }

  // 打开侧边栏 — 首页右移
  private openSidebar(): void {
    this.getUIContext()?.animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
      this.mainTranslate = this.getMaxTranslate();
      this.sideMenuOpen = true;
    });
  }

  // 关闭侧边栏 — 首页弹回
  private closeSidebar(): void {
    this.getUIContext()?.animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.mainTranslate = 0;
      this.sideMenuOpen = false;
    });
  }

  build() {
    Stack({ alignContent: Alignment.Start }) {
      // === 第一层：侧边栏（始终在底层，首页覆盖其上）===
      SideMenu({
        onClose: () => {
          this.closeSidebar();
        },
        onNavigate: (route: string) => {
          this.onNavigate(route);
        }
      })
        .width('100%')
        .height('100%')
        // 侧边栏左滑关闭手势（不干扰垂直滚动和点击）
        .gesture(
          PanGesture({ fingers: 1, distance: 10, direction: PanDirection.Horizontal })
            .onActionUpdate((event: GestureEvent) => {
              if (this.sideMenuOpen) {
                const dx: number = event.offsetX;
                const maxT: number = this.getMaxTranslate();
                this.mainTranslate = Math.max(0, Math.min(maxT, maxT + dx));
              }
            })
            .onActionEnd((event: GestureEvent) => {
              if (this.sideMenuOpen) {
                const dx: number = event.offsetX;
                if (dx < -50) {
                  this.closeSidebar();
                } else {
                  this.openSidebar();
                }
              }
            })
        )

      // === 第二层：主内容区（叠在侧边栏上，打开时右移暴露侧边栏）===
      Stack() {
        if (chatStore.currentConversation === null) {
          // 空状态：首页（Logo + 问候语 + 功能标签 + 升本价值 + 政策 + 模拟输入框）
          this.homePage()
        } else {
          // 对话状态：消息列表 + 顶栏 + 输入栏
          Stack() {
            // 空消息时显示 Logo 动画
            if (chatStore.currentConversation!.messages.length === 0) {
              Column() {
                Image($r('app.media.logo'))
                  .width(80)
                  .height(80)
                  .borderRadius(40)
                  .objectFit(ImageFit.Cover)
                  .shadow({ radius: 12, color: '#20000000', offsetX: 0, offsetY: 4 })
                  .scale({ x: this.logoScale, y: this.logoScale })
                  .translate({ y: this.logoFloatY })
                  .rotate({ angle: this.logoRotate })

                Text('开始你的第一次对话')
                  .fontSize(16)
                  .fontColor($r('app.color.moon_text_hint'))
                  .margin({ top: 16 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }

            this.messageList()

            Column() {
              ChatTopBar({
                onMenuClick: () => {
                  this.toggleSidebar();
                },
                onModelClick: () => {
                  this.modelSheetVisible = true;
                },
                onNewChat: () => {
                  chatStore.createConversation();
                }
              })

              Blank()
                .layoutWeight(1)

              ChatInputBar({
                onSend: (content: string) => {
                  this.onSend(content);
                },
                onPlusClick: () => {
                  promptAction.showToast({ message: '附件功能开发中', duration: 1500 });
                },
                onNavigate: (route: string) => {
                  this.onNavigate(route);
                },
                disabled: chatStore.isAiResponding
              })
            }
            .width('100%')
            .height('100%')
            .hitTestBehavior(HitTestMode.Transparent)
          }
        }

        // 侧边栏打开时，透明覆盖层处理点击关闭
        // 避免在主内容区Stack上设置onClick导致TextArea无法获取焦点
        if (this.sideMenuOpen) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(Color.Transparent)
            .onClick(() => {
              this.closeSidebar();
            })
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.moon_bg_page'))
      .translate({ x: this.mainTranslate })
      .shadow({ radius: 20, color: '#30000000', offsetX: -4, offsetY: 0 })
      .clip(true)
      .borderRadius({ topLeft: 16, bottomLeft: 16 })
      // 右滑手势 — 打开/关闭侧边栏
      .gesture(
        PanGesture({ fingers: 1, distance: 10, direction: PanDirection.Horizontal })
          .onActionUpdate((event: GestureEvent) => {
            const dx: number = event.offsetX;
            const maxT: number = this.getMaxTranslate();
            if (this.sideMenuOpen) {
              // 打开状态下拖动：向左减小位移
              this.mainTranslate = Math.max(0, Math.min(maxT, maxT + dx));
            } else {
              // 关闭状态下拖动：向右增大位移
              this.mainTranslate = Math.max(0, Math.min(maxT, dx));
            }
          })
          .onActionEnd((event: GestureEvent) => {
            const dx: number = event.offsetX;
            if (this.sideMenuOpen) {
              // 打开状态：左滑超过阈值则关闭
              if (dx < -50) {
                this.closeSidebar();
              } else {
                this.openSidebar();
              }
            } else {
              // 关闭状态：右滑超过阈值则打开
              if (dx > 50) {
                this.openSidebar();
              } else {
                this.closeSidebar();
              }
            }
          })
      )

      // === 第三层：模型选择悬浮卡片（向下弹出，透明背景）===
      ModelDropdownCard({
        isVisible: this.modelSheetVisible,
        onClose: () => {
          this.modelSheetVisible = false;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.moon_bg_content'))
  }

  // 首页 — Logo + 问候语 + 功能标签 + 升本价值 + 政策 + 模拟输入框
  @Builder
  homePage() {
    Column() {
      // === 顶部栏：菜单按钮 ===
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.more'))
            .fontSize(20)
            .fontColor([$r('app.color.moon_text_primary')])
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#E8E8E8')
        .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
        .onClick(() => {
          this.toggleSidebar();
        })
      }
      .width('100%')
      .height(56 + this.safeAreaTop)
      .padding({ left: 16, right: 16, top: this.safeAreaTop })
      .alignItems(VerticalAlign.Center)

      // === 内容区（固定不滚动） ===
      Column() {
        Column() {
          // Logo — 应用图标
          Image($r('app.media.logo'))
            .width(64)
            .height(64)
            .borderRadius(32)
            .objectFit(ImageFit.Cover)
            .shadow({ radius: 12, color: '#20000000', offsetX: 0, offsetY: 4 })
            .scale({ x: this.logoScale, y: this.logoScale })
            .translate({ y: this.logoFloatY })
            .rotate({ angle: this.logoRotate })

          // 欢迎标题
          Text('你好，我是智慧职途')
            .fontSize(22)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.moon_text_primary'))
            .margin({ top: 14 })

          Text('你的专属升本规划师')
            .fontSize(14)
            .fontColor($r('app.color.brand_primary'))
            .margin({ top: 6 })

          Text('为你提供精准志愿填报 · 院校推荐 · 政策解读 · 备考计划')
            .fontSize(12)
            .fontColor($r('app.color.moon_text_secondary'))
            .margin({ top: 8, left: 24, right: 24 })
            .textAlign(TextAlign.Center)

          // === 功能特色标签 ===
          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Center }) {
            ForEach(FEATURE_TAGS, (tag: FeatureTag) => {
              Row({ space: 4 }) {
                SymbolGlyph(tag.icon)
                  .fontSize(13)
                  .fontColor([tag.color])
                Text(tag.label)
                  .fontSize(13)
                  .fontColor($r('app.color.moon_text_primary'))
              }
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderRadius(16)
              .backgroundColor('#FFFFFF')
              .shadow({ radius: 4, color: '#0D000000', offsetX: 0, offsetY: 1 })
              .margin({ left: 4, right: 4, top: 4, bottom: 4 })
              .onClick(() => {
                if (tag.route.length === 0) {
                  chatStore.createConversation();
                } else {
                  this.onNavigate(tag.route);
                }
              })
            }, (tag: FeatureTag) => tag.label)
          }
          .width('100%')
          .margin({ top: 16, left: 20, right: 20 })

          // === 升本价值 — 2列卡片网格 ===
          Column() {
            Text('升本价值')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.moon_text_primary'))
              .margin({ bottom: 10 })

            Flex({ wrap: FlexWrap.Wrap, direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
              ForEach(VALUE_CARDS, (card: ValueCard) => {
                Column({ space: 4 }) {
                  Text(card.value)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(card.color)
                  Text(card.title)
                    .fontSize(12)
                    .fontColor($r('app.color.moon_text_secondary'))
                  Text(card.desc)
                    .fontSize(11)
                    .fontColor($r('app.color.moon_text_hint'))
                    .maxLines(2)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .width('48%')
                .height(100)
                .padding(12)
                .alignItems(HorizontalAlign.Start)
                .borderRadius(14)
                .backgroundColor('#FFFFFF')
                .shadow({ radius: 6, color: '#0F000000', offsetX: 0, offsetY: 1 })
                .margin({ bottom: 8 })
              }, (card: ValueCard) => card.title)
            }
            .width('100%')

            // 数据可信度说明
            Text('* 以上数据基于往届学员大数据分析')
              .fontSize(11)
              .fontColor($r('app.color.moon_text_hint'))
              .margin({ top: 4 })
          }
          .width('100%')
          .margin({ top: 24, left: 20, right: 20 })

          // === 最新政策 ===
          if (this.policyList.length > 0) {
            Column() {
              Row() {
                Text('最新政策')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.moon_text_primary'))
                Blank()
                Text('查看全部')
                  .fontSize(13)
                  .fontColor($r('app.color.brand_primary'))
                  .onClick(() => {
                    this.onNavigate(RouteNames.POLICY_DETAIL);
                  })
              }
              .width('100%')
              .margin({ bottom: 10 })

              ForEach(this.policyList.slice(0, 3), (policy: PolicyInfo) => {
                Row() {
                  Column() {
                    Text(policy.title)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.moon_text_primary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(policy.summary)
                      .fontSize(12)
                      .fontColor($r('app.color.moon_text_secondary'))
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)

                  SymbolGlyph($r('sys.symbol.arrow_right'))
                    .fontSize(12)
                    .fontColor([$r('app.color.moon_text_hint')])
                }
                .width('100%')
                .padding(14)
                .borderRadius(14)
                .backgroundColor('#FFFFFF')
                .shadow({ radius: 6, color: '#0F000000', offsetX: 0, offsetY: 1 })
                .margin({ bottom: 8 })
                .onClick(() => {
                  this.pathStack.pushPath({ name: RouteNames.POLICY_DETAIL, param: policy.id });
                })
              }, (policy: PolicyInfo) => policy.id)
            }
            .width('100%')
            .margin({ top: 24, left: 20, right: 20 })
          }

          // 底部留白
          Blank().height(20)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // === 底部模拟输入框 ===
      Row() {
        Text('输入升本难题，我来解答...')
          .fontSize(15)
          .fontColor($r('app.color.moon_text_hint'))
          .layoutWeight(1)
        Column() {
          SymbolGlyph($r('sys.symbol.arrow_up'))
            .fontSize(16)
            .fontColor(['#FFFFFF'])
        }
        .width(30)
        .height(30)
        .borderRadius(15)
        .backgroundColor('#0066FF')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .backgroundEffect({
        radius: 30,
        saturation: 2.0,
        brightness: 1.05,
        color: '#30FFFFFF'
      })
      .borderRadius(24)
      .margin({ left: 16, right: 16, bottom: 8 })
      .shadow({ radius: 10, color: '#15000000', offsetX: 0, offsetY: 3 })
      .onClick(() => {
        chatStore.createConversation();
      })

      Text('内容由AI生成')
        .fontSize(11)
        .fontColor($r('app.color.moon_text_hint'))
        .margin({ bottom: 4 })
    }
    .width('100%')
    .height('100%')
  }

  // 消息列表
  @Builder
  messageList() {
    List({ scroller: this.scroller, space: 4 }) {
      ForEach(chatStore.currentConversation!.messages, (message: ChatMessage, index: number) => {
        ListItem() {
          Column() {
            // 思考过程（AI消息且有思考步骤时显示）
            if (message.role === MessageRole.AI && message.thinkingSteps.length > 0) {
              ThinkingProcess({ steps: message.thinkingSteps })
            }

            // 消息气泡
            ChatMessageBubble({
              message: message,
              isLastMessage: index === chatStore.currentConversation!.messages.length - 1
            })

            // 引用来源（AI消息且有引用时显示）
            if (message.role === MessageRole.AI && message.sources.length > 0) {
              SourceReference({ sources: message.sources })
            }

            // 追问建议（仅最后一条AI消息显示）
            if (message.role === MessageRole.AI && message.suggestions.length > 0 &&
              index === chatStore.currentConversation!.messages.length - 1 && !message.isStreaming) {
              SuggestionCards({
                suggestions: message.suggestions,
                onSuggestionClick: (suggestion: string) => {
                  this.onSuggestionClick(suggestion);
                }
              })
            }
          }
        }
      }, (message: ChatMessage) => message.id)
    }
    .width('100%')
    .height('100%')
    .padding({ top: 8, bottom: 88 })
    .scrollBar(BarState.Off)
    .cachedCount(5)
  }
}
