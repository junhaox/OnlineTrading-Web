SELECT name FROM categories WHERE id = 11;

SELECT COUNT(*) as num FROM (SELECT name FROM products INNER JOIN orders ON products.id = orders.product_id GROUP BY name) p;

SELECT COUNT(*) as num FROM (SELECT name FROM products INNER JOIN orders ON products.id = orders.product_id WHERE products.category_id = 11 GROUP BY name) p;

SELECT COUNT(*) as num FROM (SELECT users.name as name FROM users INNER JOIN orders ON users.id = orders.user_id GROUP BY users.name) p;

SELECT COUNT(*) as num FROM (SELECT users.name as name FROM users INNER JOIN orders ON users.id = orders.user_id INNER JOIN products ON products.category_id = 11 GROUP BY users.name) c;

SELECT COUNT(*) as num FROM (SELECT state FROM users INNER JOIN orders ON users.id = orders.user_id GROUP BY state) p;

SELECT COUNT(*) as num FROM (SELECT state FROM users INNER JOIN orders ON users.id = orders.user_id INNER JOIN products ON products.category_id = 11 GROUP BY state) s;

WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) AS totalsales FROM orders GROUP BY product_id) SELECT products.id AS id, products.name AS name, col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id ORDER BY name LIMIT 10 OFFSET 10;

WITH col_header(product_id, totalsales) AS (SELECT product_id, SUM(orders.price) AS totalsales FROM products INNER JOIN orders on orders.product_id = products.id WHERE products.category_id = 11 GROUP BY product_id) SELECT products.id AS id, products.name AS name, col_header.totalsales AS totalsales FROM products INNER JOIN col_header ON products.id = col_header.product_id ORDER BY name LIMIT 10 OFFSET 10;

WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, SUM(orders.price) AS totalsales FROM users INNER JOIN orders ON users.id = orders.user_id GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users INNER JOIN row_header ON row_header.name = users.name ORDER BY totalsales DESC LIMIT 20 OFFSET 20;

WITH row_header(id, name, totalsales) AS (SELECT users.id AS id, users.name AS name, SUM(orders.price) AS totalsales FROM users INNER JOIN orders ON users.id = orders.user_id INNER JOIN products ON orders.product_id = products.id WHERE products.category_id = 14 GROUP BY users.id) SELECT DISTINCT LEFT(users.name, 10) AS name, users.id AS id, row_header.totalsales AS totalsales FROM users INNER JOIN row_header ON row_header.name = users.name ORDER BY name LIMIT 20 OFFSET 20;

WITH row_header(state, totalsales) AS (SELECT users.state AS state, SUM(orders.price) AS totalsales FROM users, orders WHERE users.id = orders.user_id GROUP BY users.state ORDER BY totalsales DESC) SELECT DISTINCT LEFT(users.state, 10) AS state, users.id AS id, row_header.totalsales AS totalsales FROM users INNER JOIN row_header ON row_header.state = users.state ORDER BY state LIMIT 20 OFFSET 40;

WITH row_header(state, totalsales) AS (SELECT users.state AS state, SUM(orders.price) AS totalsales FROM users INNER JOIN orders ON users.id = orders.user_id INNER JOIN products ON orders.product_id = products.id WHERE products.category_id = 11 GROUP BY users.state ORDER BY totalsales DESC) SELECT DISTINCT LEFT(users.state, 10) AS state, users.id AS id, row_header.totalsales AS totalsales FROM users INNER JOIN row_header ON row_header.state = users.state ORDER BY state LIMIT 20 OFFSET 20;

SELECT SUM(orders.price) AS totalprices FROM orders WHERE orders.product_id = 6 AND orders.user_id = 5 GROUP BY orders.product_id, orders.user_id;

SELECT SUM(orders.price) AS totalprices FROM orders INNER JOIN users ON users.id = orders.user_id INNER JOIN products on products.id = orders.product_id WHERE orders.product_id = 4 AND users.state = 'CA' GROUP BY orders.product_id, users.state;



CREATE INDEX idx_orders_user_id on orders(user_id);
DROP INDEX idx_orders_user_id;
CREATE INDEX idx_orders_product_id on orders(product_id);
DROP INDEX idx_orders_product_id;
CREATE INDEX idx_users_state on users(state);
DROP INDEX idx_users_state;
CREATE INDEX idx_users_name on users(name);
DROP INDEX idx_users_name;
CREATE INDEX idx_orders_price on orders(price);
DROP INDEX idx_orders_price;
CREATE INDEX idx_products_category_id on products(category_id);
DROP INDEX idx_products_category_id;