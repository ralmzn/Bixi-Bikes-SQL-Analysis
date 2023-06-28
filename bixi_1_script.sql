/*

Bixi Project Deliverable 1
Rafael Almazan
2023-04-12
Brainstation

*/


# using the bixi schema
USE bixi;

####################################
############ Question 1 ############
####################################

# checking if there were any trips started in 2016 but ended in 2017
SELECT *
FROM trips
WHERE (YEAR(start_date) = 2016)
AND (YEAR(end_date) = 2017);
# none, there were no trips that went over new years

# checking which months were used 
SELECT DISTINCT MONTH(start_date) FROM trips;
# months dec - march, not used, not in service

# The total number of trips for the year of 2016 and 2017
SELECT
	YEAR(start_date) AS tripYear,
    COUNT(*) AS no_of_trips
FROM trips
GROUP BY tripYear;
#HAVING (tripYear = 2016); --> removed to combine 1.1 and 1.2
# 3917401 trips in 2016
# 4666765 trips in 2017

# The total number of trips for the year of 2016 broken down by month
SELECT 
	YEAR(start_date) AS tripYear,
    MONTHNAME(start_date) AS tripMonth,
    COUNT(*) AS no_of_trips
FROM trips
GROUP BY tripYear, tripMonth
HAVING (tripYear = 2016)
ORDER BY tripMonth;

# The total number of trips for the year of 2017 broken down by month
SELECT 
	YEAR(start_date) AS tripYear,
    MONTHNAME(start_date) AS tripMonth,
    COUNT(*) AS no_of_trips
FROM trips
GROUP BY tripYear, tripMonth
HAVING (tripYear = 2017)
ORDER BY tripMonth;

# Average number of trips a day for each year-month combination in the dataset
#CREATE TABLE working_table1 - for when working table was created
SELECT 
	YEAR(start_date) AS tripYear,
    MONTHNAME(start_date) AS tripMonth,
    COUNT(*) AS no_of_trips,
	COUNT(*) / COUNT(DISTINCT DATE(start_date)) AS avgTrips_Day #total trips in the month by number of days in month
FROM trips
GROUP BY tripMonth, tripYEAR
ORDER BY start_date;
#create table as working_table1

#trying a different way for double checking

#subquery no of trips per day
SELECT
	CAST(start_date AS DATE) AS date,
    COUNT(*) AS no_of_trips
FROM trips
GROUP BY date;

#putting it together
SELECT 
	YEAR(date) AS tripYear,
    MONTHNAME(date) AS tripMonth,
    AVG(no_of_trips)
FROM 
(
SELECT
	CAST(start_date AS DATE) AS date,
    COUNT(*) AS no_of_trips
FROM trips
GROUP BY date
) AS tripByDay
GROUP BY tripMonth, tripYear
ORDER BY date;

####################################
############ Question 2 ############
####################################
# in trips.is_member, 1 is Yes (is member) and 0 is No (not member)
# according to binary logic https://www.computerhope.com/jargon/b/binary.htm

# The total number of trips in the year 2017 broken down by membership status (member/non-member)
SELECT 
	COUNT(*) AS no_of_trips,
    CASE
		WHEN is_member = 1 THEN "member"
		WHEN is_member = 0 THEN "non member"
	END AS membership
FROM trips
WHERE (YEAR(start_date) = 2017)
GROUP BY membership;

# The percentage of total trips by members for the year 2017 broken down by month
SELECT 
	((COUNT(CASE
			WHEN is_member = 1 THEN 1
            ELSE NULL
			END) / COUNT(*)) * 100) as percentMembers,
            MONTHNAME(start_date) AS tripMonth,
            YEAR(start_date) AS tripYear
FROM trips
WHERE (YEAR(start_date) = 2017)
GROUP BY tripMonth, tripYear;

# The percentage of total trips by non-members for the year 2017 broken down by month
SELECT 
	ROUND(((COUNT(CASE
					WHEN is_member = 0 THEN 1
					ELSE NULL
					END) / COUNT(*)) * 100), 1) as percent_nonMembers,
	MONTHNAME(start_date) AS tripMonth,
    YEAR(start_date) AS tripYear
FROM trips
WHERE (YEAR(start_date) = 2017)
GROUP BY tripMonth, tripYear
ORDER BY start_date;

####################################
############ Question 3 ############
####################################
/*

1. The demand for Bixi bikes is at its peak during the months of June-September 
with July being the highest since this is peak summer months. These months had 
the highest average trips per day. 2017 had more trips these months than 2016

2. If I were to give a promotion to non-members to convert them to be members,
it would be during those summer months. This is because there is a higher percentage
of non-members using bixi bikes during the summer months and so there is more exposure
to the public. Due to the larger non-member portion of users during these months, There would
be a higher chance of luring more membership signups because they might think 
"i'm using the bikes anyway, might as well keep using them" and offering them a membership
when they are most happy with the product (summer) will be of great help to luring them insert


*/

####################################
############ Question 4 ############
####################################
# What are the names of the 5 most popular starting stations?
# Without subquery
SELECT
	s.name AS stationName,
    COUNT(t.id) AS startCount
FROM stations AS s
JOIN trips AS t
ON s.code = t.start_station_code
GROUP BY stationName
ORDER BY startCount DESC
LIMIT 5;

# With subquery
SELECT
	COUNT(t.id) AS startCount,
    t.start_station_code AS startCode
FROM trips AS t
GROUP BY startCode;

SELECT
	s.name AS stationName,
    startCount
FROM
(
SELECT
	COUNT(t.id) AS startCount,
    t.start_station_code AS startCode
FROM trips AS t
GROUP BY startCode
) AS startTrip
JOIN stations AS s
ON s.code = startCode
ORDER BY startCount DESC
LIMIT 5;

# Way faster with the subquery, 10.91sec vs 2.48sec
# Faster because sql does not have to iterate through a whole other table, and will just go 
# through a portion of that table (subquery)
# less data to process (only processing the necessary data)

####################################
############ Question 5 ############
####################################
# station Mackay / de Maisonneuve subquery
SELECT code, name FROM stations
WHERE (name = 'Mackay / de Maisonneuve');

# Checking if there are rides that start in one time of day and end in another
SELECT 
	CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
       ELSE 'night'
	END AS startTimeOfDay,
	CASE
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
       ELSE 'night'
	END AS endTimeOfDay
    #COUNT(*) AS count
FROM trips
HAVING (startTimeOfDay != endTimeOfDay);

# Two Queries, one for start time and one for end time

# Start time
SELECT  
	CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN 'morning'
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN 'afternoon'
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN 'evening'
       ELSE 'night'
	END AS startTimeOfDay,
    COUNT(*) as no_of_rides
FROM 
(
SELECT code, name FROM stations
WHERE (name = 'Mackay / de Maisonneuve')
) As mackayStation
JOIN trips
ON  mackayStation.code = trips.start_station_code
GROUP BY startTimeOfDay
ORDER BY no_of_rides;
# evening, afternoon, morning, night

# End time
SELECT  
	CASE
       WHEN HOUR(end_date) BETWEEN 7 AND 11 THEN 'morning'
       WHEN HOUR(end_date) BETWEEN 12 AND 16 THEN 'afternoon'
       WHEN HOUR(end_date) BETWEEN 17 AND 21 THEN 'evening'
       ELSE 'night'
	END AS endTimeOfDay,
    COUNT(*) as no_of_rides
FROM 
(
SELECT code, name FROM stations
WHERE (name = 'Mackay / de Maisonneuve')
) As mackayStation
JOIN trips
ON  mackayStation.code = trips.start_station_code
GROUP BY endTimeOfDay
ORDER BY no_of_rides;
# evening, afternoon, morning, night

# Most rides in mackay/ de maisonneuve start or end in the evening
# followed by the afternoon, morning, then night
# Hypothesis: Bixi bike ridership is higher in the evening and afternoon 
# because the bikes are likely to be used for leisure or commuting in Mackay
# Mackay is part of downtown montreal and so traffic could be a big reason Bixi
# bikes are used in the evening. Analysis looks at the 'evening' starting at around 5PM
# which is when most people would come off work and when rush hour is at it's peak
# incentivising bike rides to beat the traffic. The afternoon and evening is also 
# the time where most people have the most free time to leisurely ride bixi bikes
# This is shown through the data as both start and end times were predominantly
# in the afternoon and evening.

# also near universities, students commuting in the evening/afternoon, after classes
# place is in downtown near offices and other buildings
# close to public transit

####################################
############ Question 6 ############
####################################
# List all the stations for which at least 10% of trips are round trips
# Round trips are those that start and end in the same station. 
# This time we will only consider stations with at least 500 starting trips

# Count the number of starting trips per station
# used to create a view of all starting trips per station
#CREATE VIEW startingTrips_station AS
SELECT
	no_of_trips_started,
    s.name
FROM 
(
SELECT 
	COUNT(*) AS no_of_trips_started, 
	start_station_code 
FROM trips
GROUP BY start_station_code
) AS tripCount
JOIN stations as s
ON tripCount.start_station_code = s.code
ORDER BY no_of_trips_started DESC;

# Counts number of round trips per station
# Create a view of the round trips per each station
#CREATE VIEW roundTrips_station AS
SELECT
	no_of_trips,
    s.name
FROM 
(
SELECT 
	COUNT(*) AS no_of_trips, 
	start_station_code,
    end_station_code
FROM trips
WHERE (start_station_code = end_station_code)
GROUP BY start_station_code
) AS tripCount
JOIN stations as s
ON tripCount.start_station_code = s.code
ORDER BY no_of_trips DESC;

# Calculate the fraction of round trips to the total 
# number of starting trips for each station
# joined previously made views above
SELECT
	round((rs.no_of_trips / ss.no_of_trips_started)*100, 2) AS roundTrip_percent,
    rs.name,
    rs.no_of_trips,
    ss.no_of_trips_started
FROM roundtrips_station AS rs
JOIN startingtrips_station as ss
ON rs.name = ss.name
ORDER BY roundtrip_percent DESC;

# Filter down to stations with at least 500 trips originating from them
# and having at least 10% of their trips as round trips
SELECT
	round((rs.no_of_trips / ss.no_of_trips_started)*100, 2) AS roundTrip_percent,
    rs.name,
    rs.no_of_trips AS roundTrips,
    ss.no_of_trips_started AS tripsStarted
FROM roundtrips_station AS rs
JOIN startingtrips_station as ss
ON rs.name = ss.name
HAVING (tripsStarted >= 500)
AND (roundTrip_percent >= 10)
ORDER BY roundTrip_percent DESC;

# Where would you expect to find stations with a high fraction of round trips?
# you would expect stations near parks to have a high fraction of round trips
# people would want to take the bike for a leisure ride along the part, especially
# big parks where there are paths and bikeways. Since these stations are near the parks,
# riders have a higher chance of just taking the bike to the park rather than using it to commute
# when they use it to commute they're trying to get from one place to another, and this is 
# not the case when they ride it in a park, they take it to the park and bring it back to 
# the closest station.



# Extra analysis for curiosity

# Which stations had the longest bike rides
SELECT
	start_station_code,
    duration_sec
FROM trips;

SELECT
	s.name,
    AVG(duration_sec) AS avgDurationSec,
    AVG(duration_sec) * 60 AS avgDurationMin
FROM
(
SELECT
	start_station_code,
    duration_sec
FROM trips
) AS tripDuration
JOIN stations AS s
ON tripDuration.start_station_code = s.code
GROUP BY s.code
ORDER BY avgDurationMin DESC
LIMIT 10;

# Months with the longest rides
SELECT
	MONTHNAME(start_date) AS month,
    YEAR(start_date),
    AVG(duration_sec) AS avgDurationSec,
    AVG(duration_sec) / 60 AS avgDurationMin
FROM trips
GROUP BY month, YEAR(start_date)
ORDER BY start_date;

# Months with the longest rides
# filtered out the rides less than 5 mins
SELECT
	MONTHNAME(start_date) AS month,
    YEAR(start_date),
    AVG(duration_sec) AS avgDurationSec,
    AVG(duration_sec) / 60 AS avgDurationMin
FROM trips
WHERE duration_sec > 120
GROUP BY month, YEAR(start_date)
ORDER BY start_date;

# Calculate the fraction of non-round trips
# EXTRA for business report
SELECT
	AVG(((ss.no_of_trips_started-rs.no_of_trips) / ss.no_of_trips_started)*100) AS NONroundTrip_percent
FROM roundtrips_station AS rs
JOIN startingtrips_station as ss
ON rs.name = ss.name
ORDER BY NONroundtrip_percent DESC;


    







