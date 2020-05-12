#simple R script for grabbing NYT COVID County Data and adding political info. 

library(dplyr)
library(lubridate)


#Getting County Data 
county = read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv",header=TRUE,stringsAsFactors = FALSE)
county_pop = fromJSON("https://raw.githubusercontent.com/Zoooook/CoronavirusTimelapse/master/static/population.json") %>% as.data.frame

#fix date 
county$date = ymd(county$date)
county$fips = ifelse(county$county=="New York City","36998",county$fips)

#strip leading zeros from fips so it matches with subsequent data 
county_pop$us_county_fips = sub("^0+", "", county_pop$us_county_fips)

#add in population info 
county = merge(county,county_pop,by.x="fips",by.y="us_county_fips")
#county = merge(county,hospitals, by.x="fips",by.y="FIPS")
county$nyt_population=NULL
county = arrange(county,date)

#narrow to just March 1 and beyond 
countyMarch = county %>% filter(.,date>="2020-03-01")

#Get 2016 election info 
votes = read.csv("https://raw.githubusercontent.com/tonmcg/US_County_Level_Election_Results_08-16/master/2016_US_County_Level_Presidential_Results.csv",header = TRUE,stringsAsFactors = FALSE)
votes = merge(countyMarch,votes,by.x="fips",by.y="combined_fips",all.x=TRUE)
votes$party = ifelse(votes$per_dem>votes$per_gop,"Blue","Red")
votes$party = ifelse(votes$county=="New York City","Blue",votes$party)
