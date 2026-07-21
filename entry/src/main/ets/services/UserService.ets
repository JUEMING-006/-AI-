// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
// import { httpClient } from './HttpClient';
// import type { AxiosResponse } from '@ohos/axios';
import { userStore } from '../stores/UserStore';
import { appStore } from '../stores/AppStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'UserService';

// ── 请求/响应接口定义 ──

interface UserProfileData {
  userId: string;
  phone: string;
  nickname: string;
  avatar: string;
  province: string;
  specialty: string;
  targetCollegeId: string;
  targetCollegeName: string;
  examDate: string;
}

interface UpdateProfileRequest {
  nickname?: string;
  province?: string;
  specialty?: string;
  targetCollegeId?: string;
  targetCollegeName?: string;
  examDate?: string;
}

/**
 * 用户服务 — 调用 FastAPI 后端 /user 接口
 *
 * 对应后端:
 *   GET  /api/v1/user/profile    — 获取用户资料
 *   PUT  /api/v1/user/profile    — 更新用户资料
 */
export class UserService {

  /** GET /user/profile — 获取用户资料，同步到 UserStore 和 AppStore */
  async fetchProfile(): Promise<void> {
    hilog.info(DOMAIN, TAG, '[MOCK] fetchProfile');
    // [BACKEND] const response: AxiosResponse<UserProfileData> = await httpClient.get('/user/profile');
    // [BACKEND] const data: UserProfileData = response.data;
    // [BACKEND] appStore.userId = data.userId; ...
    // mock：保持本地 Store 现有数据不变，仅补全默认值
    if (appStore.nickname === '') {
      appStore.nickname = '觉明同学';
    }
    if (userStore.province === '') {
      userStore.province = '广东';
    }
    if (userStore.specialty === '') {
      userStore.specialty = '计算机应用技术';
    }
    if (userStore.targetCollegeName === '') {
      userStore.targetCollegeName = '华南师范大学';
    }
    if (userStore.examDate === '') {
      userStore.examDate = '2026-03-15';
    }
    hilog.info(DOMAIN, TAG, '[MOCK] fetchProfile success');
  }

  /** PUT /user/profile — 更新用户资料，从 UserStore 读取数据发送 */
  async updateProfile(): Promise<void> {
    hilog.info(DOMAIN, TAG, '[MOCK] updateProfile');
    // [BACKEND] const body: UpdateProfileRequest = { ... };
    // [BACKEND] const response: AxiosResponse<UserProfileData> = await httpClient.put('/user/profile', body);
    // [BACKEND] const data: UserProfileData = response.data;
    // [BACKEND] appStore.nickname = data.nickname; ...
    // mock：不做任何事，本地 Store 已由 UI 直接修改
    hilog.info(DOMAIN, TAG, '[MOCK] updateProfile success (local only)');
  }
}

export const userService: UserService = new UserService();
