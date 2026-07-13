# TopUpAI - 专升本AI助手

> 一款帮助专科学生备考专升本的智能辅助应用

## 🚀 快速开始

### 首次使用必读

**克隆项目后，请先配置 API 环境文件：**

```bash
# 创建本地配置文件
cp entry/src/main/ets/common/ApiConfig.example.ets entry/src/main/ets/common/ApiConfig.local.ets
cp entry/src/main/ets/common/ApiConfig.example.ets entry/src/main/ets/common/ApiConfig.prod.ets
```

**然后修改 `ApiConfig.local.ets` 配置你的本地后端地址。**

详细配置说明请查看：[环境配置指南](./docs/环境配置指南.md)

## 📚 文档目录

- [环境配置指南](./docs/环境配置指南.md) - 配置文件使用说明
- [API配置管理说明](./docs/API配置管理说明.md) - API 配置详细文档
- [后端API接入需求文档](./docs/后端API接入需求文档.md) - 需要实现的后端接口

## 🏗️ 项目结构

```
TopUpAI/
├── entry/                      # 主模块
│   └── src/main/ets/
│       ├── common/             # 公共配置
│       │   ├── ApiConfig.ets          # API 主配置
│       │   ├── ApiConfig.example.ets  # 配置示例
│       │   ├── ApiConfig.local.ets    # 本地配置（不提交）
│       │   └── ApiConfig.prod.ets     # 生产配置（不提交）
│       ├── components/         # 公共组件
│       ├── models/             # 数据模型
│       ├── services/           # 服务层（API调用）
│       ├── stores/             # 状态管理
│       └── views/              # 页面视图
└── docs/                       # 文档目录
```

## 🔧 技术栈

- **前端框架：** HarmonyOS ArkTS
- **UI组件：** ArkUI
- **HTTP客户端：** axios
- **状态管理：** AppStorageV2
- **后端API：** Python FastAPI（待接入）

## 📋 功能模块

- [x] 院校库查询
- [x] 志愿填报推荐
- [x] 政策资讯浏览
- [x] 学习计划管理
- [x] 资格检测
- [ ] 用户认证（待后端实现）
- [ ] 真实数据接入（待后端实现）

## 🔐 安全提示

⚠️ **重要：** 请勿将以下文件提交到 Git：

- `ApiConfig.local.ets` - 包含本地配置
- `ApiConfig.prod.ets` - 包含生产环境敏感信息

这些文件已在 `.gitignore` 中配置，不会意外提交。

## 📞 联系方式

如有问题或建议，请提交 Issue 或联系项目维护者。

---

**祝你开发愉快！** 🎉
