#!/bin/bash

cd "$(dirname "$0")/.."

_lua="$(pwd)/.lua/bin/lua"

pushd "separateconcerns/blog"
    "$_lua" generate.lua
popd
