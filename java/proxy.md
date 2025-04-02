Java 代理模式
---


### **一、代理模式（Proxy Pattern）**
**代理模式** 是一种 **设计模式**，属于 **对象行为型模式**，其核心思想是通过一个代理对象来控制对目标对象的访问，从而在不修改目标对象的情况下，实现对目标对象功能的增强或控制。

#### **核心角色**
1. **抽象主题（Subject）**  
   - 定义目标对象和代理对象的共同接口，使客户端能够统一调用。
   - 通常是接口或抽象类。
2. **真实主题（Real Subject）**  
   - 实现抽象主题接口，提供核心业务逻辑。
3. **代理（Proxy）**  
   - 实现与真实主题相同的接口，包含对真实主题的引用。
   - 在调用真实主题方法前后，可以添加额外逻辑（如日志、权限校验、缓存等）。

#### **代理模式的用途**
- **控制访问**：在访问目标对象前增加校验逻辑。
- **增强功能**：在目标方法执行前后添加额外操作（如日志、性能监控）。
- **降低耦合**：客户端无需直接依赖真实对象，通过代理间接调用。

### **二、静态代理（Static Proxy）**
静态代理是代理模式的 **基础实现方式**，代理类在编译时就已经确定，与目标对象实现相同的接口。

#### **实现步骤**
1. **定义接口**  
   ```java
   public interface SellTickets {
       void sell();
   }
   ```
2. **实现真实对象**  
   ```java
   public class TrainStation implements SellTickets {
       @Override
       public void sell() {
           System.out.println("火车站卖票......");
       }
   }
   ```
3. **创建代理类**  
   ```java
   public class ProxyPoint implements SellTickets {
       private TrainStation station = new TrainStation();
       
       @Override
       public void sell() {
           System.out.println("代售点收取费用......");
           station.sell(); // 调用真实对象的方法
       }
   }
   ```
4. **客户端调用**  
   ```java
   public class Client {
       public static void main(String[] args) {
           SellTickets proxy = new ProxyPoint();
           proxy.sell();
       }
   }
   ```

| **优点** | **缺点** |
|----------|----------|
| 实现简单，容易理解 | 代理类与目标类必须实现相同接口，扩展性差 |
| 可直接控制代理逻辑 | 每增加一个目标类，需编写一个代理类，代码冗余 |
| 支持多线程（如Runnable实现静态代理） | 接口变更时需修改所有代理类 |


### **三、动态代理（Dynamic Proxy）**

动态代理是一种在 **运行时** 动态生成代理类的技术，其核心目的是在不修改目标对象代码的情况下，通过代理对象对目标对象的方法进行增强（如日志、权限校验、性能监控等）。Java中主要通过以下两种方式实现动态代理：

1. **JDK动态代理**：基于接口，利用 `java.lang.reflect.Proxy` 和 `InvocationHandler` 实现。
2. **CGLIB动态代理**：基于类，通过生成目标类的子类实现，依赖 `cglib` 库。

#### **1. JDK动态代理的原理**
##### **（1）核心组件**
- **Proxy类**：  
  `java.lang.reflect.Proxy` 是动态代理的核心类，提供 `newProxyInstance()` 方法在运行时生成代理类。
- **InvocationHandler接口**：  
  定义 `invoke()` 方法，用于处理代理对象的所有方法调用。开发者需实现该接口并定义增强逻辑。

##### **（2）实现步骤**
1. **定义接口**  
   目标对象和代理对象必须实现相同的接口（JDK动态代理的硬性要求）。  
   ```java
   public interface IService {
       void doSomething();
   }
   ```

2. **创建目标对象**  
   实现接口的类，提供核心业务逻辑。  
   ```java
   public class RealService implements IService {
       @Override
       public void doSomething() {
           System.out.println("RealService doSomething");
       }
   }
   ```

3. **实现InvocationHandler**  
   在 `invoke()` 方法中定义增强逻辑（如日志、权限校验）。  
   ```java
   public class ServiceProxy implements InvocationHandler {
       private Object target; // 目标对象引用

       public Object bind(Object target) {
           this.target = target;
           return Proxy.newProxyInstance(
               target.getClass().getClassLoader(), // 类加载器
               target.getClass().getInterfaces(),  // 目标对象实现的接口
               this // InvocationHandler实例
           );
       }

       @Override
       public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
           System.out.println("Before method invoke"); // 增强逻辑：前置增强
           Object result = method.invoke(target, args); // 调用目标方法
           System.out.println("After method invoke"); // 增强逻辑：后置增强
           return result;
       }
   }
   ```

4. **生成并使用代理对象**  
   ```java
   public class Client {
       public static void main(String[] args) {
           IService real = new RealService();
           IService proxy = (IService) new ServiceProxy().bind(real);
           proxy.doSomething();
       }
   }
   ```

##### **（3）关键过程解析**
- **字节码生成**：  
  `Proxy.newProxyInstance()` 方法在运行时动态生成一个代理类，该类：
  - 继承 `java.lang.reflect.Proxy` 类。
  - 实现目标对象的所有接口（如 `IService`）。
  - 重写接口中的每个方法，将方法调用委托给 `InvocationHandler` 的 `invoke()` 方法。

- **方法调用流程**：  
  当客户端调用代理对象的 `doSomething()` 方法时：
  1. 代理对象拦截调用，调用 `invoke()` 方法。
  2. 在 `invoke()` 中执行前置增强逻辑（如日志）。
  3. 通过反射调用目标对象的 `doSomething()` 方法。
  4. 执行后置增强逻辑（如释放资源）。
  5. 返回结果给客户端。

#### **2. CGLIB动态代理的原理**
##### **（1）核心机制**
- **CGLIB（Code Generation Library）**：  
  通过生成目标类的 **子类** 实现代理，无需目标类实现接口。依赖底层字节码生成库（如 ASM）。
- **关键类**：  
  - `Enhancer`：用于创建代理对象。
  - `MethodInterceptor`：定义方法拦截逻辑，类似 `InvocationHandler`。

##### **（2）实现步骤**
1. **依赖引入**  
   需要引入 CGLIB 库：  
   ```xml
   <dependency>
       <groupId>cglib</groupId>
       <artifactId>cglib</artifactId>
       <version>3.3.0</version>
   </dependency>
   ```

2. **实现MethodInterceptor**  
   ```java
   import net.sf.cglib.proxy.MethodInterceptor;
   import net.sf.cglib.proxy.MethodProxy;

   public class CglibProxy implements MethodInterceptor {
       private Object target;

       public Object bind(Object target) {
           this.target = target;
           Enhancer enhancer = new Enhancer();
           enhancer.setSuperclass(target.getClass()); // 设置父类
           enhancer.setCallback(this); // 设置拦截器
           return enhancer.create(); // 创建代理对象
       }

       @Override
       public Object intercept(Object obj, Method method, Object[] args, MethodProxy proxy) throws Throwable {
           System.out.println("Before method invoke");
           Object result = proxy.invokeSuper(obj, args); // 调用父类方法
           System.out.println("After method invoke");
           return result;
       }
   }
   ```

3. **客户端调用**  
   ```java
   public class Client {
       public static void main(String[] args) {
           RealService real = new RealService();
           RealService proxy = (RealService) new CglibProxy().bind(real);
           proxy.doSomething();
       }
   }
   ```

##### **（3）关键过程解析**
- **字节码生成**：  
  CGLIB 通过 ASM 库在运行时生成一个目标类的子类（如 `RealService$$EnhancerByCGLIB$$xxxx`），并重写目标类的方法。
- **方法调用流程**：  
  当客户端调用代理对象的 `doSomething()` 方法时：
  1. 子类拦截调用，调用 `intercept()` 方法。
  2. 在 `intercept()` 中执行前置增强逻辑。
  3. 通过 `MethodProxy` 调用父类（目标对象）的 `doSomething()` 方法。
  4. 执行后置增强逻辑并返回结果。


#### **共同原理**
- **代理对象生成**：  
  在运行时动态生成代理类（JDK通过 `Proxy`，CGLIB通过字节码生成）。
- **方法拦截与转发**：  
  代理类的方法调用最终通过 `InvocationHandler` 或 `MethodInterceptor` 拦截，执行增强逻辑后转发给目标对象。
- **反射机制**：  
  通过 `Method.invoke()` 或 `MethodProxy.invokeSuper()` 调用目标对象的方法。

#### **关键区别**
| **特性**               | **JDK动态代理**                          | **CGLIB动态代理**                          |
|------------------------|------------------------------------------|--------------------------------------------|
| **代理对象生成方式**    | 实现接口，继承 `Proxy` 类                | 生成目标类的子类                          |
| **依赖条件**            | 目标对象必须实现接口                    | 目标对象无需接口（但需非 `final` 类/方法） |
| **性能**                | 较高（反射调用）                        | 稍低（子类继承，但无需接口）               |
| **适用场景**            | 接口明确且稳定的场景（如Spring AOP）     | 需代理无接口类或需避免接口约束的场景        |



#### **动态代理的应用场景**
1. **AOP（面向切面编程）**  
   - 在方法调用前后插入日志、事务管理、权限校验等横切逻辑。
2. **远程调用（RPC）**  
   - 代理对象封装网络通信细节，客户端直接调用本地代理方法。
3. **性能监控**  
   - 统计方法执行时间、调用次数等指标。
4. **缓存优化**  
   - 在代理中缓存方法结果，减少重复计算。


#### **动态代理的局限性**
1. **JDK动态代理的限制**  
   - 目标对象必须实现接口。
   - 无法代理 `private` 或 `static` 方法。
2. **CGLIB的限制**  
   - 无法代理 `final` 类或方法。
   - 需额外依赖库，可能增加项目复杂度。

| **优点** | **缺点** |
|----------|----------|
| **JDK动态代理**： | **JDK动态代理**： |
| - 运行时生成代理，无需预写代码 | - 目标对象必须实现接口 |
| - 支持多线程 | - 无法代理无接口的类 |
| **CGLIB动态代理**： | **CGLIB动态代理**： |
| - 无需接口，支持无接口类 | - 性能稍低于JDK代理 |
| - 通过继承实现，但需依赖第三方库 | - 无法代理`final`方法或类 |


| **对比项**       | **静态代理**               | **动态代理（JDK/CGLIB）**       |
|------------------|---------------------------|--------------------------------|
| **代理类生成时机** | 编译时                   | 运行时动态生成                 |
| **代码维护**       | 代理类与目标类一一对应，维护成本高 | 一个代理类可代理多个目标类       |
| **灵活性**         | 固定逻辑，扩展性差        | 可动态添加逻辑，灵活性高        |
| **是否依赖接口**   | 必须实现相同接口          | JDK依赖接口，CGLIB无需接口      |
| **适用场景**       | 简单场景或接口固定的情况   | 复杂场景、需代理大量类或无接口类 |