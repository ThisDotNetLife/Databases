    DROP PROCEDURE IF EXISTS dbo.jsonGetAuthors
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonGetAuthors
	Author:   Mark Orlando
	Date:	  11/01/2019
	Remarks:  Return authors and number of webcasts they are associated with.
	
	EXEC dbo.jsonGetAuthors

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonGetAuthors 
	AS
	BEGIN
		BEGIN TRY
	
		SET NOCOUNT ON

		DECLARE @SPStep		        INT
		DECLARE @SPMessage          VARCHAR(1000)	

		SELECT (SELECT A.Descr AS Author, A.ID AS AuthorID, COUNT(W.ID) AS NumberOfWebcasts
                  FROM dbo.Author A INNER JOIN dbo.Webcast W ON A.ID=W.AuthorID
                 GROUP BY A.Descr, A.ID
                 ORDER BY A.Descr FOR JSON PATH) AS JsonOutput

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				SET @SPMessage = 'Exception occurred in jsonGetAuthors at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO