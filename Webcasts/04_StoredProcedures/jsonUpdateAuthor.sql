    DROP PROCEDURE IF EXISTS dbo.jsonUpdateAuthor
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonUpdateAuthor
	Author:   Mark Orlando
	Date:	  10/14/2019
	Remarks:  Change name of Author.
	
	EXEC dbo.jsonUpdateAuthor @JsonInput='{"ID":251,"Descr":"Joe Eames and Jim Cooper"}'

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonUpdateAuthor(@JsonInput VARCHAR(MAX))	
	AS
	BEGIN
		BEGIN TRY

		DECLARE @SPStep		   INT
		DECLARE @SPMessage     VARCHAR(1000)	
		DECLARE @AuthorID      INT
		DECLARE @Descr         VARCHAR(25)
		DECLARE @ExistingID    INT

		BEGIN 
			SET @SPStep = 2
			SELECT @AuthorID=ID, @Descr=Descr
			  FROM OPENJSON(@JsonInput) WITH ( ID     INT          '$.ID',
											   Descr  VARCHAR(25)  '$.Descr')
		END -- PARSE JSON INTO LOCAL VARIABLES

		BEGIN TRANSACTION

		SET @SPStep = 4
		SET @ExistingID=(SELECT ID FROM dbo.Author WHERE Descr=@Descr)

		IF @ExistingID IS NULL
			BEGIN
				SET @SPStep = 6
				UPDATE dbo.Author SET Descr=@Descr WHERE ID=@AuthorID
			END
		ELSE
			BEGIN
				SET @SPStep = 8
				UPDATE dbo.Webcast
				   SET AuthorID=@ExistingID
				 WHERE AuthorID=@AuthorID
				DELETE dbo.Author WHERE ID=@AuthorID
			END

		COMMIT TRANSACTION

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				IF @@TRANCOUNT > 0
				    ROLLBACK TRANSACTION
				IF LEN(@SPMessage) = 0
					SET @SPMessage = 'Exception occurred in jsonUpdateAuthor at step ' + CAST (@SPStep as NVARCHAR(10)) + 
					' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;

				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO