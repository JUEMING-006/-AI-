// AI 对话状态管理 — 全局对话状态、历史记录、流式输出控制
import { AppStorageV2 } from '@kit.ArkUI';
import { ChatMessage, Conversation, MessageRole, ThinkingStep, ThinkingStatus, SourceRef } from '../models/ChatModel';

@ObservedV2
export class ChatStore {
  // 所有对话列表（按更新时间倒序）
  @Trace conversations: Conversation[] = [];
  // 当前活跃对话
  @Trace currentConversation: Conversation | null = null;
  // AI 是否正在回复
  @Trace isAiResponding: boolean = false;

  // ============ 对话管理 ============

  // 新建对话并设为当前
  // 如果当前对话没有消息，先删除避免空对话堆积
  createConversation(): Conversation {
    if (this.currentConversation !== null && this.currentConversation.messages.length === 0) {
      const index: number = this.conversations.indexOf(this.currentConversation);
      if (index >= 0) {
        this.conversations.splice(index, 1);
      }
    }
    const conversation = new Conversation();
    this.conversations.unshift(conversation);
    this.currentConversation = conversation;
    return conversation;
  }

  // 切换到指定对话
  switchConversation(conversation: Conversation): void {
    this.currentConversation = conversation;
  }

  // 清除当前对话（回到首页）
  // 不删除对话，保持侧边栏历史信息在首页和聊天页之间一致
  // 空对话的清理在 createConversation 中处理
  clearCurrentConversation(): void {
    this.currentConversation = null;
  }

  // 删除对话
  deleteConversation(conversation: Conversation): void {
    const index: number = this.conversations.indexOf(conversation);
    if (index >= 0) {
      this.conversations.splice(index, 1);
      if (this.currentConversation === conversation) {
        if (this.conversations.length > 0) {
          this.currentConversation = this.conversations[0];
        } else {
          this.currentConversation = null;
        }
      }
    }
  }

  // 确保有当前对话，没有则新建
  ensureConversation(): Conversation {
    if (this.currentConversation === null) {
      return this.createConversation();
    }
    return this.currentConversation;
  }

  // ============ 消息管理 ============

  // 添加用户消息
  addUserMessage(content: string): ChatMessage {
    const conversation: Conversation = this.ensureConversation();
    const message: ChatMessage = new ChatMessage(MessageRole.USER, content);
    conversation.messages.push(message);
    conversation.updatedAt = Date.now();

    // 首条消息作为对话标题
    if (conversation.messages.length === 1) {
      conversation.title = content.length > 20 ? content.substring(0, 20) + '...' : content;
    }
    return message;
  }

  // 创建AI消息并开始流式输出
  startAiMessage(): ChatMessage {
    const conversation: Conversation = this.ensureConversation();
    const message: ChatMessage = new ChatMessage(MessageRole.AI, '');
    message.isStreaming = true;
    conversation.messages.push(message);
    conversation.updatedAt = Date.now();
    this.isAiResponding = true;
    return message;
  }

  // 追加AI消息内容（流式输出）
  appendAiContent(message: ChatMessage, chunk: string): void {
    message.content += chunk;
  }

  // 完成AI消息流式输出
  finishAiMessage(message: ChatMessage): void {
    message.isStreaming = false;
    this.isAiResponding = false;
  }

  // ============ 思考过程 ============

  // 添加思考步骤
  addThinkingStep(message: ChatMessage, text: string): ThinkingStep {
    const step: ThinkingStep = new ThinkingStep(text);
    message.thinkingSteps.push(step);
    return step;
  }

  // 完成思考步骤
  finishThinkingStep(step: ThinkingStep): void {
    step.status = ThinkingStatus.DONE;
  }

  // 完成所有思考步骤
  finishAllThinkingSteps(message: ChatMessage): void {
    message.thinkingSteps.forEach((step: ThinkingStep) => {
      step.status = ThinkingStatus.DONE;
    });
  }

  // ============ 引用来源 ============

  // 添加引用来源
  addSource(message: ChatMessage, title: string, description: string, link: string = ''): void {
    message.sources.push(new SourceRef(title, description, link));
  }

  // ============ 追问建议 ============

  // 设置追问建议
  setSuggestions(message: ChatMessage, suggestions: string[]): void {
    message.suggestions = suggestions;
  }

  // ============ 查询方法 ============

  // 获取当前消息列表
  getCurrentMessages(): ChatMessage[] {
    if (this.currentConversation === null) {
      return [];
    }
    return this.currentConversation.messages;
  }

  // 是否有对话内容
  hasMessages(): boolean {
    return this.currentConversation !== null && this.currentConversation.messages.length > 0;
  }

  // 是否为空状态（无对话或无消息）
  isEmpty(): boolean {
    return !this.hasMessages();
  }
}

// 全局单例，通过 AppStorageV2 共享
export const chatStore: ChatStore = AppStorageV2.connect(ChatStore, 'chatStore', () => new ChatStore())!;
