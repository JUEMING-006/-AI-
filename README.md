# TopUpAI - 鸿蒙升本助手

一款基于 HarmonyOS NEXT 的 AI 智能助手应用，专注于专升本升学场景，提供 AI 对话、院校查询、志愿填报、学习规划等一站式服务。

## 功能特性

- **AI 智能对话** — 基于大语言模型的升学咨询对话，支持多轮会话、模型切换
- **院校查询** — 快速检索院校信息，了解招生详情
- **志愿填报** — 智能志愿填报辅助，科学规划升学路径
- **学习规划** — 个性化学习建议与备考指导
- **液态玻璃 UI** — HarmonyOS 原生液态玻璃视觉风格，沉浸光感体验

## 技术栈

| 层面 | 技术 |
|------|------|
| 平台 | HarmonyOS NEXT (API 23) |
| 语言 | ArkTS / ArkUI |
| 状态管理 | V2 装饰器（@ComponentV2 / @ObservedV2 / @Provider / @Consumer） |
| 路由 | Navigation + NavPathStack |
| 网络请求 | @ohos/axios |
| 后端 | FastAPI (Python) |
| 构建工具 | hvigor |

## 项目结构

```
TopUpAI/
├── AppScope/                  # 应用级配置
├── entry/src/main/ets/
│   ├── common/                # 公共常量、工具类
│   ├── components/            # 通用 UI 组件
│   │   └── chat/              # 聊天相关组件
│   ├── models/                # 数据模型
│   ├── pages/                 # 页面入口
│   ├── router/                # 路由配置
│   ├── services/              # 网络服务层
│   ├── stores/                # 全局状态管理
│   └── views/                 # 业务视图
│       ├── auth/              # 登录认证
│       ├── chat/              # AI 对话页
│       ├── college/           # 院校查询
│       ├── home/              # 首页
│       ├── setting/           # 设置页
│       ├── study/             # 学习模块
│       └── volunteer/         # 志愿填报
└── docs/                      # 设计文档
```

## 开发环境

- **DevEco Studio** — 最新版本（支持 HarmonyOS NEXT）
- **SDK** — HarmonyOS API 23
- **Node.js** — hvigor 构建依赖

## 运行方式

1. 使用 DevEco Studio 打开项目
2. 等待依赖下载完成（ohpm install）
3. 连接模拟器或真机
4. 点击 Run 运行应用

## 后端服务

后端基于 FastAPI 搭建，提供以下核心接口：

- 验证码登录（免注册）
- AI 对话（流式响应）
- 院校数据查询
- 志愿填报辅助

> 详细接口文档见 `docs/API配置管理说明.md`

## 许可证

[LICENSE](LICENSE)
