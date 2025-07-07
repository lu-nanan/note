
`intent-filter` 是 Android 中用于 **隐式启动组件**的核心机制。它通过定义组件能响应的 `Intent` 类型（如动作、类别、数据等），帮助系统匹配合适的组件来处理请求。

在 `AndroidManifest.xml` 中，`intent-filter` 通常作为 `<activity>`、`<service>` 或 `<receiver>` 的子元素定义：

```xml
<activity android:name=".DemoActivity">
    <intent-filter>
        <!-- 动作 -->
        <action android:name="com.example.DEMO_ACTION" />
        <!-- 类别 -->
        <category android:name="android.intent.category.DEFAULT" />
        <!-- 数据 -->
        <data android:scheme="http" android:host="example.com" />
    </intent-filter>
</activity>
```

**作用**
- **组件能力声明**：告诉系统该组件能处理哪些类型的 `Intent`。
- **隐式启动支持**：允许其他应用或系统通过隐式 `Intent` 启动该组件。
- **提高应用可发现性**：通过定义标准动作（如拨号、分享），使其他应用更容易调用你的组件。

#### **核心属性详解**

#### **1. Action（动作）**

**作用**：定义组件能处理的动作（如查看、拨号）。

**匹配规则**：
  - `Intent` 中的 `action` 必须与 `intent-filter` 中的某一个 `<action>` 完全匹配
  - 如果 `intent-filter` 没有定义任何 `<action>`，则无法匹配任何 `Intent`
  - 如果 `Intent` 没有指定 `action`，但 `intent-filter` 包含至少一个 `<action>`，则匹配成功

**示例**

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <action android:name="android.intent.action.EDIT" />
</intent-filter>
```

#### **2. Category（类别）**

**作用**：描述动作的上下文环境（如默认、启动器）

**匹配规则**：
  - `Intent` 中的 `category` 必须全部包含在 `intent-filter` 的 `<category>` 列表中。
  - 如果 `intent-filter` 没有定义任何 `<category>`，则仅匹配没有 `category` 的 `Intent`
  
  **特殊规则**：对于 `Activity`，若使用 `startActivity()` 或 `startActivityForResult()`，系统会自动添加 `Intent.CATEGORY_DEFAULT`，因此 `intent-filter` 必须包含该类别才能匹配

**常见类别**
- `android.intent.category.DEFAULT`：默认类别（必须包含）。
- `android.intent.category.LAUNCHER`：启动器（应用入口）。
- `android.intent.category.BROWSABLE`：允许通过浏览器调用。

**示例**

```xml
<intent-filter>
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
</intent-filter>
```

#### **3. Data（数据）**

**作用**：定义组件能处理的数据类型（如 URI、MIME 类型）。

**匹配规则**：
  - `Intent` 的 `data` 必须与 `intent-filter` 中的 `<data>` 匹配。
  - 数据匹配分为 **URI 匹配** 和 **MIME 类型匹配**：
    - **URI 匹配**：通过 `scheme`、`host`、`port`、`path` 等字段定义。
    - **MIME 类型匹配**：通过 `mimeType` 字段定义。

#### **URI 格式**
```
scheme://host:port/path
```
- 示例：`content://com.android.contacts/contacts/1`（联系人数据）。

#### **示例**
```xml
<intent-filter>
    <data android:scheme="http" android:host="example.com" />
    <data android:mimeType="image/*" />
</intent-filter>
```

| 匹配项          | 规则说明                                                                |
| ------------ | ------------------------------------------------------------------- |
| **Action**   | `Intent` 的 `action` 必须与 `intent-filter` 中的某一个 `<action>` 匹配。        |
| **Category** | `Intent` 的所有 `category` 必须包含在 `intent-filter` 的 `<category>` 列表中。   |
| **Data**     | `Intent` 的 `data` 必须与 `intent-filter` 的 `<data>` 匹配（URI 和 MIME 类型）。 |
### **应用场景**

1. **设置启动页面**

```xml
<intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
</intent-filter>
```

- **作用**：标记该 `Activity` 为应用的主入口。

2. **处理文件或数据**

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:scheme="file" />
    <data android:mimeType="audio/*" />
</intent-filter>
```

- **作用**：允许其他应用通过文件或音频数据启动该组件。

3. **跨应用跳转**

```xml
<intent-filter>
    <action android:name="com.example.OTHER_APP_ACTION" />
    <category android:name="android.intent.category.DEFAULT" />
</intent-filter>
```

- **代码调用**：

```kotlin
  val intent = Intent().apply {
      action = "com.example.OTHER_APP_ACTION"
  }
  startActivity(intent)
```
