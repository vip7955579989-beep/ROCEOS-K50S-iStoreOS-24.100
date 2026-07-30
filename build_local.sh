#!/bin/bash
set -e

echo "=================================================="
echo "=== 1. 清理并进入 Linux 本地工作目录 ==="
echo "=================================================="
cd /home/builder
sudo rm -rf openwrt

echo "=================================================="
echo "=== 2. 克隆 iStoreOS 24.10 官方源码 ==="
echo "=================================================="
git clone https://github.com/istoreos/istoreos.git -b istoreos-24.10 openwrt
cd openwrt

echo "=================================================="
echo "=== 3. 更新与安装 Feeds 软件源 ==="
echo "=================================================="
./scripts/feeds update -a
./scripts/feeds install -a

echo "=================================================="
echo "=== 4. 植入 K50S DTS 设备树与物理网络配置 ==="
echo "=================================================="
mkdir -p target/linux/rockchip/dts/rockchip/
cp -f "/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/patches/target/linux/rockchip/dts/rk3568-roc-k50s.dts" target/linux/rockchip/dts/rockchip/
cp -f "/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/patches/target/linux/rockchip/dts/rk3568-roc-k50s.dtsi" target/linux/rockchip/dts/rockchip/

TARGET_MK="target/linux/rockchip/image/armv8.mk"
[ ! -f "$TARGET_MK" ] && TARGET_MK="target/linux/rockchip/image/Makefile"
if [ -f "$TARGET_MK" ]; then
  cat << 'DEVICE_EOF' >> "$TARGET_MK"

define Device/roceos_k50s
  $(call Device/rk3568)
  DEVICE_VENDOR := ROCEOS
  DEVICE_MODEL := K50S
  SOC := rk3568
  DEVICE_DTS := rockchip/rk3568-roc-k50s
  UBOOT_IMAGE := k50s-rk3568-u-boot-rockchip.bin
  SUPPORTED_DEVICES += roceos,k50s
  DEVICE_PACKAGES := kmod-brcmfmac
endef
TARGET_DEVICES += roceos_k50s
DEVICE_EOF
fi

mkdir -p staging_dir/target-aarch64_generic_musl/image/
mkdir -p build_dir/target-aarch64_generic_musl/linux-rockchip_armv8/
mkdir -p target/linux/rockchip/image/
cp -f "/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/u-boot/k50s-rk3568-u-boot-rockchip.bin" staging_dir/target-aarch64_generic_musl/image/k50s-rk3568-u-boot-rockchip.bin 2>/dev/null || true
cp -f "/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/u-boot/k50s-rk3568-u-boot-rockchip.bin" target/linux/rockchip/image/k50s-rk3568-u-boot-rockchip.bin 2>/dev/null || true


mkdir -p files/etc/board.d/
mkdir -p files/etc/uci-defaults/
cp -f "/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/files/etc/board.d/02_network" files/etc/board.d/02_network

cat << 'UCI_EOF' > files/etc/uci-defaults/99-custom-k50s
#!/bin/sh
uci set network.lan.ipaddr='192.168.100.1'
uci set system.@system[0].timezone='CST-8'
uci set system.@system[0].zonename='Asia/Shanghai'
uci commit network
uci commit system
exit 0
UCI_EOF
chmod +x files/etc/uci-defaults/99-custom-k50s

echo "=================================================="
echo "=== 5. 集成 OpenClash 等第三方核心插件 ==="
echo "=================================================="
git clone --depth 1 -b master https://github.com/vernesong/OpenClash.git /tmp/openclash
cp -r /tmp/openclash/luci-app-openclash package/luci-app-openclash
rm -rf /tmp/openclash
./scripts/feeds update -a
./scripts/feeds install -a

echo "=================================================="
echo "=== 6. 生成编译配置文件 .config ==="
echo "=================================================="
cat << 'CFG_EOF' > .config
CONFIG_TARGET_rockchip=y
CONFIG_TARGET_rockchip_armv8=y
CONFIG_TARGET_rockchip_armv8_DEVICE_roceos_k50s=y
CONFIG_TARGET_KERNEL_PARTSIZE=128
CONFIG_TARGET_ROOTFS_PARTSIZE=3072
CONFIG_PACKAGE_kmod-r8125=y
CONFIG_PACKAGE_kmod-r8169=y
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-uas=y
CONFIG_PACKAGE_kmod-ata-ahci=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-exfat=y
CONFIG_PACKAGE_kmod-fs-ntfs3=y
CONFIG_PACKAGE_luci-app-store=y
CONFIG_PACKAGE_luci-app-quickstart=y
CONFIG_PACKAGE_dnsmasq=n
CONFIG_PACKAGE_dnsmasq-full=y
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_dnsmasq_full_ipset=y
CONFIG_PACKAGE_dnsmasq_full_nftset=y
CONFIG_PACKAGE_luci-app-openclash=y
CONFIG_PACKAGE_luci-app-dockerman=y
CONFIG_PACKAGE_luci-app-samba4=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-diskman=y
CFG_EOF

make defconfig
echo "=================================================="
echo "=== 7. 下载源码依赖包与固件库 ==="
echo "=================================================="
make download -j8
find dl -size -1024c -exec rm -f {} \;

echo "=================================================="
echo "=== 8. 开始并行编译生成固件 (请保持电脑开机) ==="
echo "=================================================="
make -j$(nproc) || make -j1 V=s

echo "=================================================="
echo "=== 9. 拷贝产物至本地 Windows 项目目录 ==="
echo "=================================================="
OUT_DIR="/mnt/d/Antigravity IDE数据文件夹/K50S-iStoreOS-24.10-Build/bin_out"
mkdir -p "$OUT_DIR"
cp -f bin/targets/rockchip/armv8/*sysupgrade.img.gz "$OUT_DIR/" 2>/dev/null || true
cp -f bin/targets/rockchip/armv8/*.img "$OUT_DIR/" 2>/dev/null || true

echo "=================================================="
echo "=== 🎉 恭喜！本地 K50S iStoreOS 24.10 固件编译成功！ ==="
echo "=== 固件放置目录: D:\\Antigravity IDE数据文件夹\\K50S-iStoreOS-24.10-Build\\bin_out\\"
echo "=================================================="
