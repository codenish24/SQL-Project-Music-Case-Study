/* Q1: Who is the senior most employee based on job title? */
select title, first_name, last_name
from employee
order by levels desc
limit 1

/* Q2: Which countries have the most Invoices? */
select billing_country, sum(total) as c
from invoice
group by billing_country
order by c desc

/* Q3: What are top 3 values of total invoice? */
select total
from invoice
order by total desc

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
select billing_city, sum(total) as total_invoice
from invoice
group by billing_city
order by total_invoice desc
limit 1

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total)as spent_money
from customer
join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by spent_money desc
limit 1

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
select email, first_name, last_name, genre.name
from customer
join invoice
on customer.customer_id = invoice.customer_id
join invoice_line
on invoice.invoice_id = invoice_line.invoice_id
join track
on invoice_line.track_id = track.track_id
join genre
on track.genre_id = genre.genre_id
where genre.name like 'Rock'

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from track
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
select name, milliseconds
from track
where milliseconds > (select avg(milliseconds) as avg_lengh_tack from track)
order by milliseconds desc

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
with best_selling_artist as(
select artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
from invoice_line
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by artist.artist_id
order by total_sales desc
limit 1)
select c.customer_id, c.first_name, c.last_name, bsa.name, sum(il.unit_price*il.quantity)
from invoice i 
join customer c on i.customer_id = c.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album a on t.album_id = a.album_id
join best_selling_artist bsa on a.artist_id = bsa.artist_id
group by 1,2,3,4
order by 5 desc;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
with popular_genre as(
	select count(il.quantity) as purchase, c.country, g.name, g.genre_id,
    row_number() over(partition by c.country order by count(il.quantity)) as rowno 
	from invoice_line il
	join invoice i on il.invoice_id = i.invoice_id
	join customer c on i.customer_id = c.customer_id
	join track t on il.track_id = t.track_id
	join genre g on t.genre_id = g.genre_id
	group by 2,3,4
	order by 2 asc , 1 desc
)
select * from popular_genre 
where rowno <=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with Customter_with_country as(
	
	select c.customer_id, c.first_name, c.last_name, i.billing_country, sum(total) as spending,
	row_number() over(partition by i.billing_country order by sum(total) desc) as rowno
	from invoice i
	join customer c on i.customer_id = c.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)
select * from Customter_with_country
where rowno<=1

