import pandas as pd

df = pd.read_parquet('..\data\yellow_tripdata_2023-12.parquet', engine='pyarrow')
df['day_of_week'] = df['tpep_pickup_datetime'].dt.day_of_week
df['hour_of_day'] = df['tpep_pickup_datetime'].dt.hour
df.to_csv('..\data\yellow_tripdata_2023-12.csv', index=False)

df = pd.read_parquet('..\data\yellow_tripdata_2024-01.parquet', engine='pyarrow')
df['day_of_week'] = df['tpep_pickup_datetime'].dt.day_of_week
df['hour_of_day'] = df['tpep_pickup_datetime'].dt.hour
df.to_csv('..\data\yellow_tripdata_2024-01.csv', index=False)

df = pd.read_parquet('..\data\yellow_tripdata_2024-02.parquet', engine='pyarrow')
df['day_of_week'] = df['tpep_pickup_datetime'].dt.day_of_week
df['hour_of_day'] = df['tpep_pickup_datetime'].dt.hour
df.to_csv('..\data\yellow_tripdata_2024-02.csv', index=False)
