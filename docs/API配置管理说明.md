# API 配置管理说明

## 📁 文件结构

```
entry/src/main/ets/common/
├── ApiConfig.ets           # 主配置文件（导入环境配置）
├── ApiConfig.example.ets   # 配置示例（提交到 Git）
├── ApiConfig.local.ets     # 本地开发配置（不提交）
└── ApiConfig.prod.ets      # 生产环境配置（不提交）
```

## 🔧 使用方法

### 1. 首次使用

如果你是第一次克隆项目，需要手动创建配置文件：

```bash
# 复制示例文件为本地配置
cp ApiConfig.example.ets ApiConfig.local.ets
cp ApiConfig.example.ets ApiConfig.prod.ets
```

### 2. 配置本地开发环境

编辑 `ApiConfig.local.ets`：

```typescript
export class ApiConfigEnv {
  static readonly BASE_URL: string = 'http://localhost:8000';  // 本地后端地址
  static readonly API_PREFIX: string = '/api/v1';
  static readonly TIMEOUT: number = 10000;
  static readonly DEBUG_MODE: boolean = true;
  static readonly USE_MOCK_DATA: boolean = true;  // 后端未完成时使用 Mock
  static readonly API_KEY: string = '';
}
```

### 3. 配置生产环境

编辑 `ApiConfig.prod.ets`：

```typescript
export class ApiConfigEnv {
  static readonly BASE_URL: string = 'https://api.yourdomain.com';  // 生产环境地址
  static readonly API_PREFIX: string = '/api/v1';
  static readonly TIMEOUT: number = 10000;
  static readonly DEBUG_MODE: boolean = false;
  static readonly USE_MOCK_DATA: boolean = false;  // 使用真实后端
  static readonly API_KEY: string = 'your-real-api-key';
}
```

### 4. 切换环境

在 `ApiConfig.ets` 中修改导入语句：

**开发环境：**
```typescript
import { ApiConfigEnv } from './ApiConfig.local';
```

**生产环境：**
```typescript
import { ApiConfigEnv } from './ApiConfig.prod';
```

## 🔐 安全性说明

### 已加入 .gitignore 的文件

以下文件**不会**提交到 Git 仓库，可以安全配置敏感信息：

- `ApiConfig.local.ets` - 本地开发配置
- `ApiConfig.prod.ets` - 生产环境配置
- `.env` / `.env.local` / `.env.production` - 环境变量文件

### 会提交到 Git 的文件

以下文件**会**提交到 Git 仓库：

- `ApiConfig.ets` - 主配置文件（不包含敏感信息）
- `ApiConfig.example.ets` - 配置示例（不包含真实配置）

## 🚀 在代码中使用

### 基本使用

```typescript
import { ApiConfig } from '../common/ApiConfig';

// 获取 API 基础地址
const baseUrl = ApiConfig.BASE_URL;

// 获取完整 API 地址
const fullUrl = ApiConfig.getFullUrl('/colleges');
// 结果: http://localhost:8000/api/v1/colleges

// 检查是否使用 Mock 数据
if (ApiConfig.USE_MOCK_DATA) {
  // 返回 Mock 数据
} else {
  // 调用真实 API
}

// 检查调试模式
if (ApiConfig.DEBUG_MODE) {
  console.log('Debug info:', data);
}
```

### 在 Service 中使用

```typescript
import { ApiConfig } from '../common/ApiConfig';
import { httpClient } from './HttpClient';

export class CollegeService {
  async getColleges(): Promise<CollegeInfo[]> {
    // 如果配置为使用 Mock 数据，则返回模拟数据
    if (ApiConfig.USE_MOCK_DATA) {
      return this.getMockColleges();
    }
    
    // 否则调用真实 API
    const response = await httpClient.get(ApiConfig.getFullUrl('/colleges'));
    return response.data;
  }
  
  private getMockColleges(): CollegeInfo[] {
    // Mock 数据逻辑
  }
}
```

## 📋 配置项说明

| 配置项 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `BASE_URL` | string | API 服务器基础地址 | `http://localhost:8000` |
| `API_PREFIX` | string | API 路径前缀 | `/api/v1` |
| `TIMEOUT` | number | 请求超时时间（毫秒） | `10000` |
| `DEBUG_MODE` | boolean | 是否启用调试模式 | `true` |
| `USE_MOCK_DATA` | boolean | 是否使用 Mock 数据 | `true` |
| `API_KEY` | string | API 密钥（可选） | `your-api-key` |

## 🔄 环境切换流程

### 开发 → 测试 → 生产

1. **开发阶段**
   - 使用 `ApiConfig.local.ets`
   - `USE_MOCK_DATA = true`（后端未完成）
   - `DEBUG_MODE = true`

2. **联调测试**
   - 使用 `ApiConfig.local.ets`
   - `USE_MOCK_DATA = false`（连接测试后端）
   - `DEBUG_MODE = true`

3. **生产部署**
   - 修改 `ApiConfig.ets` 导入 `ApiConfig.prod`
   - `USE_MOCK_DATA = false`
   - `DEBUG_MODE = false`
   - 配置真实的生产环境地址和密钥

## ⚠️ 注意事项

1. **首次克隆项目后**，必须创建 `ApiConfig.local.ets` 和 `ApiConfig.prod.ets` 文件
2. **不要**将真实的 API 地址、密钥等信息提交到 Git
3. **不要**修改 `ApiConfig.example.ets` 为真实配置，它只是示例
4. 部署到生产环境前，确保 `USE_MOCK_DATA = false`
5. 生产环境建议关闭 `DEBUG_MODE`

## 🛠️ 扩展配置

如果需要添加新的配置项：

1. 在 `ApiConfigEnv` 类中添加新配置项
2. 在 `ApiConfig` 类中导出新配置项
3. 更新 `ApiConfig.example.ets` 示例文件

示例：

```typescript
// ApiConfig.local.ets
export class ApiConfigEnv {
  // ... 现有配置
  
  // 新增配置项
  static readonly UPLOAD_URL: string = 'http://localhost:8000/upload';
  static readonly MAX_FILE_SIZE: number = 10 * 1024 * 1024; // 10MB
}

// ApiConfig.ets
export class ApiConfig {
  // ... 现有配置
  
  static readonly UPLOAD_URL: string = ApiConfigEnv.UPLOAD_URL;
  static readonly MAX_FILE_SIZE: number = ApiConfigEnv.MAX_FILE_SIZE;
}
```
