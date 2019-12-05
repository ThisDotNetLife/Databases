/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE QuoteDB
	GO

/*  ================================================================
    USER DEFINED FUNCTION : udf_SplitByDelimiter
    ================================================================
    Purpose: Returns a table of strings that have been split by a 
             delimiter. Null items are not returned so if there are 
             multiple separators between items, only the non-null items 
             are returned. Space is not a valid delimiter.
    Inputs:  @InputList - String of values seperated by a given delimiter. 
             @Delimiter - The delimiting character.
    Syntax:  SELECT * FROM dbo.udf_SplitByDelimiter('Farscape|Flight of the Pheonix|Flight|Pheonix|Plan', '|')
    Author:  Andrew Novick http://www.NovickSoftware.com
    ================================================================  */
    IF EXISTS (SELECT * FROM dbo.sysobjects 
                WHERE id = object_id(N'dbo.udf_SplitByDelimiter') 
                  AND xtype in (N'FN', N'IF', N'TF'))
    DROP FUNCTION dbo.udf_SplitByDelimiter
    GO
    
    CREATE FUNCTION dbo.udf_SplitByDelimiter (
        @InputList varchar(4000),
        @Delimiter char(1) = '-' 
    )   RETURNS @List TABLE (Item varchar(8000))
        WITH SCHEMABINDING
    AS BEGIN
    
    DECLARE @Item Varchar(8000)
    DECLARE @Pos int -- Current Starting Position
          , @NextPos int -- position of next delimiter
          , @LenInput int -- length of input
          , @LenNext int -- length of next item
          , @DelimLen int -- length of the delimiter
    
    SELECT @Pos = 1
         , @DelimLen = LEN(@Delimiter) --  usually 1 
         , @LenInput = LEN(@InputList)
         , @NextPos = CharIndex(@Delimiter, @InputList, 1) 
    
    -- Doesn't work for space as a delimiter
    IF @Delimiter = ' ' BEGIN
       INSERT INTO @List 
           SELECT 'ERROR: Blank is not a valid delimiter'
       RETURN
    END
    
    -- loop over the input, until the last delimiter.
    While @Pos <= @LenInput and @NextPos > 0 BEGIN
    
        IF @NextPos > @Pos BEGIN -- another delimiter found
           SET @LenNext = @NextPos - @Pos           
           Set @Item = LTrim(RTrim(
                                substring(@InputList
                                       , @Pos
                                      , @LenNext)
                                   )
                             ) 
           IF LEN(@Item) > 0 
               Insert Into @List Select @Item
           -- ENDIF
    
        END -- IF
    
        -- Position over the next item
        SELECT @Pos = @NextPos + @DelimLen
             , @NextPos = CharIndex(@Delimiter
                                  , @InputList
                                  , @Pos) 
    END
    
    -- Now there might be one more item left
    SET @Item = LTrim(RTrim(
                          SUBSTRING(@InputList
                                   , @Pos
                                   , @LenInput-@Pos + 1)
                           )
                     )
    
    IF Len(@Item) > 0 -- Put the last item in, if found
       INSERT INTO @List SELECT @Item
    
    RETURN
    END
    GO
    
    GRANT SELECT ON dbo.udf_SplitByDelimiter TO Public
    GO