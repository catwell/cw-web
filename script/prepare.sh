#!/bin/bash

cd "$(dirname "$0")/.."

curl https://loadk.com/localua.sh -O
sh localua.sh .lua

./.lua/bin/luarocks install djot
./.lua/bin/luarocks install lustache
./.lua/bin/luarocks install penlight
./.lua/bin/luarocks install tl
