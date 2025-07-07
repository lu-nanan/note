```java
new Thread(() -> {
      try {
          pos.write("Hello from balabala!".getBytes());
          pos.close();
      } catch (IOException e) { e.printStackTrace(); }
  }).start();
```
