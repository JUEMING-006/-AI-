// 动画时长常量 (ms)
export class Duration {
  static readonly FAST: number = 150;
  static readonly NORMAL: number = 300;
  static readonly SLOW: number = 500;
  static readonly STAGGER_DELAY: number = 50;  // 列表逐项延迟
}

// 常用动画配置
export class AnimConfig {
  // 液态按压效果配置（更强反馈）
  static readonly PRESS_SCALE: number = 0.91;           // 更明显的下沉感
  static readonly PRESS_OPACITY: number = 0.75;         // 更明显的暗化
  static readonly LIQUID_PRESS_DURATION: number = 80;   // 按下更快更灵敏
  static readonly LIQUID_RELEASE_DURATION: number = 400; // 释放更有弹性感
  static readonly LIQUID_PRESS_CURVE: Curve = Curve.EaseOut;
  static readonly LIQUID_RELEASE_CURVE: Curve = Curve.EaseOut;

  // 按钮专用按压参数（更深、更快、回弹更慢更弹性）
  static readonly BUTTON_PRESS_SCALE: number = 0.88;     // 按钮按压更深
  static readonly BUTTON_PRESS_OPACITY: number = 0.7;    // 按钮暗化更强
  static readonly BUTTON_PRESS_DURATION: number = 60;    // 按钮响应更快
  static readonly BUTTON_RELEASE_DURATION: number = 500; // 按钮回弹更慢更弹性
  static readonly BUTTON_PRESS_CURVE: Curve = Curve.EaseOut;
  static readonly BUTTON_RELEASE_CURVE: Curve = Curve.EaseOut;

  // Tab 栏按压参数
  static readonly TAB_PRESS_SCALE: number = 0.85;
  static readonly TAB_PRESS_OPACITY: number = 0.6;
  static readonly TAB_PRESS_DURATION: number = 60;
  static readonly TAB_RELEASE_DURATION: number = 450;
  static readonly TAB_PRESS_CURVE: Curve = Curve.EaseOut;
  static readonly TAB_RELEASE_CURVE: Curve = Curve.EaseOut;

  // 兼容旧引用
  static readonly PRESS_DURATION: number = 80;
  static readonly PRESS_CURVE: Curve = Curve.EaseOut;

  // 淡入滑入配置
  static readonly FADE_IN_DURATION: number = 300;
  static readonly SLIDE_OFFSET_Y: number = 20;

  // 弹性数字配置
  static readonly BOUNCE_DURATION: number = 600;
  static readonly BOUNCE_CURVE: Curve = Curve.EaseOut;

  // Tab 切换动画
  static readonly TAB_SWITCH_DURATION: number = 250;
  static readonly TAB_SWITCH_CURVE: Curve = Curve.EaseInOut;

  // 页面转场动画
  static readonly PAGE_TRANSITION_DURATION: number = 300;
  static readonly PAGE_TRANSITION_CURVE: Curve = Curve.FastOutSlowIn;

  // 表单聚焦动画
  static readonly FOCUS_ANIM_DURATION: number = 200;
}

// 列表项 stagger 动画延迟计算
export function getStaggerDelay(index: number): number {
  return index * Duration.STAGGER_DELAY;
}
