JavaScript
===
---

- [JavaScript](#javascript)
    - [**1. JavaScript 简介**](#1-javascript-简介)
      - [**历史与ECMAScript标准**](#历史与ecmascript标准)
    - [**2. 基础语法**](#2-基础语法)
      - [**变量声明**](#变量声明)
      - [**数据类型**](#数据类型)
      - [**类型转换与检测**](#类型转换与检测)
      - [**运算符与表达式**](#运算符与表达式)
      - [**流程控制**](#流程控制)
    - [**3. 函数与作用域**](#3-函数与作用域)
      - [**函数定义与调用**](#函数定义与调用)
      - [**参数传递**](#参数传递)
      - [**作用域与作用域链**](#作用域与作用域链)
      - [**闭包原理**](#闭包原理)
      - [**`this`关键字的指向**](#this关键字的指向)
    - [**4. 核心数据结构与操作**](#4-核心数据结构与操作)
      - [**4.1. 数组与对象**](#41-数组与对象)
      - [**4.2. 内置对象**](#42-内置对象)
    - [**5. DOM与BOM操作**](#5-dom与bom操作)
      - [**5.1. DOM编程**](#51-dom编程)
      - [**5.2. BOM（浏览器对象模型）**](#52-bom浏览器对象模型)
    - [**6. 异步编程与网络请求**](#6-异步编程与网络请求)
      - [**6.1. 回调函数**](#61-回调函数)
      - [**6.2. Promise（链式调用）**](#62-promise链式调用)
      - [**6.3. async/await 语法糖**](#63-asyncawait-语法糖)
      - [**6.3. 网络请求**](#63-网络请求)
    - [**7. 现代JavaScript（ES6+）**](#7-现代javascriptes6)
      - [**7.1. ES6+新特性**](#71-es6新特性)



### **1. JavaScript 简介**
#### **历史与ECMAScript标准**
- **JavaScript** 由Brendan Eich在1995年开发，最初用于浏览器交互。
- **ECMAScript（ES）** 是JavaScript的标准化规范，目前主流版本是ES6（2015）及后续更新（ES7+）。
- 示例：ES6新增了`let`、`const`、箭头函数等语法。

### **2. 基础语法**

#### **变量声明**

- **`var`**：传统声明方式，存在变量提升和函数作用域。
  ```javascript
  var name = "Alice";
  console.log(name); // "Alice"
  ```
- **`let`**：块级作用域，不可重复声明。
  ```javascript
  let age = 25;
  if (true) {
    let age = 30; // 新的块级作用域
    console.log(age); // 30
  }
  console.log(age); // 25
  ```
- **`const`**：声明常量，不可重新赋值（对象属性可修改）。
  ```javascript
  const PI = 3.14;
  const user = { name: "Bob" };
  user.name = "Charlie"; // 允许修改属性
  ```

#### **数据类型**
- **原始类型**（按值传递）：
  ```javascript
  let num = 42;          // Number
  let str = "Hello";     // String
  let bool = true;       // Boolean
  let empty = null;      // Null（表示空值）
  let notDefined;        // Undefined（未赋值）
  let sym = Symbol("id");// Symbol（唯一标识符）
  let big = 123n;        // BigInt（大整数）
  ```
- **引用类型**（按引用传递）：
  ```javascript
  let obj = { key: "value" }; // Object
  let arr = [1, 2, 3];        // Array
  ```

#### **类型转换与检测**
- **隐式转换**：
  ```javascript
  console.log("5" + 3);      // "53"（字符串拼接）
  console.log("5" - 2);      // 3（自动转数字）
  ```
- **显式转换**：
  ```javascript
  let numStr = "123";
  console.log(Number(numStr)); // 123
  console.log(String(123));    // "123"
  ```
- **类型检测**：
  ```javascript
  console.log(typeof "Hello"); // "string"
  console.log([] instanceof Array); // true
  ```

#### **运算符与表达式**
- **算术运算符**：`+`、`-`、`*`、`/`、`%`、`**`
- **比较运算符**：`==`（值相等）、`===`（值和类型相等）
  ```javascript
  console.log(5 == "5");  // true（类型转换后相等）
  console.log(5 === "5"); // false（类型不同）
  ```
- **逻辑运算符**：`&&`、`||`、`!`
  ```javascript
  let age = 20;
  console.log(age > 18 && age < 30); // true
  ```

#### **流程控制**
- **条件语句**：
  ```javascript
  let score = 85;
  if (score >= 90) {
    console.log("A");
  } else if (score >= 80) {
    console.log("B"); // 输出B
  } else {
    console.log("C");
  }

  // switch语句
  let day = "Monday";
  switch (day) {
    case "Monday":
      console.log("工作日");
      break;
    default:
      console.log("休息日");
  }
  ```
- **循环语句**：
  ```javascript
  // for循环
  for (let i = 0; i < 5; i++) {
    console.log(i); // 0,1,2,3,4
  }

  // while循环
  let count = 3;
  while (count > 0) {
    console.log(count--); // 3,2,1
  }
  ```

---

### **3. 函数与作用域**
#### **函数定义与调用**
- **声明式函数**：
  ```javascript
  function greet(name) {
    return `Hello, ${name}!`;
  }
  console.log(greet("Alice")); // "Hello, Alice!"
  ```
- **函数表达式**：
  ```javascript
  const add = function(a, b) {
    return a + b;
  };
  console.log(add(2, 3)); // 5
  ```
- **箭头函数**（ES6）：
  ```javascript
  const multiply = (a, b) => a * b;
  console.log(multiply(4, 5)); // 20
  ```

#### **参数传递**
- **默认参数**：
  ```javascript
  function createUser(name, role = "user") {
    return { name, role };
  }
  console.log(createUser("Bob")); // { name: "Bob", role: "user" }
  ```
- **剩余参数**：
  ```javascript
  function sum(...numbers) {
    return numbers.reduce((acc, num) => acc + num, 0);
  }
  console.log(sum(1, 2, 3)); // 6
  ```

#### **作用域与作用域链**
- **全局作用域**：在函数外声明的变量。
- **函数作用域**：`var`声明的变量属于函数作用域。
- **块级作用域**：`let`/`const`声明的变量属于块级作用域（如`if`、`for`）。
  ```javascript
  function scopeDemo() {
    var x = 10;       // 函数作用域
    if (true) {
      let y = 20;     // 块级作用域
      var z = 30;     // 函数作用域（泄漏到外层）
    }
    console.log(x, z); // 10,30
    console.log(y);    // 报错：y未定义
  }
  ```

#### **闭包原理**
- **闭包**：函数访问其外部作用域的变量，即使外部函数已执行完毕。
  ```javascript
  function createCounter() {
    let count = 0;
    return function() {
      return ++count;
    };
  }
  const counter = createCounter();
  console.log(counter()); // 1
  console.log(counter()); // 2
  ```

#### **`this`关键字的指向**
- **默认绑定**：函数独立调用时，`this`指向全局对象（浏览器中为`window`）。
  ```javascript
  function showThis() {
    console.log(this); // 浏览器中输出window
  }
  showThis();
  ```
- **隐式绑定**：作为对象方法调用时，`this`指向调用对象。
  ```javascript
  const user = {
    name: "Alice",
    sayHi() {
      console.log(`Hi, ${this.name}!`);
    }
  };
  user.sayHi(); // "Hi, Alice!"
  ```
- **显式绑定**：通过`call`、`apply`、`bind`指定`this`。
  ```javascript
  function greet() {
    console.log(`Hello, ${this.name}`);
  }
  const person = { name: "Bob" };
  greet.call(person); // "Hello, Bob"
  ```

### **4. 核心数据结构与操作**

#### **4.1. 数组与对象**
**数组操作**

- **增删元素**：
  ```javascript
  let fruits = ["apple", "banana"];
  fruits.push("orange");   // 末尾添加 ["apple", "banana", "orange"]
  fruits.pop();            // 删除末尾元素 ["apple", "banana"]
  fruits.unshift("grape"); // 开头添加 ["grape", "apple", "banana"]
  fruits.shift();          // 删除开头元素 ["apple", "banana"]
  ```

- **高阶函数**（处理数组元素）：
  ```javascript
  // map：映射新数组
  let numbers = [1, 2, 3];
  let doubled = numbers.map(num => num * 2); // [2, 4, 6]

  // filter：过滤符合条件的元素
  let even = numbers.filter(num => num % 2 === 0); // [2]

  // reduce：累积计算结果
  let sum = numbers.reduce((acc, num) => acc + num, 0); // 6
  ```

**对象属性与方法**

- **属性访问**：
  ```javascript
  const user = {
    name: "Alice",
    age: 25,
    sayHi() {
      console.log(`Hi, ${this.name}!`);
    }
  };
  console.log(user.name);       // "Alice"（点语法）
  console.log(user["age"]);     // 25（方括号语法）
  user.sayHi();                 // "Hi, Alice!"
  ```

- **解构赋值**（ES6）：
  ```javascript
  const { name, age } = user;
  console.log(name, age); // "Alice", 25

  // 数组解构
  const [first, second] = ["A", "B"];
  console.log(first); // "A"
  ```

- **浅拷贝与深拷贝**：
  ```javascript
  // 浅拷贝（只复制引用）
  const obj1 = { a: 1, b: { c: 2 } };
  const obj2 = { ...obj1 }; 
  obj2.b.c = 3;
  console.log(obj1.b.c); // 3（原对象被修改）

  // 深拷贝（完全独立副本）
  const obj3 = JSON.parse(JSON.stringify(obj1));
  obj3.b.c = 4;
  console.log(obj1.b.c); // 3（原对象未受影响）
  ```

#### **4.2. 内置对象**

- **Math**：
  ```javascript
  console.log(Math.max(1, 5, 3));  // 5
  console.log(Math.floor(3.7));    // 3（向下取整）
  console.log(Math.random());      // 0~1随机数
  ```

- **Date**：
  ```javascript
  const now = new Date();
  console.log(now.getFullYear()); // 当前年份
  console.log(now.toISOString()); // ISO格式时间字符串
  ```

- **JSON**：
  ```javascript
  const data = { name: "Bob", age: 30 };
  const jsonStr = JSON.stringify(data); // 对象转JSON字符串
  const parsedData = JSON.parse(jsonStr); // JSON字符串转对象
  ```
- **Set**（唯一值集合）：
  ```javascript
  const set = new Set([1, 2, 2, 3]);
  console.log(set); // Set {1, 2, 3}
  set.add(4).delete(1);
  ```

- **Map**（键值对集合）：
  ```javascript
  const map = new Map();
  map.set("name", "Alice");
  map.set("age", 25);
  console.log(map.get("name")); // "Alice"
  ```

- **字符串方法**：
  ```javascript
  const str = "Hello World";
  console.log(str.includes("Hello")); // true
  console.log(str.slice(0, 5));       // "Hello"
  ```

- **正则表达式**：
  ```javascript
  const regex = /\d+/g; // 匹配数字
  const text = "2023年10月";
  console.log(text.match(regex)); // ["2023", "10"]
  ```


### **5. DOM与BOM操作**

#### **5.1. DOM编程**

**DOM树结构与节点类型**

- **节点类型**：元素节点（如 `<div>`）、文本节点、属性节点等。
- **DOM树示例**：
  ```html
  <div id="container">
    <p class="text">Hello</p>
  </div>
  ```

**元素选择与操作**

- **选择元素**：
  ```javascript
  const container = document.getElementById("container"); // ID选择
  const p = document.querySelector(".text");             // 类选择
  const allP = document.querySelectorAll("p");           // 所有p元素
  ```

- **增删改查元素**：
  ```javascript
  // 创建元素
  const newDiv = document.createElement("div");
  newDiv.textContent = "New Element";

  // 插入元素
  container.appendChild(newDiv);

  // 修改样式
  p.style.color = "red";

  // 删除元素
  container.removeChild(newDiv);
  ```

**事件处理**

- **事件监听**：
  ```javascript
  const button = document.querySelector("button");
  button.addEventListener("click", function(event) {
    console.log("按钮被点击了！", event.target);
  });
  ```

- **事件冒泡与捕获**：
  - **事件冒泡**：指当一个元素触发了某个事件时，该事件会从最内层的目标元素开始，依次向上传播到外层的祖先元素，就像气泡从水底逐渐上升到水面一样
  - **事件捕获**：与事件冒泡相反，事件捕获是从最外层的祖先元素开始，依次向内层的目标元素传播，就像从水面开始向水底搜索一样。在事件捕获阶段，事件会先经过外层元素，然后才到达内层元素。
  ```javascript
    <body>
    <!-- 嵌套的 DOM 结构 -->
    <div id="grandparent">
        Grandparent
        <div id="parent">
            Parent
            <button id="child">Child (点击我)</button>
        </div>
    </div>

    <script>
    // 获取 DOM 元素
    const grandparent = document.getElementById("grandparent");
    const parent = document.getElementById("parent");
    const child = document.getElementById("child");

    // 绑定捕获阶段的事件监听器 (第三个参数为 true)
    grandparent.addEventListener("click", () => {
      console.log("Grandparent 捕获阶段");
    }, true);

    parent.addEventListener("click", () => {
      console.log("Parent 捕获阶段");
    }, true);

    // 绑定冒泡阶段的事件监听器 (第三个参数为 false 或省略)
    grandparent.addEventListener("click", () => {
      console.log("Grandparent 冒泡阶段");
    }, false);

    parent.addEventListener("click", () => {
      console.log("Parent 冒泡阶段");
    }, false);

    // 目标元素的事件监听器（同时绑定捕获和冒泡）
    child.addEventListener("click", () => {
      console.log("Child 捕获阶段");
    }, true);

    child.addEventListener("click", () => {
      console.log("Child 冒泡阶段");
    }, false);

    // 可选：阻止默认行为（如需要）
    // child.addEventListener("click", (e) => {
    //   e.preventDefault(); // 例如阻止按钮提交表单
    // });
    </script>
    </body>
  ```
  ![20250227144352332.png](https://raw.githubusercontent.com/lu-nanan/PicList/main/upLoads/20250227144352332.png?token=BLOP47FYAYDF6DXT7QKTHOTHYAE6K)

#### **5.2. BOM（浏览器对象模型）**

**window对象**

- **定时器**：
  ```javascript
  // 一次性定时器
  setTimeout(() => {
    console.log("2秒后执行");
  }, 2000);

  // 重复定时器
  let timer = setInterval(() => {
    console.log("每隔1秒执行");
  }, 1000);
  // 清除定时器：clearInterval(timer);
  ```

**location、history、navigator**

- **页面跳转**：
  ```javascript
  location.href = "https://www.example.com"; // 跳转到新页面
  history.back(); // 返回上一页
  ```

- **浏览器信息**：
  ```javascript
  console.log(navigator.userAgent); // 获取用户代理信息
  ```

**浏览器存储**

- **localStorage**（长期存储）：
  ```javascript
  localStorage.setItem("theme", "dark");
  console.log(localStorage.getItem("theme")); // "dark"
  ```

- **sessionStorage**（会话级存储）：
  ```javascript
  sessionStorage.setItem("token", "abc123");
  ```


### **6. 异步编程与网络请求**

#### **6.1. 回调函数**


**什么是回调函数**

回调函数是一个**作为参数传递给另一个函数**的函数，并在特定条件满足时（如异步操作完成、事件触发等）被调用。

**核心特点**

1. **作为参数传递**：函数可以像变量一样被传递。
2. **延迟执行**：回调函数不会立即执行，而是在特定时机被调用。
3. **处理异步任务**：用于处理需要等待的操作（如网络请求、定时器等）。

**同步回调**

同步回调会立即执行，不涉及等待操作。

```javascript
function map(array, callback) {
  console.log('map() starts');
  const mappedArray = [];
  for (const item of array) { mappedArray.push(callback(item)) }
  console.log('map() completed');
  return mappedArray;
}

function greet(name) {
  console.log('greet() called');
  return `Hello, ${name}!`;
}

const persons = ['Cristina'];

map(persons, greet);
// logs 'map() starts'
// logs 'greet() called'
// logs 'map() completed'
```

**异步回调**

异步回调会在未来的某个时间点执行（如定时器、网络请求等）

```javascript
function fetchData(callback) {
  setTimeout(() => {
    const data = "异步数据";
    callback(data); // 1秒后调用回调
  }, 1000);
}

fetchData((data) => {
  console.log("收到数据:", data); // 1秒后输出: 收到数据: 异步数据
});
```

**回调函数的常见应用场景**

- **处理事件监听**
```javascript
document.getElementById("myButton").addEventListener("click", () => {
  console.log("按钮被点击了！"); // 点击按钮后触发回调
});
```

- **处理定时任务**
```javascript
setTimeout(() => {
  console.log("1秒后执行"); // 1秒后执行回调
}, 1000);
```

- **处理 AJAX 请求**
```javascript
function getUserData(userId, onSuccess, onError) {
  // 模拟网络请求
  setTimeout(() => {
    if (userId === 123) {
      onSuccess({ id: 123, name: "张三" });
    } else {
      onError("用户不存在");
    }
  }, 1000);
}

// 使用回调处理成功和错误
getUserData(
  123,
  (user) => console.log("获取用户成功:", user),
  (error) => console.log("错误:", error)
);
```
**回调函数的执行顺序**
1. 同步代码优先执行。
2. 异步回调被放入任务队列，等待主线程空闲时执行。

```javascript
console.log("开始");

setTimeout(() => {
  console.log("定时器回调"); // 最后执行
}, 0);

console.log("结束");

// 输出顺序:
// 开始
// 结束
// 定时器回调
```

#### **6.2. Promise（链式调用）**

- **基本用法**：用`resolve`和`reject`处理成功/失败。
  ```javascript
  const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
      Math.random() > 0.5 ? resolve("成功") : reject("失败");
    }, 1000);
  });

  promise
    .then((result) => console.log(result))
    .catch((error) => console.error(error));
  ```

- **链式调用**：解决回调地狱。
  ```javascript
  fetchData1()
    .then((data1) => fetchData2(data1))
    .then((data2) => fetchData3(data2))
    .catch((error) => console.error(error));
  ```

#### **6.3. async/await 语法糖**

- **同步化异步代码**：
  ```javascript
  async function loadData() {
    try {
      const data1 = await fetchData1();
      const data2 = await fetchData2(data1);
      console.log(data2);
    } catch (error) {
      console.error(error);
    }
  }
  loadData();
  ```


#### **6.3. 网络请求**

**XMLHttpRequest（XHR）**

- **传统方式**：
  ```javascript
  const xhr = new XMLHttpRequest();
  xhr.open("GET", "https://api.example.com/data");
  xhr.onload = () => console.log(xhr.responseText);
  xhr.send();
  ```
**Fetch API**

- **基本用法**：
  ```javascript
  fetch("https://api.example.com/data")
    .then((response) => response.json())
    .then((data) => console.log(data))
    .catch((error) => console.error(error));
  ```
- **async/await优化**：
  ```javascript
  async function fetchData() {
    try {
      const response = await fetch("https://api.example.com/data");
      const data = await response.json();
      console.log(data);
    } catch (error) {
      console.error(error);
    }
  }
  ```


### **7. 现代JavaScript（ES6+）**

#### **7.1. ES6+新特性**

**模板字符串**
  ```javascript
  const name = "Alice";
  console.log(`Hello, ${name}!`); // "Hello, Alice!"
  ```

**解构赋值**
  ```javascript
  // 对象解构
  const { age, city = "北京" } = { name: "Bob", age: 30 };
  console.log(age, city); // 30, "北京"

  // 数组解构
  const [a, , b] = [1, 2, 3];
  console.log(a, b); // 1, 3
  ```

**展开运算符（...）**
  ```javascript
  // 合并数组
  const arr1 = [1, 2], arr2 = [3, 4];
  const merged = [...arr1, ...arr2]; // [1,2,3,4]

  // 对象合并
  const obj1 = { a: 1 }, obj2 = { b: 2 };
  const combined = { ...obj1, ...obj2 }; // {a:1, b:2}
  ```

**模块化（import/export）**
  ```javascript
  // math.js
  export const add = (a, b) => a + b;

  // app.js
  import { add } from "./math.js";
  console.log(add(2, 3)); // 5
  ```

**类与继承（class、extends）**
  ```javascript
  class Animal {
    constructor(name) {
      this.name = name;
    }
    speak() {
      console.log(`${this.name} makes a noise`);
    }
  }

  class Dog extends Animal {
    speak() {
      super.speak(); // 调用父类方法
      console.log("Woof!");
    }
  }

  const dog = new Dog("Rex");
  dog.speak(); // "Rex makes a noise" + "Woof!"
  ```

**Proxy与Reflect**
  ```javascript
  const target = { name: "Alice" };
  const proxy = new Proxy(target, {
    get(obj, prop) {
      return prop in obj ? obj[prop] : "默认值";
    }
  });
  console.log(proxy.age); // "默认值"
  ```

**迭代器与生成器（Iterator/Generator）**
 ```javascript
  // 自定义迭代器
  const iterable = {
    [Symbol.iterator]() {
      let count = 0;
      return {
        next() {
          return { value: count++, done: count > 3 };
        }
      };
    }
  };
  for (const num of iterable) console.log(num); // 0,1,2

  // 生成器函数（function*）
  function* gen() {
    yield 1;
    yield 2;
  }
  const g = gen();
  console.log(g.next().value); // 1
  ```

