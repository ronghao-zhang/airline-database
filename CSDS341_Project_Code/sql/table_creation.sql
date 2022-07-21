/* Author: Luke Zhang, Jiamu Zhang, Quynh Nguyen
 * Purpose: To create tables in the airline querying database
 * Last Edited: 2022-07-18
 */

CREATE SCHEMA IF NOT EXISTS airline; 
USE airline;

CREATE TABLE IF NOT EXISTS Travelers (
    user_id INT NOT NULL,
    first_name VARCHAR(50),
    middle_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    dob DATE,
    credits INT DEFAULT 0,
    passport_no VARCHAR(20),
    citizenship VARCHAR(30),
    PRIMARY KEY (user_id),
    CHECK (gender IN ('M' , 'F', 'U'))
);

CREATE TABLE IF NOT EXISTS Crew (
    user_id INT NOT NULL,
    first_name VARCHAR(50),
    middle_name VARCHAR(50),
    last_name VARCHAR(50),
    gender CHAR(1),
    dob DATE,
    ssn INT NOT NULL,
    salary DOUBLE,
    total_distance INT,
    PRIMARY KEY (user_id),
    CHECK (gender IN ('M' , 'F', 'U'))
);

CREATE TABLE IF NOT EXISTS Airports (
    iata_code CHAR(3) NOT NULL,
    airport_name VARCHAR(100), 
    country CHAR(2),
    weather VARCHAR(30),
    airport_status VARCHAR(30),
    PRIMARY KEY (iata_code),
    CHECK (weather IN ('Sunny' , 'Mostly Sunny',
        'Partly Cloudy',
        'Cloudy',
        'Rainy',
        'Heavy Rainy',
        'Foggy',
        'Snowy',
        'Heavy Snowy',
        'Frost')),
    CHECK (airport_status IN ('Free', 'Normal',
        'Busy',
        'Small-Scale Delay',
        'Large-Scale Delay'))
);

CREATE TABLE IF NOT EXISTS Airlines (
    company_id INT NOT NULL,
    company_name VARCHAR(50),
    PRIMARY KEY (company_id)
);

CREATE TABLE IF NOT EXISTS Schedules (
    schedule_id INT NOT NULL,
    dept_date DATE,
    dept_time TIME,
    ariv_date DATE, 
    ariv_time TIME,
    PRIMARY KEY (schedule_id)
);

CREATE TABLE IF NOT EXISTS Aeroplanes_belong (
    regis_no VARCHAR(10) NOT NULL,
    fir_capacity INT,
    bus_capacity INT,
    eco_capacity INT,
    aircraft_type VARCHAR(50),
    company_id INT NOT NULL,
    PRIMARY KEY (regis_no),
    FOREIGN KEY (company_id)
        REFERENCES Airlines(company_id)
);

CREATE TABLE IF NOT EXISTS Flights_ariv_dept (
    regis_no VARCHAR(10) NOT NULL,
    flight_no VARCHAR(7) NOT NULL,
    flight_status VARCHAR(10),
    dept_iata_code CHAR(3) NOT NULL,
    ariv_iata_code CHAR(3) NOT NULL,
    PRIMARY KEY (regis_no, flight_no),
    FOREIGN KEY (regis_no)
        REFERENCES Aeroplanes_belong(regis_no),
    FOREIGN KEY (dept_iata_code)
        REFERENCES Airports(iata_code),
    FOREIGN KEY (dept_iata_code)
        REFERENCES Airports(iata_code),
    CHECK (flight_status IN ('On-Time' , 'Delay', 'Cancel'))
);

CREATE TABLE IF NOT EXISTS Tickets_book_for (
    ticket_id INT NOT NULL,
    seat_location CHAR(4),
    seat_class CHAR(1),
    luggage_no INT,
    regis_no VARCHAR(10) NOT NULL,
    flight_no VARCHAR(7) NOT NULL,
    traveler_id INT NOT NULL,
    PRIMARY KEY (ticket_id),
    FOREIGN KEY (traveler_id)
        REFERENCES Travelers(user_id),
	FOREIGN KEY (regis_no, flight_no)
        REFERENCES Flights_ariv_dept(regis_no, flight_no),
    CHECK (seat_class IN ('F' , 'B', 'E'))
);

CREATE TABLE IF NOT EXISTS serve (
    crew_id INT NOT NULL,
    regis_no VARCHAR(10) NOT NULL,
    flight_no VARCHAR(7) NOT NULL,
    PRIMARY KEY (crew_id , regis_no , flight_no),
    FOREIGN KEY (crew_id)
        REFERENCES Crew(user_id),
    FOREIGN KEY (regis_no, flight_no)
        REFERENCES Flights_ariv_dept(regis_no, flight_no)
);

CREATE TABLE IF NOT EXISTS assign (
    regis_no VARCHAR(10) NOT NULL,
    flight_no VARCHAR(7) NOT NULL,
    schedule_id INT NOT NULL,
    PRIMARY KEY (regis_no , flight_no , schedule_id),
    FOREIGN KEY (regis_no, flight_no)
        REFERENCES Flights_ariv_dept(regis_no, flight_no),
    FOREIGN KEY (schedule_id)
        REFERENCES Schedules(schedule_id)
);

CREATE TABLE IF NOT EXISTS hub (
    company_id INT NOT NULL,
    iata_code CHAR(3) NOT NULL,
    PRIMARY KEY (company_id , iata_code),
    FOREIGN KEY (company_id)
        REFERENCES Airlines(company_id),
    FOREIGN KEY (iata_code)
        REFERENCES Airports(iata_code)
);

/* tables can be dropped in the following order */
# DROP TABLE hub;
# DROP TABLE assign;
# DROP TABLE serve;
# DROP TABLE Tickets_book_for;
# DROP TABLE Flights_ariv_dept; 
# DROP TABLE Aeroplanes_belong;
# DROP TABLE Travelers; 
# DROP TABLE Crew; 
# DROP TABLE Airports; 
# DROP TABLE Airlines;
# DROP TABLE Schedules;
