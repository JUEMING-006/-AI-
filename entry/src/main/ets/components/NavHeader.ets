import { AppColors } from '../common/Constants';

/**
 * 自定义导航栏组件 - 替代 NavDestination 系统标题栏
 *
 * 特性：
 * - 自带状态栏安全区避让（Blank + safeAreaTop）
 * - 返回按钮 + 标题
 * - 配合 .hideTitleBar(true) + .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]) 使用
 */
@ComponentV2
export struct NavHeader {
  @Param title: string = '';
  @Consumer('pathStack') pathStack: NavPathStack = new NavPathStack();

  build() {
    Column() {
      // 状态栏安全区避让
      Blank().height(AppStorage.get<number>('safeAreaTop') ?? 0)

      // 导航栏
      Row() {
        // 返回按钮
        SymbolGlyph($r('sys.symbol.chevron_left'))
          .fontSize(24)
          .fontColor([AppColors.TEXT_PRIMARY])
          .padding({ left: 4, right: 4, top: 8, bottom: 8 })
          .onClick(() => {
            this.pathStack.pop();
          })

        // 标题
        Text(this.title)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppColors.TEXT_PRIMARY)
          .margin({ left: 4 })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)

        // 右侧占位（保持标题左对齐平衡）
        Blank().width(32)
      }
      .width('100%')
      .height(44)
      .padding({ left: 8, right: 16 })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
  }
}
