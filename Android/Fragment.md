---
tags:
  - Android
  - Fragment
---
在 Android 开发中，**Fragment（碎片）** 是一个重要的组件，用于构建灵活、模块化的用户界面。

Fragment 是 Android 3.0（API 11）引入的组件，可以视为 **Activity 的一部分模块化 UI**。它拥有自己的生命周期、布局和行为，并可以动态地嵌入到 Activity 中。
   
  **设计目的**  
   - **适应不同屏幕尺寸**：在平板等大屏设备上，Fragment 可以并排显示多个模块（如左侧导航 + 右侧详情），而在手机等小屏设备上，Fragment 可以通过切换实现动态布局。
   - **模块化与复用**：Fragment 可以被多个 Activity 复用，减少代码冗余。
   - **动态 UI 管理**：通过 FragmentTransaction 实现 Fragment 的添加、替换、移除等操作，提升用户体验。

**核心特点**
1. **生命周期管理**  
   Fragment 有自己的生命周期回调方法（如 `onCreateView()`、`onPause()` 等），但其生命周期由宿主 Activity 控制。例如：
   - 当 Activity 被销毁时，关联的 Fragment 也会被销毁。
   - 当 Fragment 被动态添加到 Activity 中时，其生命周期会与 Activity 同步。

2. **动态性与灵活性**  
   - **静态添加**：通过 XML 布局文件直接声明 Fragment。
   - **动态添加**：通过 `FragmentManager` 和 `FragmentTransaction` 在运行时动态管理 Fragment。

3. **独立性与依赖性**  
   - Fragment 可以独立管理自己的布局和逻辑。
   - 但必须依赖于宿主 Activity 存在（不能独立运行）。

4. **多 Fragment 协同**  
   - 一个 Activity 可以包含多个 Fragment，支持复杂的 UI 交互（如新闻应用的列表 + 详情布局）

### 一、生命周期

Fragment 的生命周期与宿主 Activity 紧密关联，但拥有独立的回调方法，用于管理 Fragment 的创建、显示、交互、销毁等过程

![[Fragment_生命周期.png]]
#### 1.1. **关联阶段**

在该阶段，Fragment**与宿主 Activity 建立联系**，是 Fragment 生命周期的起点

**`onAttach(Context context)`**  
  - **作用**：Fragment 与宿主 Activity 建立关联。  
  - **使用场景**：  
    - 获取宿主 Activity 的上下文（`context`）。  
    - 初始化 Fragment 与 Activity 的通信接口（如定义回调接口）。  
  - **注意**：此方法在 Fragment 和 Activity 绑定后调用，是 Fragment 生命周期的起点。

#### 1.2. **视图创建阶段**

在该阶段，Fragment完成 **UI 布局加载**的相关内容

**`onCreate(Bundle savedInstanceState)`**  
  - **作用**：初始化非 UI 相关的数据（如加载数据、初始化变量）。  
  - **使用场景**：  
    - 恢复通过 `onSaveInstanceState` 保存的状态数据。  
    - 启动后台线程或服务（如网络请求）。  

**`onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)`**  
  - **作用**：加载 Fragment 的布局文件并返回根视图（`View`）。  
  - **使用场景**：  
    - 使用 `LayoutInflater` 将 XML 布局文件转换为 `View` 对象。  
    - **注意**：此阶段**不应直接操作 UI 组件**（如 `findViewById`），因为视图尚未完全初始化。  

**`onViewCreated(View view, Bundle savedInstanceState)`**  
  - **作用**：视图创建完成后调用，适合进行 UI 初始化操作。  
  - **使用场景**：  
    - 绑定控件（如 `TextView`、`Button`）。  
    - 设置监听器（如点击事件）。  
    - 请求数据并更新 UI（如调用 API 后刷新列表）。  
 
**`onActivityCreated(Bundle savedInstanceState)`**  
  - **作用**：宿主 Activity 的 `onCreate()` 完成后调用。  
  - **使用场景**：  
    - 此时可以安全访问宿主 Activity 的资源（如其他 Fragment 或数据）。  
    - **注意**：在 AndroidX 中，此方法已被弃用，建议在 `onViewCreated()` 中处理相关逻辑。

#### **1.3. 活跃阶段**

在该阶段，Fragment变得**用户可见并可交互**

**`onStart()`**  
  - **作用**：Fragment 变为可见状态（但未获取焦点）。  
  - **使用场景**：  
    - 启动动画或注册广播接收器。  
    - 更新 UI 状态（如根据用户偏好调整界面）。  

**`onResume()`**  
  - **作用**：Fragment 进入活动状态，用户可与之交互。  
  - **使用场景**：  
    - 启动传感器监听（如陀螺仪、加速度计）。  
    - 开始播放视频或音频。  
    - 注册生命周期感知的组件（如 `LiveData`）。

#### **1.4. 暂停/停止阶段**

Fragment 不再活跃，并最终完全不可见

**`onPause()`**  
  - **作用**：Fragment 失去焦点但仍部分可见（如弹窗覆盖）。  
  - **使用场景**：  
    - 暂停耗时操作（如保存表单数据）。  
    - 释放摄像头或麦克风资源。  

**`onStop()`**  
  - **作用**：Fragment 完全不可见。  
  - **使用场景**：  
    - 停止网络请求或动画。  
    - 释放非 UI 资源（如取消线程池任务）。  

#### **1.5. 销毁阶段**

Fragment的视图被移除，同时销毁相关资源，与宿主Activity解除关联

**`onDestroyView()`**  
  - **作用**：Fragment 的视图被移除（但 Fragment 实例仍存在）。  
  - **使用场景**：  
    - 清除视图相关引用（如置空 `RecyclerView` 适配器）。  
    - 防止内存泄漏（如解除事件监听器绑定）。  

**`onDestroy()`**  
  - **作用**：销毁非视图资源（如数据库连接、线程池）。  
  - **使用场景**：  
    - 释放后台服务或资源。  
    - 清理数据缓存。  

**`onDetach()`**  
  - **作用**：Fragment 与宿主 Activity 解除关联。  
  - **使用场景**：  
    - 置空 Activity 引用（如接口监听器）。  
    - 最终清理资源，确保无残留引用。

| **Activity 生命周期** | **Fragment 对应方法**                                                  |
| ----------------- | ------------------------------------------------------------------ |
| `onCreate()`      | `onAttach()` → `onCreate()` → `onCreateView()` → `onViewCreated()` |
| `onStart()`       | `onStart()`                                                        |
| `onResume()`      | `onResume()`                                                       |
| `onPause()`       | `onPause()`                                                        |
| `onStop()`        | `onStop()`                                                         |
| `onDestroy()`     | `onDestroyView()` → `onDestroy()` → `onDetach()`                   |

#### 1.6. 应用

**1. 状态保存与恢复**
- **保存状态**：在 `onSaveInstanceState(Bundle outState)` 中保存关键数据（如用户输入内容）。  
  ```kotlin
  override fun onSaveInstanceState(outState: Bundle) {
      super.onSaveInstanceState(outState)
      outState.putString("key", "保存的数据")
  }
  ```
- **恢复状态**：在 `onCreate()` 或 `onCreateView()` 中通过 `savedInstanceState` 恢复数据。

**2. 动态 Fragment 事务管理**
- **添加/替换 Fragment**：  
  ```kotlin
  val transaction = fragmentManager.beginTransaction()
  transaction.replace(R.id.fragment_container, fragment)
  transaction.addToBackStack(null) // 添加到回退栈
  transaction.commit()
  ```
- **回退栈**：调用 `addToBackStack(null)` 后，按返回键可回退到上一个 Fragment 状态。

**3. 避免内存泄漏**
- 在 `onDestroyView()` 中释放视图相关资源（如解绑 `LiveData`）
- 不要在 Fragment 中持有宿主 Activity 的强引用（在 `onDetach()` 中置空）

```kotlin
override fun onDestroyView() {
    super.onDestroyView()
    // 释放非必要资源（如取消网络请求、清理缓存）
    imageView.setImageResource(0)
    adapter.clear()
}
```

**4. 懒加载（Lazy Loading）**

**场景**：在 Fragment 可见时才加载数据（如网络请求），避免资源浪费

```kotlin
class LazyLoadFragment : Fragment() {
    private var isLoaded = false

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        // 延迟加载：在 onViewCreated 中触发数据加载
        if (!isLoaded) {
            loadData()
            isLoaded = true
        }
    }

    private fun loadData() {
        // 模拟网络请求
        lifecycleScope.launch {
            delay(1000)
            // 更新 UI
            view?.findViewById<TextView>(R.id.text_view)?.text = "数据加载完成"
        }
    }

    // 可见性判断
    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        super.setUserVisibleHint(isVisibleToUser)
        if (isVisibleToUser && isResumed && !isLoaded) {
            loadData()
            isLoaded = true
        }
    }
}
```



**6. 与 Activity 通信** ：SharedViewModel

**定义 SharedViewModel**：

```kotlin
class SharedViewModel : ViewModel() {
    private val _data = MutableLiveData<String>()
    val data: LiveData<String> get() = _data

    fun updateData(newData: String) {
        _data.value = newData
    }
}
```

**Fragment 和 Activity 共享数据**：
```kotlin
// 在 Fragment 中
val viewModel = activity?.run {
    ViewModelProvider(this)[SharedViewModel::class.java]
}
viewModel?.data?.observe(viewLifecycleOwner) {
    textView.text = it
}

// 在 Activity 中
viewModel?.updateData("Hello from Activity!")
```

| **回调方法**              | **作用**                                                      |
| --------------------- | ----------------------------------------------------------- |
| `onAttach()`          | Fragment 与 Activity 关联时调用。                                  |
| `onCreate()`          | 初始化 Fragment，通常用于设置参数（`setArguments()`）。                    |
| `onCreateView()`      | 加载 Fragment 的布局文件（`inflate`），返回视图对象。                        |
| `onActivityCreated()` | Activity 的 `onCreate()` 执行完毕后调用，Fragment 可以访问 Activity 的资源。 |
| `onStart()`           | Fragment 变为可见状态。                                            |
| `onResume()`          | Fragment 准备好与用户交互。                                          |
| `onPause()`           | 用户离开 Fragment（但仍可见）。                                        |
| `onStop()`            | Fragment 不再可见。                                              |
| `onDestroyView()`     | Fragment 的视图被移除时调用（但 Fragment 仍存在）。                         |
| `onDestroy()`         | Fragment 被销毁前调用。                                            |
| `onDetach()`          | Fragment 与 Activity 解除关联。                                   |

### 二、基本使用

#### 1.1. 创建Fragment

**创建 Fragment**：编写xml布局文件，同时继承Fragment类，实现相关方法

```kotlin
class MyFragment : Fragment() {

    private var _binding: FragmentMyBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater,
        container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentMyBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        
        // 初始化UI和逻辑
        binding.button.setOnClickListener {
            // 处理点击事件
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null // 防止内存泄漏
    }
}
```

#### 1.2. 页面切换

**静态添加** (XML布局)：在 Activity 布局文件中直接声明

```xml
<fragment
    android:id="@+id/my_fragment"
    android:name="com.example.MyFragment"
    android:layout_width="match_parent"
    android:layout_height="match_parent"/>
```

**动态添加/替换** 
```kotlin
// 获取 FragmentManager
val fragmentManager = supportFragmentManager

// 开启事务
val transaction = fragmentManager.beginTransaction()

// 替换 Fragment
transaction.replace(R.id.fragment_container, AnotherFragment())

// 提交事务
transaction.commit()
```

当然，处理上述 `replace` ，还可以使用下面的方法替换/切换Fragment：
- **`add()`**：添加新 Fragment（不替换现有 Fragment）
- **`remove()`**：移除 Fragment
- **`show()`/`hide()`**：显示/隐藏 Fragment（保留状态）
- **`addToBackStack()`**：将操作加入返回栈，允许用户按返回键返回

**页面切换优化**：使用 `add()` + `hide()`/`show()` 替代 `replace()`，避免重复创建 Fragment 实例

```kotlin
// 在 Activity 中切换 Fragment
val fragment1 = Fragment1()
val fragment2 = Fragment2()

val transaction = supportFragmentManager.beginTransaction()
transaction.add(R.id.fragment_container, fragment1, "fragment1")
transaction.add(R.id.fragment_container, fragment2, "fragment2")
transaction.hide(fragment2) // 默认显示 fragment1
transaction.commit()

// 切换到 fragment2
val transaction = supportFragmentManager.beginTransaction()
transaction.hide(fragment1)
transaction.show(fragment2)
transaction.commit()
```

除此之外还可以使用Navigation组件或ViewPager2（[[布局与控件#七、ViewPager2]]）实现Fragment的管理及切换


### 三、 参数传递

#### 3.1. Bundle 参数

通过 `setArguments()` 在 Fragment 初始化时传递数据，或在后续通过方法更新

适合初始数据传递，但无法实时通信

```kotlin
// Activity中
// 创建Bundle对象 
// 作用:存储数据，并传递到Fragment中 
bundle : Bundel = new Bundle()

// 往bundle中添加数据 
bundle.putString("message", "I love Google")

// 把数据设置到Fragment中 
fragment.setArguments(bundle)

// 在 Fragment 中获取参数
// 通过getArgments()获取从Activity传过来的全部值 
bundle = this.getArguments()

// 获取某一值 
message = bundle.getString("message")
```

#### 3.2. 接口回调

在 Fragment 中定义接口，Activity 实现该接口。

Fragment 通过 `onAttach()` 获取 Activity 的接口实例并调用方法。

```kotlin
// 定义回调接口
interface OnItemSelectedListener {
    fun onItemSelected(item: Item)
}

// 宿主 Activity 实现接口
class MainActivity : AppCompatActivity(), OnItemSelectedListener {
    override fun onItemSelected(item: Item) {
        // 处理选择事件
    }
}

// Fragment 中触发回调
class ListFragment : Fragment() {
    private var listener: OnItemSelectedListener? = null
    
    override fun onAttach(context: Context) {
        super.onAttach(context)
        listener = context as? OnItemSelectedListener
    }
    
    private fun selectItem(item: Item) {
        listener?.onItemSelected(item)
    }
}
```

### 四、通信
#### **4.1. 通信原则**

**独立性**：Fragment 应设计为独立组件，避免直接与其他 Fragment 或 Activity 通信。

**推荐方案**：
  - **共享持久性数据** → 使用 `ViewModel`
  - **一次性结果传递** → 使用 `Fragment Result API`
#### **4.2. ViewModel**

**1. 与宿主 Activity 共享数据**

**场景**：Fragment 与 Activity 需共享数据（如点击事件触发全局操作）。

```kotlin
// ViewModel
class ItemViewModel : ViewModel() {
    private val mutableSelectedItem = MutableLiveData<Item>()
    val selectedItem: LiveData<Item> get() = mutableSelectedItem

    fun selectItem(item: Item) {
        mutableSelectedItem.value = item
    }
}

class MainActivity : AppCompatActivity() {
    // Using the viewModels() Kotlin property delegate from the activity-ktx
    // artifact to retrieve the ViewModel in the activity scope.
    private val viewModel: ItemViewModel by viewModels()
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewModel.selectedItem.observe(this, Observer { item ->
            // Perform an action with the latest item data.
        })
    }
}

class ListFragment : Fragment() {
    // Using the activityViewModels() Kotlin property delegate from the
    // fragment-ktx artifact to retrieve the ViewModel in the activity scope.
    private val viewModel: ItemViewModel by activityViewModels()

    // Called when the item is clicked.
    fun onItemClicked(item: Item) {
        // Set a new item.
        viewModel.selectItem(item)
    }
}
```

**2. 在 Fragment 之间共享数据**

**场景**：两个 Fragment 需通过 Activity 范围共享数据（如列表过滤器与列表展示）。

```kotlin
// ViewModel
class ListViewModel : ViewModel() {
    val filters = MutableLiveData<Set<Filter>>()
    fun addFilter(filter: Filter) { ... }
    fun removeFilter(filter: Filter) { ... }
}

// 列表 Fragment
class ListFragment : Fragment() {
    private val viewModel: ListViewModel by activityViewModels()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewModel.filteredList.observe(viewLifecycleOwner, Observer { list ->
            // 更新列表 UI
        })
    }
}

// 过滤器 Fragment
class FilterFragment : Fragment() {
    private val viewModel: ListViewModel by activityViewModels()
    fun onFilterSelected(filter: Filter) = viewModel.addFilter(filter)
}
```

**3. 父 Fragment 与子 Fragment 通信**

**场景**：父 Fragment 与嵌套的子 Fragment 共享数据。

```kotlin
// 父 Fragment
class ParentFragment : Fragment() {
    private val viewModel: ListViewModel by viewModels()
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        viewModel.filteredList.observe(viewLifecycleOwner, Observer { list ->
            // 更新父 Fragment 界面
        })
    }
}

// 子 Fragment
class ChildFragment : Fragment() {
    private val viewModel: ListViewModel by viewModels({ requireParentFragment() })
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        // 使用父 Fragment 的 ViewModel
    }
}
```

#### 4.3. Fragmen Result API

**1. Fragment 之间传递一次性结果**
- `setFragmentResultListener()`：监听结果。
- `setFragmentResult()`：发送结果。

结果存储在 `FragmentManager` 中，直到监听器被触发。

**场景**：Fragment B 向 Fragment A 返回结果（如扫码后返回数据）。

```kotlin
// Fragment A（接收方）
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setFragmentResultListener("requestKey") { requestKey, bundle ->
        val result = bundle.getString("bundleKey")
        // 处理结果
    }
}

// Fragment B（发送方）
button.setOnClickListener {
    val result = "result"
    setFragmentResult("requestKey", bundleOf("bundleKey" to result))
}
```

**2. 父子 Fragment 之间传递结果**

父 Fragment 接收子 Fragment 的结果：

```kotlin
class ParentFragment : Fragment() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 使用 childFragmentManager 监听子 Fragment 的结果
        childFragmentManager.setFragmentResultListener("requestKey") { _, bundle ->
            val result = bundle.getString("bundleKey")
            // 处理结果
        }
    }
}
```

子 Fragment 发送结果

```kotlin
class ChildFragment : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        view.findViewById<Button>(R.id.button).setOnClickListener {
            val result = "result"
            // 使用 setFragmentResult 发送结果到父 Fragment
            setFragmentResult("requestKey", bundleOf("bundleKey" to result))
        }
    }
}
```


**3. 宿主 Activity 接收 Fragment 的结果**

Activity 监听 Fragment 的结果

```kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 使用 supportFragmentManager 监听 Fragment 的结果
        supportFragmentManager.setFragmentResultListener("requestKey", this) { _, bundle ->
            val result = bundle.getString("bundleKey")
            // 处理结果
        }
    }
}
```

Fragment 发送结果给 Activity

```kotlin
class FragmentB : Fragment() {
    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        view.findViewById<Button>(R.id.button).setOnClickListener {
            val result = "result"
            // 发送结果到 Activity
            setFragmentResult("requestKey", bundleOf("bundleKey" to result))
        }
    }
}
```


