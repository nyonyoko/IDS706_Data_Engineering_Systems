-- 1) Insert Duke Tech for 2014
INSERT OR REPLACE INTO university_rankings (institution, country, year, world_rank, score)
VALUES ('Duke Tech', 'USA', 2014, 350, 60.5);

-- 2) How many Japan universities in the global top 200 in 2013?
SELECT COUNT(*) AS japan_top200_2013
FROM university_rankings
WHERE country = 'Japan'
  AND year = 2013
  AND world_rank <= 200;

-- 3) Oxford 2014 score was miscalculated: +1.2 points
UPDATE university_rankings
SET score = score + 1.2
WHERE institution = 'University of Oxford'
  AND year = 2014;

-- (confirm the new value)
SELECT institution, year, score
FROM university_rankings
WHERE institution = 'University of Oxford' AND year = 2014;

-- 4) Remove 2015 records with score < 45
DELETE FROM university_rankings
WHERE year = 2015
  AND score < 45;

-- (verify none remain)
SELECT COUNT(*) AS remaining_below_45_in_2015
FROM university_rankings
WHERE year = 2015 AND score < 45;
