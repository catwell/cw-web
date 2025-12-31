#!/bin/bash

cd "$(dirname "$0")/.."

_tl="$(pwd)/.lua/bin/tl"

pushd "separateconcerns/blog"
    "$_tl" run generate.tl
popd
