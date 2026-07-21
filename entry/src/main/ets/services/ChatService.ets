// AI 对话服务 — [BACKEND] 后端调用已注释，当前使用前端 mock 回复
import { chatStore } from '../stores/ChatStore';
import { ChatMessage, MessageRole, SourceRef } from '../models/ChatModel';
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
  if (lower.includes('分数线') || lower.includes('录取') || lower.includes('分数')) {
    return '专升本分数线是录取的关键参考指标，以下是详细说明：\n\n**分数线类型：**\n- **省控线（最低控制线）**：省教育考试院统一划定，低于此线无法投档\n- **院校线**：各院校实际录取最低分，通常≥省控线\n- **专业线**：同一院校不同专业分数线可能差异较大\n\n**2024年广东省专升本省控线参考：**\n- 文史类：180分\n- 理工类：160分\n- 经管类：170分\n- 教育类：190分\n\n**查询建议：**\n1. 关注省教育考试院官网发布的官方数据\n2. 在「院校库」查看各院校历年录取分数线\n3. 对比近三年分数线趋势，评估录取概率\n\n你可以告诉我你的专业和预估分数，我帮你分析可报院校。';
  }
  if (lower.includes('政策') || lower.includes('报名') || lower.includes('报考')) {
    return '专升本最新政策要点如下：\n\n**报考条件：**\n1. 应届普通高职（专科）毕业生\n2. 或具有普通高职（专科）毕业学历的退役士兵\n3. 部分省份要求专业对口或相近\n\n**报名时间：**\n- 一般在每年1-3月报名，4-5月考试\n- 具体时间以省教育考试院通知为准\n\n**考试科目：**\n- 公共课：英语、政治（部分省份考数学）\n- 专业课：根据报考专业确定，通常1-2门\n- 各省份考试科目和分值不同\n\n**政策趋势：**\n- 扩招持续，部分院校新增招生计划\n- 职业本科纳入专升本招生范围\n- 退役士兵免文化课考试政策推广\n\n建议关注「政策资讯」页面获取最新动态。';
  }
  if (lower.includes('考试') || lower.includes('科目') || lower.includes('考什么')) {
    return '专升本考试科目因省份和专业而异，以下是通用说明：\n\n**公共课（必考）：**\n- **英语**：大部分省份必考，满分100-150分\n- **政治**：部分省份必考，满分100分\n- **数学**：理工类专业通常考，满分100-150分\n- **大学语文**：文史类专业通常考\n\n**专业课（按专业划分）：**\n- 计算机类：计算机基础、数据结构等\n- 经管类：管理学、经济学等\n- 教育类：教育学、心理学等\n- 护理类：医学基础、护理学等\n\n**备考建议：**\n1. 查阅目标省份的考试大纲\n2. 公共课尽早开始复习，尤其是英语\n3. 专业课参考指定教材和历年真题\n4. 制定分阶段复习计划\n\n你可以在「学习计划」页面生成个性化备考方案。';
  }
  return '你好！我是你的专升本 AI 助手，可以帮你解答以下问题：\n\n📚 **专升本政策** — 报考条件、考试科目、报名时间\n🏫 **院校选择** — 院校推荐、分数线查询、专业匹配\n📝 **学习计划** — 复习规划、每日任务、进度跟踪\n🎯 **志愿填报** — 冲稳保策略、院校推荐、录取概率\n📊 **分数线查询** — 省控线、院校线、专业线\n\n请问有什么我可以帮你的吗？';
}

// mock 追问建议
function getMockSuggestions(userContent: string): string[] {
  const lower: string = userContent.toLowerCase();
  if (lower.includes('专升本') || lower.includes('升本')) {
    return ['专升本考试什么时候报名？', '专升本考试科目有哪些？', '如何选择目标院校？'];
  }
  if (lower.includes('院校') || lower.includes('学校') || lower.includes('大学')) {
    return ['查看院校录取分数线', '哪些院校可以跨专业报考？', '公办和民办院校有什么区别？'];
  }
  if (lower.includes('专业') || lower.includes('科目')) {
    return ['我的专业可以报哪些本科专业？', '热门专升本专业有哪些？', '跨专业报考有什么限制？'];
  }
  if (lower.includes('学习') || lower.includes('计划') || lower.includes('复习')) {
    return ['生成个性化学习计划', '专升本英语怎么复习？', '如何高效备考专业课？'];
  }
  if (lower.includes('志愿') || lower.includes('填报')) {
    return ['帮我分析冲稳保策略', '志愿填报有哪些注意事项？', '如何评估录取概率？'];
  }
  if (lower.includes('分数线') || lower.includes('录取') || lower.includes('分数')) {
    return ['历年分数线趋势分析', '我的分数能上什么学校？', '省控线和院校线有什么区别？'];
  }
  if (lower.includes('政策') || lower.includes('报名') || lower.includes('报考')) {
    return ['专升本报考条件是什么？', '退役士兵有什么优惠政策？', '2024年专升本有什么新政策？'];
  }
  return ['专升本考试科目有哪些？', '如何选择目标院校？', '专升本分数线是多少？'];
}

// mock 引用来源
function getMockSources(userContent: string): SourceRef[] {
  const lower: string = userContent.toLowerCase();
  const sources: SourceRef[] = [];
  if (lower.includes('政策') || lower.includes('报名') || lower.includes('报考')) {
    sources.push(new SourceRef('广东省教育考试院', '2024年普通专升本招生工作通知', 'https://eea.gd.gov.cn'));
    sources.push(new SourceRef('教育部', '普通高等学校专升本考试招生工作通知'));
  }
  if (lower.includes('院校') || lower.includes('学校') || lower.includes('大学')) {
    sources.push(new SourceRef('院校库', '广东省专升本招生院校汇总信息'));
  }
  if (lower.includes('分数线') || lower.includes('录取')) {
    sources.push(new SourceRef('广东省教育考试院', '2024年专升本各科类最低控制分数线'));
  }
  if (lower.includes('学习') || lower.includes('计划') || lower.includes('复习')) {
    sources.push(new SourceRef('学习计划', '基于大数据的专升本备考方案推荐'));
  }
  return sources;
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

      // 7. 添加引用来源
      const sources: SourceRef[] = getMockSources(content);
      for (const src of sources) {
        chatStore.addSource(aiMessage, src.title, src.description, src.link);
      }

      // 8. 添加追问建议
      const suggestions: string[] = getMockSuggestions(content);
      chatStore.setSuggestions(aiMessage, suggestions);

      // 9. 完成回复
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
