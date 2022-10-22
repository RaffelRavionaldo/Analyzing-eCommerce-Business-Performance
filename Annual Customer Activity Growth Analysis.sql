-- Mencari Monthly Active User pertahun
with mau as(
    select 
    date_part('year', o.order_purchase_timestamp) as tahun,
    date_part('month',o.order_purchase_timestamp) as bulan,
    count(distinct c.customer_unique_id) as jumlah_aktif
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 1,2
)

select tahun, round(avg(jumlah_aktif),2) as mau_average
from mau
group by 1;

-- Mencari jumlah customer baru pertahun
with customer_baru as(
    select
    min(date_part('year',o.order_purchase_timestamp)) as pembelian_pertama,
    c.customer_unique_id as customer
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 2
)

select 
pembelian_pertama as tahun,
count(distinct customer) as customer_baru
from customer_baru
group by 1
order by 1;


-- Mencari customer yang melakukan repeat order pertahun
with repeat_order as(
    select 
    date_part('year', o.order_purchase_timestamp) as tahun,
    c.customer_unique_id as customer,
    count(o.order_id) as jumlah_order
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 1,2
    having count(o.order_id) > 1
)

select tahun, count(distinct customer) as repeat_order
from repeat_order
group by 1;


-- rata-rata frekuensi order untuk setiap tahun.
with frekuensi_order as(
    select 
    c.customer_unique_id as customer,
    date_part('year', o.order_purchase_timestamp) as tahun,
    count(o.order_id) as frekuensi_beli
    from order_dataset as o
    inner join customers_dataset as c
    on c.customer_id = o.customer_id
    group by 1,2
)

select tahun, round(avg(frekuensi_beli),2) as average_order
from frekuensi_order
group by 1
order by 1;

-- menggabungkan keempat matrik
with mau as(
    select tahun, round(avg(jumlah_aktif),2) as mau_rata_rata
    from(
    select 
    date_part('year', o.order_purchase_timestamp) as tahun,
    date_part('month',o.order_purchase_timestamp) as bulan,
    count(distinct c.customer_unique_id) as jumlah_aktif
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 1,2) as subq
    group by 1
),

customer_baru as(
    select pembelian_pertama as tahun, count(distinct customer) as jumlah_customer_baru
    from(
    select
    min(date_part('year',o.order_purchase_timestamp)) as pembelian_pertama,
    c.customer_unique_id as customer
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 2) as subq
    group by 1
),

repeat_order as(
    select tahun, count(distinct customer) as jumlah_repeat_order
    from(
    select 
    date_part('year', o.order_purchase_timestamp) as tahun,
    c.customer_unique_id as customer,
    count(o.order_id) as jumlah_order
    from customers_dataset as c
    inner join order_dataset as o
    on c.customer_id = o.customer_id
    group by 1,2
    having count(o.order_id) > 1) as subq
    group by 1
),

frekuensi_order as(
    select  tahun, round(avg(frekuensi_beli),2) as average_order
    from(
    select 
    c.customer_unique_id as customer,
    date_part('year', o.order_purchase_timestamp) as tahun,
    count(o.order_id) as frekuensi_beli
    from order_dataset as o
    inner join customers_dataset as c
    on c.customer_id = o.customer_id
    group by 1,2) as subq
    group by 1
)

select m.tahun, m.mau_rata_rata,
cb.jumlah_customer_baru, 
ro.jumlah_repeat_order, 
fo.average_order
from mau as m
inner join customer_baru as cb on cb.tahun = m.tahun
inner join repeat_order as ro on ro.tahun = m.tahun
inner join frekuensi_order as fo on fo.tahun = m.tahun


