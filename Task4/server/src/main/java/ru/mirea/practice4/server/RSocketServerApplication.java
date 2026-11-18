package ru.mirea.practice4.server;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import java.io.IOException;

@SpringBootApplication
public class RSocketServerApplication {
    public static void main(String[] args) {
        SpringApplication.run(RSocketServerApplication.class, args);
    }

    @Bean
    public CsvCatalog csvCatalog() throws IOException {
        CsvCatalog catalog = CsvCatalog.fromResources();
        System.out.printf("[RSocket / DATA] Загружено: дарксторы=%d, товары=%d, доставки=%d, позиции=%d%n",
                catalog.darkstoreCount(), catalog.goodCount(),
                catalog.deliveryCount(), catalog.goodsListCount());
        System.out.println("[RSocket / READY] TCP-сервер доступен: localhost:7000");
        return catalog;
    }
}
