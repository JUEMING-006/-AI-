// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
import { ScoreInput, RecommendCollege, VolunteerPlan, SubjectScore } from '../models/VolunteerModel';
// [BACKEND] import { httpClient } from './HttpClient';
// [BACKEND] import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'VolunteerService';

// ── JSON → Model 映射 ──

function toRecommendCollege(d: Record<string, Object>): RecommendCollege {
  const c = new RecommendCollege();
  c.id = d['id'] as string;
  c.name = d['name'] as string;
  c.type = d['type'] as string;
  c.tier = d['tier'] as string;
  c.probability = d['probability'] as number;
  c.lastYearMinScore = d['lastYearMinScore'] as number;
  c.enrollCount = d['enrollCount'] as number;
  c.isSelected = d['isSelected'] as boolean;
  c.tuition = (d['tuition'] as number) ?? 0;
  c.major = (d['major'] as string) ?? '';
  c.city = (d['city'] as string) ?? '';
  return c;
}

function toVolunteerPlan(d: Record<string, Object>): VolunteerPlan {
  const plan = new VolunteerPlan();
  const recs = d['recommendations'] as Record<string, Object>[];
  plan.recommendations = recs.map((r: Record<string, Object>) => toRecommendCollege(r));
  plan.rushCount = d['rushCount'] as number;
  plan.stableCount = d['stableCount'] as number;
  plan.safeCount = d['safeCount'] as number;
  return plan;
}

// 将 ScoreInput 实例转为纯 JSON 对象（避免 @Trace 序列化问题）
function scoreInputToBody(scoreInput: ScoreInput): Record<string, Object> {
  const subjects: Record<string, Object>[] = scoreInput.subjects.map((s: SubjectScore) => {
    const obj: Record<string, Object> = {};
    obj['subject'] = s.subject;
    obj['score'] = s.score;
    obj['fullScore'] = s.fullScore;
    return obj;
  });
  const body: Record<string, Object> = {};
  body['subjects'] = subjects;
  body['totalScore'] = scoreInput.totalScore;
  body['province'] = scoreInput.province;
  return body;
}

@ObservedV2
export class VolunteerService {
  @Trace currentPlan: VolunteerPlan = new VolunteerPlan();
  @Trace currentScore: ScoreInput = new ScoreInput();
  @Trace isLoading: boolean = false;
  @Trace hasScore: boolean = false;

  /** POST /volunteer/match — 志愿匹配 */
  async matchVolunteer(scoreInput: ScoreInput): Promise<VolunteerPlan> {
    this.isLoading = true;
    hilog.info(DOMAIN, TAG, '[MOCK] matchVolunteer: totalScore=%{public}d, province=%{public}s',
      scoreInput.totalScore, scoreInput.province);
    try {
      // [BACKEND] const body = scoreInputToBody(scoreInput);
      // [BACKEND] const response = await httpClient.post('/volunteer/match', body);
      // [BACKEND] const plan = toVolunteerPlan(response.data);
      const plan = getMockVolunteerPlan(scoreInput.totalScore);
      this.currentPlan = plan;
      this.currentScore = scoreInput;
      this.hasScore = true;
      return plan;
    } finally {
      this.isLoading = false;
    }
  }

  /** GET /volunteer/recommend — 获取推荐列表 */
  async getRecommendations(totalScore: number, province: string): Promise<RecommendCollege[]> {
    hilog.info(DOMAIN, TAG, '[MOCK] getRecommendations: totalScore=%{public}d, province=%{public}s',
      totalScore, province);
    // [BACKEND] const response = await httpClient.get('/volunteer/recommend', {
    // [BACKEND]   params: { total_score: totalScore, province }
    // [BACKEND] });
    // [BACKEND] return rawData.map(d => toRecommendCollege(d));
    return getMockRecommendations(totalScore);
  }

  resetScore(): void {
    this.currentScore = new ScoreInput();
    this.currentPlan = new VolunteerPlan();
    this.hasScore = false;
  }
}

// ── mock 数据 ──

function getMockVolunteerPlan(totalScore: number): VolunteerPlan {
  const plan = new VolunteerPlan();
  plan.recommendations = getMockRecommendations(totalScore);
  plan.rushCount = 2;
  plan.stableCount = 3;
  plan.safeCount = 2;
  return plan;
}

function getMockRecommendations(totalScore: number): RecommendCollege[] {
  const list: RecommendCollege[] = [];
  const data: Array<[string, string, string, string, string, number, number, number, string]> = [
    // [id, name, type, tier, city, probability, lastYearMinScore, enrollCount, major]
    ['v_001', '华南师范大学', '公办', '冲', '广州', 35, totalScore + 15, 80, '计算机科学与技术'],
    ['v_002', '深圳技术大学', '公办', '冲', '深圳', 40, totalScore + 10, 60, '软件工程'],
    ['v_003', '广东技术师范大学', '公办', '稳', '广州', 65, totalScore - 5, 100, '计算机科学与技术'],
    ['v_004', '岭南师范学院', '公办', '稳', '湛江', 70, totalScore - 10, 50, '网络工程'],
    ['v_005', '韩山师范学院', '公办', '稳', '潮州', 75, totalScore - 15, 40, '信息安全'],
    ['v_006', '广东石油化工学院', '公办', '保', '茂名', 90, totalScore - 30, 45, '数据科学与大数据技术'],
    ['v_007', '广州软件学院', '民办', '保', '广州', 95, totalScore - 40, 70, '软件工程'],
  ];
  for (const item of data) {
    const c = new RecommendCollege();
    c.id = item[0];
    c.name = item[1];
    c.type = item[2];
    c.tier = item[3];
    c.city = item[4];
    c.probability = item[5];
    c.lastYearMinScore = item[6];
    c.enrollCount = item[7];
    c.major = item[8];
    c.isSelected = false;
    c.tuition = item[2] === '公办' ? 6000 : 18000;
    list.push(c);
  }
  return list;
}

export const volunteerService: VolunteerService = new VolunteerService();
