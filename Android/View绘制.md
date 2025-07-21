Android 中的 View 是 UI 框架的核心组件，其绘制流程是一个高效、递归的过程，主要负责确定每个 View 的尺寸、位置和可视内容。

这个流程由 ViewRootImpl（Android 3.0 及以上版本）触发，通过 performTraversals() 方法协调三个主要阶段：Measure（测量）、Layout（布局）和 Draw（绘制）。

View 的绘制从根视图（DecorView）开始，以树形结构递归遍历所有子 View。整个流程由 ViewRootImpl 的 performTraversals() 方法驱动，这个方法会依次调用三个核心阶段：

```java
// ViewRootImpl.java (简化示例，实际的该函数很长)
private void performTraversals() {
    performMeasure();  // 测量阶段：确定尺寸
    performLayout();   // 布局阶段：确定位置
    performDraw();     // 绘制阶段：渲染内容
}
```

**触发时机**：通常由 invalidate()、requestLayout() 或系统事件（如屏幕旋转、输入事件）触发。绘制过程与屏幕刷新同步，确保流畅的 UI 更新。

整个流程都会在 UI 主线程执行，避免阻塞以防止 ANR（Application Not Responding）。

### 一、 Measure

Android View 的绘制流程以 Measure 阶段开头，该阶段由 ViewRootImpl 的 performMeasure() 启动，递归遍历视图树。每个 View 的 measure() 方法由其父 View 调用。

这个阶段负责根据父 View 提供的 MeasureSpec（测量规范，包括模式和大小）计算 View 的测量尺寸（measuredWidth 和 measuredHeight）。MeasureSpec 确保 View 不超过可用空间，同时允许自适应（如 wrap_content）。

**MeasureSpec**：MeasureSpec 是一个 32 位整数，高 2 位表示模式（Mode），低 30 位表示大小（Size）。
   - **三种模式**：
     - **EXACTLY**：精确模式（如 layout_width="match_parent" 或具体数值，如 100dp），View 必须使用指定的 Size。
     - **AT_MOST**：最大模式（如 wrap_content），View 可以小于或等于 Size，但需根据内容自适应。
     - **UNSPECIFIED**：未指定模式（如 ScrollView 中的子 View），View 可以任意大小，通常用于无限滚动场景。

**入口**：`performMeasure()` ，调用 `measure()` 函数进行进一步处理

```java
private void performMeasure(int childWidthMeasureSpec, int childHeightMeasureSpec) {  
    if (mView == null) {  
        return;  
    }  
    Trace.traceBegin(Trace.TRACE_TAG_VIEW, "measure");  
    try {  
        mView.measure(childWidthMeasureSpec, childHeightMeasureSpec);  
    } finally {  
        Trace.traceEnd(Trace.TRACE_TAG_VIEW);  
    }  
}
```

其中 `measure()` 函数如下所示：

```java
public final void measure(int widthMeasureSpec, int heightMeasureSpec) {  

	// 处理光学边界
    boolean optical = isLayoutModeOptical(this);  
    if (optical != isLayoutModeOptical(mParent)) {  
        Insets insets = getOpticalInsets();  
        int oWidth  = insets.left + insets.right;  
        int oHeight = insets.top  + insets.bottom;  
        widthMeasureSpec  = MeasureSpec.adjust(widthMeasureSpec,  optical ? -oWidth  : oWidth);  
        heightMeasureSpec = MeasureSpec.adjust(heightMeasureSpec, optical ? -oHeight : oHeight);  
    }  

	//缓存键
    // Suppress sign extension for the low bytes  
    long key = (long) widthMeasureSpec << 32 | (long) heightMeasureSpec & 0xffffffffL;  
    if (mMeasureCache == null) mMeasureCache = new LongSparseLongArray(2);  
  
    final boolean forceLayout = (mPrivateFlags & PFLAG_FORCE_LAYOUT) == PFLAG_FORCE_LAYOUT;  
  
    // Optimize layout by avoiding an extra EXACTLY pass when the view is  
    // already measured as the correct size. In API 23 and below, this    
    // extra pass is required to make LinearLayout re-distribute weight.    
    final boolean specChanged = widthMeasureSpec != mOldWidthMeasureSpec  
            || heightMeasureSpec != mOldHeightMeasureSpec;  
    final boolean isSpecExactly = MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY  
            && MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY;  
    final boolean matchesSpecSize = getMeasuredWidth() == MeasureSpec.getSize(widthMeasureSpec)  
            && getMeasuredHeight() == MeasureSpec.getSize(heightMeasureSpec);  
    final boolean needsLayout = specChanged  
            && (sAlwaysRemeasureExactly || !isSpecExactly || !matchesSpecSize);  
    
    // 执行测量
    if (forceLayout || needsLayout) {  
        // first clears the measured dimension flag  
        mPrivateFlags &= ~PFLAG_MEASURED_DIMENSION_SET;  
  
        resolveRtlPropertiesIfNeeded();  
  
        int cacheIndex = forceLayout ? -1 : mMeasureCache.indexOfKey(key);  
        if (cacheIndex < 0 || sIgnoreMeasureCache) {  
            // measure ourselves, this should set the measured dimension flag back  
            onMeasure(widthMeasureSpec, heightMeasureSpec);  
            mPrivateFlags3 &= ~PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;  
        } else {  
            long value = mMeasureCache.valueAt(cacheIndex);  
            // Casting a long to int drops the high 32 bits, no mask needed  
            setMeasuredDimensionRaw((int) (value >> 32), (int) value);  
            mPrivateFlags3 |= PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;  
        }  
  
        // flag not set, setMeasuredDimension() was not invoked, we raise  
        // an exception to warn the developer        
        if ((mPrivateFlags & PFLAG_MEASURED_DIMENSION_SET) != PFLAG_MEASURED_DIMENSION_SET) {  
            throw new IllegalStateException("View with id " + getId() + ": "  
                    + getClass().getName() + "#onMeasure() did not set the"  
                    + " measured dimension by calling"  
                    + " setMeasuredDimension()");  
        }  
  
        mPrivateFlags |= PFLAG_LAYOUT_REQUIRED;  
    }  

	// 更新旧规格并缓存结果
    mOldWidthMeasureSpec = widthMeasureSpec;  
    mOldHeightMeasureSpec = heightMeasureSpec;  
  
    mMeasureCache.put(key, ((long) mMeasuredWidth) << 32 |  
            (long) mMeasuredHeight & 0xffffffffL); // suppress sign extension  
}
```
#### 1.1. 处理光学边界

光学边界（Optical Insets）用于处理如阴影或发光效果的额外空间，如果当前和父 View 的光学模式不同，需要调整 MeasureSpec 的 Size

```java
boolean optical = isLayoutModeOptical(this);
if (optical != isLayoutModeOptical(mParent)) {
    Insets insets = getOpticalInsets();
    int oWidth  = insets.left + insets.right;
    int oHeight = insets.top  + insets.bottom;
    widthMeasureSpec  = MeasureSpec.adjust(widthMeasureSpec,  optical ? -oWidth  : oWidth);
    heightMeasureSpec = MeasureSpec.adjust(heightMeasureSpec, optical ? -oHeight : oHeight);
}
```

**MeasureSpec.adjust()**：根据光学模式添加或减去 insets，确保测量考虑这些额外空间，防止光学效果导致布局溢出或重叠。

#### 1.2. 缓存键

将 widthMeasureSpec 和 heightMeasureSpec 组合成一个 long 值，用于 mMeasureCache查询以前的测量结果

```java
long key = (long) widthMeasureSpec << 32 | (long) heightMeasureSpec & 0xffffffffL;
if (mMeasureCache == null) mMeasureCache = new LongSparseLongArray(2);

final boolean forceLayout = (mPrivateFlags & PFLAG_FORCE_LAYOUT) == PFLAG_FORCE_LAYOUT;

final boolean specChanged = widthMeasureSpec != mOldWidthMeasureSpec
        || heightMeasureSpec != mOldHeightMeasureSpec;
final boolean isSpecExactly = MeasureSpec.getMode(widthMeasureSpec) == MeasureSpec.EXACTLY
        && MeasureSpec.getMode(heightMeasureSpec) == MeasureSpec.EXACTLY;
final boolean matchesSpecSize = getMeasuredWidth() == MeasureSpec.getSize(widthMeasureSpec)
        && getMeasuredHeight() == MeasureSpec.getSize(heightMeasureSpec);
final boolean needsLayout = specChanged
        && (sAlwaysRemeasureExactly || !isSpecExactly || !matchesSpecSize);
```

**检查条件**：
  - **forceLayout**：如果 View 的标志位 PFLAG_FORCE_LAYOUT 被设置（例如通过 requestLayout()），强制重新测量。
  - **specChanged**：如果 MeasureSpec 与上次的 mOldWidthMeasureSpec/mOldHeightMeasureSpec 不同，需要重新测量。
  - **isSpecExactly** 和 **matchesSpecSize**：如果规格是 EXACTLY 模式且当前测量尺寸已匹配，无需重新测量

通过上述缓存设计，避免了不必要的 onMeasure() 调用，尤其在规格未变时，提高性能

#### 1.3. 执行测量

如果 `forceLayout` 或者上判断需要测量，则忽略缓存，否则查询 mMeasureCache。

```java
if (forceLayout || needsLayout) {
    mPrivateFlags &= ~PFLAG_MEASURED_DIMENSION_SET;
    resolveRtlPropertiesIfNeeded();
    int cacheIndex = forceLayout ? -1 : mMeasureCache.indexOfKey(key);
    if (cacheIndex < 0 || sIgnoreMeasureCache) {
        onMeasure(widthMeasureSpec, heightMeasureSpec);
        mPrivateFlags3 &= ~PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;
    } else {
        long value = mMeasureCache.valueAt(cacheIndex);
        setMeasuredDimensionRaw((int) (value >> 32), (int) value);
        mPrivateFlags3 |= PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;
    }
    if ((mPrivateFlags & PFLAG_MEASURED_DIMENSION_SET) != PFLAG_MEASURED_DIMENSION_SET) {
        throw new IllegalStateException(...);
    }
    mPrivateFlags |= PFLAG_LAYOUT_REQUIRED;
}
```

首先清除测量标志，解析 RTL（右到左布局）属性。

**缓存检查**：
  - 如果无缓存或忽略缓存，调用 **onMeasure()**（核心自定义点）。
  - 如果有缓存，直接使用 setMeasuredDimensionRaw() 设置尺寸（从缓存值提取高低 32 位）。

在最后设置 PFLAG_LAYOUT_REQUIRED，表示需要后续 Layout 阶段。

#### 1.4. 更新并缓存

更新旧规格：保存当前 MeasureSpec 为“旧值”，用于下次比较，同时将测量结果存入缓存，便于未来复用

```java
mOldWidthMeasureSpec = widthMeasureSpec;
mOldHeightMeasureSpec = heightMeasureSpec;
mMeasureCache.put(key, ((long) mMeasuredWidth) << 32 | (long) mMeasuredHeight & 0xffffffffL);
```

#### 1.5. onMeasure() 

一般的，`onMeasure()` 调用 `getDefaultSize() 计算宽度和高度，然后通过 setMeasuredDimension() 设置

```java
protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
    setMeasuredDimension(getDefaultSize(getSuggestedMinimumWidth(), widthMeasureSpec),
            getDefaultSize(getSuggestedMinimumHeight(), heightMeasureSpec));
}
```

对于自定义的view，开发者应重写此方法，根据 MeasureSpec 模式计算尺寸。例如，对于 ImageView，需要测量图片大小；对于 TextView，需要计算文本行数。

其中，默认的 `getDefaultSize()` 的实现如下所示

```java
public static int getDefaultSize(int size, int measureSpec) {
    int result = size;
    int specMode = MeasureSpec.getMode(measureSpec);
    int specSize = MeasureSpec.getSize(measureSpec);
    switch (specMode) {
    case MeasureSpec.UNSPECIFIED: result = size; break;
    case MeasureSpec.AT_MOST:
    case MeasureSpec.EXACTLY: result = specSize; break;
    }
    return result;
}
```

UNSPECIFIED 返回建议最小尺寸（size，通常从 minWidth/minHeight 或 background Drawable 获取）
AT_MOST/EXACTLY 返回 specSize。

> **注**：在 AT_MOST（wrap_content）下，直接返回 specSize，导致 View 可能过大。自定义时需在 onMeasure() 中手动计算内容尺寸。

### 二、Layout

在 Measure 阶段确定 View 尺寸后，Layout阶段主要负责为 View 及其所有后代分配位置（左、上、右、下坐标），确保视图树在屏幕上的正确排列。这个过程是递归的，由父 View 调用子 View 的 layout() 方法，从视图树的根（通常是 DecorView）开始遍历。

由 ViewRootImpl 的 performLayout() 方法启动，递归遍历视图树。每个 View 的 layout() 方法由其父 View 调用（例如，ViewGroup 在其 onLayout() 中调用子 View 的 layout()）

**入口**：`performLayout()`，源码如下所示：

```java
private void performLayout(WindowManager.LayoutParams lp, int desiredWindowWidth, int desiredWindowHeight) {  
    
    // performLayout() 的初始化和根布局调用
    mScrollMayChange = true;  
    mInLayout = true;  
  
    final View host = mView;  
    if (host == null) {  
        return;  
    }  
    if (DEBUG_ORIENTATION || DEBUG_LAYOUT) {  
        Log.v(mTag, "Laying out " + host + " to (" +  
                host.getMeasuredWidth() + ", " + host.getMeasuredHeight() + ")");  
    }  
  
    Trace.traceBegin(Trace.TRACE_TAG_VIEW, "layout");  
    try {  
        host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());  

		// 处理布局期间的 requestLayout() 请求
        mInLayout = false;  
        int numViewsRequestingLayout = mLayoutRequesters.size();  
        if (numViewsRequestingLayout > 0) {  
            // requestLayout() was called during layout.  
            // If no layout-request flags are set on the requesting views, there is no problem.            
            // If some requests are still pending, then we need to clear those flags and do            
            // a full request/measure/layout pass to handle this situation.            
            ArrayList<View> validLayoutRequesters = getValidLayoutRequesters(mLayoutRequesters, false);  
            if (validLayoutRequesters != null) {  
                
                // Set this flag to indicate that any further requests are happening during  
                // the second pass, which may result in posting those requests to the next                
                // frame instead                
                mHandlingLayoutInLayoutRequest = true;  
  
                // Process fresh layout requests, then measure and layout  
                int numValidRequests = validLayoutRequesters.size();  
                for (int i = 0; i < numValidRequests; ++i) {  
                    final View view = validLayoutRequesters.get(i);  
                    Log.w("View", "requestLayout() improperly called by " + view +  
                            " during layout: running second layout pass");  
                    view.requestLayout();  
                }  
                measureHierarchy(host, lp, mView.getContext().getResources(),  
                        desiredWindowWidth, desiredWindowHeight);  
                mInLayout = true;  
                host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());  
  
                mHandlingLayoutInLayoutRequest = false;  
  
                // Check the valid requests again, this time without checking/clearing the  
	                // layout flags, since requests happening during the second pass get noop'd
	                
	            validLayoutRequesters = getValidLayoutRequesters(mLayoutRequesters, true);  
                
                if (validLayoutRequesters != null) {  
                    final ArrayList<View> finalRequesters = validLayoutRequesters;  
                    // Post second-pass requests to the next frame  
                    getRunQueue().post(new Runnable() {  
                        @Override  
                        public void run() {  
                            int numValidRequests = finalRequesters.size();  
                            for (int i = 0; i < numValidRequests; ++i) {  
                                final View view = finalRequesters.get(i);  
                                Log.w("View", "requestLayout() improperly called by " + view +  
                                        " during second layout pass: posting in next frame");  
                                view.requestLayout();  
                            }  
                        }  
                    });  
                }  
            }  
  
        }  
    } finally {  
        Trace.traceEnd(Trace.TRACE_TAG_VIEW);  
    }  
    mInLayout = false;  
}
```

#### 2.1. 初始化和根布局调用

**初始化**：设置 mScrollMayChange（表示滚动可能变化）和 mInLayout（表示正在布局中），防止嵌套布局。

其中的 host 是 DecorView（窗口的根视图）。使用 Measure 结果调用 host.layout(0, 0, measuredWidth, measuredHeight)，启动递归布局

```java
private void performLayout(WindowManager.LayoutParams lp, int desiredWindowWidth, int desiredWindowHeight) {
    mScrollMayChange = true;
    mInLayout = true;

    final View host = mView;
    if (host == null) {
        return;
    }
    
    if (DEBUG_ORIENTATION || DEBUG_LAYOUT) { Log.v(...); }

    Trace.traceBegin(Trace.TRACE_TAG_VIEW, "layout");
    try {
	    // 从根视图启动递归布局
        host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());
        // ... (后续处理)
    } finally {
        Trace.traceEnd(Trace.TRACE_TAG_VIEW);
    }
    mInLayout = false;
}
```

这是 Layout 阶段的入口，确保从 (0,0) 开始布局整个窗口。
#### 2.2. 处理 `requestLayout()` 请求

处理布局期间可能产生的 `requestLayout()` 

```java
mInLayout = false;

// 检查 mLayoutRequesters（布局期间调用 requestLayout() 的 View 列表）
int numViewsRequestingLayout = mLayoutRequesters.size();
if (numViewsRequestingLayout > 0) {

	// 过滤掉无效或已处理的请求（参数 false 表示第一次检查）
    ArrayList<View> validLayoutRequesters = getValidLayoutRequesters(mLayoutRequesters, false);
    】if (validLayoutRequesters != null) {
        mHandlingLayoutInLayoutRequest = true;
        int numValidRequests = validLayoutRequesters.size();
        for (int i = 0; i < numValidRequests; ++i) {
            final View view = validLayoutRequesters.get(i);
	            Log.w(...);
            view.requestLayout();
        }
        measureHierarchy(host, lp, mView.getContext().getResources(), desiredWindowWidth, desiredWindowHeight);
        mInLayout = true;
        host.layout(0, 0, host.getMeasuredWidth(), host.getMeasuredHeight());
        mHandlingLayoutInLayoutRequest = false;

        validLayoutRequesters = getValidLayoutRequesters(mLayoutRequesters, true);
        if (validLayoutRequesters != null) {
            final ArrayList<View> finalRequesters = validLayoutRequesters;
            getRunQueue().post(new Runnable() {
                @Override
                public void run() {
                    int numValidRequests = finalRequesters.size();
                    for (int i = 0; i < numValidRequests; ++i) {
                        final View view = finalRequesters.get(i);
                        Log.w(...);
                        view.requestLayout();
                    }
                }
            });
        }
    }
}
```

**有效请求过滤**：getValidLayoutRequesters() 过滤掉无效或已处理的请求（参数 false 表示第一次检查）。

**第二次遍历**：如果有有效请求，设置 mHandlingLayoutInLayoutRequest，日志警告，然后：
  - 调用 view.requestLayout() 处理每个请求。
  - 重新测量（measureHierarchy()，递归 Measure 整个树）。
  - 重新设置 mInLayout 并调用 host.layout()（第二次 Layout）。

**第三次检查**：再次过滤（参数 true），如果仍有请求，post 到下一帧的 RunQueue（Handler 队列），延迟处理防止无限循环。

> 这是一种容错机制。布局期间的 requestLayout() 可能由动画或事件引起；多次遍历确保稳定性，但是在日常开发中应避免
> 
> `requestLayout()` 方法注释：This should not be called while the view hierarchy is currently in a layout pass ({@link #isInLayout()}. If layout is happening, the request may be honored at the end of the current layout pass (and then layout will run again) or after the current frame is drawn and the next layout occurs. 
#### 2.3. layout()

`layout()` 的源码如下所示，用以处理具体某个 View 的布局

```java

@SuppressWarnings({"unchecked"})  
public void layout(int l, int t, int r, int b) {  
    if ((mPrivateFlags3 & PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT) != 0) {  
        onMeasure(mOldWidthMeasureSpec, mOldHeightMeasureSpec);  
        mPrivateFlags3 &= ~PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;  
    }  
  
    int oldL = mLeft;  
    int oldT = mTop;  
    int oldB = mBottom;  
    int oldR = mRight;  
  
    boolean changed = isLayoutModeOptical(mParent) ?  
            setOpticalFrame(l, t, r, b) : setFrame(l, t, r, b);  
  
    if (changed || (mPrivateFlags & PFLAG_LAYOUT_REQUIRED) == PFLAG_LAYOUT_REQUIRED) {  
        onLayout(changed, l, t, r, b);  
  
        if (shouldDrawRoundScrollbar()) {  
            if(mRoundScrollbarRenderer == null) {  
                mRoundScrollbarRenderer = new RoundScrollbarRenderer(this);  
            }  
        } else {  
            mRoundScrollbarRenderer = null;  
        }  
  
        mPrivateFlags &= ~PFLAG_LAYOUT_REQUIRED;  
  
        ListenerInfo li = mListenerInfo;  
        if (li != null && li.mOnLayoutChangeListeners != null) {  
            ArrayList<OnLayoutChangeListener> listenersCopy =  
                    (ArrayList<OnLayoutChangeListener>)li.mOnLayoutChangeListeners.clone();  
            int numListeners = listenersCopy.size();  
            for (int i = 0; i < numListeners; ++i) {  
                listenersCopy.get(i).onLayoutChange(this, l, t, r, b, oldL, oldT, oldR, oldB);  
            }  
        }  
    }  
  
    final boolean wasLayoutValid = isLayoutValid();  
  
    mPrivateFlags &= ~PFLAG_FORCE_LAYOUT;  
    mPrivateFlags3 |= PFLAG3_IS_LAID_OUT;  
  
    if (!wasLayoutValid && isFocused()) {  
        mPrivateFlags &= ~PFLAG_WANTS_FOCUS;  
        if (canTakeFocus()) {  
            // We have a robust focus, so parents should no longer be wanting focus.  
            clearParentsWantFocus();  
        } else if (getViewRootImpl() == null || !getViewRootImpl().isInLayout()) {  
            // This is a weird case. Most-likely the user, rather than ViewRootImpl, called  
            // layout. In this case, there's no guarantee that parent layouts will be evaluated            
            // and thus the safest action is to clear focus here.            
            clearFocusInternal(null, /* propagate */ true, /* refocus */ false);  
            clearParentsWantFocus();  
        } else if (!hasParentWantsFocus()) {  
            // original requestFocus was likely on this view directly, so just clear focus  
            clearFocusInternal(null, /* propagate */ true, /* refocus */ false);  
        }  
        // otherwise, we let parents handle re-assigning focus during their layout passes.  
    } else if ((mPrivateFlags & PFLAG_WANTS_FOCUS) != 0) {  
        mPrivateFlags &= ~PFLAG_WANTS_FOCUS;  
        View focused = findFocus();  
        if (focused != null) {  
            // Try to restore focus as close as possible to our starting focus.  
            if (!restoreDefaultFocus() && !hasParentWantsFocus()) {  
                // Give up and clear focus once we've reached the top-most parent which wants focus.                
                focused.clearFocusInternal(null, /* propagate */ true, /* refocus */ false);  
            }  
        }  
    }  
  
    if ((mPrivateFlags3 & PFLAG3_NOTIFY_AUTOFILL_ENTER_ON_LAYOUT) != 0) {  
        mPrivateFlags3 &= ~PFLAG3_NOTIFY_AUTOFILL_ENTER_ON_LAYOUT;  
        notifyEnterOrExitForAutoFillIfNeeded(true);  
    }  
  
    notifyAppearedOrDisappearedForContentCaptureIfNeeded(true);  
}
```

**检查并处理预测量需求**

```java
if ((mPrivateFlags3 & PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT) != 0) {
    onMeasure(mOldWidthMeasureSpec, mOldHeightMeasureSpec);
    mPrivateFlags3 &= ~PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT;
}
```

如果标志位 PFLAG3_MEASURE_NEEDED_BEFORE_LAYOUT 被设置（通常在 Measure 阶段从缓存加载时设置），表示需要在 Layout 前重新测量

这是一种优化机制，确保尺寸准确（例如，缓存失效或规格变化）

**保存旧位置并设置新位置**

```java
int oldL = mLeft;
int oldT = mTop;
int oldB = mBottom;
int oldR = mRight;

boolean changed = isLayoutModeOptical(mParent) ?
        setOpticalFrame(l, t, r, b) : setFrame(l, t, r, b);
```

记录当前的 mLeft、mTop、mRight、mBottom，用于后续比较和监听器通知。

**设置新位置**：
  - 如果父 View 使用光学布局模式（optical），调用 setOpticalFrame()，它调整坐标以考虑光学 insets（如阴影边界）。
  - 否则，调用 setFrame()，这是一个内部方法，更新 mLeft、mTop、mRight、mBottom，并计算 View 的宽度和高度（mRight - mLeft, mBottom - mTop）。

**changed 标志**：如果新位置与旧位置不同，返回 true。这用于优化后续步骤，只在变化时执行 onLayout() 等操作

**执行相关处理**

```java
// 如果位置变化或标志位 PFLAG_LAYOUT_REQUIRED 被设置，则执行核心逻辑。
if (changed || (mPrivateFlags & PFLAG_LAYOUT_REQUIRED) == PFLAG_LAYOUT_REQUIRED) {
    
    onLayout(changed, l, t, r, b);

	// 检查是否需要绘制圆形滚动条（shouldDrawRoundScrollbar()
    if (shouldDrawRoundScrollbar()) {
	    // 如果需要，初始化 RoundScrollbarRenderer
        if(mRoundScrollbarRenderer == null) {
            mRoundScrollbarRenderer = new RoundScrollbarRenderer(this);
        }
    } else {
	    // 否则清除它
        mRoundScrollbarRenderer = null;
    }

    // 移除 PFLAG_LAYOUT_REQUIRED，表示 Layout 完成
    mPrivateFlags &= ~PFLAG_LAYOUT_REQUIRED;

    // 通知监听器
    ListenerInfo li = mListenerInfo;
    if (li != null && li.mOnLayoutChangeListeners != null) {
	        ArrayList<OnLayoutChangeListener> listenersCopy = 
						        (ArrayList<OnLayoutChangeListener>)li.mOnLayoutChangeListeners.clone();
        int numListeners = listenersCopy.size();
        for (int i = 0; i < numListeners; ++i) {
            listenersCopy.get(i).onLayoutChange(this, l, t, r, b, oldL, oldT, oldR, oldB);
        }
    }
}
```

在该函数中，通过**调用 onLayout()**，传递 changed 和新位置参数，排列子 View

同时，若有 OnLayoutChangeListener 注册，克隆列表并调用每个监听器的 `onLayoutChange()` ，传递新旧位置。这允许外部代码响应布局变化

**处理焦点和布局有效性**

```java

// 检查布局有效性
final boolean wasLayoutValid = isLayoutValid();

mPrivateFlags &= ~PFLAG_FORCE_LAYOUT;
mPrivateFlags3 |= PFLAG3_IS_LAID_OUT;

// 确保焦点在布局变化后正确处理
if (!wasLayoutValid && isFocused()) {
    mPrivateFlags &= ~PFLAG_WANTS_FOCUS;
    if (canTakeFocus()) {
        clearParentsWantFocus();
    } else if (getViewRootImpl() == null || !getViewRootImpl().isInLayout()) {
        clearFocusInternal(null, true, false);
        clearParentsWantFocus();
    } else if (!hasParentWantsFocus()) {
        clearFocusInternal(null, true, false);
    }
} else if ((mPrivateFlags & PFLAG_WANTS_FOCUS) != 0) {
    mPrivateFlags &= ~PFLAG_WANTS_FOCUS;
    View focused = findFocus();
    if (focused != null) {
        if (!restoreDefaultFocus() && !hasParentWantsFocus()) {
            focused.clearFocusInternal(null, true, false);
        }
    }
}
```

**布局有效性**：检查 isLayoutValid()（基于标志位判断布局是否已有效）。

**焦点管理**：防止布局变化导致焦点丢失或混乱
  - 如果布局无效且 View 已聚焦，清除焦点请求标志，并根据条件（如 canTakeFocus() 或父 View 的焦点需求）清除焦点或传播到父级。
  - 如果有 PFLAG_WANTS_FOCUS 标志，尝试恢复默认焦点（restoreDefaultFocus()），或清除现有焦点。

**通知 `autofill` 和内容捕获**

```java
if ((mPrivateFlags3 & PFLAG3_NOTIFY_AUTOFILL_ENTER_ON_LAYOUT) != 0) {
    mPrivateFlags3 &= ~PFLAG3_NOTIFY_AUTOFILL_ENTER_ON_LAYOUT;
    notifyEnterOrExitForAutoFillIfNeeded(true);
}

notifyAppearedOrDisappearedForContentCaptureIfNeeded(true);
```

如果标志设置，通知 autofill 系统 View 已进入布局（用于自动填充如密码字段），同时通知内容捕获系统 View 已出现或消失（用于无障碍服务或截屏）

#### 2.4. onLayout()

**默认实现**：为空

```java
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
  }
```

对于单 View（如 ImageView），默认为空，因为它们没有子 View，无需排列。
ViewGroup 必须重写此方法来计算并调用每个子 View 的 layout()，例如 LinearLayout 根据方向线性排列子 View。

当然，onLayout() 也可用于特定 View 的后布局逻辑，如更新内部状态或自适应内容，而非排列子 View，如 TextView 的重写：

  ```java
  protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
      super.onLayout(changed, left, top, right, bottom);
      if (mDeferScroll >= 0) {
          int curs = mDeferScroll;
          mDeferScroll = -1;
          bringPointIntoView(Math.min(curs, mText.length()));
      }
      autoSizeText();
  }
  ```



### 三、draw

Android View 的绘制流程中，Draw（绘制）阶段是 Measure 和 Layout 之后的最终阶段，负责渲染视图树的所有元素，包括背景、内容、子 View 和装饰，到 Canvas 上。最终提交到 Surface（屏幕缓冲区），与 VSYNC（垂直同步，60Hz）同步显示

这个过程由 ViewRootImpl 的 performDraw() 方法协调，从根视图（DecorView）开始，递归调用每个 View 的 draw() 方法，最终将内容绘制到 Canvas，并通过 SurfaceFlinger 合成显示。Draw 过程支持硬件加速（GPU 渲染），并处理如异步缓冲、栅栏同步和内容捕获等高级机制，以确保流畅性和稳定性。

**触发**：由 ViewRootImpl 的 performTraversals() 调用 performDraw()，在 invalidate() 或系统刷新后执行。

**核心方法**：
  - **performDraw()**：ViewRootImpl 中的私有方法，管理绘制前后的状态、硬件同步和异常处理。
  - **draw(Canvas canvas)**：View 的公共方法，执行7个有序绘制步骤（背景 → 内容 → 子 View → 装饰等）。
  - **onDraw(Canvas canvas)** 和 **dispatchDraw(Canvas canvas)**：自定义点，分别用于绘制内容和分发子 View。

Draw 过程从 `performDraw()` 开始，设置状态、调用绘制逻辑，然后处理同步和清理。内部通过 View 的 `draw()` 执行渲染

其中 `performDraw()` 函数如下所示：

```java
private boolean performDraw() {  
    if (mAttachInfo.mDisplayState == Display.STATE_OFF && !mReportNextDraw) {  
        return false;  
    } else if (mView == null) {  
        return false;  
    }  
  
    final boolean fullRedrawNeeded = mFullRedrawNeeded || mSyncBufferCallback != null;  
    mFullRedrawNeeded = false;  
  
    mIsDrawing = true;  
    Trace.traceBegin(Trace.TRACE_TAG_VIEW, "draw");  
  
    addFrameCommitCallbackIfNeeded();  
  
    boolean usingAsyncReport = isHardwareEnabled() && mSyncBufferCallback != null;  
    if (usingAsyncReport) {  
        registerCallbacksForSync(mSyncBuffer, mSyncBufferCallback);  
    } else if (mHasPendingTransactions) {  
        // These callbacks are only needed if there's no sync involved and there were calls to  
        // applyTransactionOnDraw. These callbacks check if the draw failed for any reason and        
        // apply those transactions directly so they don't get stuck forever.        
        registerCallbackForPendingTransactions();  
    }  
    mHasPendingTransactions = false;  
  
    try {  
        boolean canUseAsync = draw(fullRedrawNeeded, usingAsyncReport && mSyncBuffer);  
        if (usingAsyncReport && !canUseAsync) {  
            mAttachInfo.mThreadedRenderer.setFrameCallback(null);  
            usingAsyncReport = false;  
        }  
    } finally {  
        mIsDrawing = false;  
        Trace.traceEnd(Trace.TRACE_TAG_VIEW);  
    }  
  
    // For whatever reason we didn't create a HardwareRenderer, end any  
    // hardware animations that are now dangling    
    if (mAttachInfo.mPendingAnimatingRenderNodes != null) {  
        final int count = mAttachInfo.mPendingAnimatingRenderNodes.size();  
        for (int i = 0; i < count; i++) {  
            mAttachInfo.mPendingAnimatingRenderNodes.get(i).endAllAnimators();  
        }  
        mAttachInfo.mPendingAnimatingRenderNodes.clear();  
    }  
  
    if (mReportNextDraw) {  
  
        // if we're using multi-thread renderer, wait for the window frame draws  
        if (mWindowDrawCountDown != null) {  
            try {  
                mWindowDrawCountDown.await();  
            } catch (InterruptedException e) {  
                Log.e(mTag, "Window redraw count down interrupted!");  
            }  
            mWindowDrawCountDown = null;  
        }  
  
        if (mAttachInfo.mThreadedRenderer != null) {  
            mAttachInfo.mThreadedRenderer.setStopped(mStopped);  
        }  
  
        if (LOCAL_LOGV) {  
            Log.v(mTag, "FINISHED DRAWING: " + mWindowAttributes.getTitle());  
        }  
  
        if (mSurfaceHolder != null && mSurface.isValid()) {  
            final SurfaceSyncer.SyncBufferCallback syncBufferCallback = mSyncBufferCallback;  
            SurfaceCallbackHelper sch = new SurfaceCallbackHelper(() ->  
                    mHandler.post(() -> syncBufferCallback.onBufferReady(null)));  
            mSyncBufferCallback = null;  
  
            SurfaceHolder.Callback callbacks[] = mSurfaceHolder.getCallbacks();  
  
            sch.dispatchSurfaceRedrawNeededAsync(mSurfaceHolder, callbacks);  
        } else if (!usingAsyncReport) {  
            if (mAttachInfo.mThreadedRenderer != null) {  
                mAttachInfo.mThreadedRenderer.fence();  
            }  
        }  
    }  
    if (mSyncBufferCallback != null && !usingAsyncReport) {  
        mSyncBufferCallback.onBufferReady(null);  
    }  
    if (mPerformContentCapture) {  
        performContentCaptureInitialReport();  
    }  
    return true;  
}
```

#### 3.1. 初始化和条件检查

```java
private boolean performDraw() {
    if (mAttachInfo.mDisplayState == Display.STATE_OFF && !mReportNextDraw) {
        return false;
    } else if (mView == null) {
        return false;
    }

    final boolean fullRedrawNeeded = mFullRedrawNeeded || mSyncBufferCallback != null;
    mFullRedrawNeeded = false;

    mIsDrawing = true;
    Trace.traceBegin(Trace.TRACE_TAG_VIEW, "draw");
    
    // ... 

}
```

如果显示器关闭（STATE_OFF）且无报告需求，或根 View（mView）为空，直接返回 false（不绘制）

接着，初始化**全重绘标志**：
- fullRedrawNeeded 表示是否需要完整重绘
- mFullRedrawNeeded 来自 invalidate()，或有同步缓冲回调

**状态设置**：mIsDrawing = true 表示绘制中；Trace 开始性能追踪。

上述操作确保了绘制前提条件，防止无效操作。

#### 3.2. 回调和事务

添加帧提交回调，确保帧完成时通知，同时处理异步报告和挂起事务，解决多线程渲染和缓冲同步，确保绘制不丢失事务

```java
addFrameCommitCallbackIfNeeded();

boolean usingAsyncReport = isHardwareEnabled() && mSyncBufferCallback != null;
if (usingAsyncReport) {
    registerCallbacksForSync(mSyncBuffer, mSyncBufferCallback);
} else if (mHasPendingTransactions) {
    registerCallbackForPendingTransactions();
}
mHasPendingTransactions = false;
```

**事务处理**：
- **异步报告**：如果硬件加速启用且有同步缓冲（mSyncBufferCallback），注册同步回调（registerCallbacksForSync()）。
- **挂起事务**：如果有未处理事务（mHasPendingTransactions，如动画），注册回调直接应用它们，防止卡住。

#### 4.3. 实际绘制

调用 `draw()` 进行实际的绘制
- **参数**：fullRedrawNeeded（是否全重绘），usingAsyncReport && mSyncBuffer（异步缓冲标志）。
- **返回**： canUseAsync，表示是否成功使用异步。

```java
try {
    boolean canUseAsync = draw(fullRedrawNeeded, usingAsyncReport && mSyncBuffer);
    if (usingAsyncReport && !canUseAsync) {
        mAttachInfo.mThreadedRenderer.setFrameCallback(null);
        usingAsyncReport = false;
    }
} finally {
    mIsDrawing = false;
    Trace.traceEnd(Trace.TRACE_TAG_VIEW);
}
```

> 里的 `draw()` 是 ViewRootImpl 的内部方法（非 View 的 draw()），它设置 Canvas，然后调用根 View 的 `draw(canvas)`

#### 3.4.  处理挂起动画和报告下一绘制

结束所有 pending RenderNode 的动画，清除列表。

同时如果设置，等待窗口帧完成（await()），停止渲染器，处理 SurfaceHolder 回调，或使用 fence() 同步

```java
if (mAttachInfo.mPendingAnimatingRenderNodes != null) {
    // 处理挂起动画节点
    final int count = mAttachInfo.mPendingAnimatingRenderNodes.size();  
	for (int i = 0; i < count; i++) {  
	    mAttachInfo.mPendingAnimatingRenderNodes.get(i).endAllAnimators();  
	}  
	mAttachInfo.mPendingAnimatingRenderNodes.clear();
}

if (mReportNextDraw) {
    if (mWindowDrawCountDown != null) {
        mWindowDrawCountDown.await();
    }
    if (mAttachInfo.mThreadedRenderer != null) {
        mAttachInfo.mThreadedRenderer.setStopped(mStopped);
    }
    if (mSurfaceHolder != null && mSurface.isValid()) {
        // 处理 SurfaceHolder 回调
    } else if (!usingAsyncReport) {
        if (mAttachInfo.mThreadedRenderer != null) {
            mAttachInfo.mThreadedRenderer.fence();
        }
    }
}
if (mSyncBufferCallback != null && !usingAsyncReport) {
    mSyncBufferCallback.onBufferReady(null);
}

// 内容捕获：如果启用，报告初始内容（用于无障碍服务）
if (mPerformContentCapture) {
    performContentCaptureInitialReport();
}
return true;
```

确保绘制后同步和清理，防止资源泄漏。

#### 3.5. `draw(canvas)`

Draw 过程主要在 View 的 draw() 方法中执行。分为优化路径（无渐变边缘）和完整路径（有渐变边缘）两个分支，此处重点介绍前者

```java
/**  
 * Manually render this view (and all of its children) to the given Canvas. 
 * The view must have already done a full layout before this function is 
 * called.  When implementing a view, implement 
 * {@link #onDraw(android.graphics.Canvas)} instead of overriding this method.  
 * If you do need to override this method, call the superclass version. 
 * @param canvas The Canvas to which the View is rendered.  
 */
@CallSuper  
public void draw(Canvas canvas) {  
    final int privateFlags = mPrivateFlags;  
    mPrivateFlags = (privateFlags & ~PFLAG_DIRTY_MASK) | PFLAG_DRAWN;  
  
    /*  
     * Draw traversal performs several drawing steps which must be executed     
     * in the appropriate order:     
     * 1. Draw the background     
     * 2. If necessary, save the canvas' layers to prepare for fading    
     * 3. Draw view's content     
     * 4. Draw children     
     * 5. If necessary, draw the fading edges and restore layers     
     * 6. Draw decorations (scrollbars for instance)     
     * 7. If necessary, draw the default focus highlight     
     * */  
    
    // Step 1, draw the background, if needed    int saveCount;  
  
    drawBackground(canvas);  
  
    // skip step 2 & 5 if possible (common case)  
    final int viewFlags = mViewFlags;  
    boolean horizontalEdges = (viewFlags & FADING_EDGE_HORIZONTAL) != 0;  
    boolean verticalEdges = (viewFlags & FADING_EDGE_VERTICAL) != 0;  
    if (!verticalEdges && !horizontalEdges) {  
        // Step 3, draw the content  
        onDraw(canvas);  
  
        // Step 4, draw the children  
        dispatchDraw(canvas);  
  
        drawAutofilledHighlight(canvas);  
  
        // Overlay is part of the content and draws beneath Foreground  
        if (mOverlay != null && !mOverlay.isEmpty()) {  
            mOverlay.getOverlayView().dispatchDraw(canvas);  
        }  
  
        // Step 6, draw decorations (foreground, scrollbars)  
        onDrawForeground(canvas);  
  
        // Step 7, draw the default focus highlight  
        drawDefaultFocusHighlight(canvas);  
  
        if (isShowingLayoutBounds()) {  
            debugDrawFocus(canvas);  
        }  
  
        // we're done...  
        return;  
    }  
  
    // full fledged routine...
```

**标志位更新**：清除脏标志（PFLAG_DIRTY_MASK，表示需要重绘），设置已绘制标志（PFLAG_DRAWN）。这标记 View 已渲染，防止重复绘制，确保 invalidate() 后只绘制变化部分

```java
final int privateFlags = mPrivateFlags;
mPrivateFlags = (privateFlags & ~PFLAG_DIRTY_MASK) | PFLAG_DRAWN;
```

**步骤1: 绘制背景**（drawBackground()）

```java
drawBackground(canvas);
```

- **核心方法**：drawBackground() 处理背景 Drawable 的渲染。

  ```java
  private void drawBackground(Canvas canvas) {
	  // 如果无背景，直接返回
      final Drawable background = mBackground;
      if (background == null) {
          return;
      }
      
      // 设置背景边界
      setBackgroundBounds();
      
      // 硬件加速优化
      if (canvas.isHardwareAccelerated() && mAttachInfo != null && mAttachInfo.mThreadedRenderer != null) {
          mBackgroundRenderNode = getDrawableRenderNode(background, mBackgroundRenderNode);
          final RenderNode renderNode = mBackgroundRenderNode;
          if (renderNode != null && renderNode.hasDisplayList()) {
              setBackgroundRenderNodeProperties(renderNode);
              ((RecordingCanvas) canvas).drawRenderNode(renderNode);
              return;
          }
      }

	  // 考虑滚动偏移（mScrollX/mScrollY），平移 Canvas
      final int scrollX = mScrollX;
      final int scrollY = mScrollY;
      if ((scrollX | scrollY) == 0) {
          background.draw(canvas);
      } else {
          canvas.translate(scrollX, scrollY);
          background.draw(canvas);
          canvas.translate(-scrollX, -scrollY);
      }
  }
  ```

**检查渐变边缘并选择路径**

渐变边缘（fading edges）是如 ListView 的边缘淡出效果。如果无渐变（常见情况），跳过复杂计算，直接进入简单绘制

```java
final int viewFlags = mViewFlags;
boolean horizontalEdges = (viewFlags & FADING_EDGE_HORIZONTAL) != 0;
boolean verticalEdges = (viewFlags & FADING_EDGE_VERTICAL) != 0;
if (!verticalEdges && !horizontalEdges) {
    // 优化路径
} else {
    // 完整路径（处理渐变）
}
```

**优化路径的绘制步骤**

**步骤3: 绘制内容（onDraw()）**

```java
  onDraw(canvas);
```

默认实现为空：

```java
    protected void onDraw(Canvas canvas) {
    }
 ```

开发者需重写绘制 View 特定内容，如 Canvas.drawText()（文本）、drawBitmap()（图像）或 drawRect()（形状）

> **注意**：避免分配内存（如 new Paint()），使用缓存以防卡顿。

**步骤4: 绘制子 View（dispatchDraw()）**

```java
  dispatchDraw(canvas);
```

默认实现为空：

```java
    protected void dispatchDraw(Canvas canvas) {
    }
```
  
  ViewGroup 重写，递归调用每个子 View 的 draw(canvas)，确保子 View 在父内容之上渲染，形成层级。

**绘制 autofill 高亮和叠加层**

```java
  drawAutofilledHighlight(canvas);
  if (mOverlay != null && !mOverlay.isEmpty()) {
      mOverlay.getOverlayView().dispatchDraw(canvas);
  }
```
  -  autofill 高亮：为自动填充字段（如输入框）添加视觉提示。
  - Overlay：绘制叠加内容（如临时视图），在前景之下。

**步骤6: 绘制装饰（onDrawForeground()）**

```java
  onDrawForeground(canvas);
```
  
  绘制前景 Drawable、滚动条等装饰。ViewGroup 可重写以添加自定义装饰。


**步骤7: 绘制默认焦点高亮**

```java
  drawDefaultFocusHighlight(canvas);
  if (isShowingLayoutBounds()) {
      debugDrawFocus(canvas);
  }
```

如果 View 聚焦，绘制默认高亮矩形。调试模式下绘制布局边界。
### 四、原理与底层机制

View 绘制不仅仅是方法调用，还涉及 Android 的渲染管道和系统级机制

1. **ViewRootImpl 与 Choreographer**：
   - **ViewRootImpl**：作为 WindowManager 和 DecorView 的桥梁，管理整个视图树的绘制。通过 performTraversals() 响应更新请求。
   - **Choreographer**：处理 VSYNC（垂直同步）信号（通常 60Hz），确保绘制与屏幕刷新同步。收到 VSYNC 后，通过 Handler 调用 doFrame()，进而执行 performTraversals()。这防止了画面撕裂和掉帧。

2. **消息循环机制**：
   - UI 主线程使用 Handler 和 MessageQueue 处理绘制任务。invalidate() 会标记 View 为“脏”并插入重绘消息；requestLayout() 会触发完整流程。
   - 非 UI 线程可使用 postInvalidate() 异步请求重绘。

3. **双缓冲与 SurfaceFlinger**：
   - **双缓冲**：每个 Window 使用 Surface（包含 Front Buffer 用于显示，Back Buffer 用于绘制）。绘制在 Back Buffer 完成后再交换，减少闪烁。
   - **SurfaceFlinger**：Android 的合成器，负责将多个 Surface（窗口）的内容合成最终帧，并提交给显示硬件（如屏幕）。这涉及 OpenGL ES 或 Vulkan 等图形 API。

这些机制确保了高效的渲染管道，从应用层到硬件层的无缝协作。

