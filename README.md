# ROCEOS K50S (RK3568) 专属 iStoreOS 24.10 全新系统构建仓库

本工程专为 **ROCEOS K50S (瑞芯微 RK3568)** 软路由深度定制，基于官方 `iStoreOS 24.10` 源码分支构建，融合从 `G:\k50s` 原厂资料、真机 DTC 设备树拆解及拆页原理图得出的底层驱动与物理接口参数。

---

## 🌟 系统核心特性与硬件支持

基于最新《ROCEOS K50S 开发板官方产品介绍》文档与真机硬件定义：

| 硬件规格/功能项 | ROCEOS K50S 硬件配置 |
| :--- | :--- |
| **主控芯片 (SoC)** | 瑞芯微 Rockchip RK3568 (四核 A55 @ 2.0GHz) |
| **内存/闪存配置** | 4GB / 8GB LPDDR4 + 32GB / 64GB eMMC 5.1 闪存 |
| **网络接口** | 5 个物理千兆网口 (WAN: `eth0`, LAN: `eth1`~`eth4`)，支持 2.5G 网卡扩展 |
| **磁盘扩展** | 原生 SATA 3.0 接口、USB 3.0/2.0 高速扩展 |
| **无线模块** | 板载 Wi-Fi 芯片 (集成 `kmod-brcmfmac` 驱动) |
| **供电标准** | DC 12V / 2.5A ~ 4A |
| **系统兼容性** | iStoreOS 24.10/24.11 (本项目)、Ubuntu, Armbian Linux, Android 9-11 |

### ⚡ iStoreOS 24.11 专属定制项：
1. **物理 WAN 口**：`eth0`
2. **物理 LAN 口**：`eth1`, `eth2`, `eth3`, `eth4`
3. **默认管理 IP**：`192.168.0.254`（完全匹配设备底部铭牌贴纸与原厂 V220307 规格）
4. **预装应用与生态集成**：
   - **商店与中心**：`luci-app-store`, `luci-app-quickstart`
   - **核心插件**：`luci-app-openclash`, `luci-app-dockerman`, `luci-app-samba4`, `luci-app-diskman`, `luci-app-ttyd`

---

## 📁 仓库工程结构

```text
.
├── .github/
│   └── workflows/
│       └── build-k50s.yml           # GitHub Actions 云端一键全自动编译与 Release 发布工作流
├── files/
│   └── etc/
│       └── board.d/
│           └── 02_network           # K50S 5网口物理接口配置
├── patches/
│   └── target/linux/rockchip/dts/
│       ├── rk3568-roc-k50s.dts      # ROCEOS K50S 专属设备树文件
│       └── rk3568-roc-k50s.dtsi     # ROCEOS K50S 板级定义
├── u-boot/
│   └── k50s-rk3568-u-boot-rockchip.bin  # 原生 K50S 专用 U-Boot 镜像
├── build_local.sh                   # 本地 WSL / Docker 一键自动化编译脚本
└── README.md                        # 使用与刷机指南
```

---

## 🚀 编译与构建指南

### 方式一：GitHub Actions 云端自动编译

1. **开启 Actions 权限**：在 GitHub 仓库中进入 `Settings -> Actions -> General`，勾选 `Workflow permissions` 下的 `Read and write permissions`。
2. **触发编译**：
   - 进入 `Actions` 页面，选择 **“编译 ROCEOS K50S 专属 iStoreOS 24.10 固件”**；
   - 点击 `Run workflow`，确认默认 LAN IP（`192.168.0.254`）无误后启动编译。
3. **获取固件**：编译完成后，直接在 Release / Artifacts 页面下载固件产物。

### 方式二：本地 WSL / Docker 一键编译

1. 确保安装了 Ubuntu 22.04 LTS (WSL2) / Linux 编译环境；
2. 执行本地脚本：
   ```bash
   bash build_local.sh
   ```
3. 编译产物将自动放置在 `bin_out/` 文件夹中。
