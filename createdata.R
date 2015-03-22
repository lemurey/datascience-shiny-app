library(data.table) 

# set column classes, many are set to NULL because thatt data is unused,
# the used columns are BGN_DATE, EVTYPE, FATALITIES, INJURIES, PROPDMG,
# PROPDMGEXP, CROPDMG, and CROPDMGEXP
classes <- c('NULL','character',rep('NULL',4),'character','character',rep('NULL',14),
             rep('numeric',3),'character','numeric','character',rep('NULL',9))

# read in Data
wt <- fread('StormData.csv',colClasses=classes)

# create a new column of just the year for use in sorthing later
wt[,year:=format(as.Date(BGN_DATE,format="%m/%d/%Y %X"),'%Y')]

# remove BGN_DATE column
wt[,BGN_DATE:=NULL]
# remove data prior to 1991
setkey(wt,year)
wt <- wt[as.numeric(year)>1990]

# convert PROPDMGEXP to mult for extracting values
wt[,mult:=0]
indsnum <- grep('[0-9]',wt$PROPDMGEXP)
nums <- 10^as.numeric(grep('[0-9]',wt$PROPDMGEXP,value=TRUE))
wt$mult[indsnum]<-nums
wt$mult <- 1E9*grepl('B',wt$PROPDMGEXP,ignore.case=TRUE)+
     1E6*grepl('M',wt$PROPDMGEXP,ignore.case=TRUE)+
     1E3*grepl('K',wt$PROPDMGEXP,ignore.case=TRUE)+
     1E2*grepl('H',wt$PROPDMGEXP,ignore.case=TRUE)+
     1E3*grepl('[[:punct:]]',wt$PROPDMGEXP)

# convert CROPDMGEXP to cmult for extracting values
wt[,cmult:=0]
indsnum <- grep('[0-9]',wt$CROPDMGEXP)
nums <- 10^as.numeric(grep('[0-9]',wt$CROPDMGEXP,value=TRUE))
wt$mult[indsnum]<-nums
wt$cmult <- 1E9*grepl('B',wt$CROPDMGEXP,ignore.case=TRUE)+
     1E6*grepl('M',wt$CROPDMGEXP,ignore.case=TRUE)+
     1E3*grepl('K',wt$CROPDMGEXP,ignore.case=TRUE)+
     1E2*grepl('H',wt$CROPDMGEXP,ignore.case=TRUE)+
     1E3*grepl('[[:punct:]]',wt$CROPDMGEXP)

# adjust values for inflation
library(quantmod)

# get CPI adjustment from FRED
getSymbols('CPIAUCSL',src='FRED')
avgcpi <- apply.yearly(CPIAUCSL,mean)
cf <- as.numeric(avgcpi['2011'])/avgcpi
# subset FRED data to years we want
adjust <- data.table(year=format(index(cf[45:65]),'%Y'),
                     adjust = as.numeric(cf[45:65]),key='year')

# perform inflation adjustment
for (yearval in adjust[,year]) {
     mod <- adjust[.(yearval),adjust]
     wt[.(yearval),damages:=(PROPDMG*mult+CROPDMG*cmult)*mod]
}


twt <- wt[,.(EVTYPE,year,STATE,FATALITIES,INJURIES,damages)]

states <- c(unique(twt[,STATE])[1:49],'AK','HI')

twt <- twt[STATE %in% states]




heat <- unique(twt[grep('heat',EVTYPE,ignore.case=TRUE),EVTYPE])
heat <- heat[!grepl('drought',heat,ignore.case=TRUE)]

cold <- unique(twt[grep('cold',EVTYPE,ignore.case=TRUE),EVTYPE])
cold <- cold[!grepl('tornado',cold,ignore.case=TRUE)]

drought <- unique(twt[grep('drought',EVTYPE,ignore.case=TRUE),EVTYPE])

hurricane <- unique(twt[grep('hurricane',EVTYPE,ignore.case=TRUE),EVTYPE])

tornados <- unique(twt[grep('tornado',EVTYPE,ignore.case=TRUE),EVTYPE])

flood <- unique(twt[grep('flood',EVTYPE,ignore.case=TRUE),EVTYPE])
flash <- grepl('flash',flood,ignore.case=TRUE)
river <- grepl('(river){1}|(stream){1}',flood,ignore.case=TRUE)
flashflood <- flood[flash]
riverflood <- flood[river]
flood <- flood[!(flash+river)]

tstmwind <- unique(twt[grep('(tstm|thuderstorm).*wind',EVTYPE,ignore.case=TRUE),EVTYPE])
tstmwind <- tstmwind[!grepl('tornado|non',tstmwind,ignore.case=TRUE)]
tstmwind <- c(tstmwind,'THUNDERSTORM WIND')

top80events <- c('FLOOD','HURRICANE','STORM SURGE','TORNADO','HAIL','FLASH FLOOD','DROUGHT',
                 'RIVER FLOOD','ICE STORM','COLD','HEAT','THUNDERSTORM WIND','LIGHTNING',
                 'HIGH WIND','RIP CURRENT','AVALANCHE',heat,cold,drought,hurricane,
                 tornados,flood,flashflood,riverflood,tstmwind)
twt <- twt[EVTYPE %in% top80events,]

save(twt,file='forap.rda')


