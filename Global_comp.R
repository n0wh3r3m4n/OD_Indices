
# LOAD ALL RANKINGS INTO THE R ENVIRONMENT

if (require("googlesheets") == FALSE) {
    install.packages("googlesheets")
}
if (require("ggthemes") == FALSE) {
    install.packages("ggthemes")
}
require(googlesheets)
require(ggthemes)

#
# Open Data Barometer
#
# You need to add the Open Data Barometer Historic data sheet to your google drive.
# 1. Go to: https://docs.google.com/spreadsheets/d/1YbicyCIdnJjBTgQCN84YilqSyaW8OyVHnALoPEj200I/edit#gid=1838396352
# 2. Add the file to your google drive (icon on top next to the name of the file)
#

ODBHIST <- gs_title("Open Data Barometer - Historical Data (All four Editions) - Public")

#
# A browser window will open to create a code that will allow the googlesheets package
# access to the files in your google drive
#

ODB <- gs_read(ss=ODBHIST, ws = "ODB-2016-Rankings")
rm(ODBHIST)
ODB$region <- NULL
colnames(ODB)[5:12] <- c("Rank","Country","Score.ODB","Change","Rank_Change","Readiness","Implementation","Impact")

#
# Open Data Index
#

GODI <- read.csv("https://index.okfn.org/api/places.csv")
GODI$name <- as.character(GODI$name)
colnames(GODI)[8] <- "Score.GODI"

#
# Open Data Inventory
#

ODIN <- read.csv("http://odin.opendatawatch.com/Report/ToCSV?type=RankingView&sortOrder=&appConfigId=4")
ODIN$Country <- as.character(ODIN$Country)
colnames(ODIN)[7] <- "Score.ODIN"

#
# List of World Bank country names with income and region
# The table can be found as an excel file at
# http://data.worldbank.org/about/country-and-lending-groups
# I use the xlsx package to import the file
#

if (require("xlsx") == FALSE) {
    install.packages("xlsx")
}
require(xlsx)

class <- read.xlsx("CLASS.xls",sheetIndex = 1, startRow = 5, header = TRUE)
class$Economy <- as.character(class$Economy)

#
# All countries need to have the same name. Each tool however has around
# 13 countries (many different from each other) with different names (e.g. "Russia"
# vs. "Russian Federation", etc.)
# I have used "subset(ODB$Country, !(ODB$Country %in% class$Economy))" to identify
# those countries and edited the index databases. In the cases of Sao Tome and Principe and Cote D'Ivoire I also
# edited the "class" file.
#

# edits in class
class[166,3] <- ODIN[162,4]
class[49,3] <- ODB[95,6]

# edits in ODB
ODB$Country[ODB$Country == "Slovakia"] <- "Slovak Republic"
ODB$Country[ODB$Country == "United States of America"] <- "United States"
ODB$Country[ODB$Country == "Kyrgyzstan"] <- "Kyrgyz Republic"
ODB$Country[ODB$Country == "Korea"] <- "Korea, Rep."
ODB$Country[ODB$Country == "Russia"] <- "Russian Federation"
ODB$Country[ODB$Country == "Russia"] <- "Macedonia, FYR"
ODB$Country[ODB$Country == "Russia"] <- "Russian Federation"
ODB$Country[ODB$Country == "Macedonia"] <- "Macedonia, FYR"
ODB$Country[ODB$Country == "Egypt"] <- "Egypt, Arab Rep."
ODB$Country[ODB$Country == "Saint Lucia"] <- "St. Lucia"
ODB$Country[ODB$Country == "DR Congo"] <- "Congo, Dem. Rep."
ODB$Country[ODB$Country == "Venezuela"] <- "Venezuela, RB"
ODB$Country[ODB$Country == "Palestine"] <- "West Bank and Gaza"
ODB$Country[ODB$Country == "Yemen"] <- "Yemen, Rep."

# edits in ODIN
ODIN$Country[ODIN$Country == "Slovakia"] <- "Slovak Republic"
ODIN$Country[ODIN$Country == "Kyrgyzstan"] <- "Kyrgyz Republic"
ODIN$Country[ODIN$Country == "Palestine"] <- "West Bank and Gaza"
ODIN$Country[ODIN$Country == "Taiwan"] <- "Taiwan, China"
ODIN$Country[ODIN$Country == "Egypt"] <- "Egypt, Arab Rep."
ODIN$Country[ODIN$Country == "Venezuela"] <- "Venezuela, RB"
ODIN$Country[ODIN$Country == "St. Vincent & Grenadines"] <- "St. Vincent and the Grenadines"
ODIN$Country[ODIN$Country == "The Bahamas"] <- "Bahamas, The"
ODIN$Country[ODIN$Country == "The Gambia"] <- "Gambia, The"
ODIN$Country[ODIN$Country == "Cote d'Ivoire"] <- ODB$Country[95]


# edits in GODI
GODI$name[GODI$name == "Taiwan"] <- "Taiwan, China"
GODI$name[GODI$name == "Slovakia"] <- "Slovak Republic"
GODI$name[GODI$name == "Great Britain"] <- "United Kingdom"
GODI$name[GODI$name == "Hong Kong"] <- "Hong Kong SAR, China"
GODI$name[GODI$name == "Russia"] <- "Russian Federation"
GODI$name[GODI$name == "Macedonia"] <- "Macedonia, FYR"
GODI$name[GODI$name == "Iran"] <- "Iran, Islamic Rep."
GODI$name[GODI$name == "The Bahamas"] <- "Bahamas, The"
GODI$name[GODI$name == "Saint Lucia"] <- "St. Lucia"
GODI$name[GODI$name == "Venezuela"] <- "Venezuela, RB"
GODI$name[GODI$name == "Saint Vincent and the Grenadines"] <- "St. Vincent and the Grenadines"
GODI$name[GODI$name == "Saint Kitts and Nevis"] <- "St. Kitts and Nevis"

# add region code to class dataframe
# note I add the "LAC" code AFTER "HIC" to add High Income countries from
# LAC (Uruguay and Chile, for example) in the LAC group.

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "South Asia") {
            class$group[i] <- "SAS"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "Sub-Saharan Africa") {
            class$group[i] <- "SSA"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "East Asia & Pacific") {
            class$group[i] <- "EAP"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "Middle East & North Africa") {
            class$group[i] <- "MNA"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "Europe & Central Asia") {
            class$group[i] <- "ECA"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Income.group[i]))) {
        if (as.character(class$Income.group[i]) == "High income") {
            class$group[i] <- "HIC"
        }
    }
}

for (i in 1:nrow(class)) {
    if (!is.na(as.character(class$Region[i]))) {
        if (as.character(class$Region[i]) == "Latin America & Caribbean") {
            class$group[i] <- "LAC"
        }
    }
}

# Add regions to indicators dataframes

GODI <- merge(GODI,class[,c(3,6,13)],by.x="name", by.y="Economy", all.x = TRUE)
ODIN <- merge(ODIN,class[,c(3,6,13)],by.x="Country", by.y="Economy", all.x = TRUE)
ODB <- merge(ODB,class[,c(3,6,13)],by.x="Country", by.y="Economy", all.x = TRUE)
GODI <- GODI[!is.na(GODI$group),]
ODIN <- ODIN[!is.na(ODIN$group),]
ODB <- ODB[!is.na(ODB$group),]

# Graphs per indicator

if (require("ggplot2") == FALSE) {
    install.packages("ggplot2")
}

require(ggplot2)

ggplot(GODI,aes(x=reorder(group,Score.GODI,median),y=Score.GODI))+
    geom_boxplot(outlier.color="NA",fill="blue")+geom_jitter(size=1,alpha=0.7)+
    guides(fill=FALSE)+ylim(0,100)+theme_economist()+
    labs(title="Global Open Data Index", subtitle="Regional scores")+
    xlab("Region")+ylab("Score")

ggplot(ODB,aes(x=reorder(group,Score.ODB,median),y=Score.ODB))+
    geom_boxplot(outlier.color="NA",fill="brown1")+geom_jitter(size=1,alpha=0.7)+
    guides(fill=FALSE)+ylim(0,100)+theme_economist()+
    labs(title="Open Data Barometer", subtitle="Regional scores")+
    xlab("Region")+ylab("Score")

ggplot(ODIN,aes(x=reorder(group,Overall,median),y=Overall))+
    geom_boxplot(outlier.color="NA",fill="brown1")+geom_jitter(size=1,alpha=0.7)+
    guides(fill=FALSE)+ylim(0,100)+theme_economist()+
    labs(title="Open Data Inventory", subtitle="Regional scores")+
    xlab("Region")+ylab("Score")

allin <- merge(GODI[!is.na(GODI$group),c(1,8)],ODB[!is.na(ODB$group),c(1,7)],
               by.x="name",by.y="Country",all = TRUE)
allin <- merge(ODIN[!is.na(ODIN$group),c(1,7)],allin,by.x="Country",by.y="name",all = TRUE)
allin <- merge(allin,class[,c(3,13)],by.x="Country",by.y="Economy",all.x=TRUE)

if (require("reshape2") == FALSE) {
    install.packages("reshape2")
}

cbPalette <- c("#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

require(reshape2)

allmelt <- melt(allin,measure.vars = c("Score.ODB","Score.GODI","Score.ODIN"))
allmelt <- allmelt[!is.na(allmelt$value),]

g <- ggplot(allmelt,aes(x=reorder(group,value,median),y=value))+
    geom_boxplot(outlier.color="NA")+geom_jitter(size=1,alpha=0.7)+facet_wrap(~variable)+guides(fill=FALSE)+ylim(0,101)+theme_economist()+
    labs(title="Open Data Indicators", subtitle="Regional Scores in ODB, GODI and ODIN")+
    xlab("Region")+ylab("Score")


q <- ggplot() + geom_point(data = ODB, aes(x=Readiness, y=Implementation, 
                                           size=Impact, fill=group), alpha=0.5,shape=21) +
    scale_size(range = c(1,15)) + xlim(0,100) + ylim(0,120) + 
    scale_fill_manual(values = cbPalette) + theme(legend.position="right")+
    geom_smooth(data = ODB, aes(x=Readiness, y=Implementation), method="lm",
                formula = (y ~ poly(x,2)), color = "red", se = FALSE, alpha = 0.5) + 
    guides(fill = guide_legend(override.aes = list(size = 5)))+
    labs(title="Open Data Barometer 2016", 
         subtitle="Implementation, Readiness, and Impact")
