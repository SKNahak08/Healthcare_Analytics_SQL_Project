-- seed_data

use medicore_health;
set session cte_max_recursion_depth = 20000;

-- departments
Insert into departments (department_name, floor_no)
values ('Cardiology', 1), ('Orthopedics', 2), ('General Medicine', 1), ('Pediatrics', 3), 
		('Neurology', 4), ('Gynecology', 3), ('Dermatology', 2), ('Emergency', 0) ;
        
-- Doctors
Insert into doctors (doctor_name, department_id, specialization, experience_years, consultation_fee, join_date)
values 
('Dr. Anita Rao',1,'Interventional Cardiologist',15,1200,'2015-04-01'),
('Dr. Vikram Shah',1,'Cardiologist',9,1000,'2018-06-15'),
('Dr. Rohan Mehta',2,'Orthopedic Surgeon',12,900,'2016-02-10'),
('Dr. Sneha Iyer',2,'Sports Medicine',6,800,'2021-01-20'),
('Dr. Arjun Nair',3,'Physician',18,600,'2012-09-01'),
('Dr. Kavita Desai',3,'Physician',7,500,'2020-03-12'),
('Dr. Meera Kulkarni',4,'Pediatrician',10,700,'2017-07-07'),
('Dr. Sameer Khan',4,'Neonatologist',14,900,'2014-11-25'),
('Dr. Priya Menon',5,'Neurologist',11,1100,'2016-05-30'),
('Dr. Rajesh Gupta',5,'Neurosurgeon',20,1500,'2010-01-18'),
('Dr. Neha Kapoor',6,'Gynecologist',13,800,'2015-08-08'),
('Dr. Farah Siddiqui',6,'Obstetrician',8,750,'2019-10-02'),
('Dr. Karthik Reddy',7,'Dermatologist',5,600,'2022-02-14'),
('Dr. Isha Verma',7,'Cosmetologist',4,550,'2023-01-09'),
('Dr. Sanjay Patil',8,'Emergency Physician',9,700,'2018-12-03'),
('Dr. Lakshmi Pillai',8,'Trauma Specialist',16,1000,'2013-06-21');

-- Patients
INsert into patients (patient_name, gender, dob, city, insurance_type, registration_date)
with recursive seq as (
	select 1 as n union all select n+1 from seq where n < 3000
    )
select concat('Patient_', n),
		If(rand() < 0.5, 'M', 'F'),
        DATE_SUB('2025-12-31', interval floor(300 + rand()*29700) day),
        ELT(1 + floor(rand()*6), 'Bengaluru', 'Mumbai','Delhi','Chennai','Hyderabad','Pune'), 
        ELT(1 + floor(rand()*10), 'Insured','Insured','Insured','Insured', 
								'Self-Pay','Self-Pay','Self-Pay', 'Corporate','Corporate','Corporate'),
		date_add('2022-01-01', interval floor(rand()*730) day)
from seq ;
        
-- APPOINTMENTS
Insert into appointments (patient_id, doctor_id, appointment_date, status, visit_type)
with recursive seq as (
	select 1 as n union all select n+1 from seq where n < 15000
    )
select 
		1 + floor(3000 * pow(rand(), 1.6)),
		1 + floor(16 * pow(rand(), 1.4)),
        date_add('2024-01-01', interval floor(730*pow(rand(), 0.85)) day),
        ELT(1 + floor(rand() * 10), 'Completed','Completed','Completed','Completed',
                                   'Completed','Completed','Completed','Cancelled','Cancelled','No-Show'),
		if(rand() < 0.6, 'New', 'Follow-up') 
from seq;

-- Admissions
Insert into admissions (patient_id, doctor_id, admit_date, discharge_date, diagnosis, ward_type)
with recursive seq as (
	select 1 as n union all select n+1 from seq where n < 1500
    )
select 1 + floor(rand() * 3000),
		1 + floor(rand() * 16),
        date_add('2024-01-01', interval (n*37) % 700 day),
        date_add('2024-01-01', interval ((n*37) % 700 ) + 1 + (n*5) % 14 day),
        ELT(1+ floor(rand() * 8), 'Diabetes','Hypertension','Pneumonia','Fracture',
                                  'Heart Disease','Appendicitis','Kidney Stone','Dengue'),
		ELT(1+ floor(rand() *10), 'General','General','General','General',
                                   'Semi-Private','Semi-Private','Semi-Private',
                                   'Private','Private','ICU')
from seq ;

-- Billing : Outpatient
Insert into billing (patient_id, appointment_id, admission_id, bill_date, total_amount, insurance_covered, payment_status)
select 
		a.patient_id, a.appointment_id, null, a.appointment_date, d.consultation_fee,
        round(d.consultation_fee * case	p.insurance_type
										when 'Insured' then 0.60
                                        when 'Corporate' then 0.80
                                        else 0
									end, 2 ),
		ELT(1 + floor(rand() * 10), 'Paid','Paid','Paid','Paid','Paid','Paid','Paid','Paid','Pending','Overdue')
from appointments a
join doctors d on d.doctor_id = a.doctor_id
join patients p on a.patient_id = p.patient_id
where a.status = 'Completed' ;

-- Billing : Inpatient
Insert into billing (patient_id, appointment_id, admission_id, bill_date, total_amount, insurance_covered, payment_status)
select ad.patient_id, null, ad.admission_id, ad.discharge_date,
		datediff(discharge_date, ad.admit_date)*
			case ad.ward_type when 'General' then 3000
							  when 'Semi-Private' then 5000
                              when 'Private' then 8000
                              else 15000
			end
            + 5000 + (ad.admission_id * 7919) % 40000,
		round((datediff(discharge_date, ad.admit_date)*
			case ad.ward_type when 'General' then 3000
							  when 'Semi-Private' then 5000
                              when 'Private' then 8000
                              else 15000
			end
            + 5000 + (ad.admission_id * 7919) % 40000)
            * case p.insurance_type when 'Insured' then 0.70
									when 'Corporate' then 0.85
									else 0
			end, 2),
		ELT(1 + ad.admission_id % 10, 'Paid','Paid','Paid','Paid','Paid','Paid','Paid','Pending','Pending','Overdue')
from admissions ad 
join patients p 
on p.patient_id = ad.patient_id ;