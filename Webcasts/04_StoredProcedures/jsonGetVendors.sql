    DROP PROCEDURE IF EXISTS dbo.jsonGetVendors
	GO

    SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

/*  ========================================================================================
	Name:	  jsonGetVendors
	Author:   Mark Orlando
	Date:	  11/01/2019
	Remarks:  Return vendors and number of webcasts they are associated with.
	
	EXEC dbo.jsonGetVendors

	Revision History:
	Date		Author			Description
	========================================================================================
	
    ======================================================================================== */	
	CREATE PROCEDURE dbo.jsonGetVendors 
	AS
	BEGIN
		BEGIN TRY
	
		SET NOCOUNT ON

		DECLARE @SPStep		        INT
		DECLARE @SPMessage          VARCHAR(1000)	

		SELECT (SELECT V.Descr AS Vendor, V.ID AS VendorID, COUNT(W.ID) AS NumberOfWebcasts
		          FROM dbo.Vendor V INNER JOIN dbo.Webcast W ON V.ID=W.VendorID
		         GROUP BY V.Descr, V.ID
		         ORDER BY V.Descr FOR JSON PATH) AS JsonOutput

		RETURN 0

		END TRY	

		BEGIN CATCH
			BEGIN
				SET @SPMessage = 'Exception occurred in jsonGetVendors at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
				RETURN 1
			END
		END CATCH
		RETURN 
	END
GO