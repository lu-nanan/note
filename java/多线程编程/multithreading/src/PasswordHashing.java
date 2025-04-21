import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordHashing {
    // 生成随机盐
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    // 哈希密码
    public static String hashPassword(String password, String salt) throws NoSuchAlgorithmException {
        String saltedPassword = salt + password;
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hashedPassword = md.digest(saltedPassword.getBytes());
        return Base64.getEncoder().encodeToString(hashedPassword);
    }

    // 验证密码
    public static boolean verifyPassword(String password, String salt, String hashedPassword) throws NoSuchAlgorithmException {
        String hashedInput = hashPassword(password, salt);
        return hashedInput.equals(hashedPassword);
    }

    public static void main(String[] args) throws NoSuchAlgorithmException {
        // 示例演示了密码哈希和加盐存储的过程
        String password = "123456";
        String salt = generateSalt();
        String hashedPassword = hashPassword(password, salt);

        // 存储用户信息，包括哈希后的密码和盐
        String storage = salt + ":" + hashedPassword;
        System.out.println("存储的用户信息： " + storage);

        System.out.println("原密码： " + password);
        System.out.println("盐： " + salt);
        System.out.println("哈希后的密码： " + hashedPassword);

        // 验证密码
        boolean isValid = verifyPassword(password, salt, hashedPassword);
        System.out.println("密码验证结果： " + isValid);
    }
}