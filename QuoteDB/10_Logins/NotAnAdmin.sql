/*  ================================================================
    CREATE A NON-ADMINISTRATIVE USER ID
    ================================================================  */
    USE Master
    GO
    EXEC sp_addlogin 'NotAnAdmin', 'FigureItOut', 'master'
    GO
    USE AllMyQuotes
    GO
    EXEC sp_grantdbaccess 'NotAnAdmin'
    GO
    EXEC sp_addrolemember 'db_owner',      'NotAnAdmin'
    GO
    USE Master
    GO
    EXEC sp_helplogins 'NotAnAdmin'
    GO