<H2>Ecommerce Company Performance Analysis</H2>

**[Brief]** <H3> Brief </H3>

Maven Analytics created a fictitious eCommerce retail company named
Maven Factory with a database storing 3 years of business data. I will
pretend to be a data analyst to investigate their performance and offer
some recommendations based on my findings.


I will split up the analyses into two sections:

1)  First 18 months: '2012-04-01' to '2013-09-31'

2)  Full \~ 3 years : '2012-04-01' to '2014-12-31'


I have commented throughout my SQL scripts to show my analytical thought
process.

-   Most of the data outputs will be trending on a quarterly basis to
    maintain a reasonable frame size of data


**For the first 18 months of data (SEGMENT 1), I investigated exploratory
trends including:**

-   Trending website traffic, orders, and session-to-order conversion
    rates

-   Trending website traffic and sales broken out by advertising
    campaigns

-   Hour of day sales analysis

-   Website pages funnel analysis

-   Landing page click through rate analysis

-   Device type sales comparison


**For the full \~ 3 years of data (SEGMENT 2), I provided some
comprehensive analysis that the company owner might present to investors
to demonstrate long term growth. Analyses include:**

-   Trending website traffic, orders, conversion rates, revenue per
    order, and revenue per session

-   Trending organic search volume vs. paid search volume

-   Product cross sell analysis

-   Trending for repeat vs. first time website visitors on sessions,
    order conversion rate, and revenue per visit


**[Data Set]**

-   6-table relational database schema -- [see
    here.](Maven_SQL_project/Maven_Factory_Database_Schema.pdf)

-   Maven Factory database SQL file-- [see
    here.](Maven_SQL_project/mavenfactory_vApril2022.sql)


**[Tools]**

-   MySQL -- [view SQL
    scripts](https://github.com/nickrspence/eCommerce-company-performance-analysis/blob/main/FINAL_maven_sql_project.sql)

-   Tableau for data visualization


**[Tableau Visualizations]**


-   [SEGMENT 1 dashboard
    here](https://public.tableau.com/shared/5N4D4Y2JF?:display_count=n&:origin=viz_share_link)[SEGMENT
    2 dashboard
    here](https://public.tableau.com/views/Maven_Dashboard_2/Segment2?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

-   Refer to the SQL script for visualization reference numbers:

    -   [Query 1.1 viz
        here](https://public.tableau.com/views/Viz_1_1_16886685366820/Salesvolumebroad_DATE?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 1.2 viz
        here](https://public.tableau.com/views/Viz_1_2_16886686023040/Salesvolumebycampaign_DATE?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 1.3 viz
        here](https://public.tableau.com/views/Maven_Viz_1_3/Hourlysessionsconv?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 1.4 viz
        here](https://public.tableau.com/views/Maven_Viz_1_4/Websitefunnelanalysis?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 2.1 viz
        here](https://public.tableau.com/views/Maven_Viz_2_1/Wholesalessummary?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 2.2 viz
        here](https://public.tableau.com/views/Maven_Viz_2_2/Relativeorganicsearchvolume?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 2.3 viz
        here](https://public.tableau.com/views/Maven_Viz_2_3/Crosssellanalysis?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)

    -   [Query 2.4 viz
        here](https://public.tableau.com/views/Maven_Viz_2_4/Repeatvisitors?:language=en-US&publish=yes&:display_count=n&:origin=viz_share_link)
