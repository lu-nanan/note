### 一、MVC


MVC 是一种经典的设计模式，将应用程序分为三个主要部分：模型（Model）、视图（View）和控制器（Controller）。这种模式的目的是将业务逻辑与用户界面分离，从而提高代码的可维护性。

**组成部分**
- **Model（模型）** ：负责应用程序的数据和业务逻辑。它直接与数据库或其他数据源交互，处理数据的获取、存储和更新。
- **View（视图）** ：负责显示数据（模型）并向用户呈现界面。视图通常是 XML 布局文件和 Activity/Fragment。
- **Controller（控制器）** ：充当模型和视图之间的中介。它接收用户输入（如点击事件），更新模型，并通知视图更新。

```java
// Activity中典型代码
button.setOnClickListener(v -> {
    controller.fetchData(param, new Callback(){
        void onSuccess(Data data){
            textView.setText(data.text); // View直接操作
        }
    });
});
```

该设计模式结构简单直观，在小型项目当中非常高效，但是一旦项目越来越大便会导致很多问题：
- Controller膨胀臃肿，难以测试和维护
- view直接持有controller和model实例，不同职责的代码进行耦合，导致代码耦合性高，模块分工不清晰

### 二、MVP

MVP 是对 MVC 的一种改进，旨在进一步解耦视图和业务逻辑。它将控制器的职责分散到 Presenter 中，使得视图更加简单。

**组成部分**
- **Model（模型）** ：与 MVC 中的模型相同，负责数据和业务逻辑。
- **View（视图）** ：负责显示数据并处理用户输入。视图通常是 Activity/Fragment，但它只负责 UI 相关的工作。
- **Presenter（演示者）** ：充当视图和模型之间的中介。它处理用户输入，更新模型，并更新视图。Presenter 不直接引用视图，而是通过接口与视图交互。

**关键特性** 
- **接口通信**：View 和 Presenter 通过接口进行交互，确保解耦。
- **单向依赖**：View 依赖于 Presenter，Presenter 依赖于 View 接口和 Model，但 View 不依赖于 Presenter 的具体实现。 
- **可测试性**：Presenter 可以在不依赖 Android 框架的情况下进行单元测试。 
 
**MVP的流程** 
1. **View** 接收用户操作（如按钮点击）
2. **View** 调用 **Presenter** 的方法，传递用户操作参数
3. **Presenter** 处理业务逻辑，调用 **Model** 获取或修改数据
4. **Model** 完成数据操作后，**Presenter** 更新 **View**。

**示例**

**Model**：负责数据逻辑，如用户信息和登录验证

```kotlin
// UserModel.kt

// 表示用户信息的数据类
data class User(val username: String, val password: String)

// 用户模型，用以模拟网络请求实现登录验证
class UserModel {
    fun login(user: User): Boolean {
        return user.username == "admin" && user.password == "password"
    }
}
```

**View Interface**：定义了两个方法 `showLoginSuccess` 和 `showLoginError`，用于更新 UI

```kotlin
// LoginView.kt
interface LoginView {
    fun showLoginSuccess()
    fun showLoginError()
}
```

**Presenter**：接受 View 层和 Model 层的实例（ `LoginView` 和 `UserModel` ），通过 `login` 方法处理登录逻辑，同时根据 `UserModel` 的登录结果，调用对应的 View 方法来更新界面

```kotlin
// LoginPresenter.kt
class LoginPresenter(private val view: LoginView, private val model: UserModel) {
    fun login(username: String, password: String) {
        val user = User(username, password)
        if (model.login(user)) {
            view.showLoginSuccess()
        } else {
            view.showLoginError()
        }
    }
}
```

**Activity**：实现了 `LoginView` 接口，并在 `onCreate` 方法中初始化 `LoginPresenter`

当用户点击登录按钮时，调用 `presenter.login` 方法，传递用户输入的用户名和密码，同时根据 Presenter 的回调，显示登录成功或失败的提示信

```kotlin
// LoginActivity.kt
class LoginActivity : AppCompatActivity(), LoginView {
    private lateinit var presenter: LoginPresenter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        val userModel = UserModel()
        presenter = LoginPresenter(this, userModel)

        val usernameEditText: EditText = findViewById(R.id.username)
        val passwordEditText: EditText = findViewById(R.id.password)
        val loginButton: Button = findViewById(R.id.login_button)

        loginButton.setOnClickListener {
            presenter.login(usernameEditText.text.toString(), passwordEditText.text.toString())
        }
    }

    override fun showLoginSuccess() {
        Toast.makeText(this, "Login Successful", Toast.LENGTH_SHORT).show()
    }

    override fun showLoginError() {
        Toast.makeText(this, "Login Failed", Toast.LENGTH_SHORT).show()
    }
}
```

在这个例子中，`User Model` 负责处理用户数据和登录逻辑，`LoginPresenter` 处理用户输入并更新视图。`LoginActivity` 实现了 `LoginView` 接口，负责显示用户界面

该架构方法通过视图和业务逻辑的分离，使得单元测试变得更加容易，同时，Presenter 可以更好地管理视图的状态，减少视图的复杂性。

但是，该方法需要定义额外的接口，增加了代码的复杂性。在处理复杂的业务逻辑时，Presenter 可能会变得庞大

### 三、MVVM

MVVM 是一种现代的架构模式，特别适用于数据绑定和响应式编程。它通过 ViewModel 来管理 UI 相关的数据和状态。

**组成部分**
- **Model（模型）** ：与 MVC 和 MVP 中的模型相同，负责数据和业务逻辑。
- **View（视图）** ：负责显示 UI，通常是 Activity/Fragment。视图通过数据绑定与 ViewModel 进行交互。
- **ViewModel（视图模型）** ：负责准备和管理 UI 所需的数据。它将模型的数据转换为视图可以使用的格式，并处理与视图的交互。ViewModel 通常使用 LiveData 或其他观察者模式来通知视图更新。

该设计模式的关键便在于 viewModel ，viewModel通过将数据和 view 进行绑定，修改数据会直接反映到 view 上，通过**数据驱动型思想**，彻底把 MVP 中的 Presenter 的 UI 操作逻辑给去掉了。而 viewModel 是绑定于单独的 view 的，也就不需要进行编写接口了。

这样 View 只需要关注 Viewmodel 的数据部分，而无需知道数据是怎么来的；而 ViewModel 只需要关注数据逻辑，而不需要知道UI是如何实现的。View 可以随意更换UI实现，但 ViewModel 却完全不需要改变。

但是，这样的处理也使得我们必须要有一个 view-data 绑定框架，来实现对 data 的更改可以实时反映到 view 上

为此，google 推出了如下的适合 android 开发的框架。
![[android 设计模式_Jetpack组件生态.png]]
各个部分的阐释如下所示：
- View对应的就是Activity和Fragment，在这里进行UI操作。
- ViewModel中包含了LiveData，这是一种可观察数据类型框架。View通过向LIveData注册观察者，当LiveData发生改变时，就会直接调用观察者的逻辑把数据更新到view上。
- ViewModel完全不需要关心UI操作，只需要专注于数据与业务操作。
- Repository代表了Model层，Repository对ViewModel进行了减压，把业务操作般到了Repository中，避免了viewModel臃肿。
- Repository对请求进行判断是要到本地数据库获取还是网络请求获取分别调用不同的模块。


**示例**

**Model**：负责获取天气数据，模拟网络请求

```kotlin
// WeatherModel.kt
data class WeatherData(val temperature: Int, val condition: String)

class WeatherModel {
    fun fetchWeather(): WeatherData {
        // 模拟网络请求
        return WeatherData(25, "Sunny")
    }
}
```

**Repository**：作为数据的单一来源，负责从 Model 获取数据，可能包括缓存逻辑、数据转换等

```kotlin
// WeatherRepository.kt
class WeatherRepository(private val model: WeatherModel) {
    fun getWeather(): WeatherData {
        return model.fetchWeather()
    }
}
```

**ViewModel**：持有 `WeatherRepository` 的引用，通过 `LiveData` 发布天气数据。

```kotlin
// WeatherViewModel.kt
class WeatherViewModel : ViewModel() {
    private val repository = WeatherRepository(WeatherModel())

    private val _weather = MutableLiveData<WeatherData>()
    val weather: LiveData<WeatherData> get() = _weather

    fun loadWeather() {
        viewModelScope.launch {
            val data = repository.getWeather()
            _weather.value = data
        }
    }
}
```

**Activity**：初始化 DataBinding，绑定 ViewModel，并设置 `lifecycleOwner` 以确保 LiveData 能正确感知生命周期状态，同时通过 `Observer` 观察 `weather` LiveData，进行额外的 UI 操作（如需要）

```kotlin
// WeatherActivity.kt
class WeatherActivity : AppCompatActivity() {
    private lateinit var binding: ActivityWeatherBinding
    private val viewModel: WeatherViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 初始化 DataBinding
        binding = DataBindingUtil.setContentView(this, R.layout.activity_weather)
        binding.viewModel = viewModel
        binding.lifecycleOwner = this

        // 观察 LiveData
        viewModel.weather.observe(this, Observer { weather ->
            // UI 自动更新通过 DataBinding
            // 可在这里添加额外逻辑，如显示 Toast 或更新其他视图
        })

        // 初始加载
        viewModel.loadWeather()
    }
}
```
