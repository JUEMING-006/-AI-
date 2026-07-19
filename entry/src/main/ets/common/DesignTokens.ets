// 字体大小令牌 (fp)
export class FontSize {
  static readonly DISPLAY: number = 34;
  static readonly TITLE: number = 22;
  static readonly HEADLINE: number = 17;
  static readonly SUBTITLE: number = 17; // 保留兼容，等同 HEADLINE
  static readonly BODY: number = 15;
  static readonly CAPTION: number = 13;
}

// 字重令牌
export class FontWeightTokens {
  static readonly BOLD: FontWeight = FontWeight.Bold;
  static readonly MEDIUM: FontWeight = FontWeight.Medium;
  static readonly NORMAL: FontWeight = FontWeight.Normal;
}

// 间距令牌 (vp)
export class Spacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 12;
  static readonly LG: number = 20;
  static readonly XL: number = 32;
  static readonly XXL: number = 48;
  static readonly SECTION: number = 40;
}

// 圆角令牌 (vp)
export class Radius {
  static readonly XS: number = 4;
  static readonly SM: number = 10;
  static readonly MD: number = 14;
  static readonly LG: number = 20;
  static readonly XL: number = 24;
  static readonly FULL: number = 999;

  // 语义化圆角
  static readonly BUTTON: number = 10;   // 按钮专用圆角
  static readonly CARD_SM: number = 14;  // 小卡片/列表项
  static readonly CARD_LG: number = 20;  // 大卡片
  static readonly INPUT: number = 12;    // 输入框圆角
}

// 阴影令牌
export class Shadows {
  static readonly CARD: ShadowOptions = { radius: 8, color: '#0A000000', offsetX: 0, offsetY: 2 };
  static readonly ELEVATED: ShadowOptions = { radius: 16, color: '#14000000', offsetX: 0, offsetY: 4 };
  static readonly GLASS: ShadowOptions = { radius: 24, color: '#1A000000', offsetX: 0, offsetY: 8 };
}

// 液态玻璃效果配置 (Liquid Glass) — 透明但有玻璃质感
export class GlassEffect {
  // backgroundEffect — 极低模糊，不会模糊内容，但提供玻璃"折射感"
  static readonly EFFECT_RADIUS: number = 3;           // 极低模糊半径，仅产生微妙的光学质感
  static readonly SATURATION: number = 1.8;            // 高饱和度，透出的内容更鲜亮（玻璃折射增益）
  static readonly BRIGHTNESS: number = 1.08;           // 亮度增强，模拟光线穿过玻璃
  static readonly MASK_COLOR: string = '#12FFFFFF';    // 7% 白色遮罩，极淡

  // 玻璃背景色
  static readonly GLASS_BG_COLOR: string = '#0DFFFFFF';  // 5% 白色极淡底色

  // 玻璃边框 — 明亮的边缘高光，体现玻璃折射
  static readonly BORDER_WIDTH: number = 0.8;          // 稍粗一点，更有质感
  static readonly BORDER_COLOR: string = '#66FFFFFF';  // 40% 白色，明亮玻璃边缘

  // 顶部高光渐变 — 玻璃顶部边缘的反射光
  static readonly HIGHLIGHT_COLOR_START: string = '#33FFFFFF';  // 20% 白色，顶部强高光
  static readonly HIGHLIGHT_COLOR_END: string = '#00FFFFFF';    // 全透明

  // 底部深度渐变 — 模拟玻璃厚度的深度感
  static readonly DEPTH_COLOR_START: string = '#00000000';      // 顶部透明
  static readonly DEPTH_COLOR_END: string = '#0D000000';        // 底部 5% 黑色，微弱内阴影

  // 兼容旧配置
  static readonly BACKDROP_BLUR: number = 28;
  static readonly GRAYSCALE: [number, number] = [0, 0];
  static readonly BLUR_THIN: number = 20;
  static readonly BLUR_REGULAR: number = 40;
  static readonly BLUR_THICK: number = 80;
}

// Kimi 品牌色配置 — 纯蓝 #0066FF（对标Kimi官方配色，无紫色渐变）
export class KimiGradient {
  static readonly ANGLE: number = 135;                          // 渐变角度（保留兼容）
  static readonly START_COLOR: string = '#0066FF';             // 品牌蓝（Kimi标准）
  static readonly END_COLOR: string = '#0066FF';               // 同起始色，无渐变
  static readonly START_COLOR_LIGHT: string = '#4D94FF';       // 浅蓝（悬停态）
  static readonly END_COLOR_LIGHT: string = '#4D94FF';         // 同浅蓝
  static readonly DISABLED_COLOR: string = '#CCCCCC';          // 禁用态灰色背景
  static readonly DISABLED_ICON: string = '#999999';           // 禁用态图标色
}

// 对话场景圆角令牌（参考Kimi特色圆角）
export class ChatRadius {
  static readonly INPUT: number = 22;       // 输入框（大胶囊形，区别于通用12vp）
  static readonly MESSAGE: number = 18;     // 消息气泡（更圆润）
  static readonly TAB_TAG: number = 16;     // 工具栏标签（胶囊形）
  static readonly SHEET_TOP: number = 16;   // BottomSheet顶部圆角
  static readonly CARD: number = 12;        // 卡片/容器
  static readonly MENU_ITEM: number = 8;    // 菜单项
  static readonly BUBBLE_TAIL: number = 6;   // 气泡尖角
}

// 对话场景字体令牌（参考Kimi）
export class ChatFontSize {
  static readonly TITLE: number = 16;       // 模型选择器标题
  static readonly BODY: number = 15;        // 消息正文（比通用15fp一致）
  static readonly STEP: number = 13;        // 思考步骤文字
  static readonly SUGGESTION: number = 13;  // 追问建议
  static readonly SOURCE: number = 13;      // 引用来源标题
  static readonly SOURCE_DESC: number = 12; // 引用来源描述
  static readonly TIME_GROUP: number = 12;  // 历史对话分组标题
}
