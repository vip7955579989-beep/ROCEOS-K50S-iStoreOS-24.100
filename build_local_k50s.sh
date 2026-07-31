#!/bin/bash
set -e

echo "=== 🚀 开始 ROCEOS K50S (RK3568) 本地极速编译工程 ==="

# 0. 自动设置 WSL2 稳健 DNS 解析 (防止 Could not resolve host 错)
sudo bash -c 'echo "nameserver 223.5.5.5" > /etc/resolv.conf && echo "nameserver 8.8.8.8" >> /etc/resolv.conf' 2>/dev/null || true

# 1. 避开路径空格限制，在 D 盘创建专用无空格编译区 /mnt/d/K50S_Build
BUILD_WORK_DIR="/mnt/d/K50S_Build"
echo "--> 目标 D 盘编译空间: ${BUILD_WORK_DIR}"
mkdir -p "${BUILD_WORK_DIR}"
cd "${BUILD_WORK_DIR}"

# 2. 准备 Linux 编译依赖包 (即使 apt 锁住也继续)
sudo apt-get update -y || true
sudo apt-get install -y build-essential clang flex bison gawk gettext git libncurses5-dev libssl-dev python3-distutils python3-pyelftools rsync unzip zlib1g-dev squashfs-tools device-tree-compiler swig python3-dev python3-setuptools || true

# 3. 拉取 iStoreOS 24.12 官方源码 (自动 DNS + 重试循环)
if [ ! -d "openwrt" ]; then
  until git clone --depth 1 https://github.com/istoreos/istoreos.git -b istoreos-24.12 openwrt || git clone --depth 1 https://github.com/istoreos/istoreos.git -b main openwrt; do
    echo "网络拉取重试中..."
    sleep 2
  done
  cd openwrt
  ./scripts/feeds update -a
  ./scripts/feeds install -a
else
  cd openwrt
fi

# 4. 植入 K50S DTS 设备树与板级驱动配置
mkdir -p target/linux/rockchip/dts/rockchip/
cp -f /mnt/d/Antigravity\ IDE数据文件夹/K50S-iStoreOS-24.10-Build/patches/target/linux/rockchip/dts/rk3568-roc-k50s.dts target/linux/rockchip/dts/rockchip/ 2>/dev/null || true
cp -f /mnt/d/Antigravity\ IDE数据文件夹/K50S-iStoreOS-24.10-Build/patches/target/linux/rockchip/dts/rk3568-roc-k50s.dtsi target/linux/rockchip/dts/rockchip/ 2>/dev/null || true

TARGET_MK="target/linux/rockchip/image/armv8.mk"
[ ! -f "$TARGET_MK" ] && TARGET_MK="target/linux/rockchip/image/Makefile"
if [ -f "$TARGET_MK" ] && ! grep -q "roceos_k50s" "$TARGET_MK"; then
  printf "\ndefine Device/roceos_k50s\n  DEVICE_VENDOR := ROCEOS\n  DEVICE_MODEL := K50S\n  SOC := rk3568\n  DEVICE_DTS := rockchip/rk3568-roc-k50s\n  UBOOT_IMAGE := k50s-rk3568-u-boot-rockchip.bin\n  SUPPORTED_DEVICES += roceos,k50s\n  DEVICE_PACKAGES := kmod-brcmfmac kmod-r8125 kmod-phy-realtek\nendef\nTARGET_DEVICES += roceos_k50s\n" >> "$TARGET_MK"
fi

# 5. 生成 .config 配置文件
echo "CONFIG_TARGET_rockchip=y" > .config
echo "CONFIG_TARGET_rockchip_armv8=y" >> .config
echo "CONFIG_TARGET_rockchip_armv8_DEVICE_roceos_k50s=y" >> .config
echo "CONFIG_PACKAGE_kmod-r8125=y" >> .config
echo "CONFIG_PACKAGE_kmod-r8169=y" >> .config
echo "CONFIG_PACKAGE_kmod-phy-realtek=y" >> .config
echo "CONFIG_PACKAGE_kmod-brcmfmac=y" >> .config
echo "CONFIG_PACKAGE_luci-app-store=y" >> .config
echo "CONFIG_PACKAGE_luci-app-quickstart=y" >> .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config

make defconfig
sed -i 's/CONFIG_PACKAGE_dnsmasq=y/# CONFIG_PACKAGE_dnsmasq is not set/' .config
make download -j$(nproc)

# 6. 注入 u-boot 并开启多核并发极速编译
mkdir -p staging_dir/target-aarch64_generic_musl/image/
mkdir -p build_dir/target-aarch64_generic_musl/linux-rockchip_armv8/
mkdir -p target/linux/rockchip/image/
mkdir -p bin/targets/rockchip/armv8/

UBOOT_SRC="/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/u-boot/k50s-rk3568-u-boot-rockchip.bin"
if [ -f "$UBOOT_SRC" ]; then
  cp -f "$UBOOT_SRC" staging_dir/target-aarch64_generic_musl/image/ 2>/dev/null || true
  cp -f "$UBOOT_SRC" target/linux/rockchip/image/ 2>/dev/null || true
  cp -f "$UBOOT_SRC" build_dir/target-aarch64_generic_musl/linux-rockchip_armv8/ 2>/dev/null || true
  cp -f "$UBOOT_SRC" bin/targets/rockchip/armv8/ 2>/dev/null || true
fi

echo "=== ⚡ 开启 K50S 多核并发极速编译 (使用的 CPU 核心数: $(nproc)) ==="
make -j$(nproc) V=s

echo "=== 🎉 K50S 本地编译完成！固件已存放在 D:\\K50S_Build\\openwrt\\bin\\targets\\rockchip\\armv8\\ ==="
