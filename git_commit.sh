#!/bin/bash
# Bash script for push of new upgraded code.


read -p "Write commit message:" message

git add . -A 
git remote set-url origin git@github.com:Ciusss89/REflectometry-board-hb.git
git remote set-url origin https://github.com/Ciusss89/REflectometry-board-hb.git
git add ./*
git commit -m "$message "
git push
