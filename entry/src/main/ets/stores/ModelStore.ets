// AI 模型状态管理 — 当前选中模型、模型列表、切换逻辑
import { AppStorageV2 } from '@kit.ArkUI';

// AI 模型定义
export class AiModel {
  readonly id: string;
  readonly name: string;
  readonly description: string;

  constructor(id: string, name: string, description: string) {
    this.id = id;
    this.name = name;
    this.description = description;
  }
}

@ObservedV2
export class ModelStore {
  // 当前选中模型 ID
  @Trace currentModelId: string = 'fast';
  // 当前选中模型名称（便于 UI 直接读取）
  @Trace currentModelName: string = '快速模式';

  // 可选模型列表
  readonly models: AiModel[] = [
    new AiModel('fast', '快速模式', '极速回答，适合简单问题'),
    new AiModel('think', '思考模式', '深入推理，多步思考'),
    new AiModel('search', '联网搜索', '实时联网获取最新信息'),
    new AiModel('k3', 'K3', '最强模型，适合复杂任务'),
  ];

  // 切换模型
  switchModel(modelId: string): void {
    const model: AiModel | undefined = this.models.find((m: AiModel) => m.id === modelId);
    if (model !== undefined) {
      this.currentModelId = model.id;
      this.currentModelName = model.name;
    }
  }

  // 获取所有模型
  getModels(): AiModel[] {
    return this.models;
  }
}

// 全局单例
export const modelStore: ModelStore = AppStorageV2.connect(ModelStore, 'modelStore', () => new ModelStore())!;
