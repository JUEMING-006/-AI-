// AI 对话主页 — 叠层侧边栏 + 右滑手势 + 对话列表
// 首页叠在侧边栏上，右滑打开暴露侧边栏，点击首页弹回
import { promptAction, display } from '@kit.ArkUI';
import { AppColors, RouteNames } from '../../common/Constants';
import { LiquidGlass } from '../../common/DesignTokens';
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
  { title: '就业选择', value: '+60%', desc: '本科可投递岗位数量较专科增加约60%', color: AppColors.PRIMARY_COLOR },
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
  { icon: $r('sys.symbol.building'), label: '院校推荐', color: '#FF9500', route: RouteNames.COLLEGE_LIST },
  { icon: $r('sys.symbol.bookmark'), label: '志愿填报', color: '#34C759', route: RouteNames.VOLUNTEER_MAIN },
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
  @Local showPolicyBubble: boolean = true;
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
      this.logoScale = 1.0 + 0.08 * Math.sin(t * 2);
      this.logoFloatY = -6 * Math.sin(t * 1.5);
      this.logoRotate = 8 * Math.sin(t * 1.2);
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
                  .onClick(() => {
                    this.modelSheetVisible = true;
                  })

                Text('开始你的第一次对话')
                  .fontSize(16)
                  .fontColor($r('app.color.moon_text_hint'))
                  .margin({ top: 16 })

                Text('点击Logo切换模式')
                  .fontSize(12)
                  .fontColor($r('app.color.brand_primary'))
                  .margin({ top: 6 })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
            }

            // 仅有消息时才渲染列表，避免空List拦截Logo点击
            if (chatStore.currentConversation!.messages.length > 0) {
              this.messageList()
            }

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
        },
        onNavigate: (route: string) => {
          this.onNavigate(route);
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
      // === 顶部栏：菜单按钮 + 信箱通知 ===
      Row() {
        // 左侧：菜单按钮
        Button() {
          SymbolGlyph($r('sys.symbol.more'))
            .fontSize(20)
            .fontColor([$r('app.color.moon_text_primary')])
        }
        .type(ButtonType.Circle)
        .width(40)
        .height(40)
        .borderRadius(20)
        .backgroundColor($r('app.color.moon_icon_bg'))
        .backgroundBlurStyle(LiquidGlass.BUTTON_BLUR)
        .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
        .shadow(LiquidGlass.SHADOW_CONTAINER)
        .onClick(() => {
          this.toggleSidebar();
        })

        // 中间：新政策气泡提示（无政策时 Blank 占位）
        if (this.showPolicyBubble && this.policyList.length > 0) {
          Row() {
            Text('新政策')
              .fontSize(10)
              .fontColor('#FFFFFF')
              .backgroundColor('#FF3B30')
              .borderRadius(4)
              .padding({ left: 4, right: 4, top: 1, bottom: 1 })

            Text(this.policyList[0].title)
              .fontSize(13)
              .fontColor($r('app.color.moon_text_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
              .margin({ left: 8 })

            SymbolGlyph($r('sys.symbol.arrow_right'))
              .fontSize(12)
              .fontColor([$r('app.color.moon_text_hint')])
          }
          .layoutWeight(1)
          .height(36)
          .margin({ left: 8, right: 8 })
          .padding({ left: 12, right: 12 })
          .borderRadius(18)
          .backgroundColor($r('app.color.moon_value_card_bg'))
          .border({ width: LiquidGlass.BORDER_WIDTH, color: '#FF3B30' })
          .shadow(LiquidGlass.SHADOW_CONTAINER)
          .onClick(() => {
            if (this.policyList.length > 0) {
              this.pathStack.pushPath({ name: RouteNames.POLICY_DETAIL, param: this.policyList[0].id });
            }
          })
        } else {
          Blank()
        }

        // 右侧：信箱按钮（带红点提示）
        Stack({ alignContent: Alignment.TopEnd }) {
          Button() {
            SymbolGlyph($r('sys.symbol.speaker_wave_2'))
              .fontSize(20)
              .fontColor([$r('app.color.moon_text_primary')])
          }
          .type(ButtonType.Circle)
          .width(40)
          .height(40)
          .borderRadius(20)
          .backgroundColor($r('app.color.moon_icon_bg'))
          .backgroundBlurStyle(LiquidGlass.BUTTON_BLUR)
          .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
          .shadow(LiquidGlass.SHADOW_CONTAINER)
          .onClick(() => {
            this.onNavigate(RouteNames.POLICY_DETAIL);
          })

          // 红点提示
          if (this.policyList.length > 0) {
            Column()
              .width(8)
              .height(8)
              .borderRadius(4)
              .backgroundColor('#FF3B30')
              .margin({ top: 8, right: 8 })
          }
        }
        .width(40)
        .height(40)
      }
      .width('100%')
      .height(48 + this.safeAreaTop)
      .padding({ left: 16, right: 16, top: this.safeAreaTop })
      .alignItems(VerticalAlign.Center)

      // === 内容区（固定布局） ===
      Column() {
          // === 精简头部 — Logo + 欢迎语水平排列 ===
          Row({ space: 12 }) {
            Image($r('app.media.logo'))
              .width(44)
              .height(44)
              .borderRadius(22)
              .objectFit(ImageFit.Cover)
              .shadow({ radius: 8, color: '#20000000', offsetX: 0, offsetY: 2 })
              .scale({ x: this.logoScale, y: this.logoScale })
              .translate({ y: this.logoFloatY })

            Column() {
              Text('你好，我是智慧职途')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.moon_text_primary'))
              Text('你的专属升本规划师')
                .fontSize(12)
                .fontColor($r('app.color.brand_primary'))
                .margin({ top: 2 })
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }
          .width('100%')
          .padding({ left: 20, right: 20, top: 8, bottom: 16 })

          // === Bento 大卡片：开始对话（蓝色渐变背景） ===
          Row() {
            Column() {
              SymbolGlyph($r('sys.symbol.star'))
                .fontSize(28)
                .fontColor(['#FFFFFF'])
              Text('开始对话')
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .margin({ top: 8 })
              Text('输入你的升本难题，AI为你解答')
                .fontSize(12)
                .fontColor('#B0FFFFFF')
                .margin({ top: 4 })
            }
            .width('100%')
            .padding(20)
            .alignItems(HorizontalAlign.Start)
            .borderRadius(20)
            .linearGradient({
              angle: 135,
              colors: [['#0066FF', 0.0], ['#003D99', 1.0]]
            })
            .shadow({ radius: 16, color: '#300066FF', offsetY: 6 })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 10 })
          .onClick(() => {
            chatStore.createConversation();
          })

          // === Bento 三列：核心数据 + 院校 + 志愿 ===
          Row() {
            Column() {
              Text('+40%')
                .fontSize(22)
                .fontWeight(FontWeight.Bold)
                .fontColor('#0066FF')
              Text('薪资提升')
                .fontSize(11)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 2 })
            }
            .layoutWeight(1)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('app.color.moon_value_card_bg'))
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ right: 5 })

            Column() {
              SymbolGlyph($r('sys.symbol.building'))
                .fontSize(24)
                .fontColor(['#FF9500'])
              Text('院校库')
                .fontSize(11)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('app.color.moon_value_card_bg'))
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ left: 5, right: 5 })
            .onClick(() => {
              this.onNavigate(RouteNames.COLLEGE_LIST);
            })

            Column() {
              SymbolGlyph($r('sys.symbol.bookmark'))
                .fontSize(24)
                .fontColor(['#34C759'])
              Text('志愿填报')
                .fontSize(11)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('app.color.moon_value_card_bg'))
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ left: 5 })
            .onClick(() => {
              this.onNavigate(RouteNames.VOLUNTEER_MAIN);
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 10 })

          // === Bento 两列：政策资讯 + 学习计划 ===
          Row() {
            Column() {
              Row() {
                SymbolGlyph($r('sys.symbol.doc'))
                  .fontSize(20)
                  .fontColor(['#AF52DE'])
                Text('政策资讯')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.moon_text_primary'))
                  .margin({ left: 6 })
              }
              Text(this.policyList.length > 0 ? `${this.policyList.length}条最新政策` : '暂无政策')
                .fontSize(12)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .height(80)
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('app.color.moon_value_card_bg'))
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ right: 5 })
            .onClick(() => {
              this.onNavigate(RouteNames.POLICY_DETAIL);
            })

            Column() {
              Row() {
                SymbolGlyph($r('sys.symbol.calendar'))
                  .fontSize(20)
                  .fontColor(['#FF6B35'])
                Text('学习计划')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.moon_text_primary'))
                  .margin({ left: 6 })
              }
              Text('个性化备考方案')
                .fontSize(12)
                .fontColor($r('app.color.moon_text_secondary'))
                .margin({ top: 6 })
            }
            .layoutWeight(1)
            .height(80)
            .padding(12)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .borderRadius(16)
            .backgroundColor($r('app.color.moon_value_card_bg'))
            .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
            .shadow(LiquidGlass.SHADOW_CONTAINER)
            .margin({ left: 5 })
            .onClick(() => {
              this.onNavigate(RouteNames.STUDY_PLAN);
            })
          }
          .width('100%')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 10 })

          // 间距
          Blank().height(16)

          // === 最新政策 — 横向滑动卡片 ===
          if (this.policyList.length > 0) {
            Column() {
              Row() {
                Text('最新政策')
                  .fontSize(16)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.moon_text_primary'))
                Blank()
                Text('查看全部 >')
                  .fontSize(13)
                  .fontColor($r('app.color.brand_primary'))
                  .onClick(() => {
                    this.onNavigate(RouteNames.POLICY_DETAIL);
                  })
              }
              .width('100%')
              .margin({ bottom: 10, left: 28, right: 28 })

              Scroll() {
                Row({ space: 10 }) {
                  ForEach(this.policyList.slice(0, 5), (policy: PolicyInfo) => {
                    Column() {
                      Text(policy.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('app.color.moon_text_primary'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                      Text(policy.summary)
                        .fontSize(12)
                        .fontColor($r('app.color.moon_text_secondary'))
                        .maxLines(2)
                        .textOverflow({ overflow: TextOverflow.Ellipsis })
                        .margin({ top: 6 })
                      Text(policy.publishDate)
                        .fontSize(11)
                        .fontColor($r('app.color.moon_text_hint'))
                        .margin({ top: 8 })
                    }
                    .width(180)
                    .padding(14)
                    .alignItems(HorizontalAlign.Start)
                    .borderRadius(16)
                    .backgroundColor($r('app.color.moon_value_card_bg'))
                    .border({ width: LiquidGlass.BORDER_WIDTH, color: $r('app.color.moon_card_border') })
                    .shadow(LiquidGlass.SHADOW_CONTAINER)
                    .onClick(() => {
                      this.pathStack.pushPath({ name: RouteNames.POLICY_DETAIL, param: policy.id });
                    })
                  }, (policy: PolicyInfo) => policy.id)
                }
                .padding({ left: 28, right: 28 })
              }
              .scrollable(ScrollDirection.Horizontal)
              .scrollBar(BarState.Off)
              .edgeEffect(EdgeEffect.Spring)
            }
            .width('100%')
            .margin({ top: 16 })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
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
