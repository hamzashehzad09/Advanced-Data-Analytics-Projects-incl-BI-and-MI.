

-- Section 7
-- multiple channels: website, typed in search, emails, social media

-- Analyzing Channel portfolio analysis

-- identify traffic coming from multiple marketing channels, we will use utm parameters stored in 
-- in sessions table and use leftjoin on orders to see the sales


-- utm content allows cpmanies to trace a specific add launched by them

select utm_content, -- null shows non-paid campaign

	count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id)  as session_to_order_conversion_rate
    
    from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id

where website_sessions.created_at Between '2014-01-01' and '2014-02-01'
group by 1
order by sessions desc;


-- assignement 1 Expanded channel protfolio


select 
	year(created_at) as year,
	week(created_at) as week,
    created_at,
    min(date(created_at)) as week_start_date,
    count(distinct website_session_id) as total_sessions,
    count(distinct case when utm_source ='gsearch' then website_session_id else null end) as gsearch_sessions,
    count(distinct case when utm_source ='bsearch' then website_session_id else null end) as bsearch_session
    
    from website_sessions
where created_at > '2012-08-22' and  
	created_at < '2012-11-29' and
	utm_campaign ='nonbrand'
group by 1,2
order by 1, 2;

-- bsearch is big enough


select 

	-- YEARWEEK(created_ad) as year_week
    min(date(created_at)) as week_start_date,
    count(distinct website_session_id) as total_sessions,
    count(distinct case when utm_source ='gsearch' then website_session_id else null end) as gsearch_sessions,
    count(distinct case when utm_source ='bsearch' then website_session_id else null end) as bsearch_session
    
    from website_sessions
where created_at > '2012-08-22' and  
	created_at < '2012-11-29' and
	utm_campaign ='nonbrand'
group by yearweek(created_at);



select 
	
    count(website_session_id) as total_sessions,
    count(distinct case when utm_source ='gsearch' and device_type ='mobile' then website_session_id else null end) as g_search_mobile_sessions,
    count(distinct case when utm_source ='gsearch' and device_type ='mobile' then website_session_id else null end)
					/ count(distinct website_session_id) g_percent_mobile,
                    
	 count(distinct case when utm_source ='bsearch' and device_type ='mobile' then website_session_id else null end) as b_search_mobile_sessions,
     count(distinct case when utm_source ='bsearch' and device_type = 'mobile' then website_session_id else null end)
					/ count(distinct website_session_id) b_percent_mobile
    
    from website_sessions
where created_at > '2012-08-22' and  
	created_at < '2012-11-30' and
	utm_campaign ='nonbrand';
    
    

select 
	utm_source,
    count(website_session_id) as total_sessions,
    count(distinct case when device_type ='mobile' then website_session_id else null end) as mobile_sessions,
    count(distinct case when  device_type ='mobile' then website_session_id else null end)
					/ count(distinct website_session_id) percent_mobile_sessions_out_of_total
    
    from website_sessions
where created_at > '2012-08-22' and  
	created_at < '2012-11-30' and (utm_source = 'gsearch' or utm_source = 'bsearch') and
	utm_campaign ='nonbrand'
group by 1;






-- assignment:  cross channel bid optimization


select 

	device_type,	
    count(distinct website_sessions.website_session_id ) as total_sessions,
    count(distinct case when utm_source ='gsearch' then website_sessions.website_session_id  else null end) as gsearch_sessions,
    count(distinct case when utm_source ='bsearch' then website_sessions.website_session_id  else null end) as bsearch_session,
	count(distinct case when utm_source ='gsearch' then order_id else null end) as gsearch_orders,
	count(distinct case when utm_source ='bsearch' then order_id else null end) as bsearch_orers,
    
    count(distinct case when utm_source ='gsearch' then order_id else null end)
				/  count(distinct case when utm_source ='gsearch' then website_sessions.website_session_id else null end) as gsearch_conv_rate,
		
    
     count(distinct case when utm_source ='bsearch' then order_id else null end)
				/ count(distinct case when utm_source ='bsearch' then website_sessions.website_session_id  else null end) as bsearch_conv_rate
    
    from website_sessions
    left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-08-22' and  
	website_sessions.created_at < '2012-09-19' and
	utm_campaign ='nonbrand'
group by 1;



select 

	device_type,	
    utm_source,
    
    count(distinct website_sessions.website_session_id) as total_sessions,
    count(distinct order_id ) as orders,
    count(distinct order_id)
			/ count(distinct website_sessions.website_session_id) as  conversion_rate_sessions_to_order
    
    from website_sessions
    left join orders
		on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-08-22' and  
	website_sessions.created_at < '2012-09-19' and
	utm_campaign ='nonbrand' and (utm_source ='gsearch' or utm_source = 'bsearch')
group by 1,2;



-- assignment channel porfolio trend




select 
	year(created_at) as year,
	week(created_at) as week,
    created_at as week_start_date,
  --   count(distinct website_sessions.website_session_id ) as total_sessions,
--     count(distinct case when utm_source ='gsearch' then website_sessions.website_session_id  else null end) as gsearch_sessions,
--     count(distinct case when utm_source ='bsearch' then website_sessions.website_session_id  else null end) as bsearch_session,
-- 	count(distinct case when utm_source ='gsearch' then order_id else null end) as gsearch_orders,
-- 	count(distinct case when utm_source ='bsearch' then order_id else null end) as bsearch_orers,
--     
--     count(distinct case when utm_source ='gsearch' then order_id else null end)
-- 				/  count(distinct case when utm_source ='gsearch' then website_sessions.website_session_id else null end) as gsearch_conv_rate,
-- 		
--     
--      count(distinct case when utm_source ='bsearch' then order_id else null end)
-- 				/ count(distinct case when utm_source ='bsearch' then website_sessions.website_session_id  else null end) as bsearch_conv_rate
                
                
	
    count(distinct case when utm_source ='gsearch' and device_type ='desktop' then website_session_id else null end) as g_search_desktop_sessions,
    count(distinct case when utm_source ='bsearch' and device_type ='desktop' then website_session_id else null end) as b_search_desktop_sessions,
	count(distinct case when utm_source ='bsearch' and device_type ='desktop' then website_session_id else null end)
			/ count(distinct case when utm_source ='gsearch' and device_type ='desktop' then website_session_id else null end) bsearch_to_gsearch_ratio,
	
       count(distinct case when utm_source ='gsearch' and device_type ='mobile' then website_session_id else null end) as g_search_mobile_sessions,
    count(distinct case when utm_source ='bsearch' and device_type ='mobile' then website_session_id else null end) as b_search_mobile_sessions,
	count(distinct case when utm_source ='bsearch' and device_type ='mobile' then website_session_id else null end)
			/ count(distinct case when utm_source ='gsearch' and device_type ='mobile' then website_session_id else null end) bsearch_to_gsearch_ratio
    
    from website_sessions
where website_sessions.created_at > '2012-11-04' and  
	website_sessions.created_at < '2012-12-22' and
	utm_campaign ='nonbrand'
group by 1,2
order by 1 , 2;
-- before the bid own on b-search which occured on dec 2nd based on the assignment, we can see that bsearch being about 40 % of the volume of gsearch, and after bid
--  down the volume decreased and bsearch is less price elastic on mobile device

# ------------------------------------------------------------------------------------------------------------------------------------------------------------------




-- Analyzing Brand driven traffic and direct traffic
-- Hallo effect: promotion of addional traffic that is direct , if so then the bids can be adjusted accordingly
-- for non-paid traffic (i.e organic search, direct type in), we can analyze data where the utm parameters are null


        
-- http_referer is null when someone is directly typing the website 
-- organic search: the session came from search engine but doesn't have paid traffic parameters
-- utm_campaign = non-brand then it's a paid non-brand
-- utm_camapign = paid brand then its a paid brand
select *

from website_sessions
	where website_session_id between 100000 and 115000
		and utm_source is Null;

select 
	*,
	case 
		when http_referer is Null THEN "directly_typed_in"
		when http_referer = 'https://www.gsearch.com' then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' then 'bsearch_organic'
		else 'other'
	END AS Type_of_search ,
    
    count(distinct website_session_id) as sessions
    
    
from website_sessions
	where website_session_id between 100000 and 115000
		and utm_source is Null
group by 1;


-- ---------------------------------------------------------------------------------------------------------------------------------------
select 
	
	case 
		when http_referer is Null THEN "directly_typed_in"
		when http_referer = 'https://www.gsearch.com' then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' then 'bsearch_organic'
		else 'other'
	END AS Type_of_search ,
    
    count(distinct website_session_id) as sessions
    
from website_sessions
	where website_session_id between 100000 and 115000
		and utm_source is Null
group by 1
order by 1 desc;




select *

from website_sessions
	where website_session_id between 100000 and 115000
		and utm_source is Null;
        
select 
	
	case 
		when http_referer is Null THEN "directly_typed_in"
		when http_referer = 'https://www.gsearch.com'  and utm_source is null then 'gsearch_organic'
        when http_referer = 'https://www.bsearch.com' and utm_source is null then 'bsearch_organic' -- same code as above
		else 'other'
	END AS Type_of_search ,
    
    count(distinct website_session_id) as sessions
    
    
from website_sessions
	where website_session_id between 100000 and 115000
		and utm_source is Null
group by 1
order by 1 desc;


-- Assignment Traffic Analysis Breakdown


-- STEP 1: FINDING MAIN BUCKETS OF TRAFFICS
select distinct	
		utm_source,
        utm_campaign,
        http_referer
from website_sessions
where created_at < '2012-12-23';



-- STEP 2: LABELLING MAIN BUCKETS OF TRAFFICS INTO CHANEL GROUPS


select distinct
	
	case 
		when utm_source is null and http_referer in ('https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
        when utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_campaign = 'brand' then 'paid_brand'
		when utm_source is Null and http_referer  is null then 'direct_typed_in'
        END as channel_group
	
from website_sessions
	where created_at < '2012-12-23';



select distinct
	website_session_id,
    created_at,
	case 
		when utm_source is null and http_referer in ( 'https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
        when utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_campaign = 'brand' then 'paid_brand'
		when utm_source is Null and http_referer  is null then 'direct_typed_in'
        END as channel_group
	
from website_sessions
	where created_at < '2012-12-23';







select 

	year(created_at) as yr,
    month(created_at) month,
    count(distinct case when channel_group = 'paid_nonbrand' then website_session_id else null end) as nonbrand,
    count(distinct case when channel_group = 'paid_brand' then website_session_id else null end) as brand,
    
    count(distinct case when channel_group = 'paid_brand' then website_session_id else null end)
			/ count(distinct case when channel_group = 'paid_nonbrand' then website_session_id else null end) as paid_brand_percent_to_paid_nonbrand,
            
	count(distinct case when channel_group = 'direct_typed_in' then website_session_id else null end) as directly_typed_in,
    
    count(distinct case when channel_group = 'direct_typed_in' then website_session_id else null end) 
			/ count(distinct case when channel_group = 'paid_nonbrand' then website_session_id else null end) as directly_typed_in_to_paid_nonbrand,
	
    count(distinct case when channel_group = 'organic_search' then website_session_id else null end) as organic_searched,
    
    count(distinct case when channel_group = 'organic_search' then website_session_id else null end)
			/ count(distinct case when channel_group = 'paid_nonbrand' then website_session_id else null end) as organic_searched_to_paid_nonbrand


from(

select distinct
	website_session_id,
    created_at,
	case 
		when utm_source is null and http_referer in ( 'https://www.gsearch.com','https://www.bsearch.com') then 'organic_search'
        when utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_campaign = 'brand' then 'paid_brand'
		when utm_source is Null and http_referer  is null then 'direct_typed_in'
        END as channel_group
	
from website_sessions
	where created_at < '2012-12-23') as channel_group
    group by 1, 2;
    