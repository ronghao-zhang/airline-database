/* Author: Luke Zhang, Jiamu Zhang, Quynh Nguyen
 * Purpose: To create tables in the airline querying database
 * Last Edited: 2022-07-18
 */
 
CREATE TABLE Travelers(
	user_id        int NOT NULL, 
    first_name     varchar(50),
    middle_name    varchar(50),
    last_name      varchar(50),
    gender         char(1), 
    dob            date,
    credits        int DEFAULT 0, 
    passport_no    varchar(20), 
    citizenship    varchar(30),
    PRIMARY KEY (user_id), 
    CHECK (gender in('M','F','U'))
);

CREATE TABLE Crew(
	user_id        int NOT NULL, 
    first_name     varchar(50),
    middle_name    varchar(50),
    last_name      varchar(50),
    gender         char(1), 
    dob            date,
    ssn            int NOT NULL,
    salary         double, 
    total_distance int, 
	PRIMARY KEY (user_id), 
    CHECK (gender in('M','F','U'))
);

CREATE TABLE Tickets_book_for(
	ticket_id      int NOT NULL,
    seat_location  char(4),
    seat_class     char,
    luggage_no     int,
    regis_no       varchar(10) NOT NULL, 
    flight_no      varchar(7) NOT NULL,
	PRIMARY KEY (ticket_id), 
    FOREIGN KEY (traveler_id) references Travelers.traveler_id,
    FOREIGN KEY (regis_no) references Aeroplanes_belong.regis_no,
    FOREIGN KEY (flight_no) references Flights_ariv_dept.flight_no, 
    CHECK (seat_class in ('First', 'Business', 'Economic'))
);

CREATE TABLE Airports(
	iata_code      char(3) NOT NULL,
    weather        char, 
    temperature    int,
    airport_status char,
    PRIMARY KEY (iata_code),
    CHECK (weather in ('Sunny', 'Mostly Sunny', 'Partly Cloudy', 'Cloudy', 'Rainy', 'Heavy Rainy', 'Foggy', 'Snowy', 'Heavy Snowy','Frost')),
    CHECK (airport_status in ('Free', 'Normal', 'Busy', 'Small-Scale Delay', 'Large-Scale Delay'))
);

CREATE TABLE Airlines(
	company_id     int NOT NULL,
	company_name   varchar(30), 
    PRIMARY KEY (company_id)
); 

CREATE TABLE Aeroplanes_belong(
	regis_no       varchar(10) NOT NULL,
    fir_capacity   int, 
    bus_capacity   int, 
    eco_capacity   int, 
    aircraft_type  varchar(10),
    company_id     int NOT NULL, 
    PRIMARY KEY (regis_no), 
    FOREIGN KEY (company_id) references Airlines.company_id
);

CREATE TABLE Schedules(
	schedule_id    int NOT NULL,
    operate_date   date, 
    dept_time      time,
    ariv_time      time,
    PRIMARY KEY (schedule_id)
);

CREATE TABLE Flights_ariv_dept(
	regis_no       varchar(10) NOT NULL,
    flight_no      varchar(7) NOT NULL,
    flight_status  varchar(10),
    dept_iata_code char(3) NOT NULL,
    ariv_iata_code char(3) NOT NULL, 
    PRIMARY KEY (regis_no, flight_no),
    FOREIGN KEY (regis_no) references Aeroplanes_belong.regis_no,
    FOREIGN KEY (dept_iata_code) references Airports.iata_code,
    FOREIGN KEY (dept_iata_code) references Airports.iata_code,
    CHECK (flight_status in ('On-Time','Delay','Cancel'))
);

CREATE TABLE serve(
	crew_id int NOT NULL,
    regis_no varchar(10) NOT NULL,
    flight_no varchar(7) NOT NULL,
    PRIMARY KEY (crew_id, regis_no, flight_no), 
    FOREIGN KEY (crew_id) references Crew.user_id,
    FOREIGN KEY (regis_no) references Aeroplanes_belong.regis_no,
    FOREIGN KEY (flight_no) references Flights_ariv_dept.flight_no
);

CREATE TABLE assign(
	regis_no varchar(10) NOT NULL,
    flight_no varchar(7) NOT NULL,
    schedule_id int NOT NULL,
    PRIMARY KEY (regis_no, flight_no, schedule_id), 
    FOREIGN KEY (regis_no) references Aeroplanes_belong.regis_no,
    FOREIGN KEY (flight_no) references Flights_ariv_dept.flight_no,
    FOREIGN KEY (schedule_id) references Schedules.schedule_id
);

CREATE TABLE hub(
	company_id int NOT NULL, 
    iata_code char(3) NOT NULL,
    PRIMARY KEY (company_id, iata_code),
    FOREIGN KEY (company_id) references Airlines.company_id,
    FOREIGN KEY (iata_code) references Airports.iata_code 
);

