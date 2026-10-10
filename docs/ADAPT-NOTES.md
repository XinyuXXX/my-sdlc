# pstack-distilled + superpowers 盘点筛选清单

> 2026-10-10 盘点。盘点对象：`pstack-distilled`（48 个技能）、`superpowers`（v7.0.0，15 个技能）。
> 现状（2026-10-10 晚更新）：pstack-distilled 与 superpowers 的本地副本均已删除，需要的部分已全部落进本仓库 my-sdlc；两个上游都可从 GitHub 重新克隆（`lionkeng/pstack-distilled`、`obra/superpowers`）。
> 分类：**✅ 保留 / ⚠️ 重复待定 / ❌ 建议丢弃**。

## 重大发现：superpowers 已原生支持 Kimi Code

`obra/superpowers` v7.0.0 自带 `.kimi-plugin/plugin.json` + `docs/README.kimi.md`，可通过 Kimi Code 的 `/plugins` 市场直接安装，**无需手工移植**。它已完成工具映射（Task→Agent、TodoWrite→TodoList 等）。后续若要用，直接走插件安装 + 实测触发即可。

## 一、pstack-distilled（48 个技能）

### ✅ 保留——零宿主耦合的纯方法论（直接可搬，30 个）

- **22 个原则全部**：attack-the-premise、boundary-discipline、build-the-lever、encode-lessons-in-structure、exhaust-the-design-space、experience-first、explain-the-number、fix-root-causes、foundational-thinking、guard-the-context-window、laziness-protocol、make-operations-idempotent、migrate-callers-then-delete-legacy-apis、minimize-reader-load、model-the-domain、never-block-on-the-human、outcome-oriented-execution、prove-it-works、redesign-from-first-principles、separate-before-serializing-shared-state、sequence-verifiable-units、subtract-before-you-add、test-behavior-not-implementation、type-system-discipline
  - 理由：纯短文零依赖，是 pstack 的灵魂，任何项目通用
- **unslop**（33 条 AI 文风反模式，被大量技能引用）
- **technical-writing**（Diátaxis + Google 风格）
- **tdd**（失败测试先行纪律）
- **correct**（挖仓库里 agent 反复犯的错，分层消除）
- **benchmark-checklist**（性能数字 7 问，防谎报）
- **typescript-best-practices**（TS 项目适用；非 TS 项目可丢）
- **bro**（9 行小工具，零成本）

### ✅ 保留——依赖 subagent 委托，Kimi 有对应能力（11 个）

| 技能 | 功能 | Kimi 上的退化 |
|---|---|---|
| poteto-mode | 中央路由 + 23 个 playbook | 无定时唤醒→会话内轮询；多模型→单模型 |
| how | 代码库问答带引用 | 无 |
| why | 设计考古（git blame + 多源调查） | 可选 gh/MCP 增强失效，核心可用 |
| architect | 实现前先出 2+ 设计候选 | 多模型→单模型多候选 |
| arena | 多候选竞赛 + 选基座嫁接 | 跨模型评审信号变弱 |
| interrogate | 对抗式评审 | 同模型多实例，信号变弱但仍有效 |
| swarm | 并行 worker fan-out | 本地 subagent 代替远程 worker |
| figure-it-out | 无匹配 playbook 时自建工作流 | 无 |
| show-me-your-work | TSV 决策日志 | 末尾审计环节可选跳过 |
| no-comments | 注释清理裁决 | 无 |
| create-verification-skill + maintain-verification-skill | 为仓库生成"真实验证"能力 | 无（按项目表面选 Playwright/tmux 等） |

### ⚠️ 重复待定——与本机已装技能重叠

| pstack 技能 | 已装技能 | 建议 |
|---|---|---|
| unslop | humanizer | 都留：unslop 面向代码/技术写作且被 pstack 内部引用；humanizer 面向通用 prose |
| interrogate | clean-code-guard | 待定：clean-code-guard 是清单式审查，interrogate 是对抗式评审，互补；若嫌重复可只留 interrogate |
| principle-attack-the-premise | grill-me-thermonuclear | 都留：前者是编码原则，后者是计划压力测试，触发场景不同 |
| tdd | （superpowers 也有 TDD） | 见下方 superpowers 取舍 |
| poteto-mode 内嵌的 PR 文风规范 | clean-code | 不冲突，clean-code 是编码规范 |

### ❌ 建议丢弃——核心依赖 Cursor conversation history，Kimi 上缩水最重（4 个）

- **automate-me** — 挖 Cursor 对话记录生成个人 mode 技能，降级后 mining 环节失效
- **recall** — 核心输入是 conversation history，降级后只剩 git 状态
- **reflect** — step 1 就要会话 record，降级为手写 digest，价值大减
- **setup-pstack** — 整件事就是配置多模型角色映射，单模型宿主上无意义

> 注意：丢弃前确认引用方有降级（poteto-mode 引用 setup-pstack 的 models.md，但写了"文件不存在则用默认"，可安全丢弃）。

### 外部工具依赖提醒

- poteto-mode 的 Bun 脚本（watch-pr/orch）需 Bun + 首次联网；不装 Bun 则相关 playbook 手工执行
- shipping/autopilot-stack 依赖 gh（已有 ✅）+ Graphite（无，相关 playbook 降级）
- worktree-cleanup playbook 含 iOS 模拟器清理（macOS 适用）

## 二、superpowers（15 个技能）

全部零第三方依赖（git/node/bash 之外无），且官方已适配 Kimi。

### 与 pstack 重叠的取舍建议

| superpowers | pstack 对应 | 取舍建议 |
|---|---|---|
| test-driven-development | tdd | **留 superpowers 版**（更完整，含 writing-good-tests.md），丢 pstack 的 tdd |
| systematic-debugging | bug-fix playbook / fix-root-causes | **都留**：superpowers 是纪律铁律，pstack 是证据框架，互补 |
| requesting/receiving-code-review | interrogate / no-comments | 都留：superpowers 走流程门禁，pstack 走对抗内容评审 |
| verification-before-completion | prove-it-works | 重复，留一个即可（倾向 superpowers 版，门禁更硬） |
| brainstorming + writing-plans + executing-plans | figure-it-out / multi-phase-plan | 都留：superpowers 偏"先问清再做"，pstack 偏"大型任务编排" |
| subagent-driven-development + dispatching-parallel-agents | swarm / poteto-mode 子代理纪律 | 重复度高，**二选一**（倾向 superpowers 版，模板更细） |
| using-git-worktrees / finishing-a-development-branch | poteto-mode playbooks | 留 superpowers 版（独立技能更轻） |
| writing-skills | authoring-a-skill playbook | 留 superpowers 版（用 TDD 测技能，独特） |
| using-superpowers | （无对应） | 留：Kimi 插件的 sessionStart 注入入口 |
| diagnosing-superpowers | （无对应） | 可选：仅调试 superpowers 自身时用 |

## 三、用户已确认的决策（2026-10-10）

1. ~~pstack ❌ 名单（automate-me/recall/reflect/setup-pstack）是否确认丢弃？~~ → **确认丢弃**，已从 skills/ 删除
2. ~~重复的 subagent 编排（superpowers vs pstack swarm）二选一还是都留？~~ → **暂时不动**（pstack 侧全保留）
3. ~~superpowers 直接走 Kimi 插件市场安装，还是也 clone 改造后手动挂？~~ → **不安装**；~~仓库保留备用~~ → 后续决定：**本地副本也删除**（见决策 7）
4. ~~typescript-best-practices 是否保留？~~ → **保留**

## 四、追加决策（2026-10-10 晚）

5. ~~pstack-distilled 本地副本是否保留？~~ → **删除**。my-sdlc 是最终工作流版本，pstack-distilled 仅作上游溯源，git 历史在 GitHub 上可恢复。本文件随删除迁入 my-sdlc/docs/。
6. ~~重复技能如何处理？~~ → **合并去重**（2026-10-10 晚第二轮）。grill-me-thermonuclear 并入 grill-me 成为双模式单技能（intake + thermonuclear）；show-me-your-work 并入 execution-ledger 成为双工件单技能（progress.md + decisions.tsv，log.sh 与模板随迁）。两个旧目录与符号链接已删，全部引用已改写。技能数 49 → 47。
7. ~~superpowers 本地副本是否保留备用？~~ → **删除**。其精华（SessionStart 注入、TDD 铁律、ledger）早已合入 my-sdlc，其余重叠件对应技能均更强。本地工作流只认 my-sdlc 一个事实来源。
