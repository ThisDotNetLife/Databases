USE TVShows
GO

/*  ============================================================================
    DROP TRIGGERS
    ============================================================================ */
	IF  OBJECT_ID('dbo.Show_Update', 'TR') IS NOT NULL
		DROP TRIGGER dbo.Show_Update

	IF  OBJECT_ID('dbo.Person_Update', 'TR') IS NOT NULL
		DROP TRIGGER dbo.Person_Update

	IF  OBJECT_ID('dbo.Episode_Update', 'TR') IS NOT NULL
		DROP TRIGGER dbo.Episode_Update

	IF  OBJECT_ID('dbo.EpisodePerson_Update', 'TR') IS NOT NULL
		DROP TRIGGER dbo.EpisodePerson_Update

/*  ============================================================================
    DROP CONSTRAINTS
    ============================================================================ */
    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE NAME = N'FK_ShowEpisode' )          
       ALTER TABLE dbo.Episode DROP CONSTRAINT FK_ShowEpisode  

    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE NAME = N'FK_PersonM2M' )          
       ALTER TABLE dbo.EpisodePerson DROP CONSTRAINT FK_PersonM2M

    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE NAME = N'FK_EpisodeM2M' )          
       ALTER TABLE dbo.EpisodePerson DROP CONSTRAINT FK_EpisodeM2M  
	GO
 	
/*  =============================================================
    DROP EXISTING TABLES
    ============================================================= */	 
    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.Show') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Show  

    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.Person') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Person  

    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.Episode') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Episode 

    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.EpisodePerson') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.EpisodePerson 
    GO

/*  =============================================================
    BUILD TABLES
    ============================================================= */ 
	CREATE TABLE dbo.Show(
		ShowID         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		Title          VARCHAR(50)       NOT NULL,
		Summary        VARCHAR(8000)     NOT NULL,
		DefaultImage   VARCHAR(200)      NOT NULL,
		DefaultIcon    VARCHAR(200)      NOT NULL,
		LastModified   DATETIME          NOT NULL DEFAULT(GETDATE()))

	CREATE TABLE dbo.Person(
		PersonID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		FirstName      VARCHAR(20)       NOT NULL,
		LastName       VARCHAR(30)       NOT NULL,
		IsFamous       BIT               NOT NULL DEFAULT 0,
		InStarringRole BIT               NOT NULL DEFAULT 0,
		LastModified   DATETIME          NOT NULL DEFAULT(GETDATE()))

	CREATE TABLE dbo.Episode(
		EpisodeID      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
		ShowID         INT               NOT NULL,
		Season         TINYINT           NOT NULL,
		Episode        TINYINT           NOT NULL,
		AirDate        DATE              NOT NULL,
		Title          VARCHAR(50)       NOT NULL,
		Synopsis       VARCHAR(8000)     NOT NULL,
		LastModified   DATETIME          NOT NULL DEFAULT(GETDATE()))

	CREATE TABLE dbo.EpisodePerson(
		EpisodeID      INT               NOT NULL,
		PersonID       INT               NOT NULL,
		CharacterName  VARCHAR(30)       NOT NULL DEFAULT(''),
		IsActor        BIT               NOT NULL DEFAULT(0),
		IsWriter       BIT               NOT NULL DEFAULT(0),
		IsDirector     BIT               NOT NULL DEFAULT(0),
		LastModified   DATETIME          NOT NULL DEFAULT(GETDATE()))
	GO

/*  ============================================================================
    BUILD ADDITIONAL TABLE INDEXES
    ============================================================================ */
    CREATE UNIQUE NONCLUSTERED INDEX IX_Show
        ON dbo.Show(Title)                   
                    
    CREATE UNIQUE NONCLUSTERED INDEX IX_Person
        ON dbo.Person(FirstName, LastName)      
	GO

--/*  ============================================================================
--    BUILD RELATIONSHIPS
--    ============================================================================ */   			    
	ALTER TABLE dbo.Episode  
		ADD CONSTRAINT FK_ShowEpisode FOREIGN KEY ( ShowID ) 
		    REFERENCES dbo.Show ( ShowID )
		    NOT FOR REPLICATION

	ALTER TABLE dbo.EpisodePerson 
		ADD CONSTRAINT FK_EpisodeM2M FOREIGN KEY ( EpisodeID ) 
		    REFERENCES dbo.Episode ( EpisodeID )
		    NOT FOR REPLICATION,

		    CONSTRAINT FK_PersonM2M FOREIGN KEY ( PersonID ) 
		    REFERENCES dbo.Person ( PersonID )
		    NOT FOR REPLICATION
	GO	 	    

/*  =============================================================
    CREATE TRIGGERS
    ============================================================= */
	CREATE TRIGGER dbo.Show_Update ON dbo.Show AFTER UPDATE 
	    AS BEGIN
			UPDATE dbo.Show 
		      SET LastModified=GETDATE() 
			 FROM INSERTED I, dbo.Show A WHERE I.ShowID=A.ShowID
			 END
    GO

	CREATE TRIGGER dbo.Person_Update ON dbo.Person AFTER UPDATE 
	    AS BEGIN
			UPDATE dbo.Person 
		      SET LastModified=GETDATE() 
			 FROM INSERTED I, dbo.Person T WHERE I.PersonID=T.PersonID
			 END
    GO

	CREATE TRIGGER dbo.Episode_Update ON dbo.Episode AFTER UPDATE 
	    AS BEGIN
			UPDATE dbo.Episode 
		      SET LastModified=GETDATE() 
			 FROM INSERTED I, dbo.Episode TA WHERE I.EpisodeID=TA.EpisodeID
			 END
    GO

	CREATE TRIGGER dbo.EpisodePerson_Update ON dbo.EpisodePerson AFTER UPDATE 
	    AS BEGIN
			UPDATE dbo.EpisodePerson 
		      SET LastModified=GETDATE() 
			 FROM INSERTED I, dbo.EpisodePerson T WHERE I.EpisodeID=T.EpisodeID AND I.PersonID=T.PersonID
			 END
    GO