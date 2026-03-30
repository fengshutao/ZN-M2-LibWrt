#!/bin/bash

# 1. 修改默认 IP 地址 (由 1.1 改为 2.1)
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 2. 定义 Git 稀疏克隆函数
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 3. 移除 General.config 中明确禁用的包源码
# 注意：这里不再移除 feeds/luci/themes/luci-theme-argon，以保留原版
rm -rf feeds/luci/themes/luci-theme-aurora
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-sqm
rm -rf feeds/luci/applications/luci-app-wol
rm -rf feeds/luci/applications/luci-app-frpc
rm -rf feeds/luci/applications/luci-app-frps
rm -rf feeds/luci/applications/luci-app-samba4
rm -rf feeds/luci/applications/luci-app-aria2
rm -rf feeds/luci/applications/luci-app-wechatpush
rm -rf feeds/luci/applications/luci-app-oaf
rm -rf feeds/luci/applications/luci-app-ttyd
rm -rf feeds/luci/applications/luci-app-watchcat

# 4. 核心替换：彻底移除 PassWall 相关组件
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf package/passwall-packages

# 5. 更新 Golang 版本 (确保 OpenClash 编译兼容性)
rm -rf feeds/packages/lang/golang
git_sparse_clone master https://github.com/laipeng668/packages lang/golang
mv -f package/golang feeds/packages/lang/golang

# 6. 安装 OpenClash
rm -rf package/luci-app-openclash
git clone --depth=1 https://github.com/vernesong/OpenClash package/luci-app-openclash

# 7. 修正 feeds 索引并安装
./scripts/feeds update -a
./scripts/feeds install -a
