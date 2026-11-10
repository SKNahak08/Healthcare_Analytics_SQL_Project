-- One unified billing view (OPD + IPD), tied to the responsible doctor
create or replace view billing_detail as
select b.bill_id, b.patient_id, b.bill_date, b.total_amount, b.insurance_covered,
		b.total_amount - b.insurance_covered as patient_payable,
        b.payment_status,
        case when b.admission_id is null then 'Outpatient' else 'Inpatient' end as bill_type,
        coalesce(a.doctor_id, ad.doctor_id) as doctor_id
from billing b
left join appointments a
	on a.appointment_id = b.appointment_id
left join admissions ad
	on ad.admission_id = b.admission_id ;
    
