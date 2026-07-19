// AI 对话数据模型 — 参考 Kimi 对话结构
// 包含消息、对话、思考步骤、引用来源等数据定义

// 消息角色枚举
export enum MessageRole {
  USER = 'user',
  AI = 'assistant',
  SYSTEM = 'system'
}

// 思考步骤状态枚举
export enum ThinkingStatus {
  LOADING = 'loading',
  DONE = 'done'
}

// 历史对话分组类型
export enum ConversationGroup {
  TODAY = '今天',
  YESTERDAY = '昨天',
  WEEK = '7天内',
  EARLIER = '更早'
}

// 思考过程步骤
@ObservedV2
export class ThinkingStep {
  @Trace text: string;
  @Trace status: ThinkingStatus;

  constructor(text: string, status: ThinkingStatus = ThinkingStatus.LOADING) {
    this.text = text;
    this.status = status;
  }
}

// 引用来源
@ObservedV2
export class SourceRef {
  @Trace title: string;
  @Trace description: string;
  @Trace link: string;

  constructor(title: string, description: string, link: string = '') {
    this.title = title;
    this.description = description;
    this.link = link;
  }
}

// 聊天消息
@ObservedV2
export class ChatMessage {
  readonly id: string;
  @Trace role: MessageRole;
  @Trace content: string;
  @Trace timestamp: number;
  @Trace thinkingSteps: ThinkingStep[];
  @Trace sources: SourceRef[];
  @Trace suggestions: string[];
  @Trace isStreaming: boolean;

  constructor(role: MessageRole, content: string) {
    this.id = generateId();
    this.role = role;
    this.content = content;
    this.timestamp = Date.now();
    this.thinkingSteps = [];
    this.sources = [];
    this.suggestions = [];
    this.isStreaming = false;
  }
}

// 对话（会话）
@ObservedV2
export class Conversation {
  readonly id: string;
  @Trace title: string;
  @Trace messages: ChatMessage[];
  @Trace createdAt: number;
  @Trace updatedAt: number;

  constructor(title: string = '新对话') {
    this.id = generateId();
    this.title = title;
    this.messages = [];
    this.createdAt = Date.now();
    this.updatedAt = Date.now();
  }
}

// 生成唯一 ID
function generateId(): string {
  return `${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
}

// 获取对话分组
export function getConversationGroup(conversation: Conversation): ConversationGroup {
  const now: number = Date.now();
  const today: Date = new Date(now);
  today.setHours(0, 0, 0, 0);
  const todayStart: number = today.getTime();
  const yesterdayStart: number = todayStart - 24 * 60 * 60 * 1000;
  const weekStart: number = todayStart - 7 * 24 * 60 * 60 * 1000;

  if (conversation.updatedAt >= todayStart) {
    return ConversationGroup.TODAY;
  } else if (conversation.updatedAt >= yesterdayStart) {
    return ConversationGroup.YESTERDAY;
  } else if (conversation.updatedAt >= weekStart) {
    return ConversationGroup.WEEK;
  } else {
    return ConversationGroup.EARLIER;
  }
}
