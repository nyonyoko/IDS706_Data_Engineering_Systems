-- 1. 
DROP TABLE IF EXISTS athlete_event CASCADE;
DROP TABLE IF EXISTS noc_region;

CREATE TABLE noc_region (
  noc   varchar(10) PRIMARY KEY,
  region text,
  note   text
);

CREATE TABLE athlete_event (
  athlete_event_id serial PRIMARY KEY,
  id      integer,
  name    text,
  sex     varchar(1),
  age     integer,
  height  numeric,
  weight  numeric,
  team    text,
  noc     varchar(10),
  games   text,
  year    integer,
  season  varchar(10),
  city    text,
  sport   text,
  event   text,
  medal   text
);

-- Minimal DML just for INSERT and UPDATE demonstration
INSERT INTO noc_region (noc, region, note)
VALUES ('SGP', NULL, 'Override to Singapore');

UPDATE noc_region
SET region = 'Singapore'
WHERE noc = 'SGP';

-- In real, I used the client side \copy command to import the data from csv. 
\copy noc_region FROM 'data/noc_regions.csv' WITH (FORMAT csv, NULL 'NA', HEADER);
\copy athlete_event (id, name, sex, age, height, weight, team, noc, games, year, season, city, sport, event, medal) FROM 'data/athlete_events.csv' WITH (FORMAT csv, NULL 'NA', HEADER);

-- 2. 
SELECT name, team, height
FROM athlete_event
WHERE noc = 'SGP'
ORDER BY height DESC NULLS LAST
LIMIT 5;

-- 3.
SELECT team, year, COUNT(*) AS medal_count
FROM athlete_event
WHERE medal IS NOT NULL
  AND year = 2008
GROUP BY team, year
HAVING COUNT(*) >= 5
ORDER BY medal_count DESC, team
LIMIT 5;

-- 4. 
SELECT
  COALESCE(ae.noc, nr.noc) AS noc,
  nr.region,
  COUNT(ae.id) AS athlete_rows
FROM athlete_event ae
FULL OUTER JOIN noc_region nr
  ON ae.noc = nr.noc
GROUP BY COALESCE(ae.noc, nr.noc), nr.region
ORDER BY athlete_rows DESC
LIMIT 5;

-- 5.
CREATE OR REPLACE VIEW medal_event AS
SELECT
  ae.*,
  CASE
    WHEN ae.noc = 'SGP' THEN 'Singapore'
    ELSE COALESCE(nr.region, ae.team)
  END AS region
FROM athlete_event ae
LEFT JOIN noc_region nr
  ON nr.noc = ae.noc
WHERE ae.medal IS NOT NULL;

-- 6.
WITH golds AS (
  SELECT region, event, COUNT(*) AS gold_medals
  FROM medal_event
  WHERE event ILIKE '%fencing%' AND medal = 'Gold'
  GROUP BY region, event
),
ranked AS (
  SELECT
    region,
    event,
    gold_medals,
    RANK() OVER (PARTITION BY event ORDER BY gold_medals DESC) AS rnk
  FROM golds
  WHERE gold_medals > 0
)
SELECT region, event, gold_medals, rnk
FROM ranked
WHERE rnk <= 3
ORDER BY event, rnk, region
LIMIT 5;

-- 7.
SELECT event,
       year,
       height,
       LAG(height) OVER (PARTITION BY event ORDER BY year) AS previous_height
FROM medal_event
WHERE event ILIKE '%pole vault%'
  AND medal = 'Gold'
  AND height IS NOT NULL
ORDER BY event, year
LIMIT 5;

-- 8.
WITH yearly AS (
  SELECT
    region,
    year,
    COUNT(*)                                                     AS total_medals,
    COUNT(*) FILTER (WHERE medal = 'Gold')                       AS golds,
    COUNT(*) FILTER (WHERE medal = 'Silver')                     AS silvers,
    COUNT(*) FILTER (WHERE medal = 'Bronze')                     AS bronzes
  FROM medal_event
  GROUP BY region, year
)
SELECT
  region,
  year,
  golds, silvers, bronzes, total_medals,
  SUM(total_medals) OVER (PARTITION BY region ORDER BY year
                          ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rolling_total
FROM yearly
ORDER BY region, year
LIMIT 5;
