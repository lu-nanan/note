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
