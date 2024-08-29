create database pizza_sales;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id));

create table order_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id));

-- Retrieve the total number of orders placed

select count(order_id) as total_order from orders;

-- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;

-- Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS ordered_pizza_count
FROM
    pizzas
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY ordered_pizza_count DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pizza_types.name AS pizza_name,
    SUM(order_details.quantity) AS total_qty
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_name
ORDER BY total_qty DESC
LIMIT 5;
 
 -- Join the necessary tables to find the total quantity of each pizza category ordered.
 
 SELECT 
    pizza_types.category AS category,
    SUM(order_details.quantity) AS total_quantity
FROM
    order_details
        INNER JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
        INNER JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
GROUP BY category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS count
FROM
    orders
GROUP BY hour
ORDER BY count DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS total_pizza
FROM
    pizza_types
GROUP BY category
ORDER BY total_pizza DESC;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as avg_pizzas_ordered
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    INNER JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
	
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name AS pizza_type,
    SUM(pizzas.price * order_details.quantity) AS total_revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type
ORDER BY total_revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category AS category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                0) AS total_sales
                FROM
                    pizzas
                        INNER JOIN
                    order_details ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        INNER JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        INNER JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.

SELECT order_date, sum(revenue) OVER(ORDER BY order_date) AS cum_revenue 
FROM (SELECT 
    orders.order_date,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    orders
        INNER JOIN
    order_details ON orders.order_id = order_details.order_id
        INNER JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
GROUP BY orders.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

select category, name, revenue from 
(select category, name, revenue, rank() over(partition by category order by revenue desc) as rn from 
(select pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue 
from pizza_types inner join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id inner join order_details 
on order_details.pizza_id = pizzas.pizza_id group by pizza_types.category, pizza_types.name) as a) as b 
where rn <=3;







