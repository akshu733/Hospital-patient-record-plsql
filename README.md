# 🏥 Hospital Patient Record System — Oracle PL/SQL

A end-to-end Hospital Patient Management System built using Oracle PL/SQL,
demonstrating core database programming concepts used in enterprise 
application support environments.

---

## 📌 Project Overview

This system manages complete hospital workflows including patient admissions,
doctor appointments, medical records, billing, and audit logging —
all handled through PL/SQL stored procedures, functions, triggers, and cursors.

---

## 🗄️ Database Structure

| Table | Purpose |
|---|---|
| `patients` | Stores patient details and admission status |
| `doctors` | Stores doctor details and specialization |
| `appointments` | Links patients to doctors with diagnosis notes |
| `medical_records` | Stores treatments and medicines prescribed |
| `bills` | Manages billing and payment status |
| `audit_log` | Auto-logs every action in the system |

---

## ⚙️ PL/SQL Concepts Covered

### ✅ Stored Procedures
- `admit_patient` — Admits a new patient and logs the action
- `discharge_patient` — Discharges a patient and updates status
- `update_bill_status` — Updates payment status of a patient's bill

### ✅ Functions
- `get_total_bill` — Returns total bill amount for a patient
- `get_patient_status` — Returns current admission status of a patient

### ✅ Triggers
- `trg_patient_admit` — Auto-logs every new patient admission
- `trg_prevent_delete` — Blocks deletion of patients with unpaid bills
- `trg_bill_date` — Auto-sets bill date on bill creation

### ✅ Cursors
- Explicit cursor — Generates admitted patients report
- Implicit cursor (FOR loop) — Generates unpaid bills report

### ✅ Exception Handling
- `NO_DATA_FOUND` handled in all procedures and functions
- `OTHERS` exception with `ROLLBACK` for data safety
- Custom error using `RAISE_APPLICATION_ERROR`

---

## 🚀 How to Run

1. Go to [FreeSQL](https://www.freesql.com) or Oracle Live SQL
2. Create a free account
3. Open the SQL Worksheet
4. Paste the contents of `Hospital_Patient_Record_System.sql`
5. Click **Run as Script**

---

## 📊 Sample Output

**Admitted Patients Report:**
===== ADMITTED PATIENTS REPORT =====
ID: 2 | Name: Meena Iyer | Age: 32 | Gender: Female | Status: ADMITTED
ID: 3 | Name: Ravi Shankar | Age: 60 | Gender: Male | Status: ADMITTED
ID: 4 | Name: Suresh Babu | Age: 45 | Gender: Male | Status: ADMITTED
ID: 5 | Name: Meena Iyer | Age: 32 | Gender: Female | Status: ADMITTED
ID: 6 | Name: Ravi Shankar | Age: 60 | Gender: Male | Status: ADMITTED
ID: 7 | Name: Anjali Singh | Age: 35 | Gender: Female | Status: ADMITTED
ID: 21 | Name: Lakshmi Devi | Age: 28 | Gender: Female | Status: ADMITTED
===== END OF REPORT =====
**Unpaid Bills Report:**
===== UNPAID BILLS REPORT =====
Bill ID: 4 | Patient: Suresh Babu | Amount: Rs.25000 | Status: UNPAID
Bill ID: 1 | Patient: Suresh Babu | Amount: Rs.25000 | Status: UNPAID
Bill ID: 6 | Patient: Ravi Shankar | Amount: Rs.12000 | Status: UNPAID
Bill ID: 3 | Patient: Ravi Shankar | Amount: Rs.12000 | Status: UNPAID
===== END OF REPORT =====
**Audit Log:**

Action: ADMIT      | Remarks: New patient admitted: Lakshmi Devi
Action: NEW ADMIT  | Patient ID: 21 | Remarks: Patient automatically logged: Lakshmi Devi
Action: DISCHARGE  | Patient ID: 1  | Remarks: Patient discharged: Suresh Babu
Action: BILL UPDATE| Patient ID: 3  | Remarks: Bill marked as: PAID
