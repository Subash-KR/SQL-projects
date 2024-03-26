CREATE DATABASE ipl;
USE ipl;

-- Getting to know your data
SELECT * FROM ipl_bidding_details;
SELECT * FROM  ipl_bidder_details;
SELECT * FROM ipl_bidder_points; 
SELECT * FROM ipl_match;
SELECT * FROM ipl_match_schedule;
SELECT * FROM ipl_player;
SELECT * FROM ipl_team_standings;
SELECT * FROM ipl_tournament;

-- 1.Show the percentage of wins of each bidder in the order of highest to lowest percentage
### total bid count
SELECT Count(Bid_Status) FROM ipl_bidding_details ;
### wincount
SELECT 
    BIDDER_ID, COUNT(Bid_Status) win_count
FROM
    ipl_bidding_details
WHERE
    BID_STATUS = 'Won'
GROUP BY bidder_id;
### Solution - 
SELECT a.Bidder_id,round((win_count/count(Bid_Status))*100,2) AS wins_percentage FROM ipl_bidding_details a 
JOIN
(SELECT BIDDER_ID , Count(Bid_Status) AS win_count FROM ipl_bidding_details b WHERE BID_STATUS = 'Won' GROUP BY bidder_id)t
ON a.Bidder_id = t.Bidder_id GROUP BY a.Bidder_id ORDER BY wins_percentage DESC ;

## In above question we concluded that Bidder with Bidder ID 103 has highest wining percentage i.e 100% follwed by bidder ID 121 with winning percentge 90.91 and bidder id 10%.##

-------------------------------------------------------------------------------------------------------------
-- 2.Display the number of matches conducted at each stadium with the stadium name and city.
SELECT 
    a.STADIUM_ID, a.STADIUM_NAME, a.City, COUNT(match_id)
FROM
    ipl_stadium a
        JOIN
    ipl_match_schedule b ON a.STADIUM_ID = b.STADIUM_ID
GROUP BY a.STADIUM_ID
ORDER BY a.STADIUM_ID;
## In above we analysed that highest no. of matches were conducted at  wankhede stadium , Mumbai foolowed by Is bindra stadium, Mohali  .

-------------------------------------------------------------------------------------------------------------

-- 3.In a given stadium, what is the percentage of wins by a team which has won the toss?
select * from ipl_match;
SELECT SUM(
  CASE 
    WHEN 
	( toss_winner = match_winner )  
	THEN 1
	ELSE 0 
  END) / COUNT(*) * 100 "Percentage of wins by a team which has won the toss"
FROM ipl_match;
##In above scenerio, we concluded that the Percentage of wins by a team which has won the toss is 46.6667.

-------------------------------------------------------------------------------------------------------------
 -- 4.Show the total bids along with the bid team and team name.

SELECT b.bid_team,c.TEAM_NAME,sum(a.no_of_bids) AS total_bids FROM ipl_bidder_points a  JOIN ipl_bidding_details b
 ON a.BIDDER_ID = b.BIDDER_ID JOIN ipl_team c  ON b.BID_TEAM = c.TEAM_ID GROUP BY   b.bid_team ORDER BY  b.bid_team ;
 
 ##Above table is showing us the count of total bids of each team where sunrisers Hyderabad has highest total bids.
 
-------------------------------------------------------------------------------------------------------------

-- 5.Show the team id who won the match as per the win details.
SELECT 
    match_id,
    WIN_DETAILS,
    CASE
        WHEN match_winner = 1 THEN team_id1
        WHEN match_winner = 2 THEN team_id2
        ELSE 0
    END AS winning_team_id
FROM
    ipl_match;
##Using CASE WHEN here in this query we have got the desired outcome that which team has who won the match as per the win details.

-------------------------------------------------------------------------------------------------------------

 -- 6.Display total matches played, total matches won and total matches 	lost by the team along with its team name.
 ##Solution :
 SELECT 
    a.team_name,
    SUM(matches_played) total_matches_played,
    SUM(matches_won) total_matches_won,
    SUM(matches_lost) total_matches_lost
FROM
    ipl_team a
        JOIN
    ipl_team_standings b ON a.team_id = b.team_id
GROUP BY a.team_name;
 ## As asked in question here we have summarised total matched played , total matches won and total matches lost  by  each team
 
 -------------------------------------------------------------------------------------------------------------
 
-- 7.Display the bowlers for the Mumbai Indians team.
SELECT 
    a.player_name, c.Team_name, b.player_role
FROM
    ipl_player a
        JOIN
    ipl_team_players b ON a.PLAYER_ID = b.PLAYER_ID
        JOIN
    ipl_team c ON b.team_id = c.team_id
WHERE
    c.team_name LIKE '%Mumbai Indians%'
        AND b.player_role LIKE '%Bowler%';

## Here with the help of joins we have extracted the bowlres from Mumbai indians and we came to know that mumbai indians has total 9 bowlers.

-------------------------------------------------------------------------------------------------------------

-- 8.How many all-rounders are there in each team, Display the teams with more than 4 all-rounders in descending order.
select * from ipl_team_players;
SELECT 
    *
FROM
    ipl_team;
SELECT 
    a.team_name, COUNT(player_role) AS All_rounders
FROM
    ipl_team a
        JOIN
    ipl_team_players b ON a.team_id = b.team_id
WHERE
    player_role = 'All-Rounder'
GROUP BY a.team_name
HAVING All_rounders > 4
ORDER BY All_rounders DESC;

 ##Here with the help of joins and having clause we have extracted the teams with more than 4 all-rounders and we came to know that Delhi Daredevils has more no of all rounders.
 
 -------------------------------------------------------------------------------------------------------------
 
/*9. Write a query to get the total bidders points for each bidding status of those bidders who bid on CSK when it won the match in M. Chinnaswamy Stadium bidding year-wise.
 Note the total bidders’ points in descending order and the year is bidding year.
               Display columns: bidding status, bid date as year, total bidder’s points */ 
     
SELECT 
    a.BIDDER_ID,
    YEAR(bid_date),
    a.bid_status,
    SUM(b.TOTAL_POINTS)
FROM
    ipl_bidding_details a
        JOIN
    ipl_bidder_points b ON a.BIDDER_ID = b.BIDDER_ID
GROUP BY a.BIDDER_ID , a.bid_status , YEAR(bid_date)
HAVING bidder_id IN ((SELECT 
        bidder_id
    FROM
        ipl_bidding_details
    WHERE
        schedule_id IN (SELECT 
                ad.schedule_id
            FROM
                (SELECT 
                    stadium_name, stadium_id
                FROM
                    ipl_stadium) a
                    JOIN
                (SELECT 
                    T1.match_id, stadium_id, winning_team_id, schedule_id
                FROM
                    (SELECT 
                    match_id, Stadium_id, schedule_id
                FROM
                    ipl_match_schedule) T1
                JOIN (SELECT 
                    match_id,
                        CASE
                            WHEN match_winner = 1 THEN team_id1
                            WHEN match_winner = 2 THEN team_id2
                            ELSE 0
                        END AS winning_team_id
                FROM
                    ipl_match
                WHERE
                    Win_details LIKE '%CSK%') T2 ON T1.match_id = T2.match_id
                    AND stadium_id = 7) ad ON ad.stadium_id = a.stadium_id)))
ORDER BY SUM(b.TOTAL_POINTS) DESC;   
     
#Above result shows that bidder id 104 has the maximum total points when CSK won the match in M. Chinnaswamy Stadium.

-------------------------------------------------------------------------------------------------------------

/* 10.Extract the Bowlers and All Rounders those are in the 5 highest number of wickets.
Note 
1. use the performance_dtls column from ipl_player to get the total number of wickets
2. Do not use the limit method because it might not give appropriate results when players have the same number of wickets
3.Do not use joins in any cases.
4.Display the following columns teamn_name, player_name, and player_role. */

SELECT team "Team name" , player_name "Player name" , role "Player role" , wickets "Wickets" FROM
( SELECT * , DENSE_RANK() OVER(ORDER BY wickets DESC) "rank" FROM
( SELECT * , ( SELECT team_name FROM ipl_team WHERE team_id=t3.team_id ) "team" FROM
( SELECT player_name ,
( SELECT team_id FROM ipl_team_players WHERE t2.player_id=player_id) "team_id", 
( SELECT player_role FROM ipl_team_players WHERE t2.player_id=player_id) "role",
SUBSTR(wkt,1,LENGTH(wkt)-LENGTH(substr(wkt,INSTR(wkt," ")))) "wickets" from
( SELECT *,SUBSTR(wkts,INSTR(wkts,"-")+1) "wkt" from 
( SELECT *,SUBSTR(performance_dtls,INSTR(performance_dtls,"W")) "wkts" from
( SELECT * from Ipl_player)t )t1 
)t2
ORDER BY Wickets DESC)t3 
)t4 )t5
WHERE `rank`<=5 AND (`role`="Bowler" OR `role`="All-Rounder");

##we have got the player nmes of 5 hiighest wicket scoring team where Bubhneshwar kumar who is an allrounder from teamsunriser hyderabad has scored 9 wickets. 

-------------------------------------------------------------------------------------------------------------

-- 11.show the percentage of toss wins of each bidder and display the results in descending order based on the percentage.
SELECT 
    dd.bidder_id,
    dd.total_toss_wins,
    ROUND((dd.total_toss_wins * 100 / (SELECT 
                    COUNT(toss_winner)
                FROM
                    ipl_match)),
            2) AS percentage_toss_wins
FROM
    (SELECT 
        T1.bidder_id, COUNT(T2.winning_toss_ID) AS total_toss_wins
    FROM
        (SELECT 
        bidder_id, bid_team
    FROM
        ipl_bidding_details) T1
    JOIN (SELECT 
        CASE
                WHEN toss_winner = 1 THEN team_id1
                WHEN toss_winner = 2 THEN team_id2
                ELSE 0
            END AS winning_toss_ID
    FROM
        ipl_match
    WHERE
        toss_winner) T2 ON T1.bid_team = T2.winning_toss_ID
    GROUP BY T1.bidder_id) dd
GROUP BY dd.bidder_id , dd.total_toss_wins
ORDER BY percentage_toss_wins DESC;
         
#Here from above outcome we concluded that bidder with bidder id 121 won highest toss 

-------------------------------------------------------------------------------------------------------------

/* 12.find the IPL season which has min duration and max duration.
Output columns should be like the below:
 Tournment_ID, Tourment_name, Duration column, Duration */
 
select Tournmt_id,tournmt_name, Duration_days,
 case 
 when Duration_days =(select  max(datediff(To_date,from_date)) from ipl_tournament) then 'Max'
 when Duration_days =(select  min(datediff(To_date,from_date)) from ipl_tournament) then 'Min'
 else 0
end as Duration from 
 (select Tournmt_id,tournmt_name,datediff(To_date,from_date) as Duration_days  from ipl_tournament
where datediff(To_date,from_date) = (select  max(datediff(To_date,from_date)) from ipl_tournament) or
 datediff(To_date,from_date) = (select  min(datediff(To_date,from_date)) from ipl_tournament))T ;
 
#It is concluded that maximum duration IPL SEASON was 2012 , 2013 

-------------------------------------------------------------------------------------------------------------

/* 13.Write a query to display to calculate the total points month-wise for the 2017 bid year. 
sort the results based on total points in descending order and month-wise in ascending order.
Note: Display the following columns:
1.Bidder ID, 2. Bidder Name, 3. bid date as Year, 4. bid date as Month, 5. Total points
Only use joins for the above query queries. */

select  T1.bidder_id , T1.bidder_Name, month(T2.bid_date) as bid_month , year(T2.bid_date) as bid_year ,sum(T3.total_points) as total_points
from ipl_bidder_details as T1 left join ipl_bidding_details as T2 on T1.bidder_id= T2.bidder_id 
 join ipl_bidder_points as T3 
 on T1.bidder_id = T3.bidder_id where year(T2.bid_date) = '2017' group by T1.bidder_id,T1.bidder_name, year(T2.bid_date) ,month(T2.bid_date)
 order by month(T2.bid_date), sum(T3.total_points) desc;

#From the outcome it shows that  bidder named Aryabhatta Parachure has the maximum total points for the year 2017.

-------------------------------------------------------------------------------------------------------------

-- 14.Write a query for the above question using sub queries by having the same constraints as the above question.
with T as 
(select a.bidder_id,a.bidder_name,year(b.bid_date) as Year ,month(b.bid_date) as Month ,sum(c.total_points) as Total_points 
from ipl_bidder_details a join ipl_bidding_details b
on a.BIDDER_ID = b.BIDDER_ID join ipl_bidder_points c on b.BIDDER_ID=c.BIDDER_ID
group by a.bidder_id,a.bidder_name,year(b.bid_date),month(b.bid_date) order by month(b.bid_date),sum(c.total_points) desc)
select * from T where Year ='2017';
-
#From the outcome it shows that  bidder named Aryabhatta Parachure has the maximum total points for the year 2017.

-------------------------------------------------------------------------------------------------------------

/* 15.Write a query to get the top 3 and bottom 3 bidders based on the total bidding points for the 2018 bidding year.
Output columns should be:like:Bidder Id, Ranks (optional), Total points, Highest_3_Bidders --> columns contains name of bidder,
Lowest_3_Bidders  --> columns contains name of bidder; */
 
 SELECT rank_id "Rank",`Lowest bidder ID`,`Lowest bidder`,points,`Highest bidder id`,`Highest bidder`,total_points"Points"
FROM
( SELECT * FROM
( SELECT * , ROW_NUMBER() OVER(ORDER BY points) "Rank_id" FROM
( SELECT a.bidder_id "Lowest bidder id", bidder_name "Lowest bidder" , YEAR(b.bid_date) , SUM(c.TOTAL_POINTS) AS "Points" 
  FROM ipl_bidder_details a 
  JOIN ipl_bidding_details b ON a.BIDDER_ID=b.BIDDER_ID 
  JOIN ipl_bidder_points c ON b.BIDDER_ID=c.BIDDER_ID 
  WHERE YEAR(b.bid_date)='2018' 
  GROUP BY a.BIDDER_ID , a.BIDDER_NAME , YEAR(b.bid_date)
  ORDER BY SUM(c.TOTAL_POINTS) LIMIT 3)t1)t2
 JOIN 
( SELECT * FROM
( SELECT *  , ROW_NUMBER() OVER(ORDER BY total_points DESC) "Rank_id"FROM
( SELECT a.bidder_id "Highest bidder Id",a.Bidder_name "Highest bidder",SUM(c.TOTAL_POINTS) "total_points" 
  FROM ipl_bidder_details a 
  JOIN ipl_bidding_details b ON a.BIDDER_ID=b.BIDDER_ID 
  JOIN ipl_bidder_points c ON b.BIDDER_ID=c.BIDDER_ID 
  WHERE YEAR(b.bid_date)='2018' 
  GROUP BY a.BIDDER_ID , a.BIDDER_NAME , YEAR(b.bid_date) , c.TOTAL_POINTS
  ORDER BY SUM(c.TOTAL_POINTS) DESC LIMIT 3)t3)t4)t5
  USING(rank_id))t6;
 
 #Above result shows the top three and bottom three bidders based on the total points for the year 2018.
 
 -------------------------------------------------------------------------------------------------------------
 
/* 16.Create two tables called Student_details and Student_details_backup.

Table 1: Attributes 		Table 2: Attributes
Student id, Student name, mail id, mobile no.	Student id, student name, mail id, mobile no.

Feel free to add more columns the above one is just an example schema.
Assume you are working in an Ed-tech company namely Great Learning where you will be inserting and modifying the details of the 
students in the Student details table. Every time the students changed their details like mobile number, You need to update their
details in the student details table.  Here is one thing you should ensure whenever the new students' details come , you should 
also store them in the Student backup table so that if you modify the details in the student details table, you will be having the
old details safely.
You need not insert the records separately into both tables rather Create a trigger in such a way that It should insert the 
details into the Student back table when you inserted the student details into the student table automatically. */

CREATE TABLE Student_details
( student_id INT PRIMARY KEY,
  student_name VARCHAR(20) NOT NULL,
  mail_id VARCHAR(20) NOT NULL,
  mobile_no VARCHAR(10) NOT NULL );
  
CREATE TABLE Student_details_backup
( student_id INT PRIMARY KEY,
  student_name VARCHAR(20) NOT NULL,
  mail_id VARCHAR(20) NOT NULL,
  mobile_no VARCHAR(10) NOT NULL );
drop trigger Backup_student_details;
DELIMITER //
CREATE TRIGGER Backup_student_details
AFTER INSERT ON Student_details
FOR EACH ROW
BEGIN 
Insert into Student_details_backup
values (New.student_id,New.student_name,New.mail_id,New.mobile_no);
  END //
DELIMITER ;    

insert into  Student_details values(1,'ram','ram@1','55555');
insert into  Student_details values(2,'sam','sam@1','66666');
insert into  Student_details values(3,'vinay','vinay@3','76666');
insert into  Student_details values(4,'smith','smith@4','86666');
select * from Student_details;
select * from Student_details_backup;

insert into  Student_details_backup values(1,'ram','ram@1','55555');
insert into  Student_details_backup values(2,'sam','sam@1','66666');

update student_details set mail_id='ram@2' where student_id =1;

# Above outcome shows that when student_details table is inserted with new value,Student_details_backup table also gets inserted with the same value.