
EventBus 是一款用在 Android 开发中的发布/订阅事件总线框架，基于观察者模式，将事件的接收者和发送者分开，简化了组件之间的通信操作，使用简单、效率高、体积小


![[EventBus_发布订阅示意.png]]

### 一、使用

**安装依赖**：在gradle配置中导入 EventBus 依赖

```groovy
implementation 'org.greenrobot:eventbus:3.1.1'
```

**定义事件类**：包含事件需要传递的字段

```java
public class MessageEvent {
    /* 自定义事件字段 */
}
```

如果是内部类，最好声明为静态内部类

**注册订阅方法**：使用 @Subscribe 注解修饰处理消息的方法 ,

> **注**：该方法必须是 public void 修饰的 , 只有一个参数 , 参数类型随意 , 除了是包装好的事件类以外也可以是一些基本的类型 ;

```java
@Subscribe(threadMode = ThreadMode.MAIN)  
public void onMessageEvent(MessageEvent event) {
    /* 事件处理逻辑 */
}
```

**生命周期绑定**：一般的在onStart函数中注册订阅事件，然后再onStop函数中取消订阅事件

```java
@Override
public void onStart() {
    super.onStart();
    EventBus.getDefault().register(this);
}

@Override
public void onStop() {
    super.onStop();
    EventBus.getDefault().unregister(this);
}
```

**发送事件**：调用 `post()` 函数将处理完成的数据发送出去
```java
EventBus.getDefault().post(new MessageEvent());
```


### 二、原理

#### 2.1.  @Subscribe 注解

```java
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Subscribe {


	// 指定事件订阅方法的线程模式，即在那个线程执行事件订阅方法处理事件，默认为POSTING
    ThreadMode threadMode() default ThreadMode.POSTING;
    
    // 是否是粘性事件
    boolean sticky() default false; 

	// 指定事件订阅方法的优先级，默认为0，如果多个事件订阅方法可以接收相同事件的，则优先级高的先接收到事件
    int priority() default 0;
}
```

其中，常见的**线程模式**如下所示：

| 模式           | 执行线程 | 队列机制                                                                             | 适用场景   |
| ------------ | ---- | -------------------------------------------------------------------------------- | ------ |
| POSTING      | 发送线程 | 在那个线程发送事件就在对应线程处理事件                                                              | 实时性要求高 |
| MAIN         | 主线程  | 如在主线程（UI线程）发送事件，则直接在主线程处理事件；<br>如在子线程发送事件，将事件入队列后通过 Handler 切到主线程，依次处理(Looper队列) | UI更新   |
| MAIN_ORDERED | 主线程  | 无论那个线程发送，都先将事件入队列，然后通过 Handler 切换到主线程，依次处理事件                                     | 顺序保障   |
| BACKGROUND   | 子线程  | 如果在主线程发送事件，则先将事件入队列，然后通过线程池依次处理事件<br>如果在子线程发送事件，则直接在发送事件的线程处理事件                  | IO操作   |
| ASYNC        | 异步线程 | 无论在那个线程发送事件，都将事件入队列，然后通过线程池处理                                                    | 耗时任务   |

#### 2.2. 创建实例

```java
// 单例获取
EventBus.getDefault().register(this);

// 双检锁单例实现
public static EventBus getDefault() {
    if(defaultInstance == null) {
        synchronized(EventBus.class) {
            if(defaultInstance == null) {
                defaultInstance = new EventBus();
            }
        }
    }
    return defaultInstance;
}
```

getDefault()最终调用了new EventBus()，如下：

```java
public EventBus() {
        this(DEFAULT_BUILDER);
    }
```

然后，EventBus调用它的另一个构造函数来完成它相关属性的初始化：

```Java
EventBus(EventBusBuilder builder) {
        logger = builder.getLogger();

		// 核心数据存储
		// 事件类型 → 订阅者列表的映射
        subscriptionsByEventType = new HashMap<>();

		// 订阅者 → 事件类型集合的映射
        typesBySubscriber = new HashMap<>();
        
        // 存储粘性事件
        stickyEvents = new ConcurrentHashMap<>();

		// 线程调度组件
		// 判断当前环境是否支持主线程（Android 主线程 Looper），非 Android 环境可能返回 null
        mainThreadSupport = builder.getMainThreadSupport();
        
        // 将事件从子线程切换到主线程处理（用于 MAIN 和 MAIN_ORDERED 线程模式）
        mainThreadPoster = mainThreadSupport != null ? mainThreadSupport.createPoster(this) : null;
        
        // 在后台线程池中处理事件（用于 BACKGROUND 模式）
        backgroundPoster = new BackgroundPoster(this);
        
        // 在独立线程池中异步处理事件（用于 ASYNC 模式）
        asyncPoster = new AsyncPoster(this);
	    
        // 订阅方法发现与索引
        indexCount = builder.subscriberInfoIndexes != null ? builder.subscriberInfoIndexes.size() : 0;
        subscriberMethodFinder = new SubscriberMethodFinder(builder.subscriberInfoIndexes,
                builder.strictMethodVerification, builder.ignoreGeneratedIndex);
        
        // 异常与日志控制
        logSubscriberExceptions = builder.logSubscriberExceptions;
        logNoSubscriberMessages = builder.logNoSubscriberMessages;
        sendSubscriberExceptionEvent = builder.sendSubscriberExceptionEvent;
        sendNoSubscriberEvent = builder.sendNoSubscriberEvent;
        throwSubscriberException = builder.throwSubscriberException;
        
        // 其它
        eventInheritance = builder.eventInheritance;
        executorService = builder.executorService;
    }
```

其中，DEFAULT_BUILDER就是一个默认的EventBusBuilder，如下：

```Java
private static final EventBusBuilder DEFAULT_BUILDER = new EventBusBuilder();
```

如果有需要的话，我们也可以通过配置EventBusBuilder来更改EventBus的属性，例如：

```Java
EventBus.builder()
        .eventInheritance(false)
        .logSubscriberExceptions(false)
        .build()
        .register(this);
```


#### 2.3. **注册**

**调用入口**：通过 `register()` 函数进行注册

```java
EventBus.getDefault().register(subscriber);
```

**核心步骤**  
   - **反射扫描**：查找 `@Subscribe` 注解方法  
   - **缓存优化**：使用 `METHOD_CACHE` 避免重复反射  
   - **优先级排序**：按 `priority` 维护订阅者队列  
   - **粘性事件处理**：注册时立即触发已存在的粘性事件  

**方法扫描阶段** `findSubscriberMethods()`

扫描当前类及其父类（除非配置 `skipSuperClasses`）的方法，筛选出满足如下条件的方法
- `public` 非静态方法  
- 有且仅有一个参数  
- 带有 `@Subscribe` 注解  

```java
List<SubscriberMethod> findSubscriberMethods(Class<?> subscriberClass) {
    // 检查缓存
    if (METHOD_CACHE.contains(subscriberClass)) {
        return METHOD_CACHE.get(subscriberClass);
    }
    
    // 反射或注解处理器查找
    List<SubscriberMethod> methods = ignoreGeneratedIndex ? 
        findUsingReflection(subscriberClass) : 
        findUsingInfo(subscriberClass);
    
    // 缓存结果
    METHOD_CACHE.put(subscriberClass, methods);
    return methods;
}
```

**双级缓存加速**：通过缓存订阅方法以及建立事件和订阅者的映射的方式极大的加速了查找速度 
   - `METHOD_CACHE`：类级别订阅方法缓存  
   - `subscriptionsByEventType`：事件类型→订阅者列表  

**订阅绑定** `subscribe()`

```java
```text
private void subscribe(Object subscriber, SubscriberMethod subscriberMethod) {
        
        // 得到当前订阅了事件的方法的参数类型
        Class<?> eventType = subscriberMethod.eventType;
        
        // Subscription类保存了要注册的类对象以及当前的subscriberMethod
        Subscription newSubscription = new Subscription(subscriber, subscriberMethod);
        
        // subscriptionsByEventType是一个HashMap，保存了以eventType为key,Subscription对象集合为value的键值对
        // 先查找subscriptionsByEventType是否存在以当前eventType为key的值
        CopyOnWriteArrayList<Subscription> subscriptions = subscriptionsByEventType.get(eventType);
        
        // 如果不存在，则创建一个subscriptions，并保存到subscriptionsByEventType
        if (subscriptions == null) {
            subscriptions = new CopyOnWriteArrayList<>();
            subscriptionsByEventType.put(eventType, subscriptions);
        } else {
            if (subscriptions.contains(newSubscription)) {
                throw new EventBusException("Subscriber " + subscriber.getClass() + " already registered to event "
                        + eventType);
            }
        }
        
        // 添加上边创建的newSubscription对象到subscriptions中
        int size = subscriptions.size();
        for (int i = 0; i <= size; i++) {
            if (i == size || subscriberMethod.priority > subscriptions.get(i).subscriberMethod.priority) {
                subscriptions.add(i, newSubscription);
                break;
            }
        }
        
        // typesBySubscribere也是一个HashMap，保存了以当前要注册类的对象为key，注册类中订阅事件的方法的参数类型的集合为value的键值对
        // 查找是否存在对应的参数类型集合
        List<Class<?>> subscribedEvents = typesBySubscriber.get(subscriber);
        
        // 不存在则创建一个subscribedEvents，并保存到typesBySubscriber
        if (subscribedEvents == null) {
            subscribedEvents = new ArrayList<>();
            typesBySubscriber.put(subscriber, subscribedEvents);
        }
        
        // 保存当前订阅了事件的方法的参数类型
        subscribedEvents.add(eventType);
        
        // 粘性事件相关的
        if (subscriberMethod.sticky) {
            if (eventInheritance) {
                Set<Map.Entry<Class<?>, Object>> entries = stickyEvents.entrySet();
                for (Map.Entry<Class<?>, Object> entry : entries) {
                    Class<?> candidateEventType = entry.getKey();
                    if (eventType.isAssignableFrom(candidateEventType)) {
                        Object stickyEvent = entry.getValue();
                        checkPostStickyEventToSubscription(newSubscription, stickyEvent);
                    }
                }
            } else {
                Object stickyEvent = stickyEvents.get(eventType);
                checkPostStickyEventToSubscription(newSubscription, stickyEvent);
            }
        }
    }
```

![[EventBus_事件注册.png]]

#### 2.4. 取消注册

**调用**：通过 `unregister()` 函数进行取消注册

```Java
EventBus.getDefault().unregister(this);
```

其中，unregister()的源码如下：

```Java
public synchronized void unregister(Object subscriber) {
        
        // 得到当前注册类对象 对应的 订阅事件方法的参数类型 的集合
        List<Class<?>> subscribedTypes = typesBySubscriber.get(subscriber);
        
        if (subscribedTypes != null) {
            // 遍历参数类型集合，释放之前缓存的当前类中的Subscription
            for (Class<?> eventType : subscribedTypes) {
                unsubscribeByEventType(subscriber, eventType);
            }
            
            // 删除以subscriber为key的键值对
            typesBySubscriber.remove(subscriber);
        } else {
            logger.log(Level.WARNING, "Subscriber to unregister was not registered before: " + subscriber.getClass());
        }
    }
```

unregister()方法调用了unsubscribeByEventType()方法：

```Java
private void unsubscribeByEventType(Object subscriber, Class<?> eventType) {
        // 得到当前参数类型对应的Subscription集合
        List<Subscription> subscriptions = subscriptionsByEventType.get(eventType);
        if (subscriptions != null) {
            int size = subscriptions.size();
            // 遍历Subscription集合
            for (int i = 0; i < size; i++) {
                Subscription subscription = subscriptions.get(i);
                // 如果当前subscription对象对应的注册类对象 和 要取消注册的注册类对象相同，则删除当前subscription对象
                if (subscription.subscriber == subscriber) {
                    subscription.active = false;
                    subscriptions.remove(i);
                    i--;
                    size--;
                }
            }
        }
    }
```

所以，在unregister()方法中，最主要的就是释放typesBySubscriber、subscriptionsByEventType中缓存的资源

#### 2.5. 事件的发送与处理

**调用**：通过 `post()` 函数发送事件

```java
EventBus.getDefault().post("Hello World!")
```

其中，`post()` 方法的源码如下：

```java
public void post(Object event) {

        // currentPostingThreadState是一个PostingThreadState类型的ThreadLocal
        // PostingThreadState类保存了事件队列和线程模式等信息
        PostingThreadState postingState = currentPostingThreadState.get();
        List<Object> eventQueue = postingState.eventQueue;
        
        // 将要发送的事件添加到事件队列
        eventQueue.add(event);
        
        // isPosting默认为false
        if (!postingState.isPosting) {
            // 是否为主线程
            postingState.isMainThread = isMainThread();
            postingState.isPosting = true;
            if (postingState.canceled) {
                throw new EventBusException("Internal error. Abort state was not reset");
            }
            try {
                // 遍历事件队列
                while (!eventQueue.isEmpty()) {
                    // 发送单个事件
                    // eventQueue.remove(0)，从事件队列移除事件
                    postSingleEvent(eventQueue.remove(0), postingState);
                }
            } finally {
                postingState.isPosting = false;
                postingState.isMainThread = false;
            }
        }
    }
```

可以发现，在发送者调用 `post()` 函数后会先获取当前线程状态并将事件加入队列。

若线程不在正在分发的状态，则启动分发循环，处理队列中的每一个事件，将事件交给postSingleEvent()方法处理

```java
private void postSingleEvent(Object event, PostingThreadState postingState) throws Error {
        Class<?> eventClass = event.getClass();
        boolean subscriptionFound = false;
        // eventInheritance默认为true，表示是否向上查找事件的父类
        if (eventInheritance) {
            // 查找当前事件类型的Class，连同当前事件类型的Class保存到集合
            List<Class<?>> eventTypes = lookupAllEventTypes(eventClass);
            int countTypes = eventTypes.size();
            // 遍历Class集合，继续处理事件
            for (int h = 0; h < countTypes; h++) {
                Class<?> clazz = eventTypes.get(h);
                subscriptionFound |= postSingleEventForEventType(event, postingState, clazz);
            }
        } else {
            subscriptionFound = postSingleEventForEventType(event, postingState, eventClass);
        }
        if (!subscriptionFound) {
            if (logNoSubscriberMessages) {
                logger.log(Level.FINE, "No subscribers registered for event " + eventClass);
            }
            if (sendNoSubscriberEvent && eventClass != NoSubscriberEvent.class &&
                    eventClass != SubscriberExceptionEvent.class) {
                post(new NoSubscriberEvent(this, event));
            }
        }
    }
```

在上述函数中，先获取了事件对象的class类型

接着通过 `eventInheritance` 变量判断是否要向上查找
 - 当`eventInheritance`为`true`时，EventBus 会查找事件类型的所有父类和接口，使订阅父类或接口的方法也能接收到事件

最后调用 `postSingleEventForEventType()` 方法继续处理

```Java
private boolean postSingleEventForEventType(Object event, PostingThreadState postingState, Class<?> eventClass) {
        CopyOnWriteArrayList<Subscription> subscriptions;
        synchronized (this) {
            // 获取事件类型对应的Subscription集合
            subscriptions = subscriptionsByEventType.get(eventClass);
        }
        // 如果已订阅了对应类型的事件
        if (subscriptions != null && !subscriptions.isEmpty()) {
            for (Subscription subscription : subscriptions) {
                // 记录事件
                postingState.event = event;
                // 记录对应的subscription
                postingState.subscription = subscription;
                boolean aborted = false;
                try {
                    // 最终的事件处理
                    postToSubscription(subscription, event, postingState.isMainThread);
                    aborted = postingState.canceled;
                } finally {
                    postingState.event = null;
                    postingState.subscription = null;
                    postingState.canceled = false;
                }
                if (aborted) {
                    break;
                }
            }
            return true;
        }
        return false;
    }
```

该函数获取了事件所有的订阅者，将事件和订阅者绑定到线程状态，并调用 `postToSubscription` 分发处理事件

```java
private void postToSubscription(Subscription subscription, Object event, boolean isMainThread) {
        // 判断订阅事件方法的线程模式
        switch (subscription.subscriberMethod.threadMode) {
            // 默认的线程模式，在那个线程发送事件就在那个线程处理事件
            case POSTING:
                invokeSubscriber(subscription, event);
                break;
            // 在主线程处理事件
            case MAIN:
                // 如果在主线程发送事件，则直接在主线程通过反射处理事件
                if (isMainThread) {
                    invokeSubscriber(subscription, event);
                } else {
                     // 如果是在子线程发送事件，则将事件入队列，通过Handler切换到主线程执行处理事件
                    // mainThreadPoster 不为空
                    mainThreadPoster.enqueue(subscription, event);
                }
                break;
            // 无论在那个线程发送事件，都先将事件入队列，然后通过 Handler 切换到主线程，依次处理事件。
            // mainThreadPoster 不为空
            case MAIN_ORDERED:
                if (mainThreadPoster != null) {
                    mainThreadPoster.enqueue(subscription, event);
                } else {
                    invokeSubscriber(subscription, event);
                }
                break;
            case BACKGROUND:
                // 如果在主线程发送事件，则先将事件入队列，然后通过线程池依次处理事件
                if (isMainThread) {
                    backgroundPoster.enqueue(subscription, event);
                } else {
                    // 如果在子线程发送事件，则直接在发送事件的线程通过反射处理事件
                    invokeSubscriber(subscription, event);
                }
                break;
            // 无论在那个线程发送事件，都将事件入队列，然后通过线程池处理。
            case ASYNC:
                asyncPoster.enqueue(subscription, event);
                break;
            default:
                throw new IllegalStateException("Unknown thread mode: " + subscription.subscriberMethod.threadMode);
        }
    }
```

`postToSubscription()` 内部会根据订阅事件方法的线程模式，间接或直接的以发送的事件为参数，通过反射执行订阅事件的方法

![[EventBus_线程模式判断.png]]



### 三、粘性事件

粘性事件(Sticky Event)是EventBus中一种特殊的事件处理机制，它允许"先发送事件，后注册订阅者"的反常规操作模式

**核心特点**
1. **事件持久化**：粘性事件会被保存在内存中，直到被新的同类型事件覆盖或显式移除
2. **延迟消费**：即使订阅者在事件发送后才注册，也能收到之前发送的粘性事件
3. **事件继承**：支持父类事件类型接收子类粘性事件


**调用**：我们可以使用 `postSticky()` 发送粘性事件

```java
EventBus.getDefault().postSticky("Hello World!");
```

类似的，使用 `@Subscribe` 注解标记处理消息的方法，同时使用 `register()` 函数进行注册

```java
@Subscribe(sticky = true)
public void onMessageEvent(String event) {
    // 处理事件
}

// 注册订阅者
EventBus.getDefault().register(this);
```

**事件存储**：使用ConcurrentHashMap存储事件类型和事件对象，同步发送到当前已注册的订阅者

```java
   public void postSticky(Object event) {
       synchronized (stickyEvents) {
           stickyEvents.put(event.getClass(), event);
       }
       post(event); // 同时作为普通事件发送
   }
```

**粘性事件分发**：在`register()`过程中会检查是否有匹配的粘性事件，若有，直接调用 `postToSubscription()` 进行分发

   ```java
   private void subscribe(Object subscriber, SubscriberMethod subscriberMethod) {
       if (subscriberMethod.sticky) {
           if (eventInheritance) {
               // 检查所有可能的粘性事件
               Set<Map.Entry<Class<?>, Object>> entries = stickyEvents.entrySet();
               for (Map.Entry<Class<?>, Object> entry : entries) {
                   if (eventType.isAssignableFrom(entry.getKey())) {
                       postToSubscription(/*...*/);
                   }
               }
           } else {
               // 直接查找同类型事件
               Object stickyEvent = stickyEvents.get(eventType);
               postToSubscription(/*...*/);
           }
       }
   }
   ```

3. **事件继承支持**：
   - 当`eventInheritance=true`时，子类订阅者可接收父类粘性事件
   - 通过`isAssignableFrom()`方法判断类型兼容性

**注**：粘性事件会一直保留在内存中，需注意及时清理不再需要的事件
```java
EventBus.getDefault().removeStickyEvent(event);
// 或
EventBus.getDefault().removeAllStickyEvents();
```

**事件更新**：发送同类型新粘性事件会自动覆盖旧事件

**应用**：
- 应用初始化配置的提前加载
- 页面跳转前的数据预加载
- 需要持久化到多个生命周期的事件

