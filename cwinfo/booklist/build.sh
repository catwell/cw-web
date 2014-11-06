#!/bin/sh
luajit generate.lua > ../site/booklist/index.html
cp style.css ../site/booklist
cp -r imgs ../site/booklist
