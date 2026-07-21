// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
import { PolicyInfo, QualificationResult, QualificationCheckData } from '../models/PolicyModel';
// [BACKEND] import { httpClient } from './HttpClient';
// [BACKEND] import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'PolicyService';

// ── JSON → Model 映射 ──

function toPolicyInfo(d: Record<string, Object>): PolicyInfo {
  const p = new PolicyInfo();
  p.id = d['id'] as string;
  p.title = d['title'] as string;
  p.summary = d['summary'] as string;
  p.province = d['province'] as string;
  p.category = d['category'] as string;
  p.publishDate = d['publishDate'] as string;
  p.content = d['content'] as string;
  p.source = d['source'] as string;
  return p;
}

function toQualificationResult(d: Record<string, Object>): QualificationResult {
  const r = new QualificationResult();
  r.isQualified = d['isQualified'] as boolean;
  r.message = d['message'] as string;
  r.suggestions = d['suggestions'] as string[];
  return r;
}

/**
 * 政策服务 — 调用 FastAPI 后端
 */
export class PolicyService {

  /** GET /policies?province= — 获取政策列表 */
  async getPolicies(province: string): Promise<PolicyInfo[]> {
    hilog.info(DOMAIN, TAG, '[MOCK] getPolicies: province=%{public}s', province);
    // [BACKEND] const response = await httpClient.get('/policies', { params: { province } });
    // [BACKEND] return rawData.map(d => toPolicyInfo(d));
    return getMockPolicies();
  }

  /** GET /policies/{id} — 获取政策详情 */
  async getPolicyDetail(id: string): Promise<PolicyInfo> {
    hilog.info(DOMAIN, TAG, '[MOCK] getPolicyDetail: id=%{public}s', id);
    // [BACKEND] const response = await httpClient.get(`/policies/${id}`);
    // [BACKEND] return toPolicyInfo(response.data);
    const list: PolicyInfo[] = getMockPolicies();
    for (const p of list) {
      if (p.id === id) {
        return p;
      }
    }
    return list[0];
  }

  /** POST /qualification/check — 报考资格检测 */
  async checkQualification(data: QualificationCheckData): Promise<QualificationResult> {
    hilog.info(DOMAIN, TAG, '[MOCK] checkQualification: province=%{public}s specialty=%{public}s',
      data.province, data.specialty);
    // [BACKEND] const response = await httpClient.post('/qualification/check', data);
    // [BACKEND] return toQualificationResult(response.data);
    const r = new QualificationResult();
    r.isQualified = true;
    r.message = '根据你提供的信息，你符合' + data.province + '省专升本报考条件。你的专科专业「' + data.specialty + '」可以报考对应的本科专业。';
    r.suggestions = [
      '建议提前关注目标院校的招生简章',
      '准备好专科成绩单和学籍证明',
      '关注省教育考试院官网获取最新政策',
      '合理安排复习时间，重点突破公共课'
    ];
    return r;
  }
}

// ── mock 数据 ──

function getMockPolicies(): PolicyInfo[] {
  const list: PolicyInfo[] = [];
  const data: Array<[string, string, string, string, string, string, string, string]> = [
    [
      'policy_001',
      '2026年广东省普通专升本招生工作通知',
      '广东省教育考试院发布2026年普通专升本招生工作通知，明确了报名时间、考试科目和录取规则。',
      '广东', 'notice', '2026-01-15',
      '一、报名时间\n2026年广东省普通专升本考试报名时间为3月1日至3月15日。\n\n二、考试科目\n考试科目分为公共课和专业课两类。公共课包括英语和政治，专业课根据报考专业确定。\n\n三、录取规则\n按照“分数优先，遵循志愿”的原则进行投档录取。',
      '广东省教育考试院'
    ],
    [
      'policy_002',
      '广东省专升本考试大纲（2026版）',
      '2026年广东省专升本考试大纲已发布，各科目考试范围和题型均有调整。',
      '广东', 'outline', '2026-01-10',
      '一、英语科目\n考试范围：词汇与语法结构、阅读理解、完形填空、翻译、写作。\n题型：选择题+主观题。\n\n二、政治科目\n考试范围：马克思主义基本原理概论、毛泽东思想和中国特色社会主义理论体系概论。\n\n三、专业课\n各专业考试大纲详见附件。',
      '广东省教育考试院'
    ],
    [
      'policy_003',
      '关于做好2026年普通专升本跨省招生工作的通知',
      '教育部发布通知，规范2026年普通专升本跨省招生工作，保障考生权益。',
      '全国', 'policy', '2026-01-08',
      '各省、自治区、直辖市教育厅：\n\n为做好2026年普通专升本跨省招生工作，现就有关事项通知如下：\n\n一、严格规范招生计划\n二、加强学籍管理\n三、保障考生权益\n四、强化监督检查',
      '中华人民共和国教育部'
    ],
    [
      'policy_004',
      '广东省2026年专升本免试政策解读',
      '广东省2026年专升本免试入学政策发布，符合条件的考生可申请免试入学。',
      '广东', 'policy', '2026-01-05',
      '免试条件：\n1. 退役大学生士兵\n2. 获得国家级职业技能大赛一等奖\n3. 获得省级以上表彰的优秀学生\n\n申请流程：\n1. 在报名系统中提交免试申请\n2. 上传相关证明材料\n3. 等待审核结果',
      '广东省教育厅'
    ],
    [
      'policy_005',
      '2026年专升本加分政策公布',
      '广东省2026年专升本加分政策公布，最高可加20分。',
      '广东', 'notice', '2026-01-03',
      '加分项目：\n1. 少数民族考生：加5分\n2. 退役士兵：加10分\n3. 获得省级以上奖励：加10-20分\n\n注意：加分项目不累计，取最高分值。',
      '广东省教育考试院'
    ],
  ];
  for (const item of data) {
    const p = new PolicyInfo();
    p.id = item[0];
    p.title = item[1];
    p.summary = item[2];
    p.province = item[3];
    p.category = item[4];
    p.publishDate = item[5];
    p.content = item[6];
    p.source = item[7];
    list.push(p);
  }
  return list;
}

// 导出单例
export const policyService: PolicyService = new PolicyService();
