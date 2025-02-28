CSS
---
- [CSS](#css)
  - [1. flex布局](#1-flex布局)
    - [1.1. 容器属性](#11-容器属性)
    - [1.2. 项目属性](#12-项目属性)
  - [2.Grid布局](#2grid布局)
    - [2.1. Grid 布局基础概念](#21-grid-布局基础概念)
    - [2.2. 容器属性](#22-容器属性)
    - [2.3. 子项属性与实例](#23-子项属性与实例)
  - [3. 实例：复杂布局（Header + Sidebar + Main）](#3-实例复杂布局header--sidebar--main)
- [三、CSS 动画](#三css-动画)
  - [1. 过渡动画（Transition）](#1-过渡动画transition)
  - [2. 关键帧动画（Keyframes）](#2-关键帧动画keyframes)
  - [3. 复杂动画：卡片3D翻转](#3-复杂动画卡片3d翻转)
- [四、总结对比](#四总结对比)


### 1. flex布局

#### 1.1. 容器属性
**容器属性用于定义 Flex 父容器的布局方式**，需设置 `display: flex` 或 `display: inline-flex`。

**1. `flex-direction`**

**作用**：定义主轴方向（项目的排列方向）。  
**取值**：  
- `row`（默认）：水平排列（从左到右）  
- `row-reverse`：水平反向排列（从右到左）  
- `column`：垂直排列（从上到下）  
- `column-reverse`：垂直反向排列（从下到上）  

```css
.container {
  display: flex;
  flex-direction: row-reverse; /* 项目从右向左排列 */
}
```

**2. `flex-wrap`**

**作用**：控制项目是否换行。  
**取值**：  
- `nowrap`（默认）：不换行，可能压缩项目宽度  
- `wrap`：换行（从上到下）  
- `wrap-reverse`：反向换行（从下到上）  

```css
.container {
  display: flex;
  flex-wrap: wrap; /* 空间不足时换行 */
}
```

**1. `justify-content`**  

**作用**：定义项目在 **主轴** 上的对齐方式。  
**取值**：  
- `flex-start`（默认）：向主轴起点对齐  
- `flex-end`：向主轴终点对齐  
- `center`：居中  
- `space-between`：两端对齐，项目间距相等  
- `space-around`：项目两侧间距相等  

```css
.container {
  display: flex;
  justify-content: space-between; /* 项目均匀分布 */
}
```

**4. `align-items`**

**作用**：定义项目在 **交叉轴** 上的对齐方式。  
**取值**：  
- `stretch`（默认）：拉伸填满容器高度  
- `flex-start`：向交叉轴起点对齐  
- `flex-end`：向交叉轴终点对齐  
- `center`：居中  
- `baseline`：按项目基线对齐  

```css
.container {
  display: flex;
  align-items: center; /* 垂直居中 */
}
```

#### 1.2. 项目属性

**项目属性用于控制 Flex 子项的具体行为**。

**1. `order`**  

**作用**：定义项目的排列顺序（数值越小越靠前）。  
**取值**：整数（默认 `0`）。  

```css
.item:nth-child(2) {
  order: -1; /* 第二个项目排到最前面 */
}
```

**2. `flex-basis`**

**作用**：定义项目在分配多余空间之前的初始大小。  
**取值**：长度值（如 `200px`）或 `auto`（默认）。  

```css
.item {
  flex-basis: 150px; /* 初始宽度 150px */
}
```

**3. `flex-grow`**

**作用**：定义项目的放大比例（剩余空间分配）。  
**取值**：数值（默认 `0`，不放大）。  

```css
.item-1 { flex-grow: 1; } /* 占据剩余空间的 1 份 */
.item-2 { flex-grow: 2; } /* 占据剩余空间的 2 份 */
```

**4. `flex-shrink`**  
**作用**：定义项目的缩小比例（空间不足时）。  
**取值**：数值（默认 `1`，允许缩小）。  

```css
.item {
  flex-shrink: 0; /* 禁止缩小 */
}
```

**5. `flex`**  
**作用**：`flex-grow`, `flex-shrink`, `flex-basis` 的简写。  
**语法**：`flex: [grow] [shrink] [basis]`  

```css
.item {
  flex: 1 0 200px; /* 放大比例1，不缩小，初始200px */
}
```

**6. `align-self`**

**作用**：覆盖容器的 `align-items`，定义单个项目的交叉轴对齐方式。  
**取值**：`auto | stretch | flex-start | flex-end | center | baseline`  

```css
.item-special {
  align-self: flex-end; /* 单个项目底部对齐 */
}
```

**实例：自适应三栏布局**
```html
<div class="container">
  <div class="item left">Left</div>
  <div class="item main">Main</div>
  <div class="item right">Right</div>
</div>

<style>
.container {
  display: flex;
  gap: 10px;
}
.left, .right {
  flex: 0 0 200px; /* 固定宽度 200px */
  background: #f0f0f0;
}
.main {
  flex: 1; /* 占据剩余空间 */
  background: #e0e0e0;
}
</style>
```


**实例：动态排序卡片**
```css
.card:nth-child(1) { order: 2; } 
.card:nth-child(2) { order: 1; }
.card:nth-child(3) { order: 3; }
```


### 2.Grid布局

#### 2.1. Grid 布局基础概念
Grid 布局是一种二维布局系统，通过行（row）和列（column）的组合来设计页面。  
**核心概念**：
- **容器（Container）**：通过 `display: grid` 定义 Grid 容器。
- **子项（Item）**：容器内的直接子元素自动成为 Grid 子项。
- **轨道（Track）**：由行和列形成的轨道。
- **单元格（Cell）**：行和列的交叉区域。
- **区域（Area）**：由多个单元格合并成的矩形区域。

#### 2.2. 容器属性

**1. 基础网格布局**

```html
<div class="grid-container">
  <div class="item">1</div>
  <div class="item">2</div>
  <div class="item">3</div>
  <div class="item">4</div>
  <div class="item">5</div>
  <div class="item">6</div>
</div>
```

```css
.grid-container {
  display: grid;
  grid-template-columns: 100px 200px 100px; /* 定义3列宽度 */
  grid-template-rows: 100px 150px;          /* 定义2行高度 */
  gap: 10px;                                /* 行和列间距 */
  background: #eee;
  padding: 10px;
}

.item {
  background: lightblue;
  padding: 20px;
  text-align: center;
}
```

**效果**：
```
[100px][200px][100px]  ← 列宽
|  1  |  2   |  3  |  ← 行高100px
|  4  |  5   |  6  |  ← 行高150px
间距：10px
```

**2. 自适应列（fr单位与auto-fit）**

```css
.grid-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr)); 
  /* 自动适应列数，每列最小150px，最大1fr（等分剩余空间） */
  gap: 10px;
}
```

**效果**：
- 容器宽度足够时，显示多列（每列≥150px）。
- 容器变窄时自动减少列数，类似响应式设计。

**3. 命名区域布局**

```css
.grid-container {
  display: grid;
  grid-template-areas:
    "header header header"
    "sidebar main main"
    "footer footer footer";
  grid-template-rows: 80px 1fr 60px;
  grid-template-columns: 200px 1fr;
  height: 100vh;
  gap: 10px;
}

.item1 { grid-area: header; background: #ff6b6b; }
.item2 { grid-area: sidebar; background: #4ecdc4; }
.item3 { grid-area: main; background: #ffe66d; }
.item4 { grid-area: footer; background: #8395a7; }
```

**对应 HTML**：
```html
<div class="grid-container">
  <div class="item1">Header</div>
  <div class="item2">Sidebar</div>
  <div class="item3">Main Content</div>
  <div class="item4">Footer</div>
</div>
```

**效果**：
```
┌───────────Header───────────┐
│ Sidebar │   Main Content   │
└───────────Footer───────────┘
```

---

#### 2.3. 子项属性与实例

**1. 合并单元格**

```css
.grid-container {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 5px;
}

.item1 {
  grid-column: 1 / 3;  /* 合并第1到第3列（占据前两列） */
  grid-row: 1;         /* 指定行位置 */
  background: #ff6b6b;
}

.item5 {
  grid-column: 2 / 4;  /* 合并第2到第4列 */
  grid-row: 2 / 4;     /* 合并第2到第4行 */
  background: #4ecdc4;
}
```

**效果**：
```

┌───┬───┐
│ 1 │ 2 │
├─┬─┴─┬─┤
│4│ 5 │6│
│ │   │ │
└─┴───┴─┘
```

---

**2. 对齐方式**
```css
.grid-container {
  display: grid;
  grid-template-columns: repeat(3, 100px);
  grid-template-rows: repeat(2, 100px);
  justify-content: center;     /* 水平居中整个网格 */
  align-content: center;       /* 垂直居中整个网格 */
  height: 400px;
  background: #eee;
}

.item {
  width: 80px;
  height: 80px;
  background: lightblue;
  display: flex;
  align-items: center;         /* 子项内部垂直居中 */
  justify-content: center;     /* 子项内部水平居中 */
}
```

**效果**：
- 网格整体在容器中居中。
- 每个子项内容居中显示。
---
   - [CSS Grid 可视化教程](https://cssgridgarden.com/)
   - [MDN Grid 文档](https://developer.mozilla.org/zh-CN/docs/Web/CSS/CSS_Grid_Layout)



### 3. 实例：复杂布局（Header + Sidebar + Main）
```html
<div class="layout">
  <header>Header</header>
  <aside>Sidebar</aside>
  <main>Main Content</main>
</div>

<style>
.layout {
  display: grid;
  grid-template-columns: 200px 1fr;       /* 侧边栏固定宽度 */
  grid-template-rows: 60px 1fr;           /* 头部高度固定 */
  height: 100vh;
  gap: 10px;
}
header {
  grid-column: 1 / -1;                   /* 跨全部列 */
  background: #4a90e2;
  padding: 20px;
}
aside {
  background: #f0f0f0;
  padding: 20px;
}
main {
  background: white;
  padding: 20px;
}
</style>
```
**效果**：经典的 Dashboard 布局，侧边栏固定，主内容区自适应。

---

## 三、CSS 动画
### 1. 过渡动画（Transition）
```css
.button {
  background: #3498db;
  transition: background 0.3s, transform 0.2s; /* 多属性动画 */
}
.button:hover {
  background: #2980b9;
  transform: scale(1.05);
}
```

### 2. 关键帧动画（Keyframes）
**实例：加载旋转动画**
```css
.loader {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #3498db;
  border-radius: 50%;
  animation: spin 1s linear infinite; /* 无限循环 */
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
```

### 3. 复杂动画：卡片3D翻转
```html
<div class="card">
  <div class="front">正面</div>
  <div class="back">背面</div>
</div>

<style>
.card {
  width: 200px;
  height: 200px;
  perspective: 1000px; /* 3D透视 */
}
.card:hover .inner {
  transform: rotateY(180deg);
}
.inner {
  position: relative;
  width: 100%;
  height: 100%;
  transition: transform 0.6s;
  transform-style: preserve-3d; /* 保持3D空间 */
}
.front, .back {
  position: absolute;
  width: 100%;
  height: 100%;
  backface-visibility: hidden; /* 隐藏背面 */
}
.back {
  transform: rotateY(180deg);
  background: #e74c3c;
}
</style>
```
**效果**：悬停时卡片3D翻转显示背面内容。

---

## 四、总结对比
| 特性                | Flex                        | Grid                       |
|--------------------|-----------------------------|---------------------------|
| **维度**           | 一维布局（主轴方向）          | 二维布局（行+列）           |
| **适用场景**       | 导航栏、等分布局              | 复杂网格、响应式布局         |
| **核心优势**       | 简单快速对齐                 | 精确控制行列关系            |

**动画建议**：
1. 优先使用 `transition` 实现简单交互
2. 复杂动画使用 `@keyframes`
3. 优化性能：避免频繁触发重绘（如 `transform` 比 `left/top` 更高效）

---

通过结合具体场景的代码示例，可以更直观地掌握 CSS3 的布局与动画技术。建议通过 [CodePen](https://codepen.io/) 或本地编辑器实践这些案例。