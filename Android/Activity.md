---
tags:
  - Android
  - 四大组件
  - Activity
---
### 一、基本概念

#### 1.1. 概述

- **定义**：Activity 是 Android 应用的核心组件，代表用户交互的单个屏幕
- **作用**：
  - 提供应用与用户交互的入口点
  - 提供绘制界面的窗口（通常全屏，也可小于屏幕）
  - 实现应用中的独立功能屏幕（如设置页、照片选择页）
- **特点**：
  - 移动应用体验不同于桌面：用户旅程起点不确定
  - Activity 之间松散耦合，可跨应用调用
  - 每个 Activity 是 Activity 类的子类

#### 1.2. 配置清单声明

1. **基本声明**
```xml
<manifest>
  <application>
    <activity android:name=".ExampleActivity" />
  </application>
</manifest>
```
- **必需属性**：`android:name`（类名）
- **注意**：发布后不应修改 Activity 名称

2. **Intent** 过滤器
```xml
<activity android:name=".ShareActivity">
  <intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/plain" />
  </intent-filter>
</activity>
```
- 支持隐式 Intent 调用
- 必需组件：
  - `<action>`：指定可处理的操作
  - `<category>`：通常包含 `DEFAULT`
  - `<data>`：指定数据类型（可选）

 3. **权限声明**
**被调用方声明**：
```xml
<activity 
  android:name=".SocialActivity"
  android:permission="com.example.permission.SHARE_POST" />
```

**调用方声明**：
```xml
<uses-permission android:name="com.example.permission.SHARE_POST" />
```

### 二、Activity 生命周期

Android Activity生命周期是指Activity从创建到销毁的完整过程，开发者可以通过重写生命周期方法来管理资源和状态。核心方法包括：

```java
public class Activity {
    protected void onCreate(Bundle savedInstanceState);   // 初始化
    protected void onStart();      // 可见但无焦点
    protected void onResume();     // 获得焦点（交互态）
    protected void onPause();      // 失去焦点（仍部分可见）
    protected void onStop();       // 完全不可见
    protected void onDestroy();    // 被销毁前
    protected void onRestart();    // 从停止状态恢复
}
```

![[Activity_Activity的生命周期.png]]

``` 
启动流程：
onCreate() → onStart() → onResume()

正常退出流程：
onPause() → onStop() → onDestroy()

按HOME键流程：
onPause() → onStop() 

返回应用时：
onRestart() → onStart() → onResume()
```

#### 核心回调方法
| 方法              | 触发时机           | 典型用途                             |
| --------------- | -------------- | -------------------------------- |
| **onCreate()**  | Activity 首次创建时 | 初始化组件、绑定数据、调用 `setContentView()` |
| **onStart()**   | Activity 可见时   | 最终准备工作，进入前台前                     |
| **onResume()**  | Activity 开始交互时 | 实现核心功能，获取焦点                      |
| **onPause()**   | 失去焦点时          | 轻量级清理（避免耗时操作）                    |
| **onStop()**    | 完全不可见时         | 释放非关键资源                          |
| **onRestart()** | 从停止状态恢复时       | 恢复停止时的状态                         |
| **onDestroy()** | 销毁前            | 释放所有资源，最终清理                      |

### 三、启动模式

Activity启动模式(launchMode)决定Activity实例如何与任务栈(task)关联，控制Activity实例的创建和复用机制，主要包括以下内容：
- **任务栈(Task)**：后进先出(LIFO)的Activity集合
- **Affinity(归属关系)**：Activity所属的任务栈标识
- **复用机制**：决定是否重用已有Activity实例
#### 3.1. standard（标准模式）

最基本的启动模式，为**默认模式**

**行为特点**：每次启动都创建新实例，新实例放入启动它的Activity所在任务栈，允许多个相同Activity实例存在

**生命周期**：每次启动都执行完整生命周期（onCreate -> onDestroy）

```java
// 在AndroidManifest中声明（或不声明，默认即为standard）
<activity android:name=".StandardActivity" 
          android:launchMode="standard" />
```

```
// 1. 启动 Activity
MainActivity

//栈内容
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 2. 启动 StandardActivity
MainActivity -> StandardActivity

//栈内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 3. 启动 StandardActivity
MainActivity -> StandardActivity ->  StandardActivity

//栈内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity
```


#### 3.2. singleTop（栈顶复用模式）

**行为特点**：
  - 目标Activity位于栈顶时：复用实例，调用onNewIntent()
  - 目标Activity不在栈顶时：创建新实例

**生命周期**：
  - 复用情况：onNewIntent() -> onResume()
  - 新建情况：完整生命周期


```text
// 1. 启动 MainActivity
MainActivity
//栈内容
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 2. 启动 StandardActivity
MainActivity -> StandardActivity
//栈内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 3. 启动 SingleTopActivity
MainActivity -> StandardActivity ->  SingleTopActivity
//栈内容
com.example.launchmodetest/.SingleTopActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 4. 启动 SingleTopActivity
MainActivity -> StandardActivity ->  SingleTopActivity -> SingleTopActivity
//栈内容
com.example.launchmodetest/.SingleTopActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

//SingleTopActivity 收到 am_new_intent ，而不是创建新的 Activity
```
#### 3.3. singleTask（栈内复用模式）

**行为特点**：
  - 在系统中查找匹配的任务栈（根据taskAffinity）
  - 找到实例：清除其上的所有Activity(`clear top`)，调用onNewIntent()
  - 未找到实例：创建新实例
  
**生命周期**：
  - 复用情况：onNewIntent() -> onResume()
  - 新建情况：完整生命周期

```xml
<!-- 声明singleTask并指定taskAffinity -->
<activity android:name=".MainActivity"
          android:launchMode="singleTask"
          android:taskAffinity="com.example.app.main" />
```

```text
// 1. 启动 MainActivity：
MainActivity
//栈内容：
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 2. 启动 StandardActivity
MainActivity -> StandardActivity
//栈内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 3. 启动 SingleTaskActivity
MainActivity -> StandardActivity ->  SingleTaskActivity
//栈内容：
com.example.launchmodetest/.SingleTaskActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 4. 启动 StandardActivity
MainActivity -> StandardActivity -> SingleTaskActivity -> StandardActivity
//栈内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.SingleTaskActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 5. 启动 SingleTaskActivity
MainActivity -> StandardActivity -> SingleTaskActivity 
-> StandardActivity -> SingleTaskActivity
//栈内容：
com.example.launchmodetest/.SingleTaskActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

//备注：SingleTaskActivity 收到 am_new_intent ，将其上面的 StandardActivity Clear 掉
```

在 Manifest 中设置了 android:taskAffinity=”” 之后，启动 SingleTask 会启动一个新的 Task

```text
// 1. 启动 MainActivity
MainActivity

//栈0内容：
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 2. 启动 StandardActivity
MainActivity -> StandardActivity

//栈0内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 3. 启动 SingleTaskWithAffinity
MainActivity -> StandardActivity ->  SingleTaskWithAffinity

//栈1内容：
com.example.launchmodetest/.SingleTaskWithAffinity
//栈0内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 4. 启动 StandardActivity
MainActivity -> StandardActivity ->  SingleTaskWithAffinity -> StandardActivity

//栈1内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.SingleTaskWithAffinity
//栈0内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 5. 启动 SingleTaskWithAffinity
MainActivity -> StandardActivity ->  SingleTaskWithAffinity 
-> StandardActivity -> SingleTaskWithAffinity

//栈1内容：
com.example.launchmodetest/.SingleTaskWithAffinity
//栈0内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity
```
#### 3.4. singleInstance（单实例模式）

**行为特点**：
  - 独占一个新任务栈
  - 系统中只存在一个实例
  - 再次启动时：复用实例，调用onNewIntent()

**生命周期**：同singleTask

```text
taskAffinity=com.example.launchmodetest

// 1. 启动 MainActivity
MainActivity

//栈0内容
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 2. 启动 StandardActivity
MainActivity -> StandardActivity

//栈0内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 3. 启动 SingleInstanceActivity
MainActivity -> StandardActivity -> SingleInstanceActivity 

//栈1内容(多任务里面没有 Task)
com.example.launchmodetest/.SingleInstanceActivity
//栈0内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 4. 启动 StandardActivity
MainActivity -> StandardActivity -> SingleInstanceActivity -> StandardActivity

//栈1内容(多任务里面没有 Task)
com.example.launchmodetest/.SingleInstanceActivity
//栈0内容：
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 5. 启动 SingleInstanceActivity
MainActivity -> StandardActivity -> SingleInstanceActivity 
-> StandardActivity -> SingleInstanceActivity

//栈1内： (多任务里面没有 Task)
com.example.launchmodetest/.SingleInstanceActivity
//栈0内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 6. 启动 StandardActivity
MainActivity -> StandardActivity -> SingleInstanceActivity 
-> StandardActivity -> SingleInstanceActivity -> StandardActivity

//栈1内： (多任务里面没有 Task)
com.example.launchmodetest/.SingleInstanceActivity
//栈0内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity

-------------------------------------------------------------------
// 7. 启动 SingleInstanceActivity
MainActivity -> StandardActivity -> SingleInstanceActivity 
-> StandardActivity -> SingleInstanceActivity 
-> StandardActivity -> SingleInstanceActivity

//栈1内容 (多任务里面没有 Task)
com.example.launchmodetest/.SingleInstanceActivity
//栈0内容
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.StandardActivity
com.example.launchmodetest/.MainActivity
```

#### 3.5. Intent Flags（动态控制）

| Flag组合（[[Activity#4.5. Flag 属性]]）                    | 等效模式       | 说明              |
| ---------------------------------------------------- | ---------- | --------------- |
| `FLAG_ACTIVITY_NEW_TASK`                             | -          | 在新任务栈启动         |
| `FLAG_ACTIVITY_SINGLE_TOP`                           | singleTop  | 栈顶复用            |
| `FLAG_ACTIVITY_CLEAR_TOP`                            | -          | 清除目标之上的Activity |
| `FLAG_ACTIVITY_NEW_TASK` + `FLAG_ACTIVITY_CLEAR_TOP` | singleTask | 栈内复用            |

```java
// 示例：启动singleTask效果
Intent intent = new Intent(this, MainActivity.class);
intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP);
startActivity(intent);
```


**启动模式对比表**

| 模式                 | 多实例 | 任务栈 | 特点           | 使用场景  |
| ------------------ | --- | --- | ------------ | ----- |
| **standard**       | ✓   | 当前栈 | 每次创建新实例      | 普通页面  |
| **singleTop**      | ✓   | 当前栈 | 栈顶复用         | 防重复跳转 |
| **singleTask**     | ✗   | 专属栈 | 清除顶部Activity | 主界面   |
| **singleInstance** | ✗   | 独立栈 | 全局唯一         | 独立功能  |

### 四、intent

在 Android 开发中，`Intent` 是组件间通信的核心机制，用于启动 Activity、Service、发送广播等。
#### 4.1. `Component` 属性

**Component** 是 Intent 中用于显式指定目标组件的属性，通常通过 `ComponentName` 对象来标识一个组件，包含两个关键信息：

- **包名**：定义应用的唯一标识，如 `com.example.demo`。
- **类的完整路径名**：如 `com.example.demo.DemoActivity`。

```kotlin
val intent = Intent(MainActivity.this, DemoActivity::class.java)
startActivity(intent)
```

**获取 Component 信息：**

```kotlin
val componentName = intent.component
Log.d("Component", "Package: ${componentName?.packageName}, Class: ${componentName?.className}")
```


#### 4.2. `Action` 和 `Category` 属性

在Android中， **Action** 是一个抽象的动作，也就是说我们设置Action只是为它设定了一个动作，却并不知道这个动作具体是由哪个组件来完成

而 **Category** 主要是用于对执行动作（Action）的类别进行描述（以哪种方式去执行intent请求的action）

这两者通常结合使用，与[[Intent-Filter]]一起用于**隐式启动**组件

**常用常量**
- **Action：**
  - `Intent.ACTION_MAIN`：启动主界面。
  - `Intent.ACTION_VIEW`：查看数据。
  - `Intent.ACTION_DIAL`：拨号
  - `Intent.ACTION_SENDTO`：发短信
- **Category：**
  - `Intent.CATEGORY_DEFAULT`：默认启动方式。
  - `Intent.CATEGORY_LAUNCHER`：作为应用入口。

**隐式启动示例**

**在 `AndroidManifest.xml` 中配置：**

```xml
<activity android:name=".DemoActivity">
    <intent-filter>
        <action android:name="com.example.DEMO_ACTIVITY" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
```

**Kotlin 调用：**

```kotlin
val intent = Intent().apply {
    action = "com.example.DEMO_ACTIVITY"
    addCategory(Intent.CATEGORY_DEFAULT) // 可选，默认自动添加
}
startActivity(intent)
```

#### 4.3. `Data` 属性

**Data** 用于为 Action 提供操作的数据，通常是一个 `Uri` 对象。

**示例：跳转到拨号界面并输入号码**

```kotlin
val intent = Intent().apply {
    action = Intent.ACTION_DIAL
    data = Uri.parse("tel:123456789")
}
startActivity(intent)
```

**查看联系人信息：**

```kotlin
val intent = Intent().apply {
    action = Intent.ACTION_VIEW
    data = Uri.parse("content://com.android.contacts/contacts/1")
}
startActivity(intent)
```

**Uri 格式：**

```
scheme://host:port/path
```

**常见 scheme：**
- `tel:`（拨号）
- `content:`（内容提供者）
- `http:`（网页）


#### 4.4. `Extra` 属性

`Extra` 是 `Intent` 中用于传递数据的核心属性，通过键值对（`Bundle`）的形式在组件间传递数据。

**基本用法**：

```kotlin
// 发送端：传递数据
val intent = Intent(this, SecondActivity::class.java)
intent.putExtra("key_name", "value") // 支持基本类型、String、Parcelable等
startActivity(intent)

// 接收端：获取数据
val value = intent.getStringExtra("key_name")
```

**支持的数据类型**

| 类型     | 方法                                  | 示例                                                  |
| ------ | ----------------------------------- | --------------------------------------------------- |
| 基本类型   | `putInt`, `putBoolean`, `putDouble` | `intent.putExtra("age", 25)`                        |
| 字符串    | `putString`                         | `intent.putExtra("name", "Alice")`                  |
| 数组     | `putIntArray`, `putStringArray`     | `intent.putExtra("scores", intArrayOf(90, 85, 88))` |
| 序列化对象  | `putParcelableExtra`                | `intent.putExtra("user", user)`                     |
| Bundle | `putExtras`                         | `intent.putExtras(bundle)`                          |

对于复杂对象的传递，可使用 **`Parcelable`**：

```kotlin
data class User(
    val id: Int,
    val name: String
) : Parcelable {
    constructor(parcel: Parcel) : this(
        parcel.readInt(),
        parcel.readString() ?: ""
    )

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeInt(id)
        parcel.writeString(name)
    }

    override fun describeContents(): Int = 0

    companion object CREATOR : Parcelable.Creator<User> {
        override fun createFromParcel(parcel: Parcel): User = User(parcel)
        override fun newArray(size: Int): Array<User?> = arrayOfNulls(size)
    }
}

// 发送端
val user = User(1, "Alice")
val intent = Intent(this, SecondActivity::class.java).apply {
    putExtra("user", user)
}
startActivity(intent)

// 接收端
val user = intent.getParcelableExtra<User>("user")
```

当然，为了能够获取启动Activity的返回结果，Activity提供了`startActivityForResult(`
`Intent intent, int requestCode)`来启动Activity，该方法多了一个自定义的请求码参数。

若要实现数据回传，还需要先在当前Activity重写 `onActivityResult(int requestCode,` `int resultCode, Intent intent)` 这个回调方法。当被启动Activity返回结果时，这个方法就会被回调。

Actvity中还提供了一个`setResult(int resultCode, Intent data)`方法用来设置结果码。被启动的Activity需要调用这个方法来设置处理结果。

使用`finish()`可以结束当前的Activity

**示例**：

```kotlin
// 主Activity
class MainActivity : AppCompatActivity() {

    // 定义请求码（用于标识不同的请求）
    private val REQUEST_CODE_SECOND = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val button = findViewById<Button>(R.id.button_launch)
        val textView = findViewById<TextView>(R.id.textView_result)

        button.setOnClickListener {
            // 创建 Intent 启动 SecondActivity
            val intent = Intent(this, SecondActivity::class.java)
            // 可选：传递数据到 SecondActivity
            intent.putExtra("EXTRA_MESSAGE", "Hello from MainActivity!")
            // 启动 Activity 并等待结果
            startActivityForResult(intent, REQUEST_CODE_SECOND)
        }

        // 显示返回的数据
        textView.text = "Received Data: ${intent.getStringExtra("RETURNED_DATA")}"
    }

    // 处理 SecondActivity 返回的结果
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        // 检查请求码和结果码
        if (requestCode == REQUEST_CODE_SECOND && resultCode == Activity.RESULT_OK) {
            data?.let {
                // 从 Intent 中获取返回的数据
                val returnedData = it.getStringExtra("RETURNED_DATA")
                val textView = findViewById<TextView>(R.id.textView_result)
                textView.text = "Received Data: $returnedData"
            }
        }
    }
}
```

```kotlin
// 第二个Activity
class SecondActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_second)

        val editText = findViewById<EditText>(R.id.editText_input)
        val button = findViewById<Button>(R.id.button_return)

        // 接收 MainActivity 传递的数据
        val message = intent.getStringExtra("EXTRA_MESSAGE")
        editText.hint = message

        button.setOnClickListener {
            // 获取用户输入
            val userInput = editText.text.toString()
            // 创建返回数据的 Intent
            val resultIntent = Intent()
            resultIntent.putExtra("RETURNED_DATA", userInput)
            // 设置结果码和返回数据
            setResult(Activity.RESULT_OK, resultIntent)
            // 关闭当前 Activity
            finish()
        }
    }
}
```

#### 4.5. Flag 属性

在 Android 开发中，`Intent` 的 **Flag（标志位）** 是通过 `Intent.setFlags()` 方法设置的，用于控制 Activity 的启动行为、任务栈（Task）的管理以及组件的生命周期。

**常用 Intent Flag 及作用**

1. **`FLAG_ACTIVITY_NEW_TASK`**
	
	将目标 Activity 启动到一个新的任务栈中（Task）
	**使用场景**：
	- 启动一个独立于当前任务栈的 Activity（例如从非 Activity 的 Context 中启动 Activity）
	- 确保目标 Activity 在一个新的任务栈中运行。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
  startActivity(intent)
  ```

2. **`FLAG_ACTIVITY_CLEAR_TOP`**
	如果目标 Activity 已存在于当前任务栈中，则清除其之上的所有 Activity，并复用该实例（调用 `onNewIntent()`），如果目标 Activity 不存在，则直接启动新的实例。
	**使用场景**：
	  - 避免重复创建 Activity 实例（例如从 A → B → C → B，跳转到 B 时清除 C）。
	  - 实现“返回首页”功能。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP
  startActivity(intent)
  ```
3. **`FLAG_ACTIVITY_SINGLE_TOP`**
	如果目标 Activity 是当前任务栈的栈顶，则复用该实例（调用 `onNewIntent()`），否则，创建新的实例。
	**使用场景**：
	  - 类似 `Activity` 的 `launchMode="singleTop"` 行为。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
  startActivity(intent)
  ```

4. **`FLAG_ACTIVITY_NO_HISTORY`**
	启动的 Activity 不会被保留在任务栈中，按返回键会直接跳转到上一个 Activity。
	**使用场景**：
	  - 短暂展示的页面（例如广告页、引导页），不需要用户返回。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_NO_HISTORY
  startActivity(intent)
  ```

5. **`FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS`**
	启动的 Activity 不会出现在最近任务列表（Recent Apps）中。
	**使用场景**：
	  - 避免敏感页面被用户通过多任务界面访问。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS
  startActivity(intent)
  ```

6. **`FLAG_ACTIVITY_BROUGHT_TO_FRONT`**
	如果目标 Activity 已存在于任务栈中，则直接将其带到前台（无需重新创建）。
	**使用场景**：
	  配合 `FLAG_ACTIVITY_CLEAR_TOP` 使用，优化任务栈行为。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT
  startActivity(intent)
  ```


7. **`FLAG_ACTIVITY_REORDER_TO_FRONT`**
	如果目标 Activity 已存在于任务栈中，则将其移动到栈顶（不销毁栈顶之上的 Activity）。
	**使用场景**：
	  - 保持任务栈中已有 Activity 的状态，直接复用。

  ```kotlin
  val intent = Intent(this, TargetActivity::class.java)
  intent.flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
  startActivity(intent)
  ```
