import { AppColors, RouteNames, QuickEntryIcons, PUBLIC_ROUTES } from '../../common/Constants';
import { appStore } from '../../stores/AppStore';
import { PolicyInfo } from '../../models/PolicyModel';
import { policyService } from '../../services/PolicyService';
import { FontSize, FontWeightTokens, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig } from '../../common/AnimationHelper';
import { getDaysCountdown } from '../../common/Utils';

// 快捷入口数据
interface QuickEntry {
  label: string;
  icon: Resource;
  route: string;
  color: string;
}

// 升本价值卡片数据
interface ValueCard {
  title: string;
  value: string;
  desc: string;
  color: string;
}

/**
 * 🌟 侧边快捷入口组件 - 小巧精致的液态玻璃卡片
 * - 固定在屏幕左侧
 * - 与边缘藕断丝连的液态玻璃效果
 * - 垂直排列的小卡片
 */
@ComponentV2
struct SideQuickEntry {
  @Param label: string = '';
  @Param icon: Resource = $r('sys.symbol.plus');
  @Param route: string = '';
  @Param color: string = AppColors.PRIMARY_COLOR;
  @Param onTap: (route: string) => void = () => {};
  @Local pressScale: number = 1.0;

  build() {
    Column() {
      // 图标
      SymbolGlyph(this.icon)
        .fontSize(20)
        .fontColor([this.color])

      // 文字
      Text(this.label)
        .fontSize(9)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: 4 })
        .maxLines(1)
    }
    .width('100%') // 宽度撑满父容器
    .height(56)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(4)
    // 🌊 液态玻璃卡片 — 透明 + 微弱模糊折射
    .backgroundEffect({
      radius: 3,
      saturation: 1.6,
      brightness: 1.05,
      color: '#0AFFFFFF'
    })
    .borderRadius(Radius.LG)
    .border({
      width: 0.5,
      color: '#40FFFFFF'
    })
    .scale({ x: this.pressScale, y: this.pressScale })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: 150,
          curve: Curve.EaseOut,
        }, () => {
          this.pressScale = 0.92;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: 200,
          curve: Curve.EaseOut,
        }, () => {
          this.pressScale = 1.0;
        });
      }
    })
    .onClick(() => {
      this.onTap(this.route);
    })
  }
}

// 政策卡片组件（液态玻璃材质 + 按压反馈）
@ComponentV2
struct PolicyCardItem {
  @Param policy: PolicyInfo = new PolicyInfo();
  @Param onTap: (id: string) => void = () => {};
  @Local pressScale: number = 1.0;
  @Local pressOpacity: number = 1.0;

  build() {
    Column({ space: Spacing.SM }) {
      Text(this.policy.title)
        .fontSize(FontSize.HEADLINE)
        .fontWeight(FontWeightTokens.MEDIUM)
        .fontColor(AppColors.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      Text(this.policy.publishDate)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_HINT)

      Text(this.policy.summary)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .padding(Spacing.LG)
    .backgroundColor(AppColors.GLASS_LIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .borderRadius(Radius.MD)
    .shadow(Shadows.GLASS)
    .scale({ x: this.pressScale, y: this.pressScale })
    .opacity(this.pressOpacity)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          this.pressScale = AnimConfig.PRESS_SCALE;
          this.pressOpacity = AnimConfig.PRESS_OPACITY;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          this.pressScale = 1.0;
          this.pressOpacity = 1.0;
        });
      }
    })
    .onClick(() => {
      this.onTap(this.policy.id);
    })
  }
}

@ComponentV2
export struct HomePage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local examDate: string = '2027-03-15';
  @Local policyList: PolicyInfo[] = [];
  @Local isLoading: boolean = true;
  @Local daysRemaining: number = 0;
  // 侧边栏展开/收起状态（由父组件传入）
  @Param sideBarExpanded: boolean = false;
  // 侧边栏关闭回调
  @Param onSideBarClose: () => void = () => {};
  // 安全区底部高度
  @Local safeAreaBottom: number = 0;

  // 🌟 所有快捷入口集中在左侧（8个功能）
  private quickEntries: QuickEntry[] = [
    { label: '学习规划', icon: QuickEntryIcons.PLANNING, route: RouteNames.STUDY_PLAN, color: '#007AFF' },
    { label: '每日任务', icon: QuickEntryIcons.TASK, route: RouteNames.DAILY_TASK, color: '#5856D6' },
    { label: '院校推荐', icon: QuickEntryIcons.RECOMMENDATION, route: RouteNames.COLLEGE_DETAIL, color: '#FF9500' },
    { label: '志愿填报', icon: QuickEntryIcons.VOLUNTEER, route: RouteNames.VOLUNTEER_RESULT, color: '#34C759' },
    { label: '政策资讯', icon: QuickEntryIcons.POLICY, route: RouteNames.POLICY_DETAIL, color: '#8E8E93' },
    { label: '资格检测', icon: QuickEntryIcons.QUALIFICATION, route: RouteNames.QUALIFICATION_CHECK, color: '#30B0C7' },
    { label: '专业对照', icon: QuickEntryIcons.COMPARISON, route: RouteNames.COLLEGE_FILTER, color: '#AF52DE' },
    { label: 'AI问答', icon: QuickEntryIcons.AI, route: '', color: '#FF3B30' }
  ];

  private valueCards: ValueCard[] = [
    {
      title: '薪资提升',
      value: '+40%',
      desc: '本科学历平均薪资较专科提升约40%，就业竞争力显著增强',
      color: AppColors.PRIMARY_COLOR
    },
    {
      title: '升学路径',
      value: '本科→研究生',
      desc: '升本后可继续深造考研，打通完整学历提升通道',
      color: AppColors.SUCCESS_COLOR
    },
    {
      title: '成功案例',
      value: '85%',
      desc: '往届升本学员中85%成功进入理想本科院校并顺利毕业',
      color: AppColors.WARNING_COLOR
    }
  ];

  aboutToAppear(): void {
    this.daysRemaining = getDaysCountdown(this.examDate);
    this.safeAreaBottom = AppStorage.get<number>('safeAreaBottom') ?? 0;
    this.loadPolicies();
  }

  /**
   * 收起侧边栏
   */
  private collapseSideBar(): void {
    if (this.sideBarExpanded) {
      this.onSideBarClose();
    }
  }

  private async loadPolicies(): Promise<void> {
    this.isLoading = true;
    try {
      this.policyList = await policyService.getPolicies('');
    } catch (_e) {
      this.policyList = [];
    }
    this.isLoading = false;
  }

  private getCategoryLabel(category: string): string {
    if (category === 'notice') {
      return '通知';
    } else if (category === 'policy') {
      return '政策';
    }
    return '大纲';
  }

  private getCategoryColor(category: string): string {
    if (category === 'notice') {
      return AppColors.PRIMARY_COLOR;
    } else if (category === 'policy') {
      return AppColors.SUCCESS_COLOR;
    }
    return AppColors.WARNING_COLOR;
  }

  /**
   * 🌟 左侧快捷入口栏 - 固定在左边，与边缘藕断丝连
   */
  @Builder
  leftSideBar() {
    Column() {
      ForEach(this.quickEntries, (entry: QuickEntry, index: number) => {
        SideQuickEntry({
          label: entry.label,
          icon: entry.icon,
          route: entry.route,
          color: entry.color,
          onTap: (route: string) => {
            if (route === '') {
              return;
            }
            if (!appStore.isLoggedIn && !PUBLIC_ROUTES.includes(route)) {
              this.pathStack.pushPath({ name: RouteNames.LOGIN });
              return;
            }
            this.pathStack.pushPath({ name: route });
          }
        })
        .margin({ top: index === 0 ? 0 : Spacing.SM })
      })
    }
    .width('100%') // 宽度撑满容器
    .padding({ top: 8, bottom: 8, left: 4, right: 4 })
    // 🌊 液态玻璃 — 透明 + 微弱模糊折射
    .backgroundEffect({
      radius: 4,
      saturation: 2.0,
      brightness: 1.1,
      color: '#08FFFFFF'
    })
    .borderRadius({ topRight: Radius.XL, bottomRight: Radius.XL })
    .border({
      width: 0.5,
      color: '#4DFFFFFF'
    })
    .shadow({
      radius: 12,
      color: 'rgba(0, 0, 0, 0.06)',
      offsetX: 2,
      offsetY: 0
    })
  }

  /**
   * 🌟 中间主内容区域
   */
  @Builder
  mainContent() {
    Scroll() {
      Column() {
        // 🌟 紧凑的标题 + 倒计时
        Column() {
          Row() {
            // Logo + 标题
            Row() {
              Text('🎓')
                .fontSize(24)

              Column({ space: 2 }) {
                Text('鸿蒙AI指导者')
                  .fontSize(20)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(AppColors.TEXT_PRIMARY)

                Text('智能升本助手')
                  .fontSize(11)
                  .fontColor(AppColors.TEXT_SECONDARY)
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 8 })
            }
            .layoutWeight(1)

            // 倒计时
            Column() {
              Text(`${this.daysRemaining}`)
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(AppColors.PRIMARY_COLOR)

              Text('天')
                .fontSize(12)
                .fontColor(AppColors.TEXT_SECONDARY)
            }
            .alignItems(HorizontalAlign.End)
          }
          .width('100%')
          .padding({ left: 44, right: Spacing.LG })
        }
        .width('100%')
        .margin({ bottom: Spacing.LG })

        // 🌟 升本价值轮播
        Column() {
          Text('升本价值')
            .fontSize(FontSize.TITLE)
            .fontWeight(FontWeightTokens.MEDIUM)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ bottom: Spacing.MD })

          Swiper() {
            ForEach(this.valueCards, (card: ValueCard) => {
              Column({ space: Spacing.SM }) {
                Text(card.title)
                  .fontSize(FontSize.CAPTION)
                  .fontColor(AppColors.TEXT_SECONDARY)
                Text(card.value)
                  .fontSize(28)
                  .fontWeight(FontWeightTokens.BOLD)
                  .fontColor(card.color)
                Text(card.desc)
                  .fontSize(FontSize.BODY)
                  .fontColor(AppColors.TEXT_SECONDARY)
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              .width('100%')
              .height(140)
              .padding(Spacing.XL)
              .alignItems(HorizontalAlign.Start)
              .borderRadius(Radius.LG)
              .backgroundColor(AppColors.GLASS_LIGHT)
              .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
              .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
              .shadow(Shadows.GLASS)
            })
          }
          .width('100%')
          .height(140)
          .indicator(Indicator.dot()
            .color('#D0D0D0')
            .selectedColor(AppColors.PRIMARY_COLOR))
          .loop(true)
          .autoPlay(false)
        }
        .width('100%')
        .margin({ bottom: Spacing.SECTION })

        // 🌟 最新政策列表
        Column() {
          Row() {
            Text('最新政策')
              .fontSize(FontSize.TITLE)
              .fontWeight(FontWeightTokens.MEDIUM)
              .fontColor(AppColors.TEXT_PRIMARY)
            Blank()
            Text('查看全部')
              .fontSize(FontSize.BODY)
              .fontColor(AppColors.PRIMARY_COLOR)
              .onClick(() => {
                // 预留：跳转政策列表页
              })
          }
          .width('100%')
          .margin({ bottom: Spacing.MD })

          ForEach(this.policyList, (policy: PolicyInfo) => {
            Column() {
              PolicyCardItem({
                policy: policy,
                onTap: (id: string) => {
                  this.pathStack.pushPath({ name: RouteNames.POLICY_DETAIL, param: id });
                }
              })
            }
            .margin({ top: Spacing.MD })
          }, (policy: PolicyInfo) => policy.id)
        }
        .width('100%')

        // 底部留白（为悬浮Tab栏留空间）
        Blank().height(80)
      }
      .width('100%')
      .padding({ top: 8, left: Spacing.LG, right: Spacing.LG, bottom: Spacing.LG })
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      // 🌟 底层：背景
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(AppColors.BACKGROUND_COLOR)

      // 🌟 中间层：主内容
      Column() {
        this.mainContent()
      }
      .width('100%')
      .height('100%')

      // 🌟 蒙层：展开时覆盖全屏，点击收起侧边栏
      if (this.sideBarExpanded) {
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000000')
          .onClick(() => {
            this.collapseSideBar();
          })
      }

      // 🌟 侧边栏（垂直居中，可收起/展开）
      Column() {
        this.leftSideBar()
      }
      .width(60)
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Center)
      .translate({ x: this.sideBarExpanded ? 0 : -70 })
      .opacity(this.sideBarExpanded ? 1 : 0)
    }
    .width('100%')
    .height('100%')
  }
}
