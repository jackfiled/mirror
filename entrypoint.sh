#!/usr/bin/env bash
set -e

if [[ "${DEBUG}" -eq "true" ]]; then
    set -x
fi

# Set git configurations
git config --global --add safe.directory /github/workspace
git config --global credential.username jackfiled
git config --global core.askPass $PWD/cred-helper.sh
git config --global credential.helper cache

# Mirror leetcode repo

git clone --bare https://git.rrricardo.top/jackfiled/leetcode.git
cd leetcode.git
git push --mirror https://github.com/jackfiled/leetcode-rust.git
cd ..

# Mirror YaeBlog repo

git clone --bare https://git.rrricardo.top/jackfiled/YaeBlog.git
cd YaeBlog.git
git lfs fetch --all
git lfs push --all https://github.com/jackfiled/YaeBlog.git
git push --mirror https://github.com/jackfiled/YaeBlog.git
cd ..

# Mirror LeetCodeSharp repo

git clone --bare https://git.rrricardo.top/jackfiled/LeetCodeSharp.git
cd LeetCodeSharp.git
git push --mirror https://github.com/jackfiled/LeetCodeSharp.git
cd ..
