import { StudyPhase, DailyTask, StudyProgress, GapAnalysis } from '../models/StudyPlanModel';
import { httpClient } from './HttpClient';
import type { AxiosResponse } from '@ohos/axios';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'StudyService';

// ── 请求接口定义 ──
interface GeneratePlanRequest {
  targetCollegeId: string;
}

// ── JSON → Model 映射 ──

function toStudyPhase(d: Record<string, Object>): StudyPhase {
  const p = new StudyPhase();
  p.name = d['name'] as string;
  p.startDate = d['startDate'] as string;
  p.endDate = d['endDate'] as string;
  p.progress = d['progress'] as number;
  p.description = d['description'] as string;
  return p;
}

function toDailyTask(d: Record<string, Object>): DailyTask {
  const t = new DailyTask();
  t.id = d['id'] as string;
  t.title = d['title'] as string;
  t.subject = d['subject'] as string;
  t.estimatedMinutes = d['estimatedMinutes'] as number;
  t.isCompleted = d['isCompleted'] as boolean;
  t.completedAt = d['completedAt'] as string;
  return t;
}

function toStudyProgress(d: Record<string, Object>): StudyProgress {
  const p = new StudyProgress();
  p.weeklyCompletionRates = d['weeklyCompletionRates'] as number[];
  p.totalTasks = d['totalTasks'] as number;
  p.completedTasks = d['completedTasks'] as number;
  p.currentStreak = d['currentStreak'] as number;
  p.weekDates = d['weekDates'] as string[];
  return p;
}

function toGapAnalysis(d: Record<string, Object>): GapAnalysis {
  const g = new GapAnalysis();
  g.targetScore = d['targetScore'] as number;
  g.currentEstimate = d['currentEstimate'] as number;
  g.gap = d['gap'] as number;
  g.targetCollegeName = d['targetCollegeName'] as string;
  g.daysRemaining = d['daysRemaining'] as number;
  return g;
}

/**
 * 学习计划服务 — 调用 FastAPI 后端
 */
export class StudyService {

  /** POST /study-plan/generate — 生成学习计划 */
  async generatePlan(targetCollegeId: string): Promise<StudyPhase[]> {
    hilog.info(DOMAIN, TAG, 'generatePlan: targetCollegeId=%{public}s', targetCollegeId);
    const requestBody: GeneratePlanRequest = { targetCollegeId: targetCollegeId };
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.post('/study-plan/generate', requestBody);
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toStudyPhase(d));
  }

  /** GET /study-plan/daily-tasks?date= — 获取每日任务 */
  async getDailyTasks(date: string): Promise<DailyTask[]> {
    hilog.info(DOMAIN, TAG, 'getDailyTasks: date=%{public}s', date);
    const response: AxiosResponse<Record<string, Object>[]> = await httpClient.get('/study-plan/daily-tasks', { params: { date: date } });
    const rawData: Record<string, Object>[] = response.data;
    return rawData.map((d: Record<string, Object>) => toDailyTask(d));
  }

  /** PUT /study-plan/tasks/{id}/complete — 完成任务 */
  async completeTask(taskId: string): Promise<void> {
    hilog.info(DOMAIN, TAG, 'completeTask: taskId=%{public}s', taskId);
    await httpClient.put(`/study-plan/tasks/${taskId}/complete`);
  }

  /** GET /study-plan/progress — 获取学习进度 */
  async getProgress(): Promise<StudyProgress> {
    hilog.info(DOMAIN, TAG, 'getProgress');
    const response: AxiosResponse<Record<string, Object>> = await httpClient.get('/study-plan/progress');
    return toStudyProgress(response.data);
  }

  /** GET /study-plan/gap-analysis — 差距分析 */
  async getGapAnalysis(): Promise<GapAnalysis> {
    hilog.info(DOMAIN, TAG, 'getGapAnalysis');
    const response: AxiosResponse<Record<string, Object>> = await httpClient.get('/study-plan/gap-analysis');
    return toGapAnalysis(response.data);
  }
}

export const studyService: StudyService = new StudyService();
