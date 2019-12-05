/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    VIEW : vw_AllSubjects
    ================================================================
    Purpose: Return all subjects in alphabetical order. In addition, 
             this view returns the number of quotations attributed 
             to each subject.
    ================================================================  */
    IF EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND category = 0 AND name='vw_AllSubjects')
        DROP VIEW vw_AllSubjects
    GO
    
    CREATE VIEW vw_AllSubjects AS
      SELECT Keyword.WatchWord, COUNT(KeywordQuote.QuoteID) AS TimesReferenced
        FROM KeywordQuote RIGHT JOIN Keyword 
          ON KeywordQuote.KeywordID = Keyword.KeywordID
    GROUP BY Keyword.WatchWord
      HAVING COUNT(KeywordQuote.QuoteID) > 0
    GO