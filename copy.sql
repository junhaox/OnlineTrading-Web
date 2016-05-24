COPY users(name, role, age, state) FROM '/Users/Junhao/Documents/workspace/CSE135_P2/users.txt' DELIMITER ',' CSV;

COPY categories(name, description) FROM '/Users/Junhao/Documents/workspace/CSE135_P2/categories.txt' DELIMITER ',' CSV;

COPY products(name, sku, category_id, price, is_delete) FROM '/Users/Junhao/Documents/workspace/CSE135_P2/products.txt' DELIMITER ',' CSV;

COPY orders(user_id, product_id, quantity, price, is_cart) FROM '/Users/Junhao/Documents/workspace/CSE135_P2/orders.txt' DELIMITER ',' CSV;
