#### 1. 推送远程仓库

```bash
git status                  # 查看修改
git add .                   # 添加所有变更
git commit -m "commit 的信息"     # 提交到本地
git pull origin 分支名        # 拉取最新代码
git push origin 分支名        # 推送到远程
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