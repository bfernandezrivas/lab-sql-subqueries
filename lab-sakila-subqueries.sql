-- ---------------------------------------------------
-- Lab: SQL Subqueries (Sakila Database)
-- ---------------------------------------------------

USE sakila;

-- ---------------------------------------------------
-- 1. Number of copies of "Hunchback Impossible" in inventory
-- ---------------------------------------------------
SELECT 
    COUNT(*) AS copies_in_inventory
FROM inventory
WHERE film_id = (
    SELECT film_id 
    FROM film 
    WHERE title = 'HUNCHBACK IMPOSSIBLE'
);

-- ---------------------------------------------------
-- 2. Films longer than the average length of all films
-- ---------------------------------------------------
SELECT 
    title, 
    length
FROM film
WHERE length > (
    SELECT AVG(length) FROM film
)
ORDER BY length DESC;

-- ---------------------------------------------------
-- 3. All actors who appear in the film "Alone Trip"
-- ---------------------------------------------------
SELECT 
    a.first_name, 
    a.last_name
FROM actor a
WHERE a.actor_id IN (
    SELECT fa.actor_id
    FROM film_actor fa
    INNER JOIN film f ON fa.film_id = f.film_id
    WHERE f.title = 'ALONE TRIP'
);

-- ---------------------------------------------------
-- BONUS 4. Identify all movies categorized as family films
-- ---------------------------------------------------
SELECT 
    f.title AS family_films
FROM film f
WHERE f.film_id IN (
    SELECT fc.film_id
    FROM film_category fc
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Family'
)
ORDER BY f.title;

-- ---------------------------------------------------
-- BONUS 5. Retrieve name and email of customers from Canada (using subquery)
-- ---------------------------------------------------
SELECT 
    first_name, 
    last_name, 
    email
FROM customer
WHERE address_id IN (
    SELECT address_id 
    FROM address
    WHERE city_id IN (
        SELECT city_id 
        FROM city
        WHERE country_id = (
            SELECT country_id FROM country WHERE country = 'Canada'
        )
    )
);

-- Same query using JOINs:
SELECT 
    c.first_name, 
    c.last_name, 
    c.email
FROM customer c
INNER JOIN address a ON c.address_id = a.address_id
INNER JOIN city ci ON a.city_id = ci.city_id
INNER JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- ---------------------------------------------------
-- BONUS 6. Films starred by the most prolific actor
-- ---------------------------------------------------
-- Step 1: Find the most prolific actor (with most film appearances)
SELECT 
    actor_id, 
    COUNT(film_id) AS film_count
FROM film_actor
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

-- Step 2: Use that actor_id in a subquery to list their films
SELECT 
    f.title
FROM film f
WHERE f.film_id IN (
    SELECT film_id 
    FROM film_actor
    WHERE actor_id = (
        SELECT actor_id 
        FROM film_actor
        GROUP BY actor_id
        ORDER BY COUNT(film_id) DESC
        LIMIT 1
    )
);

-- ---------------------------------------------------
-- BONUS 7. Films rented by the most profitable customer
-- ---------------------------------------------------
-- Step 1: Find the most profitable customer
SELECT 
    customer_id, 
    SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 1;

-- Step 2: List the films rented by that customer
SELECT 
    f.title AS rented_films
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT customer_id 
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- ---------------------------------------------------
-- BONUS 8. Clients who spent more than the average of total spent by all clients
-- ---------------------------------------------------
-- Step 1: Calculate total spent per client
-- Step 2: Compare each client’s total with the average of all totals
SELECT 
    customer_id,
    SUM(amount) AS total_spent
FROM payment
GROUP BY customer_id
HAVING total_spent > (
    SELECT AVG(total_per_customer) 
    FROM (
        SELECT SUM(amount) AS total_per_customer
        FROM payment
        GROUP BY customer_id
    ) AS totals
)
ORDER BY total_spent DESC;
