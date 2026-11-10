-- 01_schema.sql | Medicore Health Network
CREATE DATABASE IF NOT EXISTS medicore_health;
use medicore_health;

create table departments (
department_id int primary key auto_increment,
department_name VARCHAR(50) not null unique,
floor_no int
);
create table doctors (
doctor_id int primary key auto_increment,
doctor_name varchar(80) not null,
department_id int not null,
specialization varchar(80),
experience_years int,
consultation_fee decimal(10,2) not null,
join_date date,
foreign key (department_id) references departments(department_id)
);

create table patients (
patient_id int primary key auto_increment,
patient_name varchar(80) not null,
gender char(1),
dob date,
city varchar(40),
insurance_type enum('Insured', 'Self-Pay', 'Corporate') not null,
registration_date date
);

create table appointments (
appointment_id int primary key auto_increment,
patient_id int not null,
doctor_id int not null,
appointment_date date not null,
status enum('Completed', 'Canceled', 'No-Show') not null,
visit_type enum('New', 'Follw-up') not null,
foreign key (patient_id) references patients(patient_id),
foreign key (doctor_id) references doctors(doctor_id)
);

create table admissions (
admission_id int primary key auto_increment,
patient_id int not null,
doctor_id int not null,
admit_date date not null,
discharge_date date not null,
diagnosis varchar(60),
ward_type enum('General', 'Semi-Private', 'Private', 'ICU') not null,
foreign key (patient_id) references patients(patient_id),
foreign key (doctor_id) references doctors(doctor_id)
);

create table billing (
bill_id int primary key auto_increment,
patient_id int not null,
appointment_id int not null,
admission_id int not null,
bill_date date not null,
total_amount decimal(12,2) not null,
insurance_covered decimal(12,2) not null default 0,
payment_status enum('Paid', 'Pending', 'Overdue') not null,
foreign key (patient_id) references patients(patient_id),
foreign key (appointment_id) references appointments(appointment_id),
foreign key (admission_id) references admissions(admission_id),
check ((appointment_id is not null and admission_id is null)
		or (appointment_id is null and admission_id is not null))
);