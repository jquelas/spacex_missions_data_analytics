-- CREACIÓN DE TABLA E IMPORTACIÓN DE DATOS

-- Se crea base de datos
create database spacex_missions;

-- Nos situamos dentro de la nueva base de datos creada
use spacex_missions; 

-- En este punto se importa la tabla spacex_missions en formato CSV

-- Verificamos que la tabla fue importada correctamente
select * from spacex_missions;

-- ARMADO DE TABLA Dragon_Missions

-- Se verifican los datos a aislar en una nueva tabla
select Flight_Number, 
	   Launch_Date, 
	   Payload, 
	   Dragon_Model, 
	   Re_Used_Dragon_Module, 
	   Orbit 
	   from spacex_missions where Exclusive_Dragon_Mass = 'Yes';

-- Se crea la tabla Dragon_Missions
create table Dragon_Missions 
(
Dragon_Mission_ID int not null identity(1,1),
Flight_Number varchar(10) not null,
Launch_Date datetime not null,
Payload_Name varchar(100) not null,
Dragon_Model varchar(50),
Re_Used_Dragon_Module varchar(10),
Orbit varchar(100),
primary key (Dragon_Mission_ID)
);

-- Se insertan datos obtenidos del select
insert into Dragon_Missions (Flight_Number,
							Launch_Date, 
							Payload_Name, 
							Dragon_Model, 
							Re_Used_Dragon_Module, 
							Orbit) 
							select Flight_Number, 
								   Launch_Date, 
								   Payload, 
								   Dragon_Model, 
								   Re_Used_Dragon_Module, 
								   Orbit 
							from spacex_missions where Exclusive_Dragon_Mass = 'Yes';

-- Se verifica que los datos fueron correctamente insertados
select * from Dragon_Missions; 

-- ARMADO DE TABLA Launch_Outcome

-- Se verifican los datos a aislar en una nueva tabla
select distinct Launch_Outcome, Failure_Type from spacex_missions;

-- Se crea la tabla Launch_Outcome
create table Launch_Outcome 
(
Outcome_ID int not null identity(1,1), 
Outcome varchar(20) not null,
Failure_Type varchar(100),
primary key (Outcome_ID)
);

-- Se insertan datos obtenidos del select
insert into Launch_Outcome (Outcome, Failure_Type) 
select distinct Launch_Outcome, Failure_Type from spacex_missions;

-- Se verifica que los datos fueron correctamente insertados
select * from Launch_Outcome; 

-- ARMADO DE TABLA Landing_Outcome

-- Se verifican los datos a aislar en una nueva tabla
select distinct Landing_Result, Booster_Landing from spacex_missions;

-- Se crea la tabla Landing_Outcome
create table Landing_Outcome 
(
Landing_ID int not null identity(1,1), 
Landing_Result varchar(20) not null,
Booster_Landing varchar(100),
primary key (Landing_ID)
);

-- Se insertan datos obtenidos del select
insert into Landing_Outcome (Landing_Result, Booster_Landing) 
select distinct Landing_Result, Booster_Landing from spacex_missions;

-- Se verifica que los datos fueron correctamente insertados
select * from Landing_Outcome; 

-- ARMADO DE TABLA Customers

-- Se verifican los datos a aislar en una nueva tabla
select distinct Customer from spacex_missions;

-- Se crea la tabla Customers
create table Customers 
(
Customer_ID int not null identity(1,1), 
Customer varchar(100) not null,
primary key (Customer_ID)
);

-- Se insertan datos obtenidos del select
insert into Customers (Customer) 
select distinct Customer from spacex_missions;;

-- Se verifica que los datos fueron correctamente insertados
select * from Customers; 

-- ARMADO DE TABLA Launch_Facility

-- Se verifican los datos a aislar en una nueva tabla
select distinct Launch_Site, Launch_Facility from spacex_missions;

-- Se crea la tabla Launch_Facility
create table Launch_Facility
(
Facility_ID int not null identity(1,1), 
Launch_Site varchar(20) not null,
Facility varchar (20),
primary key (Facility_ID)
);

-- Se insertan datos obtenidos del select
insert into Launch_Facility (Launch_Site, Facility) 
select distinct Launch_Site, Launch_Facility from spacex_missions;

-- Se verifica que los datos fueron correctamente insertados
select * from Launch_Facility; 

-- ARMADO DE TABLA Launcher_Version

-- Se verifican los datos a aislar en una nueva tabla
select distinct Launcher_Version, Re_used_Launcher, Boosters_Version from spacex_missions;

-- Se crea la tabla Launcher_Version
create table Launcher_Version 
(
Launcher_ID int not null identity(1,1),
Launcher_Version varchar(20) not null,
Re_Used_Launcher varchar(10),
Booster_Version varchar(10),
primary key (Launcher_ID)
);

-- Se insertan datos obtenidos del select
insert into Launcher_Version (Launcher_Version, Re_Used_Launcher, Booster_Version) 
select distinct Launcher_Version, Re_used_Launcher, Boosters_Version from spacex_missions;

-- Se verifica que los datos fueron correctamente insertados
select * from Launcher_Version; 

-- ARMADO DE TABLA Payload_Application

-- Se verifican los datos a aislar en una nueva tabla
select distinct Payload_Application from spacex_missions;

-- Se crea la tabla Payload_Application
create table Payload_Application 
(
Application_ID int not null identity(1,1), 
Payload_Application varchar(50) not null,
primary key (Application_ID)
);

-- Se insertan datos obtenidos del select
insert into Payload_Application 
select distinct Payload_Application from spacex_missions;

-- Se verifica que los datos fueron correctamente insertados
select * from Payload_Application; 

-- ARMADO DE TABLA Missions

-- Se modifica la tabla spacex_missions para agregar nuevos campos
alter table spacex_missions add Application_ID int, 
								Customer_ID int, 
								Outcome_ID int, 
								Facility_ID int, 
								Landing_ID int, 
								Launcher_ID int; 

-- Se actualiza la tabla con los nuevos datos sacados de las nuevas tablas
update spacex_missions set spacex_missions.Application_ID =  
(
select Application_ID from Payload_Application 
where spacex_missions.Payload_Application = Payload_Application.Payload_Application
);

update spacex_missions set spacex_missions.Customer_ID = 
(
select Customer_ID from Customers 
where spacex_missions.Customer = Customers.Customer
);

update spacex_missions set spacex_missions.Outcome_ID = 
(
select Outcome_ID from Launch_Outcome 
where spacex_missions.Launch_Outcome = Launch_Outcome.Outcome
);

update spacex_missions set spacex_missions.Facility_ID = 
(
select Facility_ID from Launch_Facility 
where spacex_missions.Launch_Site = Launch_Facility.Launch_Site
);

update spacex_missions set spacex_missions.Landing_ID = 
(
select Landing_ID from Landing_Outcome 
where spacex_missions.Landing_Result = Landing_Outcome.Landing_Result 
and spacex_missions.Booster_Landing = Landing_Outcome.Booster_Landing
);

update spacex_missions set spacex_missions.Launcher_ID = 
(
select Launcher_ID from Launcher_Version 
where spacex_missions.Launcher_Version = Launcher_Version.Launcher_Version 
and spacex_missions.Boosters_Version = Launcher_Version.Booster_Version
);

-- Se verifica el agregado de los datos a las nuevas columnas
select * from spacex_missions; 

-- Se crea la tabla Missions
create table Missions 
(
Mission_ID int not null identity(1,1),
Flight_Number varchar(10) not null,
Launch_Date datetime not null,
Payload varchar(100) not null,
Payload_Application_ID int,
Payload_Quantity int not null,
Payload_Mass_kg int not null,
Orbit varchar(100) not null,
Dragon_Mission_ID int,
Customer_ID int,
Outcome_ID int,
Facility_ID int,
Landing_ID int,
Launcher_ID int,
primary key (Mission_ID),
foreign key (Payload_Application_ID) references Payload_Application(Application_ID),
foreign key (Dragon_Mission_ID) references Dragon_Missions(Dragon_Mission_ID),
foreign key (Customer_ID) references Customers(Customer_ID),
foreign key (Outcome_ID) references Launch_Outcome(Outcome_ID),
foreign key (Facility_ID) references Launch_Facility(Facility_ID),
foreign key (Landing_ID) references Landing_Outcome(Landing_ID),
foreign key (Launcher_ID) references Launcher_Version(Launcher_ID)
);

-- Se insertan datos obtenidos del select
insert into Missions(Flight_Number, 
					 Launch_Date, 
					 Payload, 
					 Payload_Application_ID, 
					 Payload_Quantity, 
					 Payload_Mass_kg, 
					 Orbit, 
					 Customer_ID, 
					 Outcome_ID, 
					 Facility_ID, 
					 Landing_ID, 
					 Launcher_ID) 
					 select Flight_Number, 
							Launch_Date, 
							Payload, 
							Application_ID, 
							Payload_Quantity, 
							Payload_Mass_kg, 
							Orbit, 
							Customer_ID, 
							Outcome_ID, 
							Facility_ID, 
							Landing_ID, 
							Launcher_ID 
							from spacex_missions;

-- Se actualiza la tabla Missions con los datos de la tabla Dragon_Missions
update Missions set Missions.Dragon_Mission_ID = 
(
select Dragon_Mission_ID from Dragon_Missions where Missions.Payload = Dragon_Missions.Payload_Name
);

-- Se verifican que los datos fueron correctamente insertados/actualizados en la tabla Missions
select * from Missions;