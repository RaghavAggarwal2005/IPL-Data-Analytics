-- ============================================================
-- IPL Data Analytics | top_batters.sql
-- Top 10 all-time run scorers in IPL history
-- Dataset: deliveries.csv
-- ============================================================

SELECT
    batsman,
    SUM(batsman_runs)                                      AS total_runs,
    COUNT(*)                                               AS balls_faced,
    ROUND(SUM(batsman_runs) * 100.0 / COUNT(*), 2)        AS strike_rate,
    SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END)     AS fours,
    SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END)     AS sixes,
    MAX(batsman_runs)                                      AS highest_in_a_ball
FROM deliveries
GROUP BY batsman
HAVING COUNT(*) >= 500          -- minimum 500 balls faced
ORDER BY total_runs DESC
LIMIT 10;


-- ============================================================
-- Season-wise top scorer
-- ============================================================

SELECT
    m.season,
    d.batsman,
    SUM(d.batsman_runs) AS season_runs
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY m.season, d.batsman
QUALIFY ROW_NUMBER() OVER (PARTITION BY m.season ORDER BY SUM(d.batsman_runs) DESC) = 1
ORDER BY m.season;


-- ============================================================
-- Most centuries (100+ in a single innings)
-- ============================================================

SELECT
    batsman,
    COUNT(*) AS centuries
FROM (
    SELECT
        match_id,
        inning,
        batsman,
        SUM(batsman_runs) AS innings_runs
    FROM deliveries
    GROUP BY match_id, inning, batsman
    HAVING SUM(batsman_runs) >= 100
) centuries_table
GROUP BY batsman
ORDER BY centuries DESC
LIMIT 10;


-- ============================================================
-- Most sixes hit (all-time)
-- ============================================================

SELECT
    batsman,
    SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END) AS sixes,
    SUM(CASE WHEN batsman_runs = 4 THEN 1 ELSE 0 END) AS fours
FROM deliveries
GROUP BY batsman
ORDER BY sixes DESC
LIMIT 10;
