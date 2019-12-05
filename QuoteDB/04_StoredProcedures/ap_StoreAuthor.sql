/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_StoreAuthor
    ================================================================
    Purpose: Updates the author in both the Author and the AuthorQuote
             table (the many-to-many table for this data).
    Inputs:  @InputList - String of values seperated by a given delimiter. 
             @Delimiter - The delimiting character.
    Syntax:  EXEC ap_StoreAuthor 1, 'D''Argo'
             EXEC ap_StoreAuthor 1, 'Crichton'
             EXEC ap_StoreAuthor 2, 'Crichton'   
             SELECT * FROM AUTHOR
             SELECT * FROM AUTHORQUOTE
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_StoreAuthor')
        DROP PROCEDURE dbo.ap_StoreAuthor
    GO
    
    CREATE PROCEDURE dbo.ap_StoreAuthor  
        @QuoteID               int,
        @NameOfAuthor          varchar(50)
    AS
        SET NOCOUNT ON
    
        DECLARE @AuthorID      int
    
        SET @AuthorID = 0
    
        BEGIN TRAN UPDATE_AUTHOR
    
    --  Get key to existing author or create a new one.
        IF DATALENGTH(@NameOfAuthor) > 0
            BEGIN
            SET @AuthorID = (SELECT AuthorID FROM Author WHERE NameOfAuthor=@NameOfAuthor)
            IF @AuthorID IS NULL
                BEGIN
                SET @AuthorID = (SELECT MAX(AuthorID) FROM Author)
                IF @AuthorID IS NULL
                    SET @AuthorID = 0
                SET @AuthorID = @AuthorID + 1            
                INSERT Author (AuthorID, NameOfAuthor) VALUES (@AuthorID, @NameOfAuthor)
                END
            END
    
        IF @AuthorID > 0
            BEGIN
            DELETE FROM AuthorQuote WHERE QuoteID=@QuoteID
            INSERT INTO AuthorQuote (AuthorID, QuoteID) VALUES (@AuthorID, @QuoteID)
            END
    
        IF DATALENGTH(@NameOfAuthor) = 0
            DELETE AuthorQuote WHERE QuoteID = @QuoteID
    
    --  Drop keywords no longer referenced in the many-to-many table.
        DELETE FROM Author WHERE AuthorID IN (
            SELECT Author.AuthorID
              FROM Author LEFT JOIN AuthorQuote 
                ON Author.AuthorID = AuthorQuote.AuthorID
             WHERE AuthorQuote.AuthorID IS NULL)
    
        COMMIT TRAN UPDATE_AUTHOR
    
        RETURN
    GO
      
    GRANT EXECUTE ON dbo.ap_StoreAuthor TO PUBLIC
    GO

