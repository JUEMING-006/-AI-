// 应用颜色常量 — 对标Kimi官方配色（黑白灰 + 品牌蓝 #0066FF）
export class AppColors {
  // 品牌色 — 纯蓝 #0066FF（对标Kimi官方配色）
  static readonly PRIMARY_COLOR: string = '#0066FF';        // 品牌蓝（Kimi标准）
  static readonly PRIMARY_LIGHT: string = '#E3F2FD';        // 淡蓝背景（选中态）
  static readonly PRIMARY_GRADIENT_END: string = '#0066FF'; // 同品牌蓝（无渐变）
  static readonly BACKGROUND_COLOR: string = '#F5F5F7';    // Apple 浅灰底
  static readonly CARD_COLOR: string = '#FFFFFF';
  static readonly TEXT_PRIMARY: string = '#1D1D1F';
  static readonly TEXT_SECONDARY: string = '#86868B';
  static readonly TEXT_HINT: string = '#AEAEB2';
  static readonly DIVIDER_COLOR: string = '#E5E5EA';
  static readonly SUCCESS_COLOR: string = '#10B981';       // 翡翠绿
  static readonly WARNING_COLOR: string = '#F59E0B';       // 琥珀色
  static readonly ERROR_COLOR: string = '#FF3B30';
  static readonly TAB_INACTIVE: string = '#999999';
  static readonly ACCENT_COLOR: string = '#FF9500';        // Apple 橙
  static readonly BLUR_BG: string = '#F2F2F7';             // 毛玻璃半透浅灰

  // 液态玻璃材质色 (Liquid Glass)
  static readonly GLASS_XLIGHT: string = '#F5FFFFFF';      // 极浅玻璃（标题栏、导航栏）
  static readonly GLASS_LIGHT: string = '#E8FFFFFF';       // 浅色玻璃（高透明白）
  static readonly GLASS_MEDIUM: string = '#CCFFFFFF';      // 中等玻璃
  static readonly GLASS_DARK: string = '#99F5F5F7';        // 深色玻璃
  static readonly GLASS_BORDER: string = '#33FFFFFF';      // 玻璃边框（微白描边）
  static readonly GLASS_HIGHLIGHT: string = '#4DFFFFFF';   // 玻璃高光

  // 志愿三梯度色
  static readonly TIER_RUSH: string = '#FF6B6B';
  static readonly TIER_STABLE: string = '#10B981';
  static readonly TIER_SAFE: string = '#0056CC';           // 保底色：稳重深蓝

  // 月之亮面色系（浅色模式）— 对标Kimi官方配色
  static readonly MOON_LIGHT_BG_PAGE: string = '#FFFFFF';       // 页面背景
  static readonly MOON_LIGHT_BG_CONTENT: string = '#F5F5F5';    // 内容区背景
  static readonly MOON_LIGHT_AI_REPLY_BG: string = '#E8E8E8';   // AI回复容器背景
  static readonly MOON_LIGHT_TEXT_PRIMARY: string = '#212121';  // 主文字
  static readonly MOON_LIGHT_TEXT_SECONDARY: string = '#666666';// 次级文字
  static readonly MOON_LIGHT_TEXT_HINT: string = '#999999';     // 辅助文字
  static readonly MOON_LIGHT_DIVIDER: string = '#E0E0E0';       // 分隔线
  static readonly MOON_LIGHT_INPUT_BG: string = '#F5F5F5';      // 输入框背景

  // 月之暗面色系（深色模式）— 对标Kimi官方配色
  static readonly MOON_DARK_BG_PAGE: string = '#121212';        // 页面背景
  static readonly MOON_DARK_BG_CONTENT: string = '#1F1F1F';     // 内容区背景
  static readonly MOON_DARK_AI_REPLY_BG: string = '#2A2A2A';    // AI回复容器背景
  static readonly MOON_DARK_TEXT_PRIMARY: string = '#FFFFFF';   // 主文字
  static readonly MOON_DARK_TEXT_SECONDARY: string = '#AAAAAA'; // 次级文字
  static readonly MOON_DARK_TEXT_HINT: string = '#666666';      // 辅助文字
  static readonly MOON_DARK_DIVIDER: string = '#333333';        // 分隔线
  static readonly MOON_DARK_INPUT_BG: string = '#2A2A2A';       // 输入框背景
}

// 按钮风格常量
export class ButtonStyles {
  static readonly PRIMARY_BTN_BG: string = '#0066FF';        // 主按钮背景（品牌蓝）
  static readonly PRIMARY_BTN_TEXT: string = '#FFFFFF';      // 主按钮文字
  static readonly SECONDARY_BTN_BG: string = '#FFFFFF';      // 次按钮背景
  static readonly SECONDARY_BTN_BORDER: string = '#E5E7EB';  // 次按钮边框
  static readonly SECONDARY_BTN_TEXT: string = '#1A1A2E';    // 次按钮文字
  static readonly TEXT_BTN_COLOR: string = '#0066FF';        // 文字按钮颜色
}

// ============ 系统图标定义 ============
// 最安全策略：仅使用最基础的图标名（无 _fill、无 _2 后缀、无复合名称）
export class TabIcons {
  static readonly HOME: Resource = $r('sys.symbol.house')              // 首页
  static readonly COLLEGE: Resource = $r('sys.symbol.building')        // 院校 - 建筑图标
  static readonly STUDY: Resource = $r('sys.symbol.calendar')          // 规划 - 日历图标表示计划
  static readonly VOLUNTEER: Resource = $r('sys.symbol.doc')           // 志愿 - 文档表单
}

// 快捷入口图标名称
export class QuickEntryIcons {
  static readonly POLICY: Resource = $r('sys.symbol.doc')                 // 政策资讯
  static readonly QUALIFICATION: Resource = $r('sys.symbol.checkmark')    // 资格检测
  static readonly RECOMMENDATION: Resource = $r('sys.symbol.star')        // 院校推荐
  static readonly COMPARISON: Resource = $r('sys.symbol.arrow_right')     // 院校对比
  static readonly PLANNING: Resource = $r('sys.symbol.calendar')          // 学习规划
  static readonly TASK: Resource = $r('sys.symbol.bell')                   // 每日任务
  static readonly PROGRESS: Resource = $r('sys.symbol.clock')             // 学习进度
  static readonly VOLUNTEER: Resource = $r('sys.symbol.bookmark')         // 志愿填报
  static readonly AI: Resource = $r('sys.symbol.lightbulb')              // AI 问答
}

// 底部 Tab 标签文本
export class TabLabels {
  static readonly HOME: string = '首页';
  static readonly COLLEGE: string = '院校';
  static readonly STUDY: string = '规划';
  static readonly VOLUNTEER: string = '志愿';
}

// 中国各省份列表
export const PROVINCE_LIST: string[] = [
  '北京', '天津', '河北', '山西', '内蒙古',
  '辽宁', '吉林', '黑龙江',
  '上海', '江苏', '浙江', '安徽', '福建', '江西', '山东',
  '河南', '湖北', '湖南', '广东', '广西', '海南',
  '重庆', '四川', '贵州', '云南', '西藏',
  '陕西', '甘肃', '青海', '宁夏', '新疆'
];

// 院校类型枚举
export enum CollegeType {
  PUBLIC = '公办',
  PRIVATE = '民办',
  INDEPENDENT = '独立学院',
  SINO_FOREIGN = '中外合作办学'
}

// 院校层次枚举
export enum CollegeLevel {
  DOUBLE_FIRST_CLASS = '双一流',
  FIRST_CLASS_DISCIPLINE = '一流学科',
  REGULAR = '普通本科',
  VOCATIONAL = '高职专科'
}

// 页面路由名称常量
export class RouteNames {
  static readonly POLICY_DETAIL: string = 'PolicyDetail';
  static readonly QUALIFICATION_CHECK: string = 'QualificationCheck';
  static readonly COLLEGE_DETAIL: string = 'CollegeDetail';
  static readonly COLLEGE_FILTER: string = 'CollegeFilter';
  static readonly COLLEGE_COMPARE: string = 'CollegeCompare';
  static readonly STUDY_PLAN: string = 'StudyPlan';
  static readonly DAILY_TASK: string = 'DailyTask';
  static readonly PROGRESS: string = 'Progress';
  static readonly SCORE_INPUT: string = 'ScoreInput';
  static readonly VOLUNTEER_RESULT: string = 'VolunteerResult';
  static readonly LOGIN: string = 'LoginPage';
  // 志愿填报新增路由
  static readonly VOLUNTEER_FORM: string = 'VolunteerForm';
  static readonly SCORE_LINE: string = 'ScoreLine';
  static readonly VOLUNTEER_DIAGNOSE: string = 'VolunteerDiagnose';
  static readonly MAJOR_DETAIL: string = 'MajorDetail';
  static readonly COLLEGE_VOLUNTEER: string = 'CollegeVolunteer';
  static readonly SETTING: string = 'Setting';
}

// 公开路由（无需登录即可访问）
export const PUBLIC_ROUTES: string[] = [
  RouteNames.POLICY_DETAIL,
];

// 需要登录才能访问的 Tab 索引（1=院校, 2=规划, 3=志愿）
export const RESTRICTED_TAB_INDICES: number[] = [1, 2, 3];

// 导航参数接口
export interface CollegeNavParam {
  collegeName: string;
}

export interface MajorNavParam {
  majorName: string;
}
