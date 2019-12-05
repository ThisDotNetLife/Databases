/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE QuoteDB
	GO

/*  =================================================================
    USER DEFINED FUNCTION : udf_JoinByDelimiter
    ================================================================
    Purpose: Returns a string of keywords that belong to a 
             specific quotation ID. The keywords are in 
             alphabetical order and separated by a 
             user-specified delimiter. 
    Syntax:  SELECT dbo.udf_JoinByDelimiter(5, '|')
    Author:  Andrew Novick http://www.NovickSoftware.com
    ================================================================  */
    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.udf_JoinByDelimiter') 
                  AND xtype in (N'FN', N'IF', N'TF'))
    DROP FUNCTION dbo.udf_JoinByDelimiter
    GO
    
    CREATE FUNCTION dbo.udf_JoinByDelimiter ( 
        @QuoteID     INT, 
        @Delimiter   CHAR(1)=NULL) RETURNS VARCHAR(4000) 
    AS BEGIN
    
        DECLARE @Result VARCHAR(4000)
    
    --  If we don't set @Result to an empty string is will be NULL by default
    --  and we'll constantly get NULL as a return value.
        SET @Result = ''
    
        SELECT @Result = @Result 
               + CASE WHEN LEN(@Result)>0 THEN @Delimiter ELSE '' END 
               + WatchWord
          FROM dbo.Keyword
         INNER JOIN dbo.KeywordQuote
            ON Keyword.KeywordID = KeywordQuote.KeywordID 
         INNER JOIN dbo.Quote
            ON Quote.QuoteID = KeywordQuote.QuoteID    
         WHERE Quote.QuoteID = @QuoteID
         ORDER BY WatchWord
    
        RETURN @Result
    END
    GO  

    GRANT SELECT ON dbo.udf_SplitByDelimiter TO Public
    GO