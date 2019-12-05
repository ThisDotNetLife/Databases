    DROP PROCEDURE IF EXISTS dbo.jsonUpdateTag
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonUpdateTag
	Author:   Mark Orlando
	Date:	  10/14/2019
	Remarks:  Change name of Author.
	
	EXEC dbo.jsonUpdateTag @JsonInput='{"ID":9,"Descr":"Azure DevOps"}'

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonUpdateTag(@JsonInput VARCHAR(MAX))	
	AS
	BEGIN
		BEGIN TRY

		DECLARE @SPStep		   INT
		DECLARE @SPMessage     VARCHAR(1000)	
		DECLARE @TagID         INT
		DECLARE @Descr         VARCHAR(50)
		DECLARE @ExistingID    INT

		BEGIN 
			SET @SPStep = 2
			SELECT @TagID=ID, @Descr=Descr
			  FROM OPENJSON(@JsonInput) WITH ( ID     INT          '$.ID',
											   Descr  VARCHAR(25)  '$.Descr')
		END -- PARSE JSON INTO LOCAL VARIABLES

		BEGIN TRANSACTION

		SET @SPStep = 4
		SET @ExistingID=(SELECT ID FROM dbo.Tag WHERE Descr=@Descr)

		IF @ExistingID IS NULL
			BEGIN
				SET @SPStep = 6
				UPDATE dbo.Tag SET Descr=@Descr WHERE ID=@TagID
			END
		ELSE
			BEGIN
				SET @SPStep = 8

				UPDATE dbo.WebcastTag
				   SET TagID=@ExistingID 
				 WHERE TagID=@TagID

				DELETE dbo.Tag WHERE ID=@TagID
			END

		COMMIT TRANSACTION

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				IF @@TRANCOUNT > 0
				    ROLLBACK TRANSACTION
				IF LEN(@SPMessage) = 0
					SET @SPMessage = 'Exception occurred in jsonUpdateTag at step ' + CAST (@SPStep as NVARCHAR(10)) + 
					' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;

				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO