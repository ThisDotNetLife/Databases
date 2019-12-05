/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    VIEW : vw_AllAuthors
    ================================================================
    Purpose: Return all authors in alphabetical order. In addition, 
             this view returns the number of quotations attributed 
             to each author.
    ================================================================  */
    IF EXISTS (SELECT * FROM sysobjects WHERE xtype='V' AND category = 0 AND name='vw_AllAuthors')
        DROP VIEW vw_AllAuthors
    GO
    
    CREATE VIEW vw_AllAuthors AS
      SELECT Author.NameOfAuthor, COUNT(AuthorQuote.QuoteID) AS TimesQuoted
        FROM AuthorQuote RIGHT JOIN Author 
          ON AuthorQuote.AuthorID = Author.AuthorID
    GROUP BY Author.NameOfAuthor
      HAVING COUNT(AuthorQuote.QuoteID) > 0
    GO