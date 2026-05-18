-- ============================================================
--   HOSPITAL PATIENT RECORD SYSTEM
--   Author  : Akshitha Lakshmi C
--   Tech    : Oracle PL/SQL
--   Purpose : End-to-end patient management system built as
--             a resume project demonstrating PL/SQL concepts
-- ============================================================


-- ============================================================
-- STEP 1: CREATE TABLES
-- ============================================================

CREATE TABLE doctors (
    doctor_id       NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    doctor_name     VARCHAR2(100) NOT NULL,
    specialization  VARCHAR2(100),
    phone           VARCHAR2(15),
    email           VARCHAR2(100)
);

CREATE TABLE patients (
    patient_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_name  VARCHAR2(100) NOT NULL,
    age           NUMBER,
    gender        VARCHAR2(10),
    phone         VARCHAR2(15),
    address       VARCHAR2(200),
    admitted_date DATE DEFAULT SYSDATE,
    status        VARCHAR2(20) DEFAULT 'ADMITTED'
);

CREATE TABLE appointments (
    appointment_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id       NUMBER REFERENCES patients(patient_id),
    doctor_id        NUMBER REFERENCES doctors(doctor_id),
    appointment_date DATE DEFAULT SYSDATE,
    diagnosis        VARCHAR2(300),
    notes            VARCHAR2(500)
);

CREATE TABLE medical_records (
    record_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id  NUMBER REFERENCES patients(patient_id),
    doctor_id   NUMBER REFERENCES doctors(doctor_id),
    treatment   VARCHAR2(300),
    medicines   VARCHAR2(300),
    record_date DATE DEFAULT SYSDATE
);

CREATE TABLE bills (
    bill_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id   NUMBER REFERENCES patients(patient_id),
    total_amount NUMBER(10,2) DEFAULT 0,
    paid_status  VARCHAR2(10) DEFAULT 'UNPAID',
    bill_date    DATE DEFAULT SYSDATE
);

CREATE TABLE audit_log (
    log_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    action      VARCHAR2(100),
    patient_id  NUMBER,
    action_date DATE DEFAULT SYSDATE,
    remarks     VARCHAR2(300)
);


-- ============================================================
-- STEP 2: INSERT SAMPLE DATA
-- ============================================================

-- Doctors
INSERT INTO doctors (doctor_name, specialization, phone, email)
VALUES ('Dr. Ramesh Kumar', 'Cardiology', '9876543210', 'ramesh@hospital.com');

INSERT INTO doctors (doctor_name, specialization, phone, email)
VALUES ('Dr. Priya Sharma', 'Neurology', '9845012345', 'priya@hospital.com');

INSERT INTO doctors (doctor_name, specialization, phone, email)
VALUES ('Dr. Anil Verma', 'Orthopedics', '9900112233', 'anil@hospital.com');

-- Patients
INSERT INTO patients (patient_name, age, gender, phone, address)
VALUES ('Suresh Babu', 45, 'Male', '9812345678', 'Bangalore');

INSERT INTO patients (patient_name, age, gender, phone, address)
VALUES ('Meena Iyer', 32, 'Female', '9823456789', 'Mysore');

INSERT INTO patients (patient_name, age, gender, phone, address)
VALUES ('Ravi Shankar', 60, 'Male', '9834567890', 'Chennai');

-- Appointments
INSERT INTO appointments (patient_id, doctor_id, diagnosis, notes)
VALUES (1, 1, 'Chest Pain', 'ECG required');

INSERT INTO appointments (patient_id, doctor_id, diagnosis, notes)
VALUES (2, 2, 'Migraine', 'MRI scan advised');

INSERT INTO appointments (patient_id, doctor_id, diagnosis, notes)
VALUES (3, 3, 'Knee Pain', 'X-ray required');

-- Medical Records
INSERT INTO medical_records (patient_id, doctor_id, treatment, medicines)
VALUES (1, 1, 'Angioplasty', 'Aspirin, Clopidogrel');

INSERT INTO medical_records (patient_id, doctor_id, treatment, medicines)
VALUES (2, 2, 'Pain Management', 'Ibuprofen, Sumatriptan');

INSERT INTO medical_records (patient_id, doctor_id, treatment, medicines)
VALUES (3, 3, 'Physiotherapy', 'Diclofenac Gel');

-- Bills
INSERT INTO bills (patient_id, total_amount, paid_status)
VALUES (1, 25000, 'UNPAID');

INSERT INTO bills (patient_id, total_amount, paid_status)
VALUES (2, 8000, 'PAID');

INSERT INTO bills (patient_id, total_amount, paid_status)
VALUES (3, 12000, 'UNPAID');

COMMIT;


-- ============================================================
-- STEP 3: STORED PROCEDURES
-- ============================================================

-- Procedure 1: Admit a New Patient
CREATE OR REPLACE PROCEDURE admit_patient (
    p_name    IN VARCHAR2,
    p_age     IN NUMBER,
    p_gender  IN VARCHAR2,
    p_phone   IN VARCHAR2,
    p_address IN VARCHAR2
) AS
BEGIN
    INSERT INTO patients (patient_name, age, gender, phone, address)
    VALUES (p_name, p_age, p_gender, p_phone, p_address);

    INSERT INTO audit_log (action, remarks)
    VALUES ('ADMIT', 'New patient admitted: ' || p_name);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient ' || p_name || ' admitted successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error admitting patient: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Procedure 2: Discharge a Patient
CREATE OR REPLACE PROCEDURE discharge_patient (
    p_patient_id IN NUMBER
) AS
    v_name VARCHAR2(100);
BEGIN
    SELECT patient_name INTO v_name
    FROM patients
    WHERE patient_id = p_patient_id;

    UPDATE patients
    SET status = 'DISCHARGED'
    WHERE patient_id = p_patient_id;

    INSERT INTO audit_log (action, patient_id, remarks)
    VALUES ('DISCHARGE', p_patient_id, 'Patient discharged: ' || v_name);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Patient ' || v_name || ' discharged successfully.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Patient ID ' || p_patient_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

-- Procedure 3: Update Bill Payment Status
CREATE OR REPLACE PROCEDURE update_bill_status (
    p_patient_id IN NUMBER,
    p_status     IN VARCHAR2
) AS
BEGIN
    UPDATE bills
    SET paid_status = p_status
    WHERE patient_id = p_patient_id;

    INSERT INTO audit_log (action, patient_id, remarks)
    VALUES ('BILL UPDATE', p_patient_id, 'Bill marked as: ' || p_status);

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Bill status updated to ' || p_status || ' for Patient ID: ' || p_patient_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error updating bill: ' || SQLERRM);
        ROLLBACK;
END;
/


-- ============================================================
-- STEP 4: FUNCTIONS
-- ============================================================

-- Function 1: Calculate Total Bill of a Patient
CREATE OR REPLACE FUNCTION get_total_bill (
    p_patient_id IN NUMBER
) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT NVL(SUM(total_amount), 0)
    INTO v_total
    FROM bills
    WHERE patient_id = p_patient_id;

    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

-- Function 2: Get Patient Status
CREATE OR REPLACE FUNCTION get_patient_status (
    p_patient_id IN NUMBER
) RETURN VARCHAR2 AS
    v_status VARCHAR2(20);
BEGIN
    SELECT status
    INTO v_status
    FROM patients
    WHERE patient_id = p_patient_id;

    RETURN v_status;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Patient Not Found';
END;
/


-- ============================================================
-- STEP 5: TRIGGERS
-- ============================================================

-- Trigger 1: Auto log when a new patient is admitted
CREATE OR REPLACE TRIGGER trg_patient_admit
AFTER INSERT ON patients
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (action, patient_id, remarks)
    VALUES ('NEW ADMIT', :NEW.patient_id,
            'Patient automatically logged: ' || :NEW.patient_name);
END;
/

-- Trigger 2: Prevent deleting a patient who has unpaid bills
CREATE OR REPLACE TRIGGER trg_prevent_delete
BEFORE DELETE ON patients
FOR EACH ROW
DECLARE
    v_unpaid NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_unpaid
    FROM bills
    WHERE patient_id = :OLD.patient_id
    AND paid_status = 'UNPAID';

    IF v_unpaid > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
        'Cannot delete patient. Unpaid bills exist for Patient ID: '
        || :OLD.patient_id);
    END IF;
END;
/

-- Trigger 3: Auto set bill date when bill is created
CREATE OR REPLACE TRIGGER trg_bill_date
BEFORE INSERT ON bills
FOR EACH ROW
BEGIN
    :NEW.bill_date := SYSDATE;
    INSERT INTO audit_log (action, patient_id, remarks)
    VALUES ('BILL CREATED', :NEW.patient_id,
            'New bill created for Patient ID: ' || :NEW.patient_id);
END;
/


-- ============================================================
-- STEP 6: CURSORS
-- ============================================================

-- Cursor 1: Admitted Patients Report (Explicit Cursor)
DECLARE
    CURSOR cur_patients IS
        SELECT patient_id, patient_name, age, gender, status
        FROM patients
        WHERE status = 'ADMITTED';

    v_id     patients.patient_id%TYPE;
    v_name   patients.patient_name%TYPE;
    v_age    patients.age%TYPE;
    v_gender patients.gender%TYPE;
    v_status patients.status%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== ADMITTED PATIENTS REPORT =====');
    OPEN cur_patients;
    LOOP
        FETCH cur_patients INTO v_id, v_name, v_age, v_gender, v_status;
        EXIT WHEN cur_patients%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || v_id ||
            ' | Name: ' || v_name ||
            ' | Age: ' || v_age ||
            ' | Gender: ' || v_gender ||
            ' | Status: ' || v_status
        );
    END LOOP;
    CLOSE cur_patients;
    DBMS_OUTPUT.PUT_LINE('===== END OF REPORT =====');
END;
/

-- Cursor 2: Unpaid Bills Report (Implicit Cursor / FOR loop)
DECLARE
    CURSOR cur_unpaid IS
        SELECT b.bill_id, p.patient_name, b.total_amount, b.paid_status
        FROM bills b
        JOIN patients p ON b.patient_id = p.patient_id
        WHERE b.paid_status = 'UNPAID';
BEGIN
    DBMS_OUTPUT.PUT_LINE('===== UNPAID BILLS REPORT =====');
    FOR rec IN cur_unpaid LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Bill ID: ' || rec.bill_id ||
            ' | Patient: ' || rec.patient_name ||
            ' | Amount: Rs.' || rec.total_amount ||
            ' | Status: ' || rec.paid_status
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('===== END OF REPORT =====');
END;
/


-- ============================================================
-- STEP 7: FINAL TEST QUERIES
-- ============================================================

-- Admit a new patient
EXEC admit_patient('Anjali Singh', 35, 'Female', '9911223344', 'Bangalore');

-- Discharge a patient
EXEC discharge_patient(1);

-- Update bill status
EXEC update_bill_status(3, 'PAID');

-- View all patients
SELECT patient_id, patient_name, age, gender, status
FROM patients
ORDER BY patient_id;

-- View all bills
SELECT b.bill_id, p.patient_name, b.total_amount, b.paid_status
FROM bills b
JOIN patients p ON b.patient_id = p.patient_id
ORDER BY b.bill_id;

-- View full audit log
SELECT log_id, action, patient_id, remarks, action_date
FROM audit_log
ORDER BY log_id;

-- Test functions
BEGIN
    DBMS_OUTPUT.PUT_LINE('Total Bill for Patient 1: Rs.' || get_total_bill(1));
    DBMS_OUTPUT.PUT_LINE('Status of Patient 1: ' || get_patient_status(1));
END;
/
