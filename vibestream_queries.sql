/*
Question #1: 
Vibestream is designed for users to share brief updates about 
how they are feeling, as such the platform enforces a character limit of 25. 
How many posts are exactly 25 characters long?

Expected column names: char_limit_posts
*/

-- q1 solution:

SELECT 
	COUNT(post_id) AS char_limit_posts
FROM
	posts
WHERE
	LENGTH(content) = 25
;



/*

Question #2: 
Users JamesTiger8285 and RobertMermaid7605 are Vibestream’s most active posters.

Find the difference in the number of posts these two users made on each day 
that at least one of them made a post. Return dates where the absolute value of 
the difference between posts made is greater than 2 
(i.e dates where JamesTiger8285 made at least 3 more posts than RobertMermaid7605 or vice versa).

Expected column names: post_date
*/

-- q2 solution:


WITH filterd_table AS (              -- Create a temporary filtered table
  SELECT
    posts.post_date AS post_date,  
    COUNT(posts.post_id) FILTER (WHERE users.user_name = 'JamesTiger8285') AS nums_james_post,  -- Count posts by James
    COUNT(posts.post_id) FILTER (WHERE users.user_name = 'RobertMermaid7605') AS nums_robert_post  -- Count posts by Robert
  FROM 
    users 
  JOIN 
    posts ON users.user_id = posts.user_id  -- Join users and posts on user_id
  GROUP BY 
    posts.post_date                          -- Group by post_date
  HAVING 
    COUNT(posts.post_id) FILTER (WHERE users.user_name = 'JamesTiger8285') >=1  
    OR              																															-- Only include dates where James posted Or Robert posted
    COUNT(posts.post_id) FILTER (WHERE users.user_name = 'RobertMermaid7605') >=1  
)

SELECT
    post_date
FROM
    filterd_table
WHERE 
    ABS(nums_james_post - nums_robert_post) > 2  -- Return dates where the absolut difference in post counts is greater than 2
;



----Second Solution 

SELECT
    posts.post_date 
FROM 
    users
JOIN 
    posts ON users.user_id = posts.user_id    -- Join users and posts on user_id
GROUP BY 
    posts.post_date                         -- Group by post date
HAVING 
    ABS(
        SUM(CASE WHEN users.user_name = 'JamesTiger8285' THEN 1 ELSE 0 END) -  -- Count posts by James
        SUM(CASE WHEN users.user_name = 'RobertMermaid7605' THEN 1 ELSE 0 END)  -- Count posts by Robert
    ) > 2               -- Only return dates where the absolut difference in post counts is greater than 2
;               



/*
Question #3: 
Most users have relatively low engagement and few connections. 
User WilliamEagle6815, for example, has only 2 followers.

Network Analysts would say this user has two **1-step path** relationships. 
Having 2 followers doesn’t mean WilliamEagle6815 is isolated, however. 
Through his followers, he is indirectly connected to the larger Vibestream network.  

Consider all users up to 3 steps away from this user:

- 1-step path (X → WilliamEagle6815)
- 2-step path (Y → X → WilliamEagle6815)
- 3-step path (Z → Y → X → WilliamEagle6815)

Write a query to find follower_id of all users within 4 steps of WilliamEagle6815. 
Order by follower_id and return the top 10 records.

Expected column names: follower_id

*/

-- q3 solution:

WITH one_step_path AS (
  
  SELECT             -- Selecting the direct followers of WilliamEagle6815 (1-step)
    follower_id 
  FROM 
    follows
  WHERE 
   followee_id = (SELECT user_id FROM users WHERE user_name = 'WilliamEagle6815')
),

two_step_path AS (
  
  SELECT              -- Selecting followers of the users in the 1-step path (2-step)
    follows.follower_id AS follower_id
  FROM 
    follows
  WHERE 
    follows.followee_id IN (SELECT follower_id FROM one_step_path)
),

three_step_path AS (
  
  SELECT            -- Selecting followers of the users in the 2-step path (3-step)
    follows.follower_id AS follower_id
  FROM 
    follows
  WHERE 
    follows.followee_id IN (SELECT follower_id FROM two_step_path)
),

four_step_path AS (
  
  SELECT          -- Selecting followers of the users in the 3-step path (4-step)
    follows.follower_id AS follower_id
  FROM 
    follows
  WHERE 
    follows.followee_id IN (SELECT follower_id FROM three_step_path)
)


SELECT DISTINCT follower_id     -- Combining all the follower_id from the 1-step to 4-step paths
FROM one_step_path
UNION
SELECT follower_id FROM two_step_path
UNION
SELECT follower_id FROM three_step_path
UNION
SELECT follower_id FROM four_step_path
ORDER BY follower_id
LIMIT 10
;     

/*
Question #4: 
Return top posters for 2023-11-30 and 2023-12-01. 
A top poster is a user who has the most OR second most number of posts 
in a given day. Include the number of posts in the result and 
order the result by post_date and user_id.

Expected column names: post_date, user_id, posts

</aside>
*/

-- q4 solution:

WITH ranked_by_post_count AS (
  SELECT
			post_date,
      user_id,
      COUNT(post_id) AS posts,     ----- Count the number of posts per user
      DENSE_RANK () OVER (ORDER BY COUNT(post_id) DESC ) AS rank    -- Rank users by post count
      
FROM
		posts
WHERE 
		post_date IN ('2023-11-30' , '2023-12-01')  -- Filter for specific dates
GROUP BY 
		post_date, user_id
ORDER BY 
		post_date, COUNT(post_id) DESC  -- Order by post date, then by post count (highest first)

)

SELECT
			post_date,
      user_id,
      posts
FROM
		ranked_by_post_count
WHERE 
		rank <= 2  -- Only show top 2 ranks
ORDER BY 
		post_date, user_id
;
