# **Java 进程通信**
---

- [Java 进程通信](#java-进程通信)
      - [**1. 管道（Pipes）**](#1-管道pipes)
      - [**2. 文件共享（File Sharing）**](#2-文件共享file-sharing)
      - [**3. Socket通信（TCP/UDP）**](#3-socket通信tcpudp)
      - [**4. Java RMI（Remote Method Invocation）**](#4-java-rmiremote-method-invocation)
      - [**5. 消息队列（Message Queues）**](#5-消息队列message-queues)
      - [**6. 内存映射文件（Memory-Mapped Files）**](#6-内存映射文件memory-mapped-files)


在Java中，进程间通信（IPC, Inter-Process Communication）需要通过操作系统提供的机制实现，因为进程之间是隔离的。

#### **1. 管道（Pipes）**
- **原理**：单向字节流，用于有父子/兄弟关系的进程。
- **Java实现**：`java.io.PipedInputStream` 和 `java.io.PipedOutputStream`。
- **示例**：
  ```java
  // 父进程创建管道
  PipedInputStream pis = new PipedInputStream();
  PipedOutputStream pos = new PipedOutputStream(pis);
  
  // 子进程写入
  new Thread(() -> {
      try {
          pos.write("Hello from child!".getBytes());
          pos.close();
      } catch (IOException e) { e.printStackTrace(); }
  }).start();
  
  // 父进程读取
  int data;
  while ((data = pis.read()) != -1) {
      System.out.print((char) data);
  }
  pis.close();
  ```
- **适用场景**：简单的父子进程通信。
- **缺点**：单向通信，仅适用于有血缘关系的进程。

#### **2. 文件共享（File Sharing）**
- **原理**：通过读写同一文件实现数据交换。
- **实现**：使用`File`、`FileInputStream`、`FileOutputStream`等类。
- **示例**：
  ```java
  // 进程A写入文件
  try (FileWriter writer = new FileWriter("shared.txt")) {
      writer.write("Data from Process A");
  }
  
  // 进程B读取文件
  try (BufferedReader reader = new BufferedReader(new FileReader("shared.txt"))) {
      System.out.println(reader.readLine());
  }
  ```
- **注意事项**：
  - 需要文件锁（`FileLock`）避免并发写入冲突。
  - 适合低频通信，性能较差。
  
#### **3. Socket通信（TCP/UDP）**
- **原理**：通过网络套接字实现跨进程通信。
- **实现**：`java.net.Socket`（TCP）和`java.net.DatagramSocket`（UDP）。
- **TCP示例**：
  ```java
  // 服务端（进程A）
  ServerSocket server = new ServerSocket(8080);
  Socket client = server.accept();
  BufferedReader in = new BufferedReader(new InputStreamReader(client.getInputStream()));
  System.out.println("Received: " + in.readLine());
  
  // 客户端（进程B）
  Socket socket = new Socket("localhost", 8080);
  PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
  out.println("Hello from Process B");
  ```
- **优点**：跨机器通信，灵活可靠。
- **缺点**：需处理网络延迟和异常。

#### **4. Java RMI（Remote Method Invocation）**
- **原理**：通过远程方法调用实现分布式对象通信。
- **实现**：`java.rmi`包。
- **步骤**：
  1. 定义远程接口（继承`Remote`）。
  2. 实现远程接口（继承`UnicastRemoteObject`）。
  3. 注册服务（使用`Registry`）。
- **示例**：
  ```java
  // 定义接口
  public interface RemoteService extends Remote {
      String getMessage() throws RemoteException;
  }
  
  // 服务端实现
  public class RemoteServiceImpl extends UnicastRemoteObject implements RemoteService {
      public RemoteServiceImpl() throws RemoteException {}
      public String getMessage() { return "Hello from RMI"; }
  }
  
  // 服务端注册
  Registry registry = LocateRegistry.createRegistry(1099);
  registry.rebind("RemoteService", new RemoteServiceImpl());
  
  // 客户端调用
  Registry registry = LocateRegistry.getRegistry("localhost", 1099);
  RemoteService service = (RemoteService) registry.lookup("RemoteService");
  System.out.println(service.getMessage());
  ```
- **优点**：面向对象，适合复杂调用。
- **缺点**：依赖Java环境，防火墙配置复杂。

#### **5. 消息队列（Message Queues）**
- **原理**：通过中间件（如ActiveMQ、RabbitMQ）实现异步通信。
- **实现**：需引入第三方库（如JMS API）。
- **示例**（使用JMS）：
  ```java
  // 发送消息
  ConnectionFactory factory = new ActiveMQConnectionFactory("tcp://localhost:61616");
  Connection connection = factory.createConnection();
  Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
  Queue queue = session.createQueue("MyQueue");
  MessageProducer producer = session.createProducer(queue);
  producer.send(session.createTextMessage("Hello from Process A"));
  
  // 接收消息
  MessageConsumer consumer = session.createConsumer(queue);
  connection.start();
  TextMessage message = (TextMessage) consumer.receive();
  System.out.println("Received: " + message.getText());
  ```
- **优点**：解耦、异步、支持广播。
- **缺点**：依赖中间件，增加系统复杂度。

#### **6. 内存映射文件（Memory-Mapped Files）**
- **原理**：通过`FileChannel`将文件映射到内存，实现高效共享。
- **实现**：`java.nio.MappedByteBuffer`。
- **示例**：
  ```java
  // 进程A写入
  RandomAccessFile file = new RandomAccessFile("shared.dat", "rw");
  FileChannel channel = file.getChannel();
  MappedByteBuffer buffer = channel.map(FileChannel.MapMode.READ_WRITE, 0, 1024);
  buffer.put("Hello from Process A".getBytes());
  
  // 进程B读取
  buffer.flip();
  byte[] data = new byte[buffer.remaining()];
  buffer.get(data);
  System.out.println(new String(data));
  ```
- **优点**：高性能，适合大数据量。
- **缺点**：需处理同步问题。


| **方法**         | **适用场景**                | **性能** | **复杂度** | **跨平台** | **Java标准支持** |
|------------------|---------------------------|---------|-----------|-----------|----------------|
| **管道**          | 父子进程简单通信            | 低      | 低        | 是        | 是             |
| **文件共享**      | 低频数据交换                | 低      | 低        | 是        | 是             |
| **Socket**       | 跨机器/网络通信            | 中      | 中        | 是        | 是             |
| **RMI**          | 分布式Java应用             | 中      | 高        | 是        | 是             |
| **消息队列**      | 异步解耦、高并发            | 高      | 高        | 是        | 需第三方库      |
| **内存映射文件**  | 高性能本地进程通信          | 高      | 中        | 是        | 是             |

