import { RouteNames, AppColors, TabIcons, TabLabels } from '../common/Constants';
import { routerMap } from '../router/RouterMap';
import { AnimConfig } from '../common/AnimationHelper';
import { HomePage } from '../views/home/HomePage';
import { CollegePage } from '../views/college/CollegePage';
import { StudyPlanPage } from '../views/study/StudyPlanPage';
import { VolunteerPage } from '../views/volunteer/VolunteerPage';

// 主入口页面：Navigation + Tabs 框架
@Entry
@ComponentV2
struct Index {
  @Provider('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local currentIndex: number = 0;
  @Local tabScale: number[] = [1.0, 1.0, 1.0, 1.0];
  @Local tabOpacity: number[] = [1.0, 1.0, 1.0, 1.0];

  @Builder
  tabBarBuilder(icon: Resource, label: string, index: number) {
    Column() {
      SymbolGlyph(icon)
        .fontSize(24)
        .fontColor([index === this.currentIndex ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT])
      Text(label)
        .fontSize(11)
        .margin({ top: 2 })
        .fontColor(index === this.currentIndex ? AppColors.PRIMARY_COLOR : AppColors.TEXT_HINT)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(AppColors.CARD_COLOR)
    .border({ width: { top: 1 }, color: AppColors.DIVIDER_COLOR })
    .scale({ x: this.tabScale[index], y: this.tabScale[index] })
    .opacity(this.tabOpacity[index])
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.TAB_PRESS_DURATION,
          curve: AnimConfig.TAB_PRESS_CURVE,
        }, () => {
          const newScale: number[] = [...this.tabScale];
          newScale[index] = AnimConfig.TAB_PRESS_SCALE;
          this.tabScale = newScale;
          const newOpacity: number[] = [...this.tabOpacity];
          newOpacity[index] = AnimConfig.TAB_PRESS_OPACITY;
          this.tabOpacity = newOpacity;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.TAB_RELEASE_DURATION,
          curve: AnimConfig.TAB_RELEASE_CURVE,
        }, () => {
          const newScale: number[] = [...this.tabScale];
          newScale[index] = 1.0;
          this.tabScale = newScale;
          const newOpacity: number[] = [...this.tabOpacity];
          newOpacity[index] = 1.0;
          this.tabOpacity = newOpacity;
        });
      }
    })
  }

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.currentIndex }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.tabBarBuilder(TabIcons.HOME, TabLabels.HOME, 0))

        TabContent() {
          CollegePage()
        }
        .tabBar(this.tabBarBuilder(TabIcons.COLLEGE, TabLabels.COLLEGE, 1))

        TabContent() {
          StudyPlanPage()
        }
        .tabBar(this.tabBarBuilder(TabIcons.STUDY, TabLabels.STUDY, 2))

        TabContent() {
          VolunteerPage()
        }
        .tabBar(this.tabBarBuilder(TabIcons.VOLUNTEER, TabLabels.VOLUNTEER, 3))
      }
      .barHeight(49)
      .onChange((index: number) => {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.TAB_SWITCH_DURATION,
          curve: AnimConfig.TAB_SWITCH_CURVE,
        }, () => {
          this.currentIndex = index;
        });
      })
    }
    .navDestination(routerMap)
    .hideTitleBar(true)
  }
}
