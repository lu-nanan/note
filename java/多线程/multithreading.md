Java 多线程编程
===
---

- [Java 多线程编程](#java-多线程编程)
  - [线程概述](#线程概述)
  - [创建线程的方法](#创建线程的方法)
    - [继承Thread类](#继承thread类)
    - [实现Runnable接口](#实现runnable接口)
    - [匿名内部类创建](#匿名内部类创建)
    - [lambda表达式创建Runnable子类对象](#lambda表达式创建runnable子类对象)
  - [Thread类](#thread类)
    - [常见的构造方法](#常见的构造方法)
    - [常用属性](#常用属性)
    - [`start()`与`run()`的区别](#start与run的区别)
    - [`sleep()`方法](#sleep方法)
    - [`join()`方法](#join方法)
    - [`interrupt()`中断线程](#interrupt中断线程)
    - [`yield()` 让出CPU](#yield-让出cpu)
  - [线程状态](#线程状态)
      - [线程的状态](#线程的状态)
      - [状态转移](#状态转移)
      - [获取线程状态](#获取线程状态)
      - [wait()](#wait)
      - [设置优先级](#设置优先级)
    - [守护线程（Daemon Thread）](#守护线程daemon-thread)
  - [Java 内存模型（JMM）](#java-内存模型jmm)
    - [原子性](#原子性)
    - [可见性](#可见性)
    - [有序性](#有序性)
    - [volatile底层机制——java内存屏障](#volatile底层机制java内存屏障)
      - [内存屏障](#内存屏障)
      - [java内存屏障](#java内存屏障)
  - [无锁](#无锁)
      - [悲观锁与乐观锁](#悲观锁与乐观锁)
      - [CAS](#cas)



## 线程概述

**Java中的线程**
- 基于操作系统原生线程实现（1:1线程模型）
- 通过java.lang.Thread类实现线程控制

**与操作系统中线程概念的区别**
- 实现模型：
  - Java线程通过JVM映射到OS线程
  - 早期Green Threads模型（用户级线程）已弃用
- 调度方式：
  - Java线程优先级建议（1-10）最终映射到OS优先级（通常1-5）
  - 实际调度仍由操作系统决定
- 资源分配：
  - OS线程直接分配CPU时间片
  - Java线程通过JVM分配内存资源（堆/方法区）


**进程和线程的区别**
- 进程是包含线程的. 每个进程至少有⼀个线程存在，即主线程。
- 进程和进程之间不共享内存空间. 同⼀个进程的线程之间共享同⼀个内存空间.
- 进程是系统分配资源的最小单位，线程是系统调度的最小单位。
- ⼀个进程挂了⼀般不会影响到其他进程. 但是⼀个线程挂了, 可能把同进程内的其他线程⼀起带走(整个进程崩溃)

![图 0](images/879760441ac4386ca05474643f21c2f5bfa34d713678f4337287a1c638f6d90d.png)  

## 创建线程的方法

### 继承Thread类
- 继承Thread类，并重写run方法
- 创建子类对象，调用start方法启动线程
- 注意：
  - 线程启动后，会自动调用run方法
  - 线程启动后，不能再次调用start方法

```java
public class threadPr extends Thread  {
	@Override
	public void run() {
		System.out.println("这是一个新建的线程");
	}

	public static void main(String[] args) {
		System.out.println("这是主线程");
		threadPr t = new threadPr();
		t.start();
	}
}
```

### 实现Runnable接口
- 实现Runnable接口，并重写run方法
- 创建实现类对象，将实现类对象作为参数传递给Thread类的构造方法
- 创建Thread类对象，调用start方法启动线程

```java
public class MyRunnable implements Runnable  {
    @Override
    public void run() {
        System.out.println("这是一个新建的线程");
    }


    public static void main(String[] args) {
        System.out.println("这是主线程");
        MyRunnable myRunnable = new MyRunnable();
        Thread thread = new Thread(myRunnable);
        thread.start();
    }
}
```
实现Runnable更灵活，避免单继承限制，适合资源共享。

### 匿名内部类创建

```java
public class Iner {
    public static void main(String[] args) {
        Thread t1 = new Thread() {
            @Override
            public void run() {
                System.out.println("这是新建的线程");
            }
        };
        Thread t2 = new Thread(new Runnable()  {
            @Override
            public void run() {
                System.out.println("这是新建的线程");
            }
        });
        t2.start();
        System.out.println("这是主线程");
        t1.start(); 
    } 
}
```

### lambda表达式创建Runnable子类对象

```java
public class Lambda {
    public static void main(String[] args) {
        System.out.println("这是主线程");
        Thread t = new Thread(() -> {
            System.out.println("这是新建的线程");
        });
        t.start();
    }
}
```

## Thread类
### 常见的构造方法
- `Thread()`：创建一个新的线程对象。
- `Thread(Runnable target)`：使用Runnable对象创建一个新的线程对象。
- `Thread(String name)`：创建一个新的线程对象，并指定线程名称。
- `Thread(Runnable target, String name)`：使用Runnable对象创建一个新的线程对象，并指定线程名称。

### 常用属性
- `String : getName()`：获取线程名称。
- `long : getId()`：获取线程ID。
- `int : getPriority()`：获取线程优先级。
- `boolean : isAlive()`：检查线程是否处于活动状态。
- `boolean : isDaemon()`：检查线程是否为守护线程。
- `boolean : isInterrupted()`：检查线程是否被中断。

### `start()`与`run()`的区别
- `start()`：启动新线程，JVM调用`run()`方法。
- 直接调用`run()`：不会创建新线程，代码在当前线程执行。

```java
public static void main(String[] args) {
    Thread thread = new Thread(() -> {
        System.out.println("当前线程: " + Thread.currentThread().getName());
    });
    thread.start(); // 输出：当前线程: Thread-0
    thread.run();   // 输出：当前线程: main
}
```

### `sleep()`方法
让线程休眠指定时间（毫秒），期间线程处于`TIMED_WAITING`状态。

```java
class SleepExample extends Thread {
    @Override
    public void run() {
        try {
            for (int i = 3; i > 0; i--) {
                System.out.println(i);
                Thread.sleep(1000); // 暂停1秒
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

### `join()`方法
等待线程终止。例如，主线程等待子线程完成：

```java
public class Main {
    public static void main(String[] args) throws InterruptedException {
        Thread thread = new Thread(() -> {
            try {
                Thread.sleep(2000);
                System.out.println("子线程完成");
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        });
        thread.start();
        thread.join(); // 主线程等待子线程结束
        System.out.println("主线程继续执行");
    }
}
```

### `interrupt()`中断线程
通过中断标志位终止线程。若线程在阻塞状态（如`sleep()`），会抛出`InterruptedException`。

```java
class InterruptExample extends Thread {
    @Override
    public void run() {
        try {
            while (!isInterrupted()) {
                System.out.println("运行中...");
                Thread.sleep(1000);
            }
        } catch (InterruptedException e) {
            System.out.println("线程被中断");
        }
    }
}

public class Main {
    public static void main(String[] args) throws InterruptedException {
        InterruptExample thread = new InterruptExample();
        thread.start();
        Thread.sleep(3000);
        thread.interrupt(); // 中断线程
    }
}
```
### `yield()` 让出CPU

yield 不会改变线程的状态，但会使当前线程让出CPU资源，让其他具有相同或更高优先级的线程运行，让当前线程重新去排队
调用 yield() 方法并不会释放锁或者阻塞当前线程，它只是暂停当前线程的执行，并允许其他线程获得执行。当当前线程被重新调度时，它将继续执行，但并不能保证它会立即被调度。

但是，调用 yield() 方法并不能保证其他线程会获得执行，因为调度器可以选择忽略 yield() 方法的调用。过度使用 yield() 方法可能会导致性能问题，因为频繁的调用 yield() 方法可能会导致线程频繁地切换，从而降低系统的性能。

```java
public class YieldExample {
    public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new Runnable() {
            @Override
            public void run() {
                while (true) {
                      System.out.println("张三");
                      Thread.yield();
              }
            }
        }, "t1");
        
        t1.start();
        
        Thread t2 = new Thread(new Runnable() {
          @Override
            public void run() {
                while (true) {
                      System.out.println("李四");
                }
            }
        }, "t2");
        t2.start();
    }
}
```

## 线程状态

#### 线程的状态

- **NEW**：系统中的线程还没创建出来，只是有了一个 Thread 对象（已经安排好了工作，但是还未开始行动）。
- **TERMINATED**：系统中的线程已经执行完了，但 Thread 对象还在（工作已经完成了）。
- **RUNNABLE**：就绪状态，有两种可能的情况
  - 线程正在CPU上运行
  - 线程已经准备好随时可以去CPU上运行
 （表示“可工作的”状态；又可以分成正在工作中和即将开始工作）。
- **TIMED_WAITING**：线程正在“指定时间等待”，表示线程在有限时地等待唤醒（等待其它线程发来通知）。一个典型的状况就是线程正在休眠sleep()。
- **BLOCKED**：表示等待获取锁的状态。
- **WAITING**：使用 `wait()` 方法出现，表示线程在无限时等待唤醒（等待其它线程发来通知）。

#### 状态转移

![图 0](images/5d57a228e3d059962ae0413807c7342e180b09097ea73cf4564e95b8cbb84f68.png)  


#### 获取线程状态

通过`getState()`方法获取线程状态。

```java
Thread thread = new Thread(() -> {
    try {
        Thread.sleep(1000);
    } catch (InterruptedException e) {
        e.printStackTrace();
    }
});
System.out.println(thread.getState()); // NEW
thread.start();
System.out.println(thread.getState()); // RUNNABLE
Thread.sleep(500);
System.out.println(thread.getState()); // TIMED_WAITING
```

#### wait()

在Java中，线程必须持有对象的锁才能调用 wait() 方法。当线程调用 wait() 方法时，它会释放当前持有的锁，并将自己挂起，直到被其他线程唤醒。一旦线程调用了 wait() 方法并释放了锁，其他线程就可以获取该对象的锁并继续执行同步块中的代码。当该线程被唤醒（notify）时，它会重新尝试获取对象的锁并恢复执行。但是，在其它线程未释放锁之前该线程仍然会被阻塞。一旦它获得了对象的锁，它才可以继续执行同步块中的代码。

#### 设置优先级
优先级范围：1（最低）~10（最高），默认5。

```java
Thread thread1 = new Thread(() -> System.out.println("低优先级"));
Thread thread2 = new Thread(() -> System.out.println("高优先级"));
thread1.setPriority(Thread.MIN_PRIORITY); // 1
thread2.setPriority(Thread.MAX_PRIORITY); // 10
thread1.start();
thread2.start();
```

### 守护线程（Daemon Thread）
守护线程在后台运行，JVM在所有非守护线程结束后自动退出。

```java
Thread daemonThread = new Thread(() -> {
    while (true) {
        System.out.println("守护线程运行中...");
    }
});
daemonThread.setDaemon(true); // 设置为守护线程
daemonThread.start();
// 主线程结束后，守护线程自动终止
```

## Java 内存模型（JMM）

Java虚拟机规范中定义的，来屏蔽各个硬件平台和操作系统的内存访问差异，以实现让Java程序在各种平台下都能达到一致的内存访问效果的一种规范。

![图 1](images/f7f4fe66dfcf2eb55568d3578369dfa8fdeed407222c42216286d420ad4e0f06.png)  

Java内存模型规定所有的变量都是存在主存当中，每个线程都有自己的工作内存。线程的工作内存中保存了该线程中使用到的变量的主内存副本拷贝，线程对变量的所有操作都必须在工作内存中进行，而不能直接对主存进行操作。并且每个线程不能访问其他线程的工作内存，线程之间的通信递需要经过主内存。

和内存模型一样，java内存模型中同样存在原子性，可见性，有序性等问题

### 原子性

在Java中，对基本数据类型的变量的读取和赋值操作是原子性操作，即这些操作是不可被中断的，要么执行，要么不执行

```java
x = 1; // 原子性操作
x = y; // 非原子性操作（读y + 赋值）
```
如果要实现更大范围操作的原子性，可以通过synchronized和Lock来实现

### 可见性

Java提供了 **`volatile`** 关键字来保证可见性。

当一个共享变量被`volatile`修饰时，它会保证修改的值会立即被更新到主存，当有其他线程需要读取时，它会去内存中读取新值，并且会让其它线程对于该变量的缓存失效。

在对volatile修饰的变量做写操作时，jvm会给CPU发送lock前缀指令，强制要求在写操作结束后将修改的值写回主存，然后根据缓存一致性协议，其他线程的工作内存中该变量的缓存失效，从而保证了可见性。

### 有序性

Java内存模型具备一些先天的“有序性”，即不需要通过任何手段就能够得到保证的有序性，这个通常也称为 happens-before（先行发生） 原则。如果两个操作的执行次序无法从happens-before原则推导出来，那么它们就不能保证它们的有序性，虚拟机可以随意地对它们进行重排序。

注意：A happens-before B并不要求A操作一定要在B操作之前，而是说A操作后的结果对B操作是可见的，即如果A操作将a的值修改为1，那么B操作在用到a的值的时候已经知道了a的值为1。


### volatile底层机制——java内存屏障

#### 内存屏障

内存屏障（Memory Barrier）是一种CPU指令，用于控制特定条件下的重排序和内存可见性问题。

**分类**

读屏障（Load Barrier）：
   在指令前插入Load Barrier，可以让高速缓存中的数据失效，强制从新从主内存加载数据。

写屏障（Store Barrier）：
  在指令后插入Store Barrier，能让写入缓存中的最新数据更新写入主内存，让其他线程可见。

**作用**：

- 阻止屏障两侧的指令重排序。

- 强制把写缓冲区/高速缓存中的脏数据等写回主内存，让缓存中相应的数据失效。

#### java内存屏障

同样，Java虚拟机为java程序运行时提供了java内存屏障。

java内存屏障有四种类型

- **LoadLoad屏障**：对于这样的语句Load1； LoadLoad；Load2，在Load2及后续读取操作要读取的数据被访问前，保证Load1要读取的数据被读取完毕。
- **StoreStore屏障**：对于这样的语句Store1；StoreStore；Store2，在Store2及后续写入操作执行前，保证Store1的写入操作对其它处理器可见。
- **LoadStore屏障**：对于这样的语句Load1；LoadStore；Store2，在Store2及后续写入操作被刷出前，保证Load1要读取的数据被读取完毕。
- **StoreLoad屏障**：对于这样的语句Store1；StoreLoad；Load2，在Load2及后续所有读取操作执行前，保证Store1的写入对所有处理器可见。它的开销是四种屏障中最大的。在大多数处理器的实现中，这个屏障是个万能屏障，兼具其它三种内存屏障的功能。

**volatile语义中的内存屏障**：

- 在每个volatile写操作前插入StoreStore屏障，在写操作后插入StoreLoad屏障；

- 在每个volatile读操作前插入LoadLoad屏障，在读操作后插入LoadStore屏障；

## 无锁
#### 悲观锁与乐观锁

**悲观锁**

一种悲观的思想，总是假设最坏的情况，每次去拿数据的时候都认为别人会修改

每次在拿数据的时候都会上锁，这样别人想拿这个数据就会阻塞直到它拿到锁

**乐观锁**

一种乐观的的思想，每次取数据都假设别人不会修改，所以不会上锁。

当需要更新数据时，会检测这个数据是否已经被其他人更新了，如果已经被别人更新过了，就返回让用户自己选择怎么处理。乐观锁适用于读多写少的场景。

**java解决临界区代码安全问题的办法**：

- 阻塞式方法：使用synchronized或者Lock进行加锁。这其实就是一种悲观锁的思想。

- 非阻塞式方法：使用原子变量的方法。这就是一种乐观锁的思想。

#### CAS

java中乐观锁是通过CAS（compare and swap）方式实现的。

**算法思想**

CAS算法有三个操作数，内存地址V，旧值A，新值B。

CAS算法的思想：当需要更新值时，先将旧值A与内存地址V中的值进行比较，如果相同，就说明没有其他人对这个值作更新，此时就可以执行更新操作；如果发现旧值A与内存地址V中的值不同，说明有其他人更新过这个值，此时将旧值A换成别人修改过的值，继续进行检测，直到检测到内存地址V中的值和A的值一样时，就执行更新操作。下面代码来模拟CAS算法。

```java
gradle
public class CAS {

    private int value;  //代表内存地址中的值

    public synchronized int compareAndSwap(int A, int B){    
        //java中实际上没有使用synchronized关键字，而是通过操作硬件实现的
        int oldValue = value;
        if(oldValue == A){  //如果A的值和内存地址中的值相同就进行更新
            value = B;
        }
        return oldValue;   //返回上次内存地址中的值，在更新失败时将此值赋给A
    }
}
```

**CAS的优点**：
- 没有使用锁，不存在死锁的情况。
- 在读多写少的情况下不需要每次都加锁，不会使其他线程阻塞。

**CAS的缺点**：
- 如果线程读写频繁，则循环检测会浪费CPU很多资源。
- 只能保证一个共享变量的原子操作。
- 存在ABA问题

从Java1.5开始JDK提供了AtomicReference类来保证引用对象之间的原子性，可以把多个变量放在一个对象里来进行CAS操作。


**ABA问题**：

如果线程1将A修改为B，线程2又将B修改为A，这时线程C想要修改这个值，他看到的还是A，操作可以顺利进行，但是却不知道A->B->A的这个变化

解决ABA问题可以在CAS方法中加入版本号，每次修改都使版本号加1，这样只要做了修改，版本号就会有变化。





