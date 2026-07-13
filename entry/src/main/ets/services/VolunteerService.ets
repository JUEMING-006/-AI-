import { ScoreInput, RecommendCollege, VolunteerPlan } from '../models/VolunteerModel';
import { httpClient } from './HttpClient';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'VolunteerService';

// Mock 院校数据池
interface CollegeTemplate {
  name: string;
  type: string;
  baseScore: number;
  enrollCount: number;
}

const RUSH_COLLEGES: CollegeTemplate[] = [
  { name: '华南师范大学', type: '公办', baseScore: 385, enrollCount: 120 },
  { name: '广东工业大学', type: '公办', baseScore: 378, enrollCount: 95 },
  { name: '广州大学', type: '公办', baseScore: 372, enrollCount: 110 },
  { name: '深圳技术大学', type: '公办', baseScore: 380, enrollCount: 80 },
  { name: '东莞理工学院', type: '公办', baseScore: 368, enrollCount: 90 }
];

const STABLE_COLLEGES: CollegeTemplate[] = [
  { name: '广东技术师范大学', type: '公办', baseScore: 355, enrollCount: 150 },
  { name: '仲恺农业工程学院', type: '公办', baseScore: 348, enrollCount: 130 },
  { name: '五邑大学', type: '公办', baseScore: 342, enrollCount: 100 },
  { name: '广东石油化工学院', type: '公办', baseScore: 338, enrollCount: 120 },
  { name: '岭南师范学院', type: '公办', baseScore: 345, enrollCount: 140 },
  { name: '韶关学院', type: '公办', baseScore: 335, enrollCount: 110 },
  { name: '嘉应学院', type: '公办', baseScore: 330, enrollCount: 95 }
];

const SAFE_COLLEGES: CollegeTemplate[] = [
  { name: '广州城市理工学院', type: '民办', baseScore: 310, enrollCount: 200 },
  { name: '广东白云学院', type: '民办', baseScore: 305, enrollCount: 180 },
  { name: '广州商学院', type: '民办', baseScore: 298, enrollCount: 160 },
  { name: '广东科技学院', type: '民办', baseScore: 295, enrollCount: 170 },
  { name: '广州工商学院', type: '民办', baseScore: 290, enrollCount: 150 }
];

function buildCollege(template: CollegeTemplate, tier: string, probability: number, index: number): RecommendCollege {
  const college: RecommendCollege = new RecommendCollege();
  college.id = `college_${tier}_${index}`;
  college.name = template.name;
  college.type = template.type;
  college.tier = tier;
  college.probability = probability;
  college.lastYearMinScore = template.baseScore;
  college.enrollCount = template.enrollCount;
  college.isSelected = false;
  return college;
}

function generateMockPlan(totalScore: number): VolunteerPlan {
  const plan: VolunteerPlan = new VolunteerPlan();
  const recommendations: RecommendCollege[] = [];

  // 冲刺 3 所（录取概率 20-40%）
  const rushIndices: number[] = [0, 1, 2];
  for (const i of rushIndices) {
    const template: CollegeTemplate = RUSH_COLLEGES[i];
    const prob: number = Math.max(15, Math.min(45, 50 - (template.baseScore - totalScore) * 2));
    recommendations.push(buildCollege(template, '冲刺', prob, i));
  }

  // 稳妥 5 所（录取概率 50-75%）
  const stableIndices: number[] = [0, 1, 2, 3, 4];
  for (const i of stableIndices) {
    const template: CollegeTemplate = STABLE_COLLEGES[i];
    const prob: number = Math.max(45, Math.min(80, 70 + (totalScore - template.baseScore)));
    recommendations.push(buildCollege(template, '稳妥', prob, i));
  }

  // 保底 3 所（录取概率 80-98%）
  const safeIndices: number[] = [0, 1, 2];
  for (const i of safeIndices) {
    const template: CollegeTemplate = SAFE_COLLEGES[i];
    const prob: number = Math.max(78, Math.min(98, 85 + (totalScore - template.baseScore)));
    recommendations.push(buildCollege(template, '保底', prob, i));
  }

  plan.recommendations = recommendations;
  plan.rushCount = 3;
  plan.stableCount = 5;
  plan.safeCount = 3;
  return plan;
}

@ObservedV2
export class VolunteerService {
  @Trace currentPlan: VolunteerPlan = new VolunteerPlan();
  @Trace currentScore: ScoreInput = new ScoreInput();
  @Trace isLoading: boolean = false;
  @Trace hasScore: boolean = false;

  // POST /api/v1/volunteer/match
  matchVolunteer(scoreInput: ScoreInput): Promise<VolunteerPlan> {
    this.isLoading = true;
    hilog.info(DOMAIN, TAG, 'matchVolunteer: totalScore=%{public}d, province=%{public}s',
      scoreInput.totalScore, scoreInput.province);

    // TODO: 接入真实 FastAPI 接口
    // return httpClient.post('/volunteer/match', scoreInput).then(...)

    return new Promise<VolunteerPlan>((resolve: (value: VolunteerPlan) => void) => {
      setTimeout(() => {
        const plan: VolunteerPlan = generateMockPlan(scoreInput.totalScore);
        this.currentPlan = plan;
        this.currentScore = scoreInput;
        this.hasScore = true;
        this.isLoading = false;
        resolve(plan);
      }, 800);
    });
  }

  // GET /api/v1/volunteer/recommend
  getRecommendations(totalScore: number, province: string): Promise<RecommendCollege[]> {
    hilog.info(DOMAIN, TAG, 'getRecommendations: totalScore=%{public}d, province=%{public}s',
      totalScore, province);

    // TODO: 接入真实 FastAPI 接口
    // return httpClient.get(`/volunteer/recommend?totalScore=${totalScore}&province=${province}`).then(...)

    return new Promise<RecommendCollege[]>((resolve: (value: RecommendCollege[]) => void) => {
      setTimeout(() => {
        const plan: VolunteerPlan = generateMockPlan(totalScore);
        resolve(plan.recommendations);
      }, 500);
    });
  }

  resetScore(): void {
    this.currentScore = new ScoreInput();
    this.currentPlan = new VolunteerPlan();
    this.hasScore = false;
  }
}

export const volunteerService: VolunteerService = new VolunteerService();
