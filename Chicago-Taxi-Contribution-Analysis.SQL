SELECT 
  taxi_id,
  num_of_trips,
  CASE
    WHEN percentile_rank <= 0.01 THEN "top 1%"
    WHEN percentile_rank <= 0.1 THEN "top 10%"
    WHEN percentile_rank <= 0.2 THEN "top 20%"
    WHEN percentile_rank <= 0.5 THEN "top 50%"
    ELSE "below 50%"
  END AS contribution_category

FROM (
        SELECT
          taxi_id,
          num_of_trips,
          contribution,
          PERCENT_RANk() OVER (ORDER BY contribution DESC) AS percentile_rank
          
        FROM(
                SELECT  
                  taxi_id,
                  COUNT(taxi_id) AS num_of_trips,
                  (SELECT COUNT(unique_key) FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`) AS total_num_trips,
                  COUNT(taxi_id)/(SELECT COUNT(unique_key) FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`) AS contribution
                    

                FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips` 
                GROUP BY taxi_id
                HAVING COUNT(taxi_id) > 0
        )
)
;