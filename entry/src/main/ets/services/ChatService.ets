// AI 对话服务 — [BACKEND] 后端调用已注释，当前使用前端 mock 回复
import { chatStore } from '../stores/ChatStore';
import { ChatMessage, MessageRole } from '../models/ChatModel';
// [BACKEND] import { httpClient } from './HttpClient';
// [BACKEND] import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'ChatService';

// 请求体 DTO
class ChatMessageDto {
  role: string;
  content: string;

  constructor(role: string, content: string) {
    this.role = role;
    this.content = content;
  }
}

class ChatRequestBody {
  messages: ChatMessageDto[];

  constructor(messages: ChatMessageDto[]) {
    this.messages = messages;
  }
}

// 延时工具
function delay(ms: number): Promise<void> {
  return new Promise<void>((resolve: () => void) => setTimeout(resolve, ms));
}

// 将内容按片段分割（模拟流式逐字输出）
function splitContent(content: string): string[] {
  const chunks: string[] = [];
  const chunkSize: number = 2;
  for (let i = 0; i < content.length; i += chunkSize) {
    const end: number = Math.min(i + chunkSize, content.length);
    chunks.push(content.substring(i, end));
  }
  return chunks;
}

// mock AI 回复生成
function getMockReply(userContent: string): string {
  const lower: string = userContent.toLowerCase();
  if (lower.includes('专升本') || lower.includes('升本')) {
    return '专升本考试是专科生提升学历的重要途径。根据最新政策，专升本分为统招专升本和成人专升本两种形式。\n\n统招专升本（也称普通专升本）面向应届专科毕业生，考试科目通常包括公共课（英语、政治）和专业课，各省份具体要求略有不同。\n\n建议你：\n1. 明确目标院校和专业的招生要求\n2. 制定合理的复习计划，分阶段推进\n3. 多做真题，熟悉考试题型和难度\n4. 关注省教育考试院发布的最新政策\n\n有什么具体的专升本问题我可以帮你解答吗？';
  }
  if (lower.includes('院校') || lower.includes('学校') || lower.includes('大学')) {
    return '选择专升本院校时，建议从以下几个维度综合考虑：\n\n1. **办学层次**：关注是公办还是民办，公办院校通常学费更低、社会认可度更高\n2. **专业匹配**：确认院校是否开设与你专科专业对口的本科专业\n3. **历年分数线**：参考近三年录取分数线，评估自身实力\n4. **地理位置**：考虑城市发展与就业机会\n5. **招生计划**：关注年度招生人数和报录比\n\n你可以在「院校库」中查看详细信息，也可以告诉我你的专业和目标省份，我帮你推荐合适的院校。';
  }
  if (lower.includes('专业') || lower.includes('科目')) {
    return '专升本的专业选择非常重要，直接影响未来的发展方向。\n\n**选专业建议：**\n- 优先选择与专科相同或相近的专业，备考难度更低\n- 关注该专业的就业前景和薪资水平\n- 了解目标院校该专业的招生人数和竞争强度\n\n**常见热门专升本专业：**\n- 计算机科学与技术\n- 会计学\n- 护理学\n- 学前教育\n- 工商管理\n\n你目前是什么专业呢？我可以帮你分析可报的本科专业。';
  }
  if (lower.includes('学习') || lower.includes('计划') || lower.includes('复习')) {
    return '制定高效的专升本复习计划，建议分为三个阶段：\n\n**第一阶段：基础巩固（1-3月）**\n- 系统学习各科基础知识，梳理知识框架\n- 每天保持4-6小时有效学习时间\n- 配合教材和网课，做好笔记\n\n**第二阶段：强化提升（3-6月）**\n- 专题训练，突破重难点\n- 开始做历年真题，总结命题规律\n- 每周进行一次模拟测试\n\n**第三阶段：冲刺冲刺（最后1-2月）**\n- 查漏补缺，重点复习薄弱环节\n- 高频模拟，训练答题速度和心态\n- 关注考试动态和政策变化\n\n你可以在「学习计划」页面生成个性化的复习方案，加油！';
  }
  if (lower.includes('志愿') || lower.includes('填报')) {
    return '专升本志愿填报建议采用"冲稳保"策略：\n\n**冲（20%）**：选择略高于自己分数的院校，争取冲刺机会\n**稳（50%）**：选择与自己分数匹配的院校，确保录取概率\n**保（30%）**：选择低于自己分数的院校，作为保底\n\n**注意事项：**\n1. 仔细阅读各院校招生章程，了解录取规则\n2. 关注是否有专业限制或加试要求\n3. 合理安排志愿顺序，平行志愿也有先后\n4. 服从专业调剂可增加录取机会\n\n你可以在「志愿填报」页面输入成绩，系统会自动为你匹配推荐院校。';
  }
  return '你好！我是你的专升本 AI 助手，可以帮你解答以下问题：\n\n📚 **专升本政策** — 报考条件、考试科目、报名时间\n🏫 **院校选择** — 院校推荐、分数线查询、专业匹配\n📝 **学习计划** — 复习规划、每日任务、进度跟踪\n🎯 **志愿填报** — 冲稳保策略、院校推荐、录取概率\n\n请问有什么我可以帮你的吗？';
}

// AI 对话服务
export class ChatService {
  // 发送消息并获取 AI 回复
  static async sendMessage(content: string): Promise<void> {
    hilog.info(DOMAIN, TAG, 'sendMessage: %{public}s', content);

    // 1. 添加用户消息
    chatStore.addUserMessage(content);

    // 2. 收集对话历史（此时不含 AI 空消息）
    const history: ChatMessage[] = chatStore.getCurrentMessages();
    const dtoList: ChatMessageDto[] = [];
    for (let i = 0; i < history.length; i++) {
      const msg: ChatMessage = history[i];
      if (msg.role === MessageRole.USER) {
        dtoList.push(new ChatMessageDto('user', msg.content));
      } else if (msg.role === MessageRole.AI && msg.content.length > 0) {
        dtoList.push(new ChatMessageDto('assistant', msg.content));
      }
    }

    // 3. 创建 AI 消息（开始流式输出）
    const aiMessage = chatStore.startAiMessage();

    // 4. 显示思考步骤
    const step = chatStore.addThinkingStep(aiMessage, '正在思考...');
    await delay(400);
    chatStore.finishThinkingStep(step);

    try {
      // [BACKEND] 5. 调用后端 AI 接口（60 秒超时）
      // [BACKEND] const requestBody: ChatRequestBody = new ChatRequestBody(dtoList);
      // [BACKEND] const response: AxiosResponse<Record<string, Object>> = await httpClient.post(
      // [BACKEND]   '/chat/completions', requestBody, { timeout: 60000 });
      // [BACKEND] const aiContent: string = (response.data['content'] as string) ?? '';

      // mock AI 回复
      const aiContent: string = getMockReply(content);
      hilog.info(DOMAIN, TAG, '[MOCK] AI 回复长度: %{public}d', aiContent.length);
      await delay(300);

      // 6. 流式输出回答内容（模拟逐字显示）
      const chunks: string[] = splitContent(aiContent);
      for (let i = 0; i < chunks.length; i++) {
        chatStore.appendAiContent(aiMessage, chunks[i]);
        await delay(30);
      }

      // 7. 完成回复
      chatStore.finishAiMessage(aiMessage);

    } catch (error) {
      hilog.error(DOMAIN, TAG, '[MOCK] AI 调用失败: %{public}s', (error as Error).message);
      chatStore.appendAiContent(aiMessage, '\n\n⚠️ AI 服务暂时不可用，请检查网络后重试。');
      chatStore.finishAiMessage(aiMessage);
    }
  }

  // 新建对话
  static createNewConversation(): void {
    chatStore.createConversation();
  }
}
