### **一、基本类型**

#### **1.1. 基本类型**

1. **数字类型**：
   - `Int`：整数，32位。范围是-2^31到2^31-1。
   - `Byte`：字节，8位。范围是-128到127。
   - `Short`：短整型，16位。范围是-2^15到2^15-1。
   - `Long`：长整型，64位。范围是-2^63到2^63-1。
   - `Float`：单精度浮点型，32位。
   - `Double`：双精度浮点型，64位。

2. **字符类型** (`Char`)：表示单个字符，使用单引号定义，例如 `'a'` 或者特殊字符如 `'\n'`。

3. **布尔类型** (`Boolean`)：表示逻辑值，可以是 `true` 或 `false`。

4. **数组类型** (`Array`)：通过库函数或 arrayOf() 创建，支持对元素的索引访问。

5. **字符串类型** (`String`)：表示文本数据，使用双引号定义。Kotlin中的字符串是不可变的，但可以通过操作生成新的字符串。

#### **1.2. 类型检测（Type Checks）**

使用 **`is`** 或 **`!is`** 操作符检测对象是否属于特定类型：
```kotlin
fun printLength(obj: Any) {
    if (obj is String) {
        println("String length: ${obj.length}") // 自动智能转换为 String
    }
    if (obj !is Int) {
        println("Not an Int")
    }
}
```

**接口/类继承**：检测父类或接口时，子类对象也会通过检测：
   ```kotlin
   interface Animal
   class Dog : Animal
   
   val animal: Animal = Dog()
   if (animal is Dog) { ... } // 通过
   ```

#### **1.3. 类型转换**

**智能转换（Smart Casts）**

编译器自动处理类型转换，避免冗余显式转换：
```kotlin
fun example(obj: Any) {
    if (obj is String && obj.length > 0) { // && 后自动转换为 String
        println(obj.uppercase())
    }

    when (obj) {
        is Int -> println(obj + 1)    // 分支内自动转换为 Int
        is List<*> -> println(obj.size) // 转换为 List
    }
}
```

**限制**：仅适用于不可变值（`val`）、局部变量或 `private val` 属性（确保无外部修改）。
**自定义 `getter`**：开放属性（`open val`）或有自定义 `getter` 的属性不支持智能转换。

**显式转换（Explicit Casts）**

 1. **不安全转换 `as`**
 
	直接转换类型，失败时抛出 `ClassCastException`：

```kotlin
val str: String = obj as String // 若 obj 非 String 则崩溃
```

2. **安全转换 `as?`**
	
	转换失败时返回 `null`：

```kotlin
val str: String? = obj as? String // 安全转换
println(str?.length) // 使用安全调用
```

3. **结合 `when` 表达式**：处理多类型分支

```kotlin
when (obj) {
    is String -> println(obj.length)
    is Int -> println(obj * 2)
    else -> println("Unknown type")
}
```


### **二、控制流程**

#### 2.1. 条件表达式

1. `if` 表达式

	Kotlin 中的 `if` 是**表达式**（除了一般的用法，还可返回值），不是语句：
	
```kotlin
// 传统用法
if (a > b) max = a

// kotlin无三目运算符，采用if代替
val max = if (a > b) a else b

// 带代码块（最后一行作为返回值）
val description = if (age >= 18) {
    println("Adult")
    "Can vote"
} else {
    println("Minor")
    "Cannot vote"
}
```

2. `when` 表达式（强化版 switch）

```kotlin
when (x) {
    // 1. 常量匹配
    1 -> println("One")
    
    // 2. 多值匹配
    2, 3 -> println("Two or Three")
    
    // 3. 范围检测
    in 4..10 -> println("4 to 10")
    
    // 4. 类型检测
    is String -> println("String of length ${x.length}")
    
    // 5. 函数条件
    parseInt(x) -> println("Parsed value")
    
    // 6. 无参数模式（布尔表达式链）
    else -> println("Other")
}

// 作为表达式返回值
val type = when {
    x > 0 -> "Positive"
    x < 0 -> "Negative"
    else -> "Zero"
}

// 智能类型转换
when (obj) {
    is String -> println(obj.length)  // 自动转为String
    is Int -> println(obj.inc())      // 自动转为Int
}
```

#### 2.2. 循环结构

1. **`for`** 循环：支持迭代任何提供迭代器的对象：

```kotlin
// 1. 范围迭代
for (i in 1..5) print(i)       // 输出: 12345 (闭区间)
for (i in 1 until 5) print(i)  // 输出: 1234 (半开区间)

// 2. 步长控制
for (i in 10 downTo 1 step 2) print("$i ")  // 输出: 10 8 6 4 2 

// 3. 集合迭代
val list = listOf("A", "B", "C")
for (item in list) print(item)  // 输出: ABC

// 4. 带索引迭代
for ((index, value) in list.withIndex()) {
    println("$index: $value")
}
```
 
 2. **`while`** 和 **`do-while`** 循环：与传统语言类似
 
```kotlin
while (condition) { /* 代码 */ }

do {
    /* 至少执行一次 */
} while (condition)
```

#### 2.3. 跳转表达式

 1. **基本跳转**：continue和break（用法同其它语言）

```kotlin
for (i in 1..10) {
    if (i == 3) continue   // 跳过本次迭代
    if (i > 5) break       // 终止循环
    print(i)               // 输出: 1245
}
```

**标签**：在 Kotlin 中任何表达式都可以用标签来标记。 标签的格式为标识符后跟 `@` 符号，例如：`abc@`、`fooBar@`。 要为一个表达式加标签，我们只要在其前加标签即可。

此时，可以使用**标签限定 `break` 或者 `continue`**

2. **标签跳转**（Labeled Jumps）：解决嵌套循环跳转问题

```kotlin
outer@ for (i in 1..3) {
    inner@ for (j in 1..3) {
        if (i == 2 && j == 2) break@outer  // 直接跳出外层循环
        print("[$i,$j] ")  // 输出: [1,1] [1,2] [1,3] [2,1]
    }
}
```

 3. **Lambda 表达式**中的返回

```kotlin
fun findFirstEven(list: List<Int>) {
    list.forEach {
        if (it % 2 == 0) {
            println("Found: $it")
            return  // 从函数返回（非局部返回）
        }
    }
}

// 局部返回（仅退出lambda）
list.forEach label@{
    if (it < 0) return@label  // 退出当前lambda迭代
    print(it)
}

// 使用隐式标签（推荐），因为该标签与接受该 lambda 的函数同名
list.forEach {
    if (it < 0) return@forEach  
		    // 退出当前迭代，局部返回到该 lambda 表达式的调用者——forEach 循环
    print(it)
}

// 匿名函数替代 lambda 表达式。 匿名函数内部的 `return` 语句从该匿名函数自身返回
listOf(1, 2, 3, 4, 5).forEach(fun(value: Int) {
        if (value == 3) return  // 局部返回到匿名函数的调用者——forEach 循环
        print(value)
    })
```

#### 2.4. 异常处理

1. 基本结构：同java

```kotlin
try {
    // 可能抛出异常的代码
    val parsed = "123a".toInt()
} catch (e: NumberFormatException) {
    println("Invalid number")
} finally {
    println("Cleanup resources")
}
```

2. 类似的，在kotlin中`try` 也可作为表达式

```kotlin
val number = try {
    "123".toInt()
} catch (e: NumberFormatException) {
    null  // 转换失败返回null
}
```

3. 异常传播

```kotlin
fun readFile() {
    val input = File("data.txt").inputStream()
    input.use {  // 使用use自动关闭资源
        // 读写操作
    }  // 自动调用close()，即使发生异常
}
```

### 三、类与对象

#### 3.1. 类

Kotlin 中使用关键字 `class` 声明类

```kotlin
class Person { /*……*/ }
```

类声明由类名、类头（指定其类型参数、主构造函数等）以及由花括号包围的类体构成。类头与类体都是可选的； 如果一个类没有类体，可以省略花括号。

```kotlin
class Empty
```

#### 3.2. 构造函数 

1. **主构造函数（Primary Constructor）**

	直接在类头声明，跟在类名之后
	可以省略 `constructor` 关键字（无注解/可见性修饰符时）

```kotlin
class Person constructor(firstName: String) { /*...*/ } // 完整形式
class Person(firstName: String) { /*...*/ }           // 简化形式
```

初始化属性：使用参数初始化属性，也可以使用 `val`/`var` 直接在参数中声明属性
	 
```kotlin
  class Person constructor(name:String,age:Int){
		val name:String = name
		val age:Int = age 
 }
  
  class Person(val name: String, var age: Int) // 自动生成属性
```
  
主构造函数没有函数体 , 不能执行任何代码，初始化相关操作需在 init 初始化代码块中
 
  ```kotlin
  class Person(name: String) {
      val firstChar = name[0] // 属性初始化
    
      init {
          require(name.isNotBlank()) { "Name cannot be blank" } // 验证逻辑
      }
  }
  ```

2. **次构造函数（Secondary Constructor）**
	
	在类体内使用 `constructor` 关键字定义
	 **必须直接或间接委托给主构造函数**（通过 `this()`）


```kotlin
class Person(val name: String) {
    var age: Int = 0
    
    constructor(name: String, age: Int) : this(name) {
        this.age = age // 委托后执行额外逻辑
    }
}

// 一般格式：
constructor ( 构造函数参数列表 ) : this ( 委托的主/其它次构造函数参数列表 ){ 
	//次构造函数体 
}
```

**属性声明限制**：次构造函数参数**不能**声明为 `val`/`var`
**默认构造函数**：无构造声明时，自动生成无参 public 主构造

**与继承交互**：子类必须初始化父类主构造

```kotlin
   class Student(name: String) : Person(name) 
```

**执行顺序**

先执行主构造函数 , 此时会初始化成员属性 与 执行 init 初始化代码块 , 然后执行次构造函数内容

#### 3.3. 继承

**基础规则**

1. **所有类的基类**：所有 Kotlin 类都隐式继承自 `Any` 类（相当于 Java 的 `Object`）
   ```kotlin
   class Example // 隐式继承自 Any
   ```

	`Any` 有三个方法：`equals()`、 `hashCode()` 与 `toString()`。因此，为所有 Kotlin 类都定义了这些方法。

2. **默认不可继承**：Kotlin 类默认是 `final` 的，必须使用 `open` 关键字才能被继承
   ```kotlin
   open class Base // 可被继承
   class Derived : Base() // 继承
   ```

3. **构造函数要求**：
   - 子类**必须**初始化父类的主构造函数
   - 如果父类有主构造，子类必须在声明中调用它
   ```kotlin
   open class Parent(val name: String)
   class Child(name: String) : Parent(name) // ✅ 正确
   ```

**方法覆盖（Override）**
- 父类方法必须标记 `open` 才能被覆盖
- 子类必须使用 `override` 关键字显式覆盖
- 覆盖后的方法默认是 `open` 的，可用 `final` 禁止进一步覆盖

```kotlin
open class Animal {
    open fun makeSound() = "Generic animal sound"
}

class Cat : Animal() {
    final override fun makeSound() = "Meow!" // 禁止Cat的子类覆盖此方法
}
```

**属性覆盖**
- 支持用 `val` 覆盖 `val`
- 支持用 `var` 覆盖 `val`（因为 var 有 setter）
- **禁止**用 `val` 覆盖 `var`（会丢失 setter）
```kotlin
open class Shape {
    open val vertexCount: Int = 0
    open var color: String = "White"
}

class Triangle : Shape() {
    override val vertexCount = 3 // ✅
    // override val color = "Red" // ❌ 错误！不能用val覆盖var
    override var color = "Red"   // ✅
}
```

初始化顺序问题

```kotlin
open class Base {
    open val value: String = "Base"
    init { println("Base init: $value") }
}

class Derived : Base() {
    override val value: String = "Derived"
    init { println("Derived init: $value") }
}

// 创建Derived实例时输出：
// Base init: null  ← 危险！此时Derived的value还未初始化
// Derived init: Derived
```

**解决方案**：
- 使用 `lateinit var` 代替 `val`
- 或在父类中使用函数代替属性
```kotlin
open class SafeBase {
    open fun getValue() = "Base"
    init { println("Base init: ${getValue()}") } // 使用函数
}
```

**可见性修饰符与继承**

| 修饰符       | 类成员       | 顶层声明    | 继承影响                     |
|--------------|-------------|------------|----------------------------|
| `public`     | 所有地方可见  | 所有地方可见 | 无限制                     |
| `internal`   | 同模块可见    | 同模块可见  | 同模块子类可见             |
| `protected`  | 子类可见      | ❌ 不可用    | 子类可访问                 |
| `private`    | 类内部可见    | 文件内可见  | 子类不可访问               |

```kotlin
open class Visibility {
    private val a = 1    // 仅当前类可见
    protected val b = 2  // 子类可见
    internal val c = 3   // 同模块可见
    val d = 4            // 默认public
}

class Sub : Visibility() {
    fun show() {
        // println(a) // ❌ 不可访问
        println(b)   // ✅
        println(c)   // ✅（同模块）
        println(d)   // ✅
    }
}
```

**调用超类实现**

派生类中的代码可以使用 `super` 关键字调用其超类的函数与属性访问器的实现：

```kotlin
open class Rectangle {
    open fun draw() { println("Drawing a rectangle") }
    val borderColor: String get() = "black"
}

class FilledRectangle : Rectangle() {
    override fun draw() {
        super.draw()
        println("Filling the rectangle")
    }

    val fillColor: String get() = super.borderColor
}
```

在一个内部类中访问外部类的超类，可以使用由外部类名限定的 `super` 关键字来实现：`super@Outer`：

```kotlin
open class Rectangle {
    open fun draw() { println("Drawing a rectangle") }
    val borderColor: String get() = "black"
}

//sampleStart
class FilledRectangle: Rectangle() {
    override fun draw() {
        val filler = Filler()
        filler.drawAndFill()
    }

    inner class Filler {
        fun fill() { println("Filling") }
        fun drawAndFill() {
            super@FilledRectangle.draw() // 调用 Rectangle 的 draw() 实现
            fill()
            println("Drawn a filled rectangle with color ${super@FilledRectangle.borderColor}") // 使用 Rectangle 所实现的 borderColor 的 get()
        }
    }
}
//sampleEnd

fun main() {
    val fr = FilledRectangle()
        fr.draw()
}
```

**覆盖规则**

在 Kotlin 中，实现继承由下述规则规定：如果一个类从它的直接超类继承相同成员的多个实现， 它必须覆盖这个成员并提供其自己的实现（也许用继承来的其中之一）。

如需表示采用从哪个超类型继承的实现，请使用由尖括号中超类型名限定的 `super` ，如 `super<Base>`：

```kotlin
open class Rectangle {
    open fun draw() { /* …… */ }
}

interface Polygon {
    fun draw() { /* …… */ } // 接口成员默认就是“open”的
}

class Square() : Rectangle(), Polygon {
    // 编译器要求覆盖 draw()：
    override fun draw() {
        super<Rectangle>.draw() // 调用 Rectangle.draw()
        super<Polygon>.draw() // 调用 Polygon.draw()
    }
}
```

可以同时继承 `Rectangle` 与 `Polygon`， 但是二者都有各自的 `draw()` 实现，所以必须在 `Square` 中覆盖 `draw()`， 并为其提供一个单独的实现以消除歧义。

#### 3.4. 属性

**声明属性**

Kotlin 类中的属性既可以用关键字 `var` 声明为可变的， 也可以用关键字 `val` 声明为只读的。

```kotlin
class Address {
    var name: String = "Holmes, Sherlock"
    var street: String = "Baker"
    var city: String = "London"
    var state: String? = null
    var zip: String = "123456"
}
```

使用一个属性，以其名称引用它即可：

```kotlin
fun copyAddress(address: Address): Address {
    val result = Address() 
    result.name = address.name // 将调用访问器
    result.street = address.street
    // ……
    return result
}
```

**Getter 与 Setter**

声明一个属性的完整语法如下：

```kotlin
var <propertyName>[: <PropertyType>] [= <property_initializer>]
    [<getter>]
    [<setter>]
```

其初始器（initializer）、getter 和 setter 都是可选的

属性类型如果可以从初始器， 或其 getter 的返回值中推断出来，也可以省略

一个只读属性的语法和一个可变的属性的语法有两方面的不同： 
- 只读属性的用 `val` 而不是 `var` 声明
- 只读属性不允许 setter

```kotlin
val simple: Int? // 类型 Int、默认 getter、必须在构造函数中初始化
val inferredType = 1 // 类型 Int 、默认 getter
```

可以为属性定义自定义的访问器。如果定义了一个自定义的 getter，那么每次访问该属性时都会调用它 （这让可以实现计算出的属性）

```kotlin
//sampleStart
class Rectangle(val width: Int, val height: Int) {
    val area: Int // property type is optional since it can be inferred from the getter's return type
        get() = this.width * this.height
}
//sampleEnd
fun main() {
    val rectangle = Rectangle(3, 4)
    println("Width=${rectangle.width}, height=${rectangle.height}, area=${rectangle.area}")
}
```

如果可以从 getter 推断出属性类型，则可以省略它：

```kotlin
val area get() = this.width * this.height
```

如果定义了一个自定义的 setter，那么每次给属性赋值时都会调用它（初始化除外）

```kotlin
var stringRepresentation: String
    get() = this.toString()
    set(value) {
        setDataFromString(value) // 解析字符串并赋值给其他属性
    }
```


#### 3.5. 接口

**接口声明**

使用关键字 `interface` 来定义接口：

```kotlin
interface Animal {
    fun makeSound()  // 抽象方法
    fun sleep() {    // 带默认实现的方法
        println("Zzz...")
    }
}
```

**接口继承与实现**

一个接口可以从其他接口派生，意味着既能提供基类型成员的实现也能声明新的函数与属性。

很自然地，实现这样接口的类只需定义所缺少的实现：

```kotlin
class Dog : Animal {
    override fun makeSound() {  // 必须实现抽象方法
        println("Woof!")
    }
    // 不一定要覆盖 sleep()，因为已有默认实现
}

val dog = Dog()
dog.makeSound() // 输出: Woof!
dog.sleep()     // 输出: Zzz...
```

**接口中的属性**

可以在接口中定义属性。在接口中声明的属性要么是抽象的，要么提供访问器的实现。在接口中声明的属性不能有幕后字段（backing field），因此接口中声明的访问器不能引用它们：

1. 抽象属性

```kotlin
interface Named {
    val name: String  // 抽象属性
}

// 实现: 
// 方式1: 主构造函数
class Person(override val name: String) : Named

// 方式2: 自定义 getter
class Organization : Named {
    override val name: String
        get() = "Global Tech Inc."
}

// 方式3: 初始化属性
class Pet : Named {
    override val name = "Buddy"
}
```

2. 带访问器的属性

```kotlin
interface User {
    val email: String
    val nickname: String
        get() = email.substringBefore('@')  // 提供默认实现
}

class RegisteredUser(override val email: String) : User

```

**解决覆盖冲突**

实现多个接口时，可能会遇到同一方法继承多个实现的问题：此时需要重写该方法

```kotlin
interface A {
    fun foo() { print("A") }
    fun bar()
}

interface B {
    fun foo() { print("B") }
    fun bar() { print("bar") }
}

class C : A {
    override fun bar() { print("bar") }
}

class D : A, B {
    override fun foo() {
        super<A>.foo()
        super<B>.foo()
    }

    override fun bar() {
        super<B>.bar()
    }
}
```

#### 3.6. 函数式（SAM）接口

只有一个抽象成员函数的接口称为_函数式接口_或 _单一抽象方法（SAM）_接口。函数式接口可以有多个非抽象成员函数，但只能有一个抽象成员函数。

可以用 `fun` 修饰符在 Kotlin 中声明一个函数式接口。

```kotlin
fun interface KRunnable {
   fun invoke()
}
```

**SAM 转换**

对于函数式接口，可以通过lambda 表达式实现 SAM 转换，从而使代码更简洁、更有可读性。

例如，有这样一个 Kotlin 函数式接口：

```kotlin
fun interface IntPredicate {
   fun accept(i: Int): Boolean
}

// 一般的编写方法
// 创建一个类的实例，重写方法
val isEven = object : IntPredicate {
   override fun accept(i: Int): Boolean {
       return i % 2 == 0
   }
}

// 转换方法
// 通过 lambda 表达式创建一个实例
val isEven = IntPredicate { it % 2 == 0 }
```

#### 3.7. 扩展

**扩展的本质**
- **静态解析**：扩展在编译时静态解析，不修改原始类，其实质是静态函数的语法包装
- **接收者**：被扩展的类称为"接收者类型"

```kotlin
// 扩展函数定义
fun String.addExclamation(): String = "$this!"

// 编译后实质
public static final String addExclamation(String receiver) {
    return receiver + "!";
}
```

| 类型             | 描述                     | 示例                          |
|------------------|--------------------------|-------------------------------|
| 扩展函数         | 为类添加新方法           | `fun String.reverse() {...}`  |
| 扩展属性         | 为类添加新属性           | `val String.lastChar: Char`   |
| 扩展操作符       | 重载操作符行为           | `operator fun Point.plus(...)`|
| 伴生对象扩展     | 扩展伴生对象功能         | `fun MyClass.Companion.foo()` |

**扩展函数**

声明一个扩展函数需用一个_接收者类型_也就是被扩展的类型来作为他的前缀。

```kotlin
// 为String类添加新方法
fun String.addStars(prefix: String, suffix: String): String {
    return "$prefix$this$suffix"
}

// 使用
println("Kotlin".addStars("★", "★")) // 输出: ★Kotlin★
```

其中的 `this` 关键字在扩展函数内部对应到接收者对象（传过来的在点符号前的对象）

**可空接收者**

```kotlin
// 为可空类型添加安全扩展
fun String?.safeLength(): Int = this?.length ?: 0

// 使用
val nullStr: String? = null
println(nullStr.safeLength()) // 输出: 0
```

**扩展属性**

与扩展函数类似，Kotlin 支持扩展属性，同时具有以下特性
- 不能有初始化器（没有幕后字段）
- 必须明确提供 getter（对于 val）和 setter（对于 var）
- 不能添加实际存储状态


```kotlin
// 为String添加只读扩展属性
val String.lastChar: Char
    get() = this[length - 1]

// 为StringBuilder添加可变扩展属性
var StringBuilder.lastChar: Char
    get() = get(length - 1)
    set(value) = setCharAt(length - 1, value)

// 使用
println("Kotlin".lastChar) // 'n'

val sb = StringBuilder("Kotlin?")
sb.lastChar = '!'
println(sb) // "Kotlin!"
```

**泛型扩展**

```kotlin
// 为所有List添加扩展
fun <T> List<T>.penultimate(): T {
    if (size < 2) 
        throw NoSuchElementException("List has less than 2 elements")
    return this[size - 2]
}

// 使用
val list = listOf(1, 2, 3, 4)
println(list.penultimate()) // 输出: 3

// 为所有集合添加属性
val <T> List<T>.secondOrNull: T?
    get() = if (size >= 2) this[1] else null

// 使用
println(listOf(1, 2).secondOrNull) // 2
println(listOf(1).secondOrNull)    // null
```

**扩展操作符函数**

```kotlin
data class Point(val x: Int, val y: Int)

// 重载+操作符
operator fun Point.plus(other: Point): Point {
    return Point(x + other.x, y + other.y)
}

// 使用
val p1 = Point(10, 20)
val p2 = Point(5, 5)
println(p1 + p2) // Point(x=15, y=25)
```

#### 3.8. 泛型

Kotlin 中的类可以有类型参数，与 Java 类似：

```kotlin
class Box<T>(t: T) {
    var value = t
}
```

创建这样类的实例只需提供类型参数即可：

```kotlin
val box: Box<Int> = Box<Int>(1)
```

但是如果类型参数可以推断出来，例如从构造函数的参数或者从其他途径， 就可以省略类型参数：

```kotlin
val box = Box(1) // 1 具有类型 Int，所以编译器推算出它是 Box<Int>
```

**泛型函数**

同样的，对于函数，也可使用类型参数编写范型函数

```kotlin
// 泛型函数
fun <T> singletonList(item: T): List<T> {
    return listOf(item)
}

// 多个类型参数
fun <K, V> put(key: K, value: V): Map<K, V> {
    return mapOf(key to value)
}

// 使用
val list = singletonList("Kotlin")
val map = put("version", 1.8)
```

**类型参数约束**

可以使用 `:` 为类型参数添加约束，未指定约束时，默认上界是 `Any?`

```kotlin
// 单一约束
fun <T : Comparable<T>> sort(list: List<T>) {
    // 只有可比较类型才能排序
    list.sorted()
}

// 多个约束 (使用 where 子句)
fun <T> cloneWhenGreater(list: List<T>, threshold: T): List<T>
    where T : Comparable<T>,
          T : Cloneable {
    return list.filter { it > threshold }.map { it.clone() }
}
```

**型变 (Variance)**

在泛型中，型变指的是子类型和超类型之间的关系中，泛型类型参数是否具有相同的变化方向。`Java` 和 `Kotlin` 中支持通常的型变方式：协变和逆变，与不变对应。

**不变、协变、逆变**，他们统称为型变

1. **不变** (Invariant)：Container<父类> 与 Container<子类> 无关系

	有继承关系的两个类，在变成泛型类型时不再有关系

```kotlin
class Box<T>(var item: T)

open class Book
class MathBook : Book()

// 编译错误：类型不匹配
val bookBox: Box<Book> = Box<MathBook>(MathBook()) ❌
```

2. **协变** (Covariance - out)：Container<子类> 是 Container<父类> 的子类 

	**注**：经过协变之后，数据是可读不可写的

```kotlin
// 使用 out 关键字声明协变
interface Producer<out T> {
    fun produce(): T
}

// 协变允许子类型关系传递
val stringProducer: Producer<String> = StringProducer()
val anyProducer: Producer<Any> = stringProducer // 安全，因为 T 只出现在输出位置
```

3. **逆变** (Contravariance - in)：Container<父类> 是 Container<子类> 的子类

```kotlin
class Writer<in T> {
    fun write(item: T) { /*...*/ } // ✅ 允许输入
    // fun get(): T { ... } ❌ 禁止输出
}

val bookWriter: Writer<Book> = Writer()
val mathWriter: Writer<MathBook> = bookWriter // ✅ 逆变成功

mathWriter.write(MathBook()) // 实际调用 bookWriter
```


| 特性        | 协变 (`out`)               | 逆变 (`in`)                | 不变            |
| --------- | ------------------------ | ------------------------ | ------------- |
| **关键字**   | `out`                    | `in`                     | 无             |
| **子类型关系** | `C<Child>` ➔ `C<Parent>` | `C<Parent>` ➔ `C<Child>` | 无关系           |
| **数据流**   | 生产者 (输出)                 | 消费者 (输入)                 | 双向            |
| **可读性**   | ✅ (返回 T)                 | ❌ (返回 Any?)              | ✅             |
| **可写性**   | ❌                        | ✅ (接收 T)                 | ✅             |
| **典型应用**  | `List`, `Producer`       | `Consumer`, `Comparator` | `MutableList` |

**类型投影 (Type Projections)**

1. 使用处型变 (Use-site Variance)

```kotlin
// 协变投影 (相当于 Java 的 ? extends T)
fun copy(from: Array<out Any>, to: Array<Any>) {
    for (i in from.indices) {
        to[i] = from[i] // 可以读取，但不能写入
    }
}

// 逆变投影 (相当于 Java 的 ? super T)
fun fill(dest: Array<in String>, value: String) {
    dest[0] = value // 可以写入，但读取只能得到 Any?
}
```

2. 星投影 (Star Projections)

```kotlin
// 当类型参数未知时使用
fun printSize(list: List<*>) {
    println("Size: ${list.size}") // 可以访问不依赖具体类型的方法
}

// 等价于
fun <T> printSize(list: List<T>) {
    println("Size: ${list.size}")
}
```

### 四、函数

#### 4.1. 函数

**函数声明**：使用 `fun` 关键字声明

```kotlin
// 完整声明
fun add(a: Int, b: Int): Int {
    return a + b
}

// 表达式体函数（自动推断返回类型）
fun subtract(a: Int, b: Int) = a - b

// 无返回值函数
fun printMessage(message: String): Unit {
    println(message)
}

// Unit 可省略
fun printInfo(info: String) {
    println(info)
}
```

**函数参数**

函数参数使用 Pascal 表示法定义——_name_: _type_。

参数用逗号隔开， 每个参数必须有显式类型

1. 默认参数：函数参数可以有默认值，当省略相应的参数时使用默认值

```kotlin
fun greet(name: String = "Guest", greeting: String = "Hello") {
    println("$greeting, $name!")
}

greet() // Hello, Guest!
greet("Alice") // Hello, Alice!
greet(greeting = "Hi", name = "Bob") // Hi, Bob!
```

覆盖方法总是使用与基类型方法相同的默认实参值。 当覆盖一个有默认实参值的方法时，必须从签名中省略默认实参值：

```kotlin
open class A {
    open fun foo(i: Int = 10) { /*……*/ }
}

class B : A() {
    override fun foo(i: Int) { /*……*/ }  // 不能有默认值
}
```

如果一个有默认值参数在一个无默认值的参数之前，那么该默认值只能通过使用具名参数调用该函数来使用：

```kotlin
fun foo(
    bar: Int = 0,
    baz: Int,
) { /*……*/ }

foo(baz = 1) // 使用默认值 bar = 0
```

2. 具名参数：
	
	当然，当调用这个函数时，不一定要让其所有参数都具名

```kotlin
fun createUser(name: String, age: Int, email: String, isAdmin: Boolean = false) { /*...*/ }

// 可读性更高的调用
createUser(
    name = "John Doe",
    age = 30,
    email = "john@example.com",
    isAdmin = true
)
```

3. 可变数量参数 (vararg)

```kotlin
fun printAll(vararg messages: String) {
    for (m in messages) println(m)
}

printAll("Hello", "Kotlin", "World")

// 使用展开运算符 (*) 传递数组
val colors = arrayOf("Red", "Green", "Blue")
printAll(*colors)
```

**一些特殊的函数**：

1. 单表达式函数

	当函数体由单个表达式构成时，可以省略花括号并且在 `=` 符号之后指定代码体即可：

```kotlin
fun double(x: Int): Int = x * 2
```

2.  中缀函数

	标有 `infix` 关键字的函数也可以使用中缀表示法（忽略该调用的点与圆括号）调用。 中缀函数必须满足以下要求：
	- 它们必须是成员函数或扩展函数
	- 它们必须只有一个参数。
	- 其参数不得接受可变数量的参数且不能有默认值


	```kotlin
	infix fun Int.shl(x: Int): Int { …… }

	// 用中缀表示法调用该函数
	1 shl 2

	// 等同于这样
	1.shl(2)
	```

	**注**： 
	- 中缀函数调用的优先级低于算术操作符、类型转换以及 `rangeTo` 操作符。 
	- 中缀函数调用的优先级高于布尔操作符 `&&` 与 `||`、`is-` 与 `in-` 检测以及其他一些操作符。
	- 中缀函数总是要求指定接收者与参数。当使用中缀表示法在当前接收者上调用方法时，需要显式使用 `this`


3. 尾递归函数

	Kotlin 支持一种称为尾递归的函数式编程风格。 对于某些使用循环的算法，可以使用尾递归替代而不会有堆栈溢出的风险。 当一个函数用 `tailrec` 修饰符标记并满足所需的形式条件时，编译器会优化该递归， 留下一个快速而高效的基于循环的版本：

```kotlin
val eps = 1E-10 // "good enough", could be 10^-15

tailrec fun findFixPoint(x: Double = 1.0): Double =
    if (Math.abs(x - Math.cos(x)) < eps) x else findFixPoint(Math.cos(x))
```

这段代码计算余弦的不动点（`fixpoint` of cosine），这是一个数学常数。 它只是重复地从 `1.0` 开始调用 `Math.cos`， 直到结果不再改变，对于这里指定的 `eps` 精度会产生 `0.7390851332151611` 的结果。最终代码相当于这种更传统风格的代码：

```kotlin
val eps = 1E-10 // "good enough", could be 10^-15

private fun findFixPoint(): Double {
    var x = 1.0
    while (true) {
        val y = Math.cos(x)
        if (Math.abs(x - y) < eps) return x
        x = Math.cos(x)
    }
}
```

要符合 `tailrec` 修饰符的条件的话，函数必须将其自身调用作为它执行的最后一个操作。在递归调用后有更多代码时， 不能使用尾递归，不能用在 `try`/`catch`/`finally` 块中，也不能用于 open 的函数。 目前在 Kotlin for the JVM 与 Kotlin/Native 中支持尾递归。


#### 4.2. 高阶函数

1. **函数类型声明**
	
	Kotlin 中函数是一等公民，可以像普通变量一样声明和使用：

```kotlin
// 声明函数类型变量
val sum: (Int, Int) -> Int = { a, b -> a + b }

// 等价于
val sum = { a: Int, b: Int -> a + b }

// 使用
println(sum(2, 3)) // 输出: 5
```

所有函数类型都有一个圆括号括起来的参数类型列表以及一个返回类型：`(A, B) -> C` 表示接受类型分别为 `A` 与 `B` 两个参数并返回一个 `C` 类型值的函数类型。 参数类型列表可以为空，如 `() -> A`。`Unit` 返回类型不可省略。

| 语法结构             | 示例                                   | 说明      |
| ---------------- | ------------------------------------ | ------- |
| `(参数类型) -> 返回类型` | `(Int, String) -> Boolean`           | 基本函数类型  |
| `() -> Unit`     | `{ println("Hello") }`               | 无参数无返回值 |
| `(T) -> R?`      | `(String) -> Int?`                   | 可空返回类型  |
| `((T) -> R)?`    | `var callback: (() -> Unit)? = null` | 可空函数类型  |

2. **定义高阶函数**
	 
	 高阶函数是将函数用作参数或返回值的函数。

```kotlin
fun <T, R> Collection<T>.fold(
    initial: R, 
    combine: (acc: R, nextElement: T) -> R
): R {
    var accumulator: R = initial
    for (element: T in this) {
        accumulator = combine(accumulator, element)
    }
    return accumulator
}	
```

在上述代码中，参数 `combine` 具有函数类型 `(R, T) -> R`

为了调用 `fold`，需要传给它一个函数类型的实例作为参数

```kotlin
fun main() {
    //sampleStart
    val items = listOf(1, 2, 3, 4, 5)

    // Lambdas 表达式是花括号括起来的代码块。
    items.fold(0, { 
        // 如果一个 lambda 表达式有参数，前面是参数，后跟“->”
        acc: Int, i: Int -> 
        print("acc = $acc, i = $i, ") 
        val result = acc + i
        println("result = $result")
        // lambda 表达式中的最后一个表达式是返回值：
        result
    })

    // lambda 表达式的参数类型是可选的，如果能够推断出来的话：
    val joinedToString = items.fold("Elements:", { acc, i -> acc + " " + i })

    // 函数引用也可以用于高阶函数调用：
    val product = items.fold(1, Int::times)
    //sampleEnd
    println("joinedToString = $joinedToString")
    println("product = $product")
}
```

**标准库高阶函数**

1. **作用域函数**
	
| 函数      | 接收者  | 返回值      | 适用场景   |
| ------- | ---- | -------- | ------ |
| `let`   | it   | Lambda结果 | 空检查、转换 |
| `run`   | this | Lambda结果 | 对象初始化  |
| `with`  | this | Lambda结果 | 对象配置   |
| `apply` | this | 接收者本身    | 对象构建   |
| `also`  | it   | 接收者本身    | 副作用操作  |

```kotlin
val message = StringBuilder().apply {
    append("Hello, ")
    append("World!")
}.toString()

println(message) // Hello, World!
```

 2. 集合操作
 
```kotlin
val numbers = listOf(1, 2, 3, 4, 5)

// 1. 过滤
val evens = numbers.filter { it % 2 == 0 }

// 2. 转换
val squares = numbers.map { it * it }

// 3. 折叠
val sum = numbers.fold(0) { acc, num -> acc + num }

// 4. 分组
val grouped = numbers.groupBy { if (it % 2 == 0) "even" else "odd" }
```
#### 4.3. Lambda 表达式

Lambda 表达式是匿名函数的简写形式：

```kotlin
{ 参数 -> 函数体 }
```

- lambda 表达式总是括在花括号中。
- 完整语法形式的参数声明放在花括号内，并有可选的类型标注。
- 函数体跟在一个 `->` 之后。
- 如果推断出的该 lambda 的返回类型不是 `Unit`，那么该 lambda 主体中的最后一个（或可能是单个）表达式会视为返回值。

如果将所有可选标注都留下，看起来如下：

```kotlin
val sum = { x: Int, y: Int -> x + y }
```

**lambda特性**

1. 如果函数的最后一个参数是函数，那么作为相应参数传入的 lambda 表达式可以放在圆括号之外（这种语法也称为_拖尾 lambda 表达式_）：

```kotlin
val product = items.fold(1) { acc, e -> acc * e }
```

2. 如果该 lambda 表达式是调用时唯一的参数，那么圆括号可以完全省略：

```kotlin
run { println("...") }
```

3. 当一个 lambda 表达式只有一个参数时该参数会隐式声明为 it：

```kotlin
ints.filter { it > 0 } // 这个字面值是“(it: Int) -> Boolean”类型的
```

4. 如果 lambda 表达式的参数未使用，那么可以用下划线取代其名称：

```kotlin
map.forEach { (_, value) -> println("$value!") }
``````

**从 lambda 表达式中返回值**

1. 使用限定的返回语法从 lambda 显式返回一个值
2. 隐式返回最后一个表达式的值

```kotlin
//隐式返回最后一个表达式的值
ints.filter {
    val shouldFilter = it > 0
    shouldFilter
}

//显示返回
ints.filter {
    val shouldFilter = it > 0
    return@filter shouldFilter
}
```

#### 4.4. 匿名函数

匿名函数看起来非常像一个常规函数声明，除了其名称省略了。其函数体既可以是表达式也可以是代码块：

```kotlin
fun(x: Int, y: Int): Int {
    return x + y
}
```

参数和返回类型的指定方式与常规函数相同，除了能够从上下文推断出的参数类型可以省略：

```kotlin
ints.filter(fun(item) = item > 0)
```

 当匿名函数作为参数传递时，需将其放在括号内。 允许将函数留在圆括号外的简写语法仅适用于 lambda 表达式。

Lambda表达式与匿名函数之间的另一个区别是非局部返回的行为。 一个不带标签的 `return` 语句总是在用 `fun` 关键字声明的函数中返回。这意味着 lambda 表达式中的 `return` 将从包含它的函数返回，而匿名函数中的 `return` 将从匿名函数自身返回。

#### 4.5. 内联函数

 **`inline` 关键字**‌：声明函数时使用 `inline`，表示该函数及其 Lambda 参数在编译时会被“内联”到调用处。

```kotlin
inline fun <T> measureTime(block: () -> T): T { 
	val start = System.currentTimeMillis()
	val result = block()
	val end = System.currentTimeMillis() 
	println("Time taken: ${end - start} ms")
	return result
}
```

**内联函数的优势**‌

1. 减少 Lambda 开销
	- ‌**普通高阶函数**‌：每次调用会为 Lambda 参数生成匿名类对象（如 `Function0`, `Function1` 等）。
	- ‌**内联高阶函数**‌：Lambda 的代码会被直接插入调用处，避免创建额外对象。

2. 支持非局部返回（Non-local Return）
	- 在普通 Lambda 中，`return` 只能退出 Lambda 自身。
	- 在内联函数的 Lambda 中，`return` 可以直接从外层函数返回（类似 `return` 在普通函数中的行为）。

```kotlin
fun findUser(users: List<User>, inlineBlock: (User) -> Boolean): User? {     for (user in users) {
		if (inlineBlock(user)) return user // 允许直接返回外层函数     
	}     
	return null 
}
```

**使用限制**‌
- ‌**避免内联过大函数**‌：内联会导致代码体积膨胀，尤其是函数体较大时。
- ‌**部分参数禁止内联**‌：使用 `noinline` 关键字标记不需要内联的 Lambda 参数。
- ‌**公有 API 谨慎内联**‌：内联函数修改后，调用方的代码需要重新编译。


### 五、 异步程序设计

#### 5.1. 线程 (Threads)

线程是操作系统调度的最小执行单元。一个进程可以包含多个线程，共享进程的内存空间（堆），但拥有各自的栈。

Kotlin 直接使用 Java 的 `java.lang.Thread` 类及其相关 API (`Runnable`, `ExecutorService`, `Executors`) 来创建和管理线程。

**创建线程：** 方法同Java                [multithreading.md](https://github.com/lu-nanan/note/blob/main/java/多线程编程/multithreading.md)

```kotlin
    val thread = Thread {
        // 在后台线程中执行的耗时代码
        val result = doLongRunningTask()
        // 更新 UI？注意：不能直接在后台线程更新 UI！
        runOnUiThread { // (假设在 Android 环境中)
            updateUI(result)
        }
    }
    thread.start()
```

**使用线程池 (`ExecutorService`)：** 避免频繁创建销毁线程的开销。
        
```kotlin
	val executor: ExecutorService = Executors.newFixedThreadPool(4) // 创建包含 4 个线程的池

    executor.execute {
        val result1 = task1()
        runOnUiThread { updatePart1(result1) }
    }

    executor.execute {
        val result2 = task2()
        runOnUiThread { updatePart2(result2) }
    }

    // 记得在适当的时候关闭线程池 (例如应用退出时)
    executor.shutdown()
    ```
#### 5.2. 回调 (Callbacks)

回调是将一个函数（回调函数）作为参数传递给另一个函数（通常是异步函数）。

当异步操作完成（成功或失败）时，该异步函数会调用传入的回调函数来通知结果。

```kotlin
	fun doAsyncTask(callback: (Result) -> Unit) {
	    // 模拟在后台线程执行
	    thread {
	        val result = performTask() // 耗时操作
	        callback(result) // 操作完成，调用回调传递结果
	    }
	}
	
	// 使用
	doAsyncTask { result ->
	    runOnUiThread { // 切换回主线程更新 UI
	        handleResult(result)
	    }
	}
```

**处理成功/失败：** 通常使用两个回调参数或一个封装了结果/异常的类。

```kotlin
	// 方式1：两个 Lambda
	fun doAsyncTask(
	    onSuccess: (Result) -> Unit,
	    onError: (Throwable) -> Unit
	) {
	    thread {
	        try {
	            val result = performTask()
	            onSuccess(result)
	        } catch (e: Exception) {
	            onError(e)
	        }
	    }
	}
	
	// 方式2：使用一个包含结果或异常的密封类 Result
	sealed class Result {
	    data class Success(val data: T) : Result()
	    data class Error(val exception: Throwable) : Result()
	}
	
	fun doAsyncTask(callback: (Result) -> Unit) { ... }
	
	doAsyncTask { result ->
	    when (result) {
	        is Result.Success -> handleSuccess(result.data)
	        is Result.Error -> handleError(result.exception)
	    }
	}
 ```

#### 5.3. 协程

本质上，协程可以称为**轻量级线程**，在 CoroutineScope （协程作用域）的上下文中通过 launch、async 等协程构造器（coroutine builder）来启动。

```kotlin
import kotlinx.coroutines.*

fun main() {
    GlobalScope.launch { // 在后台启动一个新协程，并继续执行之后的代码
        delay(1000L) // 非阻塞式地延迟一秒
        println("World!") // 延迟结束后打印
    }
    println("Hello,") //主线程继续执行，不受协程 delay 所影响
    Thread.sleep(2000L) // 主线程阻塞式睡眠2秒，以此来保证JVM存活
}
```

详细的内容见：[协程.md](https://github.com/lu-nanan/note/blob/main/Android/协程.md)

 
