####### Load necessary libraries
library(readxl)
library(dplyr)
library(stringr)
library(forecast)
library(tseries)
library(xts)
#library(quantmod)
unloadNamespace("fpp")
unloadNamespace("expsmooth")
unloadNamespace("forecast")
unloadNamespace("tseries")
unloadNamespace("fma")
unloadNamespace("TTR")
unloadNamespace("xts")
unloadNamespace("quantmod")

# Define a function to process each day's data
process_day_data <- function(excel_data, start_row, date_row_offset = 9, time_row_start = 16, time_row_end = 111) {
  print(start_row)
  # Extract the date from the appropriate row
  #start_row=231
  #date_row_offset=9
  #time_row_start=16
  #time_row_end=111
  tmp_str <- excel_data[start_row + date_row_offset, 2]
  tmp_str2 <- unlist(str_split(tmp_str,"-"))
  date <- as.Date(tmp_str2[2], format = "%d.%m.%Y")
  
  # Extract the time intervals and values
  time_intervals <- excel_data[(start_row + time_row_start) : (start_row + time_row_end), 1:5]
  colnames(time_intervals) <- names
  
  # Drop any rows where the Time Interval is NA
  time_intervals <- time_intervals %>% drop_na()
  time_intervals <- time_intervals %>% mutate(obsday=date)
  time_intervals <- time_intervals %>% mutate(dt=unlist(str_split(`Tids-interval`,"-"))[1])
  time_intervals <- time_intervals %>% rowwise() %>% mutate(dt=unlist(str_split(`Tids-interval`,"-"))[1])
  time_intervals <- time_intervals %>% rowwise() %>% mutate(dt2=as.POSIXct(paste(date, dt), format = "%Y-%m-%d %H:%M"))
  return(time_intervals)
}

# Load the Excel file
excel_data <-read_xls("data/trafik.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20161.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20191.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20201.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20211.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20221.xls",col_names = FALSE)
excel_data <-read_xls("data/trafik20231.xls",col_names = FALSE)
names=unlist(excel_data[16,1:6])

# Initialize an empty list to hold all days' data
all_days_data <- list()

# Loop over the rows to extract data for each day
tr=seq(1, nrow(excel_data), by = 115)
#trt=tr[1:4]
#for (start_row in trt) {
#nrow(excel_data)
#for (start_row in (seq(1, nrow(excel_data), by = 115))) {
#  print(start_row)
#}

for (start_row in (seq(1, nrow(excel_data), by = 115))) {
  day_data <- process_day_data(excel_data, start_row)
  all_days_data[[length(all_days_data) + 1]] <- day_data
}

# Combine all days' data into a single data frame
final_data <- bind_rows(all_days_data)
fd=as_tibble(final_data)
saveRDS(fd,"trafik2019.rds")
saveRDS(fd,"trafik2016.rds")
saveRDS(fd,"trafik2020.rds")
saveRDS(fd,"trafik2021.rds")
saveRDS(fd,"trafik2022.rds")
saveRDS(fd,"trafik2023.rds")

#fd=fd %>% mutate(obsday=as.Date(dt2))
#tt=fd[34,'dt2']
#class(tt$dt2)


fd=readRDS("trafik2022.rds")


# aggregate
fdsm=fd[,c(2,3,4,5,6)]
fdsm[1:4]=lapply(fdsm[1:4], as.integer)

str(fdsm)
daily= fdsm %>% group_by(obsday) %>% summarise(across(everything(),sum,na.rm=TRUE))

plot(daily$obsday,daily$`Person- og varebiler`, type="l", col="blue")
lines(daily$obsday, daily$`Køretøjer 580-1250`, col = "red", lwd = 2)
lines(daily$obsday, daily$`Køretøjer 1250-2200`, col = "green", lwd = 2)

subplot=fdsm[fdsm$obsday=='2022-01-01',]
subplot=fdsm[fdsm$obsday=='2022-05-01',]
subplot=fdsm[fdsm$obsday=='2022-06-01',]
subplot=fdsm[fdsm$obsday=='2022-04-15',]
subplot=fdsm[fdsm$obsday=='2022-04-4',]
str(fdsm$obsday)


plot((1:nrow(subplot)),subplot$`Køretøjer 1250-2200`, type="l", col="blue")

# test for stationarity
time_index <- seq(from = as.POSIXct("2020-01-01 00:00"), by = "15 min", length.out = (21*96))
traffic=fd[,c(5,8)]
traffic_counts <- fd[,5]
sub_t = traffic[(96*100):(96*121),1]
sub_t=sub_t[1:(nrow(sub_t)-1),]

colnames(sub_t)="obs"
#t_ts=ts(traffic_counts,start=c(2022,1), frequency = 96)
sub_t$obs=as.integer(sub_t$obs)
#sub_t=sub_t[1:(nrow(sub_t)-1),]

xt_ts=xts(sub_t,frequency = 96, order.by = time_index)
plot(t_ts)
print(t_ts)
plot(t_ts, main="Traffic Data Time Series", ylab="Traffic Volume", xlab="Time")
plot(xt_ts, main = "Tung trafik over Øresund")



# test
tt=read.csv("data/ITstore_bidaily.csv", sep=";")
my_ts=ts(tt$X203,start=1, frequency = 12)
plot(my_ts)
