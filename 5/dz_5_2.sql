create table small_ratings as 
SELECT * FROM ratings LIMIT 10000;


SELECT userID, array_agg(distinct movieId) as user_views FROM small_ratings group by userid;

DROP TABLE IF EXISTS user_movies_agg;
SELECT userID, user_views INTO public.user_movies_agg FROM 
(SELECT userID, array_agg(distinct movieId) as user_views
FROM small_ratings group by userid);

SELECT * FROM user_movies_agg;


CREATE OR REPLACE FUNCTION cross_arr (int[], int[]) RETURNS int[] as 
$$
select ARRAY(
SELECT UNNEST($1) AS ARR1
INTERSECT
SELECT UNNEST($2) AS ARR2
);
$$ language sql;

select u1.userid u1, u1.user_views r1, u2.userid u2, u2.user_views r2 
from user_movies_agg u1, user_movies_agg u2 
where u1.userid <> u2.userid;

WITH USERS_LINE AS (
    select u1.userid u1, u1.user_views r1, u2.userid u2, u2.user_views r2 
    from user_movies_agg u1, user_movies_agg u2 
    where u1.userid <> u2.userid
)
, USER_PAIRS AS (
    SELECT u1, u2, cross_arr(r1::int[], r2::int[]) crossed_array
    FROM USERS_LINE 
)
SELECT u1, u2, crossed_array INTO common_user_views FROM user_pairs;

SELECT * FROM common_user_views;

CREATE OR REPLACE FUNCTION diff_arr (int[], int[]) RETURNS int[] as 
$$
select ARRAY(
SELECT UNNEST($1) AS ARR1
EXCEPT
SELECT UNNEST($2) AS ARR2
);
$$ language sql;