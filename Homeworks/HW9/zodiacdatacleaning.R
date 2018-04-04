library(foreign)
library(tidyr)
library(Hmisc)

dataset <- read.spss( "C:\\Users\\zaidmansr\\Desktop\\NEWMainDat_NewCgSbs_NewPRS_SOB_OC_012918.sav", 
                      to.data.frame = TRUE)

dataset <- subset(dataset, is.na(dataset$BirthDate)==FALSE)

dataset <- mutate(dataset, zodiac= case_when(
  MOB_012318 == "Jan" & DOB_012318 >19 ~ "Aquarius",
  MOB_012318 == "Feb" & DOB_012318 <19 ~ "Aquarius",
  MOB_012318 == "Feb" & DOB_012318 >= 19 ~ "Pisces",
  MOB_012318 == "Mar" & DOB_012318 < 21 ~ "Pisces",
  MOB_012318 == "Mar" & DOB_012318 >= 21 ~ "Aries",
  MOB_012318 == "Apr" & DOB_012318 < 20 ~ "Aries",
  MOB_012318 == "Apr" & DOB_012318 >= 20 ~ "Taurus",
  MOB_012318 == "May" & DOB_012318 < 21 ~ "Taurus",
  MOB_012318 == "May" & DOB_012318 >= 21 ~ "Gemini",
  MOB_012318 == "Jun" & DOB_012318 < 21 ~ "Gemini",
  MOB_012318 == "Jun" & DOB_012318 >= 21 ~ "Cancer",
  MOB_012318 == "Jul" & DOB_012318 < 23 ~ "Cancer",
  MOB_012318 == "Jul" & DOB_012318 >= 23 ~ "Leo",
  MOB_012318 == "Aug" & DOB_012318 < 23 ~ "Leo",
  MOB_012318 == "Aug" & DOB_012318 >= 23 ~ "Virgo",
  MOB_012318 == "Sep" & DOB_012318 < 23 ~ "Virgo",
  MOB_012318 == "Sep" & DOB_012318 >= 23 ~ "Libra",
  MOB_012318 == "Oct" & DOB_012318 < 23 ~ "Libra",
  MOB_012318 == "Oct" & DOB_012318 >= 23 ~ "Scorpio",
  MOB_012318 == "Nov" & DOB_012318 < 22 ~ "Scorpio",
  MOB_012318 == "Nov" & DOB_012318 >= 22 ~ "Sagittarius",
  MOB_012318 == "Dec" & DOB_012318 < 22 ~ "Sagittarius",
  MOB_012318 == "Dec" & DOB_012318 >= 22 ~ "Capricorn",
  MOB_012318 == "Jan" & DOB_012318 <= 19 ~ "Capricorn"
))

cleandataset <- select(dataset, 1,15,38,39,46,229:299,817)

write.csv(cleandataset, file = "C:\\Users\\zaidmansr\\Desktop\\cleandata40418.csv")

