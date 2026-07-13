import { PolicyInfo, QualificationResult, QualificationCheckData } from '../models/PolicyModel';

// 政策服务：封装政策相关 API 调用（暂用 Mock 数据）
export class PolicyService {

  // 获取政策列表 GET /api/v1/policies?province=
  async getPolicies(province: string): Promise<PolicyInfo[]> {
    // TODO: 替换为真实 API 调用
    // const response = await httpClient.get(`/policies?province=${province}`);
    // return response.data as PolicyInfo[];
    return PolicyService.getMockPolicies(province);
  }

  // 获取政策详情 GET /api/v1/policies/{id}
  async getPolicyDetail(id: string): Promise<PolicyInfo> {
    // TODO: 替换为真实 API 调用
    // const response = await httpClient.get(`/policies/${id}`);
    // return response.data as PolicyInfo;
    const policies: PolicyInfo[] = PolicyService.getMockPolicies('');
    const found: PolicyInfo | undefined = policies.find((p: PolicyInfo) => p.id === id);
    if (found !== undefined) {
      return found;
    }
    const empty: PolicyInfo = new PolicyInfo();
    empty.id = id;
    empty.title = '未找到政策';
    empty.content = '该政策信息暂时无法获取，请稍后重试。';
    return empty;
  }

  // 资格检测 POST /api/v1/qualification/check
  async checkQualification(data: QualificationCheckData): Promise<QualificationResult> {
    // TODO: 替换为真实 API 调用
    // const response = await httpClient.post('/qualification/check', data);
    // return response.data as QualificationResult;
    return PolicyService.getMockQualificationResult(data);
  }

  // Mock 政策数据
  private static getMockPolicies(province: string): PolicyInfo[] {
    const mockData: PolicyInfo[] = [
      PolicyService.createPolicy(
        'policy_001',
        '广东省2026年普通专升本报名通知',
        '广东省教育考试院发布2026年普通专升本考试报名工作的通知，明确报名时间、考试科目及要求。',
        '广东',
        'notice',
        '2026-06-15',
        '广东省教育考试院',
        '根据教育部有关文件精神，现就做好广东省2026年普通高等学校专升本招生报名工作通知如下：\n\n' +
        '一、招生对象：具有广东省户籍的普通高校专科应届毕业生或往届毕业生。\n\n' +
        '二、报名时间：2026年1月10日至1月20日。\n\n' +
        '三、考试科目：公共课（政治理论、英语）+ 专业基础课 + 专业综合课。\n\n' +
        '四、考试时间：2026年4月中旬，具体以准考证为准。\n\n' +
        '五、报名方式：登录广东省教育考试院官网进行网上报名，按要求上传材料并缴费。'
      ),
      PolicyService.createPolicy(
        'policy_002',
        '2026年专升本招生政策改革要点解读',
        '教育部发布专升本招生新政，对招生计划、考试科目和录取规则进行调整。',
        '全国',
        'policy',
        '2026-05-20',
        '教育部',
        '2026年专升本招生政策主要变化如下：\n\n' +
        '一、扩大招生规模：全国专升本招生计划较2025年增加约10%，重点向理工类和医学类专业倾斜。\n\n' +
        '二、考试科目优化：部分省份试点统考+校考结合模式，专业课由招生院校自主命题。\n\n' +
        '三、录取规则调整：平行志愿院校数量由原来的6个增加至9个，增加考生录取机会。\n\n' +
        '四、免试入学政策：退役大学生士兵、技能大赛获奖选手等可申请免试入学。'
      ),
      PolicyService.createPolicy(
        'policy_003',
        '广东省专升本考试大纲（2026年版）',
        '广东省教育考试院公布2026年专升本各科目考试大纲及参考书目。',
        '广东',
        'outline',
        '2026-04-01',
        '广东省教育考试院',
        '2026年广东省普通专升本考试大纲要点：\n\n' +
        '【政治理论】\n考试范围涵盖马克思主义基本原理、毛泽东思想、习近平新时代中国特色社会主义思想等。\n题型：单选30题、多选10题、简答4题、论述2题。满分100分。\n\n' +
        '【英语】\n考试难度相当于大学英语四级水平。题型包括阅读理解、完形填空、翻译和写作。满分100分。\n\n' +
        '【高等数学】\n涵盖极限与连续、一元函数微积分、多元函数微积分、常微分方程等。满分100分。'
      ),
      PolicyService.createPolicy(
        'policy_004',
        '关于做好2026年专升本志愿填报工作的通知',
        '省招办就专升本志愿填报时间、流程及注意事项发布专项通知。',
        '广东',
        'notice',
        '2026-06-01',
        '广东省招生办公室',
        '各有关高校及考生：\n\n' +
        '2026年普通专升本志愿填报工作将于成绩公布后启动，现将有关事项通知如下：\n\n' +
        '一、填报时间：成绩公布后3个工作日内。\n\n' +
        '二、志愿设置：设置9个平行志愿，每个志愿可填报1所院校的1个专业。\n\n' +
        '三、投档原则：按照"分数优先、遵循志愿"原则进行投档。\n\n' +
        '四、注意事项：考生须在规定时间内完成填报，逾期不予受理。建议参考历年录取分数线合理填报。'
      )
    ];

    if (province === '') {
      return mockData;
    }
    return mockData.filter((p: PolicyInfo) => p.province === province || p.province === '全国');
  }

  // Mock 资格检测结果
  private static getMockQualificationResult(data: QualificationCheckData): QualificationResult {
    const result: QualificationResult = new QualificationResult();
    if (data.province === '' || data.specialty === '') {
      result.isQualified = false;
      result.message = '请填写完整的省份和专业信息后再进行检测。';
      result.suggestions = ['请选择所在省份', '请输入您的专科专业名称'];
      return result;
    }
    result.isQualified = true;
    result.message = `根据${data.province}省2026年专升本招生政策，您符合报考基本条件。` +
      `当前年级为${data.grade}，建议在报考前确认目标院校的具体要求。`;
    result.suggestions = [
      '确认目标院校是否接受跨专业报考',
      '提前准备政治理论和英语公共课复习',
      '关注目标院校官网发布的最新招生简章',
      '建议大三上学期开始系统备考'
    ];
    return result;
  }

  // 辅助创建 PolicyInfo 实例
  private static createPolicy(
    id: string, title: string, summary: string, province: string,
    category: string, publishDate: string, source: string, content: string
  ): PolicyInfo {
    const policy: PolicyInfo = new PolicyInfo();
    policy.id = id;
    policy.title = title;
    policy.summary = summary;
    policy.province = province;
    policy.category = category;
    policy.publishDate = publishDate;
    policy.source = source;
    policy.content = content;
    return policy;
  }
}

// 导出单例
export const policyService: PolicyService = new PolicyService();
