import { AppColors, TabIcons, TabLabels } from '../common/Constants';
import { routerMap } from '../router/RouterMap';
import { HomePage } from '../views/home/HomePage';
import { CollegePage } from '../views/college/CollegePage';
import { StudyPlanPage } from '../views/study/StudyPlanPage';
import { VolunteerPage } from '../views/volunteer/VolunteerPage';
import { LiquidTabBar } from '../components/LiquidTabBar';

/**
 * 🌟 主入口页面 - 液态玻璃风格底部Tab栏
 * 
 * 特性：
 * - 悬浮固定的底部Tab导航栏
 * - 液态玻璃磨砂质感
 * - 穿透交互设计
 * - 适配安全区域
 */
@Entry
@ComponentV2
struct Index {
  @Provider('pathStack') pathStack: NavPathStack = new NavPathStack();
  @Local currentIndex: number = 0;
  @Local safeAreaTop: number = 0;
  @Local safeAreaBottom: number = 0;

  aboutToAppear(): void {
    // 获取安全区域高度
    this.safeAreaTop = AppStorage.get<number>('safeAreaTop') ?? 0;
    this.safeAreaBottom = AppStorage.get<number>('safeAreaBottom') ?? 0;
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 📱 页面内容区域
      Navigation(this.pathStack) {
        // 根据当前 Tab 索引显示对应页面
        if (this.currentIndex === 0) {
          HomePage()
        } else if (this.currentIndex === 1) {
          CollegePage()
        } else if (this.currentIndex === 2) {
          StudyPlanPage()
        } else if (this.currentIndex === 3) {
          VolunteerPage()
        }
      }
      .width('100%')
      .height('100%')
      .navDestination(routerMap)
      .hideTitleBar(true)
      .mode(NavigationMode.Stack)
      
      // 🌊 液态玻璃风格底部 Tab 栏
      LiquidTabBar({
        currentIndex: this.currentIndex,
        onTabChange: (index: number) => {
          this.currentIndex = index;
        },
        safeAreaBottom: this.safeAreaBottom
      })
    }
    .width('100%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
