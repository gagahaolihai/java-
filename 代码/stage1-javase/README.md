# stage1-javase · 第 1–2 周代码

## 这是什么

W1–W2 的每日练习代码。**故意不用 Maven** —— 因为 W2 才学 Maven，W3 才学 JDBC。

这样做的好处：你会先体会"手工管理依赖、手工编译"的麻烦，再学 Maven 时就知道它到底解决了什么问题。**没被工具折磨过的人，不会真的理解工具。**

## 目录结构

```
stage1-javase/
├── README.md              ← 你在这里
├── src/
│   ├── day01oop/          ← 接口/抽象类/多态 + equals/hashCode 契约
│   ├── day02generics/     ← Result<T> / Pair / PageResult / PECS / 类型擦除
│   ├── day03collections/  ← 手写 MyArrayList / MyHashMap + LRU
│   ├── day04stream/       ← Stream 成绩统计 + Optional + toMap 踩坑
│   ├── day05io/           ← 词频统计 / 大文件读取 / 缓冲性能对比
│   ├── day06exception/    ← 异常体系 + AutoCloseable + 抑制异常
│   └── day07contacts/     ← 综合练习：控制台通讯录（分层 + CSV）
├── tmp/                   ← 测试用大文件（★ 已被 .gitignore 忽略，不要提交）
└── out/                   ← 编译产物（★ 已被 .gitignore 忽略）
```

每日任务书在 [`../../进度/issues/`](../../进度/issues/)。

## 怎么跑

### 用 IntelliJ IDEA（推荐）

1. `File → Open` 选中 `stage1-javase` 目录
2. Project SDK 选 **21**（没有就装；用 26 也能跑，但生态兼容性差）
3. 打开任意 `dayNNxxx/Main.java`，点行号旁的绿色三角运行

### 用命令行

```powershell
cd "C:\Users\嘎嘎在这里\Desktop\java全栈\代码\stage1-javase"
javac -encoding UTF-8 -d out src/day01oop/*.java
java -cp out day01oop.Main
```

## 编码规范（从第一天就养成）

| 项 | 要求 |
|---|---|
| 包名 | 全小写，`day01oop` 这种（**不能用连字符**，所以和文档里的 `day01-oop` 写法不同） |
| 类名 | 大驼峰 `MyArrayList` |
| 方法/变量 | 小驼峰 `totalArea` |
| 常量 | 全大写 `DEFAULT_CAPACITY` |
| 缩进 | 4 空格（IDEA 默认） |
| 文件编码 | **UTF-8**（Windows 默认 GBK，一定要改，否则中文注释乱码） |
| 日志 | 练习期可以 `System.out`，但**调试残留必须删干净**；W2 引入 SLF4J 后改用日志 |

> IDEA 设置 UTF-8：`Settings → Editor → File Encodings` → 三处都选 UTF-8，并勾 `Transparent native-to-ascii conversion` 之外的默认项。

## W2 之后的去向

W2 学完 Maven 后，从 **D8 起**转为 Maven 多模块工程（`stage1-parent` + `common` + `dao` + `service`），届时：

- 这个 `src/` 里的包会**保留作为练习存档**
- 新的 Maven 工程建在 `代码/stage1-javase/` 的同级或内部子目录，具体见 W2 任务书

## 面试时怎么讲这段代码

这个目录里有两个东西是**可以直接在面试里讲的**：

1. **手写的 `MyHashMap`** —— "我手写过一遍，所以扩容时用 `hash & oldCap` 把链表拆成高低位这件事我印象很深。"
2. **`try-with-resources` 的抑制异常实验** —— "我做过实验，`try` 块和 `close()` 都抛异常时，主异常不会被覆盖，关闭异常进了 `getSuppressed()`。"

这两句话比背八股有力得多，因为它们是**你自己跑出来的**。
