select * from author;

-- 1. The poetry in this database is the work of children in grades 1 through 5.  
--     a. How many poets from each grade are represented in the data?  
--        1st: 623, 2nd: 1437, 3rd: 2344, 4th: 3288, 5th: 3464
--     b. How many of the poets in each grade are Male and how many are Female? Only return the poets identified as Male or Female.  
--        1st: M: 163, F: 243; 2nd: M:412, F:605 ; 3rd: M:577, F:948 ; 4th: M:723, F:1241 ; 5th: M:757, F:1294 
--     c. Do you notice any trends across all grades?
--        There are more females than males across all grades. As the grade increases, so does total authors.

-- 1a
select grade_id as grade,
       count(grade_id) as total_students
from author
group by grade
order by grade;

-- 1b
select grade_id as grade,
       gender.name as gender,
       count(grade_id) as total_students
from author
     join gender 
          on gender.id = author.gender_id
     where gender.name = 'Male' 
          or gender.name = 'Female'
group by grade,
         gender.name
order by grade,
         gender.name;

-- 2. Two foods that are favorites of children are pizza and hamburgers. Which of these things do children write about more often?
--    Which do they have the most to say about when they do? Return the **total** number of poems, their **average character count** for poems that mention **pizza** and 
--    poems that mention the word **hamburger**. Do this in a single query.
--    Answer: 251 total poems containing either. 225 containing pizza (241.63 avg character count). 28 containing hamburger (259.71 avg character count)

-- select count(title) as b_ttl_poem, 
--        round(avg(char_count), 2) as b_avg_length
-- from poem
--     where text ilike '%hamburger%';
     
-- select count(title) as p_ttl_poem, 
--        round(avg(char_count), 2) as p_avg_length
-- from poem
--     where text ilike '%pizza%';
       
select count(*) as total_poems,
       sum(case when text ilike '%pizza%' then 1 else 0 end) as pizza_count,
       (select round(avg(char_count), 2) from poem where text ilike '%pizza%') as avg_char_pizza,
       sum(case when text ilike '%hamburger%' then 1 else 0 end) as burger_count,
       (select round(avg(char_count), 2) from poem where text ilike '%hamburger%') as avg_char_burger
from poem
     where text ilike '%pizza%'
        or text ilike '%hamburger%';

-- 3. Do longer poems have more emotional intensity compared to shorter poems?  
--     a. Start by writing a query to return each emotion in the database with its average intensity and character count.   
--         - Which emotion is associated the longest poems on average?  
--            - Anger: 261.16 avg characters
--         - Which emotion has the shortest? 
--            - Joy: 220.99 avg characters
--     b. Convert the query you wrote in part a into a CTE. Then find the 5 most intense poems that express anger and whether they are to be longer or shorter than the average angry poem.   
--         - What is the most angry poem about? 
--            - Summer
--         - Do you think these are all classified correctly?
--            - Not really. One is about how summer is perfect, another is about Sonic the Hedgehog. They don't seem very angry to me.
with avg_emotion_stats as (          
                           select name,
                                  round(avg(char_count), 2) as avg_length,
                                  round(avg(intensity_percent), 2) as avg_intensity
                           from poem as p
                                join poem_emotion as p_e
                                     on p.id = p_e.poem_id
                                join emotion as e
                                     on p_e.emotion_id = e.id
                           group by e.name
                          )
select p.id,
       p.text,
       e.name,
       char_count,
       intensity_percent, 
       avg_length,
       avg_intensity
from poem as p
     join poem_emotion as p_e
          on p.id = p_e.poem_id
     join emotion as e
          on p_e.emotion_id = e.id
     join avg_emotion_stats as a_e_s
          on e.name = a_e_s.name
where e.name = 'Anger'
group by p.id,
         p.text,
         e.name,
         char_count,
         intensity_percent,
         avg_length,
         avg_intensity
order by intensity_percent desc
limit 5;

-- 4. Compare the 5 most joyful poems by 1st graders to the 5 most joyful poems by 5th graders.  
-- 	   a. Which group writes the most joyful poems according to the intensity score?  
--         - 5th graders top 5 scores at 92-99 percent. That is higher than 1st graders.
--     b. Who shows up more in the top five for grades 1 and 5, males or females?  
--         - Males for both
--     c. Which of these do you like the best?
--         - Poem 29159 is my favorite of the bunch due to it being about baseball. Every baseball player has made up scenarios like that before.
with joy_stats as (
                   select p.id,
                          p.text,
                          e.name,
                          intensity_percent
                   from poem as p
                        join poem_emotion as p_e
                             on p.id = p_e.poem_id
                        join emotion as e
                             on p_e.emotion_id = e.id
                   where e.name = 'Joy'
                   group by p.id,
                            p.text,
                            e.name,
                            intensity_percent
                   order by intensity_percent desc
                  )
select joy_stats.id,
       joy_stats.name,
       joy_stats.intensity_percent,
       grade_id,
       gender.name,
       joy_stats.text
from joy_stats
     join poem
          using(id)
     join author
          on poem.author_id = author.id
     join gender
          on author.gender_id = gender.id
where grade_id = '1'
-- where grade_id = '5'
order by intensity_percent desc
limit 5;

-- 5. Robert Frost was a famous American poet... 
-- 	   a. Examine the poets in the database with the name `robert`.
--        Create a report showing the count of Roberts by grade along with the distribution of emotions that characterize their work.  
--	   b. Export this report to Excel and create a visualization that shows what you have found.
select count(author.name),
       grade.name,
       emotion.name
from author
     join poem 
          on author.id = poem.author_id
     join poem_emotion
          on poem.id = poem_emotion.poem_id
     join emotion
          on poem_emotion.emotion_id = emotion.id
     join grade
          on author.grade_id = grade.id
where author.name = 'robert'
group by grade.name,
         emotion.name;


