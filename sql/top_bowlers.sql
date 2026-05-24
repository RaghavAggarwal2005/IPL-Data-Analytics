-- ============================================================
-- IPL Data Analytics | top_bowlers.sql
-- Top 10 all-time wicket takers in IPL history
-- Dataset: deliveries.csv
-- ============================================================

SELECT
    bowler,
    COUNT(*)                                                    AS wickets,
    COUNT(DISTINCT match_id)                                    AS matches,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT match_id), 2)        AS wickets_per_match,
    SUM(total_runs)                                             AS runs_conceded,
    ROUND(SUM(total_runs) * 6.0 / COUNT(DISTINCT over || '-' || match_id), 2) AS economy_rate
FROM deliveries
WHERE dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
  AND dismissal_kind IS NOT NULL
GROUP BY bowler
HAVING COUNT(DISTINCT match_id) >= 20     -- minimum 20 matches
ORDER BY wickets DESC
LIMIT 10;


-- ============================================================
-- Best bowling economy (min 50 overs bowled)
-- ============================================================

SELECT
    bowler,
    ROUND(SUM(total_runs) * 6.0 / COUNT(*), 2)    AS economy_rate,
    SUM(total_runs)                                 AS runs_conceded,
    COUNT(*)                                        AS balls_bowled,
    COUNT(*) / 6                                    AS overs_bowled
FROM deliveries
GROUP BY bowler
HAVING COUNT(*) >= 300      -- minimum 50 overs (300 balls)
ORDER BY economy_rate ASC
LIMIT 10;


-- ============================================================
-- Best bowling figures in a single match (wickets then runs)
-- ============================================================

SELECT
    d.bowler,
    m.season,
    m.team1,
    m.team2,
    COUNT(*) AS wickets_in_match,
    SUM(d.total_runs) AS runs_given
FROM deliveries d
JOIN matches m ON d.match_id = m.id
WHERE d.dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
  AND d.dismissal_kind IS NOT NULL
GROUP BY d.bowler, m.season, m.team1, m.team2, d.match_id
ORDER BY wickets_in_match DESC, runs_given ASC
LIMIT 10;


-- ============================================================
-- Season-wise top wicket taker (Purple Cap race)
-- ============================================================

SELECT
    m.season,
    d.bowler,
    COUNT(*) AS wickets
FROM deliveries d
JOIN matches m ON d.match_id = m.id
WHERE d.dismissal_kind NOT IN ('run out', 'retired hurt', 'obstructing the field')
  AND d.dismissal_kind IS NOT NULL
GROUP BY m.season, d.bowler
QUALIFY ROW_NUMBER() OVER (PARTITION BY m.season ORDER BY COUNT(*) DESC) = 1
ORDER BY m.season;
