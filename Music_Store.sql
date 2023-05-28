/*1. Who is the senior most employee based on job title?*/
SELECT CONCAT(first_name , ' ' ,last_name) as Full_name 
FROM employee
WHERE reports_to IS NULL;

/*2. Which countries have the most Invoices?*/
SELECT billing_country,
		COUNT(billing_country) 
FROM invoice
GROUP BY billing_country
ORDER BY billing_country DESC
LIMIT 1;

/*3. What are top 3 values of total invoice?*/
SELECT total
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* 4. Which city has the best customers? We would like to throw a promotional Music
Festival in the city we made the most money. Write a query that returns one city that
has the highest sum of invoice totals. Return both the city name & sum of all invoice
totals*/
SELECT billing_city,SUM(total)
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC
LIMIT 1;

/*5. Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money*/
SELECT i.customer_id,first_name,last_name,SUM(total) FROM customer cu
JOIN invoice i
ON cu.customer_id=i.customer_id
GROUP BY i.customer_id,first_name,last_name
ORDER BY SUM(total) DESC
LIMIT 1;

/*6. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A */
WITH CTE AS(
	SELECT cu.email,first_name,last_name FROM customer cu
	JOIN invoice i ON cu.customer_id=i.customer_id
	JOIN invoice_line il ON i.invoice_id=il.invoice_id
	JOIN track tr ON il.track_id=tr.track_id
	JOIN genre ge ON tr.genre_id=ge.genre_id
	WHERE ge.name='Rock'
)
SELECT email,first_name,last_name FROM CTE
GROUP BY email,first_name,last_name
ORDER BY email;

/*7. Let's invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands*/
SELECT ar.name AS artist,
	COUNT(ge.name) AS total_songs 
FROM album al
JOIN track tr
	ON al.album_id=tr.album_id
JOIN genre ge
	ON tr.genre_id=ge.genre_id
JOIN artist ar
	ON al.artist_id=ar.artist_id 
WHERE ge.name='Rock'
GROUP BY ar.name,ge.name 
ORDER BY COUNT(ge.name) DESC
LIMIT 10;

/* 8. Return all the track names that have a song length longer than the average song length.
Return the Name and Milliseconds for each track. Order by the song length with the
longest songs listed first*/
SELECT tr.name AS song_name,
		tr.milliseconds AS song_length 
FROM track tr
WHERE milliseconds >=(SELECT AVG(milliseconds) FROM track)
ORDER BY song_length DESC;

/*9. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/
WITH best_selling AS(
	SELECT ar.artist_id,
			ar.name AS artist_name,
			SUM(il.unit_price*il.quantity) 
	FROM invoice_line il
	JOIN track tr ON tr.track_id=il.track_id
	JOIN album al ON al.album_id=tr.album_id
	JOIN artist ar ON ar.artist_id=al.album_id	
	GROUP BY ar.artist_id
	ORDER BY 3 DESC
	LIMIT 1
	)
SELECT cu.customer_id,cu.first_name,cu.last_name,bs.artist_name,
		SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer cu ON cu.customer_id=i.customer_id
JOIN invoice_line il ON il.invoice_id=i.invoice_id
JOIN track tr ON tr.track_id=il.track_id
JOIN album al ON al.album_id=tr.album_id
JOIN best_selling bs ON bs.artist_id=al.artist_id
GROUP BY cu.customer_id,cu.first_name,cu.last_name,bs.artist_name
ORDER BY SUM(il.unit_price*il.quantity) DESC

/*10. We want to find out the most popular music Genre for each country. We determine the
most popular genre as the genre with the highest amount of purchases. Write a query
that returns each country along with the top Genre. For countries where the maximum
number of purchases is shared return all Genres*/
WITH popular_genre AS(
	SELECT cu.country,ge.name,ge.genre_id,
			COUNT(il.quantity) AS purchases,
			ROW_NUMBER() OVER(PARTITION BY cu.country ORDER BY COUNT(il.quantity) DESC) AS RowN
	FROM invoice_line il
	JOIN invoice i ON il.invoice_id=i.invoice_id
	JOIN customer cu ON cu.customer_id=i.customer_id
	JOIN track tr ON tr.track_id=il.track_id
	JOIN genre ge ON tr.genre_id=ge.genre_id
	GROUP BY cu.country,ge.name,ge.genre_id
	ORDER BY cu.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowN<=1


/*11. Write a query that determines the customer that has spent the most on music for each
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all
customers who spent this amount */
WITH CTE AS (
	SELECT cu.customer_id,first_name,last_name,billing_country,SUM(total) as total_spent,
			 ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) as x
			 FROM invoice i
			JOIN customer cu on cu.customer_id=i.customer_id
			GROUP BY cu.customer_id,first_name,last_name,billing_country
			ORDER BY 4 ASC, 5 DESC
			)

SELECT * FROM CTE
WHERE x=1

/*TABLES*/
SELECT * FROM album 
SELECT * FROM artist
SELECT * FROM customer 
SELECT * FROM employee 
SELECT * FROM genre 
SELECT * FROM invoice 
SELECT * FROM invoice_line 
SELECT * FROM media_type 
SELECT * FROM playlist 
SELECT * FROM playlist_track 
SELECT * FROM track 