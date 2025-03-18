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
