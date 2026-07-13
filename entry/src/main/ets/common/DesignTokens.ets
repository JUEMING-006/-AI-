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

// 液态玻璃效果配置 (Liquid Glass)
export class GlassEffect {
  static readonly BLUR_THIN: number = 20;       // 薄毛玻璃模糊度
  static readonly BLUR_REGULAR: number = 40;    // 常规毛玻璃
  static readonly BLUR_THICK: number = 80;      // 浓厚毛玻璃
  static readonly BORDER_WIDTH: number = 0.5;   // 玻璃边框宽度
  static readonly SATURATION: number = 1.8;     // 饱和度增强
}
