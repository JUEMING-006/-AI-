// [BACKEND] 后端调用已注释，当前使用前端 mock 数据
// import { httpClient } from './HttpClient';
// import type { AxiosResponse } from '@ohos/axios';
import { appStore } from '../stores/AppStore';
import { userStore } from '../stores/UserStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'AuthService';

// ── 请求/响应接口定义 ──

interface SendCodeRequest {
  phone: string;
}

interface VerifyCodeRequest {
  phone: string;
  code: string;
}

interface SendCodeResponse {
  success: boolean;
  code: string;
}

interface UserInfo {
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

interface AuthResponse {
  token: string;
  user: UserInfo;
}

class AuthService {
  /** POST /auth/send-code — 发送验证码，返回验证码明文（开发阶段） */
  async sendCode(phone: string): Promise<string> {
    hilog.info(DOMAIN, TAG, '[MOCK] sendCode: phone=%{public}s', phone);
    // [BACKEND] const body: SendCodeRequest = { phone: phone };
    // [BACKEND] const response: AxiosResponse<SendCodeResponse> = await httpClient.post('/auth/send-code', body);
    // [BACKEND] return response.data.code;
    return '1234'; // mock 验证码
  }

  /** POST /auth/verify-code — 验证码登录，成功后写入 appStore 和 userStore */
  async verifyCode(phone: string, code: string): Promise<void> {
    hilog.info(DOMAIN, TAG, '[MOCK] verifyCode: phone=%{public}s code=%{public}s', phone, code);
    // [BACKEND] const body: VerifyCodeRequest = { phone: phone, code: code };
    // [BACKEND] const response: AxiosResponse<AuthResponse> = await httpClient.post('/auth/verify-code', body);
    // [BACKEND] const data: AuthResponse = response.data;

    // mock 登录成功，写入 AppStore
    appStore.token = 'mock_token_' + Date.now();
    appStore.isLoggedIn = true;
    appStore.userId = 'mock_user_001';
    appStore.phone = phone;
    appStore.nickname = '觉明同学';

    // mock 用户资料，写入 UserStore
    userStore.province = '广东';
    userStore.specialty = '计算机应用技术';
    userStore.targetCollegeId = 'college_001';
    userStore.targetCollegeName = '华南师范大学';
    userStore.examDate = '2026-03-15';

    hilog.info(DOMAIN, TAG, '[MOCK] verifyCode success: userId=mock_user_001');
  }

  /** POST /auth/refresh — 刷新 token，成功后更新 appStore 和 userStore */
  async refreshToken(): Promise<boolean> {
    hilog.info(DOMAIN, TAG, '[MOCK] refreshToken');
    const token: string = appStore.token;
    if (token === '') {
      return false;
    }
    // [BACKEND] try {
    // [BACKEND]   const response: AxiosResponse<AuthResponse> = await httpClient.post(
    // [BACKEND]     `/auth/refresh?token=${encodeURIComponent(token)}`);
    // [BACKEND]   const data: AuthResponse = response.data;
    // [BACKEND]   appStore.token = data.token;
    // [BACKEND]   ... 同步 userStore
    // [BACKEND]   return true;
    // [BACKEND] } catch (e) { return false; }
    appStore.token = 'mock_token_refreshed_' + Date.now();
    return true;
  }

  /** 退出登录 — 清空 appStore 和 userStore 中的用户状态 */
  logout(): void {
    hilog.info(DOMAIN, TAG, 'logout');
    appStore.token = '';
    appStore.isLoggedIn = false;
    appStore.userId = '';
    appStore.phone = '';
    appStore.nickname = '';
    userStore.province = '';
    userStore.specialty = '';
    userStore.targetCollegeId = '';
    userStore.targetCollegeName = '';
    userStore.examDate = '';
  }
}

export const authService = new AuthService();
