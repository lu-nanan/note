import java.util.concurrent.locks.ReentrantReadWriteLock;

public class TestReadWriteLock {

    public static void main(String[] args) {

        ReentrantReadWriteLock lock = new ReentrantReadWriteLock();

        for (int i=0; i<10; i++){
            new Thread(()->{
                try {
                    lock.readLock().lock();
                    System.out.println(Thread.currentThread().getName() + "--- 正在读取 ---");
                    Thread.sleep(100);
                    System.out.println(Thread.currentThread().getName() + "【读取完毕】");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    lock.readLock().unlock();
                }
            }).start();
        }

        for (int i=0; i<10; i++){
            new Thread(()->{
                try {
                    lock.writeLock().lock();
                    System.out.println(Thread.currentThread().getName() + "--- 正在写入 ---");
                    Thread.sleep(1000);
                    System.out.println(Thread.currentThread().getName() + "【写入完毕】");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    lock.writeLock().unlock();
                }
            }).start();
        }

    }
}