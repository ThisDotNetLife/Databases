/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_GetAnEntry
    ================================================================
    Purpose: Returns a specified entry or all entries.
    Syntax:  EXEC ap_GetAnEntry 6
             EXEC ap_GetAnEntry
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_GetAnEntry')
        DROP PROCEDURE dbo.ap_GetAnEntry
    GO
    
    CREATE PROCEDURE dbo.ap_GetAnEntry  
        @QuoteID               int = null
    AS
        SET NOCOUNT ON
    
        IF @QuoteID IS NULL
            SELECT Quote.QuoteID, 
                   ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, 
                   TypeOfTextID, 
                   BodyOfText, 
                   dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
              FROM Quote 
              LEFT OUTER JOIN AuthorQuote
                ON Quote.QuoteID = AuthorQuote.QuoteID 
              LEFT OUTER JOIN Author
                ON Author.AuthorID = AuthorQuote.AuthorID
            ORDER BY Quote.QuoteID ASC
        ELSE
            SELECT Quote.QuoteID, 
                   ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, 
                   TypeOfTextID, 
                   BodyOfText, 
                   DateCreated, 
                   dbo.udf_JoinByDelimiter(@QuoteID, '|') AS Keywords 
              FROM Quote 
              LEFT OUTER JOIN AuthorQuote
                ON Quote.QuoteID = AuthorQuote.QuoteID 
              LEFT OUTER JOIN Author
                ON Author.AuthorID = AuthorQuote.AuthorID
             WHERE Quote.QuoteID = @QuoteID
    GO
      
    GRANT EXECUTE ON dbo.ap_GetAnEntry TO PUBLIC
    GO