-- ============================================================
-- IPL Data Analytics | phase_analysis.sql
-- Phase-wise run rate analysis: Powerplay / Middle / Death
-- Dataset: deliveries.csv
-- ============================================================

-- ============================================================
-- Average runs per over by phase (all matches combined)
-- ============================================================

SELECT
    CASE
        WHEN over BETWEEN 1  AND 6  THEN '1. Powerplay (1-6)'
        WHEN over BETWEEN 7  AND 15 THEN '2. Middle (7-15)'
        WHEN over BETWEEN 16 AND 20 THEN '3. Death (16-20)'
    END                                     AS phase,
    ROUND(AVG(over_runs), 2)                AS avg_runs_per_over,
    SUM(over_runs)                          AS total_runs,
    COUNT(*)                                AS total_overs
FROM (
    SELECT
        match_id,
        over,
        SUM(total_runs) AS over_runs
    FROM deliveries
    GROUP BY match_id, over
) over_totals
GROUP BY phase
ORDER BY phase;


-- ============================================================
-- Over-by-over average runs (granular, overs 1-20)
-- ============================================================

SELECT
    over,
    ROUND(AVG(over_runs), 2)    AS avg_runs,
    MIN(over_runs)               AS min_runs,
    MAX(over_runs)               AS max_runs
FROM (
    SELECT match_id, over, SUM(total_runs) AS over_runs
    FROM deliveries
    GROUP BY match_id, over
) t
GROUP BY over
ORDER BY over;


-- ============================================================
-- Wickets lost per phase
-- ============================================================

SELECT
    CASE
        WHEN over BETWEEN 1  AND 6  THEN 'Powerplay (1-6)'
        WHEN over BETWEEN 7  AND 15 THEN 'Middle (7-15)'
        WHEN over BETWEEN 16 AND 20 THEN 'Death (16-20)'
    END                         AS phase,
    COUNT(*)                    AS total_wickets,
    ROUND(COUNT(*) * 1.0 /
        (SELECT COUNT(DISTINCT match_id) FROM deliveries), 2)  AS wickets_per_match
FROM deliveries
WHERE dismissal_kind IS NOT NULL
  AND dismissal_kind != ''
GROUP BY phase
ORDER BY phase;


-- ============================================================
-- Team-wise powerplay average (which teams are best at powerplay)
-- ============================================================

SELECT
    m.batting_team,
    ROUND(AVG(pp_runs), 2)      AS avg_powerplay_score
FROM (
    SELECT
        match_id,
        inning,
        SUM(total_runs) AS pp_runs
    FROM deliveries
    WHERE over BETWEEN 1 AND 6
    GROUP BY match_id, inning
) pp
JOIN matches m
  ON pp.match_id = m.id
  AND pp.inning  = 1
GROUP BY m.batting_team
ORDER BY avg_powerplay_score DESC;


-- ============================================================
-- Death over specialists: batters with best SR in overs 16-20
-- ============================================================

SELECT
    batsman,
    SUM(batsman_runs)                                           AS death_runs,
    COUNT(*)                                                    AS balls,
    ROUND(SUM(batsman_runs) * 100.0 / COUNT(*), 2)             AS death_strike_rate,
    SUM(CASE WHEN batsman_runs = 6 THEN 1 ELSE 0 END)          AS sixes
FROM deliveries
WHERE over BETWEEN 16 AND 20
GROUP BY batsman
HAVING COUNT(*) >= 100          -- minimum 100 balls in death overs
ORDER BY death_strike_rate DESC
LIMIT 10;
