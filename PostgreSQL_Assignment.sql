-- Active: 1747400461607@@127.0.0.1@5432@wildlife_conservation
-- Active: 1747400461607@@127.0.0.1@5432@postgres

-- Create Database
CREATE DATABASE wildlife_conservation;


-- Create table statement

CREATE TABLE rangers (
    ranger_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE species (
    species_id SERIAL PRIMARY KEY,
    common_name VARCHAR(100) NOT NULL,
    scientific_name VARCHAR(150) NOT NULL,
    discovery_date DATE NOT NULL,
    conservation_status VARCHAR(50) CHECK (
        conservation_status IN ('Endangered', 'Vulnerable', 'Critically Endangered', 'Least Concern', 'Historic')
    )
);

CREATE TABLE sightings (
    sighting_id SERIAL PRIMARY KEY,
    ranger_id INT NOT NULL,
    species_id INT NOT NULL,
    sighting_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(150) NOT NULL,
    notes TEXT,

    FOREIGN KEY (ranger_id) REFERENCES rangers(ranger_id) ON DELETE CASCADE,
    FOREIGN KEY (species_id) REFERENCES species(species_id) ON DELETE CASCADE
);


--  Insert Data in the the existing table

-- Insert into rangers
INSERT INTO rangers (name, region) VALUES
('Alice Green', 'Northern Hills'),
('Bob White', 'River Delta'),
('Carol King', 'Mountain Range');

-- Insert into species
INSERT INTO species (common_name, scientific_name, discovery_date, conservation_status) VALUES
('Snow Leopard', 'Panthera uncia', '1775-01-01', 'Endangered'),
('Bengal Tiger', 'Panthera tigris tigris', '1758-01-01', 'Endangered'),
('Red Panda', 'Ailurus fulgens', '1825-01-01', 'Vulnerable'),
('Asiatic Elephant', 'Elephas maximus indicus', '1758-01-01', 'Endangered');

-- Insert into sightings
INSERT INTO sightings (species_id, ranger_id, location, sighting_time, notes) VALUES
(1, 1, 'Peak Ridge', '2024-05-10 07:45:00', 'Camera trap image captured'),
(2, 2, 'Bankwood Area', '2024-05-12 16:20:00', 'Juvenile seen'),
(3, 3, 'Bamboo Grove East', '2024-05-15 09:10:00', 'Feeding observed'),
(1, 2, 'Snowfall Pass', '2024-05-18 18:30:00', NULL);

-- ////////....PostgreSQL Problems.........//

-- Register a new ranger with provided data with name = 'Derek Fox' and region = 'Coastal Plains'

INSERT INTO rangers (name, region)
VALUES ('Derek Fox', 'Coastal Plains');




-- Count unique species ever sighted.

SELECT COUNT(DISTINCT species_id) AS unique_species_count
FROM sightings;


-- Find all sightings where the location includes "Pass".

SELECT * FROM sightings WHERE location ILIKE '%Pass%';



--  List each ranger's name and their total number of sightings.

SELECT r.name, COUNT(s.sighting_id) AS total_sightings FROM rangers r
JOIN sightings s ON r.ranger_id = s.ranger_id GROUP BY r.name ORDER BY r.name;



-- List species that have never been sighted.

SELECT s.common_name FROM species s LEFT JOIN sightings si ON s.species_id = si.species_id
WHERE si.sighting_id IS NULL;



-- Show the most recent 2 sightings.
SELECT sp.common_name, si.sighting_time, r.name FROM sightings si
JOIN species sp ON si.species_id = sp.species_id
JOIN rangers r ON si.ranger_id = r.ranger_id ORDER BY si.sighting_time DESC LIMIT 2;


-- Update all species discovered before year 1800 to have status 'Historic'.

UPDATE species
SET conservation_status = 'Historic'
WHERE discovery_date < '1800-01-01';


-- Label each sighting's time of day as 'Morning', 'Afternoon', or 'Evening'.
-- Step-1: Create the Function
CREATE OR REPLACE FUNCTION get_time_of_day(s_time TIMESTAMP)
RETURNS TEXT AS $$
BEGIN
    IF EXTRACT(HOUR FROM s_time) < 12 THEN
        RETURN 'Morning';
    ELSIF EXTRACT(HOUR FROM s_time) BETWEEN 12 AND 17 THEN
        RETURN 'Afternoon';
    ELSE
        RETURN 'Evening';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Step 2 Use the function for geeting result
SELECT sighting_id, get_time_of_day(sighting_time) AS time_of_day
FROM sightings;











