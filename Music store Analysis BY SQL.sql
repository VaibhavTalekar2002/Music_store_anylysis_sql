--Q1 : who is senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels desc
limit 1

--Q2 : Which countries have the most Invoices?

select * from invoice
select count(*) as c , billing_country 
from invoice
group by billing_country
order by c desc

--Q3 : WHAT ARE TOP 5 VALUES OF TOTAL INVOICE?

select total from invoice
order by total desc
limit 5


--Q4 : which customer has best customer? which country made most money? write a querry 
--that returns one city that has the largest sums of invoice totals.Returns both the city name and sum of all invoices total.

select * from invoice
select sum(total) as  invoice_total , billing_city
from invoice
group by billing_city
order by  invoice_total desc

--Q5 : FIND best customer.write quessry who has spent the most money

select * from customer
select customer.customer_id, customer.first_name, SUM(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1

--Q6.write querry to return email,first name,last name and genere of all rock music listeners.
--return te list ordered alphabetically by email starting with A

select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
             select track_id from track
             join genre on track.genre_id = genre.genre_id
             where genre.name like 'Rock'
)
order by email;

--Q7.Write the name of artist who written the most songs.write querry that retrurns 
--the artist name and total track count of top 5 rock bands.

SELECT artist.artist_id, artist.name, Count(artist.artist_id) as number_of_songs
from track
JOIN album on album.album_id = track.album_id
JOIN artist on artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
where genre.name LIKE 'Rock'
GROUP BY artist.artist_id
order by number_of_songs desc
limit 5;


--Q8.Return the track name that have long length than average length.return the name and milliseconds
--for each track.order by the song length with the longest song listed first.

select name,milliseconds
from track
WHERE milliseconds > (
              select avg(milliseconds) as avg_track_length
              from track)
order by milliseconds desc;


--Q9.write querry to return customer name , atist name and total spent.

WITH best_selling_artist AS 
	(SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
	 SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


--Q10.FIND most popular genre for each country.

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

--Q11.Write query that determines the customer that has spent the most music for each country.
--write querry that returns the country along with top customer and how much they spent.

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1






