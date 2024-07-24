-- Active: 1721292127253@@127.0.0.1@3306@sakila
--1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT f.title, COUNT(i.inventory_id) AS "Copies in inventory"
FROM film AS f
JOIN inventory AS i 
ON f.film_id = i.film_id
WHERE f.title = "Hunchback Impossible";
--2. List all films whose length is longer than the average length of all the films in the Sakila database. 
SELECT f.title,AVG(f.length) AS "Average"
FROM film AS f
GROUP BY f.title
HAVING Average > (SELECT ROUND(AVG(f.length)) AS "Average"
FROM film as f);
--3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT "Alone Trip" AS title, CONCAT(a.first_name, ' ', a.last_name) AS actors_name
FROM actor AS a
JOIN film_actor AS fa
ON a.actor_id = fa.actor_id
WHERE fa.film_id = (SELECT film_id FROM film WHERE title = "Alone Trip");
--4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.name AS "Category"
FROM film as f 
JOIN film_category as fa 
ON f.film_id = fa.film_id
JOIN category as c
ON fa.category_id = c.category_id
WHERE c.name in (SELECT name FROM category 
WHERE name = "Family");
--5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT CONCAT(c.first_name, ' ', c.last_name) AS customers_name, c.email,
       (SELECT co.country
        FROM country AS co
        WHERE co.country_id =
              (SELECT ci.country_id
               FROM city AS ci
               WHERE ci.city_id = a.city_id)
       ) AS country
FROM customer AS c
JOIN address AS a
ON c.address_id = a.address_id
WHERE a.city_id IN (
    SELECT ci.city_id
    FROM city AS ci
    WHERE ci.country_id = (
        SELECT co.country_id
        FROM country AS co
        WHERE co.country = "Canada"
    )
);
--6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
SELECT f.title, fa.actor_id
FROM film AS f
JOIN film_actor AS fa 
ON f.film_id = fa.film_id
WHERE fa.actor_id = (
    SELECT actor_id
    FROM film_actor
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);
--7 Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT f.title, cu.customer_id FROM film AS f
JOIN inventory AS i
ON f.film_id = i.film_id
JOIN rental as r
ON i.inventory_id = r.inventory_id
JOIN customer as cu
ON r.customer_id = cu.customer_id
WHERE cu.customer_id = (SELECT cu.customer_id FROM customer AS cu
JOIN payment AS pa
ON pa.customer_id = cu.customer_id
GROUP BY cu.customer_id
ORDER BY SUM(pa.amount) DESC LIMIT 1);
--8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
WITH client_totals AS (
    SELECT customer_id AS client_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
),
average_total AS (
    SELECT AVG(total_amount_spent) AS avg_total_amount_spent
    FROM client_totals
)
SELECT client_totals.client_id, client_totals.total_amount_spent
FROM client_totals
JOIN average_total
ON client_totals.total_amount_spent > average_total.avg_total_amount_spent;