import { StudyPhase, DailyTask, StudyProgress, GapAnalysis } from '../models/StudyPlanModel';
import { userStore } from '../stores/UserStore';

// Mock 数据构建器
function buildMockPhases(): StudyPhase[] {
  const phase1: StudyPhase = new StudyPhase();
  phase1.name = '基础阶段';
  phase1.startDate = '2026-03-01';
  phase1.endDate = '2026-05-31';
  phase1.progress = 78;
  phase1.description = '系统梳理各科基础知识，建立完整知识框架';

  const phase2: StudyPhase = new StudyPhase();
  phase2.name = '强化阶段';
  phase2.startDate = '2026-06-01';
  phase2.endDate = '2026-07-31';
  phase2.progress = 35;
  phase2.description = '针对薄弱点专项突破，大量刷题巩固';

  const phase3: StudyPhase = new StudyPhase();
  phase3.name = '冲刺阶段';
  phase3.startDate = '2026-08-01';
  phase3.endDate = '2026-08-25';
  phase3.progress = 0;
  phase3.description = '全真模拟演练，查缺补漏提升应试能力';

  return [phase1, phase2, phase3];
}

function buildMockTasks(): DailyTask[] {
  const tasks: DailyTask[] = [
    buildTask('task_001', '背诵英语高频词汇 50 个', '英语', 30, true, '2026-07-07 08:15'),
    buildTask('task_002', '完成英语阅读理解 2 篇', '英语', 45, false, ''),
    buildTask('task_003', '高数极限与连续章节练习', '高等数学', 60, false, ''),
    buildTask('task_004', '复习政治马原核心概念', '政治', 40, true, '2026-07-07 10:30'),
    buildTask('task_005', '政治毛中特时间线整理', '政治', 35, false, ''),
    buildTask('task_006', '英语语法专项：虚拟语气', '英语', 30, false, ''),
    buildTask('task_007', '高数导数应用题 10 道', '高等数学', 50, false, ''),
    buildTask('task_008', '计算机基础：数据结构复习', '计算机', 40, false, ''),
  ];
  return tasks;
}

function buildTask(id: string, title: string, subject: string, minutes: number,
  completed: boolean, completedAt: string): DailyTask {
  const task: DailyTask = new DailyTask();
  task.id = id;
  task.title = title;
  task.subject = subject;
  task.estimatedMinutes = minutes;
  task.isCompleted = completed;
  task.completedAt = completedAt;
  return task;
}

function buildMockProgress(): StudyProgress {
  const progress: StudyProgress = new StudyProgress();
  progress.weeklyCompletionRates = [85, 72, 90, 65, 80, 95, 60];
  progress.totalTasks = 56;
  progress.completedTasks = 41;
  progress.currentStreak = 12;
  progress.weekDates = ['7/1', '7/2', '7/3', '7/4', '7/5', '7/6', '7/7'];
  return progress;
}

function buildMockGapAnalysis(): GapAnalysis {
  const gap: GapAnalysis = new GapAnalysis();
  gap.targetScore = 320;
  gap.currentEstimate = 268;
  gap.gap = 52;
  gap.targetCollegeName = userStore.targetCollegeName !== '' ? userStore.targetCollegeName : '广东技术师范大学';
  gap.daysRemaining = 49;
  return gap;
}

export class StudyService {
  // POST /api/v1/study-plan/generate
  async generatePlan(targetCollegeId: string): Promise<StudyPhase[]> {
    // TODO: await httpClient.post('/study-plan/generate', { targetCollegeId })
    return buildMockPhases();
  }

  // GET /api/v1/study-plan/daily-tasks?date=YYYY-MM-DD
  async getDailyTasks(date: string): Promise<DailyTask[]> {
    // TODO: await httpClient.get(`/study-plan/daily-tasks?date=${date}`)
    return buildMockTasks();
  }

  // PUT /api/v1/study-plan/tasks/{id}/complete
  async completeTask(taskId: string): Promise<void> {
    // TODO: await httpClient.put(`/study-plan/tasks/${taskId}/complete`)
    return Promise.resolve();
  }

  // GET /api/v1/study-plan/progress
  async getProgress(): Promise<StudyProgress> {
    // TODO: await httpClient.get('/study-plan/progress')
    return buildMockProgress();
  }

  // GET /api/v1/study-plan/gap-analysis (mock)
  async getGapAnalysis(): Promise<GapAnalysis> {
    // TODO: await httpClient.get('/study-plan/gap-analysis')
    return buildMockGapAnalysis();
  }
}

export const studyService: StudyService = new StudyService();
