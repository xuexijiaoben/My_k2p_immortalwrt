#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

#!/bin/bash

function git_sparse_clone() {
    git clone --filter=blob:none --no-checkout --depth=1 $1 $2 && cd $2
    git sparse-checkout init --cone
    git sparse-checkout set $3
    git checkout
    mv $3 ../$4
    cd ../ && rm -rf $2
}

# Add mtkiappd support for 802.11 k/v/r
# git_sparse_clone https://github.com/coolsnowwolf/lede lede package/lean/mt/mtkiappd package/kernel/mt-drivers/mtkiappd

function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
    	echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}


# Add a feed source

# echo '添加omcproxy软件源'组播代理
# git clone -b 18.06 https://github.com/riverscn/luci-app-omcproxy.git package/luci-app-omcproxy

# git clone -b master --depth 1 https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git package/app/luci-app-unblockneteasemusic
git clone --depth 1 https://github.com/ilxp/luci-app-ikoolproxy.git package/app/luci-app-ikoolproxy

./scripts/feeds update -a

merge_package openwrt-23.05 https://github.com/coolsnowwolf/luci feeds/luci/applications applications/luci-app-pppwn
merge_package master https://github.com/coolsnowwolf/packages feeds/packages/multimedia multimedia/pppwn-cpp
merge_package master https://github.com/coolsnowwolf/luci feeds/luci/applications applications/luci-app-easymesh

./scripts/feeds install -a

# 修复feeds错误
sed -i 's/+libpcre/+libpcre2/g' package/feeds/telephony/freeswitch/Makefile

# echo '### Argon Theme Config ###'
rm -rf feeds/luci/themes/luci-theme-argon
# git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
git clone -b master https://github.com/jerrykuku/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-app-argon-config.git feeds/luci/applications/luci-app-argon-config

./scripts/feeds update -a
./scripts/feeds install -a
