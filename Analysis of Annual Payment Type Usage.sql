-- jumlah penggunaan masing-masing tipe pembayaran secara all time 
-- diurutkan dari yang terfavorit
select 
payment_type,
count(1) as jumlah_pemakaian
from order_payments_dataset
group by 1
order by 2 desc;

-- Menampilkan detail informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun
select
payment_type,
sum(case when tahun = 2016 then jumlah_pemakaian else 0 end) as tahun_2016,
sum(case when tahun = 2017 then jumlah_pemakaian else 0 end) as tahun_2017,
sum(case when tahun = 2018 then jumlah_pemakaian else 0 end) as tahun_2018
from(
    select 
    date_part('year', o.order_purchase_timestamp) as tahun,
    payment_type,
    count(2) as jumlah_pemakaian
    from order_payments_dataset as opd
    join order_dataset as o
    on o.order_id = opd.order_id
    group by 1, 2
) as subq
group by 1
order by 1