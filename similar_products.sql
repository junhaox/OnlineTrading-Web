DROP VIEW IF EXISTS pairings CASCADE;
DROP VIEW IF EXISTS magnitudes CASCADE;
DROP VIEW IF EXISTS matching_orders CASCADE;
DROP VIEW IF EXISTS combined_orders CASCADE;

CREATE VIEW pairings AS 
SELECT p1.id AS p1_id, p2.id AS p2_id
FROM products p1, products p2
WHERE p1.id < p2.id;

SELECT * FROM pairings;

CREATE VIEW combined_orders AS
SELECT o.user_id, o.product_id, SUM(o.price) AS price
FROM orders o
GROUP BY o.user_id, o.product_id;

CREATE VIEW magnitudes AS
SELECT p.id, (SUM(o.price)) AS mag_sqrt
FROM combined_orders o, products p
WHERE p.id = o.product_id
GROUP BY p.id;

SELECT * FROM magnitudes;

CREATE VIEW matching_orders AS
SELECT o1.user_id AS id1, o2.user_id AS id2, p.p1_id, p.p2_id, o1.price AS price1, o2.price AS price2
FROM pairings p, combined_orders o1, combined_orders o2
WHERE p.p1_id = o1.product_id AND p.p2_id = o2.product_id AND o1.user_id = o2.user_id;

SELECT * FROM matching_orders;
(
SELECT p3.name, p4.name, 0 AS cosine_similarity
FROM products p3, products p4, pairings pair
WHERE pair.p1_id = p3.id AND pair.p2_id = p4.id AND NOT EXISTS (
	SELECT 1
	FROM matching_orders mo
	WHERE p3.id = mo.id1 AND p4.id = mo.id2)
)
UNION
(	
SELECT p1.name, p2.name, ((SUM(mo.price1 * mo.price2)) / (m1.mag_sqrt * m2.mag_sqrt)) AS cosine_similarity
FROM products p1, products p2, magnitudes m1, magnitudes m2, matching_orders mo
WHERE mo.p1_id = m1.id AND mo.p2_id = m2.id AND m1.id = p1.id AND m2.id = p2.id
GROUP BY p1.name, p2.name, m1.mag_sqrt, m2.mag_sqrt
)
ORDER BY cosine_similarity DESC;

DROP VIEW pairings CASCADE;
DROP VIEW magnitudes CASCADE;
DROP VIEW matching_orders CASCADE;
DROP VIEW combined_orders CASCADE;