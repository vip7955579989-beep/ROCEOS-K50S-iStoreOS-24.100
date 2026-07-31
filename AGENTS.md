# 🤖 ROCEOS K50S 专属持久化记忆库 (AGENTS.md)

## 📌 项目核心全量上下文
- **设备**: ROCEOS K50S (RK3568 SoC, 3 个 2.5G 电口 + 2 个 SFP 光口)
- **本地工程路径**: `d:\Antigravity IDE数据文件夹\K50S-iStoreOS-24.10-Build`
- **GitHub 远程仓库**: `https://github.com/vip7955579989-beep/ROCEOS-K50S-iStoreOS-24.12.git`
- **原厂资料物理路径**: `G:\k50s`
- **DTS 路径**: `patches/target/linux/rockchip/dts/rk3568-roc-k50s.dts`
- **关键修补事项**:
  1. Bootloader 注入：U-Boot `k50s-rk3568-u-boot-rockchip.bin` 在编译前全阶段注入 `staging_dir` 和 `target`。
  2. 包依赖：`dnsmasq-full` 编译后使用 `sed -i` 剔除基础 `dnsmasq`。
  3. Actions 产物上传：使用 `bin_out/` 实体目录和 `find openwrt/bin/targets/ -type f` 递归提取镜像。

---

## 🛠️ 助手最高恪守法则
1. **全量记忆永不遗忘**：永远自动保存与用户的对话记忆、执行过的任务记忆、排错历史以及做过的所有事情。每次系统重启或恢复窗口后，优先读取记忆库，瞬间恢复 100% 全量上下文。
2. **全程纯中文展示（最高铁律）**：所有的回答、解释、说明、弹窗选择、思考过程以及所有工具调用的 `toolAction` / `toolSummary` 参数，必须 100% 严格使用中文展示，绝不允许出现英文混杂！

