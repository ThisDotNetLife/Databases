/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_GetEntriesBySubject
    ================================================================
    Purpose: Return all entries related to a specific keyword. This 
             procedure provides the option of specify a type of text, 
             such as 'Q' for quotation, 'P' for poem, etc. In addition, 
             the code allows the user to return a specified numer of 
             entries from a specified starting point; useful for 
             returning batches.
    Syntax:  EXEC ap_GetEntriesBySubject 'Work'
             EXEC ap_GetEntriesBySubject 'Compassion', 'Q'
             EXEC ap_GetEntriesBySubject 'Work',       'Q'
             EXEC ap_GetEntriesBySubject 'Work',       'Q', 3, 9
             EXEC ap_GetEntriesBySubject 'Work',      NULL, 3, 9
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_GetEntriesBySubject')
        DROP PROCEDURE dbo.ap_GetEntriesBySubject
    GO
    
    CREATE PROCEDURE dbo.ap_GetEntriesBySubject  
        @WatchWord          VARCHAR(25),
        @TypeOfEntry        CHAR(1) = NULL,
        @EntriesToReturn    int=0,
        @StartingFrom       int=0
    AS
        SET NOCOUNT ON
    
        DECLARE @TypeOfEntries VARCHAR
    
        SET ROWCOUNT @EntriesToReturn
    
        IF @TypeOfEntry IS NULL
            IF @StartingFrom > 0
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 INNER JOIN KeywordQuote
                    ON Quote.QuoteID = KeywordQuote.QuoteID
                 INNER JOIN Keyword
                    ON KeywordQuote.KeywordID = Keyword.KeywordID
                 WHERE Keyword.WatchWord = @WatchWord
                   AND Quote.QuoteID >= @StartingFrom
                 ORDER BY Quote.QuoteID            
            ELSE
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated, 
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 INNER JOIN KeywordQuote
                    ON Quote.QuoteID = KeywordQuote.QuoteID
                 INNER JOIN Keyword
                    ON KeywordQuote.KeywordID = Keyword.KeywordID
                 WHERE Keyword.WatchWord = @WatchWord
                 ORDER BY Quote.QuoteID
        ELSE
            IF @StartingFrom > 0
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 INNER JOIN KeywordQuote
                    ON Quote.QuoteID = KeywordQuote.QuoteID
                 INNER JOIN Keyword
                    ON KeywordQuote.KeywordID = Keyword.KeywordID
                 WHERE Keyword.WatchWord = @WatchWord
                   AND Quote.TypeOfTextID = @TypeOfEntry
                   AND Quote.QuoteID >= @StartingFrom
                 ORDER BY Quote.QuoteID       
            ELSE
                SELECT Quote.QuoteID, ISNULL(Author.NameOfAuthor, '') AS NameOfAuthor, TypeOfTextID, BodyOfText, DateCreated,
                       dbo.udf_JoinByDelimiter(Quote.QuoteID, '|') AS Keywords 
                  FROM Quote 
                  LEFT OUTER JOIN AuthorQuote
                    ON Quote.QuoteID = AuthorQuote.QuoteID 
                  LEFT OUTER JOIN Author
                    ON Author.AuthorID = AuthorQuote.AuthorID
                 INNER JOIN KeywordQuote
                    ON Quote.QuoteID = KeywordQuote.QuoteID
                 INNER JOIN Keyword
                    ON KeywordQuote.KeywordID = Keyword.KeywordID
                 WHERE Keyword.WatchWord = @WatchWord
                   AND Quote.TypeOfTextID = @TypeOfEntry
                 ORDER BY Quote.QuoteID
    
        SET ROWCOUNT 0
    GO
      
    GRANT EXECUTE ON dbo.ap_GetEntriesBySubject TO PUBLIC
    GO