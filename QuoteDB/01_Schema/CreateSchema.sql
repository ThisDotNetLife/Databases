/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations

/*  ================================================================
    DROP EXISTING TABLE RELATIONSHIPS
    ================================================================  */
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FK_AuthorQuote_Author') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.AuthorQuote DROP CONSTRAINT FK_AuthorQuote_Author
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FK_KeywordQuote_Keyword') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.KeywordQuote DROP CONSTRAINT FK_KeywordQuote_Keyword
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FK_Quote_TypeOfText') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.Quote DROP CONSTRAINT FK_Quote_TypeOfText
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FK_AuthorQuote_Quote') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.AuthorQuote DROP CONSTRAINT FK_AuthorQuote_Quote
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.FK_KeywordQuote_Quote') AND OBJECTPROPERTY(id, N'IsForeignKey') = 1)
        ALTER TABLE dbo.KeywordQuote DROP CONSTRAINT FK_KeywordQuote_Quote
    GO

/*  ================================================================
    DROP EXISTING TABLES
    ================================================================  */
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.AuthorQuote') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.AuthorQuote
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.KeywordQuote') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.KeywordQuote
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.Quote') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Quote
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.Author') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Author
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.Keyword') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.Keyword
    GO
    
    IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.TypeOfText') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
        DROP TABLE dbo.TypeOfText
    GO

/*  ================================================================
    BUILD TABLES
    ================================================================  */
    CREATE TABLE dbo.Author (
        AuthorID     int          NOT NULL CONSTRAINT Author_PK     PRIMARY KEY CLUSTERED,
        NameOfAuthor varchar (50) NOT NULL )
    GO
    
    CREATE TABLE dbo.Keyword (
        KeywordID    int          NOT NULL CONSTRAINT Keyword_PK    PRIMARY KEY CLUSTERED,
        WatchWord    varchar (25) NOT NULL ) 
    GO
    
    CREATE TABLE dbo.TypeOfText (
        TypeOfTextID char    (1)  NOT NULL CONSTRAINT TypeOfText_PK PRIMARY KEY CLUSTERED,
        CommonName   varchar (15) NOT NULL )
    GO
    
    CREATE TABLE dbo.Quote (
        QuoteID      int          NOT NULL CONSTRAINT Quote_PK      PRIMARY KEY CLUSTERED,
        TypeOfTextID char    (1)  NOT NULL DEFAULT 'Q' ,
        BodyOfText   text         NOT NULL ,
        DateCreated  datetime     NOT NULL DEFAULT getdate())
    GO
    
    CREATE TABLE dbo.AuthorQuote (
        AuthorID     int          NOT NULL ,
        QuoteID      int          NOT NULL ,
        CONSTRAINT AuthorQuote_PK  PRIMARY KEY CLUSTERED (AuthorID, QuoteID))
    GO
    
    CREATE TABLE dbo.KeywordQuote (
        KeywordID    int          NOT NULL ,
        QuoteID      int          NOT NULL ,
        CONSTRAINT KeywordQuote_PK PRIMARY KEY CLUSTERED (KeywordID, QuoteID))
    GO

/*  ================================================================
    BUILD UNIQUE INDEXES
    ================================================================  */
    CREATE UNIQUE INDEX IX_Keyword    ON dbo.Keyword (WatchWord)
    GO
    CREATE INDEX IX_Quote_DateCreated ON dbo.Quote   (DateCreated)
    GO

/*  ================================================================
    POPULATE TABLES BEFORE RELATIONSHIPS ARE ESTABLISHED
    ================================================================  */
    INSERT dbo.TypeOfText (TypeOfTextID, CommonName) VALUES ('Q', 'Quotation')
    INSERT dbo.TypeOfText (TypeOfTextID, CommonName) VALUES ('P', 'Poem')
    INSERT dbo.TypeOfText (TypeOfTextID, CommonName) VALUES ('S', 'Song')
    GO

/*  ================================================================
    BUILD RELATIONSHIPS
    ================================================================  */
    ALTER TABLE dbo.Quote 
        ADD CONSTRAINT FK_Quote_TypeOfText 
                FOREIGN KEY (TypeOfTextID) REFERENCES dbo.TypeOfText (TypeOfTextID)
                NOT FOR REPLICATION 
    GO
    
    ALTER TABLE dbo.AuthorQuote 
        ADD CONSTRAINT FK_AuthorQuote_Author 
                FOREIGN KEY (AuthorID) REFERENCES dbo.Author (AuthorID)
                NOT FOR REPLICATION ,
    	CONSTRAINT FK_AuthorQuote_Quote 
                FOREIGN KEY (QuoteID) REFERENCES dbo.Quote (QuoteID) 
                NOT FOR REPLICATION 
    GO
    
    ALTER TABLE dbo.KeywordQuote 
        ADD CONSTRAINT FK_KeywordQuote_Keyword 
                FOREIGN KEY (KeywordID) REFERENCES dbo.Keyword (KeywordID) 
                NOT FOR REPLICATION ,
    	CONSTRAINT FK_KeywordQuote_Quote 
                FOREIGN KEY (QuoteID) REFERENCES dbo.Quote (QuoteID) 
                NOT FOR REPLICATION 
    GO
