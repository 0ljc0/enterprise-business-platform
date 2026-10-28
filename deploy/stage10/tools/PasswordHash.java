import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
public class PasswordHash {
    public static void main(String[] args) {
        String value = System.getenv("BOOTSTRAP_PASSWORD");
        if (value == null || value.length() < 16) throw new IllegalArgumentException("Missing bootstrap password");
        System.out.print(new BCryptPasswordEncoder().encode(value));
    }
}
