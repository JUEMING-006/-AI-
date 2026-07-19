// AI 对话服务 — Mock 实现，后续可替换为真实大模型 API
import { chatStore } from '../stores/ChatStore';

// Mock 引用来源
class MockSource {
  title: string;
  description: string;

  constructor(title: string, description: string) {
    this.title = title;
    this.description = description;
  }
}

// Mock 回复结构
class MockResponse {
  content: string;
  sources: MockSource[];
  suggestions: string[];

  constructor(content: string, sources: MockSource[], suggestions: string[]) {
    this.content = content;
    this.sources = sources;
    this.suggestions = suggestions;
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

// 根据用户输入关键词匹配 Mock 回复
function getMockResponse(userMessage: string): MockResponse {
  const msg: string = userMessage.toLowerCase();

  // 专升本报考条件
  if (msg.includes('条件') || msg.includes('资格') || msg.includes('报考')) {
    return new MockResponse(
      '专升本报考一般需要满足以下条件：\n\n1. 学历要求：具有国民教育系列专科及以上学历\n2. 身份要求：应届或往届专科毕业生\n3. 专业要求：报考专业需与专科专业相同或相近\n4. 年龄要求：一般无年龄限制\n\n具体条件因省份而异，建议查看当地教育考试院的官方通知。',
      [
        new MockSource('教育部专升本政策文件', '官方专升本报考条件说明'),
        new MockSource('各省教育考试院', '各省份具体报考要求')
      ],
      ['各省份专升本政策有什么差异？', '专升本考试科目有哪些？', '如何选择目标院校？']
    );
  }

  // 专升本考试科目
  if (msg.includes('科目') || msg.includes('考试内容') || msg.includes('考什么')) {
    return new MockResponse(
      '专升本考试科目一般分为以下几类：\n\n1. 公共课：英语、政治/计算机基础\n2. 专业课：根据报考专业不同，考查相关专业知识\n3. 部分省份还需考查高等数学\n\n以广东省为例，考试科目为：英语 + 政治 + 专业基础课 + 专业综合课。建议根据目标省份的考试大纲有针对性地复习。',
      [
        new MockSource('各省专升本考试大纲', '官方考试科目与范围'),
        new MockSource('历年真题汇总', '往年考试题型参考')
      ],
      ['如何制定复习计划？', '英语复习有什么技巧？', '专业课怎么复习？']
    );
  }

  // 院校选择
  if (msg.includes('院校') || msg.includes('学校') || msg.includes('选择') || msg.includes('推荐')) {
    return new MockResponse(
      '选择专升本院校时，建议从以下几个维度综合考虑：\n\n1. 院校层次：双一流 > 一流学科 > 普通本科\n2. 录取分数：参考往年分数线，结合自身成绩定位\n3. 招生人数：招生人数多的院校录取概率相对较高\n4. 专业匹配：确保目标院校开设你的专科对应专业\n5. 地理位置：考虑城市发展水平和就业机会\n\n建议采用"冲稳保"策略，合理填报志愿梯度。',
      [
        new MockSource('全国专升本院校库', '各院校招生信息汇总'),
        new MockSource('历年分数线数据', '各院校录取分数参考')
      ],
      ['什么是冲稳保策略？', '如何查询院校分数线？', '志愿填报有什么技巧？']
    );
  }

  // 志愿填报
  if (msg.includes('志愿') || msg.includes('填报') || msg.includes('录取')) {
    return new MockResponse(
      '专升本志愿填报技巧：\n\n1. 冲稳保策略：\n   - 冲刺院校：录取概率 30-50%\n   - 稳妥院校：录取概率 60-80%\n   - 保底院校：录取概率 90%+\n\n2. 梯度设置：志愿间分差建议 10-20 分\n\n3. 专业优先 vs 院校优先：\n   - 就业导向：院校优先\n   - 深造导向：专业优先\n\n4. 注意事项：\n   - 关注招生计划变化\n   - 了解专业对照表\n   - 确认身体条件要求',
      [
        new MockSource('志愿填报指南', '官方志愿填报说明'),
        new MockSource('录取规则解读', '平行志愿与梯度志愿区别')
      ],
      ['如何评估录取概率？', '平行志愿怎么填？', '滑档了怎么办？']
    );
  }

  // 学习计划
  if (msg.includes('学习') || msg.includes('复习') || msg.includes('计划') || msg.includes('备考')) {
    return new MockResponse(
      '专升本备考建议分三个阶段：\n\n1. 基础阶段（3-6个月）：\n   - 系统学习各科基础知识\n   - 建立知识框架体系\n   - 每日学习 4-6 小时\n\n2. 强化阶段（2-3个月）：\n   - 专项突破薄弱环节\n   - 大量刷题巩固\n   - 每日学习 6-8 小时\n\n3. 冲刺阶段（1个月）：\n   - 模拟考试训练\n   - 查漏补缺\n   - 调整心态和作息\n\n建议使用"番茄工作法"保持专注，并结合错题本复盘。',
      [
        new MockSource('专升本备考经验', '上岸学长学姐分享'),
        new MockSource('各科复习方法', '分科目复习策略')
      ],
      ['如何制定每日学习计划？', '英语复习有什么技巧？', '如何保持学习动力？']
    );
  }

  // 默认回复
  return new MockResponse(
    `你好！我是鸿蒙AI指导者，你的智能升本助手。\n\n关于"${userMessage}"，我目前还在学习中。你可以尝试问我：\n\n- 专升本报考条件是什么？\n- 专升本考试科目有哪些？\n- 如何选择目标院校？\n- 志愿填报有什么技巧？\n- 如何制定复习计划？\n\n我会持续优化，为你提供更精准的回答。`,
    [],
    ['专升本报考条件是什么？', '如何选择目标院校？', '如何制定复习计划？']
  );
}

// AI 对话服务（Mock 实现）
export class ChatService {
  // 发送消息并获取 AI 回复
  static async sendMessage(content: string): Promise<void> {
    // 1. 添加用户消息
    chatStore.addUserMessage(content);

    // 2. 创建 AI 消息（开始流式输出）
    const aiMessage = chatStore.startAiMessage();

    // 3. 模拟思考过程（3 步）
    const thinkingSteps: string[] = ['正在搜索相关信息...', '分析资料内容...', '整理回复内容...'];
    for (let i = 0; i < thinkingSteps.length; i++) {
      const step = chatStore.addThinkingStep(aiMessage, thinkingSteps[i]);
      await delay(800);
      chatStore.finishThinkingStep(step);
    }

    // 4. 获取 Mock 回复
    const response: MockResponse = getMockResponse(content);

    // 5. 流式输出回答内容
    const chunks: string[] = splitContent(response.content);
    for (let i = 0; i < chunks.length; i++) {
      chatStore.appendAiContent(aiMessage, chunks[i]);
      await delay(50);
    }

    // 6. 添加引用来源
    for (let i = 0; i < response.sources.length; i++) {
      const source = response.sources[i];
      chatStore.addSource(aiMessage, source.title, source.description);
    }

    // 7. 添加追问建议
    chatStore.setSuggestions(aiMessage, response.suggestions);

    // 8. 完成回复
    chatStore.finishAiMessage(aiMessage);
  }

  // 新建对话
  static createNewConversation(): void {
    chatStore.createConversation();
  }
}
