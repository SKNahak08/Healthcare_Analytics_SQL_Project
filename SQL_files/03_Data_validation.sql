-- quality_Check

-- 1. Appointments pointing to a missing patient
select count(*) as orphan_appointments
from appointments a 
left join patients p
on p.patient_id = a.patient_id
where p.patient_id is null ;

-- 2. Discharge before admission
select count(*) as bad_stays 
from admissions
where discharge_date < admit_date ;

-- 3. Insurance covering more than the bill
select count(*) as bad_coverage
from billing
where insurance_covered > total_amount ;

-- 4. Bill linked to both or neither source
select count(*) as bad_links
from billing
where (appointment_id is null and admission_id is null)
or (appointment_id is not null and admission_id is not null) ;

-- 5. Row counts per table
select 'departments' as tbl, count(*) as rows_cnt from departments union all
select 'doctors', count(*) from doctors union all
select 'patients', count(*) from patients union all
select 'appointments', count(*) from appointments union all
select 'admission', count(*) from admissions union all
select 'billing', count(*) from billing ; 

-- 6. Possible duplicate bookings (same patient, doctor, day)
select patient_id, doctor_id, appointment_date, count(*) as dup_cnt
from appointments
group by patient_id, doctor_id, appointment_date
having count(*) > 1
order by dup_cnt desc
 ;
 
