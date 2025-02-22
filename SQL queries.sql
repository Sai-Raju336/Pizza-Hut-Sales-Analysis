-- 1. Find the total number of orders placed.

select count(order_id) as 'Toatal_Orders'
from orders;


-- 2. Calculate the total revenue from pizza sales.

select round(sum(od.quantity*p.price),0) as 'Total_Revenue'
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id;


-- 3. Identify the highest-priced pizza.

select pt.pizza_type_id,pt.name,p.pizza_id,p.size,p.price
from pizza_types as pt join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
order by price desc
limit 1;


-- 4. Determine the most frequently ordered pizza size.

select p.size,count(od.order_details_id) as 'Total_orders'
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id 
group by p.size
order by total_orders desc
limit 1;


-- 5. List the top 5 pizzas by order quantity.

select pt.name,sum(od.quantity) as 'orders'
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by pt.name
order by orders desc
limit 5;


-- 6. Calculate the total quantity ordered for each pizza category.

select pt.category, sum(o.quantity) as total_orders
from pizza_types as pt join pizzas as p 
on pt.pizza_type_id = p.pizza_type_id
join order_details as o
on o.pizza_id = p.pizza_id
group by pt.category
order by total_orders desc;


-- 7. Analyze the distribution of orders by hour of day.

select hour(order_time) as hours, count(order_id) as total_orders
from orders
group by hours
order by hours desc;


-- 8. Determine the order distribution of pizzas by category.

select category,count(order_id) as orders
from pizza_types as pt join pizzas as p 
on pt.pizza_type_id = p.pizza_type_id
join order_details as o
on o.pizza_id = p.pizza_id
group by category
order by orders desc;


-- 9. Calculate the average number of pizzas ordered each day.

select round(avg(total_per_day),0) as 'Average_daily_orders'
from
(select order_date,sum(quantity) as total_per_day
from order_details as od join orders as o
on od.order_id = o.order_id
group by order_date) as orders_per_day;


-- 10. Identify the top 3 pizzas based on revenue.

select pt.name,sum(od.quantity * p.price) as 'Total_revenue'
from order_details as od join pizzas as p 
on p.pizza_id = od.pizza_id
join pizza_types as pt 
on pt.pizza_type_id = p.pizza_type_id
group by pt.name
order by total_revenue desc
limit 3;


-- 11. Calculate each pizza type’s percentage contribution to total revenue.

with Total_revenue as
(
  select round(sum(od.quantity*p.price),0) as 'TotalRevenue'
  from order_details as od join pizzas as p
  on od.pizza_id = p.pizza_id
)
select category,round(sum(od.quantity*p.price)/(select TotalRevenue from Total_revenue) * 100,2) as Revenue_percentage
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by category
order by Revenue_percentage desc;


-- 12. Track cumulative revenue growth over time.

with daily_revenue as (
 select order_date,round(sum(quantity*price),2) as 'daily_revenue'
 from order_details as od join pizzas as p
 on od.pizza_id = p.pizza_id
 join orders as o
 on od.order_id = o.order_id
 group by order_date )
 
 select order_date,daily_revenue,round(sum(daily_revenue) over(order by order_date),2) as 'cumulative_revenue'
 from daily_revenue;
 
 
 -- 13. Determine the top 3 pizzas by revenue within each category.
 
with pizza_rev_cat as( 
select category,name,sum(quantity*price) as pizza_rev
from order_details as od join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by category,name )

select *
from(
select *,rank() over (partition by category order by pizza_rev desc) as Ranking
from pizza_rev_cat) as rankings
where Ranking <= 3;