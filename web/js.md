**JavaScript**
===
---

- [**JavaScript**](#javascript)
    - [**变量声明**](#变量声明)
    - [**数据类型**](#数据类型)
      - [**字符串**](#字符串)
      - [**数组（Array）**](#数组array)
      - [**对象（Object）**](#对象object)
      - [**运算符与表达式**](#运算符与表达式)
    - [**条件控制语句**](#条件控制语句)
      - [**1. `if...else` 语句**](#1-ifelse-语句)
      - [**2. `switch` 语句**](#2-switch-语句)
      - [**3. 三元运算符（条件表达式）**](#3-三元运算符条件表达式)
    - [**循环语句**](#循环语句)
      - [**1. `for` 循环**](#1-for-循环)
      - [**2. `while` 循环**](#2-while-循环)
      - [**3. `do...while` 循环**](#3-dowhile-循环)
      - [**4. `for...of` 循环（ES6）**](#4-forof-循环es6)
      - [**5. `for...in` 循环**](#5-forin-循环)
    - [**循环控制语句**](#循环控制语句)
      - [**1. `break`**](#1-break)
      - [**2. `continue`**](#2-continue)
      - [**3. 标签（Label）**](#3-标签label)
    - [**函数**](#函数)
      - [**函数的参数与返回值**](#函数的参数与返回值)
      - [**函数的作用域与变量**](#函数的作用域与变量)
    - [**DOM（Document Object Model，文档对象模型）**](#domdocument-object-model文档对象模型)
      - [**1. DOM 的基本结构**](#1-dom-的基本结构)
      - [**2. DOM 的核心功能**](#2-dom-的核心功能)
      - [**3. 示例代码**](#3-示例代码)
    - [**BOM（Browser Object Model，浏览器对象模型）**](#bombrowser-object-model浏览器对象模型)
      - [**1. 核心对象与方法**](#1-核心对象与方法)
      - [**2. 示例代码**](#2-示例代码)
    - [**异步编程与网络请求**](#异步编程与网络请求)
      - [**回调函数**](#回调函数)
      - [**Promise（链式调用）**](#promise链式调用)
      - [**async/await 语法糖**](#asyncawait-语法糖)
      - [**网络请求**](#网络请求)




### **变量声明**

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

### **数据类型**
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

**类型转换与检测**
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

#### **字符串**

由零个或多个 Unicode 字符组成的序列，用单引号 `'`、双引号 `"` 或反引号 `` ` ``（模板字符串）包裹。

**不可变性**：
字符串一旦创建，内容不可更改。所有看似修改字符串的操作（如 `replace`、`toUpperCase`）都会返回新字符串。
   - 示例：
     ```javascript
     let str = "abc";
     str[0] = "d"; // 无效，str 仍为 "abc"
     ```

**字符编码**：
JavaScript 字符串默认使用 UTF-16 编码，支持 Unicode 字符（包括表情符号、中文等）。
- 特殊字符需转义：
     ```javascript
     const str = "Line1\nLine2"; // 换行符
     const emoji = "\u{1F604}";  // 😄（Unicode 码点）
     ```

**创建字符串**
1. **字面量方式**：
   ```javascript
   const str1 = "Hello";  // 双引号
   const str2 = 'World';  // 单引号
   const str3 = `Hello ${str2}`; // 模板字符串（ES6）
   ```

2. **构造函数方式**：
   ```javascript
   const str = new String("Hello"); // 返回 String 对象（非原始值，不推荐）
   ```


**访问字符**
- **索引访问**：
  ```javascript
  const str = "Hello";
  console.log(str[0]);      // "H"（ES6 支持）
  console.log(str.charAt(1)); // "e"
  ```

- **遍历字符**：
  ```javascript
  for (const char of "Hello") {
    console.log(char); // 依次输出 H, e, l, l, o
  }
  ```


| 方法                  | 功能说明                              | 示例                                   |
|-----------------------|-------------------------------------|----------------------------------------|
| **`slice(start, end)`** | 截取子字符串（支持负数索引）           | `"Hello".slice(1, 3) // "el"`          |
| **`substring(start, end)`** | 类似 `slice`，但负数视为 0            | `"Hello".substring(1, 3) // "el"`      |
| **`split(separator)`** | 按分隔符分割为数组                    | `"a,b,c".split(",") // ["a", "b", "c"]`|
| **`concat(str)`**      | 拼接字符串（推荐用 `+` 或模板字符串）  | `"Hello".concat(" World") // "Hello World"`|
| **`indexOf(str)`**     | 查找子字符串首次出现的位置            | `"Hello".indexOf("l") // 2`            |
| **`includes(str)`**    | 是否包含子字符串（ES6）               | `"Hello".includes("lo") // false`      |
| **`toUpperCase()`**    | 转大写                               | `"Hello".toUpperCase() // "HELLO"`     |
| **`toLowerCase()`**    | 转小写                               | `"HELLO".toLowerCase() // "hello"`     |
| **`trim()`**           | 去除首尾空格（ES5）                   | `"  Hello  ".trim() // "Hello"`        |
| **`replace(old, new)`**| 替换首个匹配的子字符串（支持正则）     | `"Hi".replace("H", "h") // "hi"`       |
| **`match(regexp)`**    | 用正则表达式匹配字符串                | `"123".match(/\d+/) // ["123"]`        |
| **`padStart(len, padStr)`** | 填充字符串到目标长度（ES8）       | `"5".padStart(3, "0") // "005"`        |



**ES6+ 新特性**
1. **模板字符串（Template Literals）**：
   - 支持多行字符串和嵌入表达式：
     ```javascript
     const name = "Alice";
     const message = `Hello ${name},
     Today is ${new Date().toDateString()}.`;
     ```
   - **标签模板（Tagged Templates）**：
     ```javascript
     function highlight(strings, ...values) {
       // 自定义处理逻辑
     }
     const result = highlight`Hello ${name}`;
     ```

2. **Unicode 支持增强**：
   - `String.fromCodePoint()` 和 `codePointAt()` 处理 Unicode 码点：
     ```javascript
     console.log("😄".codePointAt(0)); // 128516（正确获取码点）
     ```

3. **新增方法**：
   - `startsWith()` / `endsWith()`：
     ```javascript
     "Hello".startsWith("He"); // true
     ```
   - `repeat()`：
     ```javascript
     "Ha".repeat(3); // "HaHaHa"
     ```


**字符串拼接**：
  - 避免频繁用 `+` 拼接长字符串（性能差），推荐使用数组 `push` + `join` 或模板字符串。
    ```javascript
    // 低效
    let str = "";
    for (let i = 0; i < 1000; i++) {
      str += i;
    }

    // 高效
    const parts = [];
    for (let i = 0; i < 1000; i++) {
      parts.push(i);
    }
    str = parts.join("");
    ```




#### **数组（Array）**
1. 基本概念
- **有序集合**：数组是按顺序存储数据的有序列表，通过数字索引（从 0 开始）访问元素。
- **动态类型**：数组元素可以是任意类型（数字、字符串、对象、函数，甚至是其他数组）。
- **动态长度**：数组长度可动态调整，无需预先声明大小。

2. 创建数组
```javascript
// 字面量方式（推荐）
const arr1 = [1, "hello", { key: "value" }, [2, 3]];

// 构造函数方式
const arr2 = new Array(1, 2, 3);
```

3. 常用特性与方法
- **访问元素**：通过索引 `arr[0]`。
- **长度属性**：`arr.length`（可手动修改，截断或扩展数组）。
- **常用方法**：
  - **增删元素**：
    ```javascript
    arr.push("end");       // 末尾添加
    arr.pop();             // 删除末尾
    arr.unshift("start");  // 开头添加
    arr.shift();           // 删除开头
    ```
  - **操作数组**：
    ```javascript
    arr.splice(1, 2, "new"); // 从索引1删除2个元素，并插入新元素
    arr.slice(0, 3);          // 截取索引0到2的元素（返回新数组）
    ```
  - **遍历**：
    ```javascript
    arr.forEach((item, index) => { /* ... */ });
    const newArr = arr.map(item => item * 2);
    ```
  - **查找/判断**：
    ```javascript
    arr.includes("value");    // 是否包含元素
    arr.find(item => item > 5); // 查找第一个符合条件的元素
    ```
  - **其他操作**：
    ```javascript
    arr.reverse();    // 反转数组
    arr.sort();       // 排序（默认按字符串Unicode排序）
    arr.join("-");    // 转换为字符串
    ```

4. ES6+ 新特性
- **扩展运算符**：`[...arr]` 用于复制数组或合并数组。
- **解构赋值**：`const [a, b] = arr;`
- **Array.from()**：将类数组对象（如 `arguments`、NodeList）转为数组。
- **findIndex()**、**flat()**、**flatMap()** 等新方法。



#### **对象（Object）**

- **键值对集合**：对象是无序的键值对集合，键（属性名）为字符串或 Symbol，值可以是任意类型。
- **引用类型**：对象通过引用传递，而非值传递。

1. 创建对象
```javascript
// 字面量方式（推荐）
const obj1 = { 
  name: "Alice", 
  age: 30,
  sayHi() { console.log("Hi!") }
};

// 构造函数方式
const obj2 = new Object();
obj2.key = "value";
```

2. 常用特性与方法
- **访问属性**：
  ```javascript
  obj.name;      // 点语法
  obj["age"];    // 方括号语法（支持动态键名）
  ```
- **动态增删属性**：
  ```javascript
  obj.newKey = "value";      // 添加属性
  delete obj.age;            // 删除属性
  ```
- **常用方法**：
  - **遍历属性**：
    ```javascript
    Object.keys(obj);    // 返回所有可枚举属性名数组
    Object.values(obj);  // 返回所有值数组
    Object.entries(obj); // 返回键值对数组（如 [["key1", "val1"], ...]）
    ```
  - **合并对象**：
    ```javascript
    Object.assign({}, obj1, obj2); // 合并到新对象（浅拷贝）
    ```
  - **判断属性存在性**：
    ```javascript
    "name" in obj;       // 是否包含属性（包括原型链）
    obj.hasOwnProperty("name"); // 是否自身属性（非继承）
    ```

3. ES6+ 新特性
- **简写语法**：
  ```javascript
  const name = "Alice";
  const obj = { name, sayHi() {} }; // 等价于 { name: name, sayHi: function() {} }
  ```
- **计算属性名**：
  ```javascript
  const key = "age";
  const obj = { [key]: 30 }; // { age: 30 }
  ```
- **对象解构**：
  ```javascript
  const { name, age } = obj;
  ```
- **展开运算符**（浅拷贝）：
  ```javascript
  const newObj = { ...obj1, ...obj2 };
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

### **条件控制语句**

条件语句根据不同的条件执行不同的代码分支。

#### **1. `if...else` 语句**
- **基本语法**：
  ```javascript
  if (条件1) {
    // 条件1为真时执行
  } else if (条件2) {
    // 条件2为真时执行
  } else {
    // 所有条件都不满足时执行
  }
  ```

- **示例**：
  ```javascript
  const score = 85;
  if (score >= 90) {
    console.log("A");
  } else if (score >= 80) {
    console.log("B"); // 输出 B
  } else {
    console.log("C");
  }
  ```

#### **2. `switch` 语句**
- **适用场景**：多个固定值的条件判断。
- **语法**：
  ```javascript
  switch (表达式) {
    case 值1:
      // 匹配值1时执行
      break; // 必须用 break 跳出
    case 值2:
      // 匹配值2时执行
      break;
    default:
      // 无匹配时执行
  }
  ```

- **示例**：
  ```javascript
  const day = "Monday";
  switch (day) {
    case "Monday":
      console.log("工作日开始");
      break;
    case "Saturday":
    case "Sunday":
      console.log("周末");
      break;
    default:
      console.log("其他工作日");
  }
  ```

- **注意**：`case` 使用严格相等（`===`）进行比较，忘记 `break` 会导致代码“穿透”。


#### **3. 三元运算符（条件表达式）**
- **适用场景**：简单的条件赋值或返回。
- **语法**：
  ```javascript
  条件 ? 表达式1 : 表达式2;
  ```

- **示例**：
  ```javascript
  const age = 20;
  const canVote = age >= 18 ? "Yes" : "No"; // "Yes"
  ```

### **循环语句**

循环语句用于重复执行代码块，直到满足终止条件。

#### **1. `for` 循环**
- **适用场景**：已知循环次数的遍历。
- **语法**：
  ```javascript
  for (初始化; 条件; 迭代) {
    // 循环体
  }
  ```

- **示例**：
  ```javascript
  // 遍历数组
  const arr = [1, 2, 3];
  for (let i = 0; i < arr.length; i++) {
    console.log(arr[i]); // 1, 2, 3
  }
  ```


#### **2. `while` 循环**
- **适用场景**：不确定循环次数，但条件为真时执行。
- **语法**：
  ```javascript
  while (条件) {
    // 循环体
  }
  ```

- **示例**：
  ```javascript
  let count = 3;
  while (count > 0) {
    console.log(count); // 3, 2, 1
    count--;
  }
  ```


#### **3. `do...while` 循环**
- **特点**：至少执行一次循环体，再检查条件。
- **语法**：
  ```javascript
  do {
    // 循环体
  } while (条件);
  ```

- **示例**：
  ```javascript
  let num = 0;
  do {
    console.log(num); // 0（至少执行一次）
  } while (num > 0);
  ```

#### **4. `for...of` 循环（ES6）**
- **适用场景**：遍历可迭代对象（如数组、字符串、Map、Set）。
- **语法**：
  ```javascript
  for (const item of 可迭代对象) {
    // 循环体
  }
  ```

- **示例**：
  ```javascript
  const arr = [10, 20, 30];
  for (const value of arr) {
    console.log(value); // 10, 20, 30
  }
  ```

#### **5. `for...in` 循环**
- **适用场景**：遍历对象的可枚举属性（慎用于数组）。
- **语法**：
  ```javascript
  for (const key in 对象) {
    // 循环体
  }
  ```

- **示例**：
  ```javascript
  const obj = { a: 1, b: 2 };
  for (const key in obj) {
    console.log(key, obj[key]); // "a 1", "b 2"
  }
  ```

- **注意**：会遍历原型链上的属性，建议配合 `hasOwnProperty` 过滤。


### **循环控制语句**
#### **1. `break`**
- **功能**：立即终止当前循环。
- **示例**：
  ```javascript
  for (let i = 0; i < 5; i++) {
    if (i === 3) break;
    console.log(i); // 0, 1, 2
  }
  ```

#### **2. `continue`**
- **功能**：跳过当前循环的剩余代码，进入下一次迭代。
- **示例**：
  ```javascript
  for (let i = 0; i < 5; i++) {
    if (i === 2) continue;
    console.log(i); // 0, 1, 3, 4
  }
  ```

#### **3. 标签（Label）**
- **功能**：标记循环，与 `break` 或 `continue` 配合跳出多层循环。
- **示例**：
  ```javascript
  outerLoop: 
  for (let i = 0; i < 3; i++) {
    for (let j = 0; j < 3; j++) {
      if (i === 1 && j === 1) break outerLoop; // 直接跳出外层循环
      console.log(i, j); // (0,0), (0,1), (0,2), (1,0)
    }
  }
  ```

### **函数**
  
函数是 **可重复使用的代码块**，可以接收参数、执行特定任务，并返回结果。  

**函数的创建方式**  
   - **函数声明（Function Declaration）**  
     ```javascript
     function add(a, b) {
       return a + b;
     }
     ```  
     **特点**：  
     - 被**提升（Hoisting）**，可在声明前调用。  
     - 必须有函数名。  

   - **函数表达式（Function Expression）**  
     ```javascript
     const subtract = function(a, b) {
       return a - b;
     };
     ```  
     **特点**：  
     - 变量声明会被提升，但赋值不会，需先定义后使用。  
     - 可以匿名（函数名可选）。  

   - **箭头函数（Arrow Function）**（ES6）  
     ```javascript
     const multiply = (a, b) => a * b;
     const greet = () => "Hello!";
     ```  
     **特点**：  
     - 语法简洁，无`function`关键字。  
     - **词法作用域**：`this`指向外层作用域，而非函数自身。  
     - 不能用作构造函数（无`prototype`）。  


#### **函数的参数与返回值**
1. **参数（形参与实参）**  
   - **形参**：函数声明时定义的参数（如 `function add(a, b)` 中的 `a` 和 `b`）。  
   - **实参**：调用函数时传递的值（如 `add(3, 5)` 中的 `3` 和 `5`）。  

2. **参数传递规则**  
   - **值传递**：参数是原始值的拷贝，修改形参不影响实参。  
   - **默认参数**（ES6）：  
     ```javascript
     function greet(name = "World") {
       return `Hello, ${name}!`;
     }
     greet(); // "Hello, World!"
     ```  
   - **剩余参数**（ES6）：接收多个参数为数组：  
     ```javascript
     function sum(...nums) {
       return nums.reduce((a, b) => a + b, 0);
     }
     sum(1, 2, 3); // 6
     ```  
   - **`arguments` 对象**：  
     函数内部可通过 `arguments` 访问所有实参（类数组对象）：  
     ```javascript
     function logArgs() {
       console.log(arguments); // 类数组对象
       console.log(arguments[0]); // 第一个参数
     }
     logArgs(10, 20); // 输出 10
     ```

3. **返回值（`return`）**  
   - `return` 语句用于返回结果，并终止函数执行。  
   - 可以返回任意类型（包括对象、函数等）。  
   - **无返回值时默认返回 `undefined`**。  
   ```javascript
   function add(a, b) {
     return a + b; // 明确返回值
   }
   function noReturn() {
     console.log("No return"); // 无返回值，隐式返回 undefined
   }
   ```

#### **函数的作用域与变量**
1. **变量作用域**  
   - **全局作用域**：在函数外部声明的变量，全局可用。  
   - **局部作用域**：函数内部声明的变量（用 `var`、`let`、`const`）仅在函数内部有效。  
   ```javascript
   var globalVar = "I'm global";

   function example() {
     let localVar = "I'm local"; // 局部变量
     console.log(globalVar); // 可访问全局变量
   }
   console.log(localVar); // 报错：未定义
   ```

2. **作用域链**  
   - 内层函数可以访问外层函数的变量和参数（闭包的基础）。  
   ```javascript
   function outer() {
     let outerVar = "Outer";
     function inner() {
       console.log(outerVar); // 可访问 outerVar
     }
     inner();
   }
   outer();
   ```


### **DOM（Document Object Model，文档对象模型）**

DOM 是 HTML 和 XML 文档的编程接口，将文档解析为树形结构（节点树），允许通过 JavaScript 动态操作文档内容、结构和样式。

#### **1. DOM 的基本结构**
- **节点类型**：
  - **元素节点**：对应 HTML 标签（如 `<div>`, `<p>`）。
  - **文本节点**：标签内的文本内容（如 `<p>文本节点</p>` 中的文本）。
  - **属性节点**：标签的属性（如 `id="main"`）。
  - **文档节点**：整个 HTML 文档的根节点（`document` 对象）。

#### **2. DOM 的核心功能**
- **访问节点**：
  - `document.getElementById(id)`：通过 ID 获取元素。
  - `document.querySelector(selector)`：通过 CSS 选择器获取单个元素。
  - `document.querySelectorAll(selector)`：通过 CSS 选择器获取多个元素。
  - `document.getElementsByClassName(className)`：通过类名获取元素集合。
  - `document.getElementsByTagName(tagName)`：通过标签名获取元素集合。

- **修改节点内容**：
  - `element.textContent`：获取或设置元素的纯文本内容。
  - `element.innerHTML`：获取或设置元素的 HTML 内容（会解析 HTML 标签）。
  - `element.style`：直接操作元素的行内样式（如 `element.style.color = 'red'`）。
  - `element.className` 或 `element.classList`：操作元素的 CSS 类名。

- **创建/删除节点**：
  - `document.createElement(tagName)`：创建新元素。
  - `parent.appendChild(child)`：将子元素添加到父元素末尾。
  - `parent.insertBefore(newNode, referenceNode)`：在指定位置插入新节点。
  - `parent.removeChild(child)`：删除子元素。
  - `element.remove()`：直接删除元素本身（ES6+）。

- **事件处理**：
  - `element.addEventListener(eventType, callback)`：绑定事件监听器。
  - `element.removeEventListener(eventType, callback)`：移除事件监听器。

#### **3. 示例代码**
```javascript
// 获取元素
const element = document.getElementById("myElement");

// 修改内容
element.textContent = "Hello, World!"; // 设置纯文本
element.innerHTML = "<strong>加粗文本</strong>"; // 设置 HTML 内容

// 创建新元素
const newDiv = document.createElement("div");
newDiv.textContent = "新元素";
document.body.appendChild(newDiv);

// 事件处理
element.addEventListener("click", () => {
  alert("元素被点击了！");
});

// 样式操作
element.style.backgroundColor = "lightblue";
element.classList.add("active");
```

### **BOM（Browser Object Model，浏览器对象模型）**

BOM 是浏览器提供的接口，用于操作浏览器窗口及其功能，如窗口大小、导航、弹窗、定时器等。BOM 的核心对象是 `window`。

#### **1. 核心对象与方法**

**(1) Window 对象**
- **全局对象**：所有全局变量和函数都是 `window` 的属性/方法。
- **常用方法**：
  - `window.alert(message)`：显示警告框。
  - `window.confirm(message)`：显示确认框（返回布尔值）。
  - `window.prompt(message, defaultValue)`：显示输入框，获取用户输入。
  - `window.open(url, target)`：打开新窗口（`target="_blank"` 表示新标签页）。
  - `window.close()`：关闭当前窗口（需与 `window.open` 配合使用）。
  - `window.setTimeout(callback, delay)`：延迟执行代码。
  - `window.setInterval(callback, interval)`：周期性执行代码。
  - `window.clearTimeout(id)` 和 `window.clearInterval(id)`：清除定时器。

**(2) Navigator 对象**
- 提供浏览器信息：
  - `navigator.userAgent`：获取用户代理字符串（浏览器类型、版本、操作系统）。
  - `navigator.platform`：获取操作系统平台（如 `Win32`、`MacIntel`）。
  - `navigator.language`：获取浏览器语言设置。


**(3) Location 对象**
- 操作当前页面的 URL：
  - `window.location.href`：获取或设置当前 URL。
  - `window.location.assign(url)`：跳转到指定 URL（保留历史记录）。
  - `window.location.replace(url)`：跳转到指定 URL（不保留历史记录）。
  - `window.location.reload()`：重新加载当前页面。

**(4) History 对象**
- 操作浏览器历史记录：
  - `window.history.back()`：后退一页。
  - `window.history.forward()`：前进一页。
  - `window.history.go(n)`：跳转到历史记录中的第 `n` 项（`-1` 后退，`1` 前进）。

**(5) Screen 对象**
- 获取屏幕信息：
  - `screen.width`/`screen.height`：屏幕分辨率。
  - `screen.availWidth`/`screen.availHeight`：可用屏幕尺寸（扣除任务栏）。

#### **2. 示例代码**
```javascript
// 弹窗操作
window.alert("这是一个警告框！");
const confirmResult = window.confirm("确认执行此操作？"); // 返回 true/false
const userInput = window.prompt("请输入内容：", "默认值");

// 定时器
const timerId = setTimeout(() => {
  console.log("5秒后执行");
}, 5000);
clearTimeout(timerId); // 取消定时器

// URL 操作
console.log(window.location.href); // 当前页面 URL
window.location.href = "https://example.com"; // 跳转页面

// 浏览器信息
console.log(navigator.userAgent); // 获取浏览器信息
console.log(screen.width); // 获取屏幕宽度

// 历史记录
window.history.back(); // 等同于点击浏览器的后退按钮
```


| **特性**       | **DOM**                                | **BOM**                                |
|----------------|----------------------------------------|----------------------------------------|
| **核心作用**   | 操作文档内容和结构（HTML/XML）         | 操作浏览器窗口和功能                   |
| **顶级对象**   | `document`                             | `window`                               |
| **常见操作**   | 元素增删改查、样式修改、事件绑定       | 窗口弹出、导航跳转、定时器、浏览器信息 |
| **标准化**     | W3C 标准规范                           | 浏览器厂商自定义（非标准）             |
| **兼容性**     | 跨浏览器兼容性较好                     | 部分功能兼容性较差（如 `window.open`） |



**DOM 与 BOM 的实际应用**
1. **动态页面更新**：
   ```javascript
   // 通过 DOM 动态更新内容
   document.getElementById("count").textContent = "点击次数：" + count;
   ```

2. **用户交互**：
   ```javascript
   // 点击按钮后弹窗（BOM）
   document.querySelector("#alert-btn").addEventListener("click", () => {
     window.alert("按钮被点击了！");
   });
   ```

3. **响应式布局**：
   ```javascript
   // 根据屏幕宽度调整内容（BOM 结合 DOM）
   if (window.innerWidth < 768) {
     document.body.style.backgroundColor = "lightgray";
   }
   ```

4. **表单验证**：
   ```javascript
   // 提交表单前验证输入（DOM + BOM）
   document.querySelector("form").addEventListener("submit", (e) => {
     if (!document.getElementById("username").value) {
       e.preventDefault();
       window.alert("用户名不能为空！");
     }
   });
   ```


### **异步编程与网络请求**

#### **回调函数**


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

#### **Promise（链式调用）**

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

#### **async/await 语法糖**

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


#### **网络请求**

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
