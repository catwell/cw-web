#!/bin/bash

cd "$(dirname "$0")/.."

_lua="$(pwd)/.lua/bin/lua"

pushd "cwinfo/booklist"
    "$_lua" generate.lua > ../site/booklist/index.html
    cp style.css ../site/booklist
popd
