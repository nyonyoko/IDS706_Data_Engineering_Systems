[![Python Template for IDS706](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml/badge.svg)](https://github.com/nyonyoko/IDS706_Data_Engineering_Systems/actions/workflows/main.yml)

# IDS 706 – Week 7: Build Your Personal SQL Guidebook

This assignment demonstrates advanced SQL queries on a **PostgreSQL** database containing a few tables about athletes and their performances in Olympic games. All commands were executed using the PostgreSQL command-line interface after connecting to the database.

---

# 1) Schema Setup (CREATE TABLE) + Minimal DML (INSERT, UPDATE)

**What it does:** Creates the two tables I use and inserts and updates one entry.

```sql
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
```

**Output:**

```sql
INSERT INTO noc_region (noc, region, note)
VALUES ('SGP', NULL, 'Override to Singapore');
INSERT 0 1

UPDATE noc_region
SET region = 'Singapore'
WHERE noc = 'SGP';
UPDATE 1
```

# 2) Basics: SELECT + FROM + WHERE + ORDER BY + LIMIT

**What it does:** Finds the 5 tallest athletes from NOC “SGP”.

```sql
SELECT name, team, height
FROM athlete_event
WHERE noc = 'SGP'
ORDER BY height DESC NULLS LAST
LIMIT 5;
```

**Output:**

```sql
          name          |   team    | height
------------------------+-----------+--------
 Wong Yew Tong          | Singapore |    194
 Lee Wung Yew           | Singapore |    188
 Lee Wung Yew           | Singapore |    188
 Lee Wung Yew           | Singapore |    188
 Joseph Isaac Schooling | Singapore |    184
(5 rows)
```

---

# 3) Aggregation with GROUP BY and HAVING

**What it does:** Counts medals by team for a given year, filters to only teams with at least 5 medals, and shows the top 5 teams.

```sql
SELECT team, year, COUNT(*) AS medal_count
FROM athlete_event
WHERE medal IS NOT NULL
  AND year = 2008
GROUP BY team, year
HAVING COUNT(*) >= 5
ORDER BY medal_count DESC, team
LIMIT 5;
```

**Output:**

```sql
     team      | year | medal_count
---------------+------+-------------
 United States | 2008 |         309
 China         | 2008 |         170
 Australia     | 2008 |         149
 Russia        | 2008 |         142
 Germany       | 2008 |          96
(5 rows)
```

---

# 4) Join Variety: FULL OUTER JOIN to Find Unmapped Codes (Data Quality Check)

**What it does:** Uses a `FULL OUTER JOIN` to show any `noc` present in one table but missing in the other and shows the top 5 nocs ordered by athelete_rows.

```sql
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
```

**Output:**

```sql
 noc | region  | athlete_rows
-----+---------+--------------
 USA | USA     |        18853
 FRA | France  |        12758
 GBR | UK      |        12256
 ITA | Italy   |        10715
 GER | Germany |         9830
(5 rows)
```

---

# 5) Data Cleaning View with CASE/COALESCE + LEFT JOIN

**What it does:** Keeps only rows with a medal and standardizes `region`: force ‘Singapore’ for SGP; otherwise fallback to `nr.region`, then to `ae.team` if region is NULL.

```sql
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
```

**Output:**

```sql
CREATE VIEW
```

---

# 6) Window Function (RANK): Top 3 Regions per Fencing Event by Golds

**What it does:** Uses a **Common Table Expression (CTE)** and a **window function** to identify the **top-ranked regions** in each fencing event based on the number of **gold medals** they have won.

1. The first CTE (`golds`) counts gold medals per `region` and `event` for all fencing events.
2. The second CTE (`ranked`) assigns a **rank** within each event using the `RANK()` window function, ordering by gold medal count in descending order.
3. The outer query filters to only show the **top 3 ranked regions per event** and then applies a `LIMIT 5` to display just the first five rows of the ranked results for easier viewing.

```sql
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
```

**Output:**

```sql
 region |                  event                  | gold_medals | rnk
--------+-----------------------------------------+-------------+-----
 France | Fencing Men's Foil, Individual          |          10 |   1
 Italy  | Fencing Men's Foil, Individual          |           9 |   2
 Poland | Fencing Men's Foil, Individual          |           2 |   3
 Russia | Fencing Men's Foil, Individual          |           2 |   3
 France | Fencing Men's Foil, Masters, Individual |           1 |   1
(5 rows)
```

---

# 7) Window Function (LAG): Previous Year’s Gold Medalist Height in Pole Vault

**What it does:** Shows each pole vault gold medalist’s height alongside the previous year’s height for the same event.

```sql
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
```

**Output:**

```sql
           event            | year | height | previous_height
----------------------------+------+--------+-----------------
 Athletics Men's Pole Vault | 1906 |    170 |
 Athletics Men's Pole Vault | 1908 |    170 |             170
 Athletics Men's Pole Vault | 1908 |    178 |             170
 Athletics Men's Pole Vault | 1912 |    188 |             178
 Athletics Men's Pole Vault | 1920 |    172 |             188
(5 rows)
```

---

# 8) CTE + Windowed Rolling Sum + FILTER Aggregates

**What it does:**

- `CTE` computes yearly counts of each medal type per region.
- Uses `FILTER` to split gold/silver/bronze in one pass (extra feature).
- Computes a rolling total of all medals by region across years.

```sql
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
```

**Output:**

```sql
   region    | year | golds | silvers | bronzes | total_medals | rolling_total
-------------+------+-------+---------+---------+--------------+---------------
 Afghanistan | 2008 |     0 |       0 |       1 |            1 |             1
 Afghanistan | 2012 |     0 |       0 |       1 |            1 |             2
 Algeria     | 1984 |     0 |       0 |       2 |            2 |             2
 Algeria     | 1992 |     1 |       0 |       1 |            2 |             4
 Algeria     | 1996 |     2 |       0 |       1 |            3 |             7
(5 rows)
```
