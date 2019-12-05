/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    STORED PROCEDURE : ap_StoreKeywords
    ================================================================
    Purpose: Updates the keywords in both the Keyword and KeywordQuote
             table (the many-to-many table for this data).
    Inputs:  @InputList - String of values seperated by a given delimiter. 
             @Delimiter - The delimiting character.
    Syntax:  EXECUTE ap_StoreKeywords 1, 'Flight of the Pheonix|Movie|Flight|Pheonix'
             EXECUTE ap_StoreKeywords 2, 'Farscape|Revenge'
             EXECUTE ap_StoreKeywords 1, ''
             SELECT * FROM Keyword
             SELECT * FROM KeywordQuote
    ================================================================  */
    IF EXISTS (SELECT NAME FROM sysobjects WHERE xtype='P' AND Name='ap_StoreKeywords')
        DROP PROCEDURE dbo.ap_StoreKeywords
    GO
    
    CREATE PROCEDURE dbo.ap_StoreKeywords  
        @QuoteID      int,
        @CSVOfLinks   varchar(4000)
    AS
        SET NOCOUNT ON
        
        BEGIN TRAN UPDATE_KEYWORDS
    
    --  Parse and store new keywords into a temp table.
        CREATE TABLE #KeywordsPassed (NewWord VARCHAR(25), NewWordID INT NULL)
        INSERT INTO #KeywordsPassed(NewWord)
            SELECT * FROM dbo.udf_SplitByDelimiter(@CSVOfLinks, '|') 
    
    --  Determine the value of the next primary key in the Keywords table.
        DECLARE @StarterID INT
        SET @StarterID = (SELECT MAX(KeywordID) FROM Keyword)
        IF @StarterID IS NULL
            SET @StarterID = 0
    
    --  Insert any new words that don't already exist in the Keywords table.
        DECLARE @Word2Store VARCHAR(25)
        DECLARE MyCursor CURSOR LOCAL FOR
            SELECT NewWord FROM #KeywordsPassed 
               WHERE NewWord NOT IN (SELECT DISTINCT(WatchWord) FROM Keyword)
    
        OPEN MyCursor
      --  Retrieve the first row of data from the cursor.
          FETCH NEXT FROM MyCursor INTO @Word2Store
    
    --    Loop through the rowset until end of file is reached.
          WHILE @@FETCH_STATUS = 0
          BEGIN  
             SET @StarterID = @StarterID + 1
             INSERT Keyword (KeywordID, WatchWord)
                VALUES (@StarterID, @Word2Store)
    
             FETCH NEXT FROM MyCursor INTO @Word2Store
          END
    
        CLOSE MyCursor
        DEALLOCATE MyCursor 
    
    --  Update the temp table so we know every primary key for all keywords that
    --  are associated with the given quotation.
        UPDATE #KeywordsPassed 
           SET NewWordID = KeywordID
          FROM #KeywordsPassed JOIN Keyword 
            ON (#KeywordsPassed.NewWord = Keyword.WatchWord)              
    
    --  Log any new keywords to the many-to-many table.
        INSERT INTO KeywordQuote(KeywordID, QuoteID)
            SELECT NewWordID, @QuoteID FROM #KeywordsPassed 
             WHERE NewWordID NOT IN 
               (SELECT KeywordID FROM KeywordQuote WHERE QuoteID=@QuoteID)
    
    --  Delete rows in many-to-many table for those keywords that were dropped.
        DELETE KeywordQuote
         WHERE QuoteID = @QuoteID
           AND KeywordID NOT IN (
            SELECT NewWordID FROM #KeywordsPassed)
    
    --  Handle case where user decides to delete all keywords for the quotation.
        IF DATALENGTH(@CSVOfLinks) = 0
            DELETE KeywordQuote WHERE QuoteID = @QuoteID
    
    --  Drop keywords no longer referenced in the many-to-many table.
        DELETE FROM Keyword WHERE KeywordID IN (
            SELECT Keyword.KeywordID
              FROM Keyword LEFT JOIN KeywordQuote 
                ON Keyword.KeywordID = KeywordQuote.KeywordID
             WHERE KeywordQuote.KeywordID IS NULL)
    
        COMMIT TRAN UPDATE_KEYWORDS
    GO
      
    GRANT EXECUTE ON dbo.ap_StoreKeywords TO PUBLIC
    GO