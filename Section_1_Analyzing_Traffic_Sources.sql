select * from website_sessions where website_session_id = 1059;

-- user_id is tracked using cookies on the webiste, we can keep track of one user for every visit.
-- is_repeat_session has binary 0 and 1 which shows us wehter the user has visited the website before or not
-- utm_source, utm_content, utm_ campanign are tracking papemeters that we use to measure our paid markeing activity
-- utm is used by google analytics 
-- device_type - device used by user or visitor
-- http_referrer helps us understand where the traffic is coming from, this is especiially helpful for traffic that is coming to 
-- us which we don't have tagged with paid tracking parameter because its not through a marekting camapign-- basically where traffic is coming from

select * from website_pageviews where website_session_id = 1059;
-- contains the website_session_id as a forign key from table website_session
-- Table shows that in each website_session_id several pages were visisted (column: website_pageview_id)
-- page_view_url shows which pages were clicked or visited on that speicifc website


select * from orders where website_session_id = 1059;
-- contains website session_id
-- used for , for example  gsearch nonbranded campaign allows us to uderstand wether such campaigns 
-- are contributing to larger numer of orders or not
-- primary product = first product put into basket when using e-platform


Select distinct utm_source, utm_campaign from website_sessions;
-- null utm means that traffic that is not driven by a paid camapahing or the marketer forgot to put the utm tracking paraemeters







#1 Trafic source analysis -----------------------------------------

select * from website_sessions where website_session_id between 1000 and 2000;


select utm_content, 
count(distinct website_session_id) as sessions from
 website_sessions where website_session_id between 1000 and 2000
 Group by utm_content
 Order by sessions DESC;
 
 # OR 
 
 
 -- website sessions that bring more volume
 select utm_content, 
count(distinct website_session_id) as sessions from
 website_sessions where website_session_id between 1000 and 2000
 Group by 1
 Order by 2 DESC;
 
 -- Now bringing orders as well 
 
 Select * from website_sessions;
 select * from orders;
 
SELECT 
	website_sessions.utm_content, 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions ,
    COUNT(DISTINCT orders.order_id) as orders
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
        
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;
-- the results above confirms that all the of our orders are driven by g_ad_1 during the session period 1000-2000
 
 
 -- conversion rate analysis
 -- sucessfull outcomes/attempts to convert
 -- % of session that converted to your sales/revenue
 SELECT 
	website_sessions.utm_content, 
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions ,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT orders.order_id) /COUNT(DISTINCT website_sessions.website_session_id) AS session_to_order_conversion_rate
FROM website_sessions 
	LEFT JOIN orders 
		ON website_sessions.website_session_id = orders.website_session_id
        
WHERE website_sessions.website_session_id BETWEEN 1000 AND 2000
GROUP BY 1
ORDER BY 2 DESC;




-- ----------------------------------------------------------------------------------

# Assisgnment FINDING TOP TRAFFI SOURCES

select * from website_sessions;
select * from website_pageviews;
select * from orders;
 
 SELECT 
 utm_source, 
 utm_campaign, 
 http_referer,
 COUNT(DISTINCT website_session_id) as number_of_sessions
	FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1, 2, 3 
ORDER BY 4 DESC;
-- The results above shows that gsearch with nonbrand camapgin has the highest number of session
    

# Gsearch Conversion rate
-- cvr >= 4% then we can increase the price otherwise not

select * from orders;
 SELECT 
 website_sessions.utm_source, 
 website_sessions.utm_campaign, 
 website_sessions.http_referer,
 COUNT(DISTINCT website_sessions.website_session_id) as number_of_sessions,
 COUNT(DISTINCT orders.order_id) as orders,
 COUNT(DISTINCT orders.order_id)/
						COUNT(DISTINCT website_sessions.website_session_id)*100 AS CVR_CONVERSION_RATE_SESSION_TO_ORDER
	FROM website_sessions
LEFT JOIN Orders 
	ON website_sessions.website_session_id = orders.website_session_id
    
WHERE website_sessions.created_at < '2012-04-14'
	  AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand';

# with alias
 SELECT 
 utm_source, 
 utm_campaign, 
 http_referer,
 COUNT(DISTINCT w.website_session_id) as number_of_sessions,
 COUNT(DISTINCT order_id) as orders,
 COUNT(DISTINCT order_id)/
						COUNT(DISTINCT w.website_session_id)*100 AS CVR_CONVERSION_RATE_SESSION_TO_ORDER
	FROM website_sessions as w
LEFT JOIN Orders  as o
	ON w.website_session_id = o.website_session_id
    WHERE w.created_at < '2012-04-14'
	  AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand';

    
-- shorter version
SELECT 
 COUNT(DISTINCT website_sessions.website_session_id) as number_of_sessions,
 COUNT(DISTINCT orders.order_id) as orders,
 COUNT(DISTINCT orders.order_id)/
						COUNT(DISTINCT website_sessions.website_session_id) AS CVR_CONVERSION_RATE_SESSION_TO_ORDER
	FROM website_sessions
LEFT JOIN orders 
	ON orders.website_session_id = website_sessions.website_session_id 
WHERE website_sessions.created_at < '2012-04-14'
	  AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand';
      
-- from the results above the CVR rate is less than 4% which shows that we can reduce the amount spent on these marketing 
-- campagins / overbiding on these compagins
-- this analysis saved the comapany some money since they will now spend less on marketing campaign

-- Next steps - impact of bid reductions

-- Bid Optimization and Trend Analysis

-- BID optimization
-- Date function Month, Year, Quarter
-- Month(dateOrDatetime)

Select 
website_session_id,
created_at,
MONTH(created_at) as month,
Year(created_at) as year,
WEEK(created_at) as week
From website_sessions
where website_session_id between 100000 and 115000;




-- Trend analysis of sessions by week-----------------------------------------------------

Select 
Year(created_at) as year,
WEEK(created_at) as week,
Count(distinct website_session_id) as sessions
From website_sessions
where website_session_id between 100000 and 115000
Group by 1,2;



-- min will give the minimum date for that year and week
Select 
created_at,
Year(created_at) as year,
WEEK(created_at) as week,
Min(DATE(created_at)) AS Week_start,
Count(distinct website_session_id) as sessions
From website_sessions
where website_session_id between 100000 and 115000
Group by 1,2, 3;

-- we can compare results of code above and below and can see that week_sart
-- selects the date for the year and week and choose the minimum date for the given year and week for example
-- date: 2013-06-06, 2013-06-07, 2013-06-08[all of them had same week and year i.e 22 and 2013] but were not choosen 
-- since the date 2013-06-05 was the minimum date with week 22 and year 2013
Select 
Year(created_at) as year,
WEEK(created_at) as week,
Min(DATE(created_at)) AS Week_start,
Count(distinct website_session_id) as sessions
From website_sessions
where website_session_id between 100000 and 115000
Group by 1,2;









-- PIVOT Concept
-- -- --- --- "PIVOTING" DATA with COUNT and CASE

select * from orders; 

Select 
order_id,
primary_product_id,
items_purchased,
created_at
from orders
where order_id between 31000 and 32000;
-- we need count of orders by primary product id 

-- items_purchased has 2 values i.e "1" and "2"
-- same for the primary_product_id
Select 
-- order_id,
primary_product_id,
-- items_purchased,
-- created_at,
Count(order_id) as count_total_orders
from orders
where order_id between 31000 and 32000
Group by 1;

-- finding the count of orders with 1 item and orders with 2 item, like a pivot in excel

select 
	primary_product_id,
    order_id,
    COUNT(distinct case when items_purchased  = 1 then order_id else NULL END) Orders_with_1_item,
    COUNT(distinct case when items_purchased  = 2 then order_id else NULL END) Orders_with_2_item,
    COUNT(distinct order_id) as total_orders # counts all the distinct id's within each primary_product_key which is euqal to sum of total rows in each
    FROM orders								#primary_product_id and the sum of items_purchased since no of rows will be the same
    where order_id between 31000 and 32000
    group by 1,2;
    
select 
	primary_product_id,
    order_id,
    items_purchased,
    COUNT(distinct case when items_purchased  = 1 then order_id else NULL END) Orders_with_1_item,
    COUNT(distinct case when items_purchased  = 2 then order_id else NULL END) Orders_with_2_item
    FROM orders
    where order_id between 31000 and 32000
    group by 1, 2, 3;
    
    
    
    -- shows us the orde_id with the correspoding item_purchased value
    select 
	primary_product_id,
    order_id,
     case when items_purchased  = 1 then order_id else NULL END as Orders_with_1_item,
     case when items_purchased  = 2 then order_id else NULL END as Orders_with_2_item
    FROM orders
    where order_id between 31000 and 32000;
    
    -- -----------------------------------------------------------------------------------------------------
    
    
    
    
    -- Assingment: Traffic Source Trending
    
    
    Select * from website_sessions;
    
    -- MY SOL 1
    SELECT
    YEAR(created_at) as Yr,
    WEEK(created_at) as wk,
    -- MIN(date(created_at)) AS week_start_date,
    COUNT(distinct website_session_id) as total_sessions
    FROM website_sessions
    WHERE created_at Between '2012-04-15' AND 
		'2012-05-10' AND utm_source= 'gsearch' AND utm_campaign= 'nonbrand'
    GROUP BY 1, 2;
    
    -- My SOL 2
    
     SELECT
    MIN(date(created_at)) AS week_start_date,
    COUNT(distinct website_session_id) as total_sessions
    FROM website_sessions
    WHERE created_at Between '2012-04-15' AND 
		'2012-05-10' AND utm_source= 'gsearch' AND utm_campaign= 'nonbrand'
    GROUP BY year(created_at), week(created_at)    -- NOTE WE CAN DO GROUP BY EVEN WITHOUT PUTTING THE COLUMN NAMES IN THE SELECT STATEMENTS
    ORDER BY total_sessions DESC;
    
 --    MY final sol 
    
    SELECT
    MIN(date(created_at)) AS week_start_date,
    COUNT(distinct website_session_id) as total_sessions
    FROM website_sessions
    WHERE created_at  < '2012-05-10' -- the reason we removed the '2012-04-15' is because to see the trend of 
															-- no of sessions occuring before the reduction of biding size
															-- if we keep the between fuction we will not be able to see what happended 
															-- before the bidding size was reduced
		AND utm_source= 'gsearch' 
			AND utm_campaign= 'nonbrand'
    GROUP BY year(created_at), week(created_at);    -- NOTE WE CAN DO GROUP BY EVEN WITHOUT PUTTING THE COLUMN NAMES IN THE SELECT STATEMENTS
    -- ORDER BY total_sessions DESC;
    -- we can see from the results that the number of sessions reduced / week once the bidding was reduced
    
    -- SQL by udemy 1
    SELECT
    YEAR(created_at) as Yr,
    WEEK(created_at) as wk,
    count(distinct website_session_id) as total_sessions
    FROM website_sessions
    WHERE created_at < '2012-05-10' 
			AND utm_source= 'gsearch' 
				AND utm_campaign= 'nonbrand'
    GROUP BY 1,2;

    -- final sol by udemy
	SELECT
    min(date(created_at)) as week_start_date,
    count(distinct website_session_id) as total_sessions
    FROM website_sessions
    WHERE created_at < '2012-05-10' 
			AND utm_source= 'gsearch' 
				AND utm_campaign= 'nonbrand'
    GROUP BY 
    YEAR(created_at),
    WEEK(created_at); -- NOTE WE CAN DO GROUP BY EVEN WITHOUT PUTTING THE COLUMN NAMES IN THE SELECT STATEMENTS
    
    
    
    
    
    
    
    -- -----------------------------------------------------------------------
    -- Assignment: optimization for paid traffic
    
    select * from orders;
    select  
		-- w.session_id,
		device_type,
        count(distinct w.website_session_id) as total_sessions,
        count(distinct order_id) as total_orders,
        count(distinct order_id)/count(distinct w.website_session_id) as session_to_order_conv_rate
        from website_sessions as w
        left join orders as o
			on o.website_session_id = w.website_session_id
            where w.created_at < '2012-05-11' 
				and utm_source = 'gsearch'
                and utm_campaign ='nonbrand'
		group by 1
        order by 3 desc;
        -- findings: desktop is a better option to bid on as opposed to mobile for the same camapign, this way cost can be saved
        
        
-- -----------------------------------------------------------------------------------------------------------------------





        -- Assignments: Trending with Granular Segments
        
        
select  

Min(date(created_at)) as week_start_date,
count(distinct case when device_type = 'desktop' then website_session_id else Null END) AS no_of_desktop_sessions,
count(distinct case when device_type = 'mobile' then website_session_id else Null END)  AS no_of_mobile_sessions
from website_sessions
 where created_at between '2012-04-15' and '2012-06-09'
  -- where created_at > '2012-04-15' and created_at < '2012-06-09'
	and utm_source ='gsearch'
    and utm_campaign = 'nonbrand'
group by 
	year(created_at),
    week(created_at);
    
-- from the results above it can be seen that after bidding (on 2012-06-09')  more in desktop the total no of sessions increased
-- while the mobile sessions were didn't change much
