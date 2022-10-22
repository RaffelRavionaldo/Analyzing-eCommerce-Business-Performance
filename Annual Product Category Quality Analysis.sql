-- revenue per tahun
create table revenue_per_year as
select date_part('year', order_purchase_timestamp) as tahun,
sum(otd.price + otd.freight_value) as jumlah_revenue
from order_items_dataset as otd
join order_dataset as od on od.order_id = otd.order_id
where od.order_status = 'delivered'
group by 1
order by 1;

-- jumlah cancel order per tahun
create table cancel_order_per_year as
select 
date_part('year', order_purchase_timestamp) as tahun,
count(order_status) as jumlah_cancel
from order_dataset as od
where od.order_status = 'canceled'
group by 1
order by 1;

-- top kategori yang menghasilkan revenue terbesar per tahun
create table top_product_revenue_per_year as
select 
RANK() OVER(PARTITION BY DATE_PART('year', order_purchase_timestamp)
				    ORDER BY SUM(otd.price + otd.freight_value) DESC
					) AS rank,
date_part('year', order_purchase_timestamp) as tahun,
p.product_category_name as product,
sum(otd.price + otd.freight_value) as jumlah_revenue
from order_items_dataset as otd
join order_dataset as od on od.order_id = otd.order_id
join products_dataset as p on p.product_id = otd.product_id
where od.order_status = 'delivered'
group by 2,3
order by 1,2 asc
limit 3;

-- top kategori yang mengalami cancel order terbanyak per tahun
create table top_product_getcanceled_per_year as
select 
    tahun,
    product,
    jumlah_cancel
from (select
        rank() over(partition by date_part('year', order_purchase_timestamp)
                   order by count(od.order_status) desc)
                   as rank,
        date_part('year', order_purchase_timestamp) as tahun,
        p.product_category_name as product,
        count(od.order_status) as jumlah_cancel
        from order_items_dataset as otd
        join order_dataset as od on od.order_id = otd.order_id
        join products_dataset as p on p.product_id = otd.product_id
        where od.order_status = 'delivered'
        group by 2,3) as subq
where rank = 1;

-- mengambil semua informasi dari keempat tabel

select 
tpc.tahun,
tpc.product as produk_dengan_jumlah_cancel_terbanyak,
tpc.jumlah_cancel as jumlah_cancel_produk,
co.jumlah_cancel as total_jumlah_cancel,
tpr.product as produk_dengan_revenue_terbanyak,
tpr.jumlah_revenue as revenue_product,
rp.jumlah_revenue
from 
top_product_getcanceled_per_year as tpc
join cancel_order_per_year as co on co.tahun = tpc.tahun 
join top_product_revenue_per_year as tpr on tpr.tahun = tpc.tahun
join revenue_per_year as rp on rp.tahun = tpc.tahun

