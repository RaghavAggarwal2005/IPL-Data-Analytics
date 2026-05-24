-- ============================================================
-- IPL Data Analytics | venue_analysis.sql
-- Venue-wise scoring trends and match outcome patterns
-- Dataset: matches.csv + deliveries.csv
-- ============================================================

-- ============================================================
-- Average first innings score by venue
-- ============================================================

SELECT
    m.venue,
    COUNT(DISTINCT m.id)                    AS matches_played,
    ROUND(AVG(innings_total))               AS avg_first_innings_score,
    MIN(innings_total)                      AS lowest_score,
    MAX(innings_total)                      AS highest_score
FROM (
    SELECT
        match_id,
        SUM(total_runs) AS innings_total
    FROM deliveries
    WHERE inning = 1
    GROUP BY match_id
) first_innings
JOIN matches m ON first_innings.match_id = m.id
GROUP BY m.venue
HAVING COUNT(DISTINCT m.id) >= 5           -- minimum 5 matches
ORDER BY avg_first_innings_score DESC;


-- ============================================================
-- Venue-wise: how often does the chasing team win?
-- ============================================================

SELECT
    venue,
    COUNT(*)                                                    AS total_matches,
    SUM(CASE WHEN toss_decision = 'field'
             AND toss_winner = winner THEN 1 ELSE 0 END)       AS chasing_wins,
    ROUND(
        100.0 * SUM(CASE WHEN toss_decision = 'field'
                         AND toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
    2)                                                          AS chasing_win_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY venue
HAVING COUNT(*) >= 10
ORDER BY chasing_win_pct DESC
LIMIT 15;


-- ============================================================
-- Most matches played at each venue
-- ============================================================

SELECT
    venue,
    COUNT(*)        AS matches_hosted,
    MIN(season)     AS first_season,
    MAX(season)     AS last_season
FROM matches
GROUP BY venue
ORDER BY matches_hosted DESC
LIMIT 15;


-- ============================================================
-- City-wise average score (grouped from venue names)
-- ============================================================

SELECT
    city,
    COUNT(DISTINCT id)          AS matches,
    ROUND(AVG(innings_total))   AS avg_score
FROM (
    SELECT
        m.id,
        m.city,
        SUM(d.total_runs) AS innings_total
    FROM deliveries d
    JOIN matches m ON d.match_id = m.id
    WHERE d.inning = 1
    GROUP BY m.id, m.city
) t
WHERE city IS NOT NULL
GROUP BY city
HAVING COUNT(DISTINCT id) >= 5
ORDER BY avg_score DESC;


-- ============================================================
-- Boundary count by venue (fours and sixes per match)
-- ============================================================

SELECT
    m.venue,
    COUNT(DISTINCT d.match_id)                                          AS matches,
    ROUND(SUM(CASE WHEN d.batsman_runs = 4 THEN 1 ELSE 0 END) * 1.0
          / COUNT(DISTINCT d.match_id), 1)                             AS avg_fours_per_match,
    ROUND(SUM(CASE WHEN d.batsman_runs = 6 THEN 1 ELSE 0 END) * 1.0
          / COUNT(DISTINCT d.match_id), 1)                             AS avg_sixes_per_match
FROM deliveries d
JOIN matches m ON d.match_id = m.id
GROUP BY m.venue
HAVING COUNT(DISTINCT d.match_id) >= 10
ORDER BY avg_sixes_per_match DESC
LIMIT 12;
