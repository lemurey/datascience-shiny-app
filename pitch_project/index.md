---
title       : Course Project - Developing Data Products
subtitle    : 
author      : Lee Murray
job         : 
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}
knit        : slidify::knit2slides
---

## Historical Weather Event Data Visualization

This presentation is about the exciting new Historical Weather Event Data Visualization app
Using the massive power of R and shiny, you can now find out how much damage past weather
events caused on a state by state basis.


--- 

## DETAILS!

The app works as follows: Select a date range and a state and whether you want to see
economic or population damages and the app will display a barplot of the weather categories
contributing to the top 80% of the relevant damages. AMAZING!

You can go play with it right now at [WeatherView](https://lemurey.shinyapps.io/WeatherView/)

---

## Slide 4 (it's better than Slide 3)
This app was based on the NOAA database used for the reproducible research course.
I applied some transformations to the data that you can read about [on my github page](https://github.com/lemurey/datascience-shiny-app)
  
A brief summary- I filtered out everything before 1991, then applied an
inflation adjustment to the monetary values. I then grab the event 
categories that correspond to the top 80% of any given damage type.

The original data can be found [here.](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2)

---

## data.table is great

The app uses the powerful data.table R package to perform calculations, it's great.

I used calculations like these, and some regular expressions to combine
similar categories and make the graphs easier to follow.



```r
twt[year %in% c('1991','1992','1993'),.(sum(FATALITIES)),by=STATE]
```

```
##     STATE V1
##  1:    AL  7
##  2:    AR  0
##  3:    AZ  2
##  4:    CA  3
##  5:    CO  0
##  6:    CT  0
##  7:    DC  1
##  8:    DE  0
##  9:    FL 11
## 10:    GA 11
## 11:    IA  4
## 12:    ID  3
## 13:    IL  0
## 14:    IN  3
## 15:    KS 22
## 16:    KY  3
## 17:    LA  4
## 18:    MA  0
## 19:    MD  1
## 20:    ME  0
## 21:    MI  0
## 22:    MN  4
## 23:    MO 14
## 24:    MS 18
## 25:    MT  1
## 26:    NC  3
## 27:    ND  1
## 28:    NE  2
## 29:    NH  0
## 30:    NJ  0
## 31:    NM  1
## 32:    NV  1
## 33:    NY 10
## 34:    OH  0
## 35:    OK 14
## 36:    OR  0
## 37:    PA  0
## 38:    RI  0
## 39:    SC  4
## 40:    SD  2
## 41:    TN  7
## 42:    TX  7
## 43:    UT  0
## 44:    VA  5
## 45:    VT  0
## 46:    WA  1
## 47:    WI  4
## 48:    WV  0
## 49:    WY  1
##     STATE V1
```

```r
head(twt)
```

```
##    year STATE FATALITIES INJURIES pdamages cdamages evtype
## 1: 1991    AL          0        0        0        0   heat
## 2: 1991    AL          0        0        0        0   heat
## 3: 1991    AL          0        0        0        0   heat
## 4: 1991    AL          0        0        0        0   heat
## 5: 1991    AL          0        0        0        0   heat
## 6: 1991    AL          0        0        0        0   heat
```
