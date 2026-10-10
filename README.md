# my-sdlc

自主软件开发生命周期（SDLC）agent 工作流：从需求到自动开发、验证、提交 git，高质量交付，只在重要环节请人确认。

本插件以 [pstack-distilled](../pstack-distilled)（Lauren Tan 的 pstack 移植版）为骨架，合并了 [superpowers](../superpowers) 的三项机制：

| 来源 | 机制 | 位置 |
|---|---|---|
| pstack | playbook 路由 + 22 条工程原则 + live 验证 harness + 对抗评审 | `skills/`（46 个 skill） |
| superpowers | SessionStart hook 自动激活（不依赖模型记得用） | `hooks/` |
| superpowers | TDD 铁律（无失败测试不写生产代码） | `skills/tdd/SKILL.md` |
| superpowers | 磁盘执行 ledger（抗上下文压缩，可断点续跑） | `skills/execution-ledger/SKILL.md` |

相对 pstack 原版删掉了 GitHub PR 重耦合件：`babysit`、`orchestrate`、`autopilot-full`、`autopilot-stack` playbook 及 `watch-pr`/`orch` 脚本（Bun + gh CLI 依赖）。自主长任务走 `autonomous-run` playbook；落栈走 `shipping`（已改为纯 `gh` 轮询）。

## 工作流

```
需求 → poteto-mode 路由（按任务类型选 playbook）
     → multi-phase-plan 写计划 → check-plan.mjs 机器校验 → 【人: 说 "go" 才开工】
     → architect（≥2 候选设计对抗 → 合成）
     → tdd（失败测试先行，铁律）→ 强制委派子 agent 写码（lead 永不写码）
     → 验证: 单元 + live 真实界面（verify-<app> harness）+ 性能对照
     → interrogate 对抗评审（Act on / Consider / Noted / Dismissed）
     → opening-a-pr（小步有序 commit、Conventional Commits）
     → shipping（独立验证 + patch-id 规则 → 逐个 squash 合并）
```

## 人的确认点（仅这些）

1. **计划批准**——说 "go" 才开工
2. **不可逆写操作**——force-push 共享分支、部署、删数据、对外发消息
3. **改交互的 PR**——merge 前看截图/视频
4. **合并授权**——只有明确说 ship/land，或事先授予全自治 + 根裁决干净
5. **实验无法回答的真正产品/偏好决策**

其余一律「rulings not stalls」：自主决定、记入 ledger、结束统一汇报。能用实验回答的问题跑原型决定，不麻烦人。

## 质量如何自动保证

- **TDD 铁律**：无失败测试先行不写生产代码；先写的代码必须删掉；必须亲眼看测试失败；完成前跑全项目测试套件
- **作者/裁判分离**：lead 拥有设计/评审/裁决但永不写码；验证由没写过代码的独立 agent 做，且不信任实现报告
- **live 验证**：`create-verification-skill` 生成项目专属验证 harness（Playwright 驱动 web、tmux 驱动 CLI、HTTP 驱动服务），生成后必须端到端跑过一次；裁决分级 VERIFIED / NOT VERIFIED / INCONCLUSIVE，inconclusive 不算过
- **patch-id 规则**：裁决绑定 `git patch-id`，rebase 噪音不失效、实质变化推翻重验
- **计划机器校验**：`node skills/poteto-mode/scripts/check-plan.mjs <plan.md>`
- **执行 ledger**：`.my-sdlc/runs/<slug>/progress.md` 记录完成任务+测试证据+裁决+parked 发现，压缩/重启后从 ledger + git log 恢复
- **审计轨迹**：`show-me-your-work` 的只增 decisions.tsv + 交接前跨模型独立评审

## 安装

### Kimi Code CLI

插件清单在 `.kimi-plugin/plugin.json`，声明了 `skills`、`sessionStart: poteto-mode`（会话开始自动注入路由 skill）和 `skillInstructions`（Kimi 工具映射：Task→Agent、TodoWrite→TodoList、提问→AskUserQuestion）。

### Claude Code

`.claude-plugin/plugin.json` + `hooks/hooks.json` 注册 SessionStart hook（startup/clear/compact 时执行 `hooks/session-start`，把 poteto-mode 全文注入上下文）。

## 目录结构

```
.claude-plugin/plugin.json   Claude 清单
.kimi-plugin/plugin.json     Kimi 清单（含工具映射）
hooks/                       SessionStart 注入（run-hook.cmd + session-start）
skills/
  poteto-mode/               中央路由 + 19 个 playbook + check-plan.mjs
  tdd/                       TDD 铁律（pstack 务实豁免 + superpowers iron law）
  execution-ledger/          磁盘执行 ledger（断点续跑）
  architect/ arena/ swarm/ interrogate/   设计与对抗评审
  create-verification-skill/ maintain-verification-skill/   live 验证 harness
  show-me-your-work/         decisions.tsv 审计轨迹
  how/ why/ figure-it-out/   代码库问答与自定义工作流
  principle-*/               22 条工程原则
  unslop/ technical-writing/ no-comments/ correct/ …
```

## 致谢

- pstack-distilled: https://github.com/lionkeng/pstack-distilled (MIT)，源自 Lauren Tan 的 pstack
- superpowers: https://github.com/obra/superpowers (MIT)，Jesse Vincent
