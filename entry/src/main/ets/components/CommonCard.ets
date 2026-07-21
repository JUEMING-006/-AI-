/**
 * @deprecated 此组件已废弃，新代码请使用 LiquidGlass 参数规范的组件。
 * 保留用于兼容旧代码，新功能请勿引用此组件。
 */
import { AppColors } from '../common/Constants';
import { Radius, Shadows, Spacing, GlassEffect } from '../common/DesignTokens';
import { AnimConfig } from '../common/AnimationHelper';

@ComponentV2
export struct CommonCard {
  @Param radius: number = Radius.LG;
  @Param cardPadding: number = 24;
  @Param marginTop: number = Spacing.MD;
  @Param enableBlur: boolean = true;
  @Param enablePressAnim: boolean = true;
  @BuilderParam content: () => void = this.defaultContent;
  @Local scaleValue: number = 1;
  @Local opacityValue: number = 1;

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      this.content();
    }
    .width('100%')
    .padding(this.cardPadding)
    .margin({ top: this.marginTop })
    .backgroundColor(AppColors.GLASS_LIGHT)
    .backgroundBlurStyle(BlurStyle.COMPONENT_REGULAR)
    .border({ width: GlassEffect.BORDER_WIDTH, color: AppColors.GLASS_BORDER })
    .borderRadius(this.radius)
    .shadow(Shadows.GLASS)
    .scale({ x: this.scaleValue, y: this.scaleValue })
    .opacity(this.opacityValue)
    .onTouch((event: TouchEvent) => {
      if (!this.enablePressAnim) return;
      if (event.type === TouchType.Down) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_PRESS_DURATION,
          curve: AnimConfig.LIQUID_PRESS_CURVE,
        }, () => {
          this.scaleValue = AnimConfig.PRESS_SCALE;
          this.opacityValue = AnimConfig.PRESS_OPACITY;
        });
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.getUIContext()?.animateTo({
          duration: AnimConfig.LIQUID_RELEASE_DURATION,
          curve: AnimConfig.LIQUID_RELEASE_CURVE,
        }, () => {
          this.scaleValue = 1;
          this.opacityValue = 1;
        });
      }
    })
  }
}
