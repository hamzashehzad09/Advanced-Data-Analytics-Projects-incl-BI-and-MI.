-- KEY TERMS IN BUSINESS 
-- orders: counting orders_id values
-- Revnue: Money the business will bring in with products
-- margin: price usd - cog usd
-- average revenue generated per order : avg(price usd)

select 
	count(order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    avg(price_usd) as average_order_value
from orders
where order_id between 100 and 200;


-- Product Sales analysis:

select 
	primary_product_id,
	count(order_id) as orders,
    sum(price_usd) as revenue,
    sum(price_usd - cogs_usd) as margin,
    avg(price_usd) as average_order_value
    
    
    -- website_session_id shows where the customer placed the order
    
from orders 
where order_id between 10000 and 11000
group by 1
order by 2 desc
;


-- Assignment: Product level sales analysis


select
	year(created_at),
    month(created_at),
    count(order_id) as number_of_sales,
    sum(price_usd) as total_revenue,
    sum(price_usd - cogs_usd) as total_margin
from orders
where created_at < '2013-04-01'
group by 1,2;
    
    
    
-- Assignment Product lanes

select
	year(website_sessions.created_at) as yr,
	month(website_sessions.created_at) as month,
    count(order_id) as orders,
    count(website_sessions.website_session_id) as sessions,
    count(order_id) / count(website_sessions.website_session_id) as overall_conv_rate,
    sum(price_usd)/count(website_sessions.website_session_id) as revenue_per_session,
    count(case when primary_product_id = 1 then order_id else null end) as sales_product_1,
	count(case when primary_product_id = 2 then order_id else null end) as sales_product_2
    
from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id
    
where website_sessions.created_at > '2012-04-01' and website_sessions.created_at < '2013-04-05'
group by 1,2;

-- product 2 orders are increasing once they are introduced in the market
     
     


-- PRODUCT LEVEL WEBSITE ANALYSIS
-- it is about learning how customers interact with each of your products, and 
-- how well each product converts customers



-- Product Conversion
-- we will use website_pagevies data to identfiy users who viewed the/products page and see 
-- which products they clicked next
-- and then from those specific product pages we will look at view-to-order
-- conversion rates and create multi-step conversion funnel


select distinct
pageview_url

from website_pageviews 
where created_at between '2013-02-01' and '2013-03-01'
;
-- from the results above we can see that we have two product pages:
-- 1. forever love bear
-- 2. orginal mr fuzzy 

select distinct
website_session_id,
pageview_url

from website_pageviews 
where created_at between '2013-02-01' and '2013-03-01'
	and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')
;
     
select distinct
-- website_session_id,
pageview_url,
count(distinct website_session_id) as sessions

from website_pageviews 
where created_at between '2013-02-01' and '2013-03-01'
	and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')
    group by 1
;






select distinct
-- website_session_id,
pageview_url,
count(distinct website_pageviews.website_session_id) as sessions,
count(distinct order_id) as orders,
count(distinct order_id) /count(distinct website_pageviews.website_session_id) as view_product_conversion_rate
from website_pageviews 
	left join orders
    on orders.website_session_id = website_pageviews.website_session_id
where website_pageviews.created_at between '2013-02-01' and '2013-03-01'
	and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear')
    group by 1
    
;


-- Product level pathing analysis

-- STEPS TO SOLVE THIS QUESTION
-- STEP1: Find relevant '/products' pageviews with website_session_id
-- STEP2: find the next pageview id that occurs AFTER the product pageview IF THERE IS A NEXT PAGEVIEW, MEANIng it will go to a specific product page mrfuzzy or lone bear
-- STEP3: find the pageview url associated with any applicable next product pageview
-- STEP4: summarize the data and alayzes pre vs post


CREATE temporary table products_pageviews
select 

website_session_id,
website_pageview_id,
created_at,
case
	when created_at < '2013-01-06' then ' A. Pre Product_2'
    when created_at >= '2013-01-06' then ' B. Post Product_2'
    else 'uh oh...check logic'
end as time_period
from website_pageviews
where created_at < '2013-04-06' -- date on which the request was recieved
and created_at > '2012-10-06' -- start of 3 months before product 2 launches
and pageview_url ='/products';

select * from products_pageviews;


select *

from products_pageviews
left join website_pageviews
	on website_pageviews.website_session_id = products_pageviews.website_session_id
		and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id;
        
select 
	*
from products_pageviews
left join website_pageviews
	on website_pageviews.website_session_id = products_pageviews.website_session_id
		 and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id;

-- THE CODE WILL SELECT THE WEBSITE SESSION AND PAGEVIEW IDS FOR THE PRODUCT AND THEN ONCE THE JOIN IS MADE BACK ON THE WEBSITE PAGVEW TABLE
-- THE CODE WILL SELECT ALL THE ROWS WHICH HAS THE SAME WEBSITE SESSION ID AS OF PRDOUCT PAGEVIEWS, BUT WILL SELECT SESSIONS WITH THOSE ROWS HAVING
-- PAGEVIEW ID GREATER THAN THE PAGEVIEW ID OF THE WEBSITE PAGEVIEW, THIS MEANS IT WILL MOVE FROM THE CLICK: PRODUCTS TO THE NEXT STEP IN THE CONVRATE /PRODUCT SALE STEP
-- IT IS POSSIBLE THAT THERE CAN BE MULTIPLE STEPS FOR EXAMPLE FROM /PRODUCT TO /CART /SOMEOTHER PAGE, SINCE WE HAVE PUT MIN(PAGEVIEW_ID) THIS ENSURES WE ONLY GET THE NEXT STEP / FIRST STEP AFTER'/PRODUCT' PAGE
-- 3517,18,19,21,24 WS, WPAGEVIEW 6721

-- step 2
create temporary table sessions_w_next_pageview_id

select 
	products_pageviews.time_period,
    products_pageviews.website_session_id,
    min(website_pageviews.website_pageview_id) as min_next_pageview_id

from products_pageviews
left join website_pageviews
	on website_pageviews.website_session_id = products_pageviews.website_session_id
		and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
			#THIS IS SAYING THAT WE ARE ONLY DOING OUR JOIN FOR PAGEVIEWS THAT HAPPENED AFTER THE PRODUCT PAGEVIEW

group by 1,2

;
 
 select * from  sessions_w_next_pageview_id;
 
 -- step 3
 CREATE TEMPORARY TABLE sessions_w_next_pageview_url
 
 select 
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url as next_pageview_url
from sessions_w_next_pageview_id
	left join website_pageviews
		on website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id
        
;
 

select * from sessions_w_next_pageview_url;

-- just to show the distinct next pageview urls

select distinct next_pageview_url from sessions_w_next_pageview_url;



select 
	time_period,
    count(distinct website_session_id) as sessions,
    count(distinct case when next_pageview_url is not null then website_session_id else null end) as w_next_pg,
    count(distinct case when next_pageview_url is not null then website_session_id else null end)
				/  count(distinct website_session_id) as percentage_with_next_page_view,
	count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end) as to_mrfuzzy,
    count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end)
			/      count(distinct website_session_id) as percentage_to_mrfuzzy,
	count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end) as to_forverlovebear,
    count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end)
			/     count(distinct website_session_id) as percent_to_forverlovebear

from
            
sessions_w_next_pageview_url


group by time_period;










-- ----------------------------------------SUBQUERY METHOD----------------------------

select 
	time_period,
    products_pageviews_sub_query.website_session_id,
    min(website_pageviews.website_pageview_id) as min_nex_pageview_id

from (



select 

website_session_id,
website_pageview_id,
created_at,
case
	when created_at < '2013-01-06' then ' A. Pre Product_2'
    when created_at >= '2013-01-06' then ' A. Post Product_2'
    else 'uh oh...check logic'
end as time_period
from website_pageviews
where created_at < '2013-04-06' -- date on which the request was recieved
and created_at > '2012-10-06' -- start of 3 months before product 2 launches
and pageview_url ='/products') as products_pageviews_sub_query

left join website_pageviews
	on website_pageviews.website_session_id = products_pageviews_sub_query.website_session_id
			and website_pageviews.website_pageview_id > products_pageviews_sub_query.website_pageview_id

group by 1,2;














-- ----------





select 


sessions_w_next_pageview_id_sub_query.time_period,
sessions_w_next_pageview_id_sub_query.website_session_id,
website_pageviews.pageview_url as next_pageview_url


from (
select 
	time_period,
    products_pageviews_sub_query.website_session_id,
    min(website_pageviews.website_pageview_id) as min_nex_pageview_id

from (



select 

website_session_id,
website_pageview_id,
created_at,
case
	when created_at < '2013-01-06' then ' A. Pre Product_2'
    when created_at >= '2013-01-06' then ' A. Post Product_2'
    else 'uh oh...check logic'
end as time_period
from website_pageviews
where created_at < '2013-04-06' -- date on which the request was recieved
and created_at > '2012-10-06' -- start of 3 months before product 2 launches
and pageview_url ='/products') as products_pageviews_sub_query

left join website_pageviews
	on website_pageviews.website_session_id = products_pageviews_sub_query.website_session_id
			and website_pageviews.website_pageview_id > products_pageviews_sub_query.website_pageview_id

group by 1,2) as sessions_w_next_pageview_id_sub_query

 left join website_pageviews
	on website_pageviews.website_pageview_id = sessions_w_next_pageview_id_sub_query.min_next_pageview_id

;






-- Assignment: Building conversion funned for the product


-- STEP 1: SELECT ALL PAGEVIEWS FOR RELEVANT SESSIONS
-- STEP 2: FIGURE OUT WHICH PAGEVIEW URLS TO LOOK FOR
-- STEP 3: PUT ALL PAGEVIEWS AND IDENTIFY THE FUNNEL STEPS
-- STEP 4: CREATE SESSION-LEVEL CONVERSION FUNNEL VIEW
-- STEP 5: AGGREGATE THE DATA TO ASSESS FUNNEL PERFORMANCE

create temporary table sessions_seeing_product_pages

SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
    
from website_pageviews 

	where created_at <'2013-04-10' -- date of assignment
		and created_at > '2013-01-06' -- product to launch
			and pageview_url in ('/the-original-mr-fuzzy','/the-forever-love-bear');


select * from sessions_seeing_product_pages;


  -- finding the right pageview url's to build the table.
  
  SELECT 
	website_session_id,
    website_pageview_id,
    pageview_url as product_page_seen
    
from website_pageviews 

	where created_at <'2013-04-10' -- date of assignment
		and created_at > '2013-01-06' -- product to launch
		;
        
        
  select distinct 
  
	website_pageviews.pageview_url
from
    sessions_seeing_product_pages
	left join website_pageviews
        on website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
			and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
    
    -- it gives us all the urls/steps that customer will go to to complete the conversion funnel
    ;
    
    
    
    -- we will look at the inner query first to look over the pageview-level results
    -- then, turn it into a subquery and make it the summary flags
    
    
    
    
    select 
		sessions_seeing_product_pages.website_session_id,
        sessions_seeing_product_pages.product_page_seen,
        case when pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when pageview_url = '/billing-2' then 1 else 0 end as billing_page,
        case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
	
    from
		sessions_seeing_product_pages
			left join website_pageviews
		
         on website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
			and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
	order by 
		 sessions_seeing_product_pages.website_session_id,
         website_pageviews.created_at
         
         ;
         
         
         -- adding a subquey
         
         
         
    create temporary table session_product_level_made_it_flags
     select 
		website_session_id,
        case
			when product_page_seen = '/the-original-mr-fuzzy' then 'mrfuzzy'
            when product_page_seen = '/the-forever-love-bear' then 'lovebear'
            else 'uh oh...check logic'
		end as product_seen,
        max(cart_page) as cart_made_it,
        max(shipping_page) as shipping_made_it,
        max(billing_page) as billing_made_it,
        max(thankyou_page) as thankyou_made_it
        
from (
         
           select 
		sessions_seeing_product_pages.website_session_id,
        sessions_seeing_product_pages.product_page_seen,
        case when pageview_url = '/cart' then 1 else 0 end as cart_page,
        case when pageview_url = '/shipping' then 1 else 0 end as shipping_page,
        case when pageview_url = '/billing-2' then 1 else 0 end as billing_page,
        case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end as thankyou_page
	
    from
		sessions_seeing_product_pages
			left join website_pageviews
		
         on website_pageviews.website_session_id = sessions_seeing_product_pages.website_session_id
			and website_pageviews.website_pageview_id > sessions_seeing_product_pages.website_pageview_id
	order by 
		 sessions_seeing_product_pages.website_session_id,
         website_pageviews.created_at
         ) as pageview_level
         group by
			website_session_id,
            case
			when product_page_seen = '/the-original-mr-fuzzy' then 'mrfuzzy'
            when product_page_seen = '/the-forever-love-bear' then 'lovebear'
            else 'uh oh...check logic' 
				end;
	
    select * from session_product_level_made_it_flags;
    
    
    select 
		product_seen,
        count(distinct website_session_id) as sessions,
        count(distinct case when cart_made_it = 1 then website_session_id else null end) as to_cart,
        count(distinct case when shipping_made_it = 1 then website_session_id else null end) as to_shipping,
        count(distinct case when billing_made_it = 1 then website_session_id else null end) as to_billing,
        count(distinct case when thankyou_made_it = 1 then website_session_id else null end) as to_thankyou
	from 
		session_product_level_made_it_flags
	group by product_seen;
    
    
    select 
    product_seen,
    count(distinct case when cart_made_it = 1 then website_session_id else null end)/count(distinct website_session_id) as product_click_through_rate,
    count(distinct case when shipping_made_it = 1 then website_session_id else null end)/count(distinct case when cart_made_it = 1 then website_session_id else null end) as cart_click_through,
    count(distinct case when billing_made_it = 1 then website_session_id else null end) /count(distinct case when shipping_made_it = 1 then website_session_id else null end) as shipping_click_through,
    count(distinct case when thankyou_made_it = 1 then website_session_id else null end) / count(distinct case when billing_made_it = 1 then website_session_id else null end) as billing_click_through
    
    from session_product_level_made_it_flags
    	group by product_seen;
        

-- ------------------------------------------------------------------------------------------------------------------------




-- NEW CONCEPT: CROSS SELLING PRODUCTS...........





-- crosselling products
-- cross-sell analysis is about understanding which products users are most likely
-- to purchase together, and offering smart product recommendations


-- customer will buy cat , dog , rabbit , parrot at the same time but not crab

-- undertanding which products are purchased together
-- testing and optimizng the way you cross-sell products on your website
-- understanding the conversion rate impact of trying to cross sell addiotional products
    
    
    
    -- EXAMPLE CROSS SELL ANALYSIS
    -- WE CAN ANALYZ ORDERS AND ORDER_ITEMS DATA TO UNDERSTAND WHICH PRODUCTS CROSS-SELL, AND ANALYZE THE IMPACT ON REVENUE
    -- WE WILL ASLO USE WEBSITE_PAGEVIEWS DATA TO UNDERSTAND IF CROSS-SELLING HURTS OVERALL CONVERSION RATES
    -- USING THIS DATA WE CAN DEVELOP A DEPPER UNDERSTANDING OF OUR CUSTOMER PURCHASE
    
    
SELECT * FROM ORDERS;

-- item_purchased > 1 = cross-sell
-- item_purchased < 1 = no cross-sell
-- but we also want to see to which next product the customer go through (item purchased no 2)


SELECT * from
order_items

-- is_primary_item = 1 means no cross-sell
-- is_primary_item - 0 means cross-sell

-- this tells us if a specific product(product_id) is the firs_item(primary item) or the cross-sell(2nd item)
where order_id between 10000 and 11000; 


select * from orders;

select 
	orders.order_id,
    orders.primary_product_id,
    order_items.product_id as cross_sell_products -- since rder_items.is_primary_item = 0
from
	orders
left join order_items
	on order_items.order_id = orders.order_id
			and order_items.is_primary_item = 0 -- cross-sell only


where orders.order_id between 10000 and 11000; 


select 
	-- orders.order_id,
    orders.primary_product_id,
    order_items.product_id as cross_sell_products, -- since rder_items.is_primary_item = 0
    count(distinct orders.order_id) as orders
from
	orders
left join order_items
	on order_items.order_id = orders.order_id
			and order_items.is_primary_item = 0 -- cross-sell only
where orders.order_id between 10000 and 11000
group by 1,2; 

-- for product 1 the most common thing to be cross sold is nothing
-- prooduct 2 has less cross sold as compared to 3



select 
	-- orders.order_id,
    orders.primary_product_id, 
    count(distinct orders.order_id) as orders,
	count(distinct case when order_items.product_id = 1 then orders.order_id else null end) as cross_sell_product_1,
    count(distinct case when order_items.product_id = 2 then orders.order_id else null end) as cross_sell_product_2,
	count(distinct case when order_items.product_id = 3 then orders.order_id else null end) as cross_sell_product_3
from
	orders
left join order_items
	on order_items.order_id = orders.order_id
			and order_items.is_primary_item = 0 -- cross-sell only
where orders.order_id between 10000 and 11000
group by 1; 




select 
	-- orders.order_id,
    orders.primary_product_id, 
    count(distinct orders.order_id) as orders,
	count(distinct case when order_items.product_id = 1 then orders.order_id else null end) as cross_sell_product_1,
    count(distinct case when order_items.product_id = 2 then orders.order_id else null end) as cross_sell_product_2,
	count(distinct case when order_items.product_id = 3 then orders.order_id else null end) as cross_sell_product_3,
    
	count(distinct case when order_items.product_id = 1 then orders.order_id else null end)
				/  count(distinct orders.order_id) as cross_sell_product_1_rate,
	count(distinct case when order_items.product_id = 2 then orders.order_id else null end)
			   /   count(distinct orders.order_id)    as cross_sell_product_2_rate,
	count(distinct case when order_items.product_id = 3 then orders.order_id else null end) 
			/  count(distinct orders.order_id)   as cross_sell_product_3_rate
from
	orders
left join order_items
	on order_items.order_id = orders.order_id
			and order_items.is_primary_item = 0 -- cross-sell only
where orders.order_id between 10000 and 11000
group by 1; 




-- assignment

-- STEP1: IDENTIFY THE RELEVANT /cart pageviewes and their sessions
-- STEP2: See which of those /cart sessions clicked through shipping page
-- STEP3: FIND THE ORDERS associated with the /cart sessions. Analyze products purchased, AOV
-- step4: aggregate and analyze a summary of findings





 create temporary table sessions_seeing_cart

select 
	case 
		when created_at < '2013-09-25' then 'A. Pre_cross_sell'
        when created_at >= '2013-01-06' then 'B. Post_cross_sell'
        ELSE 'uh oh.....check logic'
	end as time_period,
		website_session_id as cart_session_id,
        website_pageview_id as cart_pageview_id
	from website_pageviews
	where created_at between '2013-08-25' and  '2013-10-25'
		and pageview_url = '/cart';
    
    
  select * from sessions_seeing_cart;  
  


select 
	*

from sessions_seeing_cart
	left join website_pageviews	
		on website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
       --  and website_pageviews.website_pageview_id > sessions_seeing_cart.pageview_id

;


CREATE temporary table cart_sessions_seeing_another_page

select 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    min(website_pageviews.website_pageview_id) as pv_id_after_cart

from sessions_seeing_cart
	left join website_pageviews	
		on website_pageviews.website_session_id = sessions_seeing_cart.cart_session_id
        and website_pageviews.website_pageview_id > sessions_seeing_cart.cart_pageview_id

group by 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id
having
	min(website_pageviews.website_pageview_id) is not null;
    
    
select * from cart_sessions_seeing_another_page;


create temporary table pre_post_sessions_orders
select 
	time_period,
    cart_session_id,
    order_id,
    items_purchased,
    price_usd
    
    from sessions_seeing_cart
    
    inner join orders -- to ignore the sessions that didnt had orders
		on sessions_seeing_cart.cart_session_id = orders.website_session_id;
    -- sessions with cart which placed the orders


select * from pre_post_sessions_orders;


select 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    case when cart_sessions_seeing_another_page.cart_session_id is null then 0 else 1 end as clicked_to_another_page,
    case when pre_post_sessions_orders.order_id is null then 0 else 1 end as placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
    
    from sessions_seeing_cart
		left join cart_sessions_seeing_another_page
			on sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
         left join pre_post_sessions_orders
			on sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
            
order by cart_session_id; -- gives us all the sessions that went to cart and then went to another page and ordered and item, null and 0 condition
							-- placed since there will be rows that went to cart but not further or not all the steps
    
    
    
select 
		time_period,
        count(distinct cart_session_id) as cart_sessions,
        sum(clicked_to_another_page) as clickthroughs,
        sum(clicked_to_another_page) / count(distinct cart_session_id) as cart_,
		-- sum(placed_order) as orders_placed,
        -- sum(items_purchased) as product_purchased,
        sum(items_purchased)/sum(placed_order) as products_per_order,
        -- sum(price_usd) as revenue,
        sum(price_usd)/sum(placed_order) as aov,
        sum(price_usd)/count(distinct cart_session_id) as rev_per_cart_session
from 
(
select 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    case when cart_sessions_seeing_another_page.cart_session_id is null then 0 else 1 end as clicked_to_another_page,
    case when pre_post_sessions_orders.order_id is null then 0 else 1 end as placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
from sessions_seeing_cart
		left join cart_sessions_seeing_another_page
			on sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
         left join pre_post_sessions_orders
			on sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
	order by cart_session_id
    )As full_data
group by time_period;
    
    
    
    
select 
		time_period,
        count(distinct cart_session_id) as cart_sessions,
        sum(clicked_to_another_page) as clickthroughs,
        sum(clicked_to_another_page) / count(distinct cart_session_id) as cart_,
		sum(placed_order) as orders_placed,
        sum(items_purchased) as product_purchased,
        sum(items_purchased)/sum(placed_order) as products_per_order,
        sum(price_usd) as revenue,
        sum(price_usd)/sum(placed_order) as aov,
        sum(price_usd)/count(distinct cart_session_id) as rev_per_cart_session
from 
(
select 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    case when cart_sessions_seeing_another_page.cart_session_id is null then 0 else 1 end as clicked_to_another_page,
    case when pre_post_sessions_orders.order_id is null then 0 else 1 end as placed_order,
    pre_post_sessions_orders.items_purchased,
    pre_post_sessions_orders.price_usd
from sessions_seeing_cart
		left join cart_sessions_seeing_another_page
			on sessions_seeing_cart.cart_session_id = cart_sessions_seeing_another_page.cart_session_id
         left join pre_post_sessions_orders
			on sessions_seeing_cart.cart_session_id = pre_post_sessions_orders.cart_session_id
	order by cart_session_id
    )As full_data
group by time_period;
    
    
    
    
-- assignment portfolio expansion

select 
	case  #-----------------------------------------------------------------------------------??????????????????????????? DATE ISSUE
		when website_sessions.created_at < '2013-12-12' then 'A. Pre_Birthday_Bear'
        when website_sessions.created_at >= '2013-01-06' then 'B. Post_Birthday_Bear'
        ELSE 'uh oh.....check logic'
	end as time_period,
    count(distinct website_sessions.website_session_id) as sessions,
    count(distinct orders.order_id) as orders,
    count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as conv_rate,
    sum(orders.price_usd) as total_revenue,
    sum(orders.items_purchased) as total_products_sold,
    sum(orders.price_usd) / count(distinct orders.order_id) as average_order_value,
    sum(orders.items_purchased)/count(distinct orders.order_id) as products_per_order,
    sum(orders.price_usd)/count(distinct website_sessions.website_session_id) revenue_per_session

from website_sessions
	left join orders
		on orders.website_session_id = website_sessions.website_session_id

where website_sessions.created_at between '2013-11-12' and '2014-01-12'

group by 1;
    


-- ---------------------------------------------------------------------------------


-- PRODUCT REFUND ANALYSIS

-- HELPS US MONITORING PRODUCTS FROM DIFFERENT SUPPLIERS
-- UNDERSTANDING REFUND RATES FOR PRODUCTS AT DIFFERENT PRICE POINTS
-- TAKING PRODUCT REFUND RATES AND THE ASSOSCIATED COSTS INTO ACCOUNT WHEN ASSESSING THE OVERALL PERFORMANCE OF BUSINESS



-- analyzing product refund using our order-item data joined to the order_item_refunds table
-- tracking total amount refunded, and % of time each product is refunded and the overall impact on margin

select 
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd as price_paid_usd,
    order_items.created_at
    -- order_item_refund.order_item_refund_id,
    -- order_item_refunds.refund_amount_usd,
    -- order_item_refunds.created_at
from order_items
	-- left join order_item_refunds
	-- 	on order_item_refunds.order_item_id = order_items.order_item_id
where order_items.order_id in (3849,32049,27061) -- three random id

;


select 
	order_items.order_id,
    order_items.order_item_id,
    order_items.price_usd as price_paid_usd,
    order_items.created_at,
    order_item_refunds.order_item_refund_id,
    order_item_refunds.refund_amount_usd,
	order_item_refunds.created_at
from order_items
	left join order_item_refunds
		on order_item_refunds.order_item_id = order_items.order_item_id
        
        -- we do left join because not every item is refunded and we want to preserve the inital item data without 
        -- restrictions to only those records where theere is a match
where order_items.order_id in (3849,32049,27061);



-- last assignment


select

year(order_items.created_at) as yr,
month(order_items.created_at) as mo,
count(distinct case when product_id = 1 then order_items.order_item_id else null end) as p1_orders,
count(distinct case when product_id = 1 then order_item_refunds.order_item_id else null end)
	/count(distinct case when product_id = 1 then order_items.order_item_id else null end) as p1_refund_rate,

count(distinct case when product_id = 2 then order_items.order_item_id else null end) as p2_orders,
count(distinct case when product_id = 2 then order_item_refunds.order_item_id else null end)
	/count(distinct case when product_id = 2 then order_items.order_item_id else null end) as p2_refund_rate,

count(distinct case when product_id = 3 then order_items.order_item_id else null end) as p3_orders,
count(distinct case when product_id = 3 then order_item_refunds.order_item_id else null end)
	/count(distinct case when product_id = 3 then order_items.order_item_id else null end) as p3_refund_rate,
    
count(distinct case when product_id = 4 then order_items.order_item_id else null end) as p4_orders,
count(distinct case when product_id = 4 then order_item_refunds.order_item_id else null end)
	/count(distinct case when product_id = 4 then order_items.order_item_id else null end) as p4_refund_rate
    
from order_items
	left join order_item_refunds
		on order_items.order_item_id = order_item_refunds.order_id
where order_items.created_at < '2014-10-15'

group by 1 ,2

;
    
    