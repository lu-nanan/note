#### 1. 推送远程仓库

**推送到当前分支**：

```bash
git status                  # 查看修改
git add .                   # 添加所有变更
o     # 提交到本地
git pull origin 分支名        # 拉取最新代码
git push origin 分支名        # 推送到远程
```

**建立新的分支**：

```bash
# 1. 创建并切换到新分支
git checkout -b new-feature

# 2. 添加一些内容（必须有至少一个提交）
# .... 假装这里修改了内容。
git add .
git commit -m "Init new feature"

# 3. 推送到远程仓库（自动创建远程分支）
git push -u origin new-feature
```
#### 2. 解决冲突

在提交到本地之后，使用pull命令拉取最新的分支
（检查远程是否有新的更新，如果有，需要在本地解决）

```bash
git pull origin 分支名
```

若有冲突，如下：

```bash
lunanan@lunanandeMacBook-Pro note-1 % git pull origin main  
From https://github.com/lu-nanan/note
 * branch            main       -> FETCH_HEAD
Auto-merging text.md
CONFLICT (content): Merge conflict in text.md
Automatic merge failed; fix conflicts and then commit the result.
```

提示 text.md 存在冲突，当然也可以使用如下命令查看所有冲突的文件：

```bash
git diff --name-only --diff-filter=U
```

打开冲突文件，查看具体的冲突内容：

![[Git_文件冲突示例.png]]

一般的，文件格式如下所示：

```text
<<<<<<< HEAD
你的本地修改内容
=======
远程仓库的修改内容
>>>>>>> commit-hash
```

编辑文件，解决冲突：
- 保留需要的部分（或合并两部分）
- **删除所有冲突标记**（`<<<<<<<`, `=======`, `>>>>>>>`）

重新提交合并后的内容到本地仓库，并"签字画押"

```bash
lunanan@lunanandeMacBook-Pro note-1 % git add text.md
lunanan@lunanandeMacBook-Pro note-1 % git commit -m "fix: resolve merge conflict in text.md"    
[main 1ca3d8c] fix: resolve merge conflict in text.md
```

最后，重新推送到远程仓库

```bash
git push origin main
```

![[Git_文件冲突解决结果.png]]
#### 3. 回滚

```bash
# 1. 查看提交历史
git log --oneline

# 2. 找到要撤销的提交ID (例如: abc1234)
# 3. 执行回滚
git revert abc1234

# 4. 解决可能出现的冲突
# 5. 提交回滚
git commit -m "Revert '有问题的提交说明'"

# 6. 推送到远程
git push origin main
```

#### 4. 从历史版本恢复指定文件

```bash
git checkout <提交哈希> -- <文件名>

# 恢复多个文件
git checkout <提交哈希> -- <文件1> <文件2> <文件3>
```

恢复之后在重新提交：

```bash

git add <文件名>

git commit -m "撤回指定文件的修改"

```