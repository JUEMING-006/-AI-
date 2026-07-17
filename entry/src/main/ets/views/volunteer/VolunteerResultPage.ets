import { AppColors, ButtonStyles, RouteNames, CollegeNavParam } from '../../common/Constants';
import { FontSize, Spacing, Radius, Shadows, GlassEffect } from '../../common/DesignTokens';
import { AnimConfig, getStaggerDelay } from '../../common/AnimationHelper';
import { RecommendCollege, VolunteerPlan } from '../../models/VolunteerModel';
import { volunteerService } from '../../services/VolunteerService';
import { LoadingView } from '../../components/LoadingView';
import { CommonCard } from '../../components/CommonCard';
import { NavHeader } from '../../components/NavHeader';

// 三梯度颜色常量
const RUSH_COLOR: string = '#FF6B6B';
const STABLE_COLOR: string = '#10B981';
const SAFE_COLOR: string = '#5B7FFF';

// 推荐院校卡片组件
@ComponentV2
struct RecommendCardItem {
  @Param college: RecommendCollege = new RecommendCollege();
  @Param tierColor: string = '#FF6B6B';
  @Param visible: boolean = false;
  @Param isExpanded: boolean = false;
  @Param onToggle: (college: RecommendCollege) => void = () => {};
  @Param onCardClick: (college: RecommendCollege) => void = () => {};
  @Param onExpandToggle: (id: string) => void = () => {};
  @Local pressScale: number = 1.0;
  @Local pressOpacity: number = 1.0;

  build() {
    if (this.visible) {
      Column() {
        Row() {
          // 左侧信息
          Column() {
            Text(this.college.name)
              .fontSize(FontSize.BODY)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppColors.TEXT_PRIMARY)

            Row() {
              Text(this.college.type)
                .fontSize(FontSize.CAPTION)
                .fontColor(Color.White)
                .backgroundColor(this.college.type === '公办' ? '#007AFF' : '#FF9500')
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })

              Text(this.college.tier)
                .fontSize(FontSize.CAPTION)
                .fontColor(Color.White)
                .backgroundColor(this.tierColor)
                .borderRadius(4)
                .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                .margin({ left: Spacing.XS })
            }
            .margin({ top: Spacing.XS })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          // 右侧概率
          Column() {
            Stack() {
              Progress({ value: this.college.probability, total: 100, type: ProgressType.Ring })
                .width(50)
                .height(50)
                .color(this.tierColor)
                .backgroundColor('#F5F5F7')
                .style({ strokeWidth: 5 })
              Text(`${this.college.probability}%`)
                .fontSize(FontSize.CAPTION)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.tierColor)
            }

            Text(`去年${this.college.lastYearMinScore}分`)
              .fontSize(FontSize.CAPTION)
              .fontColor(AppColors.TEXT_HINT)
              .margin({ top: Spacing.XS })
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .onClick(() => {
          this.onCardClick(this.college);
        })

        // 展开区域
        if (this.isExpanded) {
          Row({ space: Spacing.MD }) {
            Column() {
              Text('专业')
                .fontSize(10)
                .fontColor(AppColors.TEXT_HINT)
              Text(this.college.major)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_PRIMARY)
                .margin({ top: Spacing.XS })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('学费/年')
                .fontSize(10)
                .fontColor(AppColors.TEXT_HINT)
              Text(`${this.college.tuition}`)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_PRIMARY)
                .margin({ top: Spacing.XS })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)

            Column() {
              Text('城市')
                .fontSize(10)
                .fontColor(AppColors.TEXT_HINT)
              Text(this.college.city)
                .fontSize(FontSize.CAPTION)
                .fontColor(AppColors.TEXT_PRIMARY)
                .margin({ top: Spacing.XS })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding({ top: Spacing.SM, bottom: Spacing.SM })
          .border({ width: 0.5, color: AppColors.DIVIDER_COLOR })
          .margin({ top: Spacing.XS })
          .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 10 })))
        }

        // 底部操作栏
        Row() {
          Text(`招生${this.college.enrollCount}人`)
            .fontSize(FontSize.CAPTION)
            .fontColor(AppColors.TEXT_SECONDARY)

          Blank()

          // 展开按钮
          if (this.isExpanded) {
            Text('▲')
              .fontSize(14)
              .fontColor(AppColors.TEXT_HINT)
              .margin({ right: Spacing.MD })
              .onClick(() => {
                this.onExpandToggle(this.college.id);
              })
          } else {
            Text('▼')
              .fontSize(14)
              .fontColor(AppColors.TEXT_HINT)
              .margin({ right: Spacing.MD })
              .onClick(() => {
                this.onExpandToggle(this.college.id);
              })
          }

          Button(this.college.isSelected ? '已添加' : '加入志愿表')
            .height(32)
            .fontSize(FontSize.CAPTION)
            .fontColor(this.college.isSelected ? AppColors.TEXT_HINT : Color.White)
            .backgroundColor(this.college.isSelected ? AppColors.DIVIDER_COLOR : AppColors.PRIMARY_COLOR)
            .borderRadius(Radius.BUTTON)
            .onClick(() => {
              this.onToggle(this.college);
            })
        }
        .width('100%')
        .margin({ top: Spacing.SM })
      }
      .width('100%')
      .padding(Spacing.MD)
      .backgroundColor(AppColors.CARD_COLOR)
      .borderRadius(Radius.MD)
      .shadow(Shadows.CARD)
      .border({
        width: this.college.isSelected ? 2 : 1,
        color: this.college.isSelected ? this.tierColor : AppColors.DIVIDER_COLOR
      })
      .scale({ x: this.pressScale, y: this.pressScale })
      .opacity(this.pressOpacity)
      .transition(TransitionEffect.OPACITY.combine(TransitionEffect.translate({ y: 15 })))
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
    }
  }
}

@ComponentV2
export struct VolunteerResultPage {
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local plan: VolunteerPlan = new VolunteerPlan();
  @Local isLoading: boolean = true;
  @Local cardVisible: boolean[] = [];
  @Local rushList: RecommendCollege[] = [];
  @Local stableList: RecommendCollege[] = [];
  @Local safeList: RecommendCollege[] = [];
  // 新增状态
  @Local mode: number = 0; // 0: 院校优先, 1: 专业优先
  @Local selectedCount: number = 0;
  @Local collegeTypeFilter: string = '全部';
  @Local tuitionFilter: string = '不限';
  @Local expandedId: string = '';

  aboutToAppear(): void {
    this.loadResult();
  }

  private loadResult(): void {
    if (volunteerService.hasScore && volunteerService.currentPlan.recommendations.length > 0) {
      this.plan = volunteerService.currentPlan;
    } else {
      // 硬编码 Mock 数据
      this.plan = this.getMockPlan();
    }
    this.isLoading = false;
    // 分组
    const rush: RecommendCollege[] = [];
    const stable: RecommendCollege[] = [];
    const safe: RecommendCollege[] = [];
    for (const c of this.plan.recommendations) {
      if (c.tier === '冲刺') {
        rush.push(c);
      } else if (c.tier === '稳妥') {
        stable.push(c);
      } else {
        safe.push(c);
      }
    }
    this.rushList = rush;
    this.stableList = stable;
    this.safeList = safe;
    // Stagger 入场动画
    this.cardVisible = this.plan.recommendations.map((): boolean => false);
    this.plan.recommendations.forEach((_: RecommendCollege, index: number) => {
      setTimeout(() => {
        const updated: boolean[] = [...this.cardVisible];
        updated[index] = true;
        this.cardVisible = updated;
      }, getStaggerDelay(index));
    });
  }

  private getMockPlan(): VolunteerPlan {
    const plan = new VolunteerPlan();
    const makeCollege = (
      id: string, name: string, type: string, tier: string,
      prob: number, score: number, enroll: number,
      tuition: number, major: string, city: string
    ): RecommendCollege => {
      const c = new RecommendCollege();
      c.id = id;
      c.name = name;
      c.type = type;
      c.tier = tier;
      c.probability = prob;
      c.lastYearMinScore = score;
      c.enrollCount = enroll;
      c.isSelected = false;
      c.tuition = tuition;
      c.major = major;
      c.city = city;
      return c;
    };
    plan.recommendations = [
      makeCollege('1', '深圳技术大学', '公办', '冲刺', 65, 320, 120, 5500, '计算机科学与技术', '深圳'),
      makeCollege('2', '广州理工学院', '民办', '冲刺', 55, 310, 80, 18000, '软件工程', '广州'),
      makeCollege('3', '东莞理工学院', '公办', '稳妥', 80, 298, 100, 5500, '计算机科学与技术', '东莞'),
      makeCollege('4', '佛山科学技术学院', '公办', '稳妥', 85, 290, 90, 5500, '数据科学', '佛山'),
      makeCollege('5', '广东石油化工学院', '公办', '保底', 95, 280, 70, 5500, '软件工程', '茂名'),
      makeCollege('6', '珠海科技学院', '民办', '保底', 90, 275, 60, 16000, '网络工程', '珠海')
    ];
    plan.rushCount = 2;
    plan.stableCount = 2;
    plan.safeCount = 2;
    return plan;
  }

  // 筛选逻辑
  private getFilteredList(list: RecommendCollege[]): RecommendCollege[] {
    let result = list;
    if (this.collegeTypeFilter !== '全部') {
      result = result.filter((c: RecommendCollege) => c.type === this.collegeTypeFilter);
    }
    if (this.tuitionFilter !== '不限') {
      result = result.filter((c: RecommendCollege) => {
        if (this.tuitionFilter === '<1万') return c.tuition < 10000;
        if (this.tuitionFilter === '1-2万') return c.tuition >= 10000 && c.tuition <= 20000;
        return c.tuition > 20000;
      });
    }
    return result;
  }

  private toggleExpand(id: string): void {
    this.expandedId = this.expandedId === id ? '' : id;
  }

  private navigateToCollege(college: RecommendCollege): void {
    const param: CollegeNavParam = { collegeName: college.name };
    this.pathStack.pushPath({ name: RouteNames.COLLEGE_VOLUNTEER, param: param });
  }

  private getTierColor(tier: string): string {
    if (tier === '冲刺') return RUSH_COLOR;
    if (tier === '稳妥') return STABLE_COLOR;
    return SAFE_COLOR;
  }

  private isCardVisible(globalIndex: number): boolean {
    return this.cardVisible.length > globalIndex && this.cardVisible[globalIndex];
  }

  private toggleSelection(college: RecommendCollege): void {
    college.isSelected = !college.isSelected;
    this.selectedCount = this.plan.recommendations.filter((c: RecommendCollege) => c.isSelected).length;
  }

  build() {
    NavDestination() {
      Column() {
        NavHeader({ title: '智能选志愿' })

        if (this.isLoading) {
          LoadingView({ message: '加载志愿推荐结果...' })
        } else if (this.plan.recommendations.length === 0) {
          this.emptyState()
        } else {
          // ========== 模式切换 Tab ==========
          this.modeTabs()

          // ========== 筛选栏 ==========
          this.filterBar()

          // ========== 统计栏 ==========
          this.statBar()

          // ========== 列表区 ==========
          Scroll() {
            Column() {
              // 冲刺组
              if (this.getFilteredList(this.rushList).length > 0) {
                this.tierHeader('冲刺', this.getFilteredList(this.rushList).length, RUSH_COLOR)
                ForEach(this.getFilteredList(this.rushList), (college: RecommendCollege, idx: number) => {
                  RecommendCardItem({
                    college: college,
                    tierColor: RUSH_COLOR,
                    visible: this.isCardVisible(idx),
                    isExpanded: this.expandedId === college.id,
                    onToggle: (c: RecommendCollege) => {
                      this.toggleSelection(c);
                    },
                    onCardClick: (c: RecommendCollege) => {
                      this.navigateToCollege(c);
                    },
                    onExpandToggle: (id: string) => {
                      this.toggleExpand(id);
                    }
                  })
                }, (c: RecommendCollege, idx: number) => `rush_${idx}_${c.id}`)
              }

              // 稳妥组
              if (this.getFilteredList(this.stableList).length > 0) {
                this.tierHeader('稳妥', this.getFilteredList(this.stableList).length, STABLE_COLOR)
                ForEach(this.getFilteredList(this.stableList), (college: RecommendCollege, idx: number) => {
                  RecommendCardItem({
                    college: college,
                    tierColor: STABLE_COLOR,
                    visible: this.isCardVisible(this.rushList.length + idx),
                    isExpanded: this.expandedId === college.id,
                    onToggle: (c: RecommendCollege) => {
                      this.toggleSelection(c);
                    },
                    onCardClick: (c: RecommendCollege) => {
                      this.navigateToCollege(c);
                    },
                    onExpandToggle: (id: string) => {
                      this.toggleExpand(id);
                    }
                  })
                }, (c: RecommendCollege, idx: number) => `stable_${idx}_${c.id}`)
              }

              // 保底组
              if (this.getFilteredList(this.safeList).length > 0) {
                this.tierHeader('保底', this.getFilteredList(this.safeList).length, SAFE_COLOR)
                ForEach(this.getFilteredList(this.safeList), (college: RecommendCollege, idx: number) => {
                  RecommendCardItem({
                    college: college,
                    tierColor: SAFE_COLOR,
                    visible: this.isCardVisible(this.rushList.length + this.stableList.length + idx),
                    isExpanded: this.expandedId === college.id,
                    onToggle: (c: RecommendCollege) => {
                      this.toggleSelection(c);
                    },
                    onCardClick: (c: RecommendCollege) => {
                      this.navigateToCollege(c);
                    },
                    onExpandToggle: (id: string) => {
                      this.toggleExpand(id);
                    }
                  })
                }, (c: RecommendCollege, idx: number) => `safe_${idx}_${c.id}`)
              }
            }
            .width('100%')
            .padding({ left: Spacing.LG, right: Spacing.LG, bottom: 100 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)

          // ========== 底部悬浮操作栏 ==========
          this.bottomActionBar()
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .backgroundColor(AppColors.BACKGROUND_COLOR)
  }

  @Builder
  emptyState() {
    Column() {
      Text('暂无推荐结果')
        .fontSize(FontSize.SUBTITLE)
        .fontColor(AppColors.TEXT_HINT)
      Text('请先录入成绩进行志愿匹配')
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ top: Spacing.SM })
      Button('返回录入')
        .width(120)
        .height(40)
        .fontSize(FontSize.BODY)
        .backgroundColor(AppColors.PRIMARY_COLOR)
        .margin({ top: Spacing.XL })
        .onClick(() => {
          this.pathStack.pop();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  modeTabs() {
    Row() {
      this.modeTab('院校优先', 0)
      this.modeTab('专业优先', 1)
    }
    .width('100%')
    .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })
    .backgroundColor(AppColors.CARD_COLOR)
  }

  @Builder
  modeTab(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(FontSize.BODY)
        .fontWeight(this.mode === index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.mode === index ? AppColors.PRIMARY_COLOR : AppColors.TEXT_SECONDARY)

      if (this.mode === index) {
        Column()
          .width(20)
          .height(3)
          .backgroundColor(AppColors.PRIMARY_COLOR)
          .borderRadius(1.5)
          .margin({ top: Spacing.XS })
      }
    }
    .layoutWeight(1)
    .padding({ top: Spacing.SM, bottom: Spacing.SM })
    .onClick(() => {
      this.mode = index;
    })
  }

  @Builder
  filterBar() {
    Scroll() {
      Row({ space: Spacing.SM }) {
        this.filterChip('全部', this.collegeTypeFilter === '全部', () => { this.collegeTypeFilter = '全部'; })
        this.filterChip('公办', this.collegeTypeFilter === '公办', () => { this.collegeTypeFilter = '公办'; })
        this.filterChip('民办', this.collegeTypeFilter === '民办', () => { this.collegeTypeFilter = '民办'; })
        this.filterChip('学费<1万', this.tuitionFilter === '<1万', () => { this.tuitionFilter = '<1万'; })
        this.filterChip('学费1-2万', this.tuitionFilter === '1-2万', () => { this.tuitionFilter = '1-2万'; })
        this.filterChip('学费>2万', this.tuitionFilter === '>2万', () => { this.tuitionFilter = '>2万'; })
      }
      .padding({ left: Spacing.LG, right: Spacing.LG })
    }
    .width('100%')
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .padding({ top: Spacing.SM, bottom: Spacing.SM })
  }

  @Builder
  filterChip(label: string, isActive: boolean, onTap: () => void) {
    Text(label)
      .fontSize(FontSize.CAPTION)
      .fontColor(isActive ? Color.White : AppColors.TEXT_SECONDARY)
      .backgroundColor(isActive ? AppColors.PRIMARY_COLOR : AppColors.BACKGROUND_COLOR)
      .borderRadius(16)
      .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      .border({ width: 1, color: isActive ? AppColors.PRIMARY_COLOR : AppColors.DIVIDER_COLOR })
      .onClick(onTap)
  }

  @Builder
  statBar() {
    Row() {
      Row() {
        Column()
          .width(4)
          .height(16)
          .backgroundColor(RUSH_COLOR)
          .borderRadius(2)
        Text(` 冲刺 ${this.plan.rushCount}所`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
      }

      Text('|')
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.DIVIDER_COLOR)
        .margin({ left: Spacing.SM, right: Spacing.SM })

      Row() {
        Column()
          .width(4)
          .height(16)
          .backgroundColor(STABLE_COLOR)
          .borderRadius(2)
        Text(` 稳妥 ${this.plan.stableCount}所`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
      }

      Text('|')
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.DIVIDER_COLOR)
        .margin({ left: Spacing.SM, right: Spacing.SM })

      Row() {
        Column()
          .width(4)
          .height(16)
          .backgroundColor(SAFE_COLOR)
          .borderRadius(2)
        Text(` 保底 ${this.plan.safeCount}所`)
          .fontSize(FontSize.CAPTION)
          .fontColor(AppColors.TEXT_SECONDARY)
      }
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding(Spacing.SM)
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.SM)
    .margin({ left: Spacing.LG, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })
  }

  @Builder
  tierHeader(label: string, count: number, color: string) {
    Row() {
      Column()
        .width(3)
        .height(22)
        .borderRadius(1.5)
        .backgroundColor(color)

      Text(`${label}院校`)
        .fontSize(FontSize.HEADLINE)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppColors.TEXT_PRIMARY)
        .margin({ left: Spacing.SM })

      Text(`${count}所`)
        .fontSize(FontSize.CAPTION)
        .fontColor(AppColors.TEXT_SECONDARY)
        .margin({ left: Spacing.XS })
    }
    .width('100%')
    .padding({ left: Spacing.MD, right: Spacing.LG, top: Spacing.SM, bottom: Spacing.SM })
    .margin({ top: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
    .borderRadius(Radius.SM)
  }

  @Builder
  bottomActionBar() {
    Row() {
      Text(`已选 ${this.selectedCount}/5 所`)
        .fontSize(FontSize.BODY)
        .fontColor(AppColors.TEXT_SECONDARY)

      Blank()

      Button('生成志愿表')
        .height(44)
        .fontSize(FontSize.BODY)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .linearGradient({
          direction: GradientDirection.Right,
          colors: [['#007AFF', 0.0], ['#5AC8FA', 1.0]]
        })
        .borderRadius(Radius.BUTTON)
        .padding({ left: 24, right: 24 })
        .enabled(this.selectedCount > 0)
        .onClick(() => {
          this.pathStack.pushPath({ name: 'VolunteerForm' });
        })
    }
    .width('100%')
    .padding({ left: Spacing.LG, right: Spacing.LG, top: Spacing.MD, bottom: Spacing.MD })
    .backgroundColor(AppColors.CARD_COLOR)
    .shadow({ radius: 10, color: '#10000000', offsetY: -2 })
  }
}
