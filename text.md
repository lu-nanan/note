```java
new Thread(() -> {
      try {
          pos.write("Hello from child!".getBytes());
          pos.close();
      } catch (IOException e) { e.printStackTrace(); }
  }).start();
```
