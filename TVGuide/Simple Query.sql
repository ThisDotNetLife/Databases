SELECT E.SeasonNo, E.EpisodeNo, R.CharacterName,  R.IsActor,  R.IsWriter,  R.IsDirector, P.FirstName, P.LastName, P.IsFamous
  FROM CastCrewMember R 
       INNER JOIN Episode E ON R.Episode_ID=E.ID
	   INNER JOIN Person P   ON P.ID=R.Person_ID
 WHERE Episode_ID IN (SELECT ID FROM Episode)
 ORDER BY E.SeasonNo, E.EpisodeNo