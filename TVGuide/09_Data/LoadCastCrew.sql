USE WEBCASTS
GO

/*  =============================================================
    CREATE STORED PROCEDURE TO LOAD CAST, CREW AND CHARACTERS
    ============================================================= */
	IF OBJECT_ID('dbo.LoadCastCrew') IS NOT NULL
		DROP PROCEDURE dbo.LoadCastCrew
	GO

	SET QUOTED_IDENTIFIER ON
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	GO

	/******************************************************************************
	Name:	  LoadCastCrew
	Desc:	  Load startup data into database.
	Author:   Mark Orlando
	Date:	  10/19/2015
	Examples: EXEC LoadCastCrew (ShowID, Season, Episode, CharacterName, IsActor, IsWriter, IsDirector, FirstName, LastName, IsFamous, InStarringRole) VALUES (@ShowID, 1, 1, 'Paladin', 1, 0, 0, 'Richard', 'Boone', 0, 1)
	******************************************************************************* */
	CREATE PROCEDURE dbo.LoadCastCrew 
		@ShowID         INT,
		@Season         INT,
		@Episode        INT,
		@CharacterName  VARCHAR(30),
		@IsActor        BIT,
		@IsWriter       BIT,
		@IsDirector     BIT,
		@FirstName      VARCHAR(20),
		@LastName       VARCHAR(30),
		@IsFamous       BIT,
		@InStarringRole BIT
	AS
	BEGIN
		BEGIN TRY
	
		DECLARE @SPStep		  INT
		DECLARE @SPMessage    NVARCHAR(1000) = ''
		DECLARE @PersonID     INT
		DECLARE @EpisodeID    INT

		BEGIN TRAN T1

		-- ============================================================================================================
		-- Get ID for each person. If person not in Person table, add them and get the new ID.
		-- ============================================================================================================
		SET @SPStep = 1;
		IF NOT EXISTS(SELECT 1 FROM dbo.Person WHERE FirstName=@FirstName AND LastName=@LastName)
			INSERT INTO dbo.Person (FirstName, LastName, IsFamous, InStarringRole) VALUES (@FirstName, @LastName, @IsFamous, @InStarringRole)
		SET @PersonID = @@IDENTITY

		-- ============================================================================================================
		-- Get ID for given episode.
		-- ============================================================================================================
		SET @SPStep = 2;
		SET @EpisodeID = (SELECT EpisodeID FROM dbo.Episode WHERE ShowID=@ShowID AND Season=@Season AND Episode=@Episode)

		-- ============================================================================================================
		-- Load character into EpisodePerson table..
		-- ============================================================================================================
		SET @SPStep = 3;
		INSERT INTO dbo.EpisodePerson (EpisodeID, PersonID, CharacterName, IsActor, IsWriter, IsDirector) 
		    VALUES (@EpisodeID, @PersonID, @CharacterName, @IsActor, @IsWriter, @IsDirector)

		COMMIT TRAN T1

		END TRY
	
		BEGIN CATCH
			BEGIN
				IF @@TRANCOUNT > 0
					ROLLBACK TRAN T1

				SET @SPMessage = 'Exception occurred in LoadCastCrew at step ' + CAST (@SPStep as NVARCHAR(10)) + 
				' with error: ' + CAST(ERROR_NUMBER() as NVARCHAR(10)) + ' - ' + ERROR_MESSAGE();
				THROW 51001, @SPMessage, 1;
			END
		END CATCH
	END
	GO

	GRANT EXEC ON dbo.LoadCastCrew TO public
	GO     

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS OFF
	GO