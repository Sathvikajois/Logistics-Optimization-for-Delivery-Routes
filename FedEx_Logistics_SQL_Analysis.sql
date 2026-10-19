CREATE DATABASE fedex_logistics;
USE fedex_logistics;
SELECT * FROM fedex_orders;
SELECT * FROM fedex_routes;
SELECT * FROM fedex_shipments;
-- TASK 1: DATA CLEANING & PREPARATION
-- TASK 1.1: Check Duplicates
-- Duplicate Order ID's
SELECT order_ID, count(*) as duplicate_count from fedex_orders group by 
order_ID having count(*) > 1;
-- Duplicate Shipment ID's
SELECT shipment_ID, count(*) as duplicate_count from fedex_shipments group by
shipment_ID having count(*) > 1;
-- TASK 1.2: Replace Null Delay Hours
SELECT * FROM fedex_shipments where delay_hours is NULL;
-- TASK 1.3: Format Date Columns
-- Orders table
SELECT order_ID, DATE_FORMAT(order_date, '%y-%m-%d %h:%i:%s') as formatted_order_date
from fedex_orders;
-- Shipments table
SELECT DATE_FORMAT(pickup_date, '%y-%m-%d %H:%i:%s') as formatted_pickup_date,
DATE_FORMAT(Delivery_date, '%y-%m-%d %H:%i:%s') as formatted_delivery_date
from fedex_shipments;
-- TASK 1.4: Invalid Delivery Dates
SELECT * from fedex_shipments where Delivery_date < Pickup_date;
-- TASK 1.5: Referential Integrity
-- Orders vs routes
SELECT * from fedex_orders o  left join fedex_routes r 
on o.route_ID = r.route_ID  where r.route_ID is NULL;
-- orders vs warehouses
SELECT * from fedex_orders o  left join fedex_warehouses w 
on o.warehouse_ID = w.warehouse_ID  where w.warehouse_ID is NULL;
-- shipment vs orders
SELECT * from fedex_shipments s  left join fedex_orders o 
on s.order_ID = o.order_ID  where o.order_ID is NULL;

-- TASK 2: DELIVERY DELAY ANALYSIS
-- TASK 2.1: Average delay by route
Select route_ID, round(avg(delay_hours),2) as avg_delay_hours from fedex_shipments
group by route_ID order by avg_delay_hours desc;
-- TASK 2.2: Delay by delivery type
select o.delivery_type, round(avg(s.delay_hours),2) as avg_delay from fedex_orders o
join fedex_shipments s on o.order_ID = s.order_ID group by o.delivery_type;
-- TASK 2.3: Delayed shipments by warehouse
SELECT  Warehouse_ID, COUNT(*) AS Delayed_Shipments FROM fedex_shipments WHERE Delay_Hours > 0
GROUP BY Warehouse_ID ORDER BY Delayed_Shipments DESC;
-- TASK 2.4: Delivery status distribution
SELECT  Delivery_Status, COUNT(*) AS Total_Shipments FROM fedex_shipments
GROUP BY Delivery_Status;
-- TASK 2.5: Top 5 Most Delayed Shipments
SELECT  Shipment_ID, Route_ID, Warehouse_ID, Delay_Hours FROM fedex_shipments
ORDER BY Delay_Hours DESC LIMIT 5;

-- TASK 3: ROUTE OPTIMIZATION ANALYSIS
-- TASK 3.1: Average Transit Time by Route
SELECT  Route_ID, ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)),2) AS Avg_Transit_Hours
FROM fedex_shipments GROUP BY Route_ID ORDER BY Avg_Transit_Hours DESC;
-- TASK 3.2: Distance vs Delay Correlation
SELECT  r.Route_ID, r.Distance_KM, ROUND(AVG(s.Delay_Hours),2) AS Avg_Delay FROM fedex_routes r
JOIN fedex_shipments s ON r.Route_ID = s.Route_ID
GROUP BY r.Route_ID, r.Distance_KM ORDER BY r.Distance_KM DESC;
-- TASK 3.3: Route Performance by Traffic Condition
SELECT  Route_ID, Distance_KM, Avg_Transit_Time_Hours
FROM fedex_routes ORDER BY Distance_KM DESC;
-- TASK 3.4: Fastest vs Slowest Routes
SELECT Route_ID, ROUND(AVG(TIMESTAMPDIFF(HOUR, Pickup_Date, Delivery_Date)),2) AS Avg_Transit_Hours
FROM fedex_shipments GROUP BY Route_ID ORDER BY Avg_Transit_Hours ASC;
-- TASK 3.5: Route Utilization Frequency
SELECT  Route_ID, COUNT(*) AS Shipment_Count
FROM fedex_shipments GROUP BY Route_ID ORDER BY Shipment_Count DESC;

-- TASK 4: WAREHOUSE PERFORMANCE ANALYSIS
-- TASK 4.1: Total Shipments by Warehouse
SELECT Warehouse_ID, COUNT(*) AS Total_Shipments
FROM fedex_shipments GROUP BY Warehouse_ID ORDER BY Total_Shipments DESC;
-- TASK 4.2: Average Delay by Warehouse
SELECT  Warehouse_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay
FROM fedex_shipments GROUP BY Warehouse_ID ORDER BY Avg_Delay DESC;
-- TASK 4.3: Warehouse Capacity Utilization
SELECT  w.Warehouse_ID, w.capacity_per_day, COUNT(s.Shipment_ID) AS Shipments_Handled,
ROUND((COUNT(s.Shipment_ID) / w.capacity_per_day) * 100,2) AS Utilization_Percentage
FROM fedex_warehouses w LEFT JOIN fedex_shipments s ON w.Warehouse_ID = s.Warehouse_ID
GROUP BY w.Warehouse_ID, w.capacity_per_day ORDER BY Utilization_Percentage DESC;
-- TASK 4.4: Shipment Status by Warehouse
SELECT  Warehouse_ID, Delivery_Status, COUNT(*) AS Shipment_Count FROM fedex_shipments
GROUP BY Warehouse_ID, Delivery_Status ORDER BY Warehouse_ID;
-- TASK 4.5: Warehouse Performance Ranking
SELECT  Warehouse_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay, COUNT(*) AS Total_Shipments
FROM fedex_shipments GROUP BY Warehouse_ID ORDER BY Avg_Delay ASC;

-- TASK 5: DELIVERY AGENT PERFORMANCE ANALYSIS
-- TASK 5.1: Total Shipments Handled by Each Agent
SELECT  Agent_ID, COUNT(*) AS Total_Shipments FROM fedex_shipments
GROUP BY Agent_ID ORDER BY Total_Shipments DESC;
-- TASK 5.2: Average Delay by Agent
SELECT Agent_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay FROM fedex_shipments
GROUP BY Agent_ID ORDER BY Avg_Delay DESC;
-- TASK 5.3: Successful Deliveries by Agent
SELECT Agent_ID, COUNT(*) AS Successful_Deliveries FROM fedex_shipments
WHERE Delivery_Status = 'Delivered' GROUP BY Agent_ID ORDER BY Successful_Deliveries DESC;
-- TASK 5.4: Delayed Shipments by Agent
SELECT Agent_ID, COUNT(*) AS Delayed_Shipments FROM fedex_shipments
WHERE Delay_Hours > 0 GROUP BY Agent_ID ORDER BY Delayed_Shipments DESC;
-- TASK 5.5: Agent Performance Ranking
SELECT Agent_ID, COUNT(*) AS Total_Shipments, ROUND(AVG(Delay_Hours),2) AS Avg_Delay
FROM fedex_shipments GROUP BY Agent_ID ORDER BY Avg_Delay ASC;
-- TASK 5.6: Agent Workload Distribution
SELECT Agent_ID, COUNT(*) AS Shipment_Load FROM fedex_shipments
GROUP BY Agent_ID ORDER BY Shipment_Load DESC;

-- TASK 6: REVENUE & PAYMENT ANALYSIS
-- TASK 6.1: Total Revenue Generated
SELECT ROUND(SUM(Order_Amount),2) AS Total_Revenue
FROM fedex_orders;
-- TASK 6.2: Revenue by Delivery Type
SELECT Delivery_Type, ROUND(SUM(Order_Amount),2) AS Revenue FROM fedex_orders
GROUP BY Delivery_Type ORDER BY Revenue DESC;
-- TASK 6.3: Revenue by Payment Mode
SELECT Payment_Mode, ROUND(SUM(Order_Amount),2) AS Total_Revenue FROM fedex_orders
GROUP BY Payment_Mode ORDER BY Total_Revenue DESC;
-- TASK 6.4: Average Order Amount by Payment Mode
SELECT Payment_Mode, ROUND(AVG(Order_Amount),2) AS Avg_Order_Amount FROM fedex_orders
GROUP BY Payment_Mode ORDER BY Avg_Order_Amount DESC;
-- TASK 6.5: Revenue Contribution by Warehouse
SELECT Warehouse_ID, ROUND(SUM(Order_Amount),2) AS Revenue FROM fedex_orders
GROUP BY Warehouse_ID ORDER BY Revenue DESC;
-- TASK 6.6: Top 5 Highest Value Orders
SELECT Order_ID, Customer_ID, Order_Amount, Delivery_Type, Payment_Mode
FROM fedex_orders ORDER BY Order_Amount DESC LIMIT 5;

-- TASK 7: ADVANCED BUSINESS INSIGHTS & KPI ANALYSIS
-- TASK 7.1: Overall Shipment Success Rate
SELECT ROUND((SUM(CASE WHEN Delivery_Status = 'Delivered' THEN 1 ELSE 0 END) * 100.0)/ COUNT(*),2) AS Success_Rate_Percentage
FROM fedex_shipments;
-- TASK 7.2 — Overall Average Delay
SELECT ROUND(AVG(Delay_Hours),2) AS Overall_Avg_Delay
FROM fedex_shipments;
-- TASK 7.3: Top Performing Warehouse
SELECT Warehouse_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay FROM fedex_shipments
GROUP BY Warehouse_ID ORDER BY Avg_Delay ASC LIMIT 1;
-- TASK 7.4: Best Performing Delivery Agent
SELECT Agent_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay FROM fedex_shipments
GROUP BY Agent_ID ORDER BY Avg_Delay ASC LIMIT 1;
-- TASK 7.5: Most Frequently Used Route
SELECT Route_ID, COUNT(*) AS Shipment_Count FROM fedex_shipments
GROUP BY Route_ID ORDER BY Shipment_Count DESC LIMIT 1;
-- TASK 7.6: Revenue per Warehouse
SELECT Warehouse_ID, ROUND(SUM(Order_Amount),2) AS Revenue FROM fedex_orders
GROUP BY Warehouse_ID ORDER BY Revenue DESC;
-- TASK 7.7: Delivery Type Performance Summary
SELECT Delivery_Type, COUNT(*) AS Total_Orders, ROUND(AVG(Order_Amount),2) AS Avg_Order_Value
FROM fedex_orders GROUP BY Delivery_Type;
-- TASK 7.8: High Delay Risk Routes
SELECT Route_ID, ROUND(AVG(Delay_Hours),2) AS Avg_Delay FROM fedex_shipments
GROUP BY Route_ID HAVING AVG(Delay_Hours) > 5 ORDER BY Avg_Delay DESC;