-- 11. Who is the highest-earning doctor in every department?
with doc_rev as (
	select d.doctor_id, d.doctor_name, dep.department_name,
			sum(v.total_amount) as revenue
	from billing_detail v
	join doctors d
		on d.doctor_id = v.doctor_id
	join departments dep
		on dep.department_id = d.department_id
	group by d.doctor_id, d.doctor_name, dep.department_name
),
ranked as (
	select *, rank() over (partition by department_name order by revenue desc) as rnk
	from doc_rev
)
select department_name, doctor_name, round(revenue, 0) as revenue, rnk
from ranked
where rnk = 1
order by revenue desc ;

-- 12. What percentage of admissions are repeat admissions within 30 days of discharge?
with ordered as (
	select admission_id, patient_id, admit_date, discharge_date, diagnosis,
			lag(discharge_date) over (partition by patient_id order by admit_date) as prev_discharge
	from admissions
),
flagged as (
	select *, 
			case when prev_discharge is not null
				and datediff(admit_date, prev_discharge) between 0 and 30
				then 1 else 0 end as is_readmit
	from ordered
)
select count(*) as total_admissions,
		sum(is_readmit) as readmissions_30d,
        round(100 * sum(is_readmit) / count(*), 2) as readmission_rate_pct
from flagged ;

-- 13. Of patients who first visited in a given month, how many revisits in later month ?
with visits as  (
	select distinct patient_id, 
			date_sub(appointment_date, Interval dayofweek(appointment_date) - 1 day) as visit_month
	from appointments
    where status = 'Completed'
),
first_visit as (
	select patient_id, min(visit_month) as cohort_month
	from visits
	group by patient_id
)
select f.cohort_month, 
		timestampdiff(month, f.cohort_month, v.visit_month) as months_since_first,
        count(distinct v.patient_id) as active_patients
from first_visit f 
join visits v
	on v.patient_id = f.patient_id
where timestampdiff(month, f.cohort_month, v.visit_month) <= 6
group by f.cohort_month, months_since_first
order by f.cohort_month, months_since_first ;

-- 14. How many patients make up 80% of revenue ?
with patient_rev as (
	select patient_id, sum(total_amount) as revenue
    from billing
    group by patient_id
),
cum as (
	select patient_id, revenue,
			sum(revenue) over (order by revenue desc, patient_id) as running_rev,
            sum(revenue) over() as total_rev
	from patient_rev
)
select count(*) as patient_for_80pct,
		(select count(*) from patient_rev) as total_billed_patients,
        round(100 * count(*) / (select count(*) from patient_rev), 2) as pct_of_patients
from cum
where running_rev - revenue < 0.8 * total_rev ;

-- 15. Which doctors are overloaded or under-used compared with their department?
with workload as (
	select d.doctor_id, d.doctor_name, dep.department_name,
			count(*) as completed_visits
	from appointments a 
    join doctors d 
		on d.doctor_id = a.doctor_id
	join departments dep 
		on dep.department_id = d.department_id
	where a.status = 'Completed'
    group by d.doctor_id, d.doctor_name, dep.department_name
)
select department_name, doctor_name, completed_visits,
		round(avg(completed_visits) over (partition by department_name), 0) as dept_avg,
		case 
			when completed_visits > 1.10 * avg(completed_visits) over (partition by department_name) then 'Over-utilized'
			when completed_visits < 0.90 * avg(completed_visits) over (partition by department_name) then 'Under-utilized'
			else 'Balances'
		end as load_flag
from workload
order by department_name, completed_visits desc ;

-- 16. How old is the money we have not collected?
select 
	case	
		when datediff('2025-12-31', bill_date) <= 30 then  '0-30 days'
		when datediff('2025-12-31', bill_date) <= 60 then '31-60 days'
		when datediff('2025-12-31', bill_date) <= 90 then '61-90 days'
		else '90+ days'
	end as aging_bucket,
    count(*) as bills,
    round(sum(total_amount), 0) as outstanding_amount,
    round(100 * sum(total_amount) / sum(sum(total_amount)) over (), 2) as pct_of_outstanding
from billing
where payment_status in ('Pending', 'Overdue')
group by aging_bucket
order by aging_bucket ;