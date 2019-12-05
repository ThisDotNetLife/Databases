    DROP PROCEDURE IF EXISTS dbo.jsonSearchWebcasts
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ===========================================================================================
	Name:	  jsonSearchWebcasts
	Author:   Mark Orlando
	Date:	  11/07/2019
	Remarks:  Return all webcasts that match search criteria.
	
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":0,   "FolderOnDisk":"",       "Title":"", "Author":"Jim Cooper","Vendor":"", "YearOfRelease":0, "Tags":[]}'
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":0,   "FolderOnDisk":"",       "Title":"", "Author":"",          "Vendor":"", "YearOfRelease":0, "Tags":["Ruby","Unix","MongoDB"]}'
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":950, "FolderOnDisk":"",       "Title":"", "Author":"",          "Vendor":"", "YearOfRelease":0, "Tags":[]}'
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":0,   "FolderOnDisk":"",       "Title":"", "Author":"",          "Vendor":"", "YearOfRelease":0, "Tags":["Design Patterns"]}'
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":0,   "FolderOnDisk":"Postman","Title":"", "Author":"",          "Vendor":"", "YearOfRelease":0, "Tags":[]}'
	EXEC dbo.jsonSearchWebcasts @JsonInput='{"ID":0,   "FolderOnDisk":"",       "Title":"", "Author":"",          "Vendor":"", "YearOfRelease":0, "Tags":[]}'
	
	Revision History:
	Date		Author	      Description
	===========================================================================================
	11/17/2019  Mark Orlando  All webcasts are now returned when no search criteria is provided.
    =========================================================================================== */	
	CREATE PROCEDURE dbo.jsonSearchWebcasts(@JsonInput VARCHAR(MAX))	
	AS
	BEGIN
		DECLARE @SPStep		   INT
		DECLARE @SPMessage     NVARCHAR(1000)	

		BEGIN TRY

		BEGIN 
			DECLARE @ID                INT
			DECLARE @FolderOnDisk      VARCHAR(50)
			DECLARE @Title             VARCHAR(500)
			DECLARE @Author            VARCHAR(50)
			DECLARE @Vendor            VARCHAR(50)
			DECLARE @YearOfRelease     INT
			DECLARE @NoResults         VARCHAR(1000)='No webcasts were found that matched your search criteria.'
			DECLARE @Tags              INT = 0

			DROP TABLE IF EXISTS #SearchResults
			DROP TABLE IF EXISTS #Tags

			CREATE TABLE #SearchResults (ID INT PRIMARY KEY, FolderOnDisk VARCHAR(50), Title VARCHAR(500), 
										 Vendor VARCHAR(50), Author VARCHAR(50), ReleaseDate DATE,
										 YearOfReleaseDate INT, URL VARCHAR(200))
			CREATE TABLE #Tags (Tag VARCHAR(50) PRIMARY KEY)

		END -- DECLARE VARIABLES & TEMP TABLES

		BEGIN 
			SET @SPStep = 2
			SELECT @ID=ID, @FolderOnDisk=FolderOnDisk, @Title=Title, @Author=Author, @Vendor=Vendor, @YearOfRelease=YearOfRelease
			  FROM OPENJSON(@JsonInput) WITH ( ID                INT,
			                                   FolderOnDisk      VARCHAR(50)  '$.FolderOnDisk',
			                                   Title             VARCHAR(500) '$.Title',
											   Author            VARCHAR(20)  '$.Author',
											   Vendor            VARCHAR(50)  '$.Vendor',
											   YearOfRelease     INT  '$.YearOfRelease')
			SET @SPStep = 3
			INSERT INTO #Tags (Tag) 
				SELECT value
				  FROM OPENJSON(@JsonInput, '$.Tags')
		END -- PARSE JSON-BASED ARGUMENTS INTO LOCAL VARIABLES

		BEGIN 
			IF @ID > 0
				IF NOT EXISTS(SELECT 1 FROM dbo.Webcast WHERE ID=@ID)
					BEGIN
						SET @SPMessage='Webcast ID #' + CAST(@ID AS VARCHAR(10)) + ' was not found.'
						RAISERROR (@SPMessage, 11,1)
					END
				ELSE
					BEGIN
						SET @SPStep = 4
						SELECT (SELECT W.ID, W.FolderOnDisk, W.Title, V.Descr AS Vendor, A.Descr AS Author, W.ReleaseDate, W.Summary, W.URL,
						    REPLACE( REPLACE((SELECT Descr 
							   FROM dbo.Tag T INNER JOIN dbo.WebcastTag WT ON T.ID=WT.TagID
							  WHERE WT.WebcastID=W.ID
							  ORDER BY T.Descr FOR JSON AUTO), '{"Descr":', '' ), '"}','"' ) AS Tags
						 FROM Webcast W
							INNER JOIN dbo.Vendor V      ON V.ID=W.VendorID
							INNER JOIN dbo.Author A      ON A.ID=W.AuthorID
						WHERE W.ID=@ID FOR JSON PATH) AS JsonOutput

						RETURN 0
					END
		END -- IF @ID IS PROVIDED, GET ALL PROPERTIES (INCLUDING Webcast.Summary) AND RETURN.

		BEGIN 
			IF EXISTS (SELECT 1 FROM #Tags)
				BEGIN
					SET @SPStep = 12
					SELECT @Tags = COUNT(1) FROM #Tags
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
							  FROM dbo.Webcast W
									INNER JOIN dbo.Vendor      V ON W.VendorID=V.ID
									INNER JOIN dbo.Author      A ON W.AuthorID=A.ID
									INNER JOIN dbo.WebcastTag WT ON W.ID = WT.WebcastID
									INNER JOIN dbo.Tag         T ON T.ID=WT.TagID
									INNER JOIN #Tags          TG ON TG.Tag=T.Descr
							 GROUP BY W.ID, FolderOnDisk, Title, V.Descr, A.Descr, ReleaseDate, URL
							 ORDER BY W.ReleaseDate DESC
					
					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF TAGS WERE PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF LEN(@FolderOnDisk) > 0
				BEGIN
					SET @SPStep = 12
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
							  FROM dbo.Webcast W
									INNER JOIN dbo.Vendor      V ON W.VendorID=V.ID
									INNER JOIN dbo.Author      A ON W.AuthorID=A.ID
									INNER JOIN dbo.WebcastTag WT ON W.ID = WT.WebcastID
									INNER JOIN dbo.Tag         T ON T.ID=WT.TagID
							WHERE RIGHT(W.FolderOnDisk, CHARINDEX('|', REVERSE(W.FolderOnDisk) + '|') - 1)=@FolderOnDisk
							 AND LEN(W.FolderOnDisk) > 0
							 ORDER BY W.ReleaseDate DESC
					ELSE
						DELETE #SearchResults WHERE FolderOnDisk NOT LIKE '%' + @FolderOnDisk + '%'
						
					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF @FolderOnDisk WAS PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF LEN(@Author) > 0
				BEGIN
					SET @SPStep = 6
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
									FROM dbo.Webcast W
										INNER JOIN dbo.Vendor      V ON  W.VendorID=V.ID
										INNER JOIN dbo.Author      A ON  W.AuthorID=A.ID
									WHERE A.Descr LIKE '%' + @Author + '%'
									ORDER BY W.ReleaseDate DESC
					ELSE
						DELETE #SearchResults WHERE AUTHOR NOT LIKE '%' + @Author + '%'

					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF @AUTHOR IS PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF @YearOfRelease > 0
				BEGIN
					SET @SPStep = 8
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
							  FROM dbo.Webcast W
									INNER JOIN dbo.Vendor      V ON  W.VendorID=V.ID
									INNER JOIN dbo.Author      A ON  W.AuthorID=A.ID
							 WHERE YEAR(ReleaseDate)=@YearOfRelease
							 ORDER BY ReleaseDate DESC
					ELSE
						DELETE #SearchResults WHERE YEAR(ReleaseDate) != @YearOfRelease
					
					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF @YearOfRelease IS PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF LEN(@Vendor) > 0
				BEGIN
					SET @SPStep = 10
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						BEGIN
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
							  FROM dbo.Webcast W
									INNER JOIN dbo.Vendor      V ON  W.VendorID=V.ID
									INNER JOIN dbo.Author      A ON  W.AuthorID=A.ID
							 WHERE V.Descr LIKE '%' + @Vendor + '%'
							 ORDER BY W.ReleaseDate DESC
						END
					ELSE
						DELETE #SearchResults WHERE VENDOR NOT LIKE '%' + @Vendor + '%'

					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF @VENDOR IS PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF LEN(@Title) > 0
				BEGIN
					SET @SPStep = 12
					IF NOT EXISTS (SELECT 1 FROM #SearchResults)
						INSERT #SearchResults(ID, FolderOnDisk, Title, Vendor, Author, ReleaseDate, URL)
							SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
							  FROM dbo.Webcast W
									INNER JOIN dbo.Vendor      V ON  W.VendorID=V.ID
									INNER JOIN dbo.Author      A ON  W.AuthorID=A.ID
							 WHERE Title LIKE '%' + @Title + '%' 
							 ORDER BY W.ReleaseDate DESC
					ELSE
						DELETE #SearchResults WHERE TITLE NOT LIKE '%' + @Title + '%' 

					IF NOT EXISTS(SELECT 1 FROM #SearchResults)
						BEGIN
							SET @SPMessage=@NoResults
							RAISERROR (@SPMessage, 11,1)
						END
				END
		END -- IF @Title IS PROVIDED, POPULATE #SearchResults WITH MATCHING ENTRIES.

		BEGIN 
			IF @ID=0 AND @FolderOnDisk='' AND @Title='' AND @Author='' AND @Vendor='' AND @YearOfRelease=0 AND @Tags=0
				BEGIN
					SET @SPStep = 12
					SELECT (SELECT W.ID, W.FolderOnDisk, Title, V.Descr AS Vendor, A.Descr AS Author, ReleaseDate, URL
					  FROM dbo.Webcast W
								INNER JOIN dbo.Vendor      V ON  W.VendorID=V.ID
								INNER JOIN dbo.Author      A ON  W.AuthorID=A.ID
				     ORDER BY W.ReleaseDate DESC FOR JSON PATH) AS JsonOutput
					RETURN 0
				END
		END -- IF NO SEARCH CRITERIA WAS PROVIDED, RETURN ALL ENTRIES IN DATABASE. SORT BY RELEASE DATE (DESCENDING).

		BEGIN 
			SET @SPStep = 14
			IF NOT EXISTS(SELECT 1 FROM #SearchResults)
				BEGIN
					SET @SPMessage=@SPMessage
					RAISERROR (@SPMessage, 11,1)
				END
			ELSE
				SELECT (SELECT W.ID, W.FolderOnDisk, W.Title, W.Vendor, W.Author, W.ReleaseDate, W.URL
						  FROM #SearchResults W
						 ORDER BY ReleaseDate DESC FOR JSON PATH) AS JsonOutput
		END -- RETURN SEARCH RESULTS FROM #SearchResults

		DROP TABLE IF EXISTS #Tags
		DROP TABLE IF EXISTS #SearchResults

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				DROP TABLE IF EXISTS #Tags
				DROP TABLE IF EXISTS #SearchResults

				IF LEN(@SPMessage) = 0
					SET @SPMessage = 'Exception occurred in jsonSearchWebcasts at step ' + CAST (@SPStep as NVARCHAR(10)) + 
					' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;

				RETURN 1
			END
		END CATCH
		RETURN 
	END
