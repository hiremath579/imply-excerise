WITH DAILY_TOTALS AS
(
SELECT TRUNC(TPEP_PICKUP_DATETIME) AS TRIP_DATE, COUNT(1) AS TRIP_COUNT, SUM(TIP_AMOUNT) AS TOTAL_TIPS FROM YT_TRIP_DATA 
WHERE trunc(TPEP_PICKUP_DATETIME, 'MM') >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -4)
GROUP BY TRUNC(TPEP_PICKUP_DATETIME)
),
DAILY_PAYTYPE_TOTALS AS
(
SELECT TRUNC(td.TPEP_PICKUP_DATETIME) AS TRIP_DATE, NVL(pt.PAYTYPE_DESCRIPTION, td.PAYMENT_TYPE) AS PAYMENT_TYPE, COUNT(1) AS TRIP_COUNT, SUM(td.TIP_AMOUNT) AS TOTAL_TIPS 
FROM YT_TRIP_DATA td
LEFT OUTER JOIN YT_DD_PAYTYPE pt
ON td.PAYMENT_TYPE = pt.PAYTYPE_ID
WHERE trunc(td.TPEP_PICKUP_DATETIME, 'MM') >= ADD_MONTHS(TRUNC(SYSDATE, 'MM'), -4)
GROUP BY TRUNC(td.TPEP_PICKUP_DATETIME), NVL(pt.PAYTYPE_DESCRIPTION, td.PAYMENT_TYPE)
)
SELECT 
NVL(DT.TRIP_DATE, PTT.TRIP_DATE) AS TRIP_DATE,
PTT.PAYMENT_TYPE,
PTT.TRIP_COUNT,
PTT.TOTAL_TIPS,
ROUND((PTT.TOTAL_TIPS/DT.TOTAL_TIPS) * 100, 2) AS PERCENTAGE_TIPS,
ROUND((PTT.TOTAL_TIPS/PTT.TRIP_COUNT), 2) AS AVG_TIPS
FROM DAILY_TOTALS DT
FULL OUTER JOIN DAILY_PAYTYPE_TOTALS PTT
ON DT.TRIP_DATE = PTT.TRIP_DATE
ORDER BY 1, 2
;