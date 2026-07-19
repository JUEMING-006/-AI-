import { routerMap } from '../router/RouterMap';
import { ChatPage } from '../views/chat/ChatPage';
import { chatStore } from '../stores/ChatStore';

/**
 * 主入口页面 — AI对话应用架构（参考Kimi）
 *
 * 特性：
 * - 单主页架构：ChatPage 作为唯一根页面
 * - 无底部Tab栏（Kimi风格）
 * - Navigation 用于跳转子页面（院校/志愿/学习等原有功能）
 * - 安全区域由各组件内部适配
 */
@Entry
@ComponentV2
struct Index {
  @Provider('pathStack') pathStack: NavPathStack = new NavPathStack();

  // 拦截返回键：聊天界面 → 首页，首页 → 退出应用
  onBackPress(): boolean {
    // 有子页面时让Navigation自行处理
    if (this.pathStack.size() > 0) {
      return false;
    }
    // 在聊天界面，返回首页
    if (chatStore.currentConversation !== null) {
      chatStore.clearCurrentConversation();
      return true;
    }
    // 在首页，退出应用
    return false;
  }

  build() {
    Navigation(this.pathStack) {
      // AI对话主页（唯一根页面）
      ChatPage()
    }
    .width('100%')
    .height('100%')
    .navDestination(routerMap)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }
}
