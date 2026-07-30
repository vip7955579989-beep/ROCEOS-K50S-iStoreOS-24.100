# ROCEOS K50S 专属 iStoreOS 24.10 固件 GitHub Actions 云端编译工程

本工程专为 **ROCEOS K50S (瑞芯微 RK3568)** 软路由定制，用于在 GitHub Actions 上自动拉取官方 iStoreOS 24.10 源码、集成 K50S 专用设备树 (DTS)、r8125 2.5G 网卡驱动及常用应用插件（OpenClash, Docker, Samba4），编译出可以直接刷入软路由的固件。

---

## 工程目录结构

```text
├── .github/
│   └── workflows/
│       └── build-k50s.yml           # GitHub Actions 云端一键编译工作流
├── files/
│   └── etc/
│       └── board.d/
│           └── 02_network           # K50S PCIe 网卡与 LAN/WAN 物理端口分配
├── patches/
│   └── target/
│       └── linux/
│           └── rockchip/
│               └── dts/
│                   ├── rk3568-roc-k50s.dts   # ROCEOS K50S 主设备树
│                   └── rk3568-roc-k50s.dtsi  # ROCEOS K50S 板级定义
└── README.md                        # 使用说明指南
```

---

## 使用与编译步骤

### 第一步：将本工程推送到您自己的 GitHub 仓库
1. 在 GitHub 上新建一个仓库（例如命名为 `K50S-iStoreOS-Build`）；
2. 将 `d:\Antigravity IDE数据文件夹\K50S-iStoreOS-24.10-Build\` 文件夹下的所有内容提交并推送到您刚创建的 GitHub 仓库。

### 第二步：开启 GitHub Actions 权限
1. 打开您 GitHub 仓库的 **Settings** $\rightarrow$ **Actions** $\rightarrow$ **General**；
2. 找到 **Workflow permissions**，选择 **Read and write permissions** 并保存。

### 第三步：手动触发云端编译
1. 打开仓库顶部的 **Actions** 选项卡；
2. 在左侧列表点击 **“编译 ROCEOS K50S 专属 iStoreOS 24.10 固件”**；
3. 点击右侧 **Run workflow** 按钮；
4. 可根据需要填写默认 LAN 口 IP（默认为 `192.168.100.1`），然后点击绿色的 **Run workflow**。

### 第四步：下载与刷机
1. 等待 Actions 自动编译完成（通常需要 1.5 ~ 2.5 小时）；
2. 编译完成后，在 Actions 任务页面最下方的 **Artifacts** 区域下载 `iStoreOS-24.10-ROCEOS-K50S-Firmware` 压缩包；
3. 解压获得 `.sysupgrade.img.gz` 或 `.img` 固件，即可使用 RKDevTool 刷机工具或 sysupgrade 刷入 K50S 软路由使用！
