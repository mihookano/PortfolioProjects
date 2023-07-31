-- Selecting the data I want to use 

SELECT track_name, artist_names, album_release_date, track_duration_ms AS track_duration, popularity, artist_genres, tempo 
FROM PortfolioProject..['top_10000_1960-now$']
-- WHERE Label is not null 

-- Finding who has the most amount of popular songs on Spotify 

SELECT artist_names, COUNT(artist_names) AS popular_songs
FROM PortfolioProject..['top_10000_1960-now$']
-- WHERE Label is not null 
GROUP BY artist_names
ORDER BY popular_songs DESC

-- Finding which song is the most popular right now 

SELECT track_name, artist_names, album_release_date, popularity 
FROM PortfolioProject..['top_10000_1960-now$']
ORDER BY Popularity DESC

-- Finding the most popular song released before 2000

SELECT track_name, artist_names, album_release_date, popularity 
FROM PortfolioProject..['top_10000_1960-now$']
WHERE album_release_date < '2000-01-01 00:00:00.000'
ORDER BY Popularity DESC

-- Looking at which music genre is the most popular 

SELECT artist_genres, COUNT(artist_genres) AS popular_genre
FROM PortfolioProject..['top_10000_1960-now$']
WHERE artist_genres is not null 
GROUP BY artist_genres
ORDER BY popular_genre DESC

-- Most frequently used tempo with songs >90 popularity 

SELECT popularity, tempo
	, CAST(SUM(case when tempo > 40 and tempo <= 60 then 1 else 0 end) AS int) AS largo
	, CAST(SUM(case when tempo > 60 and tempo <= 66 then 1 else 0 end) AS int) AS larghetto
	, CAST(SUM(case when tempo > 66 and tempo <= 76 then 1 else 0 end) AS int) AS adagio
	, CAST(SUM(case when tempo > 76 and tempo <= 108 then 1 else 0 end) AS int) AS andante
	, CAST(SUM(case when tempo > 108 and tempo <= 120 then 1 else 0 end) AS int) AS moderato
	, CAST(SUM(case when tempo > 120 and tempo <= 168 then 1 else 0 end) AS int) AS allegro
	, CAST(SUM(case when tempo > 168 and tempo <= 200 then 1 else 0 end) AS int) AS presto
	, CAST(SUM(case when tempo > 200 then 1 else 0 end) AS int) AS prestissimo
FROM PortfolioProject..['top_10000_1960-now$']
WHERE popularity > 90
GROUP BY popularity, tempo
ORDER BY popularity DESC

	-- Creating a temp table to find sum of each tempo category 

--DROP TABLE IF exists #TempoTypeCount
--CREATE TABLE #TempoTypeCount 
--(
	--popularity int, 
	--tempo numeric (7,3), 
	--larghetto_andante int, 
	--moderato_allegro int, 
	--presto_prestissimo int
--)

--INSERT INTO #TempoTypeCount (popularity, tempo, larghetto_andante, moderato_allegro, presto_prestissimo)
--SELECT popularity, tempo, CAST(SUM(case when tempo > 40 and tempo <= 60 then 1 else 0 end) AS int) AS largo
	--, CAST(SUM(case when tempo > 60 and tempo <= 66 then 1 else 0 end) AS int) AS larghetto
	--, CAST(SUM(case when tempo > 66 and tempo <= 76 then 1 else 0 end) AS int) AS adagio
	--, CAST(SUM(case when tempo > 76 and tempo <= 108 then 1 else 0 end) AS int) AS andante
	--, CAST(SUM(case when tempo > 108 and tempo <= 120 then 1 else 0 end) AS int) AS moderato
	--, CAST(SUM(case when tempo > 120 and tempo <= 168 then 1 else 0 end) AS int) AS allegro
	--, CAST(SUM(case when tempo > 168 and tempo <= 200 then 1 else 0 end) AS int) AS presto
	--, CAST(SUM(case when tempo > 200 then 1 else 0 end) AS int) AS prestissimo

--FROM PortfolioProject..['top_10000_1960-now$']
--WHERE popularity > 90
--GROUP BY popularity, tempo
--ORDER BY popularity DESC

	-- Looking at how many top songs are in each tempo ranges 

SELECT SUM(largo) AS largo_count
	, SUM(larghetto) AS larghetto_count
	, SUM(adagio) AS adagio_count
	, SUM(andante) AS andante_count
	, SUM(moderato) AS moderato_count
	, SUM(allegro) AS allegro_count
	, SUM(presto) AS presto_count
	, SUM(prestissimo) AS prestissimo_count
FROM PortfolioProject..[tempo_table$]
GROUP BY largo, larghetto
ORDER BY largo_count, larghetto_count, adagio_count, andante_count, moderato_count, allegro_count, presto_count, prestissimo_count DESC

-- Collecting Tables for Tableau Data Visualization

-- 1. Top 5 artists with the most amount of popular songs 
SELECT TOP(5)artist_names, COUNT(artist_names) AS popular_songs
FROM PortfolioProject..['top_10000_1960-now$']
GROUP BY artist_names
ORDER BY popular_songs DESC

--2. Top 10 most popular songs in 2023
SELECT TOP(10)track_name, artist_names, album_release_date, popularity 
FROM PortfolioProject..['top_10000_1960-now$']
ORDER BY Popularity DESC

--3. Top 10 most popular songs in 2023 released before 2000
SELECT TOP(10)track_name, artist_names, album_release_date, popularity 
FROM PortfolioProject..['top_10000_1960-now$']
WHERE album_release_date < '2000-01-01 00:00:00.000'
ORDER BY Popularity DESC

--4. Most popular music genres 
SELECT TOP(10)artist_genres, COUNT(artist_genres) AS popular_genre
FROM PortfolioProject..['top_10000_1960-now$']
WHERE artist_genres is not null 
GROUP BY artist_genres
ORDER BY popular_genre DESC

--5. Number of songs >90 popularity in tempo ranges
SELECT SUM(largo) AS largo_count
	, SUM(larghetto) AS larghetto_count
	, SUM(adagio) AS adagio_count
	, SUM(andante) AS andante_count
	, SUM(moderato) AS moderato_count
	, SUM(allegro) AS allegro_count
	, SUM(presto) AS presto_count
	, SUM(prestissimo) AS prestissimo_count
FROM PortfolioProject..[tempo_table$]
GROUP BY largo, larghetto
ORDER BY largo_count, larghetto_count, adagio_count, andante_count, moderato_count, allegro_count, presto_count, prestissimo_count DESC