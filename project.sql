-- creating database --
create database project;
use project;
select * from album2;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;
-- Analysis --
-- 1. Who is the senior most employee, find name and job title --
select * from employee;
SELECT  CONCAT_WS(' ',first_name,last_name)Name , title
FROM employee
ORDER BY levels DESC
limit 1;
-- 2.Which countries have the most Invoices?--
WITH CTE AS(
SELECT billing_country ,COUNT(invoice_id)cnt , dense_rank() OVER(ORDER BY COUNT(invoice_id) DESC)ran
FROM invoice
GROUP BY billing_country)
SELECT billing_country , cnt
FROM CTE
WHERE ran = 1;
-- 3.Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
SELECT billing_city, SUM(total)InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC 
limit 1;
-- 4.Who is the best customer? The customer who has spent the most money will be declared the best customer.--
SELECT C.customer_id,CONCAT_WS(' ',C.first_name,C.last_name)Cust_Name, SUM(I.total)TotalSpent
FROM customer C
INNER JOIN invoice I
ON C.customer_id = I.customer_id
GROUP BY C.customer_id, C.first_name, C.last_name
ORDER BY TotalSpent DESC
limit 1;
-- 5.We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
-- For countries where the maximum number of purchases is shared return all Genres.--
select * from invoice;
select * from track;
with CTE as(SELECT (I.billing_country)Country, (G.name)Genre_name, SUM(IL.quantity)No_of_purchase, DENSE_RANK() OVER(PARTITION BY I.billing_country ORDER BY SUM(IL.quantity) DESC)ran
FROM invoice I
INNER JOIN invoice_line IL
ON I.invoice_id = IL.invoice_id
INNER JOIN track T
ON IL.track_id = T.track_id
INNER JOIN genre G
ON T.genre_id = G.genre_id
GROUP BY I.billing_country, G.name)
SELECT Country, Genre_name FROM CTE
WHERE ran = 1;
-- 6.Let's invite the artists who have written the most rock music in our dataset.
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.--
SELECT A.name,COUNT(P.playlist_id)total_track_count
FROM artist A
INNER JOIN album2 AL
ON A.artist_id = AL.artist_id
INNER JOIN track T
ON AL.album_id = T.album_id
INNER JOIN playlist_track P
ON T.track_id = P.track_id
INNER JOIN genre G
ON T.genre_id = G.genre_id
WHERE G.name ='Rock'
GROUP BY A.name
ORDER BY total_track_count DESC 
limit 10;
-- 7.Return all the track names that have a song length longer than the average song length.--
SELECT name, milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;
-- 8.Write query to return the first name, last name, email & Genre of all Rock Music listeners.Return your list ordered alphabetically by email starting with A.--
SELECT DISTINCT C.first_name, C.last_name, C.email, (G.name)genre_name
FROM customer C
INNER JOIN invoice I
ON C.customer_id = I.customer_id
INNER JOIN invoice_line IL
ON I.invoice_id = IL.invoice_id
INNER JOIN track T
ON IL.track_id = T.track_id
INNER JOIN genre G
ON T.genre_id = G.genre_id
WHERE G.name = 'Rock'
ORDER BY C.email;
/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
SELECT CONCAT_WS(' ', C.first_name, C.last_name)cust_name, (A.name)artist_name, SUM(IL.unit_price * IL.quantity)total_spent
FROM customer C
INNER JOIN invoice I
ON C.customer_id = I.customer_id
INNER JOIN invoice_line IL
ON I.invoice_id = IL.invoice_id
INNER JOIN track T
ON IL.track_id = T.track_id
INNER JOIN album AL
ON T.album_id = AL.album_id
INNER JOIN artist A
ON AL.artist_id = A.artist_id
GROUP BY C.first_name, C.last_name, A.name
ORDER BY total_spent DESC;
-- 10.Write a query that determines the customer that has spent the most on music for each country --
-- Write a query that returns the country along with the top customer and how much they spent.--
-- For counties where the top amount spent is shared,provide all cutomers who spent this amount.--
with customer_with_country as( select c.customer_id,first_name,last_name,billing_country,sum(total) as total_spending,
row_number()over(partition by billing_country order by sum(total) desc) as rownumber from invoice i join customer c on c.customer_id=i.customer_id group by 1,2,3,4
order by 4 asc,5 desc)
select * from customer_with_country where rownumber<=1;
