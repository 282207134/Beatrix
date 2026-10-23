# 项目结构与架构说明

## 设计目标

Beatrix 是直播社区 UI 的离线演示工程。按功能拆分页面，保持依赖少、路由明确、状态可追踪，便于后续把静态目录与本地操作替换成服务端实现。

本项目没有为尚不存在的后端引入空的接口层、依赖注入容器或大量样板类。现阶段用一个共享状态对象和静态目录完成交互，避免过度设计。

## 分层与依赖方向

```text
main.dart
  └─ AppState.load() → BeatrixApp
       ├─ MaterialApp：主题 / Navigator
       ├─ AppScope：向页面提供共享状态
       └─ features：auth / home / browse / live / profile
            ├─ widgets/common.dart：无持久化逻辑的公共视图
            ├─ Catalog：类型化的游戏、直播和礼物目录
            └─ AppState：关注、资料、余额、搜索、主题等业务操作
                 └─ SharedPreferences：本地 JSON 快照
```

| 文件 | 职责 |
| --- | --- |
| `main.dart` | 初始化 Flutter，读取本地状态，启动应用 |
| `app.dart` | 全局导航与浅深色主题；竖屏内容最大宽度 600，横屏全屏放开宽度 |
| `core/app_state.dart` | 单一共享状态源、保存操作、输入消息与礼物扣减 |
| `core/catalog.dart` | Game、Stream、Gift 不可变模型与示例数据 |
| `core/theme.dart` | 品牌色、字重、字号、表单、按钮、分隔线、暗色表面 |
| `widgets/common.dart` | Picture、Avatar、Pill、StreamCard、ClipTile、MenuTile、空状态等 |
| `features/*` | 各功能的页面与短期表单、页签状态 |

页面通过 `AppScope.of(context)` 读取共享状态。业务操作修改 `AppState` 后调用 `notifyListeners()`，依赖它的页面会更新；持久化字段同时序列化保存。页面自身的控制器在 `dispose()` 释放。

## 状态生命周期

| 数据 | 生命周期 | 说明 |
| --- | --- | --- |
| 主题 | 持久化 | 设置页切换，全局立即生效 |
| 演示会话 | 可选择持久化 | 登录页 Remember me 控制；不保存密码或令牌 |
| 昵称、简介、邮箱 | 持久化 | 编辑表单校验后保存 |
| 关注集合 | 持久化 | Set 去重；直播间、主播详情、关注列表共用 |
| 搜索历史 | 持久化 | 去重后置顶，最多 8 条，可清空 |
| 钻石余额与赠送记录 | 持久化 | 先校验余额，扣减后记录；余额不足不产生记录 |
| 开播偏好 | 持久化 | 标题、分类、游戏、语言 |
| 聊天、演示开播状态 | 运行期 | 不连接网络，不发送外部消息 |
| 活动参加状态 | 页面期 | 本次访问的演示 RSVP |
| 数据目录、排行榜等 | 编译期常量 | 不代表实时数据 |

持久化使用 `beatrix.v1` 键保存 JSON。读取到无效 JSON 或类型不匹配时捕获异常，避免启动崩溃。退出演示会话不删除资料与关注。

`SharedPreferences` 适合这里少量、不敏感的演示数据。正式版本的凭证应迁移到安全存储；礼物余额与礼物交易应由服务端进行权威校验，而不应依赖客户端本地数字。

## 导航与页面复用

四个主入口使用 `IndexedStack`，切换时保留各自滚动及页签状态。二级页面使用 Flutter Navigator 和集中路由；Game / Stream / 主播名作为路由参数传递。

| 路由 | 页面或状态 |
| --- | --- |
| `/onboarding`、`/login`、`/register`、`/success` | 引导、登录、注册、成功 |
| `/home`、`/discover`、`/following`、`/profile` | 主容器的不同初始导航项 |
| `/search` | 最近搜索、建议、结果；结果四个页签共享查询 |
| `/games`、`/streamers`、`/streams` | 复用目录页 |
| `/category` | 一个游戏详情页面承载四个页签及排序 |
| `/streamer` | 一个主播页面承载 Broadcast / Clips / About |
| `/event` | 活动详情与演示参加状态 |
| `/stream`、`/fullscreen`、`/leaderboard` | 直播间、横屏预览、排行 |
| `/dashboard`、`/edit-live` | 开播面板与偏好编辑 |
| `/settings`、`/edit-profile`、`/account` | 设置与资料表单 |
| `/wallet`、`/gifts`、`/videos` | 钱包、礼物中心、我的视频 |
| `/help`、`/support`、`/about`、`/privacy`、`/notifications` | 帮助、服务说明、关于、条款及示例通知 |

直播间的送礼面板使用 BottomSheet，不复制整套直播页面。横屏预览进入时设置横屏方向，退出时恢复竖屏。键盘弹起时缩小预览并暂时隐藏信息区，给聊天保留可用空间。

## 视觉实现

- 品牌主色 `#6A56F6`；深色背景 `#151522`；辅助文字 `#9592AE`。
- 本地打包 Jakarta Regular / SemiBold / Bold 字体，不依赖运行时字体下载。
- 原稿主要画板宽度为 375。应用使用逻辑像素、SafeArea、弹性行列和可滚动内容适配手机。
- 公共图片组件负责裁切、圆角和缺失资源的图标回退。
- 长标题与标签使用省略及弹性约束，避免窄屏溢出。
- 原稿空白／已填写表单由实际表单状态覆盖；浅深色由全局 ThemeData 覆盖。

## 后端接入位置

| 后续能力 | 当前替换点 |
| --- | --- |
| 真实账号与 OAuth | `AuthPage.submit` 与 `AppState.login/logout` |
| API 内容目录与分页 | `Catalog`；数据变复杂时新增 repository 层 |
| 视频播放与推流 | `StreamPage`、`FullscreenPage`、`DashboardPage` 的静态预览区域 |
| 实时聊天 | `AppState.sendMessage` 与消息列表 |
| 关注同步 | `AppState.toggleFollow` |
| 礼物与钱包交易 | `AppState.sendGift`，改由服务端返回余额及交易结果 |
| 图片上传 | 资料页目前使用本地原稿头像与背景 |
| 活动报名与通知 | `EventPage` 的页面状态与示例通知 |

## 测试与截图

`test/app_state_test.dart` 验证持久化、关注、礼物余额不足、历史去重、聊天及退出。`test/ui_test.dart` 验证登录表单及主导航。`integration_test/layout_test.dart` 检查 28 个路由的浅深色布局；`integration_test/app_test.dart` 在 Android 模拟器执行实际交互并采集截图。

截图驱动等待图片解码、动画和 Android 画面提交后再保存。截图文件位于 `docs/screenshots/`；Pixso 导出参考图保存在独立的 `docs/reference/`，不将设计图冒充运行截图。最终执行结果见 [验证记录](VALIDATION.md)。
