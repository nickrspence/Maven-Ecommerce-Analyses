USE mavenfuzzyfactory;

/* Serving as a data analyst for the Maven Fuzzy Factory. Fictitious eCommerce company with a 6-table relational database.
	I'm going to show some analysis of the companies performance in two segments:
    1) first half / midpoint of the companies lifespan ('2012-03-19' - '2013-9-19')
    2) full company analysis to date ('2013-9-20' - '2015-03-19'
    - I will show two dashboards, one for each segment analysis
    - reports will be requested by and given to the CEO, Marketing Director, and Website Manager
   
    
    Within the first segment analysis, I want to show more general performance trends across various metrics including:
    - monthly trending sessions, orders, session-to-order CVN rates
		- gsearch / nonbrand, gsearch / brand, bsearch / nonbrand, bsearch / brand monthly trends
			- nonbrand indicates the general performance of our paid advertising.
            - our brand campaign will understandably have lower rates because our brand is new. We hope to see growth
            in our branded campaign and unpaid advertising in the future. Our second segment analysis should show that.
            - after seeing the gsearch is producing the majority of our paid traffic and conversions, let's look at which
            specific advertisting are driving the most. Potentially look at using similar ad type/design for bsearch.
	- monthly trending revenue and profit margin
    - look at sessions/conversion by time of day - perhaps we can display paid ads at specific times to maximize ROAS.
    - website pages funnel analysis - CTRs
			- to show an initial look at customer journies through website pages.
            - follow up comparison analysis of landing pages (probably hits harder than billing page comparison)
	- device type conversion comparison
    - look at website activity by day of week / hour of day to decide when to staff live customer support agents


Second Segment final analysis
	- Maven fuzzy factory must present to investors to gain next round of funding.
    -Show brand growth, not just growth of paid traffic/sales
		- show the increasing trends of unpaid traffic proportionally to paid traffic growth.
        - Wants you to to pull organic search, direct type in, and paid brand search sessions/month,
		and show those sessions as a % of paid search nonbrand.
	- PRODUCT ANALYSIS
		- In this second segment of the companies lifespan we have added multiple products. Show analysis of click rate
        to each product from the /products page. Compare CVN rates of each product.
        -Perform a cross sell analysis of which products cross sell most with each product, then inform the marketing director
        so we can display those specific products on each product /cart page.
        - Could also look at  Avg Products Per order, AOV (average order value), and overall revenue per /cart page view... Perhaps
        try to think of your own hypothesis/test here...
	- Compare conversion rates of repeat sessions vs first sessions. Potentially begin a customer loyalty program, or coupon automation.
    - Seasonality analysis for all products. Valentines day for the love bear. Holidays for all products.
    
    */

-- quarterly trending sessions, orders, session-to-order CVN rates - first 18 months

SELECT
	YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
	website_sessions LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-03-19' AND '2013-9-19'
GROUP BY
	1,2;
    
	year	quarter	sessions	orders	conv_rate
		2012	1	1879	60		0.0319
		2012	2	11433	347		0.0304
		2012	3	16892	684		0.0405
		2012	4	32266	1495	0.0463
		2013	1	19833	1273	0.0642
		2013	2	24745	1718	0.0694
		2013	3	23792	1580	0.0664
;
/* We see strong growth in website traffic shown by sessions,
as well as an over 100% increase in conversion rate over the 18 months.

	Next let's break this up by our two paid advertising sources (gsearch & bsearch)
	take a look at where our website traffic is coming from, along with conversion rates.
*/

SELECT
	YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_sessions,
	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN orders.order_id ELSE NULL END) AS gsearch_orders,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN orders.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS gsearch_order_conv_rate,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN orders.order_id ELSE NULL END) AS bsearch_orders,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN orders.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS bsearch_order_conv_rate
FROM
	website_sessions LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-03-19' AND '2013-9-19'
GROUP BY
	1,2;
    
	year	quarter	gsearch_sessions	gsearch_orders	gsearch_order_conv_rate	bsearch_sessions	bsearch_orders	bsearch_order_conv_rate
	2012	1	1860	60	0.0323	2	0	0.0000
	2012	2	10562	310	0.0294	61	1	0.0164
	2012	3	13179	517	0.0392	2188	95	0.0434
	2012	4	22287	984	0.0442	6578	328	0.0499
	2013	1	13764	853	0.0620	2926	204	0.0697
	2013	2	17598	1210	0.0688	3766	255	0.0677
	2013	3	16719	1075	0.0643	3369	233	0.0692
;

/* Looks like the majority of website traffic volume is coming from our gsearch paid ads (about 4x more than bsearch)
	but the conversion rates for both campaigns grew to the same peak at just under 7%.
    
    Let's dive deeper and see at which times of the day we see the most incoming website traffic, focus our gsearch
    ad spend during those time periods to maximize ROAS.
*/

SELECT
	HOUR(website_sessions.created_at) AS hour,
    COUNT(DISTINCT website_sessions.website_session_id) AS gsearch_sessions,
    COUNT(DISTINCT orders.order_id) AS gsearch_orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
	website_sessions LEFT JOIN orders
    ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-03-19' AND '2013-9-19'
AND
	utm_source = 'gsearch'
GROUP BY
	1;

/* looks like website traffic is busiest from 10am to 4pm, however conversion rates are fairly stable throughout the day.
	Now we can notify our marketing director to increase our bids during those time periods. We might also want to notify
    the customer service team that they may want to increase their live website chat agents during those time periods as well.
    
Next, first lets see a full website page analysis broken out by year and quarter. We see a huge increase in product page conversion rate (we may
want to investigate deeper into which landing pages are most effective to. The rest of our conversion rates are relatively stable through time.
There is some missing data for the last two quarters of this time period shown by 0 billing sessions.
*/

SELECT DISTINCT(pageview_url) FROM website_pageviews
	WHERE created_at BETWEEN '2012-03-19' AND '2013-9-19';

-- full website funnel analysis

DROP TABLE all_pvs;

CREATE TEMPORARY TABLE all_pvs
SELECT
	YEAR(website_pageviews.created_at) AS year,
    QUARTER(website_pageviews.created_at) AS quarter,
	website_pageviews.website_session_id,
    website_pageview_id,
    pageview_url,
    order_id
FROM
	website_pageviews
LEFT JOIN orders
ON website_pageviews.website_session_id = orders.website_session_id
WHERE
	website_pageviews.created_at BETWEEN '2012-03-19' AND '2013-9-19';
    
SELECT * FROM all_pvs;

DROP TABLE all_pvs_broken_out;
CREATE TEMPORARY TABLE all_pvs_broken_out
SELECT
	year,
    quarter,
	website_session_id,
    CASE WHEN pageview_url IN('/home', '/lander-1', '/lander-2', '/lander-3') THEN 1 ELSE 0 END AS landing_page,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS to_products_page,
	CASE WHEN pageview_url IN('/the-original-mr-fuzzy', '/the-forever-love-bear') THEN 1 ELSE 0 END AS to_product_detail,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
    CASE WHEN order_id IS NOT NULL THEN 1 ELSE 0 END AS order_placed
FROM
	all_pvs;
    
SELECT * FROM all_pvs_broken_out;

DROP TABLE all_pvs_broken_out_grouped;

CREATE TEMPORARY TABLE all_pvs_broken_out_grouped
SELECT
	year,
    quarter,
	website_session_id,
    MAX(landing_page) AS landing_page,
	MAX(to_products_page) AS to_products_page,
    MAX(to_product_detail) AS to_product_detail,
    MAX(to_cart) AS to_cart,
    MAX(to_shipping) AS to_shipping,
    MAX(to_billing) AS to_billing,
    MAX(order_placed) AS order_placed
FROM
	all_pvs_broken_out
GROUP BY 1,2,3;

SELECT * FROM all_pvs_broken_out_grouped;

SELECT
	year,
    quarter,
    COUNT(DISTINCT CASE WHEN landing_page = 1 THEN website_session_id ELSE NULL END) AS landing_page_sessions,
	COUNT(DISTINCT CASE WHEN to_products_page = 1 THEN website_session_id ELSE NULL END) AS to_products_page,
		COUNT(DISTINCT CASE WHEN to_products_page = 1 THEN website_session_id ELSE NULL END) / 
		COUNT(DISTINCT CASE WHEN landing_page = 1 THEN website_session_id ELSE NULL END) AS product_page_conv_rate,
    COUNT(DISTINCT CASE WHEN to_product_detail = 1 THEN website_session_id ELSE NULL END) AS product_detail_sessions,
		COUNT(DISTINCT CASE WHEN to_product_detail = 1 THEN website_session_id ELSE NULL END) / 
        COUNT(DISTINCT CASE WHEN to_products_page = 1 THEN website_session_id ELSE NULL END) AS product_detail_conv_rate,
	COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END) AS cart_sessions,
		COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END) / 
        COUNT(DISTINCT CASE WHEN to_product_detail = 1 THEN website_session_id ELSE NULL END) AS cart_conv_rate,
    COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) AS shipping_sessions,
		 COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) / 
         COUNT(DISTINCT CASE WHEN to_cart = 1 THEN website_session_id ELSE NULL END) AS shipping_conv_rate,
    COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) AS billing_sessions,
		 COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) / 
		COUNT(DISTINCT CASE WHEN to_shipping = 1 THEN website_session_id ELSE NULL END) AS billing_conv_rate,
    COUNT(DISTINCT CASE WHEN order_placed = 1 THEN website_session_id ELSE NULL END) AS orders_placed,
		 COUNT(DISTINCT CASE WHEN order_placed = 1 THEN website_session_id ELSE NULL END) / 
         COUNT(DISTINCT CASE WHEN to_billing = 1 THEN website_session_id ELSE NULL END) AS order_conv_rate
FROM
	all_pvs_broken_out_grouped
GROUP BY 1,2;
   
	year	quarter	landing_page_sessions	to_products_page	products_page_conv_rate	product_detail_sessions	product_detail_conv_rate	cart_sessions	cart_conv_rate	shipping_sessions	shipping_conv_rate	billing_sessions	billing_conv_rate	orders_placed	billing_conv_rate
	2012	1	1879	743	0.3954	530	0.7133	228	0.4302	156	0.6842	123	0.7885	60	0.4878
	2012	2	11433	4783	0.4184	3411	0.7132	1473	0.4318	979	0.6646	813	0.8304	347	0.4268
	2012	3	16892	8156	0.4828	5894	0.7227	2582	0.4381	1746	0.6762	1221	0.6993	684	0.5602
	2012	4	32266	15786	0.4892	11417	0.7232	4952	0.4337	3425	0.6916	1407	0.4108	1495	1.0625
	2013	1	19833	10436	0.5262	7974	0.7641	3615	0.4533	2494	0.6899	53	0.0213	1273	24.0189
	2013	2	24745	13646	0.5515	10501	0.7695	4752	0.4525	3269	0.6879	0	0.0000	1718	
	2013	3	23792	13432	0.5646	10218	0.7607	4589	0.4491	3050	0.6646	0	0.0000	1581
;
	
	
-- landing page CTR analysis through first 18 months lump sum to compare conversion rates to the landing page.

CREATE TEMPORARY TABLE all_landing_and_product
SELECT
	website_session_id,
    website_pageview_id,
    pageview_url
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-03-19' AND '2013-9-19'
AND
	pageview_url IN('/home', '/lander-1', '/lander-2', '/lander-3', '/products');
    
SELECT * FROM all_landing_and_product;

CREATE TEMPORARY TABLE landing_product_broken_out
SELECT
	website_session_id,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS lander_0,
	CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_1,
    CASE WHEN pageview_url = '/lander-2' THEN 1 ELSE 0 END AS lander_2,
    CASE WHEN pageview_url = '/lander-3' THEN 1 ELSE 0 END AS lander_3,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
FROM
	all_landing_and_product;
    
SELECT * FROM landing_product_broken_out;

CREATE TEMPORARY TABLE grouped_sessions
SELECT
	website_session_id,
    MAX(lander_0) AS lander_0,
	MAX(lander_1) AS lander_1,
    MAX(lander_2) AS lander_2,
    MAX(lander_3) AS lander_3,
    MAX(products_page) AS products_page
FROM
	landing_product_broken_out
GROUP BY 1;

SELECT * FROM grouped_sessions;

SELECT
	CASE WHEN lander_0 = 1 THEN 'lander_0'
		 WHEN lander_1 = 1 THEN 'lander_1'
         WHEN lander_2 = 1 THEN 'lander_2'
         WHEN lander_3 = 1 THEN 'lander_3'
	ELSE NULL END AS landing_page,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_page = 1 THEN website_session_id ELSE NULL END) AS to_product_page,
    COUNT(DISTINCT CASE WHEN products_page = 1 THEN website_session_id ELSE NULL END) /
	COUNT(DISTINCT website_session_id) AS landing_page_CTR
FROM
	grouped_sessions
GROUP BY 1;

	landing_page	sessions	to_product_page	landing_page_CTR
	lander_0	36909	19632	0.5319
	lander_1	47574	22244	0.4676
	lander_2	42073	22878	0.5438
	lander_3	4284	2228	0.5201
;

/* Here we see lander_0, lander_2, and lander_3 have similar CTRs. Lander_1 has lower CTR and should not be used.alter

Segment two analysis:
1) First need to show volume growth. Pull overall session and order volume, CNV rates, rev per order, and rev per session trended quarter for life of biz.
Since the most recent quarter is incomplete, you can decide how to handle it

- Investors want to see how the brand has grown through the first 3 years. Please show quarterly trending of organic search and direct type-in
*/

SELECT
	YEAR(website_sessions.created_at) as Yr,
    QUARTER(website_sessions.created_at) as Qtr,
    COUNT(website_sessions.website_session_id) as sessions,
    COUNT(order_id) as orders,
    COUNT(order_id) / COUNT(website_sessions.website_session_id) as conv_rate,
    ROUND(SUM(price_usd) / COUNT(order_id), 2) as rev_per_order,
	ROUND(SUM(price_usd) / COUNT(website_sessions.website_session_id), 2) as rev_per_session
FROM website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
    GROUP BY 1,2;

	Yr	Qtr	sessions	orders	conv_rate	rev_per_order	rev_per_session
	2012	1	1879	60	0.0319	49.99	1.60
	2012	2	11433	347	0.0304	49.99	1.52
	2012	3	16892	684	0.0405	49.99	2.02
	2012	4	32266	1495	0.0463	49.99	2.32
	2013	1	19833	1273	0.0642	52.14	3.35
	2013	2	24745	1718	0.0694	51.54	3.58
	2013	3	27663	1840	0.0665	51.73	3.44
	2013	4	40540	2616	0.0645	54.72	3.53
	2014	1	46779	3069	0.0656	62.16	4.08
	2014	2	53129	3848	0.0724	64.37	4.66
	2014	3	57141	4035	0.0706	64.49	4.55
	2014	4	76373	5908	0.0774	63.79	4.93
	2015	1	64198	5420	0.0844	62.80	5.30
;

/* Everything looks great here! Let's look at brand growth...
3) We'd like to show how we've grown specific channels. Please pull quarterly view of orders from
GSEARCH NONBRAND, BSEARCH NONBRAND, BRAND SEARCH overall, ORGANIC search, and directy type-in. */

CREATE TEMPORARY TABLE channels
SELECT
	YEAR(website_sessions.created_at) as Yr,
    QUARTER(website_sessions.created_at) as Qtr,
    website_sessions.website_session_id,
    utm_source,
    utm_campaign,
    http_referer,
    order_id
FROM website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
 WHERE website_sessions.created_at < '2015-03-20';
 
 SELECT * FROM channels;
    
SELECT
	Yr,
    Qtr,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS gsearch_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS bsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_overall,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in
FROM channels
GROUP BY 1,2;

Yr	Qtr	gsearch_nonbrand	bsearch_nonbrand	brand_overall	organic_search	direct_type_in
	2012	1	60	0	0	0	0
	2012	2	291	0	20	15	21
	2012	3	482	82	48	40	32
	2012	4	913	311	88	94	89
	2013	1	766	183	108	125	91
	2013	2	1114	237	114	134	119
	2013	3	1132	245	153	167	143
	2013	4	1657	291	248	223	197
	2014	1	1667	344	354	338	311
	2014	2	2208	427	410	436	367
	2014	3	2259	434	432	445	402
	2014	4	3248	683	615	605	532
	2015	1	3025	581	622	640	552
    ;
    
/* cross sell analysis
- look at which products are cross sold with each other
*/

SELECT
	orders.order_id,
    primary_product_id,
    product_id,
    is_primary_item
FROM
	orders
LEFT JOIN order_items
    ON orders.order_id = order_items.order_id;
    
CREATE TEMPORARY TABLE relevant_x_sell
SELECT
	orders.order_id,
    primary_product_id,
    order_item_id,
    product_id AS x_sell_product
FROM orders LEFT JOIN order_items
	ON orders.order_id = order_items.order_id
    AND order_items.is_primary_item = 0;
    
    SELECT * FROM relevant_x_sell;
    
SELECT
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN x_sell_product = 1 THEN order_id ELSE NULL END) AS _xsold_p1,
	COUNT(DISTINCT CASE WHEN x_sell_product = 2 THEN order_id ELSE NULL END) AS _xsold_p2,
    COUNT(DISTINCT CASE WHEN x_sell_product = 3 THEN order_id ELSE NULL END) AS _xsold_p3,
    COUNT(DISTINCT CASE WHEN x_sell_product = 4 THEN order_id ELSE NULL END) AS _xsold_p4,
    COUNT(DISTINCT CASE WHEN x_sell_product = 1 THEN order_id ELSE NULL END) /
    COUNT(DISTINCT order_id) AS p1_xsell_rt,
    COUNT(DISTINCT CASE WHEN x_sell_product = 2 THEN order_id ELSE NULL END) /
    COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN x_sell_product = 3 THEN order_id ELSE NULL END) /
    COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN x_sell_product = 4 THEN order_id ELSE NULL END) /
    COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM relevant_x_sell
GROUP BY 1;
            
	primary_product_id	total_orders	_xsold_p1	_xsold_p2	_xsold_p3	_xsold_p4	p1_xsell_rt	p2_xsell_rt	p3_xsell_rt	p4_xsell_rt
	1	23861	0	872	1759	3126	0.0000	0.0365	0.0737	0.1310
	2	4803	72	0	136	671	0.0150	0.0000	0.0283	0.1397
	3	3068	277	112	0	640	0.0903	0.0365	0.0000	0.2086
	4	581	16	9	22	0	0.0275	0.0155	0.0379	0.0000
;

/* Interesting. We see product #1 has by far the highest primary product order volume. This alone tells us we should focus our
marketing campaigns around product 1, if any. We also see product #4 cross sells the best for all the other products.
Marketing should display product #4 ads on the /cart pages of products 1-3.

-		 Show analysis of click rate
        to each product from the /products page. Compare CVN rates of each product.
	- Compare conversion rates of repeat sessions vs first sessions. Potentially begin a customer loyalty program, or coupon automation.
    
- revenue & margin per product and month (might show well on excel with heat map formatting - does tableau have similar functionality?
*/
		
SELECT
	YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    SUM(price_usd) AS total_rev,
    SUM(price_usd - cogs_usd) AS total_margin,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS p1_rev,
	SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS p1_margin,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS p2_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS p2_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS p3_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS p3_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS p4_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS p4_rev
FROM
	order_items
GROUP BY 1,2;

/* repeat vs first session by conv_rate. The results indicates both excellent brand growth and value of repeat customers!
	Repeat sessions increased dramatically over the 3 years, and conversion rates showed much greater growth than first timers.
    We should defintely incoporate a loyalty program to encourage repeat customers to purchase more. */

DROP TABLE repeat_sessions_to_orders;

CREATE TEMPORARY TABLE repeat_sessions_to_orders
SELECT
	YEAR(website_sessions.created_at) AS year,
    QUARTER(website_sessions.created_at) AS quarter,
	website_sessions.website_session_id,
    is_repeat_session,
    order_id,
    price_usd
FROM
	website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id;
    
SELECT * FROM repeat_sessions_to_orders;

SELECT
	year,
    quarter,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS first_visit_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS first_visit_conv_rate,
    SUM(CASE WHEN is_repeat_session = 0 THEN price_usd ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN order_id ELSE NULL END) AS first_visit_rev_per_order,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_visit_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_visit_conv_rate,
    SUM(CASE WHEN is_repeat_session = 1 THEN price_usd ELSE NULL END) /
		 COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN order_id ELSE NULL END) AS repeat_visit_rev_per_order
FROM
	repeat_sessions_to_orders
GROUP BY 1,2;

	year	quarter	first_visit_sessions	first_visit_conv_rate	first_visit_rev_per_order	repeat_visit_sessions	repeat_visit_conv_rate	repeat_visit_rev_per_order
	2012	1	1871	0.0321	49.990000	8	0.0000	
	2012	2	10528	0.0285	49.990000	905	0.0519	49.990000
	2012	3	15249	0.0392	49.990000	1643	0.0530	49.990000
	2012	4	28895	0.0453	49.990000	3371	0.0552	49.990000
	2013	1	16269	0.0625	52.281052	3564	0.0718	51.591563
	2013	2	21429	0.0685	51.495450	3316	0.0754	51.790000
	2013	3	23509	0.0651	51.722000	4154	0.0746	51.796387
	2013	4	35075	0.0630	54.593941	5465	0.0743	55.378399
	2014	1	38704	0.0619	62.155073	8075	0.0832	62.180699
	2014	2	43471	0.0704	64.322418	9658	0.0816	64.575317
	2014	3	46335	0.0693	64.603397	10806	0.0764	64.073632
	2014	4	62972	0.0761	64.003515	13401	0.0834	62.892695
	2015	1	50011	0.0843	62.779817	14187	0.0849	62.870299
;

            
            
            
            