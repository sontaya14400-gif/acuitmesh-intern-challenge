-- 1. สร้าง Time-series Index (B-Tree)
CREATE INDEX IF NOT EXISTS idx_crime_date ON crime_data (date DESC);

-- 2. สร้าง Index สำหรับ Filter ที่ใช้บ่อย (Type, District)
CREATE INDEX IF NOT EXISTS idx_crime_type_district ON crime_data (primary_type, district);

-- 3. เพิ่มคอลัมน์ Geometry สำหรับ PostGIS (SRID 4326)
ALTER TABLE crime_data ADD COLUMN IF NOT EXISTS geom GEOMETRY(Point, 4326);

-- 4. แปลงข้อมูล Latitude/Longitude ให้อยู่ในรูป Geometry Object
UPDATE crime_data
SET geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL AND longitude IS NOT NULL;

-- 5. สร้าง Geospatial Index (GiST)
CREATE INDEX IF NOT EXISTS idx_crime_geom ON crime_data USING GIST (geom);
