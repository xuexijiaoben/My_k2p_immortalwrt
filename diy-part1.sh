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
git_sparse_clone https://github.com/coolsnowwolf/lede lede package/lean/mt/mtkiappd package/kernel/mt-drivers/mtkiappd

# Add a feed source


# echo '添加omcproxy软件源'
git clone -b 18.06 https://github.com/riverscn/luci-app-omcproxy.git package/luci-app-omcproxy
