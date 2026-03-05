# ใช้ข้อมูล 100,000 rows (2024-present)
api_url = "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$limit=100000&$where=year>=2024"
response = requests.get(api_url)
df = pd.read_csv(io.StringIO(response.text))

# ทำการ clean data และ แปลง format columns
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_')
df['date'] = pd.to_datetime(df['date'])
df


# ingesting to Postgresql
with engine.begin() as conn:
    df.to_sql('crime_data', con=conn, if_exists='replace', index=False)

print(f"Task 1 Complete: Successfully loaded {len(df)} rows into 'crime_data' table.")
