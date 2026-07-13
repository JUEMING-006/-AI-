import axios from '@ohos/axios';
import type { AxiosInstance, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { ApiConfig } from '../common/ApiConfig';
import { appStore } from '../stores/AppStore';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN: number = 0x0001;
const TAG: string = 'HttpClient';

// 创建 axios 实例
const instance: AxiosInstance = axios.create({
  baseURL: `${ApiConfig.BASE_URL}${ApiConfig.API_PREFIX}`,
  timeout: ApiConfig.TIMEOUT
});

// 请求拦截器：自动添加 token header
instance.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token: string = appStore.token;
    if (token !== '') {
      config.headers['Authorization'] = `Bearer ${token}`;
    }
    hilog.info(DOMAIN, TAG, 'Request: %{public}s %{public}s', config.method ?? 'GET', config.url ?? '');
    return config;
  },
  (error: Error) => {
    hilog.error(DOMAIN, TAG, 'Request error: %{public}s', error.message);
    return Promise.reject(error);
  }
);

// 响应拦截器：统一错误处理
instance.interceptors.response.use(
  (response: AxiosResponse) => {
    hilog.info(DOMAIN, TAG, 'Response status: %{public}d', response.status);
    return response;
  },
  (error: Error) => {
    hilog.error(DOMAIN, TAG, 'Response error: %{public}s', error.message);
    return Promise.reject(error);
  }
);

// 导出单例 httpClient
export const httpClient: AxiosInstance = instance;
