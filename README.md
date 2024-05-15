# imply-excerise
Repo created to share Imply's take home exercise results

Following are the steps executed. For this excerise have used Oracle and Python

Step 1: Download the trip data of Dec-2023, Jan-2024, Feb-2024 (files inside "data" folder) and data dictionary to create necessary reference data (files inside "reference-data" folder).

Step 2: Install Oracle XE (Windows 10)

Step 3: Connect to oracle xe instance via cli "sqlplus / as sysdba" or via DBeaver as sysdba and execute "oracle-post-installation-queries.sql" sql script. This script does the following;
        a. Enable container / pluggable DB which allows to create user without ##
        b. Create tablespace with initial size and enabling autoextend option.
        c. Create user with above created tablespace as default
        d. Grants DBA privilage to the newly created user. Have went with full permissions for this excerise to avoid any delays.

Step 4: Intall Python v3.12.3, pip v24.0, Numpy, Pandas & Pyarrow

Step 5: Excute the python script "parquet-to-csv-transformation.py". This is simple ETL script which does following
        a. Read the paraquet trip data files using pyarrow library into a pandas dataframe.
        b. Add two new columns called "day_of_week" and "hour_of_day" to the pandas dataframe.
        c. Write the pandas dataframe to csv file which will be used to load into oracle table.

Step 6: Connect to oracle xe instance using newly created user (in Step 3) and run the following sql scripts located in "oracle-ddls" folder
        a. YT_DD_LOCANDZONES.sql    -- This script creates the table for location and zones (PULOC & DOLOC ID's)
        b. YT_DD_PAYTYPE.sql        -- This script creates the table for payment types 
        c. YT_DD_RATECODEID.sql     -- This script creates the table for ratecodes
        d. YT_DD_VENDOR.sql         -- This script creates the table for vendor details
        e. YT_TRIP_DATA.sql         -- This script creates the table to load the transformed trip data in Step 5
            This table is created with daily paritions for better performance. If there will be dip in performance then following can be done.
                i.   Add subpartitions based on ratecode / payment type
                ii.  Create composite indices on the necessary columns for optimal performance.
                iii. Use parallel hints with degree's 8 to 32 to better the performance.
                iv.  Gather stats on table to reduce the defragmentation; move the table to different tablespace with sufficient ini and max trans options; Split the data into multiple tables etc...

Step 7: Open command prompt and execute the commands from "sqlldr-commands.txt" file inside "oracle-sqlldr-to-load-trip-data" folder to the newly created table (Step 6.e). These are simple sqlldr commands to load data in parallel for faster loading and skipping headers.

Step 8: This is the start of excerise:- Execute the scripts via sqlplus or GUI tool like DBeaver. Recommend DBeaver for better viewing of results.
    
    a. Execute "TOP_5_BUSIEST_HOURS_OF_WEEK.sql" to produce the result of top 5 busiest hours per week. Sample output "TOP_5_BUSIEST_HOURS_OF_WEEK.PNG" is placed in "sample-outputs" folder. In this query have used the CTEs (temp tables) of oracle to reduce the number of reads from main table and RANK function to rank the results based on total trips. 
    Results show,
        i.   The start date of the week as 1st column
        ii.  Week number of the year as 2nd column
        iii. Busiest hour in 24 format as 3rd column
        iv.  Total count of trips sorted in descending order.

    b. Execute "AVG_FARE_AMT_PER_MILE.sql" to produce the result of average fare amout per mile. Sample output "AVG_FARE_AMT_PER_MILE.PNG" is placed in "sample-outputs" folder. In this query have used the CTE's and filtered out the "No charge" trips to avoid difference. If required, further finetuning can be done based on ratecodes, hour (peak & off-peak) etc... 
    Results show,
        i.   Rate code as 1st column
        ii.  Day number of week as 2nd column. For example Monday as 1, Tuesday as 2, etc...
        iii. Hour in 24 format as 3rd column
        iv.  Total fare amount as 4th column.
        v.   Total distance as 5th column.
        vi.  Average fare amount per mile which is 4th / 5th column as 6th column.

    c. Execute "SHORTEST-PATH-BETWEEN-PU-DO.sql" to produce the result of shortest path between pick up and drop off 's. Sample output "SHORTEST-PATH-BETWEEN-PU-DO.PNG" is placed in "sample-outputs" folder. This query produces the results based on weekly bases with simple min and max of trip distance between PULOC and DOLOC. If required, further improvement / enhancements can be done by adding oracel's spatial analytical capabilities to plot in the graph.
    Results show,
        i.   The start date of the week as 1st column
        ii.  Pick up location name (after joning with reference data) as 2nd column
        iii. Drop off location name (after joning with reference data) as 3rd column
        iv.  Shortest path taken by the taxi in that week between two locations as 4th column.
        v.   Longest path taken by the taxi in that week between same two locations as 5th column.

    d. Execute "AVG_TIP_AMOUNT_PAYTYPE.sql" to produce the result the percentage of tip and average tip per payment type. Sample output "AVG_TIP_AMOUNT_PAYTYPE.PNG" is placed in "sample-outputs" folder. This query produces results on daily basis per payment type. This requirement needs to be discussed further, feels incomplete can be done more / enhanced.
    Results show,
        i.   The trip start date as 1st column
        ii.  Payment type (after joining with reference data) as 2nd column
        iii. Trip counts on that day based on payment type as 3rd column
        iv.  Tips on that day based on payment type as 4th column 
        v.   Precentage of tip for that particular payment type out of total tips as 5th column. Majority (95% to 99%) of customer pays tips when they pay bill via credit card.
        vi.  Average tip per trip on that day for that particular payment type as 6th column.

    e. Execute "TOP-10-PERC-EARNINGS-v1.0.sql" to produce the result of top 10 earnings per vendor per month per fare amount and tip amount. Sample output "TOP-10-PERC-EARNINGS-v1.0.PNG" is placed in "sample-outputs" folder. This query produces results on monthly basis. This requirement is not so clear needs further discussion to understand better for better results production. Requirement definitely needs enhancement
    Results show,
        i.   The start date of the month as 1st column
        ii.  Vendor description (after joining with reference data) as 2nd column
        iii. Fare amount as 3rd column
        iv.  Tip amount as 4th column 
        v.   Total amount as reference as 5th column.
        vi.  Percentile_cnt (10 percentile ranking) on total amount as 6th column.
        vii. Rank based on percentile sorted on fare amount and tip amount partitioned on total amount as 7th column. If filtered on this column for only first 10 rows per set then that will give the near required results, something like top 10 earnings of the vendor for top 10 fare amount and tip amounts