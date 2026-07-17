// API 基础配置，后端为 Python FastAPI
export class ApiConfig {
  static readonly BASE_URL: string = 'http://192.168.1.102:8000';
  static readonly API_PREFIX: string = '/api/v1';
  static readonly TIMEOUT: number = 10000;
}
