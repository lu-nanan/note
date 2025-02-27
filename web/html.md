HTML
===
---

- [HTML](#html)
  - [一、什么是 HTML？](#一什么是-html)
  - [二、HTML5 语法规范](#二html5-语法规范)
  - [三、结构标签](#三结构标签)
  - [四、第一个 HTML5 页面](#四第一个-html5-页面)
  - [五、字符集](#五字符集)
  - [六、基础标签详解](#六基础标签详解)
    - [1. 标题标签 h1-h6](#1-标题标签-h1-h6)
    - [2. 段落标签 p](#2-段落标签-p)
    - [3. 换行标签 br](#3-换行标签-br)
    - [4. 容器标签 div 和 span](#4-容器标签-div-和-span)
      - [4.1. `<div>` 标签（块级容器）](#41-div-标签块级容器)
      - [4.2. `<span>` 标签（内联容器）](#42-span-标签内联容器)
      - [4.3. 对比 `<div>` 和 `<span>`](#43-对比-div-和-span)
      - [4.4. 实际应用场景](#44-实际应用场景)
      - [6. 图片标签 img](#6-图片标签-img)
    - [7. 超链接标签 a](#7-超链接标签-a)
    - [8. 文本格式化标签](#8-文本格式化标签)
    - [9. 表格标签](#9-表格标签)
      - [9.1. 基础表格结构](#91-基础表格结构)
      - [9.2. 语义化表格标签](#92-语义化表格标签)
      - [9.3. 复杂表格操作](#93-复杂表格操作)
    - [10. 列表标签](#10-列表标签)
      - [10.1. 无序列表 `<ul>`](#101-无序列表-ul)
      - [10.2. 有序列表 `<ol>`](#102-有序列表-ol)
      - [10.3. 定义列表 `<dl>`](#103-定义列表-dl)
      - [10.4. 嵌套列表](#104-嵌套列表)
      - [10.5. 对比](#105-对比)
    - [11. 表单标签](#11-表单标签)
      - [11.1. 表单基础结构](#111-表单基础结构)
      - [11.2. 输入控件 `<input>`](#112-输入控件-input)
      - [11.3. 按钮与提交](#113-按钮与提交)
      - [11.4. HTML5 新增输入类型](#114-html5-新增输入类型)
      - [11.5. 表单验证示例](#115-表单验证示例)
      - [11.6. 标签与分组](#116-标签与分组)
      - [11.7. 表单标签与属性](#117-表单标签与属性)
    - [七、保留字符与实体](#七保留字符与实体)



## 一、什么是 HTML？
HTML（HyperText Markup Language）是用于创建网页的标准标记语言。HTML5 是 HTML 的最新版本，新增了语义化标签、多媒体支持（audio/video）、Canvas绘图等特性。

## 二、HTML5 语法规范
1. 文档类型声明：`<!DOCTYPE html>`
2. 标签闭合：单标签可省略闭合（如 `<br>`）
3. 元素嵌套：必须正确嵌套（禁止 `<p><div></p></div>`）
4. 属性规范：推荐小写，属性值用双引号包裹

## 三、结构标签
每个页面都会有一个基本的标签结构, 页面中能够看到的内容都需要写在结构标签中

| **标签名** |  **定义**  |                     **作用**                     |
| :--------: | :--------: | :----------------------------------------------: |
|    html    |  HTML标签  |          页面中最大的标签，常称为根标签          |
|    head    | 文档的头部 |      注意在head标签中我们必须设置title标签       |
|   title    | 文档的标题 |                  页面的网页标题                  |
|    body    | 文档的主体 | 包含文档的所有内容，页面的内容都要加载在body里面 |

## 四、第一个 HTML5 页面
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>我的第一个页面</title>
</head>
<body>
  <h1>Hello World!</h1>
</body>
</html>
```

## 五、字符集
`<meta charset="UTF-8">` 必须放在<head>的最前面，支持中文等多国语言显示

## 六、基础标签详解

### 1. 标题标签 h1-h6

h1-h6 是 HTML 中用于定义标题的标签, 分别表示一级标题到六级标题, 常用于网页的标题显示

```html
<h1>主标题</h1>
<h2>二级标题</h2>
<h3>三级标题</h3>
<!-- 以此类推 -->
```

### 2. 段落标签 p

p就是单词 paragraph 的缩写, 意为段落, 常用于定义段落, 将整个网页分为若干个段落

```html
<p>这是一个段落文本。</p>
<p>这是另一个段落，显示时会自动换行。</p>
```

### 3. 换行标签 br

br 是单词 break 的缩写, 意为换行, 常用于在段落中强制换行

```html
<p>第一行内容<br>强制换行的第二行</p>
```

### 4. 容器标签 div 和 span

#### 4.1. `<div>` 标签（块级容器）

`<div>` 是 **块级元素**，默认占据整行，适合包裹大块内容或布局分区。

**实例 1：页面布局**

```html
<div class="header">
  <h1>网站标题</h1>
  <nav>导航菜单</nav>
</div>

<div class="content">
  <div class="article">
    <h2>文章标题</h2>
    <p>文章内容...</p>
  </div>
  <div class="sidebar">
    <h3>侧边栏</h3>
    <p>推荐内容...</p>
  </div>
</div>

<div class="footer">
  <p>版权信息 © 2023</p>
</div>
```

- **作用**：通过嵌套 `<div>` 实现页面的逻辑分区（页眉、内容区、页脚）。
- **特点**：每个 `<div>` 默认换行显示，适合作为布局容器。

**实例 2：样式化容器**

```html
<div style="background: #f0f0f0; padding: 20px; border-radius: 5px;">
  <h2>提示框</h2>
  <p>这是一个带有背景色和圆角的提示信息。</p>
</div>
```
- **作用**：通过 CSS 为内容块添加统一样式（背景、边距等）。


#### 4.2. `<span>` 标签（内联容器）
`<span>` 是 **内联元素**，适合包裹少量文本或局部样式调整，不换行。

**实例 1：高亮文本**

```html
<p>这是一段包含<span style="color: red; font-weight: bold;">红色加粗</span>文字的内容。</p>
```
- **效果**：仅对 "红色加粗" 这四个字应用样式，其他文本不受影响。
- **特点**：内联显示，不会破坏段落结构。

**实例 2：动态修改内容**

```html
<p>当前温度：<span id="temperature">25</span>°C</p>
<button onclick="document.getElementById('temperature').textContent = '30'">更新温度</button>
```
- **作用**：通过 JavaScript 动态修改 `<span>` 内的温度值。

#### 4.3. 对比 `<div>` 和 `<span>`

**代码对比**

```html
<!-- div 示例 -->
<div style="background: lightblue;">块级元素（换行）</div>
<div style="background: lightgreen;">第二个块级元素</div>

<!-- span 示例 -->
<span style="background: pink;">内联元素（不换行）</span>
<span style="background: yellow;">第二个内联元素</span>
```
- **显示效果**：
  - `<div>` 会换行，形成两个独立矩形区域。
  - `<span>` 会在一行内连续显示，背景色可能重叠。

**嵌套规则**

```html
<div>
  这是一个块级容器，
  <span>可以包裹内联元素</span>。
</div>

<span>
  这是一个内联容器，
  <div>但不可以包裹块级元素！</div> <!-- 错误写法！ -->
</span>
```
- **规则**：`<span>` 内不能嵌套 `<div>` 等块级元素。


#### 4.4. 实际应用场景

**`<div>` 的典型用途**
1. **布局容器**：页眉、导航栏、卡片式布局。
2. **响应式设计**：通过 CSS Grid/Flexbox 实现复杂布局。
3. **脚本操作**：动态隐藏/显示整个区块。

**`<span>` 的典型用途**
1. **局部样式**：修改文字颜色、字体或背景。
2. **图标和按钮**：配合字体图标库（如 Font Awesome）。
3. **数据绑定**：在 Vue/React 中标记动态文本区域。

**经验法则**：  
- 需要换行或布局时用 `<div>`，处理文本片段用 `<span>`。
- HTML5 推荐优先使用语义化标签（如 `<header>`、`<section>`），但 `<div>` 和 `<span>` 仍是万能

#### 6. 图片标签 img
```html
<img src="logo.png" alt="网站Logo" width="200" height="100">
```
**属性说明：**
- src：图片路径（支持绝对/相对路径）
- alt：图片描述（SEO优化/图片加载失败时显示）
- width/height：建议使用CSS控制尺寸

### 7. 超链接标签 a
```html
<a href="https://www.example.com" target="_blank">访问示例网站</a>
<a href="#section2">跳转到第二节</a>
```
**属性说明：**
- href – 指定目标url
- target – 指定链接页面的打开方式
  - _blank 新页面打开
  - _self 当前页面打开


**锚点使用：**
```html
<h2 id="section2">第二节内容</h2>
```

### 8. 文本格式化标签

|  **标签**  | **作用** |
| :--------: | :------: |
|   `<b>`    | 加粗文本 |
| `<strong>` | 加粗文本 |
|   `<i>`    | 斜体文本 |
|   `<em>`   | 斜体文本 |
|  `<mark>`  | 标记文本 |
| `<small>`  | 小号文本 |
|  `<del>`   |  删除线  |
|  `<ins>`   |  下划线  |
|  `<sub>`   | 下标文本 |
|  `<sup>`   | 上标文本 |

**示例**：
```html
<p>这是一个 <b>加粗</b> 的文本。</p>
<p>这也是一个 <strong>加粗</strong> 的文本。</p>
<p>这是一个 <i>斜体</i> 的文本。</p>
<p>这也是一个 <em>斜体</em> 的文本。</p>
<p>这是一个 <mark>标记</mark> 的文本。</p>
<p>这是一个 <small>小号</small> 的文本。</p>
<p>这是一个 <del>删除</del> 的文本。</p>
<p>这是一个 <ins>下划</ins> 的文本。</p>
<p>这是一个 <sub>下标</sub> 的文本。</p>
<p>这是一个 <sup>上标</sup> 的文本。</p>
```

![20250226173524107.png](https://raw.githubusercontent.com/lu-nanan/PicList/main/upLoads/20250226173524107.png?token=BLOP47AKV3KOGHYNX53Y5EDHX3QJS)

### 9. 表格标签

HTML 表格用于展示结构化数据（如统计信息、课程表、产品列表等），通过 `<table>` 标签及其子标签（如 `<tr>`, `<td>`, `<th>` 等）实现


#### 9.1. 基础表格结构

**实例 1：最简单的表格**
```html
<table>
  <tr>
    <td>姓名</td>
    <td>年龄</td>
    <td>职业</td>
  </tr>
  <tr>
    <td>张三</td>
    <td>28</td>
    <td>工程师</td>
  </tr>
  <tr>
    <td>李四</td>
    <td>32</td>
    <td>设计师</td>
  </tr>
</table>
```
- **效果**：生成一个 3 行 3 列的表格，但无边框和表头。
- **核心标签**：
  - `<table>`：定义表格容器。
  - `<tr>`：定义表格行（Table Row）。
  - `<td>`：定义单元格（Table Data）。

#### 9.2. 语义化表格标签

**实例 2：带表头和分区的表格**

```html
<table border="1" style="width: 100%;">
  <caption>员工信息表</caption>
  <thead>
    <tr>
      <th>姓名</th>
      <th>年龄</th>
      <th>职位</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>张三</td>
      <td>28</td>
      <td>工程师</td>
    </tr>
    <tr>
      <td>李四</td>
      <td>32</td>
      <td>设计师</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td colspan="3">数据更新日期：2023-10-01</td>
    </tr>
  </tfoot>
</table>
```
- **效果**：带边框、标题、表头、正文和页脚的完整表格。
- **核心标签**：
  - `<th>`：表头单元格（默认加粗居中）。
  - `<caption>`：表格标题。
  - `<thead>`：表头区域。
  - `<tbody>`：表格主体。
  - `<tfoot>`：表格页脚。
- **属性**：
  - `border="1"`：添加边框
  - `colspan="3"`：合并 3 列单元格。


#### 9.3. 复杂表格操作

**实例 3：合并单元格**

```html
<table border="1">
  <tr>
    <th rowspan="2">部门</th>
    <th colspan="2">人数统计</th>
  </tr>
  <tr>
    <th>男性</th>
    <th>女性</th>
  </tr>
  <tr>
    <td>技术部</td>
    <td>50</td>
    <td>20</td>
  </tr>
  <tr>
    <td>市场部</td>
    <td>30</td>
    <td>40</td>
  </tr>
</table>
```

- **效果**：合并行（`rowspan`）和列（`colspan`）。
- **规则**：
  - `rowspan="2"`：合并两行（下方少一个 `<tr>`）。
  - `colspan="2"`：合并两列（右侧少一个 `<td>`）。

**实例 4：响应式表格**

```html
<div style="overflow-x: auto;">
  <table border="1">
    <tr>
      <th>产品名称</th>
      <th>价格</th>
      <th>库存</th>
      <th>销量</th>
      <th>评分</th>
    </tr>
    <tr>
      <td>笔记本电脑</td>
      <td>￥6999</td>
      <td>200</td>
      <td>150</td>
      <td>4.8</td>
    </tr>
  </table>
</div>
```
- **作用**：当表格过宽时，外层容器添加横向滚动条。

**实例 5：语义化与 ARIA**
```html
<table>
  <thead>
    <tr>
      <th scope="col">城市</th>
      <th scope="col">人口</th>
      <th scope="col">GDP（亿元）</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">北京</th>
      <td>2189万</td>
      <td>40269</td>
    </tr>
    <tr>
      <th scope="row">上海</th>
      <td>2487万</td>
      <td>43214</td>
    </tr>
  </tbody>
</table>
```
- **优化点**：
  - `scope="col"`：指明表头关联列。
  - `scope="row"`：指明表头关联行。
  - 提升屏幕阅读器的识别准确性。

**表格标签**
|     标签      |            作用            |         示例场景         |
| :-----------: | :------------------------: | :----------------------: |
|   `<table>`   |        定义表格容器        |     包裹所有表格内容     |
|    `<tr>`     |         定义表格行         |        每一行数据        |
|    `<td>`     |       定义普通单元格       | 具体数据（如数字、文本） |
|    `<th>`     | 定义表头单元格（加粗居中） |      列标题或行标题      |
|  `<caption>`  |        定义表格标题        |     表格的说明性标题     |
|   `<thead>`   |        定义表头区域        |       包含列标题行       |
|   `<tbody>`   |        定义表格主体        |        包含数据行        |
|   `<tfoot>`   |        定义表格页脚        |     汇总行或备注信息     |
|   `colspan`   |       合并列（横向）       |       跨列显示内容       |
|   `rowspan`   |       合并行（纵向）       |       跨行显示内容       |

### 10. 列表标签

HTML 列表用于展示一组相关项目，分为 **有序列表**、**无序列表** 和 **定义列表**。


#### 10.1. 无序列表 `<ul>`
**用途**：展示无顺序关系的项目（如导航菜单、功能列表）。  
**默认样式**：项目符号（如圆点 ●）。

**实例 1：基础无序列表**

```html
<ul>
  <li>苹果</li>
  <li>香蕉</li>
  <li>橙子</li>
</ul>
```

**实例 2：导航菜单（结合 CSS）**

```html
<nav>
  <ul style="list-style: none; padding: 0; display: flex; gap: 20px;">
    <li><a href="#home">首页</a></li>
    <li><a href="#news">新闻</a></li>
    <li><a href="#about">关于我们</a></li>
  </ul>
</nav>
```

**效果**：横向导航菜单，无项目符号。


#### 10.2. 有序列表 `<ol>`

**用途**：展示有顺序关系的项目（如步骤指南、排行榜）。  
**默认样式**：数字编号（1, 2, 3）。

**实例 1：基础有序列表**

```html
<ol>
  <li>准备材料</li>
  <li>搅拌面糊</li>
  <li>烘烤 20 分钟</li>
</ol>
```

**可选 `type` 值**：
- `1`：数字（默认）
- `A`：大写字母
- `a`：小写字母
- `I`：大写罗马数字
- `i`：小写罗马数字

#### 10.3. 定义列表 `<dl>`
**用途**：展示术语及其解释（如词汇表、键值对）。  
**结构**：
- `<dt>`：定义术语（Definition Term）
- `<dd>`：定义描述（Definition Description）

**实例：术语解释**
```html
<dl>
  <dt>HTML</dt>
  <dd>超文本标记语言，用于构建网页结构。</dd>
  
  <dt>CSS</dt>
  <dd>层叠样式表，用于设计网页样式。</dd>
</dl>
```

#### 10.4. 嵌套列表

**用途**：创建多级结构（如多级菜单、大纲）。

**实例：多级菜单**

```html
<ul>
  <li>电子产品
    <ul>
      <li>手机</li>
      <li>笔记本
        <ul>
          <li>游戏本</li>
          <li>轻薄本</li>
        </ul>
      </li>
    </ul>
  </li>
  <li>家电</li>
</ul>
```

#### 10.5. 对比
| 列表类型      | 标签              | 适用场景                   | 默认样式       |
|---------------|-------------------|---------------------------|----------------|
| **无序列表**  | `<ul>` + `<li>`   | 导航、项目符号列表         | 圆点 ●         |
| **有序列表**  | `<ol>` + `<li>`   | 步骤、排名、目录           | 数字 1, 2, 3   |
| **定义列表**  | `<dl>` + `<dt>` + `<dd>` | 术语解释、键值对 | 术语左对齐，描述缩进 |


### 11. 表单标签

HTML 表单用于收集用户输入的数据，包括文本框、单选框、复选框、下拉列表等。通过 `<form>` 标签定义表单容器，使用 `<input>`、`<select>`、`<textarea>` 等标签定义表单元素。

#### 11.1. 表单基础结构

**`<form>` 标签**

定义表单容器，包裹所有表单元素，通过 `action` 和 `method` 控制数据提交方式。

```html
<form action="/submit" method="POST">
  <!-- 表单元素 -->
</form>
```
- **关键属性**：
  - `action`：数据提交的服务器 URL。
  - `method`：HTTP 请求方法（`GET` 或 `POST`）。
  - `enctype`：编码类型（如上传文件需设为 `multipart/form-data`）。

#### 11.2. 输入控件 `<input>`

`<input>` 是最常用的表单元素，通过 `type` 属性定义不同输入类型。

**文本输入**

```html
<label for="username">用户名：</label>
<input type="text" id="username" name="username" placeholder="请输入用户名" required>
```
- **属性说明**：
  - `type="text"`：单行文本输入。
  - `name`：数据提交时的键名。
  - `placeholder`：输入框提示文字。
  - `required`：必填字段（HTML5 验证）。

**密码输入**

```html
<label for="password">密码：</label>
<input type="password" id="password" name="password" minlength="6">
```
- **属性说明**：
  - `type="password"`：隐藏输入内容。
  - `minlength="6"`：最小输入长度。

**单选按钮（Radio）**

```html
<label>性别：</label>
<input type="radio" id="male" name="gender" value="male" checked>
<label for="male">男</label>
<input type="radio" id="female" name="gender" value="female">
<label for="female">女</label>
```

- **属性说明**：
  - `type="radio"`：单选按钮。
  - `name` 相同：确保单选互斥。
  - `checked`：默认选中。

**复选框（Checkbox）**

```html
<label>爱好：</label>
<input type="checkbox" id="music" name="hobby" value="music">
<label for="music">音乐</label>
<input type="checkbox" id="sports" name="hobby" value="sports">
<label for="sports">运动</label>
```
- **属性说明**：
  - `type="checkbox"`：多选按钮。
  - `value`：提交时的值。

**下拉列表 `<select>`**

```html
<label for="country">国家：</label>
<select id="country" name="country">
  <option value="cn">中国</option>
  <option value="us">美国</option>
  <option value="jp" selected>日本</option>
</select>
```
- **属性说明**：
  - `<option>`：定义选项。
  - `selected`：默认选中项。

**多行文本 `<textarea>`**

```html
<label for="bio">个人简介：</label>
<textarea id="bio" name="bio" rows="4" cols="50" maxlength="200"></textarea>
```
- **属性说明**：
  - `rows` 和 `cols`：定义行数和列数。
  - `maxlength`：最大输入字符数。

**文件上传**

```html
<label for="avatar">上传头像：</label>
<input type="file" id="avatar" name="avatar" accept="image/png, image/jpeg">
```
- **属性说明**：
  - `type="file"`：文件上传控件。
  - `accept`：限制文件类型（如 `image/*`）。


#### 11.3. 按钮与提交

**提交按钮**

```html
<button type="submit">提交表单</button>
<!-- 或 -->
<input type="submit" value="提交">
```

**重置按钮**

```html
<button type="reset">重置</button>
```

**普通按钮**

```html
<button type="button" onclick="alert('点击事件')">普通按钮</button>
```

#### 11.4. HTML5 新增输入类型

**邮箱验证**

```html
<input type="email" name="email" required>
```

**数字输入**
```html
<input type="number" name="age" min="18" max="100" step="1">
```

**日期选择**
```html
<input type="date" name="birthday">
```

**颜色选择**
```html
<input type="color" name="favcolor">
```

#### 11.5. 表单验证示例
```html
<form action="/submit" method="POST">
  <label for="phone">手机号：</label>
  <input type="tel" id="phone" name="phone" pattern="[0-9]{11}" required>
  
  <label for="url">个人主页：</label>
  <input type="url" id="url" name="url" placeholder="https://example.com">
  
  <button type="submit">提交</button>
</form>
```
- **验证属性**：
  - `pattern`：正则表达式验证（如手机号格式）。
  - `required`：强制必填。
  - `min`/`max`：数值范围限制。

#### 11.6. 标签与分组

**`<label>` 标签**

通过 `for` 属性关联输入控件，提升可访问性：
```html
<label for="email">邮箱：</label>
<input type="email" id="email" name="email">
```

**`<fieldset>` 和 `<legend>`**

分组表单元素：
```html
<fieldset>
  <legend>用户信息</legend>
  <!-- 表单元素 -->
</fieldset>
```

---

#### 11.7. 表单标签与属性
| 标签/属性              | 作用                          | 示例                          |
|-----------------------|-----------------------------|------------------------------|
| `<form>`              | 表单容器                      | `<form action="/submit">`     |
| `<input>`             | 输入控件（根据 `type` 变化）   | `<input type="text">`         |
| `<textarea>`          | 多行文本输入                   | `<textarea rows="4">`         |
| `<select>` + `<option>` | 下拉选择列表                  | `<select><option>...</select>`|
| `<button>`            | 按钮                         | `<button type="submit">`      |
| `name`                | 数据提交的键名                | `name="username"`             |
| `required`            | 必填字段                     | `<input required>`            |
| `placeholder`         | 输入提示文字                 | `placeholder="请输入"`         |
| `pattern`             | 正则表达式验证               | `pattern="[A-Za-z]{3}"`       |



### 七、保留字符与实体

**常用保留字符**
| 字符 | 描述           | 实体名称   | 实体编号  | 示例代码           |
|------|----------------|------------|-----------|--------------------|
| `<`  | 小于号         | `&lt;`     | `&#60;`   | `&lt;` → <        |
| `>`  | 大于号         | `&gt;`     | `&#62;`   | `&gt;` → >        |
| `&`  | 和号           | `&amp;`    | `&#38;`   | `&amp;` → &       |
| `"`  | 双引号         | `&quot;`   | `&#34;`   | `&quot;` → "      |
| `'`  | 单引号         | `&apos;`   | `&#39;`   | `&apos;` → '      |


**空格与格式控制符**
| 字符          | 描述             | 实体名称     | 实体编号   | 示例代码             |
|---------------|------------------|--------------|------------|----------------------|
| ` `           | 普通空格         | `&nbsp;`     | `&#160;`   | `&nbsp;` →         |
| ` `         | 全角空格         | `&emsp;`     | `&#8195;`  | `&emsp;` →       |
| ` `         | 半角空格         | `&ensp;`     | `&#8194;`  | `&ensp;` →       |
| `↵`          | 换行符           | `&crarr;`    | `&#8629;`  | `&crarr;` → ↵     |


**数学符号**
| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `×`         | 乘号             | `&times;`     | `&#215;`   | `&times;` → ×      |
| `÷`         | 除号             | `&div;`       | `&#247;`   | `&div;` → ÷        |
| `±`         | 正负号           | `&plusmn;`    | `&#177;`   | `&plusmn;` → ±    |
| `≠`         | 不等于           | `&ne;`        | `&#8800;`  | `&ne;` → ≠         |
| `≤`         | 小于等于         | `&le;`        | `&#8804;`  | `&le;` → ≤         |
| `≥`         | 大于等于         | `&ge;`        | `&#8805;`  | `&ge;` → ≥         |
| `√`         | 根号             | `&radic;`     | `&#8730;`  | `&radic;` → √      |
| `∑`         | 求和符号         | `&sum;`       | `&#8721;`  | `&sum;` → ∑       |

**货币符号**

| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `€`         | 欧元             | `&euro;`      | `&#8364;`  | `&euro;` → €        |
| `¥`         | 日元/人民币      | `&yen;`       | `&#165;`   | `&yen;` → ¥         |
| `£`         | 英镑             | `&pound;`     | `&#163;`   | `&pound;` → £       |
| `¢`         | 美分             | `&cent;`      | `&#162;`   | `&cent;` → ¢        |

**箭头符号**

| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `←`         | 左箭头           | `&larr;`      | `&#8592;`  | `&larr;` → ←       |
| `→`         | 右箭头           | `&rarr;`      | `&#8594;`  | `&rarr;` → →       |
| `↑`         | 上箭头           | `&uarr;`      | `&#8593;`  | `&uarr;` → ↑       |
| `↓`         | 下箭头           | `&darr;`      | `&#8595;`  | `&darr;` → ↓       |


**版权与商标符号**

| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `©`         | 版权符号         | `&copy;`      | `&#169;`   | `&copy;` → ©        |
| `®`         | 注册商标         | `&reg;`       | `&#174;`   | `&reg;` → ®         |
| `™`         | 商标符号         | `&trade;`     | `&#8482;`  | `&trade;` → ™      |

**希腊字母（部分示例）**

| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `Α`         | 大写 Alpha       | `&Alpha;`     | `&#913;`   | `&Alpha;` → Α      |
| `α`         | 小写 Alpha       | `&alpha;`     | `&#945;`   | `&alpha;` → α      |
| `Ω`         | 大写 Omega       | `&Omega;`     | `&#937;`   | `&Omega;` → Ω      |
| `ω`         | 小写 Omega       | `&omega;`     | `&#969;`   | `&omega;` → ω      |

**其他常用符号**

| 字符          | 描述             | 实体名称      | 实体编号   | 示例代码             |
|---------------|------------------|---------------|------------|----------------------|
| `♥`         | 心形符号         | `&hearts;`    | `&#9829;`  | `&hearts;` → ♥     |
| `★`         | 实心星号         | `&starf;`     | `&#9733;`  | `&starf;` → ★      |
| `☆`         | 空心星号         | `&star;`      | `&#9734;`  | `&star;` → ☆       |
| `¶`         | 段落符号         | `&para;`      | `&#182;`   | `&para;` → ¶       |



