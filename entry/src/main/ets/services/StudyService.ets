// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
import { StudyPhase, DailyTask, StudyProgress, GapAnalysis } from '../models/StudyPlanModel';
// [BACKEND] import { httpClient } from './HttpClient';
// [BACKEND] import type { AxiosResponse } from '@ohos/axios';
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
    hilog.info(DOMAIN, TAG, '[MOCK] generatePlan: targetCollegeId=%{public}s', targetCollegeId);
    // [BACKEND] const response = await httpClient.post('/study-plan/generate', { targetCollegeId });
    // [BACKEND] return rawData.map(d => toStudyPhase(d));
    return getMockStudyPhases();
  }

  /** GET /study-plan/daily-tasks?date= — 获取每日任务 */
  async getDailyTasks(date: string): Promise<DailyTask[]> {
    hilog.info(DOMAIN, TAG, '[MOCK] getDailyTasks: date=%{public}s', date);
    // [BACKEND] const response = await httpClient.get('/study-plan/daily-tasks', { params: { date } });
    // [BACKEND] return rawData.map(d => toDailyTask(d));
    return getMockDailyTasks();
  }

  /** PUT /study-plan/tasks/{id}/complete — 完成任务 */
  async completeTask(taskId: string): Promise<void> {
    hilog.info(DOMAIN, TAG, '[MOCK] completeTask: taskId=%{public}s', taskId);
    // [BACKEND] await httpClient.put(`/study-plan/tasks/${taskId}/complete`);
    // mock：不做任何事
  }

  /** GET /study-plan/progress — 获取学习进度 */
  async getProgress(): Promise<StudyProgress> {
    hilog.info(DOMAIN, TAG, '[MOCK] getProgress');
    // [BACKEND] const response = await httpClient.get('/study-plan/progress');
    // [BACKEND] return toStudyProgress(response.data);
    const p = new StudyProgress();
    p.weeklyCompletionRates = [0.8, 0.6, 0.9, 0.7, 0.85, 0.95, 0.75];
    p.totalTasks = 120;
    p.completedTasks = 85;
    p.currentStreak = 7;
    p.weekDates = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return p;
  }

  /** GET /study-plan/gap-analysis — 差距分析 */
  async getGapAnalysis(): Promise<GapAnalysis> {
    hilog.info(DOMAIN, TAG, '[MOCK] getGapAnalysis');
    // [BACKEND] const response = await httpClient.get('/study-plan/gap-analysis');
    // [BACKEND] return toGapAnalysis(response.data);
    const g = new GapAnalysis();
    g.targetScore = 250;
    g.currentEstimate = 210;
    g.gap = 40;
    g.targetCollegeName = '华南师范大学';
    g.daysRemaining = 60;
    return g;
  }
}

// ── mock 数据 ──

function getMockStudyPhases(): StudyPhase[] {
  const phases: StudyPhase[] = [];
  const data: Array<[string, string, string, number, string]> = [
    ['基础巩固期', '2026-01-01', '2026-02-28', 100, '系统学习各科基础知识，梳理知识框架，配合教材和网课打好基础。'],
    ['强化提升期', '2026-03-01', '2026-04-30', 65, '专题训练，突破重难点，开始做历年真题，总结命题规律。'],
    ['冲刺阶段', '2026-05-01', '2026-06-15', 20, '查漏补缺，重点复习薄弱环节，高频模拟，训练答题速度和心态。'],
  ];
  for (const item of data) {
    const p = new StudyPhase();
    p.name = item[0];
    p.startDate = item[1];
    p.endDate = item[2];
    p.progress = item[3];
    p.description = item[4];
    phases.push(p);
  }
  return phases;
}

function getMockDailyTasks(): DailyTask[] {
  const tasks: DailyTask[] = [];
  const data: Array<[string, string, string, number, boolean]> = [
    ['task_001', '英语阅读理解练习', '英语', 45, true],
    ['task_002', '政治马原章节复习', '政治', 60, true],
    ['task_003', '计算机数据结构学习', '专业课', 90, false],
    ['task_004', '英语完形填空专项', '英语', 30, false],
    ['task_005', '政治毛概知识点梳理', '政治', 45, false],
  ];
  for (const item of data) {
    const t = new DailyTask();
    t.id = item[0];
    t.title = item[1];
    t.subject = item[2];
    t.estimatedMinutes = item[3];
    t.isCompleted = item[4];
    t.completedAt = item[4] ? '2026-07-19T10:00:00' : '';
    tasks.push(t);
  }
  return tasks;
}

export const studyService: StudyService = new StudyService();
