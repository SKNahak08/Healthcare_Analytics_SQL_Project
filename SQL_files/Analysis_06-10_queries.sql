-- 6: Is revenue growing month over month?
with monthly as (
	select date_format(bill_date, '%Y-%m') as ym,
			sum(total_amount) as revenue
	from billing
    group by date_format(bill_date, '%Y-%m')
)
select ym,
		round(revenue, 0) as revenue,
        round(lag(revenue) over (order by ym), 0) as prev_month,
        round(100 * (revenue - lag(revenue) over(order by ym)) /
				lag(revenue) over (order by ym), 2) as mom_growth_pct
from monthly
order by ym ;

-- 7: How much consultation revenue do loose, and where?
select dep.department_name,
		count(*) as booked,
        sum(a.status = 'No-Show') as no_shows,
        sum(a.status = 'Cancelled') as cancelled,
        round(100 * sum(a.status <> 'Completed') / count(*), 2) as leakage_pct,
        round(sum(case when a.status <> 'Completed' then d.consultation_fee
						else 0 end), 0) as est_revenue_lost
from appointments a
join doctors d
	on d.doctor_id = a.doctor_id
join departments dep
	on dep.department_id = d.department_id
group by dep.department_name
order by est_revenue_lost desc;

-- 8: WHich diagnoses keep patients longesdt and cost the most?
select ad.diagnosis,
		count(*) as admissions,
        round(avg(datediff(ad.discharge_date, ad.admit_date)), 1) as avg_los_days,
        round(avg(b.total_amount), 0) as avg_bill,
        round(sum(b.total_amount), 0) as total_billed
from admissions ad 
join billing b
	on b.admission_id = ad.admission_id
group by ad.diagnosis
order by total_billed desc ;

-- 9: Which age groups generate the most visits and revenue?
select age_group,
		count(distinct patient_id) as patients,
        count(*) as bills,
        round(sum(total_amount), 0) as revenue,
        round(avg(total_amount), 0) as avg_bill
from (
	select p.patient_id, b.total_amount,
			case
				when timestampdiff(year, p.dob, '2025-12-31') < 18 then '0-17'
                when timestampdiff(year, p.dob, '2025-12-31') < 35 then '18-34'
                when timestampdiff(year, p.dob, '2025-12-31') < 50 then '35-49'
                when timestampdiff(year, p.dob, '2025-12-31') < 65 then '50-64'
                else '65+'
			end as age_group
	from patients p
    join billing b 
		on b.patient_id = p.patient_id
	) t
    group by age_group
    order by age_group;
    
-- 10. How much is paid by insurance vs patients, and how much is unpaid?
select p.insurance_type,
		count(*) as bills,
        round(sum(b.total_amount), 0) as billed,
        round(sum(b.insurance_covered), 0) as insurer_share,
        round(sum(b.total_amount - b.insurance_covered), 0) as patient_share,
        round(sum(case when b.payment_status <> 'Paid'
						then b.total_amount else 0 end), 0) as unpaid_total,
		round(100 * sum(case when b.payment_status <> 'Paid' then 2 else 0 end)
					/count(*), 2) as unpaid_bill_pct
from billing b
join patients p
	on p.patient_id = b.patient_id
    group by p.insurance_type
    order by billed desc ;