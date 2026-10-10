# 90 天 Java 后端全栈路线图

配套文件：[README.md](./README.md)（进度看板）· [项目文档/](./项目文档/)（需求与表设计）· [进度/](./进度/)（周报）

---

## 1. 前提与策略

| 项目 | 设定 |
|---|---|
| 起点 | 会 Java 语法（类、集合、循环），**没做过完整项目** |
| 时间预算 | 90 天 × 4–5 h ≈ **400 小时** |
| 终点定义 | 不是"学完"，而是"**能通过 Java 后端初面的项目+八股水位**" |
| 投递时间 | **第 11 周末开始投**，不要等第 12 周 |

### 三条铁律

1. **项目驱动，不是教程驱动。** 教程看到 30% 就动手写，卡住了再回头查。三个月只看视频 = 0 产出。
2. **每周必须有能跑的东西。** 跑不起来 = 本周没完成，哪怕笔记写了 20 页。
3. **八股前置。** 从第 4 周起每天 20 分钟，最后一周才背必崩。

### 每天 4.5 小时怎么分

| 时段 | 内容 | 时长 |
|---|---|---|
| A | 看文档/视频，只看到能动手为止 | 60 min |
| B | **写代码**（当天练习 + 项目推进） | 150 min |
| C | **写笔记**（用自己的话复述，代码同步贴） | 45 min |
| D | 八股 20 min + 昨日复习 10 min | 30 min |

> 顺序不要颠倒：先写代码再补笔记。笔记是"我搞懂了什么"的产物，不是抄写。

### 每周节奏

- **周一早**：建本周 Milestone + 7 个日任务 Issue，写 `进度/weekNN.md` 的"本周计划"
- **周三晚**：自查——如果周计划完成度 < 40%，当场砍范围（砍进阶留主线）
- **周日 21:00**：填周报 → 更新 README 进度看板 → 打 tag `week-NN`

---

## 2. 技术栈目标深度（先看这张表，避免学偏）

| 技术 | 学到什么程度算过关 | 不要求 |
|---|---|---|
| Java 集合 | 能画 HashMap 数组+链表+红黑树扩容流程，说清 fail-fast | 手写红黑树 |
| Java 并发 | 线程池 7 参数+拒绝策略、AQS 原理、CAS/ABA、ThreadLocal 内存泄漏 | 手写 AQS |
| JVM | 内存结构、GC 算法与收集器对比、常用调优参数、会用 jstat/arthas 定位 | 读 class 文件字节码 |
| MySQL | B+ 树索引、最左前缀、explain 关键列、事务隔离与 MVCC、锁 | 手写存储引擎 |
| Redis | 5 种数据结构+底层编码、RDB/AOF、穿透击穿雪崩、分布式锁演进 | 手写跳表 |
| Spring | IoC/AOP 原理、Bean 生命周期、循环依赖三级缓存、事务传播 | 手写 IoC 容器 |
| MyBatis | 动态 SQL、一级/二级缓存、#{} 与 ${} 区别、插件原理 | 手写 ORM |
| MQ | 可靠投递、幂等、死信/延迟队列、削峰场景 | Kafka 源码 |
| Docker | 写 Dockerfile、compose 编排、网络与卷 | K8s（只做了解） |
| Vue 3 | 组合式 API、路由、Pinia、Axios 封装，能独立写后台页面 | 源码级响应式 |
| 算法 | LeetCode 高频 60 题能独立写出 | 竞赛题 |

---

## 3. 阶段提交清单（每个阶段都必须交这六样）

这是本仓库的**验收标准**。任何一项缺失，该阶段不算完成，不进入下一阶段。

| # | 提交物 | 存放位置 | 合格标准 |
|---|---|---|---|
| 1 | **可运行代码** | `代码/stageN-xxx/` | 克隆下来按 README 三步能跑起来；有分层结构，不是一坨 Controller |
| 2 | **项目说明 README** | 各项目根目录 `README.md` | 含：项目简介、技术栈、架构图、表设计、接口清单、启动步骤、遇到的问题与解决 |
| 3 | **学习笔记** | `笔记/` | 每个技术点一篇，**用自己的话**写，含代码片段或手绘图；不接受纯复制粘贴 |
| 4 | **阶段项目文档** | `项目文档/项目N-xxx.md` | 需求、数据库表设计（字段/类型/索引）、接口定义（路径/入参/出参/错误码） |
| 5 | **周报** | `进度/weekNN.md` | 计划 vs 实际、卡点、解决方式、下周调整。诚实记录"没做完" |
| 6 | **GitHub 痕迹** | Issues / PR / Tag / Release | 每天一个 Issue 闭合；每周 tag；阶段结束打 Release 并写 Release Note |

**额外加分项（阶段二起逐步加）**：单元测试覆盖率、Swagger/Apifox 接口文档、Docker 一键启动、GitHub Actions CI 绿勾、压测报告。

### 各阶段的"答辩题"（做完能答出来才算过）

- **阶段一**：你的 DAO 层为什么要抽接口？事务在哪一层控制、为什么？
- **阶段二**：一个请求从进 Tomcat 到查数据库再返回 JSON，完整链路经过哪些组件？统一异常处理怎么保证不吞异常？
- **阶段三**：缓存和数据库怎么保持一致？消息重复消费怎么办？JWT 过期了前端怎么处理？
- **阶段四**：镜像为什么用多阶段构建？`docker-compose` 里服务间怎么互相访问？QPS 从多少优化到多少、靠什么？

---

## 4. 十二周逐周计划

---

## 阶段一 · 打地基（W1–W3）

> **阶段目标**：把"会语法"变成"能写工程化的代码"，并摸到数据层。  
> **阶段项目**：项目一 · 控制台图书管理系统（JDBC + MySQL + 分层架构）  
> **阶段 Tag**：`v1.0-stage1`

### 第 1 周 · Java 核心收口

**本周目标**：补齐"会语法"到"会用"之间的裂缝——泛型、集合原理、Stream、异常设计。

**技术点**
- 面向对象深化：封装/继承/多态、接口 vs 抽象类、组合优于继承、`Object` 方法契约（equals/hashCode/toString）
- 泛型：泛型类/方法/通配符、类型擦除、`? extends` 与 `? super`（PECS）
- 异常：受检 vs 非受检、try-with-resources、自定义业务异常、异常不要吞
- 集合框架：`ArrayList` 扩容、`LinkedList` 结构、`HashMap` 哈希扰动/扩容/树化、`TreeMap`、`LinkedHashMap`、`Iterator` 与 fail-fast
- 函数式：Lambda、函数式接口、方法引用、`Stream` 常用操作（filter/map/flatMap/collect/groupingBy）、`Optional`
- IO：字节流/字符流、缓冲、`Files`/`Path`、NIO 概念（Channel/Buffer/Selector 只做了解）
- 常用类：`String`/`StringBuilder`/`StringJoiner`、`BigDecimal`（金额）、日期时间 API（`LocalDateTime`/`DateTimeFormatter`）

**代码产出**（`代码/stage1-javase/`，W1 先用**普通 Java 工程**，W2 学完 Maven 后从 D8 起转 Maven 多模块）
- `src/day01oop/` 形状面积计算器（多态 + 接口 + equals/hashCode 契约）
- `src/day02generics/` 泛型结果包装类 `Result<T>` + `Pair<A,B>` + PECS 通配符练习
- `src/day03collections/` 手写 `MyArrayList` / `MyHashMap` 的简化版（**必须自己写一遍**）
- `src/day04stream/` 学生成绩统计分析（分组、下游收集器、排序、TopN）
- `src/day05io/` 文件词频统计 + 大文件按行读取 + 缓冲流性能对比
- `src/day06exception/` 自定义异常体系 + `AutoCloseable` 资源与异常抑制
- `src/day07contacts/` 综合练习：控制台通讯录（分层 + 增删改查 + CSV 持久化）

> 每日任务书见 [`进度/issues/`](./进度/issues/)，每份都能单独当天的 GitHub Issue 用。

**笔记产出**（`笔记/01-Java基础/`）
- `集合-HashMap原理.md`（含手绘扩容流程图）
- `泛型与类型擦除.md`
- `Stream与Optional实践.md`
- `异常设计规范.md`

**验收标准（DoD）**
- [ ] 7 个练习全部可运行，每个都有 `main` 能演示
- [ ] 能不看资料讲出 HashMap put 的完整流程（含扩容与树化阈值）
- [ ] 能说出 `ArrayList` 与 `LinkedList` 在随机访问/头插/内存上的取舍
- [ ] 笔记 4 篇，每篇有自己的例子代码

**面试可讲点**：HashMap 为什么线程不安全、`ConcurrentHashMap` 怎么解决、`equals` 与 `hashCode` 契约

---

### 第 2 周 · 并发基础 + Maven + MySQL

**本周目标**：理解并发模型（不追求手写），掌握 Maven 与 SQL。

**技术点**
- 并发：线程创建方式、线程状态、`synchronized`（对象头/锁升级概念）、`volatile`（可见性/禁止重排）、JMM、`ReentrantLock` vs `synchronized`、`ThreadLocal`、`ThreadPoolExecutor` 七参数与四种拒绝策略、`CompletableFuture` 基础、`AtomicInteger` 与 CAS
- JVM 初步：运行时数据区、对象创建过程、垃圾判定、常见 GC（了解差异）
- Maven：坐标（groupId/artifactId/version）、标准目录、生命周期（clean/compile/test/package/install）、依赖范围（compile/provided/runtime/test）、依赖传递与冲突解决（`dependencyManagement`、`exclusions`）、多模块（父 pom + 子模块）
- MySQL：库表设计规范（命名、主键、时间字段、逻辑删除）、DDL/DML/DQL、JOIN 全类型、子查询/派生表、聚合与窗口函数初步、`GROUP BY` 与 `HAVING`、约束与外键（生产是否用外键要能说理由）
- SQL 进阶：索引是什么（B+ 树）、聚簇索引 vs 二级索引、回表、联合索引与最左前缀、覆盖索引、`explain` 关键列（type/key/rows/Extra）

**代码产出**
- `代码/stage1-javase/day08-concurrency/` 线程池批量任务 + 计数器三种实现对比（synchronized/Atomic/LongAdder）
- `代码/stage1-javase/day09-optional/` `CompletableFuture` 并行聚合示例
- `代码/stage1-javase/stage1-parent/` **Maven 多模块骨架**（parent + common + dao + service）
- `代码/stage1-javase/sql-practice/` 50 道 SQL 练习（题目 + 答案 SQL + 截图）
- `代码/stage1-javase/sql-practice/schema.sql` 建库建表脚本（含测试数据）

**笔记产出**（`笔记/01-Java基础/`、`笔记/02-MySQL/`）
- `并发-线程池七参数与拒绝策略.md`
- `并发-volatile与JMM.md`
- `Maven-依赖冲突与多模块.md`
- `MySQL-索引与最左前缀.md`
- `MySQL-explain实战.md`

**验收标准（DoD）**
- [ ] 线程池任务能正确控制并发并收集结果
- [ ] Maven 多模块能 `mvn clean install` 成功，common 被 dao 正确依赖
- [ ] 50 道 SQL 至少写完 40 道，答案可执行
- [ ] 能给一条慢 SQL 加索引并用 `explain` 证明生效（type 从 ALL → ref）

**面试可讲点**：`volatile` 能保证原子性吗、线程池参数怎么定、为什么用 B+ 树不用 B 树/哈希、回表是什么

---

### 第 3 周 · JDBC + 分层架构 + Git 工作流 → **项目一**

**本周目标**：把 Java 和 MySQL 连起来，产出第一个完整项目。

**技术点**
- JDBC：DriverManager、Connection/Statement/PreparedStatement/ResultSet 六步、`#{}` 预编译防注入原理、事务（`setAutoCommit`/commit/rollback/Savepoint）、批处理
- 连接池：为什么需要、HikariCP 关键参数（maximumPoolSize/connectionTimeout/idleTimeout）、Druid 监控
- DAO 模式与分层：entity / dao / service / controller(视图层) / util / config
- 反射 + 注解：手写一个迷你 ORM，把 `ResultSet` 自动映射成对象（**这个练习对理解 MyBatis 极有价值**）
- 单元测试：JUnit 5、断言、`@BeforeEach`、Mockito 打桩入门
- Git：工作区/暂存区/版本库、分支、merge vs rebase、冲突解决、PR 流程、`.gitignore`

**代码产出** → **项目一：控制台图书管理系统**（`代码/stage1-library/`）
- 功能：图书 CRUD、读者管理、借阅/归还、逾期计算、按条件检索、统计报表（借阅排行）
- 架构：分层 + DAO 接口与实现分离 + 自定义异常 + 连接池 + 事务控制（借书要跨两张表，必须用事务）
- 附带：`README.md`（架构图 + 启动步骤）、`docs/表设计.md`、JUnit 测试 ≥ 10 个用例、`schema.sql` + 测试数据

**笔记产出**
- `JDBC-从六步到连接池.md`
- `JDBC-手写迷你ORM理解MyBatis.md`
- `Git-分支模型与PR流程.md`
- `项目一复盘.md`（难点、踩坑、如果重做会怎么改）

**验收标准（DoD）**
- [ ] 项目能按 README 三步跑起来（装库 → 改配置 → 运行）
- [ ] 借书/还书操作在异常时能完整回滚（**有测试证明**）
- [ ] 没有 SQL 拼接注入风险（全部预编译）
- [ ] 分层清晰：Controller 里不出现 SQL，DAO 里不出现业务规则
- [ ] Git 上有 ≥ 15 次有意义的提交 + 至少 3 个已合并的 PR

**面试可讲点**：`PreparedStatement` 为什么能防注入、事务写在哪一层、为什么 DAO 要抽接口、连接池满了会怎样

---

## 阶段二 · 进框架（W4–W6）

> **阶段目标**：从"手写 JDBC"切换到"用 Spring 生态高效交付 REST API"，并建立工程规范。  
> **阶段项目**：项目二 · 企业后台管理系统后端  
> **阶段 Tag**：`v2.0-stage2`

### 第 4 周 · Spring 核心 + Spring Boot 3 + REST 规范

**技术点**
- Spring 核心：IoC/DI 三种注入方式、`@Component/@Service/@Repository/@Configuration`、Bean 作用域与生命周期、`@Autowired` 与构造器注入为什么推荐、条件装配 `@Conditional`
- AOP：切面/切点/通知、`@Aspect`、JDK 动态代理 vs CGLIB、AOP 实战（统一日志、接口耗时）
- Spring Boot 3：起步依赖、自动配置原理（`@SpringBootApplication` 三段注解、`spring.factories` → `AutoConfiguration.imports`）、`@ConfigurationProperties`、yml 多环境 profile、启动流程概览
- Spring MVC：DispatcherServlet 请求链路、`@RestController`、参数绑定（`@RequestParam/@PathVariable/@RequestBody`）、`@Valid` + 分组校验、统一响应体 `Result<T>`、全局异常 `@RestControllerAdvice`、跨域 CORS
- 工程四件套：**统一返回格式 + 全局异常处理 + 参数校验 + 日志规范**（`@Slf4j`、MDC 加 traceId）
- 接口文档：SpringDoc OpenAPI（Swagger UI）
- 启动前置：**每天 20 分钟八股**开始

**代码产出**（`代码/stage2-admin-api/` 起步）
- 骨架工程：分层包结构 + 四件套 + Swagger + 多环境配置
- 示例接口：用户模块 CRUD（先用内存/假数据），每个接口带完整校验与错误码
- 全局异常处理覆盖：参数异常、业务异常、系统异常，返回统一结构且不吞堆栈

**笔记产出**
- `Spring-IoC与Bean生命周期.md`
- `Spring-AOP原理与实战.md`
- `SpringBoot-自动配置原理.md`
- `SpringMVC-一个请求的完整链路.md`
- `REST接口设计规范.md`（含错误码约定）

**验收标准（DoD）**
- [ ] 能用 `curl`/Swagger 调通每个接口，异常分支返回统一 JSON
- [ ] 构造器注入、无字段注入
- [ ] 日志里有 traceId，一次请求的日志能串起来
- [ ] 能画出并讲清 DispatcherServlet 的处理链路

**面试可讲点**：Bean 生命周期、循环依赖与三级缓存、AOP 两种代理区别、`@Transactional` 失效场景

---

### 第 5 周 · MyBatis / MyBatis-Plus + 事务 + SQL 优化

**技术点**
- MyBatis：`SqlSessionFactory`、Mapper 接口与 XML 映射、`resultMap`、动态 SQL（`if/where/foreach/choose`）、`#{}` vs `${}`、一级/二级缓存、分页插件、延迟加载
- MyBatis-Plus：`BaseMapper`、条件构造器 `LambdaQueryWrapper`、分页插件、逻辑删除、自动填充（创建/更新时间）、代码生成器
- JPA vs MyBatis 取舍（面试高频：为什么不选 JPA）
- 事务进阶：`@Transactional` 属性（propagation/isolation/rollbackFor/timeout）、7 种传播行为、失效场景（自调用、非 public、异常被吞、多线程）、`TransactionSynchronization` 概念
- 锁：乐观锁（version 字段 + MP `@Version`）、悲观锁 `select ... for update`、间隙锁与死锁排查
- SQL 优化实战：慢查询定位（慢日志/`SHOW PROCESSLIST`）、`explain` 逐列解读、索引设计（联合索引顺序、覆盖索引、前缀索引）、索引失效场景（函数、隐式转换、`like %x`、`or`）、大表分页优化（延迟关联/游标）
- 数据库设计：三范式与反范式、分库分表概念（只做了解）、主从复制与读写分离概念

**代码产出**
- 项目二持久层：Mapper + XML、分页查询、多条件动态检索、逻辑删除、自动填充、乐观锁扣减
- `代码/stage2-admin-api/sql/` 完整建表脚本 + 初始化数据（含索引设计说明注释）
- `代码/stage2-admin-api/docs/慢SQL优化.md`：≥ 5 个真实慢 SQL，优化前后 `explain` 对比与耗时数据
- `代码/stage2-admin-api/src/test/` Service 层单元测试（Mockito 打桩 Mapper）

**笔记产出**
- `MyBatis-动态SQL与缓存.md`
- `MyBatisPlus-常用姿势与坑.md`
- `Spring事务-传播行为与失效场景.md`
- `MySQL-索引失效的8种场景.md`
- `MySQL-大表分页优化.md`

**验收标准（DoD）**
- [ ] 所有查询接口走 MyBatis，无手写 JDBC 残留
- [ ] 分页接口在 10 万行数据下响应 < 500ms（造数据实测）
- [ ] 能对一个接口说清它的 SQL 走了哪个索引、为什么
- [ ] 单元测试能覆盖 Service 的主要分支

**面试可讲点**：`#{}` 与 `${}`、一级二级缓存、`@Transactional` 失效的 5 种情况、`for update` 的坑

---

### 第 6 周 · 项目二成型 → **企业后台管理系统后端**

**本周目标**：把前两周的零件组装成一个"像企业项目"的东西。

**技术点**
- RBAC 权限模型：用户-角色-权限（菜单/按钮级）、动态菜单、数据权限概念
- 部门/岗位/字典/参数配置（企业后台标配模块）
- 操作日志：AOP + 自定义注解记录操作人/IP/耗时/入参出参
- 文件上传下载：本地存储 vs MinIO/OSS、断点续传概念、文件类型与大小校验
- Excel 导入导出：EasyExcel 注解与大数据量流式导出
- 定时任务：Spring `@Scheduled`（含 cron）、Quartz/XXL-Job 概念
- 接口设计：RESTful 风格统一、版本化、幂等性、限流概念
- 代码质量：Lombok、MapStruct（对象转换）、统一常量与枚举、`Optional` 处理空值

**代码产出** → **项目二：企业后台管理系统后端**（`代码/stage2-admin-api/`）
- 模块：认证（占位，W7 完善）、用户、角色、菜单权限、部门、字典、文件、操作日志、定时任务
- 交付：完整 API 文档（Swagger 导出 + Apifox/Postman 集合 JSON）、数据库设计文档、架构图（mermaid）、启动说明
- 测试：核心 Service 单测 + 一套 HTTP 冒烟请求脚本（`.http` 文件或 Postman）
- 提交规范：本周所有开发走 Issue → 分支 → PR → squash merge

**笔记产出**
- `RBAC权限模型设计.md`
- `AOP实现操作日志.md`
- `EasyExcel大文件导出.md`
- `项目二复盘.md` + **架构图**

**验收标准（DoD）**
- [ ] 项目能从零启动：建库 → 跑 SQL → 改 yml → `mvn spring-boot:run`
- [ ] Swagger 上每个接口可调通，含 20+ 接口
- [ ] 数据库设计文档与脚本一致（字段、索引、注释齐全）
- [ ] README 含 mermaid 架构图与模块说明，**面试官不看代码也能懂这个项目**
- [ ] 有 Release `v2.0-stage2` 和 Release Note

**面试可讲点**：RBAC 表怎么设计、操作日志怎么做的、幂等怎么保证、项目里你最得意的设计

---

## 阶段三 · 上强度（W7–W9）

> **阶段目标**：做出有"技术含量"的亮点（安全、缓存、消息队列、高并发），并补齐前端能力。  
> **阶段项目**：项目三 · 全栈电商（含 Vue 3 前端）  
> **阶段 Tag**：`v3.0-stage3`

### 第 7 周 · Spring Security + JWT + Redis 缓存

**技术点**
- 认证 vs 授权、Session vs Token、无状态设计
- Spring Security 6：过滤器链、`SecurityFilterChain` 配置、`AuthenticationManager`、`UserDetailsService`、密码编码 `BCryptPasswordEncoder`、方法级鉴权 `@PreAuthorize`、自定义 `AuthenticationEntryPoint` 与 `AccessDeniedHandler`
- JWT：三段结构、签名算法、签发/校验/过期、**双 Token（access + refresh）刷新方案**、注销与黑名单（Redis）、无感刷新前后端配合
- 安全加固：防重放、验证码、登录失败锁定、接口防刷（Redis 计数/令牌桶）、越权（水平/垂直）防范、常见漏洞（XSS/SQL 注入/CSRF）认知
- Redis 基础：5 种数据结构与典型场景、底层编码（SDS/ziplist/skiplist/quicklist）、单线程模型、过期策略（惰性+定期）、内存淘汰 8 种策略、RDB vs AOF、主从/哨兵/集群概念
- Redis 实战：缓存穿透（布隆过滤器/空值缓存）、击穿（互斥锁/逻辑过期）、雪崩（随机过期/多级缓存）、缓存一致性（Cache Aside、延迟双删、binlog 订阅概念）
- 分布式锁演进：`SETNX` → `SET NX EX` + Lua 释放 → Redisson 可重入/看门狗 → RedLock 争议
- Spring Cache：`@Cacheable/@CachePut/@CacheEvict` 与 Redis 集成

**代码产出**
- 认证体系：注册/登录/刷新 Token/注销/获取当前用户/修改密码，全部带校验
- 权限：接口级 + 方法级鉴权，越权测试用例（用 A 的 token 访问 B 的数据必须失败）
- 缓存层：热点数据缓存 + 缓存三兄弟防护代码 + 压测对比（有缓存 vs 无缓存）
- 分布式锁：抢购/扣库存场景 Demo，附并发测试结果
- `代码/stage2-admin-api/docs/安全设计.md`

**笔记产出**
- `SpringSecurity6-过滤器链与自定义认证.md`
- `JWT-双Token刷新方案.md`
- `Redis-数据结构与底层编码.md`
- `Redis-缓存穿透击穿雪崩（含代码）.md`
- `Redis-分布式锁的四种实现与坑.md`

**验收标准（DoD）**
- [ ] 未登录访问受保护接口返回 401，无权限返回 403，格式统一
- [ ] Token 过期后前端能用 refreshToken 无感续期（接口可演示）
- [ ] 缓存三兄弟每个都有对应代码 + 说明为什么这样防
- [ ] 能用 Redisson 实现一个分布式锁并给出并发正确性证明（测试输出）

**面试可讲点**：JWT 优缺点与注销怎么做、缓存一致性最终方案、Redis 为什么快、分布式锁 Redisson 看门狗原理

---

### 第 8 周 · 消息队列 + Vue 3 前端速通

**技术点（上午 MQ / 下午前端，各 2h）**
- RabbitMQ：核心模型（Producer/Exchange/Queue/Consumer/Channel）、四种交换机（direct/topic/fanout/headers）、消息确认（publisher confirm + 手动 ack）、`prefetch`、死信队列、延迟队列（TTL+DLX / 延迟插件）、消息可靠性三段（生产不丢/存储不丢/消费不丢）、幂等消费（唯一键/去重表/Redis setnx）、消息堆积与顺序性
- 或 Kafka（如果目标岗位偏大数据）：Topic/Partition/Offset、消费组与 rebalance、顺序性与幂等、与 RabbitMQ 选型对比
- MQ 实战场景：异步解耦（下单后发短信/加积分）、削峰填谷（秒杀）、最终一致性（分布式事务概念）
- 前端：HTML 语义化 + CSS Flex/Grid 布局 + JS（变量/函数/数组方法/Promise/async-await/fetch）+ 模块化
- Vue 3：Vite 工程、`<script setup>`、ref/reactive/computed/watch、生命周期、组件通信（props/emit/provide-inject）、`vue-router`（动态路由与守卫）、Pinia、Element Plus 常用组件、Axios 封装（请求/响应拦截器、Token 注入、错误统一处理、刷新 Token 重试）、环境变量与跨域代理、打包部署

**代码产出**
- `代码/stage3-mq-demo/`：下单 → MQ → 异步扣积分/发通知；死信与延迟队列各 1 个可演示场景；重复消费幂等测试
- `代码/stage3-web/`（Vue 3 前端工程）
  - 登录页（含验证码、Token 存储）
  - 用户列表页（分页、搜索、增删改弹窗）
  - 路由守卫 + 动态菜单 + 权限按钮控制
  - Axios 封装 + 无感刷新 Token

**笔记产出**
- `RabbitMQ-可靠投递与幂等消费.md`
- `RabbitMQ-死信与延迟队列实战.md`
- `Vue3-组合式API速查.md`
- `前端-前后端联调与跨域问题排查.md`

**验收标准（DoD）**
- [ ] MQ Demo 能演示：正常消费、消费失败进死信、重复消息只处理一次
- [ ] 前端能独立启动并连上后端，登录 → 列表 → 增删改全链路通
- [ ] 能说清前端请求带 Token 的完整流程与刷新时机

**面试可讲点**：如何保证消息不丢不重、延迟队列实现方式、MQ 选型、前端怎么处理 Token 过期

---

### 第 9 周 · 全栈整合 → **项目三：全栈电商**

**本周目标**：把安全、缓存、MQ、前端整合成一个有亮点的全栈项目，并留下**可量化的性能数据**。

**核心业务**（选一条主线做深，别贪多）
- 用户：注册/登录/JWT 双 Token/个人中心/收货地址
- 商品：分类、SPU/SKU、上下架、搜索（多条件 + 分页 + 缓存）
- 购物车：Redis Hash 存储、登录合并匿名购物车
- 订单：下单（**Redis 预扣库存 + MQ 异步落库 + 幂等**）、订单超时自动取消（延迟队列）、订单状态机、取消/退款占位
- 秒杀/抢购：限流（Redis + Lua 原子扣减）、防超卖、防重复下单、结果异步通知
- 支付：**不接真实支付**，写模拟支付回调 + 签名校验（面试可讲）
- 后台：商品/订单管理（复用项目二的 RBAC 骨架）

**工程产出**
- `代码/stage3-fullstack/`：`backend/`（后端）+ `frontend/`（前端）+ `docs/`
- `docker-compose.dev.yml`：一键起 MySQL + Redis + RabbitMQ（应用先本地跑）
- 接口文档、表设计（含索引与分片预留思考）、架构图（含缓存与 MQ 数据流）
- 压测报告：JMeter 对秒杀接口压测，记录 QPS / 平均响应 / 错误率，**对比有/无 Redis 预扣的差异**
- 演示：`docs/演示脚本.md`（照着念就能演示 5 分钟）

**笔记产出**
- `项目三-秒杀系统设计（含时序图）.md`
- `项目三-防超卖与幂等方案对比.md`
- `项目三复盘.md`（重点：哪里是瓶颈、数据支撑）

**验收标准（DoD）**
- [ ] 前后端一起能跑，完整走通"登录 → 浏览商品 → 加购 → 下单 → 支付回调 → 订单完成"
- [ ] 秒杀接口在 JMeter 并发下不超卖（**有截图/日志证明库存为 0 且订单数 = 库存数**）
- [ ] 重复提交同一请求只生成一笔订单
- [ ] 有性能对比数据（因为这是简历上唯一能量化的东西）
- [ ] Release `v3.0-stage3` + Release Note + 演示 GIF/截图

**面试可讲点**：这套项目的技术难点是什么、为什么用 MQ、超卖了怎么发现怎么修、压测数据怎么来的

---

## 阶段四 · 能上线（W10–W11）

### 第 10 周 · Linux + Docker + Nginx 部署

**技术点**
- Linux：目录结构、常用命令（`ls/cd/grep/find/ps/top/df/du/tail/netstat/ss/lsof`）、权限 `chmod/chown`、进程管理与信号、`systemctl`、环境变量、软链接、打包解压、`vim` 基础、Shell 脚本（变量/判断/循环/函数）、日志排查套路
- Docker：镜像 vs 容器、分层与联合文件系统、常用命令、Dockerfile 指令（FROM/WORKDIR/COPY/ADD/RUN/ENV/EXPOSE/ENTRYPOINT/CMD）、**多阶段构建**、`.dockerignore`、数据卷、网络（bridge/host/自定义网络与容器 DNS）、镜像瘦身（jre-alpine/distroless/Jib）
- Docker Compose：`depends_on` 与 healthcheck、环境变量与 `.env`、网络互通、一键启停与日志查看
- Nginx：反向代理、负载均衡（轮询/权重/ip_hash）、静态资源与 history 路由、gzip、HTTPS 概念与自签证书、常见 502/504 排查
- 自动化：GitHub Actions 自动编译打包（加分：构建镜像推送到 GHCR）
- 服务器：云服务器选购、安全组、SSH 免密登录、防火墙、域名与备案概念

**代码产出**
- 每个项目的 `Dockerfile`（多阶段构建，镜像体积对比记录）
- `代码/stage4-deploy/docker-compose.yml`：mysql + redis + rabbitmq + backend + frontend + nginx **一键起全栈**
- `代码/stage4-deploy/nginx/nginx.conf`：反向代理 + 前端静态托管 + gzip
- `代码/stage4-deploy/deploy.sh`：一键部署脚本
- `代码/stage4-deploy/.github/workflows/build.yml`：CI 流水线（编译 + 测试 + 打包）
- `代码/stage4-deploy/docs/部署文档.md`：从裸机到可访问的完整步骤 + 排错记录

**笔记产出**
- `Linux-服务器排错常用命令.md`
- `Docker-多阶段构建与镜像瘦身.md`
- `DockerCompose-服务编排实战.md`
- `Nginx-反向代理与502排查.md`

**验收标准（DoD）**
- [ ] 在干净机器上 `git clone` → `docker compose up -d` → 浏览器能访问全栈应用
- [ ] 镜像体积优化有前后对比数字
- [ ] 部署文档写给别人看也能跑通（找一个朋友试）
- [ ] 至少记录 3 个真实排错过程（502/容器启动顺序/连不上 MySQL）

**面试可讲点**：Dockerfile 怎么分层优化、容器间怎么通信、Nginx 为什么能抗并发、线上 502 你怎么查

---

### 第 11 周 · 微服务 + JVM 调优 + 压测 + **简历**

**技术点**
- 微服务概念：拆分原则、服务治理要解决的问题（注册发现/配置/调用/网关/熔断/链路追踪）
- Spring Cloud Alibaba：Nacos（注册中心 + 配置中心，含配置热更新）、OpenFeign（声明式调用 + 超时重试）、Gateway（路由/断言/过滤器）、Sentinel（流控/熔断降级/热点参数）、Seata（AT 模式概念，不做深入）
- 分布式问题：分布式 ID（雪花算法）、分布式事务方案对比（2PC/TCC/可靠消息/最大努力通知）、链路追踪（Sleuth/Micrometer Tracing + Zipkin 概念）
- JVM 调优：运行时数据区、对象分配与逃逸分析、GC 算法与收集器（Serial/Parallel/CMS/G1/ZGC 取舍）、常用参数（`-Xms -Xmx -Xmn -XX:MetaspaceSize -XX:+UseG1GC`）、OOM 类型与排查、`jps/jstat/jmap/jstack`、**Arthas 实战**（`dashboard/thread/heapdump/trace/watch`）
- 压测与优化：JMeter 压测脚本、TPS/QPS/RT/P99 指标含义、瓶颈定位思路（CPU/内存/IO/DB/锁/GC）、优化手段清单（索引/缓存/连接池/异步/批量/池化）
- 简历：项目 STAR 化、技术栈排序、量化数据、一页原则、针对 JDK 逐条自测

**代码产出**
- `代码/stage4-micro/`：把项目三拆成 3 个服务（用户服务 / 商品服务 / 订单服务）+ gateway + common
  - Nacos 注册与配置、OpenFeign 调用、Gateway 统一入口、Sentinel 限流降级各 1 个可演示场景
- `代码/stage4-micro/docs/压测优化报告.md`：原始指标 → 瓶颈定位 → 优化动作 → 优化后指标（**表格 + 截图**）
- `代码/stage4-micro/docs/JVM排查记录.md`：1 次 OOM/CPU 飙高的完整 Arthas 排查记录
- **`进度/简历-v1.md`**：简历初稿（放仓库里持续迭代，注意隐去手机号等隐私）

**笔记产出**
- `微服务-Nacos与OpenFeign实践.md`
- `微服务-Gateway与Sentinel.md`
- `JVM-内存结构与GC收集器选型.md`
- `JVM-Arthas排查实战.md`
- `性能优化-从压测到定位的完整思路.md`

**验收标准（DoD）**
- [ ] 三个服务能在 Nacos 上注册并互相调用成功，网关能路由
- [ ] Sentinel 限流触发有日志/截图证据
- [ ] 压测报告里有**优化前后对比数字**（例：QPS 从 320 → 1450）
- [ ] 简历初稿完成，每个项目 3 条 STAR 描述 + 量化结果
- [ ] **本周日开始投递**（先投 5 家练手，不当场记复盘不算）

**面试可讲点**：为什么拆微服务、Nacos 配置热更新原理、Sentinel 限流算法、GC 怎么选、CPU 100% 排查步骤

---

## 阶段五 · 拿 Offer（W12）

### 第 12 周 · 八股冲刺 + 项目深挖 + 投递

**每日安排**

| 时段 | 内容 |
|---|---|
| 上午 2h | 八股专题复习（一天一专题）+ 自问自答录音回听 |
| 下午 2h | 算法：LeetCode 高频 60 题（数组/双指针/哈希/链表/二叉树/DP/回溯/栈队列） |
| 晚上 1h | 项目讲解演练 / 投递 / 面试复盘 |

**八股专题表（7 天）**
1. Java 基础 + 集合（HashMap/ConcurrentHashMap/ArrayList 源码级）
2. 并发 + JVM（线程池/AQS/锁/内存模型/GC）
3. MySQL（索引/事务/MVCC/锁/优化）
4. Redis（数据结构/持久化/缓存问题/分布式锁）
5. Spring 全家桶（IoC/AOP/事务/MVC/自动配置）
6. MQ + 微服务 + 分布式（可靠性/幂等/一致性问题）
7. 计算机网络 + 操作系统 + 设计模式 + 场景设计题（秒杀/短链/排行榜/分布式 ID）

**项目深挖准备**
- 每个项目准备：30 秒版 / 3 分钟版 / 10 分钟版讲解稿
- 每个项目准备 20 个追问的答案（写在 `笔记/07-八股与面试/项目追问-项目三.md`）
- 准备 3 个"我踩过的坑 + 怎么定位 + 怎么修"的故事（面试官最爱听）

**投递与复盘**
- `进度/投递追踪表.md`：公司 / 岗位 / 渠道 / 投递日 / 状态 / 面试时间 / 复盘链接
- 每场面试当天写 `笔记/07-八股与面试/面试复盘-MMDD-公司.md`：被问到什么 / 答成什么样 / 标准答案补上
- 渠道：BOSS 直聘（主）、牛客网内推、拉勾、公司官网校招/社招、GitHub 上的招聘 Issue

**本周产出（阶段提交清单第 6 类 + 额外）**
- [ ] `进度/简历-v2.md`（终稿，导出 PDF 放 `进度/resume.pdf`）
- [ ] `笔记/07-八股与面试/` 至少 7 个专题笔记 + 3 篇项目追问
- [ ] `进度/投递追踪表.md`（≥ 30 家投递记录）
- [ ] ≥ 3 篇面试复盘
- [ ] README 进度看板全部 ✅ + 写一段《90 天总结》

**验收标准（DoD）**
- [ ] 能对着镜子把三个项目各讲 3 分钟不卡壳
- [ ] 高频八股能答到"原理级"而不是"名词级"
- [ ] 高频 60 题能独立手写出 45 题以上
- [ ] 已发生至少 3 场真实面试

---

## 5. GitHub 记录规范（这是本仓库的核心玩法）

### Issue
- **每周一个 Milestone**：`Week 03 · JDBC 与项目一`
- **每天一个 Issue**：标题 `[W03D2] JDBC 事务控制练习`，正文用 `.github/ISSUE_TEMPLATE/每日任务.md`
- 完成即关闭，**不留 open Issue 超过 3 天**

### 分支与 PR
```bash
git switch -c feat/w03d2-jdbc-tx
# ... 写代码写笔记 ...
git add . && git commit -m "feat(w03d2): 完成 JDBC 事务回滚与保存点练习"
git push -u origin feat/w03d2-jdbc-tx
# 在 GitHub 开 PR，自己 review 一遍 diff，Squash merge
```
> **自己 review 自己的 PR 不是形式主义**：diff 里出现 `System.out.println`、注释掉的代码、`TODO`、密码硬编码，就是你自己给自己做代码审查。

### Tag 与 Release
- 每周日：`git tag week-03 && git push --tags`
- 每阶段：Release `v1.0-stage1`，Release Note 写：本阶段学了什么、产出了什么、遗留问题

### 让仓库更"面试官友好"
- 顶层 README 第一屏就能看懂你在干什么（已有）
- 每个项目 README 第一屏有截图/GIF + 技术栈 + 启动方式
- 用 mermaid 画架构图（GitHub 原生渲染）
- GitHub Actions 徽章挂在 README 上

---

## 6. 每周日自检（5 个问题，答不上就是没过）

1. 本周产出的代码**能在干净环境跑起来**吗？（不是"在我电脑上能"）
2. 本周有没有至少 **5 次有意义的 commit**？（不是 `update` / `fix bug`）
3. 随机抽一个本周技术点，我能**不看资料讲 2 分钟**吗？
4. 本周报的中"卡点"写的是**具体问题**，还是"有点难"这种废话？
5. 如果下周要讲给同学听，我能讲清**为什么**这么设计吗？

---

## 7. 进度落后了怎么办（降级方案）

三个月计划一定会被现实打乱。**按优先级砍，不要全线崩**：

| 情况 | 砍什么 | 绝不砍 |
|---|---|---|
| 落后 3 天 | 笔记从"每点一篇"降为"每主题一篇" | 代码产出 |
| 落后 1 周 | 跳过 Elasticsearch、Seata、XXL-Job、K8s、设计模式深挖 | 项目三的缓存 + MQ 亮点 |
| 落后 2 周 | 阶段四微服务只保留 Nacos + Gateway（跳过 Sentinel/Seata）；前端只做管理后台不做电商前台 | 项目一/二/三的可运行性 + 部署能力 |
| 只剩 2 周就投递 | 主线收敛为「项目三深挖 + 八股 + 算法」 | 每天投递 + 面试复盘 |

**底线**：项目必须是三个（一个基础、一个企业级、一个带亮点全栈）。只有一个项目的人，简历过不了筛选。
