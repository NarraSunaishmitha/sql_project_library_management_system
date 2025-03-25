--SQL PROJECT - LIBRARY MANAGEMENT SYSTEM
SELECT * FROM BOOKS;

SELECT * FROM BRANCH;

SELECT * FROM EMPOLOYEES;

SELECT * FROM ISSUED_STATUS;

SELECT * FROM MEMBERS;

SELECT * FROM RETURN_STATUS;


/*task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

--Issued Status == members == books == return_ststus
--filter books which is return
--overdue > 30

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1



/*Task 14: Update Book Status on Return
Write a query to update the status of books in the books 
table to "Yes" when they are returned (based on entries in the return_status table).
*/
CREATE OR REPLACE PROCEDURE add_return_records(
    p_return_id VARCHAR(10), 
    p_issued_id VARCHAR(10), 
    p_book_quality VARCHAR(10)
)
LANGUAGE plpgsql
AS $$

DECLARE
    v_isbn VARCHAR(50);
    v_book_name VARCHAR(80);

BEGIN
    -- Check if issued_id exists in issued_status
    IF NOT EXISTS (SELECT 1 FROM issued_status WHERE issued_id = p_issued_id) THEN
        RAISE EXCEPTION 'Issued ID % not found in issued_status', p_issued_id;
    END IF;

    -- Insert into return_status
    INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Fetch book details from issued_status
    SELECT issued_book_isbn, issued_book_name 
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1; -- Prevent multiple rows error

    -- If no ISBN is found, raise an exception
    IF v_isbn IS NULL THEN
        RAISE EXCEPTION 'No book found for issued_id %', p_issued_id;
    END IF;

    -- Update book status to 'yes' (available)
    UPDATE books
    SET status = 'yes'
    WHERE isbn = v_isbn;

    -- Notify user
    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;

END;
$$;


-- Testing FUNCTION add_return_records
-- Check book status before return
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';

-- Check issued status before return
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';

-- Execute the procedure
CALL add_return_records('RT101', 'IS135', 'Good');

-- Check return status after execution
SELECT * FROM return_status WHERE issued_id = 'IS135';

-- Check book status after return
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';



/*Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
and the total revenue generated from book rentals.
*/
CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
EMPOLOYEES as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;



/*Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.
*/
CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;
SELECT * FROM active_members;



/*Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, 
number of books processed, and their branch.
*/
SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
EMPOLOYEES as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2



/*Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table.
Display the member name, book title, and the number of times they've issued damaged books.
*/
SELECT 
    m.member_name,
    b.book_title,
    COUNT(i.issued_id) AS times_issued_damaged
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
JOIN books b ON i.issued_book_isbn = b.isbn
WHERE b.status = 'damaged'
GROUP BY m.member_name, b.book_title
HAVING COUNT(i.issued_id) > 2;


--COMPLEX QUERY
/*Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, 
and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure should 
return an error message indicating that the book is currently not available.
*/
SELECT * FROM BOOKS;

SELECT * FROM ISSUED_STATUS;


CREATE OR REPLACE PROCEDURE issue_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(30), p_issued_book_isbn VARCHAR(30), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
-- all the variabable
    v_status VARCHAR(10);

BEGIN
-- all the code
    -- checking if book is available 'yes'
    SELECT 
        status 
        INTO
        v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN

        INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
            SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        RAISE NOTICE 'Book records added successfully for book isbn : %', p_issued_book_isbn;


    ELSE
        RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %', p_issued_book_isbn;
    END IF;
END;
$$

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
CALL issue_book('IS156', 'C108', '978-0-375-41398-8', 'E104');

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'



/*Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.
Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned 
within 30 days. The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines
*/
SELECT 
    m.member_id,
    COUNT(r.return_id) FILTER (WHERE r.return_id IS NULL) AS unreturned_books,
    CURRENT_DATE - i.issued_date AS overdue_by_days,
    (CURRENT_DATE - i.issued_date - 30) AS fine_days
FROM members m
JOIN issued_status i ON m.member_id = i.issued_member_id
LEFT JOIN return_status r ON i.issued_id = r.issued_id
WHERE r.return_id IS NULL AND (CURRENT_DATE - i.issued_date) > 30
GROUP BY m.member_id, i.issued_date;












