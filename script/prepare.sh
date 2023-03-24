#!/bin/bash

cd "$(dirname "$0")/.."

curl https://loadk.com/localua.sh -O
sh localua.sh .lua

./.lua/bin/luarocks install lunamark
./.lua/bin/luarocks install lustache
./.lua/bin/luarocks install penlight

