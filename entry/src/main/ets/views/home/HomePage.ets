import { AppColors, RouteNames, QuickEntryIcons } from '../../common/Constants';
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
  bgColor: string; // 图标圆形背景色
}

// 升本价值卡片数据
interface ValueCard {
  title: string;
  value: string;
  desc: string;
  color: string;
}

// 快捷入口组件（液态按压反馈 + 彩色图标背景）
@ComponentV2
struct QuickEntryItem {
  @Param label: string = '';
  @Param icon: Resource = $r('sys.symbol.plus');
  @Param route: string = '';
  @Param bgColor: string = '#F0F0F5';
  @Param onTap: (route: string) => void = () => {};
  @Local pressScale: number = 1.0;
  @Local pressOpacity: number = 1.0;

  build() {
    Column() {
      // 彩色圆形图标背景
      Column() {
        SymbolGlyph(this.icon)
          .fontSize(22)
          .fontColor([Color.White])
      }
      .width(44)
      .height(44)
      .borderRadius(22)
      .backgroundColor(this.bgColor)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Text(this.label)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ top: Spacing.SM })
        .maxLines(1)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ top: Spacing.MD, bottom: Spacing.MD })
    .scale({ x: this.pressScale, y: this.pressScale })
    .opacity(this.pressOpacity)
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.BUTTON_PRESS_DURATION,
          curve: AnimConfig.BUTTON_PRESS_CURVE,
        }, () => {
          this.pressScale = AnimConfig.BUTTON_PRESS_SCALE;
          this.pressOpacity = AnimConfig.BUTTON_PRESS_OPACITY;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.BUTTON_RELEASE_DURATION,
          curve: AnimConfig.BUTTON_RELEASE_CURVE,
        }, () => {
          this.pressScale = 1.0;
          this.pressOpacity = 1.0;
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

  private quickEntries: QuickEntry[] = [
    // 第一行：高频核心功能（学习 + 备考）
    { label: '学习规划', icon: QuickEntryIcons.PLANNING, route: RouteNames.STUDY_PLAN, bgColor: '#007AFF' },
    { label: '每日任务', icon: QuickEntryIcons.TASK, route: RouteNames.DAILY_TASK, bgColor: '#5856D6' },
    { label: '院校推荐', icon: QuickEntryIcons.RECOMMENDATION, route: RouteNames.COLLEGE_DETAIL, bgColor: '#FF9500' },
    { label: '志愿填报', icon: QuickEntryIcons.VOLUNTEER, route: RouteNames.VOLUNTEER_RESULT, bgColor: '#34C759' },
    // 第二行：辅助工具功能
    { label: '政策资讯', icon: QuickEntryIcons.POLICY, route: RouteNames.POLICY_DETAIL, bgColor: '#8E8E93' },
    { label: '资格检测', icon: QuickEntryIcons.QUALIFICATION, route: RouteNames.QUALIFICATION_CHECK, bgColor: '#30B0C7' },
    { label: '专业对照', icon: QuickEntryIcons.COMPARISON, route: RouteNames.COLLEGE_FILTER, bgColor: '#AF52DE' },
    { label: 'AI问答', icon: QuickEntryIcons.AI, route: '', bgColor: '#FF3B30' }
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
    this.loadPolicies();
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

  // 快捷入口网格
  @Builder
  quickEntryGrid() {
    Grid() {
      ForEach(this.quickEntries, (entry: QuickEntry) => {
        GridItem() {
          QuickEntryItem({
            label: entry.label,
            icon: entry.icon,
            route: entry.route,
            bgColor: entry.bgColor,
            onTap: (route: string) => {
              if (route !== '') {
                this.pathStack.pushPath({ name: route });
              }
            }
          })
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr')
    .rowsTemplate('1fr 1fr')
    .width('100%')
    .height(180)
    .rowsGap(4)
    .padding({ top: Spacing.SM, bottom: Spacing.SM })
    .borderRadius(Radius.CARD_LG)
    .backgroundColor(AppColors.CARD_COLOR)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
  }

  // 政策卡片已提取为 PolicyCardItem 组件（液态玻璃 + 按压反馈）

  // 升本价值轮播卡片
  @Builder
  valueSwiper() {
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

  build() {
    Scroll() {
      Column() {
        // 顶部标题区域 — Logo + 应用名称
        Column() {
          Row() {
            // Logo 图标
            Column() {
              Text('🎓')
                .fontSize(32)
            }
            .width(48)
            .height(48)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)

            // 标题文字
            Column({ space: 2 }) {
              Text('升本智图')
                .fontSize(28)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)

              Text('您的智能升本助手 · 精准规划每一步')
                .fontSize(13)
                .fontColor('#80FFFFFF')
            }
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
            .layoutWeight(1)
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding({ top: Spacing.XL, left: Spacing.LG, right: Spacing.LG, bottom: Spacing.MD })

        // 倒计时区域
        Column() {
          Row() {
            Text(`${this.daysRemaining}`)
              .fontSize(FontSize.DISPLAY)
              .fontWeight(FontWeight.Lighter)
              .fontColor(AppColors.PRIMARY_COLOR)
            Text('天')
              .fontSize(FontSize.TITLE)
              .fontColor(AppColors.TEXT_SECONDARY)
              .margin({ left: Spacing.XS, bottom: 4 })
              .alignSelf(ItemAlign.End)
          }
          .alignItems(VerticalAlign.Bottom)
          .margin({ top: Spacing.XS })

          Text('距离专升本考试 · ' + this.examDate)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_HINT)
        }
        .width('100%')
        .padding({ top: Spacing.XL, bottom: Spacing.LG, left: Spacing.LG, right: Spacing.LG })
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#14007AFF', 0.0], ['#00007AFF', 1.0]]
        })

        // 快捷入口
        Column() {
          this.quickEntryGrid()
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG })
        .margin({ top: Spacing.LG })

        // 升本价值轮播
        Column() {
          Text('升本价值')
            .fontSize(FontSize.TITLE)
            .fontWeight(FontWeightTokens.MEDIUM)
            .fontColor(AppColors.TEXT_PRIMARY)
            .margin({ bottom: Spacing.MD })
          this.valueSwiper()
        }
        .width('100%')
        .padding({ left: Spacing.LG, right: Spacing.LG })
        .margin({ top: Spacing.SECTION })

        // 最新政策列表
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
        .padding({ left: Spacing.LG, right: Spacing.LG })
        .margin({ top: Spacing.SECTION })

        // 底部留白
        Blank().height(Spacing.XXL)
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Off)
    .backgroundColor(AppColors.BACKGROUND_COLOR)
  }
}
