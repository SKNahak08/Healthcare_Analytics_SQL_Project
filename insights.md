# Insights: MediCore Health Network


This document records the main observations from the 16 SQL analyses carried out on the `medicore_health` database. The focus was on hospital revenue, appointment outcomes, patient readmissions, doctor workload and unpaid bills.

The database contains synthetic hospital data. The figures below describe this dataset only.

Total billed ₹11.01 crore | 3,000 patients | 15,000 appointments | 1,500 admissions

These are the findings that matter most for running the hospital and growing the business.

---

## 1. Collect older outstanding bills (Q16, Q10)

₹3.26 crore (about 30% of billing) is still outstanding, and 88% of it (₹2.88 crore) is older than 90 days. The share of bills unpaid is similar for Insured, Self-Pay and Corporate patients (41-44%), so this is a billing process issue and not specific to one group.

**Action:** Start a follow-up routine for bills older than 60 days, with reminder calls and instalment plans for large inpatient bills.

## 2. Convert more booked appointments into visits (Q2, Q7)

70.5% of booked appointments were completed. The other 29.5% were cancelled (19.5%) or no-shows (10.0%), worth about ₹38.9 lakh in consultation fees. The rate is similar in all departments, and Cardiology has the largest value (₹11.3 lakh) because it has the most bookings.

**Action:** Send SMS or WhatsApp reminders with an easy reschedule option, starting with Cardiology.

## 3. Inpatient care drives revenue (Q4, Q5)

Inpatient stays account for 92% of revenue. Neurology (15.0%) and Cardiology (14.7%) are the top departments, and the other six each contribute 10-13%. Dr. Rajesh Gupta (Neurology) is the top doctor with ₹83 lakh.

**Action:** Plan capacity around bed availability and admissions.

## 4. Focus on high-value patients (Q14)

779 of 2,902 billed patients (26.8%) generate 80% of revenue, mainly through inpatient care.

**Action:** Offer these patients a follow-up and care programme to keep them connected to the hospital.

## 5. Balance Cardiology workload (Q15)

Dr. Anita Rao completed 1,434 visits against a department average of 1,190, while Dr. Vikram Shah completed 946. Every other department is within 10% of its average.

**Action:** Direct more new-patient bookings to Dr. Shah so patients are seen sooner.

## 6. Readmissions (Q12)

The 30-day readmission rate is 2.67% (40 of 1,500 admissions).

**Action:** Break readmissions down by diagnosis and add post-discharge follow-up calls where repeat stays are most common.

---

*Notes: Aging is measured as of 31 Dec 2025 from bill date, since there are no payment dates. The ₹38.9 lakh includes consultation fees only. The dataset is simulated (see the README), so these results show my analysis method rather than conclusions about a real hospital.*
