/**
 * API 配置示例文件
 * 
 * 使用说明：
 * 1. 复制此文件并重命名为 ApiConfig.local.ets（本地开发）或 ApiConfig.prod.ets（生产环境）
 * 2. 修改对应的配置参数
 * 3. 在 build-profile.json5 中配置环境变量决定使用哪个配置
 * 
 * 注意：
 * - ApiConfig.local.ets 和 ApiConfig.prod.ets 已加入 .gitignore，不会提交到远程仓库
 * - 请勿将真实的 API 地址、密钥等信息提交到代码仓库
 */

export class ApiConfigEnv {
  // API 基础地址
  static readonly BASE_URL: string = 'http://localhost:8000';
  
  // API 路径前缀
  static readonly API_PREFIX: string = '/api/v1';
  
  // 请求超时时间（毫秒）
  static readonly TIMEOUT: number = 10000;
  
  // 是否启用调试模式
  static readonly DEBUG_MODE: boolean = true;
  
  // 是否启用 Mock 数据（后端未完成时可设置为 true）
  static readonly USE_MOCK_DATA: boolean = true;
  
  // API 密钥（如果需要）
  static readonly API_KEY: string = '';
  
  // 其他配置项可根据需要添加
  // static readonly UPLOAD_URL: string = '';
  // static readonly WEBSOCKET_URL: string = '';
}
