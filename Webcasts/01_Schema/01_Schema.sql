    SET NOCOUNT ON
    GO
/*  ============================================================================
    DROP FOREIGN KEY CONSTRAINTS FROM DATABASE
    ============================================================================ */
	ALTER TABLE dbo.Webcast
    DROP CONSTRAINT IF EXISTS FK_Webcast_VendorID
	GO
	ALTER TABLE dbo.Webcast
	DROP CONSTRAINT IF EXISTS FK_Webcast_AuthorID
    GO
	ALTER TABLE dbo.WebcastTag
    DROP CONSTRAINT IF EXISTS FK_WebcastTag_WebcastID
	GO
	ALTER TABLE dbo.WebcastTag
	DROP CONSTRAINT IF EXISTS FK_WebcastTag_TagID
    GO
/*  ============================================================================
    DROP TABLES FROM DATABASE
    ============================================================================ */
	DROP TABLE IF EXISTS dbo.Vendor
	GO
	DROP TABLE IF EXISTS dbo.Tag
	GO
	DROP TABLE IF EXISTS dbo.Author
	GO
	DROP TABLE IF EXISTS dbo.Webcast
	GO
	DROP TABLE IF EXISTS dbo.WebcastTag
	GO
/*  ============================================================================
    CREATE TABLES WITH FOREIGN KEY CONSTRAINTS
    ============================================================================ */
	CREATE TABLE dbo.Vendor (
	    ID          INT PRIMARY KEY IDENTITY(1, 1),
	    Descr       VARCHAR(50) NOT NULL )
    GO
	CREATE TABLE dbo.Tag (
	    ID          INT PRIMARY KEY IDENTITY(1, 1),
	    Descr       VARCHAR(50) NOT NULL )
	GO
	CREATE TABLE dbo.Author (
	    ID          INT PRIMARY KEY IDENTITY(1, 1),
	    Descr       VARCHAR(50) NOT NULL )
	GO
	CREATE TABLE dbo.Webcast (
		ID           INT    IDENTITY(1, 1),
		PhysicalPath VARCHAR(200) NOT NULL,
		Title        VARCHAR(500) NOT NULL,
		VendorID     INT          NOT NULL,
		AuthorID     INT          NOT NULL,
		ReleaseDate  DATE         NULL,
		Summary      VARCHAR(MAX) NOT NULL,
		URL          VARCHAR(200) NOT NULL,
		CONSTRAINT PK_Webcast PRIMARY KEY(ID),
		CONSTRAINT FK_Webcast_VendorID   FOREIGN KEY (VendorID) REFERENCES dbo.Vendor(ID),
		CONSTRAINT FK_Webcast_AuthorID   FOREIGN KEY (AuthorID) REFERENCES dbo.Author(ID))
	GO
	CREATE TABLE dbo.WebcastTag (
	    WebcastID        INT NOT NULL,
	    TagID            INT NOT NULL,
		CONSTRAINT PK_WebcastTag           PRIMARY KEY (WebcastID, TagID),
		CONSTRAINT FK_WebcastTag_WebcastID FOREIGN KEY (WebcastID) REFERENCES dbo.Webcast(ID), 
		CONSTRAINT FK_WebcastTag_TagID     FOREIGN KEY (TagID)     REFERENCES dbo.Tag(ID))
	GO
/*  ============================================================================
    CREATE UNIQUE INDEXES
    ============================================================================ */
	CREATE UNIQUE INDEX IDX_VendorName    ON dbo.Vendor(Descr) 
	CREATE UNIQUE INDEX IDX_TopicDescr    ON dbo.Tag   (Descr) 
	CREATE UNIQUE INDEX IDX_AuthorName    ON dbo.Author(Descr) 
	CREATE UNIQUE INDEX IDX_WebcastOnDisk ON dbo.Webcast(PhysicalPath, Title) 
	GO