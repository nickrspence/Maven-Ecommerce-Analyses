
/*
** All Tableau visualizations for individual query outputs are linked in the README, along with both segment dashboards **

**********************************
FIRST SEGMENT EXPLORATORY ANALYSIS
**********************************
    - First 18 months of data from Maven Factory - ‘2012-04-01’ to ‘2013-09-31’

1.1) I would like to begin by pulling quarterly trending website sales data to get a broad overview of company performance.

	- I have pulled website sessions, orders, and session-to-order conversion rates.

OUTPUT (PLEASE FIND Tableau Viz 1.1 linked in the README)
	- All good indicators! We see tremendous website traffic volume growth shown by total sessions, as well as our session-to-order
		conversion rate more than doubling in the first 18 months.
	- The increase in total session volume could be the result of multiple factors including marketing campaigns, brand recognition, etc.
		The conversion rate increase may be the result of brand growth, better website page design, repeat customers.
	- This is a good overview from which to dive deeper into specific metrics.
--------------------------------------------------------------------------------------------------------------------------------------------*/
   
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
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
GROUP BY 1,2;

Yr	Qtr		sessions	orders		conv_rate
2012	2		11433		347		0.0304
2012	3		16892		684		0.0405
2012	4		32266		1495		0.0463
2013	1		19833		1273		0.0642
2013	2		24745		1718		0.0694
2013	3		27663		1840		0.0665
;

-- Below is the same query with date format modifications for better Tableau visualization

SELECT
	DATE(website_sessions.created_at) AS date,
    	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    	COUNT(DISTINCT orders.order_id) AS orders,
    	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
	website_sessions LEFT JOIN orders
    	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
GROUP BY 1;

/*----------------------------------------------------------------------------------------------------------------------------------
1.2) I would like to break down the previous data by our two paid advertising sources (gsearch & bsearch) in order to identify
	where our website traffic volume is coming from.

	- I pulled the same metrics broken out by the two advertising sources (gsearch & bsearch)

OUTPUT (Find Tableau Viz 1.2 linked in the README)
	- Looks like about 80% of our website traffic volume is coming from our gsearch paid ads.
	- However the conversion rates for both campaigns peaked at about 7%. We may want to run a follow up test that breaks out
		both gsearch and bsearch into individual advertisements in order to identify where the most session volume is coming from.
	- We may also suggest to the marketing director to increase bids on our bsearch campaigns in order to increase session volume, 
		then run a follow up test to evaluate.
---------------------------------------------------------------------------------------------------------------------------------------*/

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
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
GROUP BY 1,2;
    
Yr	Qtr		gsearch_sessions	gsearch_orders		gsearch_order_conv_rate		bsearch_sessions	bsearch_orders		bsearch_order_conv_rate
2012	2		10562			310			0.0294				61			1			0.0164
2012	3		13179			517			0.0392				2188			95			0.0434
2012	4		22287			984			0.0442				6578			328			0.0499
2013	1		13764			853			0.0620				2926			204			0.0697
2013	2		17598			1210			0.0688				3766			255			0.0677
2013	3		19465			1255			0.0645				3932			275			0.0699
;

-- Again, below is the same query date formatted for Tableau visualization

SELECT
	DATE(website_sessions.created_at) AS date,
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
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
GROUP BY 1;

/*-------------------------------------------------------------------------------------------------------------------------------------
1.3) I would like to dive deeper into our gsearch advertising campaign and look at which times of the day show more or less activity.
	We could potentially focus our ad spend on specific hours in order to maximize ROAS.
    
	- Within our gsearch campaign, I pulled session volume, orders, and conversion rate broken out by hour of day.

OUTPUT (Find Tableau Viz 1.3 linked in the README)
	- Looks like website traffic is busiest from 10am to 4pm, but conversion rates are fairly stable throughout the day.
		I would recommend that our marketing director increase our bids during those time periods. We might also want to notify
		the customer service team that they may want to increase their live customer support chat agents during those time periods 
       		in order to handle the increased website activity.
-------------------------------------------------------------------------------------------------------------------------------------*/

SELECT
	HOUR(website_sessions.created_at) AS hour,
   	COUNT(DISTINCT website_sessions.website_session_id) AS gsearch_sessions,
    	COUNT(DISTINCT orders.order_id) AS gsearch_orders,
    	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
	website_sessions LEFT JOIN orders
   	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
AND
	utm_source = 'gsearch'
GROUP BY 1;
    
hour	gsearch_sessions	gsearch_orders		conv_rate
0	2471			129			0.0522
1	1972			82			0.0416
2	1750			105			0.0600
3	1615			88			0.0545
4	1646			90			0.0547
5	1680			83			0.0494
6	2094			103			0.0492
7	2551			139			0.0545
8	3745			179			0.0478
9	5154			266			0.0516
10	6198			310			0.0500
11	6523			329			0.0504
12	6544			321			0.0491
13	6347			331			0.0522
14	6209			356			0.0573
15	6324			346			0.0547
16	6278			345			0.0550
17	5534			305			0.0551
18	4599			253			0.0550
19	3983			216			0.0542
20	3709			200			0.0539
21	3629			208			0.0573
22	3302			182			0.0551
23	2998			163			0.0544
;

/*-------------------------------------------------------------------------------------------------------------------------------------
1.4) I would like to perform a website page funnel analysis to see how many of our customers are clicking through to each page and where 
	they're dropping off. If we find signficantly low conversion rates for specific website pages, we can try split testing different variations.

OUTPUT (Find Tableau Viz 1.4 linked in the README)
	- We found some helpful data here! Our landing-to-products page CTR shows about a 40% increase over the 18 months.
		I know the marketing team tested a few different landing pages, so we can dig deeper to see which performed best.
	- Another interesting finding is the rather low cart-to-shipping page CTR. It has about a 45% conversion rate,
		while the other pages (e.g. product-to-cart, shipping-to-billing) have higher CTRs at 60-70%.
        	I would likely recommend to our website manager to test a different cart page in order to encourage buyers to click through to shipping.
 
	** There is some missing data for the last two quarters of this time period shown by 0 billing sessions, which greatly skewed those pieces of data.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- First I pulled all relevant website pageviews and pageview_urls within the designated time period, and LEFT JOINed to orders table to obtain orders data.

CREATE TEMPORARY TABLE all_pvs
SELECT
	YEAR(website_pageviews.created_at) AS year,
    	QUARTER(website_pageviews.created_at) AS quarter,
	website_pageviews.website_session_id,
    	website_pageview_id,
    	pageview_url,
    	order_id
FROM
	website_pageviews LEFT JOIN orders
	ON website_pageviews.website_session_id = orders.website_session_id
WHERE
	website_pageviews.created_at BETWEEN '2012-04-01' AND '2013-9-31';
    
SELECT * FROM all_pvs;

-- Then I grouped and labeled each pageview_url using the flag method.

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

-- Here I grouped all website pageviews by website_session_id in order to see the full page funnel for each customer visit.

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

-- With the final output, I performed a COUNT for each website session in order to present the full website funnel data.

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
   
Yr	Qtr		landing_sessions	products_sessions	products_conv_rate	product_detail_sessions		product_detail_conv_rate	cart_sessions	cart_conv_rate	shipping_sessions	shipping_conv_rate	billing_sessions	billing_conv_rate	orders_placed	order_conv_rate
2012	2		11433			4783			0.4184			3411				0.7132				1473		0.4318		979			0.6646			813			0.8304			347		0.4268
2012	3		16892			8156			0.4828			5894				0.7227				2582		0.4381		1746			0.6762			1221			0.6993			684		0.5602
2012	4		32266			15786			0.4892			11417				0.7232				4952		0.4337		3425			0.6916			1407			0.4108			1495		1.0625
2013	1		19833			10436			0.5262			7974				0.7641				3615		0.4533		2494			0.6899			53			0.0213			1273		24.0189
2013	2		24745			13646			0.5515			10501				0.7695				4752		0.4525		3269			0.6879			0			0.0000			1718	
2013	3		27663			15645			0.5656			11913				0.7615				5329		0.4473		3547			0.6656			0			0.0000			1841
;
	
-- Below I have re-written the same queries with slight modifications in order to create a lump sum funnel analysis Tablaeu viz

CREATE TEMPORARY TABLE all_pvs_funnel
SELECT
	website_pageviews.website_session_id,
    	website_pageview_id,
    	pageview_url,
    	order_id
FROM
	website_pageviews LEFT JOIN orders
	ON website_pageviews.website_session_id = orders.website_session_id
WHERE
	website_pageviews.created_at BETWEEN '2012-04-01' AND '2013-9-31';
    
SELECT * FROM all_pvs_funnel;


CREATE TEMPORARY TABLE all_pvs_broken_out_funnel
SELECT
	website_session_id,
    	CASE WHEN pageview_url IN('/home', '/lander-1', '/lander-2', '/lander-3') THEN 1 ELSE 0 END AS landing_page,
    	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS to_products_page,
	CASE WHEN pageview_url IN('/the-original-mr-fuzzy', '/the-forever-love-bear') THEN 1 ELSE 0 END AS to_product_detail,
    	CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS to_cart,
    	CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS to_shipping,
    	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS to_billing,
    	CASE WHEN order_id IS NOT NULL THEN 1 ELSE 0 END AS order_placed
FROM
	all_pvs_funnel;
    
SELECT * FROM all_pvs_broken_out_funnel;

SELECT
	CASE WHEN landing_page = 1 THEN 'landing_pg'
		WHEN to_products_page = 1 THEN 'products_pg'
		WHEN to_product_detail = 1 THEN 'product_detail_pg'
		WHEN to_cart = 1 THEN 'cart_pg'
		WHEN to_shipping = 1 THEN 'shipping_pg'
		WHEN to_billing = 1 THEN 'order_placed'
		WHEN order_placed = 1 THEN 'billing_pg'
	ELSE NULL END AS website_pg,
    	COUNT(DISTINCT website_session_id) AS sessions
FROM 
	all_pvs_broken_out_funnel
GROUP BY 1;

website_pg		sessions

landing_pg		132832
products_pg		68452
product_detail_pg	51110
cart_pg			22703
shipping_pg		15460
billing_pg		7357
order_placed		349
;

/*-------------------------------------------------------------------------------------------------------------------------------------
1.5) In the last website funnel analysis output, we saw a substantial increase in our landing-to-product page CTR.
	I would like dig deeper into that and compare the performance of our four different landing pages.
    
OUTPUT (No Viz)
	- We didn't find any signficant differences in CTR for our different landing pages.
		We see lander_0, lander_2, and lander_3 have similar CTRs, while lander_1 showed a slightly lower CTR.
		This would indicate the increase in CTR is likely due to brand recognition versus page specific design.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- I began by pulling all website pageviews of the four landing pages and the products page.

SELECT
	website_session_id,
    	website_pageview_id,
    	pageview_url
FROM
	website_pageviews
WHERE
	created_at BETWEEN '2012-04-01' AND '2013-9-31'
AND
	pageview_url IN('/home', '/lander-1', '/lander-2', '/lander-3', '/products');

-- Next I used the above code as a subquery, and then flagged and labeled each pageview.


CREATE TEMPORARY TABLE landing_product_broken_out
SELECT
	website_session_id,
    	CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS lander_0,
	CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander_1,
    	CASE WHEN pageview_url = '/lander-2' THEN 1 ELSE 0 END AS lander_2,
    	CASE WHEN pageview_url = '/lander-3' THEN 1 ELSE 0 END AS lander_3,
    	CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
FROM
	(
	SELECT
		website_session_id,
		website_pageview_id,
		pageview_url
	FROM
		website_pageviews
	WHERE
		created_at BETWEEN '2012-04-01' AND '2013-9-31'
	AND
		pageview_url IN('/home', '/lander-1', '/lander-2', '/lander-3', '/products')
	) AS all_landing_and_product;
    
SELECT * FROM landing_product_broken_out;

-- Next I grouped by website_session_id in order to reveal how many landing page visits made it to the products page.


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

-- Finally I pivoted all four landing pages to the first column, and performed a COUNT to determine CTRs to the products page.

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

landing_page	sessions	to_products_page	landing_page_CTR
lander_0	35905		19417			0.5408
lander_1	47574		22244			0.4676
lander_2	44062		24031			0.5454
lander_3	5291		2760			0.5216
;

/*-------------------------------------------------------------------------------------------------------------------------------------
1.6) To wrap up this first segment analysis, I want to perform a basic device type analysis.
	I broke out mobile and desktop website traffic and compared session-to-order conversion rates.

OUTPUT (No Viz)
	- Interesting, desktop users make up 75% of our website traffic volume, and have almost a 3x higher session-to-order conversion rate.
		We definitely would need to dive deeper into this comparison and identify which factors are accounting for the difference.
		The website manager will likely want to split test different mobile interface landing pages in order to increase the conversion rate.
-------------------------------------------------------------------------------------------------------------------------------------*/

SELECT
	device_type,
    	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    	COUNT(DISTINCT orders.order_id) AS orders,
    	COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM
	website_sessions LEFT JOIN orders
    	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2013-9-31'
GROUP BY 1;

device_type		sessions	orders	conv_rate
desktop			98567		6562	0.0666
mobile			34265		795		0.0232
;

/*
********************
SEGMENT TWO ANLAYSIS:
*********************
	- Just under 3 years of business data analysis to present to potential investors. ‘2012-04-01’ to ‘2014-12-31’

2.1) To start I would like to show overall sales volume growth and basic revenue figures.
	- I pulled quarterly trending session and order volume, CVN rates, rev per order, and rev per session.

OUTPUT (Find Tableau Viz 2.1 linked in the README)
	- All our key metrics indicated significant growth! Particularly interesting is the increase in both revenue per order
		and revenue per session over the 3 years. This indicates the business is not only getting higher order volume, but also
		more items sold per order. I'll probably take a look at common cross selling products and repeat customers in future analyses.
-------------------------------------------------------------------------------------------------------------------------------------*/

SELECT
	YEAR(website_sessions.created_at) AS year,
    	QUARTER(website_sessions.created_at) AS qtr,
    	COUNT(website_sessions.website_session_id) AS sessions,
    	COUNT(order_id) AS orders,
   	 COUNT(order_id) / COUNT(website_sessions.website_session_id) AS conv_rate,
    	ROUND(SUM(price_usd) / COUNT(order_id), 2) AS rev_per_order,
	ROUND(SUM(price_usd) / COUNT(website_sessions.website_session_id), 2) AS rev_per_session
FROM
	website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2014-12-31'
GROUP BY 1,2;

Yr	Qtr	sessions	orders	conv_rate	rev_per_order	rev_per_session
2012	2	11433		347	0.0304		49.99		1.52
2012	3	16892		684	0.0405		49.99		2.02
2012	4	32266		1495	0.0463		49.99		2.32
2013	1	19833		1273	0.0642		52.14		3.35
2013	2	24745		1718	0.0694		51.54		3.58
2013	3	27663		1840	0.0665		51.73		3.44
2013	4	40540		2616	0.0645		54.72		3.53
2014	1	46779		3069	0.0656		62.16		4.08
2014	2	53129		3848	0.0724		64.37		4.66
2014	3	57141		4035	0.0706		64.49		4.55
2014	4	75434		5836	0.0774		63.80		4.94
;

/* -------------------------------------------------------------------------------------------------------------------------------------
2.2) Although the sales data shows significant growth, it's not clear that the brand itself has grown. Perhaps the majority of our sales
	are still from paid advertising. In order to show the brand has grown, we need to look at organic search and direct-type-in search volume.
    
    - I have pulled website traffic volume data for paid sessions (gsearch nonbrand, bsearch nonbrand, and brand_overall)
		and organic sessions (organic_search and direct_type_in). 
    
OUTPUT (Find Tableau Viz 2.2 linked in the README)
	- Terrific! It looks like our organic website search volume have grown at the same rate as our paid website taffic.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- Here I pulled all our website traffic JOINED to our orders data.

CREATE TEMPORARY TABLE channels
SELECT
	YEAR(website_sessions.created_at) as Yr,
    	QUARTER(website_sessions.created_at) as Qtr,
    	website_sessions.website_session_id,
    	utm_source,
    	utm_campaign,
    	http_referer,
    	order_id
FROM
	website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2014-12-31';
 
 SELECT * FROM channels;
    
-- Next I categorized out website traffic by paid/organic sources and grouped by quarter.

SELECT
	Yr,
    	Qtr,
    	COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS gsearch_nonbrand,
	COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN order_id ELSE NULL END) AS bsearch_nonbrand,
    	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN order_id ELSE NULL END) AS brand_overall,
    	COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN order_id ELSE NULL END) AS organic_search,
    	COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN order_id ELSE NULL END) AS direct_type_in
FROM
	channels
GROUP BY 1,2;

Yr		Qtr		gsearch_nonbrand	bsearch_nonbrand	brand_overall	organic_search	direct_type_in
2012	2		291					0					20				15				21
2012	3		482					82					48				40				32
2012	4		913					311					88				94				89
2013	1		766					183					108				125				91
2013	2		1114				237					114				134				119
2013	3		1132				245					153				167				143
2013	4		1657				291					248				223				197
2014	1		1667				344					354				338				311
2014	2		2208				427					410				436				367
2014	3		2259				434					432				445				402
2014	4		3207				679					606				594				525
;
    
/*-------------------------------------------------------------------------------------------------------------------------------------
2.3)	I want to follow up on the previous output we saw and run a product cross sell analysis.

OUTPUT (Find Tableau Viz 2.3 linked in the README)
	- Interesting. We see product #1 has by far the highest primary product order volume. This alone tells us we should focus our
		marketing campaigns around product 1. We also see product #4 cross sells the best for all the other products. Marketing should 
		display product #4 ads on the /cart pages of products 1-3.
	- These cross sell insights also support the brand growth story. As we introduce more products, the business will be able to 
		cross sell more and increase overall revenue.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- I started by pulling all primary product orders from the orders table, and JOINING to the order_items table to pull cross sold products.

CREATE TEMPORARY TABLE relevant_x_sell
SELECT
	orders.order_id,
    	primary_product_id,
    	order_item_id,
    	product_id AS x_sell_product
FROM
	orders LEFT JOIN order_items
	ON orders.order_id = order_items.order_id
    	AND order_items.is_primary_item = 0
WHERE
	orders.created_at BETWEEN '2012-04-01' AND '2014-12-31';
    
    SELECT * FROM relevant_x_sell;

-- Next I grouped by primary product and performed a COUNT to list out cross sold products

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
            
primary_product		total_orders	_xsold_p1	_xsold_p2	_xsold_p3	_xsold_p4	p1_xsell_rt		p2_xsell_rt		p3_xsell_rt		p4_xsell_rt
1			20490		0		693		1356		2414		0.0000			0.0338			0.0662			0.1178
2			3746		47		0		109		455		0.0125			0.0000			0.0291			0.1215
3			2382		206		82		0		489		0.0865			0.0344			0.0000			0.2053
4			143		5		2		3		0		0.0350			0.0140			0.0210			0.0000
;

/* -------------------------------------------------------------------------------------------------------------------------------------
2.4) Lastly I would like to take a look at repeat vs first visitors. How many repeat sessions are we getting and how well are they converting?
	I compared the two segments by total sessions, session-to-order conversion rate, and revenue-per-order.
    
OUTPUT (Find Tableau Viz 2.4 linked in the README)
	- The results indicates both excellent brand growth and value of repeat customers! Repeat session volume increased dramatically over the 
		3 years, and repeat session conversion rates display faster growth than first timers. These findings also support our brand growth story.
       		We should  think of incorporating a customer loyalty program to encourage repeat visitors to purchase more.
-------------------------------------------------------------------------------------------------------------------------------------*/

-- Here I pulled all website traffic data split between first time and repeat visitors.

CREATE TEMPORARY TABLE repeat_sessions_to_orders
SELECT
	YEAR(website_sessions.created_at) AS year,
    	QUARTER(website_sessions.created_at) AS quarter,
	website_sessions.website_session_id,
    	is_repeat_session,
    	order_id,
    	price_usd
FROM 
	website_sessions LEFT JOIN orders
	ON website_sessions.website_session_id = orders.website_session_id
WHERE
	website_sessions.created_at BETWEEN '2012-04-01' AND '2014-12-31';
    
SELECT * FROM repeat_sessions_to_orders;

-- Then I performed a COUNT of session volume and orders broken out by session type and grouped by quarters

SELECT
	year,
    	quarter,
    	COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS first_visit_sessions,
    	COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS first_visit_conv_rate,
    	ROUND(SUM(CASE WHEN is_repeat_session = 0 THEN price_usd ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN order_id ELSE NULL END),2) AS first_visit_rev_per_order,
    	COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_visit_sessions,
    	COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN order_id ELSE NULL END) /
		COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_visit_conv_rate,
    	ROUND(SUM(CASE WHEN is_repeat_session = 1 THEN price_usd ELSE NULL END) /
		 COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN order_id ELSE NULL END),2) AS repeat_visit_rev_per_order
FROM
	repeat_sessions_to_orders
GROUP BY 1,2;

Yr	Qtr		first_visit_sessions	first_visit_conv_rate	first_visit_rev_per_order	repeat_visit_sessions	repeat_visit_conv_rate	repeat_visit_rev_per_order
2012	2		10528			0.0285			49.99				905			0.0519			49.99
2012	3		15249			0.0392			49.99				1643			0.0530			49.99
2012	4		28895			0.0453			49.99				3371			0.0552			49.99
2013	1		16269			0.0625			52.28				3564			0.0718			51.59
2013	2		21429			0.0685			51.50				3316			0.0754			51.79
2013	3		23509			0.0651			51.72				4154			0.0746			51.80
2013	4		35075			0.0630			54.59				5465			0.0743			55.38
2014	1		38704			0.0619			62.16				8075			0.0832			62.18
2014	2		43471			0.0704			64.32				9658			0.0816			64.58
2014	3		46335			0.0693			64.60				10806			0.0764			64.07
2014	4		62250			0.0762			64.00				13184			0.0830			62.89
;
            
