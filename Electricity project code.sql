-- Nigeria Energy Infrastructure & Electricity Access Analysis

CREATE TABLE `grid_infrastructure_new` (
  `ï»¿infrastructure_id` text,
  `type` text,
  `name` text,
  `state` text,
  `voltage_kv` int DEFAULT NULL,
  `length_km` double DEFAULT NULL,
  `commissioning_year` int DEFAULT NULL,
  `status` text,
  `capacity_mva` text,
  `plant_type` text,
  `capacity_mw` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `state_electricity_new` (
  `state_name` text,
  `year` int DEFAULT NULL,
  `total_access_pct` double DEFAULT NULL,
  `rural_access_pct` double DEFAULT NULL,
  `urban_access_pct` double DEFAULT NULL,
  `urban_population_pct` int DEFAULT NULL,
  `adjustment_factor` double DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

alter table grid_infrastructure_new
rename column ï»¿infrastructure_id TO infrastructure_id;

update grid_infrastructure_new
set
    infrastructure_id = TRIM(infrastructure_id),
    `type` = TRIM(`type`),
    `name` = TRIM(`name`),
    state = TRIM(state),
    `status` = TRIM(`status`),
    plant_type = TRIM(plant_type);

update grid_infrastructure_new
set plant_type = 'Not Applicable'
where plant_type is null;

UPDATE state_electricity_new
SET state_name = TRIM(state_name);

select *
from state_electricity_new;

select *
from grid_infrastructure_new;

select
    infrastructure_id,
    COUNT(*) AS duplicate_count
from grid_infrastructure_new
group by infrastructure_id
having COUNT(*) > 1;

select distinct state_name
from state_electricity_new
order by state_name;

select distinct state
from grid_infrastructure_new
order by state;

select state.state_name, grid.state
from state_electricity_new as state
left join grid_infrastructure_new as grid
on state.state_name = grid.state
where grid.state is null;

select *
from grid_infrastructure_new
where `type` = 'power_plant';

-- Arranging my tables for visualization

select state, round(sum(capacity_mw), 2) total_power_generated_mw
from grid_infrastructure_new
where `type` = 'power_plant'
group by state
order by total_power_generated_mw desc;

select state, round(sum(capacity_mva), 2) total_substation_capacity_mva
from grid_infrastructure_new
where `type` = 'substation'
group by state
order by total_substation_capacity_mva desc;

select state, round(sum(length_km), 2) total_transmission_length_km
from grid_infrastructure_new
where `type` = 'transmission_line'
group by state
order by total_transmission_length_km desc;

select state, plant_type, count(*) as plant_count
from grid_infrastructure_new
where `type` = 'power_plant'
group by state, plant_type
order by state, plant_count desc;

SELECT state, avg(voltage_kv) AS avg_voltage_kv
FROM grid_infrastructure_new
where voltage_kv is not null
GROUP BY state
order by avg_voltage_kv desc;


create view Electricity_generation_summary as 
select state, 
group_concat(distinct plant_type separator ', ') plant_type,
round(sum(case when `type` = 'power_plant' then capacity_mw else 0 end), 2) power_generated_mw,
round(sum(case when `type` = 'substation' then capacity_mva else 0 end), 2) generated_mva,
round(sum(case when `type` = 'transmission_line' then length_km else 0 end), 2) transmission_length_km,
count(case when `type` = 'power_plant' then 1 end) plant_count,
count(case when `type` = 'substation' then 1 end) substation_count,
count(case when `type` = 'transmission_line' then 1 end) transmission_count 
from grid_infrastructure
group by `state`;

select *
from Electricity_generation_summary;

-- Joining tables
create view nigeria_energy_analysis AS
select
    a.state_name,
    a.`year`,
    a.total_access_pct,
    a.rural_access_pct,
    a.urban_access_pct,

    b.plant_type,
    b.power_generated_mw,
    b.generated_mva,
    b.transmission_length_km

from state_electricity_new a
join Electricity_generation_summary b
on a.state_name = b.state;

select *
from nigeria_energy_analysis;












