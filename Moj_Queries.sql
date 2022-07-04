
1) /*1. Total number of adult females who have signed up on Moj.*/
*********************************************************************************
*********************************************************************************
SELECT count(*)
FROM moj_user
WHERE gender = 'F'
	AND TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) >= 18

---------------------------------------------------------------------------------
2)/* Total number of adult female influencers on Moj (influencer is anyone who has more than
10,000 followers).*/
*********************************************************************************
*********************************************************************************

SELECT count(userid) AS n_afemale_influencers
FROM (
	SELECT mj.userid
		,(
			coalesce(count(f.userid), 0) - coalesce((
					SELECT count(u.userid)
					FROM unfollow u
					WHERE u.userid = mj.userid
					), 0)
			) AS follower_count
	FROM moj_user mj
	LEFT JOIN follow f ON mj.userid = f.userid
	WHERE gender = 'F'
		AND TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) >= 18
	GROUP BY mj.userid
	) AS subquery
WHERE follower_Count > 100000

---------------------------------------------------------------------------------
3) 

 /* Top 25 female adult influencers who have maximum adult female followers (arranged in
descending order of total followers) (in absolute numbers).*/
*********************************************************************************
*********************************************************************************

SELECT a.userid
	  ,a.handle
	  ,(
		count(a.followerid) - coalesce((
				SELECT count(u.userid)
				FROM unfollow u
				WHERE u.userid = a.userid
				), 0)
		) AS follower_count
FROM (
	SELECT a.userid
		,a.handle
		,a.gender
		,a.date_of_birth
		,b.followerid
	FROM Moj_user a
	JOIN follow b ON a.userid = b.userid
	WHERE a.userid IN (
			SELECT mj.userid
			FROM moj_user mj
			JOIN follow f ON mj.userid = f.userid
			WHERE gender = 'F'
				AND TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) >= 18
			GROUP BY mj.userid
			HAVING (
					coalesce(count(f.userid), 0) - coalesce((
							SELECT count(u.userid)
							FROM unfollow u
							WHERE u.userid = mj.userid
							), 0)
					) >= 10000
			)
	) a
JOIN moj_user b ON a.followerid = b.userid
WHERE b.gender = 'F'
	AND TIMESTAMPDIFF(YEAR, b.date_of_birth, CURDATE()) >= 18
GROUP BY a.userid
	    ,a.handle
ORDER BY (
		count(followerid) - coalesce((
				SELECT count(u.userid)
				FROM unfollow u
				WHERE u.userid = a.userid
				), 0)
		) DESC 
		limit 25								  
	
			