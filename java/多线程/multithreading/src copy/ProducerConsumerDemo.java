import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class ProducerConsumerDemo {
    private final Queue<Integer> queue = new LinkedList<>();
    private final int capacity = 5;
    private final Lock lock = new ReentrantLock();
    private final Condition notFull = lock.newCondition();  // 队列未满条件
    private final Condition notEmpty = lock.newCondition(); // 队列非空条件

    // 生产者方法
    public void produce(int value) throws InterruptedException {
        lock.lock();
        try {
            // 队列已满，生产者等待
            while (queue.size() == capacity) {
                notFull.await();
            }
            queue.add(value);
            System.out.println("生产: " + value + "，队列大小: " + queue.size());
            notEmpty.signal(); // 唤醒一个消费者
        } finally {
            lock.unlock();
        }
    }

    // 消费者方法
    public int consume() throws InterruptedException {
        lock.lock();
        try {
            // 队列为空，消费者等待
            while (queue.isEmpty()) {
                notEmpty.await();
            }
            int value = queue.poll();
            System.out.println("消费: " + value + "，队列大小: " + queue.size());
            notFull.signal(); // 唤醒一个生产者
            return value;
        } finally {
            lock.unlock();
        }
    }

    public static void main(String[] args) {
        ProducerConsumerDemo demo = new ProducerConsumerDemo();

        // 生产者线程
        new Thread(() -> {
            for (int i = 1; i <= 10; i++) {
                try {
                    demo.produce(i);
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();

        // 消费者线程
        new Thread(() -> {
            for (int i = 1; i <= 10; i++) {
                try {
                    demo.consume();
                    Thread.sleep(200);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }).start();
    }
}