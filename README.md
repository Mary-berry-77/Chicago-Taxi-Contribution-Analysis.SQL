# Chicago-Taxi-Contribution-Analysis.SQL
This repository contains SQL queries and analysis related to Chicago taxi trips, specifically focusing on the contribution of individual taxis to the total number of trips. The project aims to identify trends and insights by calculating each taxi's trip count and their respective contribution percentages.

## Data Sources
- **Chicago Taxi Trips Dataset**: [BigQuery Public Dataset](https://bigquery-public-data.googleapis.com). This dataset contains records of taxi trips in Chicago.
  


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
