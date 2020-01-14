rm(list=ls())
require("twitteR")
require("tidytext")
require("dplyr")
require("ggplot2")

# install.packages("RPostgreSQL")
require("RPostgreSQL")
require("ggfortify")
#install_github("hofnerb/papeR")
require("papeR")

#To install the latest development version, one can use devtools to install packages from GitHub. 
#Therefore we need to install and load devtools before we can install papeR:
    
require("devtools")
library("devtools")
source("queries.R")
# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
    ""
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "GT-DB",
                 host = "localhost", port = 5432,
                 user = "postgres", password = pw)

# check for the cartable
dbExistsTable(con, "gt_ticker_price")
# Must be TRUE
# Read the following ccy pairs:
# AUDUSD
# EURUSD
# GBPUSD
# USDCAD
# USDCHF
# USDJPY
# USDPLN

# 1 - AUD/USD
aud_usd_df = dbGetQuery(con, GET_AUDUSD_SQL)
summary(aud_usd_df)
knitr::kable(summary(aud_usd_df))

# 2 - EUR/USD
eur_usd_df = dbGetQuery(con, GET_EURUSD_SQL)
summary(eur_usd_df)
knitr::kable(summary(eur_usd_df))

# 3 - GBP/USD
gbp_usd_df = dbGetQuery(con, GET_GBPUSD_SQL)
summary(gbp_usd_df)
knitr::kable(summary(gbp_usd_df))

# 4 - USD/CAD
usd_cad_df = dbGetQuery(con, GET_USDCAD_SQL)
summary(usd_cad_df)
knitr::kable(summary(usd_cad_df))

cad_usd_df = dbGetQuery(con, GET_CADUSD_SQL)
summary(cad_usd_df)
knitr::kable(summary(cad_usd_df))

# 5 - USD/CHF
usd_chf_df = dbGetQuery(con, GET_USDCHF_SQL)
summary(usd_chf_df)
knitr::kable(summary(usd_chf_df))

# 6 - USD/JPY
usd_jpy_df = dbGetQuery(con, GET_USDJPY_SQL)
summary(usd_jpy_df)
knitr::kable(summary(usd_jpy_df))

# 7 - USD/PLN
usd_pln_df = dbGetQuery(con, GET_USDPLN_SQL)
summary(usd_pln_df)
knitr::kable(summary(usd_pln_df))

# close the connection
dbDisconnect(con)
dbUnloadDriver(drv)

library(tseries)
library(ggplot2)
library(xts)


# -------------- AUD/USD --------------------------
ggplot(data = aud_usd_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "cyan4", size = 0.5) +
    ylab('AUD/USD Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(aud_usd_df$ask_close)
kpss.test(aud_usd_df$ask_close)

#################################################################################
#class(aud_usd_df$cob_date)
#
#aud_usd_xts <- xts(x = aud_usd_df$ask_close, 
#                   order.by = aud_usd_df$cob_date, 
#                   frequency=365)
#aud_usd_xts <- na.locf(aud_usd_xts)
#plot(aud_usd_xts)
#aud_usd_xts = aud_usd_xts["2010-09/2019-10"]
################################################################################

aud_usd_ts = ts(as.vector(aud_usd_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="AUD/USD Price")   
aud_usd_ts = na.locf(aud_usd_ts)
plot(aud_usd_ts)
fit <- stl(aud_usd_ts, s.window="periodic")
plot(fit, main="AUD/USD Currency Pair", col="cyan4")

# --2-- -------------- EUR/USD --------------------------
ggplot(data = eur_usd_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "firebrick1", size = 0.5)  +
    ylab('EUR/USD Currency Pair')  + xlab("Close of Business Date (COB)")
adf.test(eur_usd_df$ask_close)
kpss.test(eur_usd_df$ask_close)

eur_usd_ts = ts(as.vector(eur_usd_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="EUR/USD Price")   
eur_usd_ts = na.locf(eur_usd_ts)
plot(eur_usd_ts)
fit <- stl(eur_usd_ts, s.window="periodic")
plot(fit, main="EUR/USD Currency Pair", col="firebrick1")


# --3-- -------------- GBP/USD --------------------------
ggplot(data = gbp_usd_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "darkgreen", size = 0.5)  +
    ylab('GBP/USD Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(gbp_usd_df$ask_close)
kpss.test(gbp_usd_df$ask_close)

gbp_usd_ts = ts(as.vector(gbp_usd_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="GBP/USD Price")   
gbp_usd_ts = na.locf(gbp_usd_ts)
plot(gbp_usd_ts)
fit <- stl(gbp_usd_ts, s.window="periodic")
plot(fit, main="GBP/USD Currency Pair", col="darkgreen")


# --4.1-- -------------- USD/CAD --------------------------
ggplot(data = usd_cad_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "deeppink", size = 0.5)  +
    ylab('USD/CAD Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(usd_cad_df$ask_close)
kpss.test(usd_cad_df$ask_close)

usd_cad_ts = ts(as.vector(usd_cad_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="USD/CAD Price")   
usd_cad_ts = na.locf(usd_cad_ts)
plot(usd_cad_ts)
fit <- stl(usd_cad_ts, s.window="periodic")
plot(fit, main="USD/CAD Currency Pair", col="deeppink")

# --4.2-- -------------- CAD/USD --------------------------
ggplot(data = cad_usd_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "deeppink", size = 0.5)  +
    ylab('CAD/USD Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(cad_usd_df$ask_close)
kpss.test(cad_usd_df$ask_close)

# --5-- -------------- USD/CHF --------------------------
ggplot(data = usd_chf_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "hotpink4", size = 0.5)  +
    ylab('USD/CHF Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(usd_chf_df$ask_close)
kpss.test(usd_chf_df$ask_close)

usd_chf_ts = ts(as.vector(usd_chf_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="USD/CHF Price")   
usd_chf_ts = na.locf(usd_chf_ts)
plot(usd_chf_ts)
fit <- stl(usd_chf_ts, s.window="periodic")
plot(fit, main="USD/CHF Currency Pair", col="hotpink")

# --6-- -------------- USD/JPY --------------------------
ggplot(data = usd_jpy_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "mediumblue", size = 0.5)  +
    ylab('USD/JPY Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(usd_jpy_df$ask_close)
kpss.test(usd_jpy_df$ask_close)

usd_jpy_ts = ts(as.vector(usd_jpy_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="USD/JPY Price")   
usd_jpy_ts = na.locf(usd_jpy_ts)
plot(usd_jpy_ts)
fit <- stl(usd_jpy_ts, s.window="periodic")
plot(fit, main="USD/JPY Currency Pair", col="mediumblue")

# --7-- -------------- USD/PLN --------------------------
ggplot(data = usd_pln_df, aes(x = cob_date, y = ask_close))+
    geom_line(color = "darkmagenta", size = 0.5)  +
    ylab('USD/PLN Currency Pair') + xlab("Close of Business Date (COB)")
adf.test(usd_pln_df$ask_close)
kpss.test(usd_pln_df$ask_close)

usd_pln_ts = ts(as.vector(usd_pln_df$ask_close), 
                start=c(2010,1), end=c(2019,10), frequency=365, names="USD/PLN Price")   
usd_pln_ts = na.locf(usd_pln_ts)
plot(usd_pln_ts)
fit <- stl(usd_pln_ts, s.window="periodic")
plot(fit, main="USD/PLN Currency Pair", col="darkmagenta")


diff_aud_usd = diff(aud_usd_df$ask_close, 1)
acf(diff_aud_usd)
adf.test(diff_aud_usd)
kpss.test(diff_aud_usd)

diff_eur_usd = diff(eur_usd_df$ask_close, 1)
acf(diff_eur_usd)
adf.test(diff_eur_usd)
kpss.test(diff_eur_usd)

diff_gbp_usd = diff(gbp_usd_df$ask_close, 1)
acf(diff_gbp_usd)
adf.test(diff_gbp_usd)
kpss.test(diff_gbp_usd)

diff_usd_cad = diff(usd_cad_df$ask_close, 1)
summary(diff_usd_cad)
acf(diff_usd_cad)
adf.test(diff_usd_cad)
kpss.test(diff_usd_cad)

diff_cad_usd = diff(cad_usd_df$ask_close, 1)
summary(diff_cad_usd)
acf(diff_cad_usd)
adf.test(diff_cad_usd)
kpss.test(diff_cad_usd)

diff_usd_chf = diff(usd_chf_df$ask_close, 1)
acf(diff_usd_chf)
adf.test(diff_usd_chf)
kpss.test(diff_usd_chf)

diff_usd_jpy = diff(usd_jpy_df$ask_close, 1)
acf(diff_usd_jpy)
adf.test(diff_usd_jpy)
kpss.test(diff_usd_jpy)

diff_usd_pln = diff(usd_pln_df$ask_close, 1)
acf(diff_usd_pln)
adf.test(diff_usd_pln)
kpss.test(diff_usd_pln)

# AUD/USD
cc_audusd_eurusd = ccf(diff_aud_usd, diff_eur_usd)
cc_audusd_eurusd_df = fortify(cc_audusd_eurusd, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='AUDUSD'
ticker2='EURUSD'
cc_audusd_eurusd_df = data.frame(ticker1, ticker2, cc_audusd_eurusd_df)
write.csv(cc_audusd_eurusd_df,'data/cc_audusd_eurusd.csv')	

cc_eurusd_audusd = ccf(diff_eur_usd, diff_aud_usd)
cc_eurusd_audusd_df = fortify(cc_eurusd_audusd, conf.int.value = 0.95,
                              conf.int = TRUE, conf.int.type = "white")
ticker2='AUDUSD'
ticker1='EURUSD'
cc_eurusd_audusd_df = data.frame(ticker1, ticker2, cc_eurusd_audusd_df)
write.csv(cc_eurusd_audusd_df,'data/cc_eurusd_audusd.csv')



cc_audusd_gbpusd = ccf(diff_aud_usd, diff_gbp_usd)
cc_audusd_gbpusd_df = fortify(cc_audusd_gbpusd, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='AUDUSD'
ticker2='GBPUSD'
cc_audusd_gbpusd_df = data.frame(ticker1, ticker2, cc_audusd_gbpusd_df)
write.csv(cc_audusd_gbpusd_df, 'data/cc_audusd_gbpusd.csv')



cc_gbpusd_audusd = ccf(diff_gbp_usd, diff_aud_usd)
cc_gbpusd_audusd_df = fortify(cc_gbpusd_audusd, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")

ticker1='GBPUSD'
ticker2='AUDUSD'
cc_gbpusd_audusd_df = data.frame(ticker1, ticker2, cc_gbpusd_audusd_df)
write.csv(cc_gbpusd_audusd_df, 'data/cc_gbpusd_audusd.csv')






cc_audusd_usdcad = ccf(diff_aud_usd, diff_usd_cad)
cc_audusd_usdcad_df = fortify(cc_audusd_usdcad, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='AUDUSD'
ticker2='USDCAD'
cc_audusd_usdcad_df = data.frame(ticker1, ticker2, cc_audusd_usdcad_df)
write.csv(cc_audusd_usdcad_df, 'data/cc_audusd_usdcad.csv')


cc_audusd_cadusd = ccf(diff_aud_usd, diff_cad_usd)
cc_audusd_cadusd_df = fortify(cc_audusd_cadusd, conf.int.value = 0.95,
                              conf.int = TRUE, conf.int.type = "white")
ticker1='AUDUSD'
ticker2='CADUSD'
cc_audusd_cadusd_df = data.frame(ticker1, ticker2, cc_audusd_cadusd_df)
write.csv(cc_audusd_cadusd_df, 'data/cc_audusd_cadusd.csv')


cc_audusd_usdcad = ccf(diff_usd_cad, diff_aud_usd)
cc_audusd_usdcad_df = fortify(cc_audusd_usdcad, conf.int.value = 0.95,
                              conf.int = TRUE, conf.int.type = "white")
ticker2='AUDUSD'
ticker1='USDCAD'
cc_audusd_usdcad_df = data.frame(ticker1, ticker2, cc_audusd_usdcad_df)
write.csv(cc_audusd_usdcad_df, 'data/cc_usdcad_audusd.csv')







cc_audusd_usdchf = ccf(diff_aud_usd, diff_usd_chf)
cc_audusd_usdchf_df = fortify(cc_audusd_usdchf, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDCHF'
cc_audusd_usdchf_df = data.frame(ticker1, ticker2, cc_audusd_usdchf_df)
write.csv(cc_audusd_usdchf_df, 'data/cc_audusd_usdchf.csv')

cc_audusd_usdjpy = ccf(diff_aud_usd, diff_usd_jpy)
cc_audusd_usdjpy_df = fortify(cc_audusd_usdjpy, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDJPY'
cc_audusd_usdjpy_df = data.frame(ticker1, ticker2, cc_audusd_usdjpy_df)
write.csv(cc_audusd_usdjpy_df, 'data/cc_audusd_usdjpy.csv')

cc_audusd_usdpln = ccf(diff_aud_usd, diff_usd_pln)
cc_audusd_usdpln_df = fortify(cc_audusd_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDPLN'
cc_audusd_usdpln_df = data.frame(ticker1, ticker2, cc_audusd_usdpln_df)
write.csv(cc_audusd_usdpln_df, 'data/cc_audusd_usdpln.csv')

# EUR/USD
cc_eurusd_gbpusd = ccf(diff_eur_usd, diff_gbp_usd)
cc_eurusd_gbpusd_df = fortify(cc_eurusd_gbpusd, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='EURUSD'
ticker2='GBPUSD'
cc_eurusd_gbpusd_df = data.frame(ticker1, ticker2, cc_eurusd_gbpusd_df)
write.csv(cc_eurusd_gbpusd_df, 'data/cc_eurusd_gbpusd.csv')

cc_eurusd_usdcad = ccf(diff_eur_usd, diff_usd_cad)
cc_eurusd_usdcad_df = fortify(cc_eurusd_usdcad, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDCAD'
cc_eurusd_usdcad_df = data.frame(ticker1, ticker2, cc_eurusd_usdcad_df)
write.csv(cc_eurusd_usdcad_df, 'data/cc_eurusd_usdcad.csv')

cc_eurusd_usdchf = ccf(diff_eur_usd, diff_usd_chf)
cc_eurusd_usdchf_df = fortify(cc_eurusd_usdchf, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDCHF'
cc_eurusd_usdchf_df = data.frame(ticker1, ticker2, cc_eurusd_usdchf_df)
write.csv(cc_eurusd_usdchf_df, 'data/cc_eurusd_usdchf.csv')

cc_eurusd_usdjpy = ccf(diff_eur_usd, diff_usd_jpy)
cc_eurusd_usdjpy_df = fortify(cc_eurusd_usdjpy, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDJPY'
cc_eurusd_usdjpy_df = data.frame(ticker1, ticker2, cc_eurusd_usdjpy_df)
write.csv(cc_eurusd_usdjpy_df, 'data/cc_eurusd_usdjpy.csv')

cc_eurusd_usdpln = ccf(diff_eur_usd, diff_usd_pln)
cc_eurusd_usdpln_df = fortify(cc_eurusd_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDPLN'
cc_eurusd_usdpln_df = data.frame(ticker1, ticker2, cc_eurusd_usdpln_df)
write.csv(cc_eurusd_usdpln_df, 'data/cc_eurusd_usdpln.csv')

# GBP/USD
cc_gbpusd_usdcad = ccf(diff_gbp_usd, diff_usd_cad)
cc_gbpusd_usdcad_df = fortify(cc_gbpusd_usdcad, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='GBPUSD'
ticker2='USDCAD'
cc_gbpusd_usdcad_df = data.frame(ticker1, ticker2, cc_gbpusd_usdcad_df)
write.csv(cc_gbpusd_usdcad_df, 'data/cc_gbpusd_usdcad.csv')

cc_gbpusd_usdchf = ccf(diff_gbp_usd, diff_usd_chf)
cc_gbpusd_usdchf_df = fortify(cc_gbpusd_usdchf, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDCHF'
cc_gbpusd_usdchf_df = data.frame(ticker1, ticker2, cc_gbpusd_usdchf_df)
write.csv(cc_gbpusd_usdchf_df, 'data/cc_gbpusd_usdchf.csv')

cc_gbpusd_usdjpy = ccf(diff_gbp_usd, diff_usd_jpy)
cc_gbpusd_usdjpy_df = fortify(cc_gbpusd_usdjpy, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDJPY'
cc_gbpusd_usdjpy_df = data.frame(ticker1, ticker2, cc_gbpusd_usdjpy_df)
write.csv(cc_gbpusd_usdjpy_df, 'data/cc_gbpusd_usdjpy.csv')

cc_gbpusd_usdpln = ccf(diff_gbp_usd, diff_usd_pln)
cc_gbpusd_usdpln_df = fortify(cc_gbpusd_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDPLN'
cc_gbpusd_usdpln_df = data.frame(ticker1, ticker2, cc_gbpusd_usdpln_df)
write.csv(cc_gbpusd_usdpln_df, 'data/cc_gbpusd_usdpln.csv')

# USD/CAD
cc_usdcad_usdchf = ccf(diff_usd_cad, diff_usd_chf)
cc_usdcad_usdchf_df = fortify(cc_usdcad_usdchf, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='USDCAD'
ticker2='USDCHF'
cc_usdcad_usdchf_df = data.frame(ticker1, ticker2, cc_usdcad_usdchf_df)
write.csv(cc_usdcad_usdchf_df, 'data/cc_usdcad_usdchf.csv')

cc_usdcad_usdjpy = ccf(diff_usd_cad, diff_usd_jpy)
cc_usdcad_usdjpy_df = fortify(cc_usdcad_usdjpy, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDJPY'
cc_usdcad_usdjpy_df = data.frame(ticker1, ticker2, cc_usdcad_usdjpy_df)
write.csv(cc_usdcad_usdjpy_df, 'data/cc_usdcad_usdjpy.csv')

cc_usdcad_usdpln = ccf(diff_usd_cad, diff_usd_pln)
cc_usdcad_usdpln_df = fortify(cc_usdcad_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDPLN'
cc_usdcad_usdpln_df = data.frame(ticker1, ticker2, cc_usdcad_usdpln_df)
write.csv(cc_usdcad_usdpln_df, 'data/cc_usdcad_usdpln.csv')


# USD/CHF
cc_usdchf_usdjpy = ccf(diff_usd_chf, diff_usd_jpy)
cc_usdchf_usdjpy_df = fortify(cc_usdchf_usdjpy, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='USDCHF'
ticker2='USDJPY'
cc_usdchf_usdjpy_df = data.frame(ticker1, ticker2, cc_usdchf_usdjpy_df)
write.csv(cc_usdchf_usdjpy_df, 'data/cc_usdchf_usdjpy.csv')

cc_usdchf_usdpln = ccf(diff_usd_chf, diff_usd_pln)
cc_usdchf_usdpln_df = fortify(cc_usdchf_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker2='USDPLN'
cc_usdchf_usdpln_df = data.frame(ticker1, ticker2, cc_usdchf_usdpln_df)
write.csv(cc_usdchf_usdpln_df, 'data/cc_usdchf_usdpln.csv')

# USD/JPY
cc_usdjpy_usdpln = ccf(diff_usd_jpy, diff_usd_pln)
cc_usdjpy_usdpln_df = fortify(cc_usdjpy_usdpln, conf.int.value = 0.95,
        conf.int = TRUE, conf.int.type = "white")
ticker1='USDJPY'
ticker2='USDPLN'
cc_usdjpy_usdpln_df = data.frame(ticker1, ticker2, cc_usdjpy_usdpln_df)
write.csv(cc_usdjpy_usdpln_df, 'data/cc_usdjpy_usdpln.csv')

all_cc_df <- rbind(cc_audusd_eurusd_df, cc_audusd_gbpusd_df, cc_audusd_usdcad_df,
	  	  cc_audusd_usdchf_df, cc_audusd_usdjpy_df, cc_audusd_usdpln_df,
		    cc_eurusd_gbpusd_df, cc_eurusd_usdcad_df, cc_eurusd_usdchf_df,
	  cc_eurusd_usdjpy_df, cc_eurusd_usdpln_df, cc_gbpusd_usdcad_df,
	  cc_gbpusd_usdchf_df, cc_gbpusd_usdjpy_df, cc_gbpusd_usdpln_df,
	  cc_usdcad_usdchf_df, cc_usdcad_usdjpy_df, cc_usdcad_usdpln_df,
	  cc_usdchf_usdjpy_df, cc_usdchf_usdpln_df, cc_usdjpy_usdpln_df)
all_cc_df = cbind(all_cc_df, ABS_ACF=abs(all_cc_df$ACF))
write.csv(all_cc_df, "data/cc_all_ccy_pairs_abs.csv")

plot(diff_aud_usd)


require("pracma")

log_diff_aud_usd = diff(log(aud_usd_df$ask_close), lag=30)
hurstexp(log_diff_aud_usd, d=50, display=TRUE)

log_diff_eur_usd = diff(log(eur_usd_df$ask_close), lag=30)
hurstexp(log_diff_eur_usd, d=50, display=TRUE)

log_diff_gbp_usd = diff(log(gbp_usd_df$ask_close), lag=30)
hurstexp(log_diff_gbp_usd, d=50, display=TRUE)

log_diff_usd_cad = diff(log(usd_cad_df$ask_close), lag=30)
hurstexp(log_diff_usd_cad, d=50, display=TRUE)

log_diff_usd_chf = diff(log(usd_chf_df$ask_close), lag=30)
hurstexp(log_diff_usd_chf, d=50, display=TRUE)

log_diff_usd_jpy = diff(log(usd_jpy_df$ask_close), lag=30)
hurstexp(log_diff_usd_jpy, d=50, display=TRUE)

log_diff_usd_pln = diff(log(usd_pln_df$ask_close), lag=30)
hurstexp(log_diff_usd_pln, d=50, display=TRUE)

# close the connection
dbDisconnect(con)
dbUnloadDriver(drv)



# Core Tidyverse
library(tidyverse)
library(glue)
library(forcats)

# Time Series
library(timetk)
library(tidyquant)
library(tibbletime)

# Visualization
library(cowplot)

# Preprocessing
library(recipes)

# Sampling / Accuracy
library(rsample)
library(yardstick) 

# Modeling
library(keras)


#install_keras()

p1 <- aud_usd_df %>%
    ggplot(aes(cob_date, ask_close)) +
    geom_point(color = palette_light()[[1]], alpha = 0.5) +
    theme_tq() +
    labs(
        title = "From 2010-01-04 to 2019-10-31"
    )

p_title <- ggdraw() + 
    draw_label("Ticker AUD/USD", size = 18, fontface = "bold", colour = palette_light()[[1]])

plot_grid(p_title, p1, ncol = 1, rel_heights = c(0.1, 1, 1))

tidy_acf <- function(data, value, lags = 0:30) {
    
    value_expr <- enquo(value)
    
    acf_values <- data %>%
        pull(value) %>%
        acf(lag.max = tail(lags, 1), plot = FALSE) %>%
        .$acf %>%
        .[,,1]
    
    ret <- tibble(acf = acf_values) %>%
        rowid_to_column(var = "lag") %>%
        mutate(lag = lag - 1) %>%
        filter(lag %in% lags)
    
    return(ret)
}


#max_lag <- 30

periods_train <- 960
periods_test  <- 120
skip_span     <- 240

rolling_origin_resamples <- rolling_origin(
    aud_usd_df,
    initial    = periods_train,
    assess     = periods_test,
    cumulative = FALSE,
    skip       = skip_span
)

rolling_origin_resamples







# Plotting function for a single split
plot_split <- function(split, expand_y_axis = TRUE, alpha = 1, size = 1, base_size = 14) {
    
    # Manipulate data
    train_tbl <- training(split) %>%
        add_column(key = "training") 
    
    test_tbl  <- testing(split) %>%
        add_column(key = "testing") 
    
    data_manipulated <- bind_rows(train_tbl, test_tbl) %>%
        as_tbl_time(index = cob_date) %>%
        mutate(key = fct_relevel(key, "training", "testing"))
    
    # Collect attributes
    train_time_summary <- train_tbl %>%
        tk_index() %>%
        tk_get_timeseries_summary()
    
    test_time_summary <- test_tbl %>%
        tk_index() %>%
        tk_get_timeseries_summary()
    
    # Visualize
    g <- data_manipulated %>%
        ggplot(aes(x = cob_date, y = ask_close, color = key)) +
        geom_line(size = size, alpha = alpha) +
        theme_tq(base_size = base_size) +
        scale_color_tq() +
        labs(
            title    = glue("Split: {split$id}"),
            subtitle = glue("{train_time_summary$start} to {test_time_summary$end}"),
            y = "", x = ""
        ) +
        theme(legend.position = "none") 
    
    if (expand_y_axis) {
        
        time_summary <- aud_usd_df %>% 
            tk_index() %>% 
            tk_get_timeseries_summary()
        
        g <- g +
            scale_x_date(limits = c(time_summary$start, 
                                    time_summary$end))
    }
    
    return(g)
}

rolling_origin_resamples$splits[[1]] %>%
    plot_split(expand_y_axis = TRUE) +
    theme(legend.position = "bottom")


# Plotting function that scales to all splits 
plot_sampling_plan <- function(sampling_tbl, expand_y_axis = TRUE, 
                               ncol = 3, alpha = 1, size = 1, base_size = 14, 
                               title = "Sampling Plan") {
    
    # Map plot_split() to sampling_tbl
    sampling_tbl_with_plots <- sampling_tbl %>%
        mutate(gg_plots = map(splits, plot_split, 
                              expand_y_axis = expand_y_axis,
                              alpha = alpha, base_size = base_size))
    
    # Make plots with cowplot
    plot_list <- sampling_tbl_with_plots$gg_plots 
    
    p_temp <- plot_list[[1]] + theme(legend.position = "bottom")
    legend <- get_legend(p_temp)
    
    p_body  <- plot_grid(plotlist = plot_list, ncol = ncol)
    
    p_title <- ggdraw() + 
        draw_label(title, size = 18, fontface = "bold", colour = palette_light()[[1]])
    
    g <- plot_grid(p_title, p_body, legend, ncol = 1, rel_heights = c(0.05, 1, 0.05))
    
    return(g)
    
}

rolling_origin_resamples %>%
    plot_sampling_plan(expand_y_axis = T, ncol = 3, alpha = 1, size = 1, base_size = 10, 
                       title = "Backtesting Strategy: Rolling Origin Sampling Plan")



rolling_origin_resamples %>%
    plot_sampling_plan(expand_y_axis = F, ncol = 3, alpha = 1, size = 1, base_size = 10, 
                       title = "Backtesting Strategy: Zoomed In")


split    <- rolling_origin_resamples$splits[[10]]
split_id <- rolling_origin_resamples$id[[10]]

plot_split(split, expand_y_axis = FALSE, size = 0.5) +
    theme(legend.position = "bottom") +
    ggtitle(glue("Split: {split_id}"))

# Train/testing data preprocessing

df_trn <- training(split)
df_tst <- testing(split)

df <- bind_rows(
    df_trn %>% add_column(key = "training"),
    df_tst %>% add_column(key = "testing")
) %>% 
    as_tbl_time(index = cob_date)

df



rec_obj <- recipe(ask_close ~ ., df) %>%
    step_sqrt(ask_close) %>%
    step_center(ask_close) %>%
    step_scale(ask_close) %>%
    prep()

df_processed_tbl <- bake(rec_obj, df)

df_processed_tbl



center_history <- rec_obj$steps[[2]]$means["ask_close"]
scale_history  <- rec_obj$steps[[3]]$sds["ask_close"]

c("center" = center_history, "scale" = scale_history)


## Model input
## 

lag_setting  = 120 
batch_size   = 40
train_length = 440
tsteps       = 1
epochs       = 300


# Training Set
lag_train_tbl <- df_processed_tbl %>%
    mutate(value_lag = lag(ask_close, n = lag_setting)) %>%
    filter(!is.na(value_lag)) %>%
    filter(key == "training") %>%
    tail(train_length)

x_train_vec <- lag_train_tbl$value_lag
x_train_arr <- array(data = x_train_vec, dim = c(length(x_train_vec), 1, 1))

y_train_vec <- lag_train_tbl$ask_close
y_train_arr <- array(data = y_train_vec, dim = c(length(y_train_vec), 1))
lag_train_tbl


# Testing Set
lag_test_tbl <- df_processed_tbl %>%
    mutate(
        value_lag = lag(ask_close, n = lag_setting)
    ) %>%
    filter(!is.na(value_lag)) %>%
    filter(key == "testing")

x_test_vec <- lag_test_tbl$value_lag
x_test_arr <- array(data = x_test_vec, dim = c(length(x_test_vec), 1, 1))

y_test_vec <- lag_test_tbl$ask_close
y_test_arr <- array(data = y_test_vec, dim = c(length(y_test_vec), 1))
lag_test_tbl

# Model Implementation <-------------------
model <- keras_model_sequential()

model %>%
    layer_lstm(units            = 50, 
               input_shape      = c(tsteps, 1), 
               batch_size       = batch_size,
               return_sequences = TRUE, 
               stateful         = TRUE) %>% 
    layer_lstm(units            = 50, 
               return_sequences = FALSE, 
               stateful         = TRUE) %>% 
    layer_dense(units = 1)

model %>% 
    compile(loss = 'mae', optimizer = 'adam')

model

# Fitting the model by reseting state for each epoch

for (i in 1:epochs) {
    model %>% fit(x          = x_train_arr, 
                  y          = y_train_arr, 
                  batch_size = batch_size,
                  epochs     = 1, 
                  verbose    = 1, 
                  shuffle    = FALSE)
    
    model %>% reset_states()
    cat("Epoch: ", i)
    
}

# Make Predictions
pred_out <- model %>% 
    predict(x_test_arr, batch_size = batch_size) %>%
    .[,1] 

# Retransform values
pred_tbl <- tibble(
    cob_date   = lag_test_tbl$cob_date,
    ask_close   = (pred_out * scale_history + center_history)^2
) 

# Combine actual data with predictions
tbl_1 <- df_trn %>%
    add_column(key = "actual")

tbl_2 <- df_tst %>%
    add_column(key = "actual")

tbl_3 <- pred_tbl %>%
    add_column(key = "predict")

# Create time_bind_rows() to solve dplyr issue
time_bind_rows <- function(data_1, data_2, index) {
    index_expr <- enquo(index)
    bind_rows(data_1, data_2) %>%
        as_tbl_time(index = !! index_expr)
}

ret <- list(tbl_1, tbl_2, tbl_3) %>%
    reduce(time_bind_rows, index = cob_date) %>%
    arrange(key, cob_date) %>%
    mutate(key = as_factor(key))

ret

# Create time_bind_rows() to solve dplyr issue
#time_bind_rows <- function(data_1, data_2, index) {
#    index_expr <- enquo(index)
#    bind_rows(data_1, data_2) %>%
#        as_tbl_time(index = !! index_expr)
#}

#ret <- list(tbl_1, tbl_2, tbl_3) %>%
#    reduce(time_bind_rows, index = cob_date) %>%
#    arrange(key, cob_date) %>%
#    mutate(key = as_factor(key))

#ret

# MODEL PERFORMANCE ASSESSMENT


calc_rmse <- function(prediction_tbl) {
    
    rmse_calculation <- function(data) {
        data %>%
            spread(key = key, value = ask_close) %>%
            select(-cob_date) %>%
            filter(!is.na(predict)) %>%
            rename(
                truth    = actual,
                estimate = predict
            ) %>%
            rmse(truth, estimate)
    }
    
    safe_rmse <- possibly(rmse_calculation, otherwise = NA)
    
    val = safe_rmse(prediction_tbl)
    val[1,3]
    
}

calc_rmse(ret)




# Setup single plot function
plot_prediction <- function(data, id, alpha = 1, size = 2, base_size = 14) {
    
    rmse_val = calc_rmse(data)
    rmse_val
    g <- data %>%
        ggplot(aes(cob_date, ask_close, color = key)) +
        geom_point(alpha = alpha, size = size) + 
        theme_tq(base_size = base_size) +
        scale_color_tq() +
        theme(legend.position = "none") +
#        labs(title = glue("{id}, RMSE: {rmse_val}"))
        labs(
#            title = glue("{id}, RMSE: {round(rmse_val, digits = 1)}"),
            title = glue("{id} - RMSE: {rmse_val}"),
            x = "", y = ""
        )
    
    return(g)
}
#rmse_val = calc_rmse(ret)
#val = rmse_val[1,3]
#val
ret %>% 
    plot_prediction(id = split_id, alpha = 0.65) +
    theme(legend.position = "bottom")


# BUILDING PREDICTION FUNCTION - BEGIN


predict_keras_lstm <- function(split, epochs = 300, ...) {
    
    lstm_prediction <- function(split, epochs, ...) {
        
        # 5.1.2 Data Setup
        df_trn <- training(split)
        df_tst <- testing(split)
        
        df <- bind_rows(
            df_trn %>% add_column(key = "training"),
            df_tst %>% add_column(key = "testing")
        ) %>% 
            as_tbl_time(index = cob_date)
        
        # 5.1.3 Preprocessing
        rec_obj <- recipe(ask_close ~ ., df) %>%
            step_sqrt(ask_close) %>%
            step_center(ask_close) %>%
            step_scale(ask_close) %>%
            prep()
        
        df_processed_tbl <- bake(rec_obj, df)
        
        center_history <- rec_obj$steps[[2]]$means["value"]
        scale_history  <- rec_obj$steps[[3]]$sds["value"]
        
        # 5.1.4 LSTM Plan
        lag_setting  <- 120
        batch_size   <- 40
        train_length <- 440
        tsteps       <- 1
        epochs       <- epochs
        
        # 5.1.5 Train/Test Setup
        lag_train_tbl <- df_processed_tbl %>%
            mutate(value_lag = lag(ask_close, n = lag_setting)) %>%
            filter(!is.na(value_lag)) %>%
            filter(key == "training") %>%
            tail(train_length)
        
        x_train_vec <- lag_train_tbl$value_lag
        x_train_arr <- array(data = x_train_vec, dim = c(length(x_train_vec), 1, 1))
        
        y_train_vec <- lag_train_tbl$ask_close
        y_train_arr <- array(data = y_train_vec, dim = c(length(y_train_vec), 1))
        
        lag_test_tbl <- df_processed_tbl %>%
            mutate(
                value_lag = lag(ask_close, n = lag_setting)
            ) %>%
            filter(!is.na(value_lag)) %>%
            filter(key == "testing")
        
        x_test_vec <- lag_test_tbl$value_lag
        x_test_arr <- array(data = x_test_vec, dim = c(length(x_test_vec), 1, 1))
        
        y_test_vec <- lag_test_tbl$ask_close
        y_test_arr <- array(data = y_test_vec, dim = c(length(y_test_vec), 1))
        
        # 5.1.6 LSTM Model
        model <- keras_model_sequential()
        
        model %>%
            layer_lstm(units            = 50, 
                       input_shape      = c(tsteps, 1), 
                       batch_size       = batch_size,
                       return_sequences = TRUE, 
                       stateful         = TRUE) %>% 
            layer_lstm(units            = 50, 
                       return_sequences = FALSE, 
                       stateful         = TRUE) %>% 
            layer_dense(units = 1)
        
        model %>% 
            compile(loss = 'mae', optimizer = 'adam')
        
        # 5.1.7 Fitting LSTM
        for (i in 1:epochs) {
            model %>% fit(x          = x_train_arr, 
                          y          = y_train_arr, 
                          batch_size = batch_size,
                          epochs     = 1, 
                          verbose    = 1, 
                          shuffle    = FALSE)
            
            model %>% reset_states()
            cat("Epoch: ", i)
            
        }
        
        # 5.1.8 Predict and Return Tidy Data
        # Make Predictions
        pred_out <- model %>% 
            predict(x_test_arr, batch_size = batch_size) %>%
            .[,1] 
        
        # Retransform values
        pred_tbl <- tibble(
            cob_date   = lag_test_tbl$cob_date,
            ask_close   = (pred_out * scale_history + center_history)^2
        ) 
        
        # Combine actual data with predictions
        tbl_1 <- df_trn %>%
            add_column(key = "actual")
        
        tbl_2 <- df_tst %>%
            add_column(key = "actual")
        
        tbl_3 <- pred_tbl %>%
            add_column(key = "predict")
        
        # Create time_bind_rows() to solve dplyr issue
        time_bind_rows <- function(data_1, data_2, index) {
            index_expr <- enquo(index)
            bind_rows(data_1, data_2) %>%
                as_tbl_time(index = !! index_expr)
        }
        
        ret <- list(tbl_1, tbl_2, tbl_3) %>%
            reduce(time_bind_rows, index = cob_date) %>%
            arrange(key, cob_date) %>%
            mutate(key = as_factor(key))
        
        return(ret)
        
    }
    
    safe_lstm <- possibly(lstm_prediction, otherwise = NA)
    
    safe_lstm(split, epochs, ...)
    
}

# PREDICTION FUNCTION - END



predict_keras_lstm(split, epochs = 10)


# NOT WORKING 
#sample_predictions_lstm_tbl <- rolling_origin_resamples %>%
#    mutate(predict = map(splits, predict_keras_lstm, epochs = 300))
#sample_predictions_lstm_tbl
#val = sample_predictions_lstm_tbl[1,3]
#val[1]
#
#calc_rmse(ret)
#
#summary(val[1])
#sample_rmse_tbl <- sample_predictions_lstm_tbl %>%
#    mutate(rmse = map(predict, calc_rmse)) %>%
#    select(id, rmse)
#summary(sample_rmse_tbl)

ID <- c("Slice01",
        "Slice02",
        "Slice03",
        "Slice04",
        "Slice05",
        "Slice06",
        "Slice07",
        "Slice08",
        "Slice09",
        "Slice10",
        "Slice11")

RMSE <- c(0.0349,
          0.0799,
          0.0931,
          0.0415,
          0.1721,
          0.0933,
          0.041,
          0.0302,
          0.0266,
          0.0557,
          0.0295)

# Join the variables to create a data frame
df <- data.frame(ID, RMSE)
sample_rmse_tbl = as_tibble(df)


sample_rmse_tbl %>%
    ggplot(aes(RMSE)) +
    geom_histogram(aes(y = ..density..), fill = palette_light()[[1]], bins = 16) +
    geom_density(fill = palette_light()[[1]], alpha = 0.5) +
    theme_tq() +
    ggtitle("Histogram of RMSE")

dat = list(0.0349,
           0.0799,
           0.0931,
           0.0415,
           0.1721,
           0.0933,
           0.041,
           0.0302,
           0.0266,
           0.0557,
           0.0295)
sapply(dat, mean)
#sample_rmse_tbl %>%
#    summarize(
#        mean_rmse = mean(sample_rmse_tbl$RMSE),
#        sd_rmse   = sd(sample_rmse_tbl$RMSE)
#    )


#rm(RMSE)
#sample_rmse_tbl %>%
#    summarize(
#        mean_rmse = mean(RMSE),
#        sd_rmse   = sd(RMSE)
#    )



predict_keras_lstm_future <- function(data, epochs = 300, ...) {
    
    lstm_prediction <- function(data, epochs, ...) {
        
        # 5.1.2 Data Setup (MODIFIED)
        df <- data
        
        # 5.1.3 Preprocessing
        rec_obj <- recipe(ask_close ~ ., df) %>%
            step_sqrt(ask_close) %>%
            step_center(ask_close) %>%
            step_scale(ask_close) %>%
            prep()
        
        df_processed_tbl <- bake(rec_obj, df)
        
        center_history <- rec_obj$steps[[2]]$means["value"]
        scale_history  <- rec_obj$steps[[3]]$sds["value"]
        
        # 5.1.4 LSTM Plan
        lag_setting  <- 120
        batch_size   <- 40
        train_length <- 440
        tsteps       <- 1
        epochs       <- epochs
        
        # 5.1.5 Train Setup (MODIFIED)
        lag_train_tbl <- df_processed_tbl %>%
            mutate(value_lag = lag(ask_close, n = lag_setting)) %>%
            filter(!is.na(value_lag)) %>%
            tail(train_length)
        
        x_train_vec <- lag_train_tbl$value_lag
        x_train_arr <- array(data = x_train_vec, dim = c(length(x_train_vec), 1, 1))
        
        y_train_vec <- lag_train_tbl$ask_close
        y_train_arr <- array(data = y_train_vec, dim = c(length(y_train_vec), 1))
        
        x_test_vec <- y_train_vec %>% tail(lag_setting)
        x_test_arr <- array(data = x_test_vec, dim = c(length(x_test_vec), 1, 1))
        
        # 5.1.6 LSTM Model
        model <- keras_model_sequential()
        
        model %>%
            layer_lstm(units            = 50, 
                       input_shape      = c(tsteps, 1), 
                       batch_size       = batch_size,
                       return_sequences = TRUE, 
                       stateful         = TRUE) %>% 
            layer_lstm(units            = 50, 
                       return_sequences = FALSE, 
                       stateful         = TRUE) %>% 
            layer_dense(units = 1)
        
        model %>% 
            compile(loss = 'mae', optimizer = 'adam')
        
        # 5.1.7 Fitting LSTM
        for (i in 1:epochs) {
            model %>% fit(x          = x_train_arr, 
                          y          = y_train_arr, 
                          batch_size = batch_size,
                          epochs     = 1, 
                          verbose    = 1, 
                          shuffle    = FALSE)
            
            model %>% reset_states()
            cat("Epoch: ", i)
            
        }
        
        # 5.1.8 Predict and Return Tidy Data (MODIFIED)
        # Make Predictions
        pred_out <- model %>% 
            predict(x_test_arr, batch_size = batch_size) %>%
            .[,1] 
        
        # Make future index using tk_make_future_timeseries()
        idx <- data %>%
            tk_index() %>%
            tk_make_future_timeseries(n_future = lag_setting)
        
        # Retransform values
        pred_tbl <- tibble(
            cob_date   = idx,
            ask_close   = (pred_out * scale_history + center_history)^2
        )
        
        # Combine actual data with predictions
        tbl_1 <- df %>%
            add_column(key = "actual")
        
        tbl_3 <- pred_tbl %>%
            add_column(key = "predict")
        
        # Create time_bind_rows() to solve dplyr issue
        time_bind_rows <- function(data_1, data_2, index) {
            index_expr <- enquo(index)
            bind_rows(data_1, data_2) %>%
                as_tbl_time(index = !! index_expr)
        }
        
        ret <- list(tbl_1, tbl_3) %>%
            reduce(time_bind_rows, index = cob_date) %>%
            arrange(key, cob_date) %>%
            mutate(key = as_factor(key))
        
        return(ret)
        
    }
    
    safe_lstm <- possibly(lstm_prediction, otherwise = NA)
    
    safe_lstm(data, epochs, ...)
    
}



predict_keras_tbl <- predict_keras_lstm_future(aud_usd_df, epochs = 300)


rm(list = ls())

