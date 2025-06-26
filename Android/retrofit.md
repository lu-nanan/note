
### **核心概念**

1. **类型安全**：将 HTTP API 转换为 Kotlin/Java 接口
2. **注解驱动**：用注解声明请求参数、方法、路径等
3. **转换器支持**：自动序列化/反序列化数据（如 JSON → Kotlin 对象）
4. **协程友好**：原生支持 Kotlin 协程
### **基础使用步骤**

以如下接口为例，介绍retrofit的基础使用步骤：

```json
api: http://jsonplaceholder.typicode.com/posts/2

返回示例： 
{ 
	"userId": 1,
	"id": 2,
	"title": "qui est esse",
	"body": "est rerum tempore vitae\nsequi sint nihil reprehenderit dolor beatae ea dolores neque\nfugiat blanditiis voluptate porro vel nihil molestiae ut reiciendis\nqui aperiam non debitis possimus qui neque nisi nulla" 
}
```

#### 1.  添加网络权限

在`AndroidManifest.xml`中，添加如下内容
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### **2. 添加依赖**

```gradle
implementation("com.squareup.retrofit2:retrofit:2.9.0")  
implementation("com.squareup.retrofit2:converter-gson:2.9.0")  
implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.6.4")  
implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.5.1")
```

#### **3. 创建数据模型**

```kotlin
data class Article(  
    val id: Int,  
    val userId: Int,  
    val title: String,  
    val body: String  
)
```

#### **4. 定义 API 接口**

```kotlin
interface ApiService {
    @GET("posts/{id}")
    suspend fun getArticle(@Path("id") id: Int): Article
}
```

#### **常用注解**

 **1. 网络请求方法注解（作用于接口方法）**

| 注解名称       | 解释                | 关键特性                             |
| ---------- | ----------------- | -------------------------------- |
| `@GET`     | 发起 **GET 请求**     | 必须提供相对/绝对 URL 参数                 |
| `@POST`    | 发起 **POST 请求**    | 必须提供相对/绝对 URL 参数                 |
| `@PUT`     | 发起 **PUT 请求**     | 必须提供相对/绝对 URL 参数                 |
| `@DELETE`  | 发起 **DELETE 请求**  | 必须提供相对/绝对 URL 参数                 |
| `@HEAD`    | 发起 **HEAD 请求**    | 仅获取响应头信息                         |
| `@OPTIONS` | 发起 **OPTIONS 请求** | 获取服务器支持的请求方法                     |
| `@HTTP`    | **自定义请求方法**       | 需指定 `method`、`path`、`hasBody` 参数 |

**2. 标记类注解（作用于接口方法）**

| 注解名称              | 解释                                                 | 适用场景                            |
| ----------------- | -------------------------------------------------- | ------------------------------- |
| `@FormUrlEncoded` | 请求体为 **表单编码**（`application/x-www-form-urlencoded`） | 配合 `@Field` 或 `@FieldMap` 使用    |
| `@Multipart`      | 请求体为 **多部分表单**（`multipart/form-data`）              | 支持文件上传，需配合 `@Part` 或 `@PartMap` |
| `@Streaming`      | **流式处理响应体**（避免一次性加载到内存）                            | 用于下载大文件，需异步处理响应流                |

**3. 网络请求参数注解（作用于方法参数）**

| 注解名称                              | 解释                                | 适用场景                    | 示例                                                  |
| --------------------------------- | --------------------------------- | ----------------------- | --------------------------------------------------- |
| **URL 控制**                        |                                   |                         |                                                     |
| `@Url`                            | 动态传入完整 URL                        | 覆盖方法注解中的 URL            | `getData(@Url String url)`                          |
| `@Path`                           | 替换 URL 中的 **占位符**（如 `/user/{id}`） | URL 路径动态参数              | `@GET("user/{id}") getUser(@Path("id") int userId)` |
| **请求头控制**                         |                                   |                         |                                                     |
| `@Header`                         | 动态添加单个请求头                         | 每次请求可变化的值               | `@Header("Authorization") String token`             |
| `@Headers`                        | 添加 **固定值请求头**（可声明在方法或类上）          | 静态请求头（如 `Content-Type`） | `@Headers("Cache-Control: max-age=3600")`           |
| **URL 查询参数**                      |                                   |                         |                                                     |
| `@Query`                          | 添加 URL 查询参数（如 `?name=value`）      | GET 请求的显式参数             | `@GET("search") search(@Query("q") String keyword)` |
| `@QueryMap`                       | 动态添加多个查询参数                        | 参数数量不确定时                | `@QueryMap Map<String, String> filters`             |
| **请求体参数**                         |                                   |                         |                                                     |
| `@Body`                           | 直接作为 **完整请求体**（非表单）               | 发送 JSON/XML 等结构化数据      | `@POST("create") createUser(@Body User user)`       |
| **表单字段参数**（需配合 `@FormUrlEncoded`） |                                   |                         |                                                     |
| `@Field`                          | 添加表单字段（键值对）                       | 普通表单提交                  | `@Field("username") String name`                    |
| `@FieldMap`                       | 动态添加多个表单字段                        | 表单字段数量不确定               | `@FieldMap Map<String, String> fields`              |
| **文件上传参数**（需配合 `@Multipart`）      |                                   |                         |                                                     |
| `@Part`                           | 添加多部分表单的单个部分                      | 支持文件/文本                 | `@Part MultipartBody.Part file`                     |
| `@PartMap`                        | 添加多个多部分表单字段                       | 多文件/混合数据上传              | `@PartMap Map<String, RequestBody> parts`           |

1. **`@Path` 编码问题**：  
   默认会对值进行 URL 编码，可用 `encoded = true` 禁用（如 `@Path(value="name", encoded=true)`）。

2. **`@Query` vs `@Field`**：  
   - `@Query`：用于 GET 请求的 URL 参数（`?key=value`）。  
   - `@Field`：用于 POST 表单请求体中的字段（`application/x-www-form-urlencoded`）。

3. **`@Part` 类型**：  
   可接受 `RequestBody`、`MultipartBody.Part` 或对象（配合转换器如 `Gson`）。

4. **`@Streaming` 注意事项**：  
   必须异步处理响应（如 `Call` 结合 `enqueue()`），否则会阻塞主线程。

#### **5. 构建 Retrofit 实例**
```kotlin
object RetrofitClient {  
    private const val BASE_URL = "https://jsonplaceholder.typicode.com/"  
  
    val instance: ApiService by lazy {  
        Retrofit.Builder()  
            .baseUrl(BASE_URL)  
            .addConverterFactory(GsonConverterFactory.create())  
            .build()  
            .create(ApiService::class.java)  
    }  
}
```

#### **6. 发起网络请求**
```kotlin
private fun fetchArticle(articleId: Int) {  
    lifecycleScope.launch {  
        try {  
            val article = RetrofitClient.instance.getArticle(articleId)  
            displayArticle(article)  
        } catch (e: Exception) {  
            Toast.makeText(  
                this@MainActivity,  
                "请求失败: ${e.message}",  
                Toast.LENGTH_SHORT  
            ).show()  
        }  
    }  
}
```

### **高级功能**

#### **1. 自定义转换器**
支持 Moshi、Jackson 等：
```kotlin
.addConverterFactory(MoshiConverterFactory.create())
```

#### **2. 文件上传**
```kotlin
@Multipart
@POST("upload")
suspend fun uploadImage(
    @Part("description") description: RequestBody,
    @Part file: MultipartBody.Part
)

// 调用示例
val filePart = MultipartBody.Part.createFormData(
    "image", 
    "avatar.jpg", 
    File("path").asRequestBody("image/jpeg".toMediaType())
)
apiService.uploadImage("My photo", filePart)
```

#### **3. 动态请求头**
使用 `Interceptor`：
```kotlin
val authInterceptor = Interceptor { chain ->
    val request = chain.request().newBuilder()
        .header("Authorization", "Bearer $token")
        .build()
    chain.proceed(request)
}
```

#### **4. 错误处理**
```kotlin
try {
    val response = apiService.getData()
    if (!response.isSuccessful) {
        val errorBody = response.errorBody()?.string()
        // 解析错误信息
    }
} catch (e: HttpException) {
    // HTTP 状态码错误 (e.code())
} catch (e: IOException) {
    // 网络错误
}
```

### 与其他主流网络库对比分析

以下是 Retrofit2 与 OkHttp、Ktor、Volley、Fuel 的深度对比，突出各自在 Kotlin 环境中的特性：

| 特性             | Retrofit2           | OkHttp      | Ktor Client             | Volley          | Fuel             |
| -------------- | ------------------- | ----------- | ----------------------- | --------------- | ---------------- |
| **核心定位**       | 声明式 REST API 客户端    | 基础 HTTP 客户端 | 全栈 Kotlin 网络框架          | 轻量级 Android 专用库 | Kotlin 专属 HTTP 库 |
| **开发模式**       | 接口注解驱动              | 低层级请求构建     | 协程优先 DSL                | RequestQueue 模式 | 链式调用 DSL         |
| **Kotlin 支持**  | 协程/Suspend 函数一流支持   | 需手动集成协程     | 原生 Kotlin 协程设计          | Java 风格回调       | 纯 Kotlin 扩展设计    |
| **数据转换**       | 多转换器支持(GSON/Moshi等) | 需手动处理       | 内置 JSON 序列化             | 基本 JSON 解析      | 扩展模块支持           |
| **协程支持**       | 原生 suspend 函数       | 需搭配协程工具     | 深度协程集成                  | 无               | 全面协程支持           |
| **Android 优化** | 需手动缓存管理             | 内置响应缓存      | 平台无关                    | 自动内存缓存          | 无特殊优化            |
| **多平台支持**      | JVM/Android         | JVM/Android | **全平台** (JVM/JS/Native) | Android 专属      | JVM/Android      |
