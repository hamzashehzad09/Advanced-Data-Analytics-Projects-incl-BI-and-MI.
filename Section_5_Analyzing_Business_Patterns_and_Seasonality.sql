    -- ------------ Section 8: Analyzing Busineess Patterns and Seasonality ------------
    
    
    
    -- Seasonality and Business patterns.
    
    -- day parting analysis
    -- seasonality (end of year, holiday season)
    -- date functions
    -- quarter
    
    
    select 
		website_session_id,
        created_at
        from website_sessions
        where website_session_id Between 150000 and 155000;
        
      select 
		website_session_id,
        hour(created_at)
        from website_sessions
        where website_session_id Between 150000 and 155000;
    

 select 
		website_session_id,
        hour(created_at),
        weekday(created_at) -- day of week 0 = mon, 1 =tues
        from website_sessions
        where website_session_id Between 150000 and 155000;
        
        

 select 
		website_session_id,
        hour(created_at),
        weekday(created_at), -- day of week 0 = mon, 1 =tues
        case 
			when weekday(created_at) = 0 then 'monday'
            when week(created_at) = 1 then 'tuesday'
		else 'other day'
        end as clean_weekday
        from website_sessions
        where website_session_id Between 150000 and 155000;
        	



 select 
		website_session_id,
        hour(created_at),
        weekday(created_at), -- day of week 0 = mon, 1 =tues
        case 
			when weekday(created_at) = 0 then 'monday'
            when week(created_at) = 1 then 'tuesday'
		else 'other day'
        end as clean_weekday,
        quarter(created_at) as qtr
        from website_sessions
        where website_session_id Between 150000 and 155000;
        
   
 select 
		website_session_id,
        hour(created_at),
        weekday(created_at), -- day of week 0 = mon, 1 =tues
        case 
			when weekday(created_at) = 0 then 'monday'
            when week(created_at) = 1 then 'tuesday'
		else 'other day'
        end as clean_weekday,
        quarter(created_at) as qtr,
        month(created_at) as mo,
        date(created_at) as date,
        week(created_at) as week
        
        from website_sessions
        where website_session_id Between 150000 and 155000;     
        
        
        
        
	-- assignment 1:
    
    
    
    select 
		year(website_sessions.created_at) as year,
        month(website_sessions.created_at) as month,
       --  week(website_sessions.created_at) as week,
        
        count(website_sessions.website_session_id) as total_sessions,
        count(orders.order_id) as total_orders
	from website_sessions
    left join orders 
			on website_sessions.website_session_id = orders.website_session_id
	where website_sessions.created_at < '2013-01-01' 
    group by 1,2
    ;
    
    -- week trend
    
      select 
		year(website_sessions.created_at) as year,
       --  month(website_sessions.created_at) as month,
         week(website_sessions.created_at) as week,
        
        count(website_sessions.website_session_id) as total_sessions,
        count(orders.order_id) as total_orders
	from website_sessions
    left join orders 
			on website_sessions.website_session_id = orders.website_session_id
	where website_sessions.created_at < '2013-01-01' 
    group by 1,2;
    
    
select 
		year(website_sessions.created_at) as year,
       --  month(website_sessions.created_at) as month,
         week(website_sessions.created_at) as week,
         date(website_sessions.created_at),
        count(website_sessions.website_session_id) as total_sessions,
        count(orders.order_id) as total_orders
	from website_sessions
    left join orders 
			on website_sessions.website_session_id = orders.website_session_id
	where website_sessions.created_at < '2013-01-01' 
    group by 1,2
    order by 1,2
    
    ; -- the result of query above shows that 2012 month 11 week 47 there are highes number o session
    -- mabye cz of nlack friday
    
  -- 
  
  SELECT 
    DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1 , 2 , 3;
    
    
    
select


hr,
-- round(avg(website_session_id) , 1) as avg_sessions,
round(avg(case when wkday = 0 then total_sessions else null end ),1) as mon,
round(avg(case when wkday = 1 then total_sessions else null end ),1) as tue,
round(avg(case when wkday = 2 then total_sessions else null end ),1) as Wed,
round(avg(case when wkday = 3 then total_sessions else null end ),1) as thur,
round(avg(case when wkday = 4 then total_sessions else null end ),1) as fri,
round(avg(case when wkday = 5 then total_sessions else null end ),1) as sat,
round(avg(case when wkday = 6 then total_sessions else null end ),1) as sun


from (
    
SELECT 
    DATE(created_at) AS created_date,
    WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1 , 2 , 3 ) as daily_hourly_sessions
							group by 1
								order by 1;

    
-- based on the results we can say that
-- for the hour 8-5 more people on the customer care should be allocated  during week days

-- --------------------------------------------------------------------------------------------------------------------------------------

-- Product Analysis

-- Section 9:

-- how products affects the business ?
-- revenue of the product?
-- impact of adding a new product in the business ?


-- KEY TERMS IN BUSINESS 
-- orders: counting orders_id values
-- Revnue: Money the business will bring in with products
-- margin: price usd - cog usd
-- average revenue generated per order : avg(price usd)


    