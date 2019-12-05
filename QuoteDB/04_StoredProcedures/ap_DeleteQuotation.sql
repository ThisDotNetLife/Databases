/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_DeleteQuotation
    ================================================================
    Purpose: Deletes a specific quotation in the database.
    Syntax:  EXECUTE ap_DeleteQuotation 6
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_DeleteQuotation')
        DROP PROCEDURE dbo.ap_DeleteQuotation
    GO
    
    CREATE PROCEDURE dbo.ap_DeleteQuotation  
        @QuoteID               int
    AS
        SET NOCOUNT ON
    
        DECLARE @AuthorID      int
        DECLARE @RowsFound     int
    
        BEGIN TRAN REMOVE_QUOTE
    
        DELETE AuthorQuote  WHERE QuoteID=@QuoteID
    
        DELETE FROM Author WHERE AuthorID IN (
            SELECT Author.AuthorID
              FROM Author LEFT JOIN AuthorQuote 
                ON Author.AuthorID = AuthorQuote.AuthorID
             WHERE AuthorQuote.AuthorID IS NULL)
    
        DELETE KeywordQuote WHERE QuoteID=@QuoteID
    
        DELETE FROM Keyword WHERE KeywordID IN (
            SELECT Keyword.KeywordID
              FROM Keyword LEFT JOIN KeywordQuote 
                ON Keyword.KeywordID = KeywordQuote.KeywordID
             WHERE KeywordQuote.KeywordID IS NULL)
    
        DELETE Quote WHERE QuoteID = @QuoteID
    
        COMMIT TRAN REMOVE_QUOTE
    GO
      
    GRANT EXECUTE ON dbo.ap_DeleteQuotation TO PUBLIC
    GO
