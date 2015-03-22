library(shiny)

shinyUI(
          fluidPage(
          #Application title
          titlePanel('Historical Weather Event Data Visualization'),
          
          sidebarLayout(
               sidebarPanel(
                    helpText('Data subsetting options'),
                    radioButtons('damageType',label=h3('Type of Damages'),
                                       choices = list('Economic' = 'Economic',
                                                      'Population'= 'Population'),
                                       selected=NULL),
                    sliderInput('daterange',h3('Select years:'),min=1991,max=2011,
                                value=c(1991,2011),step=1,sep=''),
                    selectInput('states',label=h3('Select State:'),
                                choices=c('All',state.name))
               ),
               
               mainPanel(p('This is a tool for visualizing economic and population damage from',
                         'weather events in the US from the years 1991 to 2011. The data is',
                         'taken from the NOAA weather events database available for download ',
                         tags$a(href='','here.'), 'You can read more about',
                         'the data set from',tags$a(href='https://www.ncdc.noaa.gov/stormevents/','NOAA.'),
                         'The version of the database used in this project ends in 2011.'),
                         p('This app uses a transformed version of the database, you can read',
                           'about the transformations in the README file available in my ',
                           tags$a(href='http://github.com/lemurey/datascience-shiny-app','github.')),
                         p('You can select a range of years to analyze, whether you wish to',
                           'see economic (monetary) or population (fatalities and injuries) damages.',
                           'You can also subset the data by state if you wish using the dropdown menu.'
                           ),
                         plotOutput('barplot')
               )
          )
     )
)