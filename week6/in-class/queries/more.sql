SELECT 
    cuisine,
    ROUND(AVG(rating), 2) AS avg_rating,
    ROUND(AVG(avg_cost), 2) AS avg_cost
FROM restaurants
GROUP BY cuisine
HAVING AVG(rating) > 4.3
ORDER BY avg_rating DESC, avg_cost ASC;
