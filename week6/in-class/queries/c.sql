SELECT 
    name,
    avg_cost,
    ROUND(avg_cost * 1.075, 2) AS cost_with_tax
FROM restaurants;
