library(shiny)
library(data.table)


source('test functions.R')



shinyServer(
     function(input,output) {
          output$barplot <- renderPlot({
               states <- input$states
               years <- input$daterange
               type <- input$damageType
               if (is.null(states)){
                    states<-'All'
               }
               if (!states=='All'){
                    states <- state.abb[state.name %in% states]
               } else {
                    states <- 'USA'
               }
               tempdata <- subsetdata(states=states,years=years)
               tempdata <- combineredundant(tempdata)
               tempdata[,EVTYPE:=factor(EVTYPE)]
               if(min(years)!=max(years)) {
                    plottitle <- paste(type,'Damages by Weather Event in',states,'during',
                                       min(years),'to',max(years))
               }
               else {
                    plottitle <- paste(type,'Damages by Weather Event in',states,'for',min(years))
               }
               if(type=='Economic') {
                    setorder(tempdata,-damages)
                    plotdata <- droplevels(tempdata[,.(EVTYPE=reorder(EVTYPE,-damages),
                                                       STATE=STATE,
                                                       damages=damages/10^6)])
                    ggplot(plotdata,aes(x=EVTYPE,y=damages,fill=STATE))+
                         geom_bar(stat='identity',fill='steelblue') +
                         labs(x='Weather Event',
                              y='Economic Damages (Millions of 2011 $\'s)',
                              title=plottitle) +
                         plottheme
               } 
               else {
                    plotdata<-tempdata[,.(EVTYPE,FATALITIES,INJURIES)]
                    plotdata<-melt(plotdata,id='EVTYPE',measure=c('FATALITIES','INJURIES'))
                    plotdata <- plotdata[value>0,]
                    setorder(plotdata,-value)
                    plotdata <- droplevels(plotdata[,.(EVTYPE=reorder(EVTYPE,-value),
                                                       variable=variable,
                                                       value=value)])
                    ggplot(plotdata,aes(x=EVTYPE,y=value,fill=variable))+
                         geom_bar(stat='identity') +
                         scale_fill_manual(name = '',
                                           values = c("INJURIES" = "darkblue",
                                                      "FATALITIES" = "red")
                         ) + labs(x='Weather Event',
                                  y='INJURIES/DEATHS',
                                  title=plottitle) +
                         plottheme
               }
          })
     }
)