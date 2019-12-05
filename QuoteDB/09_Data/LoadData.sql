/*  ================================================================
    SELECT THE DATABASE
    ================================================================  */
    USE Quotations
	GO

/*  ================================================================
    LOAD TEST DATA
    ================================================================  */
    DECLARE @RC1 INT; EXEC @RC1 = ap_StoreQuotation 'Q', 'Flight of the Pheonix', 'I think a man only needs one thing in life.|He just needs someone to love.|If you can''t give him that, then give him something to believe in, and if you can''t give him that, then give him something to do.', 'Work|Life'
    DECLARE @RC2 INT; EXEC @RC2 = ap_StoreQuotation 'Q', 'D''Argo',  'Revenge is a feast best served immediately.', 'Farscape|Revenge'
    DECLARE @RC3 INT; EXEC @RC3 = ap_StoreQuotation 'Q', 'John Crichton', 'Have we sent the ''don''t shoot us we''re pathetic'' transmission yet?', 'Farscape'
    DECLARE @RC4 INT; EXEC @RC4 = ap_StoreQuotation 'Q', 'Aeryn Sun', 'Oh, just to be in the warm glow of all this testosterone.', 'Farscape|Men'
    DECLARE @RC5 INT; EXEC @RC5 = ap_StoreQuotation 'Q', 'John Crichton', 'That''s your plan? Wile E. Coyote would come up with a better plan than that!', 'Farscape|Plan|Project Planning'
    DECLARE @RCA INT; EXEC @RCA = ap_StoreQuotation 'Q', '', 'Father: A man who expects his son to be as good as he meant to be.', 'Father|Son|Good'
    DECLARE @RCB INT; EXEC @RCB = ap_StoreQuotation 'Q', '', 'You can tell when you''re on the right road--it''s uphill.', 'Work'
    DECLARE @RCC INT; EXEC @RCC = ap_StoreQuotation 'Q', 'HellBoy', 'What makes a man a man?|Is it his origin?|The way he comes to life?|I don''t think so.|Its the choices he makes.|Not how he starts things,but how he decides to end them.', 'Work|Life|Love|Choices'
    DECLARE @RCD INT; EXEC @RCD = ap_StoreQuotation 'Q', '', 'A perfect summer day is when the sun is shining, the breeze is blowing, the birds are singing and the lawn mower is broken.', 'Summer|Relaxation|Work'
    DECLARE @RCE INT; EXEC @RCE = ap_StoreQuotation 'Q', '', 'Well begun is half done.', 'Work'
    DECLARE @RCF INT; EXEC @RCF = ap_StoreQuotation 'Q', '', 'The grass may be greener on the other side, but it''s just as hard to cut.', 'Work|Opportunity'
    DECLARE @RCG INT; EXEC @RCG = ap_StoreQuotation 'Q', 'Will Smith', 'The greatest dreams are always unrealistic.', 'Work|Opportunity|Dreams'
    DECLARE @RCH INT; EXEC @RCH = ap_StoreQuotation 'Q', 'George Foreman', 'There''s more to boxing than hitting. There''s not getting hit, for instance.', 'Fighting|Boxing'
    DECLARE @RCI INT; EXEC @RCI = ap_StoreQuotation 'Q', 'Bernie Brillstein', 'Outcomes rarely turn on grand gestures or the art of the deal, but on whether you''ve sent someone a thank-you note.', 'Etiquite|Business|Opportunity|Success'
    DECLARE @RCJ INT; EXEC @RCJ = ap_StoreQuotation 'Q', '', 'Confidence is the feeling you have before you fully understand the situation.', 'Opportunity|Confidence'
    DECLARE @RCK INT; EXEC @RCK = ap_StoreQuotation 'Q', '', 'The wish for tomorrow should never supercede the will to live for today.', 'Work|Dreams|Life'
    DECLARE @RCL INT; EXEC @RCL = ap_StoreQuotation 'Q', '', 'Through prayer and tears we gain a quiet, peaceful heart.', 'Tears|Prayer|Heart|Peace'
    DECLARE @RCM INT; EXEC @RCM = ap_StoreQuotation 'Q', '', 'One of the secrets of life is to make stepping stones out of building blocks.', 'Life|Success|Opportunity'
    DECLARE @RCN INT; EXEC @RCN = ap_StoreQuotation 'Q', '', 'Do not handicap your children by making their live easy', 'Children|Parenting'
    DECLARE @RCO INT; EXEC @RCO = ap_StoreQuotation 'Q', '', 'Some are wise, and some are otherwise.', 'Wisdom'
    DECLARE @RCP INT; EXEC @RCP = ap_StoreQuotation 'Q', 'Nelson Henderson', 'The true meaning of life is to plant trees, under whose shade you do not expect to sit', 'Life|Work|Compassion'
    DECLARE @RCQ INT; EXEC @RCQ = ap_StoreQuotation 'Q', '', 'A candle loses nothing by lighting another candle.', 'Charity|Compassion'
    DECLARE @RCR INT; EXEC @RCR = ap_StoreQuotation 'Q', 'James F. Byrnes', 'Too many people are thinking of security instead of opportunity. They seem more afraid of life than death.','Life|Success|Opportunity'
    DECLARE @RCS INT; EXEC @RCS = ap_StoreQuotation 'Q', '','A goal is a dream with a deadline.','Success|Goals|Dreams'
    GO

/*  ================================================================
    RETRIEVE TEST DATA
    ================================================================  */
    EXEC ap_GetAnEntry 1;  EXEC ap_GetAnEntry 2;  EXEC ap_GetAnEntry 3;  EXEC ap_GetAnEntry 4;  EXEC ap_GetAnEntry 5
    EXEC ap_GetAnEntry 6;  EXEC ap_GetAnEntry 7;  EXEC ap_GetAnEntry 8;  EXEC ap_GetAnEntry 9;  EXEC ap_GetAnEntry 10
    EXEC ap_GetAnEntry 11; EXEC ap_GetAnEntry 12; EXEC ap_GetAnEntry 13; EXEC ap_GetAnEntry 14; EXEC ap_GetAnEntry 15
    EXEC ap_GetAnEntry 16; EXEC ap_GetAnEntry 17; EXEC ap_GetAnEntry 18; EXEC ap_GetAnEntry 19; EXEC ap_GetAnEntry 20
    EXEC ap_GetAnEntry 21; EXEC ap_GetAnEntry 22; EXEC ap_GetAnEntry 23; EXEC ap_GetAnEntry 24
    GO