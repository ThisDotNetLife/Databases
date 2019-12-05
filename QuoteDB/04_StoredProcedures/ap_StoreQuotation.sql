/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_StoreQuotation
    ================================================================
    Purpose: Stores quotations in the database. 
    To use this stored procedure to add new quotations:
    Inputs: TypeOfText is a single character that must be 'Q', 'S' or 'P'
            NameOfAuthor can be an empty string, but cannot be NULL.
            BodyOfText must have single-quotes closed off.
            CSVOfLinks can be an empty string or a string of delimited 
            words or short phrases. Use a comman as the delimiter.

    To use this stored procedure to update existing quotations:
    Inputs: TypeOfText is a single character that must be 'Q', 'S' or 'P'
            NameOfAuthor can be an empty string, but cannot be NULL.
            BodyOfText must have single-quotes closed off.
            CSVOfLinks can be an empty string or a string of delimited 
            words or short phrases. Use a comman as the delimiter.
            QuoteID must be the primary key of the quotation being updated.

    Return Codes:  Positive value is the primary key for the quotation.
                   Negative value is a SQL Server error code.

    DECLARE @RC1 INT; EXEC @RC1 = ap_StoreQuotation 'Q', 'Flight of the Pheonix', 'I think a man only needs one thing in life.|He just needs someone to love.|If you can''t give him that, then give him something to believe in, and if you can''t give him that, then give him something to do.', 'Work|Life'
    DECLARE @RC2 INT; EXEC @RC2 = ap_StoreQuotation 'Q', 'D''Argo',  'Revenge is a feast best served immediately.', 'Farscape|Revenge'
    DECLARE @RC3 INT; EXEC @RC3 = ap_StoreQuotation 'Q', 'John Crichton', 'Have we sent the ''don''t shoot us we''re pathetic'' transmission yet?', 'Farscape'
    DECLARE @RC4 INT; EXEC @RC4 = ap_StoreQuotation 'Q', 'Aeryn Sun', 'Oh, just to be in the warm glow of all this testosterone.', 'Farscape|Men'
    DECLARE @RC5 INT; EXEC @RC5 = ap_StoreQuotation 'Q', 'John Crichton', 'That''s your plan? Wile E. Coyote would come up with a better plan than that!', 'Farscape|Plan|Project Planning'
    SELECT * FROM Keyword
    SELECT * FROM KeywordQuote
    SELECT * FROM Quote
    SELECT * FROM AuthorQuote
    SELECT * FROM Author
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_StoreQuotation')
        DROP PROCEDURE dbo.ap_StoreQuotation
    GO
    
    CREATE PROCEDURE dbo.ap_StoreQuotation  
        @TypeOfText            char(1),
        @NameOfAuthor          varchar(50),
        @BodyOfText            text,
        @CSVOfLinks            varchar(4000),
        @QuoteID               int = null
    AS
        SET NOCOUNT ON
    
        BEGIN TRAN LOG_QUOTATION
    
    --  Enable the text in row option.
        EXEC sp_tableoption 'Quote', 'text in row', 'on'
    
    --  Store the quotation
        IF @QuoteID IS NULL
            BEGIN
            SET @QuoteID = (SELECT MAX(QuoteID) + 1 FROM Quote)
            IF @QuoteID IS NULL
                SET @QuoteID = 1
     
            INSERT INTO Quote (QuoteID, TypeOfTextID, BodyOfText) 
                 VALUES (@QuoteID, @TypeOfText, @BodyOfText)
            END
        ELSE
            UPDATE Quote 
               SET TypeOfTextID=@TypeOfText, BodyOfText=@BodyOfText
             WHERE QuoteID=@QuoteID
    
    --  Disable the text in row option.
        EXEC sp_tableoption 'Quote', 'text in row', 'off'
    
    --  Update the author and keywords associated with this quote.
        EXECUTE ap_StoreAuthor   @QuoteID, @NameOfAuthor
        EXECUTE ap_StoreKeywords @QuoteID, @CSVOfLinks
    
        COMMIT TRAN LOG_QUOTATION
    
        IF @@ERROR !=0 
            SET @QuoteID = @@ERROR * -1
    
        RETURN @QuoteID
    GO
      
    GRANT EXECUTE ON dbo.ap_StoreQuotation TO PUBLIC
    GO