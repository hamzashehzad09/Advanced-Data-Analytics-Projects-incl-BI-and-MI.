-- USER ANALYSIS


-- Analyzing Repeat Behaviour/visits


-- allows us to understand user beahviour and our most valued csutomer
-- we can also get information regarding a specific user segment



-- Business track customer behaviour through browser cookies, which have unique id assoiated with them

-- user _ id can be seen with repeat session column

-- datediff: allows you to compare the time difference bewteen two dates

-- dateiif(seconddate,firstdate)

-- datediff(now) as days_old
-- datediff(second_session_created, first_session_created) as days_between_sessions
-- datediff(refunded_at, ordered_at)/7 as weeks_from_order_to_refund



select 
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd as price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
    order_item_refunds.created_at,
    datediff(order_item_refunds.created_at,order_items.created_at) as days_to_refund
from order_items
	left join order_item_refunds
on order_item_refunds.order_item_refund_id = order_items.order_item_id
where order_items.order_id in (3489,32049,27061);

select * from order_items;


-- Assignment repeat visitors


-- create temporary table sessions_w_repeats


select
	user_id,
    website_session_id
from website_sessions
where created_at <'2014-11-01'
	and created_at >= '2014-01-01'
	and is_repeat_session = 0;
    
  
  
create temporary table sessions_w_repeats
select
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    website_sessions.website_session_id as repeat_session_id

from ( 

select
	user_id,
    website_session_id
from website_sessions
where created_at <'2014-11-01'
	and created_at >= '2014-01-01'
	and is_repeat_session = 0
	
) as new_sessions
	left join website_sessions
		on website_sessions.user_id = new_sessions.user_id
        and website_sessions.is_repeat_session = 1
        and website_sessions.website_session_id > new_sessions.website_session_id # redundant with the above restriction 
        and website_sessions.created_at < '2014-11-01' and website_sessions.created_at >= '2014-01-01';
        

select * from sessions_w_repeats;

select
	user_id,
    count(distinct new_session_id) as new_sessions,
    count(distinct repeat_session_id) as repeat_sessions

from sessions_w_repeats
group by 1 
order by 3 desc;


select
	repeat_sessions,
    count(distinct user_id) as users

from(
select
	user_id,
    count(distinct new_session_id) as new_sessions,
    count(distinct repeat_session_id) as repeat_sessions

from sessions_w_repeats
group by 1 
order by 3 desc
) as user_level

group by 1

;


-- min max and average time





 create temporary table sessions_w_repeats_for_time_diff
select
	new_sessions.user_id,
    new_sessions.website_session_id as new_session_id,
    new_sessions.created_at as new_session_created_at,
    website_sessions.website_session_id as repeat_session_id,
    website_sessions.created_at as repeat_session_created_at

from ( 

select
	user_id,
    website_session_id,
    created_at
from website_sessions
where created_at <'2014-11-03'
	and created_at >= '2014-01-01'
	and is_repeat_session = 0 -- new sessions only
	
) as new_sessions
	left join website_sessions
		on website_sessions.user_id = new_sessions.user_id
        and website_sessions.is_repeat_session = 1
        and website_sessions.website_session_id > new_sessions.website_session_id # redundant with the above restriction 
        and website_sessions.created_at < '2014-11-03' and website_sessions.created_at >= '2014-01-01';
        
        
select * from	sessions_w_repeats_for_time_diff;


select
	user_id,
    new_session_id,
    new_session_created_at,
    min(repeat_session_id) as second_session_id,
    min(repeat_session_created_at) as second_session_created_at
    
from sessions_w_repeats_for_time_diff
where repeat_session_id is not null
group by 1,2,3;


 create temporary table users_first_to_second

select
	user_id,
    datediff(second_session_created_at, new_session_created_at) as days_first_to_second_session
    
    
from 

(select
	user_id,
    new_session_id,
    new_session_created_at,
    min(repeat_session_id) as second_session_id,
    min(repeat_session_created_at) as second_session_created_at
    
from sessions_w_repeats_for_time_diff
where repeat_session_id is not null
group by 1,2,3)
as first_second;


select * from users_first_to_second;


select
avg(days_first_to_second_session),
min(days_first_to_second_session),
max(days_first_to_second_session)

from users_first_to_second
;


select * from website_sessions

order by user_id; -- why do we have duplicates user id with repeat session_1 


-- Assisgnement New vs Repeat sessions by Channel
-- chnanels that repeat customers come back to
select 
	utm_source,
    utm_campaign,
    http_referer,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count(case when is_repeat_session = 1 then website_session_id else null end) as repeat_sessions
from website_sessions
where created_at < '2014-11-05' and created_at >= '2014-01-01'
group by 1,2,3
order by 4 desc;



select 
	case 
		when utm_source is null and http_referer in ('https://www.gsearch.com', 'https://www.bsearch.com') then 'organic_search'
        when utm_campaign = 'nonbrand' then 'paid_nonbrand'
        when utm_campaign = 'brand' then 'paid_brand'
        when utm_source is Null and http_referer is Null then ' direct_type_in'
        when utm_source ='socialbook' then 'paid_social'
	end as channel_group,
    -- utm_source,
    -- utm_referer,
    count(case when is_repeat_session = 0 then website_session_id else null end) as new_sessions,
    count(case when is_repeat_session = 1 then website_session_id else null end) repeat_sessions
	from website_sessions
where created_at < '2014-11-05' and created_at >= '2014-01-01'
group by 1
;


-- assignement new vs repeat performance


select 
	is_repeat_session,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) as conv_rate,
    sum(price_usd)/count(distinct website_sessions.website_session_id)  as rev_per_session

from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2014-11-08' and 
	website_sessions.created_at >= '2014-01-01'
group by 1;



select 
	*

from website_sessions
	left join orders
		on website_sessions.website_session_id = orders.website_session_id

;
