    DROP PROCEDURE IF EXISTS dbo.jsonGetTags
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonGetTags
	Author:   Mark Orlando
	Date:	  11/01/2019
	Remarks:  Return tags and number of webcasts they are associated with.
	
	EXEC dbo.jsonGetTags

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonGetTags 
	AS
	BEGIN
		BEGIN TRY
	
		SET NOCOUNT ON

		DECLARE @SPStep		        INT
		DECLARE @SPMessage          NVARCHAR(1000)	

		SELECT (SELECT T.Descr AS Descr, T.ID AS TagID, COUNT(WT.TagID) AS NumberOfWebcasts
                  FROM dbo.Tag T INNER JOIN dbo.WebcastTag WT ON T.ID=WT.TagID
                 GROUP BY T.Descr, T.ID
                 ORDER BY T.Descr FOR JSON PATH) AS JsonOutput

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				SET @SPMessage = 'Exception occurred in jsonGetTags at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO