## 项目目标
- 提供番茄计时器、记录每次使用情况、支持标注与标签。
- 用可视化“番茄”图标展示使用次数，支持日历视图与统计分析。
- 提供登录后按用户维度统计与查看。

## 核心功能
- 番茄计时器：开始/暂停/继续/完成，完成后弹出标注窗口。
- 记录与标注：为每次番茄添加标签与备注，支持编辑与删除。
- 番茄图标展示：在列表、仪表盘与日历中以番茄图标表示数量。
- 统计视图：总次数、按日/周/月分布、最近30天趋势、按标签分布。
- 日历视图：月历格子显示每天的番茄数量，点击查看当天明细。
- 用户登录：用户数据隔离，只能查看与管理自己的番茄记录。

## 数据模型
- User：`email`、`password_digest`、`display_name`。
- PomodoroSession：`user_id`、`started_at`、`ended_at`、`duration_seconds`、`label`(string)、`note`(text)、`status`(enum: completed/cancelled)、`day_date`(date)、`completed_at`。
- Tag（可选）：`name`、`color`；PomodoroTagging：`pomodoro_session_id`、`tag_id`（多对多）。
- 说明：统计主要通过聚合查询而非单独统计表；对 `user_id + day_date` 建索引便于日历与统计。

## 路由与控制器
- `PomodoroSessionsController`：`index`(列表/按日筛选)、`create`(完成计时或手动添加)、`update`(编辑标注/标签)、`destroy`、`calendar`(月视图)、`stats`(概览)。
- `DashboardController`：登录后首页，展示今日番茄、快速开始计时、统计概要。
- `TagsController`（可选）：简单的标签管理。
- 路由位置参考：`config/routes.rb:12-15` 当前尚未设定 `root`，后续设置为 `dashboard#index`。

## 页面与交互
- 仪表盘：
  - 今日番茄数与番茄图标阵列；“开始一个番茄”按钮；最近活动。
- 计时器页面/组件：
  - Stimulus 控制器实现倒计时；完成时弹窗输入 `label/note/tag`；提交后创建 `PomodoroSession` 并通过 Turbo 更新列表。
- 列表页：
  - 最近番茄记录，显示图标、标注、标签；支持筛选（今天、本周、某天）。
- 日历页：
  - 月视图（Tailwind 网格），格子显示当天番茄数量（多个番茄图标或数字徽标）；左右切月、点击查看当天明细（Turbo Frame 局部刷新）。
- 统计页：
  - 总次数、按日分组柱状/番茄阵列、最近30天趋势、按标签分布；初版用纯 DOM 展示，后续可选 Chart.js。

## 前端技术
- TailwindCSS：已有集成用于快速样式（`app/assets/tailwind/application.css`）。
- Hotwire：Turbo + Stimulus（`app/javascript/controllers` 已就绪）用于无刷新交互与计时器实现。
- 图标：复用 `public/icon.svg` 或自定义番茄 SVG；以重复图标或徽标数表示数量。

## 统计与查询
- 总次数：`PomodoroSession.where(user: current_user).count`。
- 按日统计：按 `day_date` 分组聚合（考虑 `Time.zone` 一致性）。
- 日历数据源：给定月份范围，查询该月所有记录并按天聚合；返回 `{date => count}` 映射供视图渲染。
- 索引与性能：`index_pomodoro_sessions_on_user_id_and_day_date`；分页与 N+1 避免。

## 鉴权与安全
- 登录注册：启用 `has_secure_password`（`bcrypt`），最低可行鉴权；后续可切换到 Devise。
- 访问控制：控制器层面限定 `current_user` 数据范围；过滤敏感参数。

## 实施步骤（里程碑）
1. 建表与模型：User、PomodoroSession、（可选）Tag/Tagging，添加必要索引。
2. 登录/注册与会话管理（`has_secure_password` + 会话控制器）。
3. 番茄记录的基础 CRUD 与列表视图（显示番茄图标与标注）。
4. 计时器 Stimulus 控制器与完成后创建记录；Turbo 流更新。
5. 日历页（月视图）与数据聚合，支持切月与查看当天明细。
6. 统计页：总数、按日统计、最近30天概要，后续可引入图表库。
7. 测试：模型校验、控制器请求、系统测试（创建番茄、日历浏览）。
8. 收尾：设置 `root` 到仪表盘，样式与交互细节打磨。

## 测试与验证
- 模型测试：校验必填、关系、聚合查询正确性。
- 系统测试：计时完成创建记录、日历切换、统计显示正确。
- 本地验证与预览：启动开发服务器、手动走通主流程。

## 后续扩展
- 休息/长休周期管理、番茄长度自定义、目标设定（每日/每周）。
- 导出（CSV/JSON）、PWA 离线使用（项目已包含 PWA 基础视图）。
- 通知提醒（浏览器通知/邮件）。

请确认以上计划；确认后我将开始依次交付模型、控制器、视图与交互实现，并提供运行与测试验证。