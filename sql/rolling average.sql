WITH dataset_bounds AS (
    SELECT MAX(date::date) as max_date FROM crime_data
),
target_dates AS (
    SELECT generate_series(
        (SELECT max_date FROM dataset_bounds) - INTERVAL '36 days',
        (SELECT max_date FROM dataset_bounds),
        INTERVAL '1 day'
    )::date AS report_date
),
districts AS (
    SELECT DISTINCT district FROM crime_data WHERE district IS NOT NULL
),
daily_thefts AS (
    SELECT date::date AS theft_date, district, COUNT(*) AS theft_count
    FROM crime_data
    WHERE primary_type = 'THEFT'
    GROUP BY date::date, district
),
filled_data AS (
    SELECT t.report_date, d.district, COALESCE(dt.theft_count, 0) AS daily_count
    FROM target_dates t
    CROSS JOIN districts d
    LEFT JOIN daily_thefts dt ON t.report_date = dt.theft_date AND d.district = dt.district
),
rolling_calc AS (
    SELECT
        report_date, district, daily_count,
        ROUND(AVG(daily_count) OVER (
            PARTITION BY district ORDER BY report_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2) AS rolling_avg_7d
    FROM filled_data
)
SELECT * FROM rolling_calc
WHERE report_date >= (SELECT max_date FROM dataset_bounds) - INTERVAL '30 days'
ORDER BY district, report_date DESC;