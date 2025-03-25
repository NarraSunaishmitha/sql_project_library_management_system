--LIBRARY MANAGEMENT SYSTEM--

--CREATING BRANCH TABLE
CREATE TABLE BRANCH
          (
            branch_id VARCHAR(30) PRIMARY KEY,
			manager_id VARCHAR(30),
			branch_address VARCHAR(55),
			contact_no VARCHAR(30)
		  );
		  

--CREATING EMPLOYEES TABLE
CREATE TABLE EMPOLOYEES
            (
              emp_id VARCHAR(30) PRIMARY KEY,
			  emp_name VARCHAR(25),
			  position	VARCHAR(25),
			  salary VARCHAR(25),
			  branch_id VARCHAR(20) --FK
			);
			

--CREATING BOOKS TABLE
DROP TABLE IF EXISTS BOOKS;
CREATE TABLE BOOKS
             (
               isbn	VARCHAR(20)PRIMARY KEY,
			   book_title VARCHAR(75),	
			   category	VARCHAR(30),
			   rental_price	FLOAT,
			   status VARCHAR(15),
			   author VARCHAR(35),
			   publisher VARCHAR(55)
			 );


ALTER TABLE BOOKS 
ALTER COLUMN CATEGORY TYPE VARCHAR(20);


--CREATING MEMBERS TABLE
CREATE TABLE MEMBERS
            (
              member_id	 VARCHAR(10) PRIMARY KEY,
			  member_name VARCHAR(25),
			  member_address VARCHAR(75),
			  reg_date DATE
			);


--CREATING ISSUED_STATUS TABLE
CREATE TABLE ISSUED_STATUS
             ( 
			   issued_id VARCHAR(10) PRIMARY KEY,
			   issued_member_id	VARCHAR(10),  --FK
			   issued_book_name	VARCHAR(75),
			   issued_date DATE,
			   issued_book_isbn	VARCHAR(25),  --FK
			   issued_emp_id VARCHAR(10) --FK
			 );


--CREATING RETURN_STATUS TABLE
CREATE TABLE RETURN_STATUS
            (
              return_id	VARCHAR(10) PRIMARY KEY,
			  issued_id VARCHAR(10), --FK
			  return_book_name VARCHAR(75),
			  return_date DATE,
			  return_book_isbn 	VARCHAR(20)
			);


--FOREIGN KEY
ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_MEMBERS
FOREIGN KEY(issued_member_id)
REFERENCES MEMBERS(member_id);


ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_BOOKS
FOREIGN KEY(issued_book_isbn)
REFERENCES BOOKS(isbn);


ALTER TABLE ISSUED_STATUS
ADD CONSTRAINT FK_EMPOLOYEES
FOREIGN KEY(issued_emp_id)
REFERENCES EMPOLOYEES(emp_id);


ALTER TABLE EMPOLOYEES
ADD CONSTRAINT FK_BRANCH
FOREIGN KEY(branch_id)
REFERENCES BRANCH(branch_id);


ALTER TABLE RETURN_STATUS
ADD CONSTRAINT FK_ISSUED_STATUS
FOREIGN KEY(issued_id)
REFERENCES ISSUED_STATUS(issued_id);











            
