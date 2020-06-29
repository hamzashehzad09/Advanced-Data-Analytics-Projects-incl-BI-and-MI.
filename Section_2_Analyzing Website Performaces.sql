-- ----------------------- Section 5: Analyzing Website Performance ---------------------------------

select * from website_pageviews
where website_pageview_id <  1000;


select 
	pageview_url,
    count(distinct website_pageview_id) as pvs
from website_pageviews
where website_pageview_id <1000
group by pageview_url
order by pvs DESC;

-- Creating temporary table
    

select * from website_pageviews
where website_pageview_id <  1000;

-- which pageview is initally seen by the possible customer (firt thing the customer saw)

select 
	website_session_id,
    min(website_pageview_id) as min_pv_id # selects the website_pageview having minimum value for the same website_session_id
from website_pageviews
where website_pageview_id < 1000
group by website_session_id;


Create temporary table first_pageview
select 
	website_session_id,
    min(website_pageview_id) as min_pv_id # selects the website_pageview having minimum value for the same website_session_id
from website_pageviews
where website_pageview_id < 1000
group by website_session_id;

select * from first_pageview;

select * from website_pageviews
where website_pageview_id < 1000;





-- ------      analyzing  top website pages and entry pages



select * 
	from first_pageview
	left join website_pageviews
		on first_pageview.min_pv_id = website_pageviews.website_pageview_id;


-- in first pagewview we have stored for every webiste session the pageview id that shows up, and we are using it
-- to join back to the website pageview table to get the url

select 
	first_pageview.website_session_id,
    website_pageviews.pageview_url as landing_page -- aka "entry page"
	from first_pageview
	left join website_pageviews
		on first_pageview.min_pv_id = website_pageviews.website_pageview_id;
-- the code only shows the first page accessed since minimum is used

select 
    website_pageviews.pageview_url as landing_page, -- aka "entry page"
    count(distinct first_pageview.website_session_id) as sessions_hitting_this_lander
	from first_pageview
	left join website_pageviews
		on first_pageview.min_pv_id = website_pageviews.website_pageview_id
        group by 1;
-- the code only shows the first page accessed since minimum is used



-- --------------------------------------------------------------------------------------
-- ASSIGNMENT FINDING TOP WEBSITE PAGES
select * from website_pageviews;
select * FROM website_sessions;

select 
	pageview_url,
    count(distinct website_session_id) as sessions
    from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;

select 
	pageview_url,
    count(distinct website_pageview_id) as sessions
    from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;
-- home, product and fuzzy has the higest traffic









-- ------------------ ASSIGNMENT TOP ENTRY PAGES -----------------------------

-- create temporary table entry_level_pages

select * from website_pageviews;

-- STEP1: FIND THE FIRST PAGEVIEW FOR EACH SESSION
-- STEP2: FIND THE URL CUSTOMER SAW ON THAT FIRST PAGE VIEW



select 
	website_session_id,
    min(website_pageview_id) as first_page_viee_or_min_page_view
from website_pageviews
where created_at <  '2012-06-12'
group by website_session_id;


create temporary table first_page_view_per_session
select 
	website_session_id,
    min(website_pageview_id) as first_page_view_or_min_page_view
from website_pageviews
where created_at <  '2012-06-12'
group by website_session_id;

-- select * from first_page_view_per_session
-- 	left join website_pageviews
-- 		on first_page_view_per_session.first_page_view_or_min_page_view = website_pageviews.website_pageview_id;

select 
	website_pageviews.pageview_url as landing_papge_url,
    count(distinct first_page_view_per_session.website_session_id) as sessions
from first_page_view_per_session
	left join website_pageviews
		on first_page_view_per_session.first_page_view_or_min_page_view = website_pageviews.website_pageview_id
        Group by 1;
        
        
        
        
        
        
        
#----------------------------------------------------------------------
        
-- LANDING PAGE PERFORMANCE AND TESTING

-- Analyzing Bounce Rates & Landing Page tests
-- BUSINESS CONTEXT: we want to see landing page performace for a certain time period

-- STEP1: find the website_pageview_id for relevant sessions
-- STEP2: identify the landing page of each session
-- STEP3: counting pageviews for each session to identify "bounces"
-- STEP4: summarizin total sessions and bounced sessions, by LP

-- finding the minimum website pageview id associated with each session we care about

select * from website_pageviews;

select * from website_sessions;

select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	inner join website_sessions
    on website_sessions.website_session_id = website_pageviews.website_session_id
    and website_sessions.created_at Between '2014-01-01' and '2014-02-01'
group by
	website_pageviews.website_session_id;
    
    -- or could have used this instead of joining to the website_sessions table
    
    select 
	website_session_id,
    min(website_pageview_id) as min_pageview_id
from website_pageviews
    where created_at Between '2014-01-01' and '2014-02-01'
group by
website_session_id;



create temporary table first_pageviews_demo
select 
	website_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	inner join website_sessions
    on website_sessions.website_session_id = website_pageviews.website_session_id
    and website_sessions.created_at Between '2014-01-01' and '2014-02-01'
group by
	website_pageviews.website_session_id;
    

select * from first_pageviews_demo;

-- next we will bring in the landing page to each session

create temporary table sessions_w_landing_page_demo

select 
	first_pageviews_demo.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_pageviews_demo
	left join website_pageviews
		on website_pageviews.website_pageview_id = first_pageviews_demo.min_pageview_id;
        -- joining back on the website_pageview on rows with minimum pageview_id

select * from sessions_w_landing_page_demo;

-- select 
-- 	sessions_w_landing_page_demo.website_session_id,
--     sessions_w_landing_page_demo.landing_page,
--     count(website_pageviews.website_pageview_id) as count_of_pages_viewed
--     
-- from sessions_w_landing_page_demo
-- left join website_pageviews
-- 	on website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
--     
-- Group by 
-- 		sessions_w_landing_page_demo.website_session_id,
-- 		sessions_w_landing_page_demo.landing_page;
-- -- adding a having clause to get the bounce ones

select * from sessions_w_landing_page_demo;

select 
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    count(website_pageviews.website_pageview_id) as count_of_pages_viewed
    
from sessions_w_landing_page_demo
left join website_pageviews
	on website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
    
Group by 
		sessions_w_landing_page_demo.website_session_id,
		sessions_w_landing_page_demo.landing_page

having count_of_pages_viewed = 1;


select * from website_pageviews;


create table bounced_sessions_only
select 
	sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    count(website_pageviews.website_pageview_id) as count_of_pages_viewed
    
from sessions_w_landing_page_demo
left join website_pageviews
	on website_pageviews.website_session_id = sessions_w_landing_page_demo.website_session_id
    
Group by 
		sessions_w_landing_page_demo.website_session_id,
		sessions_w_landing_page_demo.landing_page

having count_of_pages_viewed = 1;


select 
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id as bounced_website_session_id
from sessions_w_landing_page_demo
	left join bounced_sessions_only
		on sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id

Order by 2;


select 
	sessions_w_landing_page_demo.landing_page,
    sessions_w_landing_page_demo.website_session_id,
    bounced_sessions_only.website_session_id as bounced_website_session_id
from sessions_w_landing_page_demo
	left join bounced_sessions_only
		on sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id

Order by 2;


-- final query 


select 
	sessions_w_landing_page_demo.landing_page,
    count(distinct sessions_w_landing_page_demo.website_session_id) as sessions,
    count(distinct bounced_sessions_only.website_session_id) as bounced_sessions
from sessions_w_landing_page_demo
	left join bounced_sessions_only
		on sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
group by 1
;


select 
	sessions_w_landing_page_demo.landing_page,
    count(distinct sessions_w_landing_page_demo.website_session_id) as sessions,
    count(distinct bounced_sessions_only.website_session_id) as bounced_sessions,
    count(distinct bounced_sessions_only.website_session_id)/ count(distinct sessions_w_landing_page_demo.website_session_id) as bounced_rate
from sessions_w_landing_page_demo
	left join bounced_sessions_only
		on sessions_w_landing_page_demo.website_session_id = bounced_sessions_only.website_session_id
group by 1
;



#---------------------------------------------------------------------







#Assignment: Calculating Bounced rates 

select * from website_pageviews;

create temporary table min_page_view
select 
	website_session_id,
    min(website_pageview_id) as min_pageview
from website_pageviews
where created_at < '2012-06-14'
group by 1;

select * from website_pageviews;
select * from min_page_view;

create temporary table sessions_with_home_landing_page
select
min_page_view.website_session_id,
website_pageviews.pageview_url as landing_page
    from min_page_view left join website_pageviews
    on website_pageviews.website_pageview_id = min_page_view.min_pageview
where websit_pageviews.pageview_url = '/home'; -- this is how we will find sessions for specifc website
-- getting landing urls for only home page
select * from sessions_with_home_landing_page;

-- now we need table with count of pageviews visited
-- then we will limit it to just bounced_sessions

create temporary table bounced_sessions_
select 
	sessions_with_home_landing_page.website_session_id,
    sessions_with_home_landing_page.landing_page,
    count(website_pageviews.website_pageview_id) as count_pageviews
    from sessions_with_home_landing_page
left join website_pageviews
	on website_pageviews.website_session_id = sessions_with_home_landing_page.website_session_id
    group by 1,2
having count_pageviews = 1;

select * from bounced_sessions_;

select 
	sessions_with_home_landing_page.website_session_id,
    bounced_sessions_.website_session_id as bounced_website_session_id
    
from sessions_with_home_landing_page -- gives us all the sessions with '/home'
left join bounced_sessions_ -- will return null if session id is missing (i.e the ones which didn't bounced off)
on sessions_with_home_landing_page.website_session_id = bounced_sessions_.website_session_id;



select
	count(sessions_with_home_landing_page.website_session_id) as total_sessions,
    count(bounced_sessions_.count_pageviews) as bounced_sessions,
    count(bounced_sessions_.count_pageviews)/count(sessions_with_home_landing_page.website_session_id) as bounced_rate
from sessions_with_home_landing_page
    left join bounced_sessions_
on sessions_with_home_landing_page.website_session_id = bounced_sessions_.website_session_id
    ;
    -- joining back on sessions_with_home_landing_page to get the total sessions as the bounced_session_ only
    -- contains sessions which bounded
    
-- based on the results the bounce rate is too high


















-- ------------ Assignment: Analyizing landing Page tests ----------------------------



select * from website_pageviews;

-- to start the comparison between home and lander 1 
-- we need created_at for lander_1 to begin with in the first place
-- once we have that we can use that date as a starting point to see the trend of
-- bounce rates for home and lander 1



select 
	website_session_id,
    created_at as first_created_at,
    min(website_pageview_id) as first_pageview
    from website_pageviews
where pageview_url ='/lander-1'
group by 1
limit 1;

select 
    min(created_at) as first_created_at,
    min(website_pageview_id) as first_pageview
    from website_pageviews
where pageview_url ='/lander-1' and created_at is not null;

-- based on two different codes
-- 2012-06-19 is the first date when lander-1 is accessed
-- 23504 is the min first_pageview for lander


create temporary table first_test_pageviews
select
	website_pageviews.website_session_id,
    -- pageview_url,
    min(website_pageviews.website_pageview_id) as min_pageview_id
from website_pageviews
	inner join website_sessions -- we had to specifically do the inner join on website_session since morgan wanted specific data on gsearch and non-brand
on 
	website_sessions.website_session_id = website_pageviews.website_session_id
    and website_sessions.created_at <'2012-07-28' -- given in the task
    and website_pageviews.website_pageview_id > 23504 -- ensures that the first ever /lander-1 created
    and utm_source = 'gsearch'
    and utm_campaign ='nonbrand'
group by 1;


select * from first_test_pageviews;


create temporary table landing_page_home_lander1
select 
	first_test_pageviews.website_session_id,
    website_pageviews.pageview_url as landing_page
from first_test_pageviews
	left join website_pageviews
on website_pageviews.website_pageview_id = first_test_pageviews.min_pageview_id -- joining on min_id to only get the url's for the first accessed page by customer
where website_pageviews.pageview_url in ('/home','/lander-1'); -- getting all the minimum/first pageviews with only url home and lander 1

select * from landing_page_home_lander1;	

create temporary table bounced_sessions_gsearch_non_brand
select
	landing_page_home_lander1.website_session_id,
    landing_page_home_lander1.landing_page,
    count(website_pageviews.website_pageview_id) as sessions
from landing_page_home_lander1
	left join website_pageviews
		on website_pageviews.website_session_id = landing_page_home_lander1.website_session_id
group by 1,2
having sessions = 1 ; -- used pageviews as left join will select all sessions from pageviews and will join

select * from bounced_sessions_gsearch_non_brand;


select
	landing_page_home_lander1.website_session_id as total_sessions_lander1_home,
    landing_page_home_lander1.landing_page,
    bounced_sessions_gsearch_non_brand.website_session_id as bounced_sessions
		from landing_page_home_lander1 -- selecting all the session ids with home and lander
left join bounced_sessions_gsearch_non_brand -- will give null to id's which are not bounced off or are not in the table 'bounced_sessions_gsearch_non_brand'
     on landing_page_home_lander1.website_session_id = bounced_sessions_gsearch_non_brand.website_session_id;
     
     
select
	landing_page_home_lander1.landing_page,
	count(landing_page_home_lander1.website_session_id) as total_sessions,
    count(bounced_sessions_gsearch_non_brand.website_session_id) as bounced_sessions,
    count(bounced_sessions_gsearch_non_brand.website_session_id)/count(landing_page_home_lander1.website_session_id) bounce_rate
	from landing_page_home_lander1 -- selecting all the session ids with home and lander
left join bounced_sessions_gsearch_non_brand -- will give null to id's which are not bounced off or are not in the table 'bounced_sessions_gsearch_non_brand'
     on landing_page_home_lander1.website_session_id = bounced_sessions_gsearch_non_brand.website_session_id
group by 1;

-- lander1 is better for page search traffic as it is causing fewer customer to bounce off





-- -- -- -- -- -- -- -- -- -- Assignment: landing Page trend analysis


-- we are staring with website_sessions as we have to restirct the results to gsearch and nonbrand
-- here we are combining two steps

-- sessions_w_min_pv_id_and_view_count

select * from website_sessions;

select 
	*
    -- website_sessions.website_session_id,
    -- min(website_pageviews.website_pageview_id) as first_pageview_id,
    -- count(website_pageviews.website_pageview_id) as count_pageviews
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
-- here 6,6,6,6 [sessions] will be joined with same

where website_sessions.created_at > '2012-06-01' -- asked by requestor
	  and website_sessions.created_at < '2012-08-31' -- date when tas was given
	  and utm_campaign ='nonbrand'
      and utm_source = 'gsearch'
      ;
      
	-- the code above shows the complete table after join, once we have that we are selecting the website_sessions
    -- and then the minium_pageview and count
    -- since the group by is done on website session, the program written below. will select the website session [9350] which is currently shown
    -- 3 times as it has 3 sessions,the 9350 with the lowest or the first page_view_id will be selected. the program will also count all the entries
    -- with the same_pageview_id since the final table has more than 1 entry for some website_pageview_id
select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    min(website_pageviews.website_pageview_id) as first_pageview_id,
    count(website_pageviews.website_pageview_id) as count_pageviews
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-06-01' -- asked by requestor
	  and website_sessions.created_at < '2012-08-31' -- date when tas was given
	  and utm_campaign ='nonbrand'
      and utm_source = 'gsearch'
	
group by  1;
      
      
create temporary table sessions_w_min_id_and_view_count
select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    min(website_pageviews.website_pageview_id) as first_pageview_id,
    count(website_pageviews.website_pageview_id) as count_pageviews
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-06-01' -- asked by requestor
	  and website_sessions.created_at < '2012-08-31' -- date when tas was given
	  and utm_campaign ='nonbrand'
      and utm_source = 'gsearch'
group by  1;

      


select * from sessions_w_min_id_and_view_count;


create temporary table sessions_w_counts_lander_and_created_at
select
	sessions_w_min_id_and_view_count.website_session_id,
    sessions_w_min_id_and_view_count.first_pageview_id,
    sessions_w_min_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url as landing_page,
    website_pageviews.created_at as session_created_at
from sessions_w_min_id_and_view_count
	left join website_pageviews
on sessions_w_min_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;



select * from sessions_w_counts_lander_and_created_at;


select 
	YEARWEEK(session_created_at) as year_weak,
    min(date(session_created_at)) as week_start_date,
    count(distinct website_session_id) as total_sessions,
    count(distinct case when count_pageviews = 1 then website_session_id else null end) as bounced_sessions,
    count(distinct case when count_pageviews = 1 then website_session_id else null end) * 1.0/ count(distinct website_session_id) as bounce_rate, #??????
    count(distinct case when landing_page =  '/home' then website_session_id else null end) as home_sessions,
    count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_sessions
from sessions_w_counts_lander_and_created_at
group by YEARWEEK(session_created_at);

select 
	YEARWEEK(session_created_at) as year_weak,
    session_created_at
--     min(date(session_created_at)) as week_start_date,
--     count(distinct website_session_id) as total_sessions,
--     count(distinct case when count_pageviews = 1 then website_session_id else null end) as bounced_sessions,
--     count(distinct case when count_pageviews = 1 then website_session_id else null end) * 1.0/ count(distinct website_session_id) as bounce_rate, #??????
--     count(distinct case when landing_page =  '/home' then website_session_id else null end) as home_sessions,
--     count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_sessions
from sessions_w_counts_lander_and_created_at;
-- group by YEARWEEK(session_created_at);
    
    

select 
	-- YEARWEEK(session_created_at) as year_weak,
    min(date(session_created_at)) as week_start_date,
    -- count(distinct website_session_id) as total_sessions,
    -- count(distinct case when count_pageviews = 1 then website_session_id else null end) as bounced_sessions,
    count(distinct case when count_pageviews = 1 then website_session_id else null end) * 1.0/ count(distinct website_session_id) as bounce_rate, #??????
    count(distinct case when landing_page =  '/home' then website_session_id else null end) as home_sessions,
    count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_sessions
from sessions_w_counts_lander_and_created_at
group by YEARWEEK(session_created_at);
    
    



#--------------------------------------------------------------------------------------------------------------








-- Building Conversion Funnel model

-- users move to home--->product---> cart-----> sale
-- finding abandoning points
-- optimizing specific page or step in between to get more sales

-- how many customers are dropping off vs customers moving forward


select * from website_pageviews where website_session_id = 1059;
-- shows an example of customer who complete the entire conversion funnel steps



-- EXAMPLE

-- we want to buld a mini conversion funnel from lander-2 to cart
-- need to find customers who moved forward and the ones who dropped off

 
 -- Step 1: select all pageviews for all relevant sessions
 -- Step 2: identify each relevant pageview as specific funnel step
 -- Step 3: create the session-level conversion funnel view
 -- Step 4: aggregate the data to assess funnel performance
 
 
 select * from website_pageviews;
 select * from website_sessions;
 
 
  select *
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at;
 
 select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at
    -- Case when pageview_url = '/products' then 1 else 0 ends as product_page,
    -- Case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 ends as mrfuzzy_page,
	-- Case when pageview_url = '/cart' then 1 else 0 ends as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at;
    
    

 select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at;
 
 -- 0 0 0 IN lander-2 means that ??????????????????????????
 
 
 
 select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at) 
    
    AS pageview_level

group by website_session_id;
    

 
 create temporary table session_level_made_it_flags_demo
 
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at)  AS pageview_level

group by website_session_id;

select * from session_level_made_it_flags_demo;


-- final output part 1


select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
	count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_made_it
    
from session_level_made_it_flags_demo;


-- final output part 2 click rates
 
 select 
	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end)
    / count(distinct website_session_id) as clicked_to_product, -- since we are clicking from lander-2 to product page so it can renamed to lander_clickthroughrate 
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) 
    / count(distinct website_session_id) as clicked_to_mrfuzzy, -- since we are clicking from product to fuzzy it can be renamed as product_clickthroughtrate
	count(distinct case when cart_made_it = 1 then website_session_id else null end)
    / count(distinct website_session_id)  as clicked_to_cart -- since we are clicking from fuzzy to cart we can call it fuzzy_clickthroughrate
    
from session_level_made_it_flags_demo;
 
 
 select
	website_session_id,
    case when cart_made_it <> 0 then (1+1+1)/3 else null end as all_steps_covered,
    case when product_made_it = 1 and mrfuzzy_made_it = 1 and cart_made_it = 0 then (1+1+0)/3 else null end as half_1,
    case when product_made_it = 0 and mrfuzzy_made_it = 1 and cart_made_it = 0 then (1+1+0)/3 else null end as half2,
    case when product_made_it = 1 and mrfuzzy_made_it = 0 and cart_made_it = 0 then (1+1+0)/3 else null end half_3
    
 
 
 from(
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at
    
    )  AS pageview_level 

group by website_session_id )as c

;
    
 
 
 select
	website_session_id,
    case when cart_made_it <> 0 then "all steps complete" else null end as all_steps_covered,
    case when product_made_it = 1 and mrfuzzy_made_it = 1 and cart_made_it = 0 then "partial complete" else null end as half_1,
    case when product_made_it = 0 and mrfuzzy_made_it = 1 and cart_made_it = 0 then "partial complete" else null end as half2,
    case when product_made_it = 1 and mrfuzzy_made_it = 0 and cart_made_it = 0 then "partial complete" else null end half_3
    
 
 
 from(
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at
    
    )  AS pageview_level 

group by website_session_id )as c;






 select
	website_session_id,
    case when cart_made_it <> 0 then (1+1+1)/3 else null end as all_steps_covered,
    case when product_made_it + mrfuzzy_made_it + cart_made_it  < 3 and cart_made_it <> 1 then (1+1+0)/3 else null end as half_way
    -- case when product_made_it = 0 and mrfuzzy_made_it = 1 and cart_made_it = 0 then (1+1+0)/3 else null end as half2,
 
 from(
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at
    
    )  AS pageview_level 

group by website_session_id )as c

;



select
	website_session_id,
    case when cart_made_it <> 0 then "all steps covered in funnel conversion" else null end as all_steps_covered,
    case when product_made_it + mrfuzzy_made_it + cart_made_it  < 3 and cart_made_it <> 1 then "partial steps complete in funnel process" else null end as half_way
    -- case when product_made_it = 0 and mrfuzzy_made_it = 1 and cart_made_it = 0 then (1+1+0)/3 else null end as half2,
 
 from(
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at
    
    )  AS pageview_level 

group by website_session_id )as c

;
 
 
 
 
 select 
 
 	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
	count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_made_it
    
    from (
  select 
	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it
    -- Max(shipping_page) as shipping_made_it,
    -- Max(billing_page) as billing_made_it,
-- Max(thankyou_page) as thankyou_made_it
-- selects the max means all the ones(1's). 1 shows that customer reached a specific page in our case(produt, fuzzy or cart)
-- 0 shows that the specific page was not accessed, max will select max value which is 1 and for a given website_session_id
-- for e.g 175252 max product_page will select 1, then max mfuzzy_page will select 1, then max_cart_page will select 0,  0 indicates that customer never reached cart_page
from (

select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at as pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page
from website_sessions
	left join website_pageviews
		on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at Between '2014-01-01' and '2014-02-01' -- random timeframe for demo purpose
	And website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by 
	website_sessions.website_session_id,
    website_pageviews.created_at)  AS pageview_level

group by website_session_id) as final;



select * from website_pageviews;
select * from website_sessions;



select distinct pageview_url from website_pageviews;

select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_sessions.created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 end AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
    
from website_sessions

left join website_pageviews on
	website_sessions.website_session_id =  website_pageviews.website_session_id 

where website_sessions.utm_source = 'gsearch' and
	  website_sessions.utm_campaign = 'nonbrand' and
	  website_sessions.created_at > '2012-08-05' and website_sessions.created_at < '2012-09-05'
order by 
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id;

-- not all id's taken ????????????????????
-- how are you ensuring that the forever love bear , lander 1, 2,3,4,5, the hudsdon river mini bear, the birthday sugar panda etc
-- are skipped ????????????

-- why the subquery doesn't run with website_sessions.website_session_id

select 

	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it,
    Max(shipping_page) as shipping_made_it,
    Max(billing_page) as billing_made_it,
    Max(thankyou_page) as thankyou_made_it
    
    from (



select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_sessions.created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 end AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
    
from website_sessions

left join website_pageviews on
	website_sessions.website_session_id =  website_pageviews.website_session_id 

where website_sessions.utm_source = 'gsearch' and
	  website_sessions.utm_campaign = 'nonbrand' and
	  website_sessions.created_at > '2012-08-05' and website_sessions.created_at < '2012-09-05'
order by 
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id ) as f
    
group by website_session_id;




 
 
 -- final version rate
 
 select 
 to_product/sessions as lander_click_through_rate,
 to_mrfuzzy/sessions as product_click_through_rate,
 to_cart/sessions as mrfuzzy_click_through_rate,
 to_shipping/sessions as cart_click_through_rate,
 to_billing/sessions as shipping_click_through_rate,
 to_thankyou/sessions as billing_click_through_rate
 
 from (
 
 select 
 	count(distinct website_session_id) as sessions,
    count(distinct case when product_made_it = 1 then website_session_id else null end) as to_product,
    count(distinct case when mrfuzzy_made_it = 1 then website_session_id else null end) as to_mrfuzzy,
	count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
    
    
    from 
    
    (
    select 

	website_session_id,
    Max(product_page) as product_made_it,
    Max(mrfuzzy_page) as mrfuzzy_made_it,
    Max(cart_page) as cart_made_it,
    Max(shipping_page) as shipping_made_it,
    Max(billing_page) as billing_made_it,
    Max(thankyou_page) as thankyou_made_it
    
    from (



select 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    -- website_sessions.created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 end AS product_page,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
	CASE WHEN pageview_url = '/cart' then 1 else 0 end as cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 end AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
	CASE WHEN pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
    
from website_sessions

left join website_pageviews on
	website_sessions.website_session_id =  website_pageviews.website_session_id 

where website_sessions.utm_source = 'gsearch' and
	  website_sessions.utm_campaign = 'nonbrand' and
	  website_sessions.created_at > '2012-08-05' and website_sessions.created_at < '2012-09-05'
order by 
	website_sessions.website_session_id,
    website_pageviews.website_pageview_id ) as f
    
group by website_session_id) as final_1) as final_rate;




select 
		website_pageviews.website_session_id,
        website_pageviews.pageview_url
        from website_pageviews
        where website_pageviews.created_at > '2012-08-05' and website_pageviews.created_at < '2012-09-05';




#-------------------------------------------------------------------------------------------------------------------

-- Assignement funel conversion -- finind which billing page was preffered by the customer
-- finding the minimum id for billing page 2 launch, from this id onwards we will perform the comparison
-- then once all the steps before billing are covered or when it is the turn of billing
-- we will identfiy for which order, which billing_page version / page was used using order id

select * from website_pageviews;

select min(website_pageviews.website_pageview_id)
       from website_pageviews
       where pageview_url = '/billing-2'
      ;
       
       
       -- to check all the session-id's with 
select website_pageviews.website_pageview_id,
	   min(date(created_at)) as min_date_for_billing_2
       from website_pageviews
       where pageview_url = '/billing-2'
       group by 1;
-- this gives us the id for billin-2

-- selecting required website_session_id


select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen
    -- orders.order_id

from website_pageviews
	-- left join orders
   --  on orders.website_session_id = website_pageviews.website_pageview_id
where website_pageviews.website_pageview_id >= 5350
and website_pageviews.created_at < '2012-11-10' -- will join on order ids with billing-1 and billing-2 only
and website_pageviews.pageview_url in ('/billing','/billing-2'); -- hence we can count easily;



select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
	orders.order_id

from website_pageviews
	left join orders
    on orders.website_session_id = website_pageviews.website_pageview_id
where website_pageviews.website_pageview_id >= 5350
and website_pageviews.created_at < '2012-11-10' -- will join on order ids with billing-1 and billing-2 only
and website_pageviews.pageview_url in ('/billing','/billing-2') -- hence we can count easily
       ;
-- for some of the billings no order was placed



select 
	billing_version_seen,
    count(distinct website_session_id) as sessions,
    count(distinct order_id) as orders,
	count(distinct order_id)/count(distinct website_session_id) as billing_to_order_rt
    from (
select 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url as billing_version_seen,
	orders.order_id
from website_pageviews
	left join orders
    on orders.website_session_id = website_pageviews.website_pageview_id
where website_pageviews.website_pageview_id >= 5350
and website_pageviews.created_at < '2012-11-10' -- will join on order ids with billing-1 and billing-2 only
and website_pageviews.pageview_url in ('/billing','/billing-2') -- hence we can count easily
      ) as billing_sessions_with_orders

group by billing_version_seen;
