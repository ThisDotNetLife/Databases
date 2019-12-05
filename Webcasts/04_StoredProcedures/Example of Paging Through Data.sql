DECLARE @Page          INT = 1   -- IF @Page OR @RowsPerPage are 0, THEN RETURN ALL RESULTS
DECLARE @RowsPerPage   INT = 10;

-- THIS APPROACH LIMITS THE QUERY EARLY TO THE ROWS WE NEED AND THEN USES THAT QUERY TO GET THE REST OF THE DATA
WITH CTE (ID)
AS (SELECT W.ID 
      FROM dbo.Webcast W
     ORDER BY ReleaseDate DESC
    OFFSET ((@Page - 1) * @RowsPerPage) ROWS FETCH NEXT @RowsPerPage ROWS ONLY)
SELECT W.ID, A.Descr AS Author, ReleaseDate, Title 
  FROM dbo.Webcast W
		INNER JOIN dbo.Author A ON W.AuthorID=A.ID
 INNER JOIN CTE AS C2 ON C2.ID = W.ID