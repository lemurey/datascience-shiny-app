load('forap.rda')
library(ggplot2)

#set theme for plot
plottheme <- theme_grey()+
     theme(title = element_text(colour='black'),
           axis.text = element_text(colour='black'),
           axis.text.x = element_text(angle=45,hjust=1),
           plot.background=element_rect(colour='black',fill='White'),
           panel.background=element_rect(colour='black',fill='White'),
           panel.grid.major.x = element_blank(),
           panel.grid.major.y = element_line(colour='black'),
           panel.grid.minor.y = element_line(colour='black'),
           panel.grid.minor.x = element_blank())


subsetdata <- function(states='USA',years=c(1991,2011)) {
     yearrange <- as.character(seq(from=min(years),to=max(years),by=1))
     setkey(twt,year)
     subdata <- twt[.(yearrange),]
     if (is.null(states)) {
          states <- 'USA'
     }
     if (!any(states %in% 'USA')) {
          subdata <- subdata[STATE %in% states,]
     }
     else {
          subdata[,STATE:='USA']
     }
     subdata <- subdata[,lapply(.SD,sum),by=.(EVTYPE,STATE),
                          .SDcols=c('damages','INJURIES','FATALITIES')]
}

combineredundant <- function(data) {
     
     heat <- data[grep('heat',EVTYPE,ignore.case=TRUE),EVTYPE]
     heat <- heat[!grepl('drought',heat,ignore.case=TRUE)]
     
     cold <- data[grep('cold',EVTYPE,ignore.case=TRUE),EVTYPE]
     cold <- cold[!grepl('tornado',cold,ignore.case=TRUE)]
     
     drought <- data[grep('drought',EVTYPE,ignore.case=TRUE),EVTYPE]
     
     hurricane <- data[grep('hurricane',EVTYPE,ignore.case=TRUE),EVTYPE]
     
     tornados <- data[grep('tornado',EVTYPE,ignore.case=TRUE),EVTYPE]
     
     flood <- data[grep('flood',EVTYPE,ignore.case=TRUE),EVTYPE]
     flash <- grepl('flash',flood,ignore.case=TRUE)
     river <- grepl('(river){1}|(stream){1}',flood,ignore.case=TRUE)
     coastal <- grepl('(coastal){1}|(beach){1}|tidal{1}',flood,ignore.case=TRUE)
     flashflood <- flood[flash]
     riverflood <- flood[river]
     coastalflood <- flood[coastal]
     flood <- flood[!(flash+river+coastal)]
     
     tstmwind <- data[grep('(tstm|thuderstorm).*wind',EVTYPE,ignore.case=TRUE),EVTYPE]
     tstmwind2 <- data[grep('THUNDERTORM WIND',EVTYPE),EVTYPE]
     tstmwind <- tstmwind[!grepl('tornado|non',tstmwind,ignore.case=TRUE)]
     tstmwind <- c(tstmwind,tstmwind2)
     
     makegroup <- list('COLD'=cold,'HEAT'=heat,'DROUGHT'=drought,'HURRICANE'=hurricane,
                       'TORNADO'=tornados,'FLOOD'=flood,'FLASH FLOOD'=flashflood,
                       'COASTAL FLOOD' = coastalflood,
                       'RIVER FLOOD'=riverflood,'THUNDERSTORM WIND'=tstmwind)
     rnlist <- list()
     for (i in 1:length(makegroup)){
          if(length(makegroup[[i]])!=0) {
               rnlist <- append(rnlist,makegroup[i])
          }
     }
     for (i in 1:length(rnlist)) {
          setkey(data,EVTYPE)
          data[rnlist[i],EVTYPE:=names(rnlist[i])]                                                 
     }
     setkey(data,EVTYPE,STATE)
     data[,lapply(.SD,sum),by=c('EVTYPE','STATE')]
}


