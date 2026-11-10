-- 1: What is the overall size of the business?
select 'total_patients' as metric, count(*) as total from patients union all
select 'total_doctors', count(*) from doctors union all
select 'total_appointment', count(*) from appointments union all
select 'total_admissions', count(*) from admissions union all
select 'total_billed', round(sum(total_amount), 0) from billing union all
select 'insurance_share', round(sum(insurance_covered), 0) from billing ;

-- 2: What share of appointments are completed, cancelled or no-shows?
select status,
		count(*) as appointments,
        round(100 * count(*) / sum(count(*)) over(), 2) as total_pct
from appointments
group by status
order by appointments desc ;

-- 3: Where are our patients and how are they covered?
select city, insurance_type, count(*) as patients
from patients
group by city, insurance_type
order by city, patients desc ;