#!/bin/bash

dt="Post at "`date "+%Y-%m-%d %H:%M:%S"`
git add .
git commit -m "$dt"
git push origin master:hexo
