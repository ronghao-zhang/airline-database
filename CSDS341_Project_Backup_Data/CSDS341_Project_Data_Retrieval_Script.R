# Load Packages
library(knitr)
library(dplyr)
library(randomNames)
library(stringi)
library(tidyverse)

# Airports Table Data 
raw_iata_data <- read.csv("C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/raw_data/raw_iata.csv")

iata_airport <- raw_iata_data %>% 
  filter(complete.cases(name,iata_code,iso_country,type)) %>%
  filter(iata_code != "" & nchar(iso_country) == 2 ) %>%
  filter(type =="large_airport") %>% 
  rename(airport_name = name, country = iso_country) %>% 
  select(airport_name, iata_code, country) 

iata_airport <- iata_airport %>% 
  filter(country == replace(country, country == 'HK', 'CN'))
iata_airport <- iata_airport %>% 
  filter(country == replace(country, country == 'TW', 'CN'))
iata_airport <- iata_airport %>% 
  filter(country == replace(country, country == 'MO', 'CN'))

set.seed(2022341)
iata_num <- dim(iata_airport)[1]

weather1 <- round(runif(floor(iata_num),1,4))
weather2 <- round(runif(ceiling(iata_num*1/10),5,10))
weather <- c(weather1, weather2)

weather <- as.data.frame(weather) %>% slice_sample(., prop = iata_num/length(weather))

# set up status data
airport_status <- round(runif(floor(iata_num),1,5))

# combine the weather and status with the original data
iata_airport_bind <- cbind(iata_airport, weather, airport_status)

iata_airport_rename <- iata_airport_bind %>% 
  mutate(weather = replace(weather, weather == '1', "Sunny"), 
         weather = replace(weather, weather == '2', "Mostly Sunny"),
         weather = replace(weather, weather == '3', "Partly Cloudy"),
         weather = replace(weather, weather == '4', "Cloudy"),
         weather = replace(weather, weather == '5', "Rainy"),
         weather = replace(weather, weather == '6', "Heavy Rainy"),
         weather = replace(weather, weather == '7', "Foggy"),
         weather = replace(weather, weather == '8', "Snowy"),
         weather = replace(weather, weather == '9', "Heavy Snowy"),
         weather = replace(weather, weather == '10', "Frost"),
         airport_status = replace(airport_status, airport_status == '1', "Free"), 
         airport_status = replace(airport_status, airport_status == '2', "Normal"),
         airport_status = replace(airport_status, airport_status == '3', "Busy"),
         airport_status = replace(airport_status, airport_status == '4', "Small-Scale Delay"),
         airport_status = replace(airport_status, airport_status == '5', "Large-Scale Delay")
  )

final_airports_data <- iata_airport_rename %>% 
  select(iata_code, airport_name, country, weather, airport_status) %>% 
  filter(country != "BE") %>%
  filter(country != "BR") %>%
  filter(country != "CH") %>%
  filter(country != "CL") %>%
  filter(country != "CU") %>% 
  filter(country != "CY") %>% 
  filter(country != "CZ") %>%
  filter(country != "DE") %>% 
  filter(country != "DO") %>% 
  filter(country != "ES") %>% 
  filter(country != "FR") %>% 
  filter(country != "CU") %>% 
  filter(country != "GP") %>% 
  filter(country != "IT") %>% 
  filter(country != "MR") %>% 
  filter(country != "MV") %>% 
  filter(country != "MX") %>% 
  filter(country != "NO") %>% 
  filter(country != "PE") %>% 
  filter(country != "PL") %>% 
  filter(country != "RO") %>% 
  filter(country != "SE") %>% 
  filter(country != "SI") %>% 
  filter(country != "SK") %>% 
  filter(country != "SN") %>% 
  filter(country != "SV") %>% 
  filter(country != "TR") %>% 
  filter(country != "VE") %>% 
  filter(country != "XK") 

write.csv(final_airports_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/airports.csv",row.names = FALSE)


# Airlines and Hub Table Data

raw_airline_data <- read.csv("C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/raw_data/raw_airlines_data.csv", header = TRUE, sep =",")

airline <- raw_airline_data %>% 
  filter(Active == "Y") %>%
  rename(company_name = X.Name, country_name = Country) %>% 
  select(company_name, country_name)

raw_country_code <- read.csv("C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/raw_data/raw_country_code.csv")

country_code <- raw_country_code %>%
  rename(country_name = ï..name) %>% 
  filter(complete.cases(country_name, code)) %>%
  filter(country_name != "" | code != "") %>%
  select(country_name, code)

airline_country <- merge(airline, country_code, by = "country_name", all = FALSE) %>% 
  select(company_name,code) %>% 
  filter(code != "CN")

airline_country[nrow(airline_country)+1,] = c("China Eastern Airlines","CN")
airline_country[nrow(airline_country)+1,] = c("China Southern Airlines","CN")
airline_country[nrow(airline_country)+1,] = c("Air China","CN")
airline_country[nrow(airline_country)+1,] = c("Hainan Airlines","CN")
airline_country[nrow(airline_country)+1,] = c("Delta","US")
airline_country[nrow(airline_country)+1,] = c("United","US")
airline_country[nrow(airline_country)+1,] = c("American Airlines","US")

set.seed(2022341)
company_id <- sample(101:999,nrow(airline_country), replace = FALSE)
airport_country_id <- cbind(company_id, airline_country)

# Export the Airlines Data.
final_airlines_data <- airport_country_id %>% 
  select(company_id, company_name)

write.csv(final_airlines_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/airlines.csv",row.names = FALSE)

airport_country_id_rename <- airport_country_id %>% 
  rename(country = code)

set.seed(2022341)
raw_hub <- merge(airport_country_id_rename, final_airports_data, by = "country") %>%
  slice_sample(., prop =3/4)
final_hub_data <- raw_hub %>%
  select(company_id, iata_code)

# Export the hub data.
write.csv(final_hub_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/hub.csv",row.names = FALSE)

# Travelers Table Data

raw_travlers <- randomNames(8000,return.complete.data = TRUE)
set.seed(2022341)
# attribute user_id
traveler_id <- sample(2000001:9999999,nrow(raw_travlers), replace = FALSE)
# attribute dob
traveler_dob <- sample(seq(as.Date('1949/01/01'), as.Date('2012/12/31'), by="day"),nrow(raw_travlers))
# attribute credits
credits <- sample(0:10000,nrow(raw_travlers))
# attribute passport_no
passport_no <- stri_paste(
  stri_rand_strings(nrow(raw_travlers),1, pattern = "[A-Z]"),
  stri_rand_strings(nrow(raw_travlers),1, pattern = "[A-Z]"),
  stri_rand_strings(nrow(raw_travlers),9, pattern = "[0-9]"))
# attribute citizenship
citizenship <- sample(country_code$code,nrow(raw_travlers), replace = TRUE)
# attribute traveler_middle_name
traveler_middle_name <- stri_paste(
  stri_rand_strings(nrow(raw_travlers),1, pattern = "[A-Z]"),
  ".")

final_travelers_data <- cbind(traveler_id,raw_travlers,traveler_dob,
                              credits,passport_no,citizenship,traveler_middle_name) %>%
  mutate(gender = replace(gender, gender == '0', 'M'), 
         gender = replace(gender, gender == '1', 'F')) %>% 
  rename(user_id = traveler_id, middle_name = traveler_middle_name, 
         dob = traveler_dob) %>% 
  select(user_id, first_name, middle_name, last_name, gender, dob, credits, passport_no, citizenship)

# Export the travelers data.
write.csv(final_travelers_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/travelers.csv",row.names = FALSE)

# Crew Table Data
set.seed(2022341)
raw_crew <- randomNames(500,return.complete.data = TRUE) %>% 
  mutate(gender = replace(gender, gender == '0', 'M'), 
         gender = replace(gender, gender == '1', 'F')) %>%
  select(-ethnicity)

# attribute crew_middle_name
crew_middle_name <- stri_paste(
  stri_rand_strings(nrow(raw_crew),1, pattern = "[A-Z]"),
  ".")
# attribute user_id 
crew_id <- sample(1000001:1999999,nrow(raw_crew), replace = FALSE)
# attribute dob
crew_dob <- sample(seq(as.Date('1949/01/01'), as.Date('1999/12/31'), by="day"),nrow(raw_crew))
# attribute ssn
ssn <- sample(123456789:987654321,nrow(raw_crew), replace = FALSE)
# attribute salary
salary <- sample(60000:250000,nrow(raw_crew), replace = TRUE)
# total distance
total_distance <- sample(5000:1000000000,nrow(raw_crew), replace = TRUE)

final_crew_data <- cbind(raw_crew, crew_middle_name, crew_id, crew_dob, salary, total_distance, ssn)%>% 
  rename(user_id = crew_id, dob = crew_dob, middle_name = crew_middle_name) %>% 
  select(user_id, first_name, middle_name, last_name, gender, dob, ssn, salary, total_distance)

write.csv(final_crew_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/crew.csv",row.names = FALSE)

# Aeroplanes_blong Table


# Schedules Table

# create 5000 sample in total
set.seed(2022341)
sche_num_1 <- 2000
sche_num_2 <- 4000

# dept_date for domestic and international
dept_date_1 <- sample(seq(as.Date('2019/01/01'), as.Date('2022/12/31'), by="day"),sche_num_1, replace = TRUE)
dept_date_2 <- sample(seq(as.Date('2019/01/01'), as.Date('2022/12/31'), by="day"),sche_num_2, replace = TRUE)

# ariv_date for domestic and international
ariv_date_1 <- dept_date_1 + 1 # add one day due to international flight
ariv_date_2 <- dept_date_2 

dept_date <- c(dept_date_1, dept_date_2)
ariv_date <- c(ariv_date_1, ariv_date_2)

# simulate time for departure
set.seed(2022341)
candidate_min <- seq(0,55,5)
hour_1 <- sample(19:23, sche_num_1, replace = TRUE) 
hour_2 <- sample(9:11, sche_num_2, replace = TRUE)
minutes_1 <- sample(candidate_min, sche_num_1, replace = TRUE)
minutes_2 <- sample(candidate_min, sche_num_2, replace = TRUE)

dept_time_1 <- NULL
for (i in 1:length(hour_1)){
  dept_time_1[i] = paste(hour_1[i],minutes_1[i],"00",sep=":")
}

dept_time_2 <- NULL
for (i in 1:length(hour_2)){
  dept_time_2[i] = paste(hour_2[i],minutes_2[i],"00",sep=":")
}

dept_time <- c(dept_time_1, dept_time_2)

# simulate time for arrival
set.seed(20223412)
candidate_min <- seq(0,55,5)
hour_1 <- sample(07:09, sche_num_1, replace = TRUE) 
hour_2 <- sample(12:14, sche_num_2, replace = TRUE)
minutes_1 <- sample(candidate_min, sche_num_1, replace = TRUE)
minutes_2 <- sample(candidate_min, sche_num_2, replace = TRUE)
ariv_time_1 <- NULL
for (i in 1:length(hour_1)){
  ariv_time_1[i] = paste(hour_1[i],minutes_1[i],"00",sep=":")
}

ariv_time_2 <- NULL
for (i in 1:length(hour_2)){
  ariv_time_2[i] = paste(hour_2[i],minutes_2[i],"00",sep=":")
}

ariv_time <- c(ariv_time_1, ariv_time_2)

schedule <- cbind(as.data.frame(dept_date),as.data.frame(dept_time),as.data.frame(ariv_date),as.data.frame(ariv_time))

set.seed(2022341)
schedule_id_1 <- sample(70001:99999,sche_num_1, replace = FALSE)
schedule_id_2 <- sample(10001:39999,sche_num_2, replace = FALSE)
schedule_id <- c(schedule_id_1,schedule_id_2)
final_schedule_data <- as.data.frame(cbind(schedule_id, schedule)) %>% 
  slice_sample(., prop = 5000/(sche_num_1+sche_num_2))

write.csv(final_schedule_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/schedules.csv",row.names = FALSE)

# Aeroplanes_belong Table
raw_plane <- read.csv("C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/raw_data/raw_flights.csv",sep=",")

# only select airbus or boeing
plane_type <- raw_plane %>% 
  rename(aircraft_type = X.Name) %>% 
  filter(grepl('Boeing',aircraft_type) | grepl('Airbus',aircraft_type)) %>% 
  filter(complete.cases(total_capacity)) %>% 
  select(aircraft_type, total_capacity)

# select candidate company_id
candidate_company_id <- final_airlines_data$company_id

plane_company_id <- rep(candidate_company_id,15)
plane_company_id <- as.data.frame(plane_company_id)

# create aeroplane data with different type & capacity
plane_num <- nrow(final_airlines_data)*15

set.seed(2022341)
row_num <- sample(1:nrow(plane_type), plane_num, replace = TRUE)

aeroplane <- data.frame(matrix(ncol = 2, nrow = plane_num))
for (i in 1:plane_num){
  row_idx = row_num[i]
  aeroplane[i,1:2] = plane_type[row_idx,1:2]
}

# create regis_no
set.seed(2022341)
regis_no <- stri_paste(
  stri_rand_strings(plane_num,1, pattern = "[A-Z]"),
  stri_rand_strings(plane_num,1, pattern = "[A-Z0-9]"),
  as.character(sample(10001:99999, plane_num, replace = FALSE))
)

# combine and rename data
aeroplane_combine <- cbind(regis_no, aeroplane, plane_company_id) %>% 
  rename(aircraft_type = X1, aircraft_capacity = X2, company_id = plane_company_id) %>% 
  select(regis_no, aircraft_capacity, aircraft_type, company_id)

# create capacity for each cabin
set.seed(2022341)
fir_capacity <- sample(0:30, plane_num, replace = TRUE) 
bus_capacity <- sample(10:40, plane_num, replace = TRUE) 
eco_capacity <- NULL
for (i in 1:plane_num){
  eco_capacity[i] <- aeroplane_combine$aircraft_capacity[i] - 
    fir_capacity[i] - bus_capacity[i]
}

# combine and export
final_aeroplanes_belong_data <- 
  cbind(aeroplane_combine, fir_capacity, bus_capacity, eco_capacity) %>%
  select(regis_no, fir_capacity, bus_capacity, eco_capacity, aircraft_type, company_id)

write.csv(final_aeroplanes_belong_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/aeroplanes_belong.csv",row.names = FALSE)

# Flights_ariv_dept Table
flight_chr <- read.csv("C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/raw_data/raw_flight_num.csv")
final_airlines_data_2 <- cbind(final_airlines_data, as.data.frame(flight_chr)) %>%
  rename(flight_no_chr = ï..flight_no_char)
final_aeroplanes_belong_data_2 <- merge(final_airlines_data_2, final_aeroplanes_belong_data, by = "company_id", all = FALSE)

# fk: regis_no, iata_code
candidate_regis_no <- final_aeroplanes_belong_data_2$regis_no

# create flight number
set.seed(2022341)
flight_no_1 <- stri_paste(
  final_aeroplanes_belong_data_2$flight_no_chr,
  as.character(sample(101:999,length(candidate_regis_no), replace = FALSE))
)

flight_no_1_combine <- cbind(final_aeroplanes_belong_data_2, flight_no_1) %>% 
  rename(flight_no = flight_no_1) %>%
  select(regis_no, flight_no)

temp <- final_aeroplanes_belong_data_2 %>% 
  filter(flight_no_chr == 'MU' | flight_no_chr == 'DL' | 
           flight_no_chr == 'HU' | flight_no_chr == 'AA' |
           flight_no_chr == 'CA' | flight_no_chr == 'UA') %>% 
  select(flight_no_chr, regis_no)

flight_no_chr_2 <- as.data.frame(rbind(temp,temp,temp,temp,temp,temp,temp,temp,temp,temp))
num_flight_no_2 <- nrow(flight_no_chr_2)
flight_no_2 <- stri_paste(
  temp$flight_no_chr,
  as.character(sample(1001:9999,num_flight_no_2, replace = FALSE))
)

flight_no_2_combine <- cbind(flight_no_chr_2, flight_no_2) %>%
  rename(flight_no = flight_no_2) %>%
  select(regis_no, flight_no)

raw_flights_data <- rbind(flight_no_1_combine, flight_no_2_combine)

set.seed(2022341)
num_status <- nrow(raw_flights_data)

# set up weather data - randomly simulated 
status_numeric <- sample(1:3,num_status, replace = TRUE)

flights_status_numeric <- cbind(raw_flights_data, status_numeric)

flights_status <- flights_status_numeric %>% 
  mutate(status_numeric = replace(status_numeric, status_numeric == '1', 'On-Time'), 
         status_numeric = replace(status_numeric, status_numeric == '2', 'Delay'),
         status_numeric = replace(status_numeric, status_numeric == '3', 'Cancel')
  )

# Depart IATA Code Candidate
candidate_dept_iata_1 <- iata_airport_rename %>% 
  filter(country == 'US') %>% 
  select(iata_code) %>%
  slice_sample(., prop = 1/8)
candidate_dept_iata_2 <- iata_airport_rename %>% 
  filter(country == 'CN') %>% 
  select(iata_code) %>%
  slice_sample(., prop = 1/2)
candidate_dept_iata <- rbind(candidate_dept_iata_1, candidate_dept_iata_2)

# ARRIVAl IATA Code Candidate
candidate_ariv_iata <- iata_airport_rename %>% 
  select(iata_code) %>%
  slice_sample(., prop = 1/5)

# dept_iata
temp <- sample(1:nrow(candidate_dept_iata), num_status, replace = TRUE)
dept_iata <- data.frame(matrix(ncol = 1, nrow = num_status))
for (i in 1:num_status){
  row_idx = temp[i]
  dept_iata[i,1] = candidate_dept_iata[row_idx,1]
}

# ariv_iata
temp <- sample(1:nrow(candidate_ariv_iata), num_status, replace = TRUE)
ariv_iata <- data.frame(matrix(ncol = 1, nrow = num_status))
for (i in 1:num_status){
  row_idx = temp[i]
  ariv_iata[i,1] = candidate_ariv_iata[row_idx,1]
}
ariv_iata <- as.data.frame(ariv_iata)

flights_ariv_dept <- cbind(flights_status, dept_iata) %>% 
  rename(dept_iata = matrix.ncol...1..nrow...num_status.)

final_flights_ariv_dept <- cbind(flights_ariv_dept, ariv_iata) %>% 
  rename(ariv_iata = matrix.ncol...1..nrow...num_status.,
         flight_status = status_numeric)

write.csv(final_flights_ariv_dept, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/flights_ariv_dept.csv",row.names = FALSE)

# Tickets_book_for Table

set.seed(2022341)
num_ticket <- 10000
# ticket_id
ticket_id <- sample(1000000001:9999999999, num_ticket, replace = FALSE)
ticket_id <- as.data.frame(ticket_id)
# seat_location
seat_location <- stri_paste(
  as.character(sample(1:50,num_ticket, replace = TRUE)),
  stri_rand_strings(num_ticket,1, pattern = "[A-F]")
)
seat_location <- as.data.frame(seat_location)

# seat_class
class_candidate <- c('First', 'Business', 'Economic')
class_numeric <- sample(1:3, num_ticket, replace = TRUE)
seat_class <- NULL
for (i in 1:num_ticket) {
  idx = class_numeric[i]
  seat_class[i] = class_candidate[idx]
}
seat_class <- as.data.frame(seat_class) 

# regis_no & flight_no
flight_no_candidate <- final_flights_ariv_dept %>% 
  select(regis_no,flight_no)
fn_select <- sample(1:nrow(flight_no_candidate),num_ticket, replace = TRUE)
fn_ticket <- data.frame(matrix(ncol = 2, nrow = num_ticket))
for (i in 1:num_ticket) {
  idx = fn_select[i]
  fn_ticket[i,1:2] = flight_no_candidate[idx,1:2]
}
fn_ticket <- fn_ticket %>% rename(regis_no = X1, flight_no = X2)

# bind and check if there is duplication
raw_ticket_data <- cbind(seat_location, seat_class, fn_ticket) %>% 
  group_by(seat_location,seat_class,regis_no,flight_no) %>%
  count() %>% filter(n == "1") %>% select(-n)

# traveler_id
traveler_id_candidate <- final_travelers_data %>% select(user_id) 
tid_numeric <- sample(1:nrow(traveler_id_candidate),nrow(raw_ticket_data),replace = TRUE)
traveler_id <- data.frame(matrix(ncol = 1, nrow = nrow(raw_ticket_data)))
for (i in 1:nrow(raw_ticket_data)) {
  idx = tid_numeric[i]
  traveler_id[i,1] = traveler_id_candidate[idx,1]
}
traveler_id <- traveler_id %>% rename(traveler_id = matrix.ncol...1..nrow...nrow.raw_ticket_data.. )
# luggage_no
luggage_no <- sample(1:3,nrow(raw_ticket_data),replace = TRUE)
luggage_no <- as.data.frame(luggage_no)

# tickets_combine 
ticket_id <- ticket_id[1:nrow(raw_ticket_data),1]
ticket_id <- as.data.frame(ticket_id)
final_tickets_book_for <- cbind(ticket_id, raw_ticket_data, traveler_id, luggage_no) %>% 
  select(ticket_id, seat_location, seat_class, luggage_no, regis_no, flight_no, traveler_id)

write.csv(final_tickets_book_for, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/tickets_book_for.csv",row.names = FALSE)

# assign Table

num_schedule <-  nrow(final_schedule_data)
num_flights <- nrow(final_flights_ariv_dept)
sch_id_candidate <- final_schedule_data %>% select(schedule_id) 
raw_assign <- final_flights_ariv_dept %>% select(regis_no, flight_no)

# random do assign relationship
set.seed(2022341)
assign_numeric <- sample(1:num_schedule, num_flights, replace = FALSE)
assign_sch_id <- NULL
for (i in 1:num_flights) {
  idx = assign_numeric[i]
  assign_sch_id[i] = sch_id_candidate[idx,1]
}
assign_sch_id <- as.data.frame(assign_sch_id)

# Combine together and Export
final_assign <- cbind(raw_assign, assign_sch_id) %>%
  rename(schedule_id = assign_sch_id)

write.csv(final_assign, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/assign.csv",row.names = FALSE)

set.seed(2022341)
# create candidate crew id
crew_id_candidate_1 <- final_crew_data %>% select(user_id) %>% 
  slice_sample(., prop = 9/10)


num_crew <- nrow(crew_id_candidate_1)
serve_numeric <- sample(1:num_crew, num_flights, replace = TRUE)
serve_crew_id_1 <- data.frame(matrix(ncol = 1, nrow = num_flights))
for (i in 1:num_flights) {
  idx = serve_numeric[i]
  serve_crew_id_1[i,1] = crew_id_candidate_1[idx,1]
}

serve_crew_id_1 <- serve_crew_id_1 %>% rename(crew_id = matrix.ncol...1..nrow...num_flights.)

serve_bind <- cbind(raw_assign, serve_crew_id_1)

# create another version 
set.seed(2022341)
raw_serve <- raw_assign %>% slice_sample(., prop = 1/5)
num_flights <- nrow(raw_serve)

serve_numeric <- sample(1:num_crew, num_flights, replace = FALSE)
serve_crew_id_1 <- data.frame(matrix(ncol = 1, nrow = num_flights))
for (i in 1:num_flights) {
  idx = serve_numeric[i]
  serve_crew_id_1[i,1] = crew_id_candidate_1[idx,1]
}

serve_crew_id_1 <- serve_crew_id_1 %>% rename(crew_id = matrix.ncol...1..nrow...num_flights.)

serve_bind_2 <- cbind(raw_serve, serve_crew_id_1)

final_serve_data <- rbind(serve_bind, serve_bind_2)

write.csv(final_serve_data, "C:/Users/luke_/OneDrive/Desktop/csds341-project-airlineDatabase/CSDS341_Project_Backup_Data/csv_data/serve.csv",row.names = FALSE)

