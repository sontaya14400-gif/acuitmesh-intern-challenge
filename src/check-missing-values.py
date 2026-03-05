total_rows = len(df)
print(f"Total Rows: {total_rows} ")

missing_locations = df[(df['latitude'].isnull()) | (df['longitude'].isnull())]
missing_locations_total = len(missing_locations)
print(f"Missing locations total: {missing_locations_total}")

missing_locations_percentage = (missing_locations_total / total_rows) * 100
print(f"Missing Values = {missing_locations_percentage:.2f}%")