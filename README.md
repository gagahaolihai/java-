# Java 后端全栈 · 90 天学习记录

> **起点**：会 Java 语法，没做过完整项目  
> **投入**：每天 4–5 小时（约 400 小时 / 90 天）  
> **目标**：第 12 周结束前完成 3 个可运行项目 + 完整笔记体系，**并已开始投递** Java 后端开发岗  
> **记录方式**：所有代码、笔记、周报、项目文档全部提交进这个仓库 —— 提交历史就是学习轨迹

---

## 为什么开这个仓库

1. **逼自己产出**：每天不提交 = 今天没学，没有例外。
2. **面试官视角**：一个有 300+ 次提交、有清晰 README、有部署文档、有 Issue/PR 记录的仓库，比简历上写"熟悉 Spring Boot"有说服力得多。
3. **可回溯**：三个月后你会忘记当初为什么这么写，热力图和 diff 会帮你回忆。

---

## 进度看板

状态：⬜ 未开始 · 🟡 进行中 · ✅ 已完成 · 🔴 卡住

| 阶段 | 周次 | 主题 | 关键产出 | 状态 |
|---|---|---|---|---|
| **0** | Day 0 | 环境与工具链 | 本仓库 + 环境清单 | 🟡 |
| **1** | W1 | Java 核心收口（OOP/集合/泛型/Stream） | 每日小程序 ×7 + 笔记 ×7 | ⬜ |
| | W2 | 并发基础 + Maven + MySQL 与 SQL | Maven 多模块骨架 + 50 道 SQL | ⬜ |
| | W3 | JDBC + DAO 分层 + Git 工作流 | **项目一：图书管理系统（控制台）** | ⬜ |
| **2** | W4 | Spring 核心 + Spring Boot 3 + REST 规范 | 统一响应/异常/校验/日志 四件套 | ⬜ |
| | W5 | MyBatis + 事务 + 索引优化 | 完整持久层 + 慢 SQL 优化笔记 | ⬜ |
| | W6 | 单体项目成型（RBAC 后台） | **项目二：企业后台管理系统后端** | ⬜ |
| **3** | W7 | Spring Security + JWT + Redis 缓存 | 认证鉴权体系 + 缓存层 | ⬜ |
| | W8 | 消息队列 + Vue 3 前端速通 | 异步下单 Demo + 前端登录/列表页 | ⬜ |
| | W9 | 全栈整合 + 高并发场景 | **项目三：全栈电商（前端+后端）** | ⬜ |
| **4** | W10 | Linux + Docker + Nginx 部署 | 一键 `docker-compose up` 全栈 | ⬜ |
| | W11 | Spring Cloud 微服务 + JVM + 压测优化 | 微服务拆分 + 优化对比报告 + **简历初稿** | ⬜ |
| **5** | W12 | 八股冲刺 + 项目深挖 + 投递 | 简历终稿 + 投递追踪表 + 面试复盘 | ⬜ |

> 每周日晚更新这张表。**状态没变的一周，就是失败的一周。**

---

## 路线图速览

```
阶段一（3周）打地基        Java 语言 → 并发 → MySQL → JDBC        产出：控制台项目
阶段二（3周）进框架        Spring Boot → MyBatis → REST 规范       产出：单体后端 API
阶段三（3周）上强度        安全/缓存/MQ + Vue3 前后端联调          产出：全栈项目
阶段四（2周）能上线        Docker/Nginx/Linux + 微服务 + 调优      产出：一键部署 + 数据报告
阶段五（1周）拿 Offer      八股 + 项目讲解稿 + 算法 + 投递          产出：简历 + 面试记录
```

完整逐周计划（含每周验收标准）见 **[ROADMAP.md](./ROADMAP.md)**。

---

## 目录结构

```
java全栈/
├── README.md                 ← 你在这里：总览 + 进度看板
├── ROADMAP.md                ← ★ 12 周逐周详细计划 + 阶段提交清单
├── LICENSE
├── .gitignore
│
├── 笔记/                      ← 所有学习笔记（Markdown）
│   ├── README.md             ← 笔记规范：命名、模板、图片存放
│   ├── 00-工具与环境/         ← JDK / Maven / MySQL / Redis / Docker / GitHub MCP
│   ├── 01-Java基础/           ← 语法、集合、并发、JVM
│   ├── 02-MySQL/              ← SQL、索引、事务、优化
│   ├── 03-Spring生态/         ← IoC/AOP、Spring Boot、MyBatis、Security
│   ├── 04-中间件/             ← Redis、RabbitMQ、Elasticsearch
│   ├── 05-前端Vue/            ← HTML/CSS/JS、Vue3、Element Plus
│   ├── 06-部署与运维/         ← Linux、Docker、Nginx、CI
│   ├── 07-八股与面试/         ← 面试题整理、场景题、复盘
│   └── templates/            ← 笔记模板（复制这个开始写）
│
├── 代码/                      ← 所有代码
│   ├── README.md
│   ├── Text01/               ← 早期练习（历史存档，不动）
│   ├── stage1-*/             ← 阶段一产物（W3 结束出现）
│   ├── stage2-*/             ← 阶段二产物（W6 结束出现）
│   ├── stage3-*/             ← 阶段三产物（W9 结束出现）
│   └── stage4-*/             ← 阶段四产物（W11 结束出现）
│
├── 项目文档/                   ← 每个项目的需求 / 表设计 / 接口 / 部署说明
│   ├── 项目一-图书管理系统.md
│   ├── 项目二-企业后台管理系统.md
│   └── 项目三-全栈电商.md
│
├── 进度/                      ← 周报与打卡
│   ├── 周报模板.md
│   ├── 投递追踪表.md
│   ├── issues/               ← ★ 每日任务书 W01D1…（可直接当 GitHub Issue 用）
│   └── week01.md … week12.md
│
└── .github/                   ← Issue / PR 模板（把 GitHub 用成工程现场）
```

---

## 每天怎么用这个仓库（固定 6 步）

| 步骤 | 动作 | 耗时 |
|---|---|---|
| 1 | 在 GitHub 建当天 Issue：`[W03D2] JDBC 事务控制练习` | 2 min |
| 2 | 切分支：`git switch -c feat/w03d2-jdbc-tx` | 1 min |
| 3 | **写代码 + 写笔记**（笔记与代码同步写，不隔夜） | 3–3.5 h |
| 4 | 提交：`git commit -m "feat(w03d2): 完成 JDBC 事务回滚与保存点练习"` | 5 min |
| 5 | 推分支 → 开 PR → 自己 review 一遍 diff → Squash merge | 10 min |
| 6 | 填 `进度/weekNN.md` 当天一行：学了什么 / 卡在哪 | 10 min |

**每天必修**：从 W4 起，早起 20 分钟背八股（`笔记/07-八股与面试/`），不要留到最后一周。

---

## 提交规范

**分支**：`feat/w03d2-jdbc-tx`、`docs/w05-index-note`、`fix/w06-page-bug`

**Commit 前缀**（Angular 约定）：

| 前缀 | 用途 | 例子 |
|---|---|---|
| `feat` | 新功能 / 新练习代码 | `feat(w09): 秒杀接口 Redis 预扣库存` |
| `docs` | 只改笔记 / 文档 | `docs(w05): 补充最左前缀失效场景` |
| `fix` | 修 bug | `fix(w06): 修正分页总数计算错误` |
| `refactor` | 重构 | `refactor(w03): DAO 抽取泛型基类` |
| `chore` | 配置 / 依赖 | `chore: 升级 spring-boot 到 3.3.x` |
| `test` | 测试 | `test(w06): 补 UserService 单元测试` |

**Tag**：每周日打 `week-03`；每阶段结束打 `v1.0-stage1`、`v2.0-stage2`…

**每个阶段结束必须提交的 6 类东西** → 见 [ROADMAP.md 第 3 节](./ROADMAP.md#3-阶段提交清单每个阶段都必须交这六样)。

---

## 技术栈与目标深度

| 分类 | 技术 | 目标深度 | 面试权重 |
|---|---|---|---|
| 语言 | Java 17/21 | 集合源码、并发、JVM 内存与 GC 能做原理级回答 | ★★★★★ |
| 构建 | Maven | 生命周期、依赖冲突排查、多模块 | ★★★ |
| 框架 | Spring Boot 3 / Spring MVC | 自动配置原理、IoC/AOP、事务传播 | ★★★★★ |
| 持久层 | MyBatis-Plus / JPA | 动态 SQL、分页、懒加载、缓存 | ★★★★ |
| 数据库 | MySQL 8 | 索引与执行计划、事务与锁、主从概念 | ★★★★★ |
| 缓存 | Redis 7 | 数据结构、持久化、穿透/击穿/雪崩、分布式锁 | ★★★★★ |
| 消息 | RabbitMQ（或 Kafka） | 可靠性投递、幂等、死信/延迟队列 | ★★★★ |
| 安全 | Spring Security + JWT | 过滤器链、RBAC、Token 刷新 | ★★★ |
| 前端 | Vue 3 + Element Plus + Axios | 能独立写管理后台页面并调通接口 | ★★（加分） |
| 部署 | Linux + Docker + Nginx | Dockerfile、compose 编排、反向代理 | ★★★★ |
| 微服务 | Spring Cloud Alibaba | Nacos / OpenFeign / Gateway / Sentinel 会用会讲 | ★★★（加分） |
| 工程 | Git / GitHub Actions / JUnit5 | 分支模型、PR 流程、单元测试 | ★★★ |

---

## Day 0 开学清单

- [ ] JDK 17 或 21（本机已装 JDK 26，建议再装一个 21 作为项目基线）→ `java -version`
- [ ] Maven 3.9+ → `mvn -v`（本机尚未安装，**先装这个**）
- [ ] MySQL 8（本机安装或用 Docker）
- [ ] Redis 7（建议 Docker）
- [ ] Docker Desktop → `docker version`
- [ ] IntelliJ IDEA（社区版够用，旗舰版可破解试用/学生认证）
- [ ] Git 身份：`git config --global user.name "xxx"` / `user.email "xxx"`
- [x] GitHub 账号：`gagahaolihai`（已确认存在）
- [x] Git 身份已配置（本仓库级）：`gagahaolihai` / `gagahaolihai@users.noreply.github.com`
- [x] GitHub MCP 已配置并通过协议层实测（42 个工具可用）→ [配置笔记](./笔记/00-工具与环境/GitHub-MCP配置.md)
- [ ] 在 GitHub 网页新建**空**仓库 `java-backend-90days`（Public，不要勾 README/.gitignore/License）
- [ ] 注册 SSH 公钥（推荐，之后推代码免凭据）：`Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard`
      然后粘到 <https://github.com/settings/ssh/new>
- [ ] 本地关联远程并推送（远程已配好，SSH 修好后可 `git remote set-url origin git@github.com:gagahaolihai/java-backend-90days.git`）：
      `git push -u origin main`

---

## 已知待办

- [ ] **注册 SSH 公钥**（解决 `github.com` 被阻断导致 push 失败的根本办法）：
      `Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub" | Set-Clipboard` → 粘到 <https://github.com/settings/ssh/new>，
      然后把 `~/.ssh/config` 的 `Host github.com` 改成 `HostName ssh.github.com` + `Port 443`。
      完整诊断过程与三种方案见 [GitHub 推送失败排查手册](./笔记/00-工具与环境/GitHub-推送失败排查手册.md)
- [ ] **轮换 GitHub PAT**：当前 token 的 `Issues` / `Pull requests` 是只读、且缺 `Administration`，
      重新生成时按 [MCP 配置文档第七节](./笔记/00-工具与环境/GitHub-MCP配置.md) 的权限表勾选
- [ ] **仓库改名**：当前叫 `java-`（建仓库时输入的中文被 GitHub 过滤），建议改成 `java-backend-90days`
- [ ] `笔记/mysql.md` 里的图片用的是本机绝对路径（`C:\Users\...\Typora\...`），推到 GitHub 后会全部裂图。需要把图片移到 `assets/` 并用相对路径引用（Typora 一次性设置见 [笔记规范](./笔记/README.md)）。
- [ ] `代码/Text01` 是早期练习，保留作存档。

---

## 一句话提醒

> 这个仓库的价值不在于"学完了"，而在于**三个月里每一天都有痕迹**。  
> 断更一天不可怕，断更一周才致命 —— 周日晚上那张进度看板就是你的报警器。
