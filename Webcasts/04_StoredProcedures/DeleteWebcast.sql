    DROP PROCEDURE IF EXISTS dbo.DeleteWebcast
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  DeleteWebcast
	Author:   Mark Orlando
	Date:	  10/22/2019
	Remarks:  Delete webcast based on ID
	
	EXEC DeleteWebcast  @ID=1512

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.DeleteWebcast @ID INT
	AS
	BEGIN
		BEGIN TRY

			DECLARE @SPStep		        INT
			DECLARE @SPMessage          VARCHAR(1000)	

			SET @SPStep=2
			DELETE dbo.WebcastTag WHERE WebcastID=@ID

			SET @SPStep=4
			DELETE dbo.Webcast WHERE ID=@ID

		 -- DROP ROWS FROM dbo.Vendor TABLE THAT ARE ORPHANED.
			SET @SPStep = 6
			DELETE V FROM dbo.Vendor V                      
			LEFT JOIN dbo.Webcast W ON W.VendorID = V.ID 
			WHERE W.VendorID IS NULL

         -- DROP ROWS FROM dbo.Author TABLE THAT ARE ORPHANED.
			SET @SPStep = 8
			DELETE A FROM dbo.Author A LEFT JOIN dbo.Webcast W ON W.AuthorID = A.ID 
			 WHERE W.AuthorID IS NULL

		 -- DROP ROWS FROM dbo.Tag TABLE THAT ARE ORPHANED.
			SET @SPStep = 10
			DELETE T FROM dbo.Tag T LEFT JOIN dbo.WebcastTag WT ON WT.TagID = T.ID 
			 WHERE WT.TagID IS NULL

			RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				SET @SPMessage = 'Exception occurred in DeleteWebcast at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
				RETURN 1
			END
		END CATCH

		RETURN 
	END
GO