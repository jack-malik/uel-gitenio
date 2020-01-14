
paste("~/a/very/long/path/here",
      "/and/then/some/more",
      "/and/then/some/more",
      "/and/then/some/more", sep="")

GET_AUDUSD_SQL = paste("select ticker, cob_date, ",
                        "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                        "gt_calendar c where tp.ticker='AUDUSD' and tp.cob_date=c.calendar_date ",
                        "and c.date_key > 40177 order by cob_date", sep="")
                       
                       
GET_EURUSD_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='EURUSD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_GBPUSD_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='GBPUSD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDCAD_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCAD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_CADUSD_SQL = paste("select ticker, cob_date, ",
                       "(1/ask_open) \"ask_open\", (1/ask_high) \"ask_high\",",
		                "(1/ask_low) \"ask_low\", (1/ask_close) \"ask_close\" ",
		                "from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCAD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDCHF_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCHF' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDJPY_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDJPY' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDPLN_SQL = paste("select ticker, cob_date, ",
                       "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDPLN' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

    
GET_ALL_SQL = paste("select ticker, cob_date, ",
                    "ask_open, ask_high, ask_low, ask_close from gt_ticker_price tp,",
                    "gt_calendar c where tp.cob_date=c.calendar_date ",
                    "and c.date_key > 40177 order ticker, by cob_date", sep="")


# ------------------- ask_close only -----------------------------------
GET_AUDUSD_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='AUDUSD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")


GET_EURUSD_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='EURUSD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_GBPUSD_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='GBPUSD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDCAD_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCAD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_CADUSD_SQL = paste("select cob_date, ",
                       "(1/ask_close) \"ask_close\" ",
                       "from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCAD' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDCHF_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDCHF' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDJPY_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDJPY' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")

GET_USDPLN_SQL = paste("select cob_date, ",
                       "ask_close from gt_ticker_price tp,",
                       "gt_calendar c where tp.ticker='USDPLN' and tp.cob_date=c.calendar_date ",
                       "and c.date_key > 40177 order by cob_date", sep="")


GET_ALL_SQL = paste("select ticker, cob_date, ",
                    "ask_close from gt_ticker_price tp,",
                    "gt_calendar c where tp.cob_date=c.calendar_date ",
                    "and c.date_key > 40177 order ticker, by cob_date", sep="")

