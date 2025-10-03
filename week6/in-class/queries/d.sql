SELECT 
    cuisine, 
    COUNT(*) AS restaurant_count
FROM restaurants
GROUP BY cuisine
ORDER BY restaurant_count DESC, cuisine ASC;
