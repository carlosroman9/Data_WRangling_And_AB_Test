--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?


--No, in order to calculate metrics like the 30-day view binary. we need the orders table and the events table to view potential purchases or item views caused by the treatment condition.

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa
  
  
  --Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.

SELECT item_id, test_a AS test_assignment,

CASE WHEN test_a IS NOT NULL THEN 'item_test_1'
END AS test_number, 

CASE WHEN test_a IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date

FROM dsv1069.final_assignments_qa

UNION 
SELECT item_id, test_b AS test_assignment, CASE WHEN test_b IS NOT NULL THEN 'item_test_2'
END AS test_number, 

CASE WHEN test_b IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date

FROM dsv1069.final_assignments_qa


UNION 

SELECT item_id, test_c AS test_assignment, CASE WHEN test_c IS NOT NULL THEN 'item_test_3'
END AS test_number, 

CASE WHEN test_c IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date

FROM dsv1069.final_assignments_qa


UNION  

SELECT item_id, test_d AS test_assignment, CASE WHEN test_d IS NOT NULL THEN 'item_test_4'
END AS test_number, 

CASE WHEN test_d IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date

FROM dsv1069.final_assignments_qa


UNION 

SELECT item_id, test_e AS test_assignment, CASE WHEN test_e IS NOT NULL THEN 'item_test_5'
END AS test_number, 

CASE WHEN test_e IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date

FROM dsv1069.final_assignments_qa


UNION 

SELECT item_id, test_f AS test_assignment, CASE WHEN test_f IS NOT NULL THEN 'item_test_6'
END AS test_number, 

CASE WHEN test_f IS NOT NULL THEN '2013-01-05 00:00:00'
END AS test_start_date


FROM 
  dsv1069.final_assignments_qa
  
ORDER BY test_number
  
  
 
 
 -- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT final_assignments.item_id, test_number, test_assignment,
 MAX(CASE WHEN (orders.created_at > final_assignments.test_start_date AND DATE_PART('day', orders.created_at - final_assignments.test_start_date) <= 30)
 THEN 1 ELSE 0 END) AS order_binary
FROM 
  dsv1069.final_assignments AS final_assignments
  
LEFT JOIN 
  dsv1069.orders AS orders

ON 
  orders.item_id = final_assignments.item_id 
  
WHERE
  test_number = 'item_test_2'
  
GROUP BY



-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2


SELECT test_assignment, COUNT(item_id) AS items, SUM(views) AS views, CAST(100*SUM(order_binary)/COUNT(item_id) AS FLOAT) AS viewed_percent,  SUM(views)/COUNT(item_id)

FROM

(SELECT final_assignments.item_id, test_assignment, COUNT(event_id) AS views,
 MAX(CASE WHEN (events.event_time > final_assignments.test_start_date AND DATE_PART('day', events.event_time - final_assignments.test_start_date) <= 30)
 THEN 1 ELSE 0 END) AS order_binary
FROM 
  dsv1069.final_assignments AS final_assignments
  
LEFT JOIN 
 (SELECT event_time, event_id, parameter_name, CASE WHEN parameter_name = 'item_id' THEN CAST (parameter_value AS FLOAT)
ELSE NULL
END AS item_id 

FROM dsv1069.events 

WHERE event_name = 'view_item' AND parameter_name = 'item_id'
) events


ON 
  events.item_id = final_assignments.item_id 
  
WHERE test_number = 'item_test_2'
  
GROUP BY
   final_assignments.item_id, test_assignment
   ORDER BY test_assignment ASC
   
) test_2

GROUP BY test_assignment



--Use the https://thumbtack.github.io/abba/demo/abba.html to compute the lifts in metrics and the p-values for the binary metrics ( 30 day order binary and 30 day view binary) using a interval 95% confidence. 
SELECT
test_assignment, COUNT(order_binary.user_id) AS users, SUM(order_binary) AS total_orders

FROM
(
SELECT final_assignments.item_id, test_number, test_assignment, orders.user_id,
 MAX(CASE WHEN (orders.created_at > final_assignments.test_start_date AND DATE_PART('day', orders.created_at - final_assignments.test_start_date) <= 30)
 THEN 1 ELSE 0 END) AS order_binary
FROM 
  dsv1069.final_assignments AS final_assignments
  
LEFT JOIN 
  dsv1069.orders AS orders

ON 
  orders.item_id = final_assignments.item_id 
  
WHERE
  test_number = 'item_test_2'
  
GROUP BY
   final_assignments.item_id, test_number, test_assignment, orders.user_id
   
   ) order_binary
   
   GROUP BY test_assignment
   final_assignments.item_id, test_number, test_assignment
