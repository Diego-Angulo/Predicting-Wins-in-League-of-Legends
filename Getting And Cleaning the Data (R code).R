# Setting Working Directory
setwd("~/Diego/Analytics/LoL Analytics/Logistic Model")

# Loading Libraries
library(dplyr)
library(readxl)

# Downloading Oracleselixir.com .xlsx data files
Url <- c("http://oracleselixir.com/gamedata/2016-spring/", "http://oracleselixir.com/gamedata/2017-complete/",
         "http://oracleselixir.com/gamedata/2018-spring/", "http://oracleselixir.com/gamedata/2018-summer/",
         "http://oracleselixir.com/gamedata/2018-worlds/", "http://oracleselixir.com/gamedata/2019-spring/",
         "http://oracleselixir.com/gamedata/2019-summer/")

Destfile <- list.files(path = ".", pattern = ".xlsx", full.names = FALSE)

for(i in 1:length(Destfile) ) { 
    if(!file.exists(Destfile[i])) {
        download.file(Url[i], destfile = Destfile[i], mode="w", method="curl")
    }
}

# Loading the .xlsx files in RStudio. (From 2016 to 2017, League of Legends introduced some changes that added new varaibles)

    #2016 Dataset
    Data1 <- read_excel(Destfile[1],
                        col_types = c(rep("text", 4),"date",rep("text", 2),rep("numeric", 2),
                                      rep("text", 8),rep("numeric", 67)),
                        sheet = 1, col_names = TRUE)
   
    Data1 <- mutate(Data1,elders = NA, oppelders = NA, ban4 = NA,ban5 = NA,fbassist = NA,elementals = NA,
                    oppelementals = NA,firedrakes = NA,waterdrakes = NA,earthdrakes = NA,airdrakes = NA,
                    firstmidouter = NA, csat15 = NA, oppcsat15 = NA,csdat15 = NA, Year = 2016,
                    d2 = case_when(d == 0 ~ 1, d != 0 ~ d),dragond = teamdragkills-oppdragkills,
                    elderd = elders - oppelders,barond = teambaronkills - oppbaronkills,kda = ((k + a)/d2),
                    wardratio = NA,opptotalgold= NA)
    
    for(j in 1:dim(Data1)[1]) {
        
        if (Data1$playerid[j] == 100) {
            Data1[j,"opptotalgold"] <- as.numeric(Data1[j+1,"totalgold"])
            Data1[j,"wardratio"] <- as.numeric(Data1[j,"wards"]/Data1[j+1,"wardkills"])
        } else if (Data1$playerid[j] == 200) {
            Data1[j,"opptotalgold"] <- as.numeric(Data1[j-1,"totalgold"])
            Data1[j,"wardratio"] <- as.numeric(Data1[j,"wards"]/Data1[j-1,"wardkills"])
        } else if (Data1$playerid[j] == 1|Data1$playerid[j] == 2|Data1$playerid[j] == 3|
                   Data1$playerid[j] == 4|Data1$playerid[j] == 5) {
            Data1[j,"opptotalgold"] <- as.numeric(Data1[j+5,"totalgold"])
        } else if (Data1$playerid[j] == 6|Data1$playerid[j] == 7|Data1$playerid[j] == 8|
                   Data1$playerid[j] == 9|Data1$playerid[j] == 10) {
            Data1[j,"opptotalgold"] <- as.numeric(Data1[j-5,"totalgold"])
        }
    }     
    
    Data1 <- mutate(Data1, gepd = ((totalgold - opptotalgold)/((totalgold + opptotalgold)/2)),
                    elementalsd = elementals - oppelementals)
    
    Data1 = Data1[, c(100,1:17,87,88,18:22,101,105,23:29,89,30:38,102,90:91,109,92:95,85,86,103,39:42,96,43:49,
                      104,50:57,106,58:63,107,108,64:72,76:84,73:75,97:99)]
    
    #2017-Present.
    for(i in 2:length(Destfile) ) {
        Data <- read_excel(Destfile[i],
                           col_types = c(rep("text", 4),"date",rep("text", 2),rep("numeric", 2),
                                         rep("text", 10),rep("numeric", 79)),
                           sheet = 1, col_names = TRUE)
        
        if (i == 2) {
            Data <- mutate(Data, Year = 2017)
        } else if (i == 3|i == 4|i == 5) {
            Data <- mutate(Data, Year = 2018)
        } else if (i == 6|i == 7|i == 8) {
            Data <- mutate(Data, Year = 2019)
        }
        
        Data <- mutate(Data, d2 = case_when(d == 0 ~ 1, d != 0 ~ d), dragond = teamdragkills-oppdragkills,
                       elderd = elders - oppelders,barond = teambaronkills - oppbaronkills, kda = ((k + a)/d2),
                       wardratio = wards/wardkills, opptotalgold= NA, cssharepost15 = NA)
        
        for(j in 1:dim(Data)[1]) {
            if (Data$playerid[j] == 100) {
                Data[j,"opptotalgold"] <- as.numeric(Data[j+1,"totalgold"])
                Data[j,"wardratio"] <- as.numeric(Data[j,"wards"]/Data[j+1,"wardkills"])
            } else if (Data$playerid[j] == 200) {
                Data[j,"opptotalgold"] <- as.numeric(Data[j-1,"totalgold"])
                Data[j,"wardratio"] <- as.numeric(Data[j,"wards"]/Data[j-1,"wardkills"])
            } else if (Data$playerid[j] == 1|Data$playerid[j] == 2|Data$playerid[j] == 3|
                       Data$playerid[j] == 4|Data$playerid[j] == 5) {
                Data[j,"opptotalgold"] <- as.numeric(Data[j+5,"totalgold"])
            } else if (Data$playerid[j] == 6|Data$playerid[j] == 7|Data$playerid[j] == 8|
                       Data$playerid[j] == 9|Data$playerid[j] == 10) {
                Data[j,"opptotalgold"] <- as.numeric(Data[j-5,"totalgold"])
            }                    
        }
        
        Data <- mutate(Data, gepd = ((totalgold - opptotalgold)/((totalgold + opptotalgold)/2)),
                       elementalsd = elementals - oppelementals)
        Data = Data[, c(100,1:24,101,105,25:41,102,42:43,109,44:49,103,50:61,104,62:69,106,70:75,107,
                        108,76:83,99,84:98)]
        
        Temp <- paste("Data", i, sep = "")
        assign(Temp, Data)
    }
    
# Binding all the datasets to create a main data with information from 2016 to present.
Data <- rbind(Data1,Data2,Data3,Data4,Data5,Data6,Data7)
rm(Url,Destfile,Temp,i,j,Data1,Data2,Data3,Data4,Data5,Data6,Data7)

# Filtering, Formatting and Cleaning the variables to be used in the Logistic Regression Model
    
    # Filtering Year, Position and League.    
    ModelData <- Data %>% filter(Year == 2019 ,position == "Team",league != "LPL") %>%
            select(result, side, elementalsd, elderd, barond, wardratio, gspd)
    
    # Formating Variables.
    # Now determine how many rows have "NA". If it's just a few, we can remove them from the dataset, otherwise we should
    # consider imputing the values with a Random Forest or some other imputation method.
    ModelData[is.na(ModelData$elderd)|is.na(ModelData$barond)|is.na(ModelData$elementalsd)|
                  is.na(ModelData$wardratio)|is.na(ModelData$gspd),]   
    
    # As there are just 4 rows with NA's, let's just remove those.
    ModelData <- na.omit(ModelData)
    
    # Formating Variables
    ModelData$result <- ifelse(ModelData$result == 1, "Victory", "Defeat")
    ModelData$result <- as.factor(ModelData$result)
    ModelData$side <- as.factor(ModelData$side)
    ModelData$elementalsd <- cut(ModelData$elementalsd, breaks = c(-6,-4,3,6),
                                 labels = c("[-6,-4]","[-3,3]","[4,6]"),
                                 include.lowest = TRUE)
    ModelData$elderd <- as.factor(ModelData$elderd)
    ModelData$barond <- cut(ModelData$barond, breaks = c(-4,-2,-1,0,1,4),
                            labels= c("[-4,-2]", "-1","0","1","[2,4]"), include.lowest = TRUE)
    ModelData$wardratio <- round(ModelData$wardratio, 2)
    ModelData$gspd <- round(ModelData$gspd, 3)


# Export a backup of the main dataset in .xlsx format in the Working Directory
library(writexl)
write_xlsx(ModelData, path = "~/Diego/Analytics/LoL Analytics/Logistic Model/Extra Files/ModelData.xlsx",
           col_names = TRUE, format_headers = TRUE)
rm(Data)

# Save the global enviroment
save.image("~/Diego/Analytics/LoL Analytics/Logistic Model/Lol_Logistic_Model.RData")