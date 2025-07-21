---
tags:
  - Android
  - Android动画
---
### 一、补间动画

“补间”（Tween）一词源于“in between”，意为“在两者之间”。在动画领域，补间动画指的是你**定义动画的起始状态和结束状态**，然后由系统**自动计算并生成中间过渡帧**的动画技术。

在 Android 中，补间动画**作用于 View 对象**。它允许你对一个视图执行一系列简单的变换操作，例如：

*   **移动（Translate）**： 将视图从一个位置移动到另一个位置。
*   **缩放（Scale）**： 放大或缩小视图。
*   **旋转（Rotate）**： 围绕一个点旋转视图。
*   **透明度变化（Alpha）**： 改变视图的透明度（淡入淡出）。

补间动画**只改变视图绘制的位置和外观，并不会实际改变视图本身的属性（如 `left`, `top`, `getX()`, `getY()`, `scaleX`, `rotation` 等）**

视图在动画结束后的“逻辑位置”仍然是动画开始前的位置。这有时会导致点击事件区域不匹配的问题（视图绘制在别处，但点击响应还在原处）

#### 1.1. 核心组件

**`Animation` 类及其子类：**
- **`TranslateAnimation`**: 实现移动动画。需要指定起始和结束的 X/Y 坐标偏移量（绝对像素值或相对于自身/父容器的百分比）。
*   **`ScaleAnimation`**: 实现缩放动画。需要指定起始和结束的 X/Y 轴缩放比例、缩放中心点（pivotX, pivotY）。缩放比例 1.0 表示原始大小。
*   **`RotateAnimation`**: 实现旋转动画。需要指定起始和结束角度、旋转中心点（pivotX, pivotY）。
*   **`AlphaAnimation`**: 实现透明度动画。需要指定起始和结束的透明度值（0.0 完全透明 - 1.0 完全不透明）。
*   **`AnimationSet`**: 用于将多个 `Animation` 对象组合起来，形成一个复杂的动画序列（可以设置它们是同时播放还是顺序播放）

**动画属性（通过 `Animation` 类或其子类设置）：**
*   **Duration (`setDuration(long)`)**： 动画持续的时间（毫秒）。
*   **Interpolator (`setInterpolator(Interpolator)`)**： **插值器**，定义了**动画变化的速率**（速度曲线）。系统默认提供了一些常用的插值器：
	*   `LinearInterpolator`: 匀速变化。
    *   `AccelerateInterpolator`: 开始时慢，然后加速。
    *   `DecelerateInterpolator`: 开始时快，然后减速。
    *   `AccelerateDecelerateInterpolator`: 开始和结束慢，中间加速（默认）。
    *   `BounceInterpolator`: 结束时弹跳效果。
    *   `AnticipateInterpolator`: 开始时先向后一小段再前进。
    *   `OvershootInterpolator`: 结束时超过目标值一点再回来。
    *   `CycleInterpolator`: 动画重复指定次数，按正弦曲线变化。
    *   `PathInterpolator`: 通过贝塞尔曲线自定义速度路径。
*   **Repeat Count/Mode (`setRepeatCount(int)`, `setRepeatMode(int)`)**：
    *   `count`: 重复次数。`Animation.INFINITE` 表示无限重复。
    *   `mode`: `Animation.RESTART` (默认，从头开始重复) 或 `Animation.REVERSE` (倒着重复)。
*   **Fill After (`setFillAfter(boolean)`)**： 设置为 `true` 时，动画结束后，视图保持动画结束时的状态（绘制层面）。
	**注意：这并不会改变视图的实际属性值！**
*   **Fill Before (`setFillBefore(boolean)`)**： 设置为 `true` 时（默认），动画开始前，视图应用动画的第一帧状态（通常就是起始状态）
*   **Start Offset (`setStartOffset(long)`)**： 动画开始前的延迟时间（毫秒）
*   **Start Time (`setStartTime(long)`)**： 设置动画的绝对开始时间（较少直接使用，通常用 `start()` 或 `startNow()`）
*   **Z Order Adjustment (`setZAdjustment(int)`)**： 控制动画运行期间视图在 Z 轴（深度）上的顺序（`Animation.ZORDER_NORMAL`, `ZORDER_TOP`, `ZORDER_BOTTOM`）

**`AnimationListener` 接口：** 用于监听动画的关键事件：
*   `onAnimationStart(Animation animation)`: 动画开始时调用
*   `onAnimationEnd(Animation animation)`: 动画正常结束时调用
*   `onAnimationRepeat(Animation animation)`: 动画重复播放时调用

#### 1.2. 动画创建

##### 1.2.1. **XML 资源定义**

1.  **创建动画资源文件：** 在 `res/anim/` 目录下创建 XML 文件
2.  **编写动画定义：** 使用 `<set>`, `<alpha>`, `<scale>`, `<translate>`, `<rotate>` 标签及其属性。
3.  **加载动画：** 在 Java/Kotlin 代码中使用 `AnimationUtils.loadAnimation(Context context, int resId)` 加载动画资源。
4.  **启动动画：** 在目标 View 上调用 `view.startAnimation(animation)`。

**示例 :**

```xml
<?xml version="1.0" encoding="utf-8"?>
<set xmlns:android="http://schemas.android.com/apk/res/android"
    android:shareInterpolator="true"> <!-- 是否共享插值器给子动画 -->
    <translate
        android:fromXDelta="-100%p" <!-- 从父容器左侧边界外开始 (自身宽度100%的负值) -->
        android:toXDelta="0%p"      <!-- 移动到原始位置 -->
        android:duration="500"/>     <!-- 持续500毫秒 -->
    <alpha
        android:fromAlpha="0.0"     <!-- 完全透明开始 -->
        android:toAlpha="1.0"       <!-- 完全不透明结束 -->
        android:duration="300"/>    <!-- 持续300毫秒 (可以与translate不同) -->
</set>
```

**在代码中使用：**

```kotlin
val slideInLeft = AnimationUtils.loadAnimation(this, R.anim.slide_in_left)
myView.startAnimation(slideInLeft)
// 或者设置监听器
slideInLeft.setAnimationListener(object : Animation.AnimationListener {
    override fun onAnimationStart(animation: Animation?) {}
    override fun onAnimationEnd(animation: Animation?) {
        // 动画结束后的逻辑，注意视图属性未变！
    }
    override fun onAnimationRepeat(animation: Animation?) {}
})
```

##### 1.2.2. 代码动态创建

直接在 Java/Kotlin 代码中实例化 `Animation` 子类对象，设置属性。

**示例 (Kotlin):**

```kotlin
// 创建一个组合动画
val animationSet = AnimationSet(true) // true 表示共享插值器

// 创建并添加一个平移动画 (从当前位置向右移动200像素)
val translateAnim = TranslateAnimation(0f, 200f, 0f, 0f)
translateAnim.duration = 1000 // 1秒
animationSet.addAnimation(translateAnim)

// 创建并添加一个旋转动画 (绕自身中心点旋转360度)
val rotateAnim = RotateAnimation(0f, 360f, Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f)
rotateAnim.duration = 1000
animationSet.addAnimation(rotateAnim)

// 设置插值器 (加速减速)
animationSet.interpolator = AccelerateDecelerateInterpolator()

// 启动动画
myView.startAnimation(animationSet)
```


### 二、逐帧动画

逐帧动画（Frame Animation/Drawable Animation）是一种传统的动画技术，通过快速连续地显示一系列静态图片（帧）来创建动画效果。就像翻书动画一样，每一页都是静态图片，但快速翻动时就形成了动画

在Android中，逐帧动画使用`AnimationDrawable`类实现

**逐帧动画 vs 补间动画**

| 特性       | 逐帧动画         | 补间动画          |
| -------- | ------------ | ------------- |
| **实现原理** | 显示一系列静态图片    | 通过插值计算中间状态    |
| **资源消耗** | 较高（需加载多张图片）  | 较低            |
| **灵活性**  | 高（可完全自定义每一帧） | 中（限于平移、旋转等变换） |
| **文件大小** | 较大（多个图片文件）   | 较小（XML定义）     |
| **适用场景** | 复杂动画、游戏角色    | 简单UI过渡效果      |

#### 2.1. 实现逐帧动画

##### 2.1.1. XML

1. 准备帧图片
2. 创建动画列表XML文件 `<animation-list>`
3. 在布局或代码中应用

**示例：** `res/drawable/frame_animation.xml`

```xml
<animation-list xmlns:android="http://schemas.android.com/apk/res/android"
    android:oneshot="false"> <!-- false表示循环播放 -->
    
    <item
        android:drawable="@drawable/frame1"
        android:duration="100" /> <!-- 每帧显示100毫秒 -->
    <item
        android:drawable="@drawable/frame2"
        android:duration="100" />
    <item
        android:drawable="@drawable/frame3"
        android:duration="100" />
    <!-- 添加更多帧... -->
</animation-list>
```

**在布局文件中使用：**
```xml
<ImageView
    android:id="@+id/animation_view"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:src="@drawable/frame_animation" />
```

**在代码中控制：**
```kotlin
val imageView = findViewById<ImageView>(R.id.animation_view)
val animation = imageView.drawable as AnimationDrawable 

// 开始动画
animation.start() 

// 停止动画 
animation.stop()
```

##### 2.1.2. 代码实现

将要播放的图片集合，一张一张的添加到一个 AnimationDrawable 对象中去，接着再将其添加到 imageView 中，调用 start() 方法便能开始播放

```kotlin
// 创建 AnimationDrawable 对象
val frameAnimation = AnimationDrawable()

// 添加帧动画
frameAnimation.addFrame(resources.getDrawable(R.drawable.frame1, null), 100)
frameAnimation.addFrame(resources.getDrawable(R.drawable.frame2, null), 100)
frameAnimation.addFrame(resources.getDrawable(R.drawable.frame3, null), 100)

// 设置动画循环播放（false）或只播放一次（true）
frameAnimation.setOneShot(false)

// 获取 ImageView 并应用动画
val imageView: ImageView = findViewById(R.id.animation_view)
imageView.setImageDrawable(frameAnimation)

// 启动动画
frameAnimation.start()
```

##### 2.1.3. View动画

```kotlin
val imageView: ImageView = findViewById(R.id.animation_view)

// 定义帧资源数组
val frameResources = intArrayOf(
    R.drawable.frame1,
    R.drawable.frame2,
    R.drawable.frame3
)

// 创建 ValueAnimator 实现帧动画
val animator = ValueAnimator.ofInt(0, frameResources.size - 1).apply {
    duration = 1000 // 总时长为 1000 毫秒
    repeatCount = ValueAnimator.INFINITE // 无限循环
    interpolator = LinearInterpolator() // 使用线性插值器（匀速）
}

// 添加动画更新监听器
animator.addUpdateListener { animation ->
    val frameIndex = animation.animatedValue as Int // 获取当前帧索引
    imageView.setImageResource(frameResources[frameIndex]) // 更新 ImageView 图片
}

// 启动动画
animator.start()
```

#### 2.2. 属性和方法

**XML属性**
- `android:oneshot`：是否只播放一次（true/false）
- `android:duration`：每帧显示时间（毫秒）
- `android:drawable`：帧图片资源

**AnimationDrawable方法**
- `start()`：开始动画
- `stop()`：停止动画
- `addFrame(Drawable frame, int duration)`：添加帧
- `setOneShot(boolean oneShot)`：设置是否只播放一次
- `isRunning()`：检查动画是否正在运行
- `getNumberOfFrames()`：获取总帧数
- `getDuration(int index)`：获取指定帧的持续时间

### 三、属性动画


属性动画是Android系统中最强大、最灵活的动画框架，其通过控制对象的属性，来实现动画效果。

与视图动画不同的是，属性动画不仅限于View对象的视图绘制效果，其可作用于任何对象的任何属性，性能和灵活性更高

**工作原理**
1. **初始化**：设置起始值、结束值、持续时间
2. **插值计算**：根据时间流逝比例计算当前进度（0.0-1.0）
3. **插值器应用**：通过Interpolator调整时间进度
4. **估值计算**：通过TypeEvaluator计算当前属性值
5. **属性更新**：将计算值应用到目标对象

#### 3.1. 基本用法

##### 3.1.1. ObjectAnimator

**属性**：和补间动画属性类似

```xml
<objectAnimator
   android:duration="int"        
   android:interpolator="@[package:]anim/interpolator_resource"
   android:propertyName="string"
   android:valueType=["intType" | "floatType"]
   android:valueFrom="float | int | color"
   android:valueTo="float | int | color"
   android:startOffset="int"
   android:repeatCount="int"
   android:repeatMode=["repeat" | "reverse"]
   />
```

创建方式依然有通过xml和在代码中动态创建两种方式

**使用xml**：首先创建xml文件

```xml
<?xml version="1.0" encoding="utf-8"?>
<objectAnimator xmlns:android="http://schemas.android.com/apk/res/android"
    android:duration="1000"
    android:interpolator="@android:anim/accelerate_decelerate_interpolator"
    android:propertyName="rotation"
    android:valueType="floatType"
    android:valueFrom="0"
    android:valueTo="360"
    android:startOffset="0"
    android:repeatCount="infinite"
    android:repeatMode="reverse"
    />
```

在代码中导入动画xml

```kotlin
// 使用动画资源创建一个类实例
val objectAnimator = AnimatorInflater.loadAnimator(this, R.animator.object_animator) 
	as ObjectAnimator

// 将类实例绑定到需要操作的对象上
objectAnimator.setTarget(target)

// 启动动画
objectAnimator.start()
```

当然，也可以使用代码创建动画，如下所示：

```kotlin
// 透明度动画 (0 -> 1)
ObjectAnimator.ofFloat(view, "alpha", 0f, 1f).apply {
    duration = 1000
    start()
}

// 平移动画 (X轴移动200像素)
ObjectAnimator.ofFloat(view, "translationX", 0f, 200f).apply {
    duration = 800
    interpolator = AccelerateDecelerateInterpolator()
    start()
}

// 旋转动画 (0 -> 360度)
ObjectAnimator.ofFloat(view, "rotation", 0f, 360f).apply {
    duration = 1200
    start()
}

// 缩放动画 (1 -> 0.5 -> 1.5)
val scaleX = PropertyValuesHolder.ofFloat("scaleX", 1f, 0.5f, 1.5f)
val scaleY = PropertyValuesHolder.ofFloat("scaleY", 1f, 0.5f, 1.5f)
ObjectAnimator.ofPropertyValuesHolder(view, scaleX, scaleY).apply {
    duration = 1500
    start()
}
```

##### 3.1.2. ValueAnimator

`ValueAnimator` 是关于数字的计算动画。它不会与View直接交互，而是通过 `addUpdateListener` 来设置动画效果。比如在TextView上显示从0到50时，就可以用`ValueAnimator`。

UpdateListener在ValueAnimator中有数值变化时，会调用`onAnimationUpdate`接口，更新UI或执行自定义逻辑

```kotlin
// 创建Animator，同时传入取值范围
val animator = ValueAnimator.ofFloat(0F, 5000F) 
// 设置差值器， 这里选择的是线性差值器
animator.interpolator = LinearInterpolator()
// 设置动画执行时间
animator.setDuration(2000)

// 实现UpdateListener
animator.addUpdateListener {
    // 在TextView中更新text
    binding.textView.text = ((it.animatedValue as Float).toInt() / 100).toString()
    // 把值传入自定义贝塞尔View，使其产生动画效果
    binding.bezierView.setValue(it.animatedValue as Float)
}

// 播放动画
animator.start()
// 动画暂定
animator.pause()
// 播放结束
animator.end()
```

一些情况下，我们还可以将动画的属性设置写在一起：

```kotlin
// 颜色渐变动画
ValueAnimator.ofArgb(Color.RED, Color.BLUE).apply {
    duration = 3000
    addUpdateListener { animation ->
        view.setBackgroundColor(animation.animatedValue as Int)
    }
    start()
}
```

或者，使用 **`ViewPropertyAnimator** 简化：

```kotlin
view.animate()
    .alpha(0.5f)
    .scaleX(1.2f)
    .scaleY(1.2f)
    .rotation(45f)
    .translationX(100f)
    .setDuration(800)
    .setInterpolator(AccelerateInterpolator())
    .withEndAction { 
        // 动画结束后的操作
    }
    .start()
```

##### 3.1.3. AnimatorSet

我们同样可以组合多个属性动画为一个动画集合，同时，还可通过 `with/after`等限制控制不同动画的播放次序

```kotlin
val fadeOut = ObjectAnimator.ofFloat(view, "alpha", 1f, 0f)
val moveLeft = ObjectAnimator.ofFloat(view, "translationX", 0f, -200f)
val fadeIn = ObjectAnimator.ofFloat(view, "alpha", 0f, 1f)

AnimatorSet().apply {
    play(fadeOut).with(moveLeft) // 同时执行
    play(fadeIn).after(moveLeft) // 在moveLeft之后执行
    duration = 1500
    start()
}
```


#### 3.2. Listener

属性动画的监听器一共有三种。
1. `AnimatorListener` ：主要监听的是属性动画的开始，结束，取消，重复
2. `AnimatorPauseListener` ：要监听的是属性动画的暂停，恢复状
3. `AnimatorUpdateListener` ：主要监听的是属性动画中值得变化

#### 3.3. Interpolator

插值器(Interpolator)定义了**动画随时间变化的速率**，它通过修改动画的时间进度（fraction）来改变动画的视觉效果。其核心数学原理是：

`output = f(input)`
- `input`: 时间进度（0.0~1.0）
- `output`: 修改后的进度（0.0~1.0）

系统默认插值器及其数学函数：

| 插值器类型                            | 函数实现                                                      | 效果描述    |
| -------------------------------- | --------------------------------------------------------- | ------- |
| LinearInterpolator               | `f(t) = t`                                                | 匀速变化    |
| AccelerateInterpolator           | `f(t) = t²` 或 `f(t) = t^(2 × factor)`                     | 加速运动    |
| DecelerateInterpolator           | `f(t) = 1 - (1 - t)²`                                     | 减速运动    |
| AccelerateDecelerateInterpolator | `f(t) = cos((t + 1) * π) / 2 + 0.5`                       | 先加速后减速  |
| BounceInterpolator               | 复杂的分段函数模拟物理反弹                                             | 弹跳效果    |
| OvershootInterpolator            | `f(t) = (t - 1)² × ((tension + 1)×(t - 1) + tension) + 1` | 超过终点再返回 |
**自定义插值器示例**：弹性插值器

```kotlin
class SpringInterpolator(
    private val damping: Float = 10f,   // 阻尼系数
    private val stiffness: Float = 100f // 刚度系数
) : Interpolator {

    override fun getInterpolation(input: Float): Float {
        // 使用弹簧-阻尼模型
        return (Math.exp(-damping * input) * Math.sin(stiffness * input)).toFloat()
    }
}

// 使用示例
ObjectAnimator.ofFloat(view, "translationY", 0f, 500f).apply {
    interpolator = SpringInterpolator(damping = 8f, stiffness = 120f)
    duration = 2000
    start()
}
```

#### 3.4. TypeEvaluator

估值器负责计算**属性在特定时间点的具体值**，其核心函数为：

`value = evaluate(fraction, startValue, endValue)`

- `fraction`: 经过插值器处理后的进度
- `startValue`: 属性起始值
- `endValue`: 属性结束值


**系统内置估值器**

| 估值器类型           | 计算逻辑                                                                                         |
| --------------- | -------------------------------------------------------------------------------------------- |
| IntEvaluator    | `(int)(start + fraction * (end - start))`                                                    |
| FloatEvaluator  | `start + fraction * (end - start)`                                                           |
| ArgbEvaluator   | 分别计算A/R/G/B通道插值                                                                              |
| PointFEvaluator | `x = start.x + fraction * (end.x - start.x)`<br>`y = start.y + fraction * (end.y - start.y)` |
| RectEvaluator   | 分别计算left/top/right/bottom插值                                                                  |

**自定义估值器实现示例**：3D点估值器
```kotlin
class Point3DEvaluator : TypeEvaluator<Point3D> {
    override fun evaluate(fraction: Float, start: Point3D, end: Point3D): Point3D {
        return Point3D(
            start.x + fraction * (end.x - start.x),
            start.y + fraction * (end.y - start.y),
            start.z + fraction * (end.z - start.z)
        )
    }
}

data class Point3D(val x: Float, val y: Float, val z: Float)

// 使用示例
val start = Point3D(0f, 0f, 0f)
val end = Point3D(100f, 200f, 50f)
val animator = ObjectAnimator.ofObject(
    view, 
    "point3D", 
    Point3DEvaluator(),
    start,
    end
)
```


**插值器与估值器**

![[Android 动画_插值器与估值器示意图.png]]


**物理模拟示例**：弹簧动画

```kotlin
class SpringPhysicsEvaluator(
    private val mass: Float = 1f,      // 质量
    private val stiffness: Float = 100f,// 刚度
    private val damping: Float = 10f    // 阻尼
) : TypeEvaluator<Float> {

    override fun evaluate(fraction: Float, start: Float, end: Float): Float {
        // 弹簧物理模型计算
        val displacement = end - start
        val force = stiffness * displacement
        val acceleration = force / mass
        val velocity = acceleration * fraction - damping * fraction
        
        return start + velocity * fraction
    }
}

class SpringInterpolator : Interpolator {
    override fun getInterpolation(input: Float): Float {
        // 使用非线性函数模拟弹簧运动
        return (Math.sin(input * Math.PI * 2.5) * Math.pow(0.5, input * 5)).toFloat()
    }
}

// 完整弹簧动画
ObjectAnimator.ofObject(
    view,
    "translationY",
    SpringPhysicsEvaluator(mass = 0.8f, stiffness = 200f, damping = 12f),
    0f,
    500f
).apply {
    interpolator = SpringInterpolator()
    duration = 1500
}
```

#### 3.5. 核心架构

**类层级关系**  
   - **`Animator`**：定义动画基本操作（`start()`/`cancel()`）和监听器接口，不涉及具体动画逻辑。
   - **`ValueAnimator`**：动画引擎核心，负责时间插值、属性值计算和帧回调调度。
   - **`ObjectAnimator`**：继承`ValueAnimator`，通过反射调用目标对象的`set`方法更新属性值。
   - **`PropertyValuesHolder`**：封装属性名、关键帧和估值器，用于计算中间值。

**关键协作组件**  
   - **`AnimationHandler`**：单例线程控制器，管理所有动画的帧回调。
   - **`Choreographer`**：接收系统VSYNC信号（每16ms一次），触发帧绘制。
   - **`TimeInterpolator`** 与 **`TypeEvaluator`**：分别控制时间曲线和属性值计算策略。

其大概原理就是 通过ofInt、ofFloat、ofArgb等将属性以及对应的值保存到PropertyValuesHolder中，然后PropertyValuesHolder通过反射将属性值注入到target中，等接收到 VSync 信号，刷新屏幕，就会通过注入的属性值改变 target，形成动画。

#### 3.6. **动画启动**

**启动入口：`ObjectAnimator.start()`**

整个动画是从 `ObjectAnimator` 的 `start()` 函数开始的，可以看到，其调用了父类的start函数
```java
// ObjectAnimator.java
public void start() {
    super.start(); // 调用ValueAnimator.start()
}
```

**`ValueAnimator`初始化与调度**

```java
    /**
     * ValueAnimator.java
     * 
     * 这个方法开始播放动画。这个start()方法使用一个boolean值playBackwards来判断是否需
     * 要回放动画。这个值通常为false，但当它从reverse()方法被调用的时候也可能为true
     * 
     * 这个方法必须从UI主线程调用
     * 
     */
    private void start(boolean playBackwards) {
        if (Looper.myLooper() == null) {
            throw new AndroidRuntimeException("Animators may only be run on Looper threads");
        }
        mPlayingBackwards = playBackwards;        // 是否需要回放动画
        mCurrentIteration = 0;                   
        mPlayingState = STOPPED;                  // 动画当前的状态
        mStarted = true;                          // 标识当前动画是否需要延时执行
        mStartedDelay = false;                    // 标识当前动画是否已经从 startDelay 中开始执行
        AnimationHandler animationHandler = getOrCreateAnimationHandler();
        animationHandler.mPendingAnimations.add(this);
        if (mStartDelay == 0) {
            // 在动画实际运行前，设置动画的初始值
            setCurrentPlayTime(0);
            mPlayingState = STOPPED;
            mRunning = true;
            notifyStartListeners();
        }
        animationHandler.start();
    }
```

在 `ValueAnimator` 的 `start()` 方法里，设置了动画的初始值，同时调用了 `animationHandler` 的 `start` 方法开始

```java
    public void setCurrentPlayTime(long playTime) {
        initAnimation();
        long currentTime = AnimationUtils.currentAnimationTimeMillis();
        if (mPlayingState != RUNNING) {
            mSeekTime = playTime;
            mPlayingState = SEEKED;
        }
        mStartTime = currentTime - playTime;
        doAnimationFrame(currentTime);
    }
```

其中的 `setCurrentPlayTime` 函数用于设置animation进度为指定时间点（类似播放器的seek功能）

playTime应该介于0到animation的总时间之间，包括animation重复执行的时候

如果animation还没有开始，那么它会等到被设置这个时间后才开始。如果animation已经运行，那么setCurrentTime()会将当前的进度设置为这个值，然后从这个点继续播放。

而在 `setCurrentPlayTime` 函数中，又调用 `initAnimation` 函数来完成animation最终的初始化


```java
    void initAnimation() {
        if (!mInitialized) {
            int numValues = mValues.length;
            for (int i = 0; i < numValues; ++i) {
                mValues[i].init();
            }
            mInitialized = true;
        }
    }

```

这个函数在处理动画的第一帧前就会被调用。如果startDelay不为0，这个函数就会在就会在延时结束后调用

此处的 mValues 是 `PropertyValuesHolder` 类型的数组，每个 `PropertyValuesHolder` 对象包含：
- 属性名称（如 "alpha"、"translationX"）
- 关键帧值序列（如 \[0, 100\]）
- 估值器（如 IntEvaluator/FloatEvaluator）

当values只有一个值的时候，这个值就作为animator的终点值；如果有两个值的话，那么这两个值就作为开始值和结束值；如果有超过两个以上的值的话，那么这些值就作为开始值，animator运行的中间值，以及结束值，这些值将均匀地分配到animator的持续时间

在 `initAnimation()` 里 `mValues[i].init()` 初始化它们的估值器 Evaluator，根据mValueType为我们初始化特定类型的Evaluator

```java
void init() {
    if (mEvaluator == null) {
        // 自动选择估值器
        mEvaluator = (mValueType == Integer.class) ? sIntEvaluator :
                    (mValueType == Float.class) ? sFloatEvaluator : null;
    }
    if (mEvaluator != null) {
        mKeyframeSet.setEvaluator(mEvaluator); // 设置估值器
    }
}
```

当然，我们也可以用 `ObjectAnimator.setEvaluator(...)` 传入特定的估值器

完成初始化后，让我们回到函数 `setCurrentPlayTime()`

```java
// 置动画的当前播放时间。参数 playTime 表示目标播放时间，单位为毫秒
public void setCurrentPlayTime(long playTime) {
    initAnimation(); // 初始化已经完成
    
    long currentTime = AnimationUtils.currentAnimationTimeMillis();    //记录当前系统时间
    if (mPlayingState != RUNNING) {
        mSeekTime = playTime;   // 记录定位位置
        mPlayingState = SEEKED; // 更新状态
    }
    mStartTime = currentTime - playTime; // 动画的理论起始时间戳，一个虚拟起始点
    doAnimationFrame(currentTime); // 基于currentTime执行一帧动画（更新属性、重绘视图等）
}
```

其中 **`mPlayingState`** 可能的状态如下所示：
- STOPPED：标识动画尚未开始播放，值为0
- RUNNING：正常播放中，值为1
- SEEKED：已定位到特定时间点，值为2

至此动画的启动和初始化完成，下面进入 `doAnimationFrame(currentTime)` 函数处理动画帧

> 此处的 **`mStartTime`** 不是实际开始时间，而是**虚拟起始点**，使系统在当前时间点看到期望的进度
> 
> 如：假设当前的系统时间戳为 1000ms ，playTime 为 300ms ，即是动画已经已经播放了 300ms
> 则此时的 `mStartTime` 为 700ms ，即是假设从 700ms 开始至此，动画刚好播放 300ms

#### 3.7. 动画帧处理

`doAnimationFrame()` 函数主要主要用来处理animator中的一帧，并在有必要的时候调整animator的开始时间

```java
final boolean doAnimationFrame(long frameTime) {
	// 对animator的开始时间和状态进行调整
    if (mPlayingState == STOPPED) {
        mPlayingState = RUNNING;
        if (mSeekTime < 0) {
            mStartTime = frameTime; // 首次启动
        } else {
            mStartTime = frameTime - mSeekTime; // 从定位位置启动
            mSeekTime = -1; // 重置定位标记
        }
    }
    
    // 确保当前时间不小于起始时间
    final long currentTime = Math.max(frameTime, mStartTime);
    return animationFrame(currentTime); // 执行实际帧计算
}
```

`doAnimationFrame(frameTime)` 完成对animator的开始时间和状态的调整后，调用 `animationFrame(currentTime)` 根据当前时间和动画状态计算动画进度，处理动画重复逻辑，并最终触发属性值更新

```java
    boolean animationFrame(long currentTime) {
        boolean done = false;
        switch (mPlayingState) {
        case RUNNING:
        case SEEKED:
	        // 计算动画的归一化进度，当 mDuration <= 0 时直接视为完成 （1f）
            float fraction = mDuration > 0 ? (float)(currentTime - mStartTime) / mDuration : 1f;
            // 动画完成周期的处理
            if (fraction >= 1f) {
                if (mCurrentIteration < mRepeatCount || mRepeatCount == INFINITE) {
	                // 处理重复播放的情况

					// 触发重复监听器
                    if (mListeners != null) {
                        int numListeners = mListeners.size();
                        for (int i = 0; i < numListeners; ++i) {
                            mListeners.get(i).onAnimationRepeat(this);
                        }
                    }

					// 处理反向模式
                    if (mRepeatMode == REVERSE) {
                        mPlayingBackwards = mPlayingBackwards ? false : true;
                        // 相当于 mPlayingBackwards = !mPlayingBackwards
                        // 反转播放方向
                    }
			            
                    mCurrentIteration += (int)fraction;  // 更新迭代计数
                    fraction = fraction % 1f;            // 重置进度
                    mStartTime += mDuration;             // 移动时间窗口
                } else {
		            // 完成处理
                    done = true;
                    fraction = Math.min(fraction, 1.0f);
                }
            }
            if (mPlayingBackwards) {
                fraction = 1f - fraction;  // 反向播放时反转进度值
            }
            animateValue(fraction);  // 更新属性
            break;
        }

        return done;
    }
```

上述函数前部分计算出 `fraction` 后，将其传入 `animateValue` 函数中，由其将归一化的进度值转换为具体的属性值，并触发视图更新

```java
void animateValue(float fraction) {

	// 通过插值器转换进度值
    fraction = mInterpolator.getInterpolation(fraction);
    mCurrentFraction = fraction;
    
    // 计算所有属性当前值
    int numValues = mValues.length;
    for (int i = 0; i < numValues; ++i) {
        mValues[i].calculateValue(fraction);
    }
    
    // 通知更新监听器
    if (mUpdateListeners != null) {
        int numListeners = mUpdateListeners.size();
        for (int i = 0; i < numListeners; ++i) {
            mUpdateListeners.get(i).onAnimationUpdate(this);
        }
    }
}
```

#### 3.8. 属性值计算流程

在 `calculateValue()` 函数中，直接调用了 `mKeyframeSet.getValue()` 函数，主要逻辑在 `getValue()` 函数中

```java
    //PropertyValuesHolder.calculateValue(...)
    void calculateValue(float fraction) {
        mAnimatedValue = mKeyframeSet.getValue(fraction);
    }

    //mKeyframeSet.getValue
    public Object getValue(float fraction) {

        if (mNumKeyframes == 2) {
	        // 双关键帧优化
        }
        
        if (fraction <= 0f) {
            // 起始区间处理
        } else if (fraction >= 1f) {
            // 结束区间处理
        }
        
        Keyframe prevKeyframe = mFirstKeyframe;
        
        for (int i = 1; i < mNumKeyframes; ++i) {
            // 中间区间处理
        }
        
        // shouldn't reach here
        return mLastKeyframe.getValue();
    }
```

**双关键帧优化（最常见场景）**

```java
if (mNumKeyframes == 2) {
    if (mInterpolator != null) {
        fraction = mInterpolator.getInterpolation(fraction);
    }
    return mEvaluator.evaluate(fraction, mFirstKeyframe.getValue(),
            mLastKeyframe.getValue());
}
```

针对只有起止关键帧的简单动画进行优化 ，直接应用全局插值器（如加速/减速效果），同时使用使用估值器（`Evaluator`）计算属性值 

避免遍历关键帧列表，提升效率

**起始区间处理（fraction ≤ 0）**

```java
if (fraction <= 0f) {
    final Keyframe nextKeyframe = mKeyframes.get(1);
    final TimeInterpolator interpolator = nextKeyframe.getInterpolator();
    
    // 应用下一关键帧的插值器
    if (interpolator != null) {
        fraction = interpolator.getInterpolation(fraction);
    }
    
    // 计算区间比例
    final float prevFraction = mFirstKeyframe.getFraction();
    float intervalFraction = (fraction - prevFraction) /
        (nextKeyframe.getFraction() - prevFraction);
    
    return mEvaluator.evaluate(intervalFraction, 
        mFirstKeyframe.getValue(), nextKeyframe.getValue());
}
```

动画进度在第一个关键帧之前（如反向播放开始）时，使用**第二关键帧的插值器**（非全局插值器）

区间比例计算：  `(当前进度 - 起点帧进度) / (下一帧进度 - 起点帧进度)`

**结束区间处理（fraction ≥ 1）**

```java
else if (fraction >= 1f) {
    final Keyframe prevKeyframe = mKeyframes.get(mNumKeyframes - 2);
    final TimeInterpolator interpolator = mLastKeyframe.getInterpolator();
    
    // 应用结束帧插值器
    if (interpolator != null) {
        fraction = interpolator.getInterpolation(fraction);
    }
    
    // 计算区间比例
    final float prevFraction = prevKeyframe.getFraction();
    float intervalFraction = (fraction - prevFraction) /
        (mLastKeyframe.getFraction() - prevFraction);
    
    return mEvaluator.evaluate(intervalFraction,
        prevKeyframe.getValue(), mLastKeyframe.getValue());
}
```

动画进度超过最后关键帧（如重复播放结束阶段），使用**结束关键帧的插值器**

区间比例计算：  `(当前进度 - 前一帧进度) / (结束帧进度 - 前一帧进度)`

**中间区间处理（0 < fraction < 1）**

```java
Keyframe prevKeyframe = mFirstKeyframe;
for (int i = 1; i < mNumKeyframes; ++i) {
    Keyframe nextKeyframe = mKeyframes.get(i);
    if (fraction < nextKeyframe.getFraction()) {
        final TimeInterpolator interpolator = nextKeyframe.getInterpolator();
        
        // 应用当前区间插值器
        if (interpolator != null) {
            fraction = interpolator.getInterpolation(fraction);
        }
        
        // 计算局部进度
        final float prevFraction = prevKeyframe.getFraction();
        float intervalFraction = (fraction - prevFraction) /
            (nextKeyframe.getFraction() - prevFraction);
        
        return mEvaluator.evaluate(intervalFraction,
            prevKeyframe.getValue(), nextKeyframe.getValue());
    }
    prevKeyframe = nextKeyframe;
}
```

逐区间插值器支持：
   - 每个关键帧可带独立插值器
   - 实现不同区间的差异化运动曲线
   
局部进度归一化： `intervalFraction = (fraction - prevFraction) / (nextFraction - prevFraction)` 
将全局进度转换为当前区间内的0-1比例

**数据结构**

1. 关键帧（Keyframe）

| 属性              | 类型               | 说明               |
| --------------- | ---------------- | ---------------- |
| `mFraction`     | float            | 关键帧时间位置（0.0-1.0） |
| `mValue`        | Object           | 关键帧属性值           |
| `mInterpolator` | TimeInterpolator | 当前区间运动曲线         |
2. 关键帧集（KeyframeSet）

| 属性               | 类型               | 说明          |
| ---------------- | ---------------- | ----------- |
| `mKeyframes`     | List<Keyframe>   | 有序关键帧集合     |
| `mFirstKeyframe` | Keyframe         | 起始关键帧（快速访问） |
| `mLastKeyframe`  | Keyframe         | 结束关键帧（快速访问） |
| `mInterpolator`  | TimeInterpolator | 全局默认插值器     |
| `mEvaluator`     | TypeEvaluator    | 属性值计算器      |
#### 3.9. 动画驱动

让我们在回到最开始的 `start()`  函数

```java
    private void start(boolean playBackwards) {
        if (Looper.myLooper() == null) {
            throw new AndroidRuntimeException("Animators may only be run on Looper threads");
        }
        mPlayingBackwards = playBackwards;        // 是否需要回放动画
        mCurrentIteration = 0;                   
        mPlayingState = STOPPED;                  // 动画当前的状态
        mStarted = true;                          // 标识当前动画是否需要延时执行
        mStartedDelay = false;                    // 标识当前动画是否已经从 startDelay 中开始执行
        AnimationHandler animationHandler = getOrCreateAnimationHandler();
        animationHandler.mPendingAnimations.add(this);
        if (mStartDelay == 0) {
            setCurrentPlayTime(0);

// ------------------  上面的分析为这之前的内容  --------------------------

            mPlayingState = STOPPED;
            mRunning = true;
            notifyStartListeners();
        }
        animationHandler.start();
    }
```

在 `setCurrentPlayTime(0)` 后，紧接着就通过 notifyStartListeners() 通知animation启动的消息。最后通过 `animationHandler.start()` 去执行

```java
    //AnimationHandler.start()
    public void start() {
        scheduleAnimation();
    }
    
    //AnimationHandler.scheduleAnimation()
    private void scheduleAnimation() {
        if (!mAnimationScheduled) {
            mChoreographer.postCallback(Choreographer.CALLBACK_ANIMATION, this, null);
            mAnimationScheduled = true;
        }
    }

    // Called by the Choreographer.
    @Override
    public void run() {
        mAnimationScheduled = false;
        doAnimationFrame(mChoreographer.getFrameTime());
    }
```

animationHandler是一个AnimationHandler类型的对象，它实现了runable接口，将内容通过mChoreographer.发送给UI系统，具体的驱动流程如下：


![[Android 动画_动画驱动.png]]








