```java
new Thread(() -> {
      try {
          pos.write("Hello from ahaaha!".getBytes());
          pos.close();
      } catch (IOException e) { e.printStackTrace(); }
  }).start();
```
