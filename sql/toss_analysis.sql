-- ============================================================
-- IPL Data Analytics | toss_analysis.sql
-- Toss decision impact on match outcomes
-- Dataset: matches.csv
-- ============================================================

-- ============================================================
-- Overall toss decision win rate (bat vs field)
-- ============================================================

SELECT
    toss_decision,
    COUNT(*)                                                                        AS total_matches,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END)                          AS won_after_winning_toss,
    ROUND(
        100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
    2)                                                                              AS win_percentage
FROM matches
WHERE winner IS NOT NULL      -- exclude no-result / D/L matches
GROUP BY toss_decision
ORDER BY win_percentage DESC;


-- ============================================================
-- Season-wise toss decision trend
-- ============================================================

SELECT
    season,
    SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END)   AS chose_field,
    SUM(CASE WHEN toss_decision = 'bat'   THEN 1 ELSE 0 END)   AS chose_bat,
    COUNT(*)                                                     AS total_matches
FROM matches
GROUP BY season
ORDER BY season;


-- ============================================================
-- Team-wise: how often they win toss AND win the match
-- ============================================================

SELECT
    toss_winner                                                                     AS team,
    COUNT(*)                                                                        AS tosses_won,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END)                          AS matches_won_after_toss,
    ROUND(
        100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
    2)                                                                              AS conversion_rate_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY toss_winner
ORDER BY conversion_rate_pct DESC;


-- ============================================================
-- Venue-wise: does toss matter more at certain grounds?
-- ============================================================

SELECT
    venue,
    COUNT(*)                                                                        AS matches_played,
    ROUND(
        100.0 * SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) / COUNT(*),
    2)                                                                              AS toss_win_match_win_pct
FROM matches
WHERE winner IS NOT NULL
GROUP BY venue
HAVING COUNT(*) >= 10         -- minimum 10 matches at venue
ORDER BY toss_win_match_win_pct DESC
LIMIT 15;


-- ============================================================
-- Chasing vs defending win rate (all seasons combined)
-- ============================================================

SELECT
    CASE
        WHEN toss_decision = 'field' AND toss_winner = winner THEN 'Chased successfully'
        WHEN toss_decision = 'field' AND toss_winner != winner THEN 'Chase failed'
        WHEN toss_decision = 'bat'   AND toss_winner = winner THEN 'Defended successfully'
        WHEN toss_decision = 'bat'   AND toss_winner != winner THEN 'Defence failed'
    END                         AS outcome,
    COUNT(*)                    AS matches
FROM matches
WHERE winner IS NOT NULL
GROUP BY outcome
ORDER BY matches DESC;
