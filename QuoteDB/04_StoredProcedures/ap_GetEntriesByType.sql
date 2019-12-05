/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_GetEntriesByType
    ================================================================
    Purpose: Return all entries of a specific type. In addition, the
             stored procedure supports the ability to return batches of
             entries based on a starting ID and the number of entries 
             to return. This procedure has the ability to return all 
             types of text (quotations, poems, song lyrics) if you pass 
             a NULL value for the @TypeOfEntry argument.
    Syntax:  EXEC ap_GetEntriesByType 'Q'
             EXEC ap_GetEntriesByType 'Q', 5
             EXEC ap_GetEntriesByType 'Q', 1,   1
             EXEC ap_GetEntriesByType 'Q', 5,   6
             EXEC ap_GetEntriesByType 'Q', 10, 11
             EXEC ap_GetEntriesByType 'Q', 5,  20
             EXEC ap_GetEntriesByType NULL
             EXEC ap_GetEntriesByType NULL, 5
             EXEC ap_GetEntriesByType NULL, 5,   1
             EXEC ap_GetEntriesByType NULL, 5,   6
             EXEC ap_GetEntriesByType NULL, 10, 11
             EXEC ap_GetEntriesByType NULL, 5,  20
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_GetEntriesByType')
        DROP PROCEDURE dbo.ap_GetEntriesByType
    GO
    
    CREATE PROCEDURE dbo.ap_GetEntriesByType  
        @TypeOfEntry        char(1)=NULL,
        @EntriesToReturn    int=0,
        @StartingFrom       int=0
    AS
        SET NOCOUNT ON
    
        SET ROWCOUNT @EntriesToReturn
    
        IF @StartingFrom > 0
            IF @TypeOfEntry IS NULL
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated, 
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 WHERE Quote.QuoteID >= @StartingFrom
                 ORDER BY Quote.QuoteID
            ELSE
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 WHERE TypeOfTextID = @TypeOfEntry
                   AND Quote.QuoteID >= @StartingFrom
                 ORDER BY Quote.QuoteID
        ELSE
            IF @TypeOfEntry IS NULL 
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 ORDER BY Quote.QuoteID
            ELSE
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 WHERE TypeOfTextID = @TypeOfEntry
                 ORDER BY Quote.QuoteID
    
        SET ROWCOUNT 0
    GO
      
    GRANT EXECUTE ON dbo.ap_GetEntriesByType TO PUBLIC
    GO