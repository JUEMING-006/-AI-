// AI 模型状态管理 — 当前选中模式、模式列表、切换逻辑
import { AppStorageV2 } from '@kit.ArkUI';
import { RouteNames } from '../common/Constants';

// 对话模式定义
export class AiModel {
  readonly id: string;
  readonly name: string;
  readonly description: string;
  readonly route: string; // 空字符串表示留在对话页

  constructor(id: string, name: string, description: string, route: string = '') {
    this.id = id;
    this.name = name;
    this.description = description;
    this.route = route;
  }
}

@ObservedV2
export class ModelStore {
  // 当前选中模式 ID
  @Trace currentModelId: string = 'ai';
  // 当前选中模式名称（便于 UI 直接读取）
  @Trace currentModelName: string = 'AI对话';

  // 可选模式列表
  readonly models: AiModel[] = [
    new AiModel('ai', 'AI对话', '智能对话，解答专升本问题'),
    new AiModel('college', '院校库', '浏览全国专升本院校', RouteNames.COLLEGE_DETAIL),
    new AiModel('volunteer', '志愿填报', '智能志愿推荐与诊断', RouteNames.VOLUNTEER_RESULT),
    new AiModel('study', '学习计划', '制定个性化备考计划', RouteNames.STUDY_PLAN),
    new AiModel('policy', '政策资讯', '最新专升本政策解读', RouteNames.POLICY_DETAIL),
  ];

  // 切换模式
  switchModel(modelId: string): void {
    const model: AiModel | undefined = this.models.find((m: AiModel) => m.id === modelId);
    if (model !== undefined) {
      this.currentModelId = model.id;
      this.currentModelName = model.name;
    }
  }

  // 获取所有模式
  getModels(): AiModel[] {
    return this.models;
  }
}

// 全局单例
export const modelStore: ModelStore = AppStorageV2.connect(ModelStore, 'modelStore', () => new ModelStore())!;
