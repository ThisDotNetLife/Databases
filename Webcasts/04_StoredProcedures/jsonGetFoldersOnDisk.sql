    DROP PROCEDURE IF EXISTS dbo.jsonGetFoldersOnDisk
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonGetFoldersOnDisk
	Author:   Mark Orlando
	Date:	  11/15/2019
	Remarks:  Return topics and number of webcasts asociated with each topic.
	
	EXEC dbo.jsonGetFoldersOnDisk

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonGetFoldersOnDisk 
	AS
	BEGIN
		BEGIN TRY
	
		SET NOCOUNT ON

		DECLARE @SPStep		        INT
		DECLARE @SPMessage          VARCHAR(1000)	

		SELECT (SELECT RIGHT(W.FolderOnDisk, CHARINDEX('|', REVERSE(W.FolderOnDisk) + '|') - 1) AS Topic, COUNT(W.ID) AS NumberOfWebcasts
		          FROM dbo.Webcast W
				  WHERE LEN(W.FolderOnDisk) > 0
		         GROUP BY RIGHT(W.FolderOnDisk, CHARINDEX('|', REVERSE(W.FolderOnDisk) + '|') - 1)
		         ORDER BY RIGHT(W.FolderOnDisk, CHARINDEX('|', REVERSE(W.FolderOnDisk) + '|') - 1)
				   FOR JSON PATH) AS JsonOutput

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				SET @SPMessage = 'Exception occurred in jsonGetFoldersOnDisk at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO