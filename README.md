# ROCEOS K50S 专属 iStoreOS 24.100 官方构建仓库

[![Build K50S iStoreOS Firmware](https://github.com/vip7955579989-beep/ROCEOS-K50S-iStoreOS-24.100/actions/workflows/build-k50s.yml/badge.svg)](https://github.com/vip7955579989-beep/ROCEOS-K50S-iStoreOS-24.100/actions/workflows/build-k50s.yml)

本仓库提供针对 **ROCEOS K50S** 软路由/开发板的 **iStoreOS 24.10** 全套固件自动化编译配置、Linux 本地构建脚本以及 GitHub Actions 云端一键构建工作流。

---

## 硬件规格与网口定义

结合 ROCEOS K50S 官方硬件原理图、原生 DTS 设备树与外观结构说明：

* **核心 CPU**: Rockchip RK3568 (四核 Cortex-A55, 主频 2.0GHz)
* **内存 / 存储**: 4GB/8GB LPDDR4X，32GB/64GB eMMC，拓展支持 M.2 NVMe 及 SATA 盘
* **无线网络**: AP6255 2.4G+5G 双频 WiFi 及蓝牙模块
* **默认管理地址**: `192.168.0.254` (账号: `root` / 密码: `password` 或空)
* **五网口物理布局与接口映射**:
  - **LAN 桥接网口 (3 × 2.5G 电口)**:
    - `ETH0` (左一 2.5G 电口)
    - `ETH1` (左二 2.5G 电口)
    - `ETH2` (左三 2.5G 电口)
  - **WAN 光口 (2 × 1G/2.5G SFP 光口)**:
    - `ETH3` (右上 SFP 光口)
    - `ETH4` (右下 SFP 光口)

---

## 构建特性与集成组件

1. **最新 iStoreOS 24.12 架构基线**: 内核与系统软件包全新升级。
2. **完整驱动支持**:
   - 板载 RTL8125BG 2.5G 网卡原生驱动 (`kmod-r8125`)
   - RTL8211FS SFP 光口 PHY 驱动支持
   - AP6255 无线网卡驱动 (`kmod-brcmfmac`)
   - USB 3.0 / SATA / NVMe 存储驱动与 Ext4 / NTFS3 / ExFAT 文件系统支持
3. **内置核心应用**:
   - **iStore 应用商店** (`luci-app-store`)
   - **QuickStart 快捷启动面板** (`luci-app-quickstart`)
   - **OpenClash 全能网络代理** (`luci-app-openclash`)
   - **Docker 容器引擎与管理** (`luci-app-dockerman`)
   - **Samba4 网络共享** (`luci-app-samba4`)
   - **TTYD 网页终端** (`luci-app-ttyd`)
   - **DiskMan 磁盘管理** (`luci-app-diskman`)

---

## 快速使用说明

### 方式 A：GitHub Actions 云端编译（推荐）
1. Fork 本仓库：`https://github.com/vip7955579989-beep/ROCEOS-K50S-iStoreOS-24.12.git`
2. 点击仓库页面的 **Actions** 选项卡。
3. 选择 **编译 ROCEOS K50S 专属 iStoreOS 24.12 固件** 工作流，点击 **Run workflow** 即可开始云端并行构建。
4. 构建完成后在 Artifacts / Release 中下载刷机镜像 (`*sysupgrade.img.gz`)。

### 方式 B：Linux 本地手动编译
在 Linux (Ubuntu 22.04 / WSL2) 终端中运行：
```bash
bash build_local.sh
```
编译产物将自动输出至 `bin_out/` 目录下。

---

## 开源许可与致谢
* 原厂硬件资料与 DTS 来自 ROCEOS 官方
* OpenWrt / iStoreOS 项目组
