import os
import getopt
import logging
from datetime import datetime
import zipfile
import sys
import csv
from decimal import Decimal, getcontext
from gitenio.core.util import db_manager

logger_ = logging.getLogger(__name__)
logger_.setLevel(logging.INFO)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
formatter = logging.Formatter('[%(asctime)s]-[%(name)s]-[%(levelname)s]: %(message)s')
handler.setFormatter(formatter)
logger_.addHandler(handler)


class CcyCorrelationMatrix(object):

    def build(self, file_name, out_file_name):

        """
        Parsing file of the following format:
        <TICKER>,<DTYYYYMMDD>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>
        USDJPY,20010102,230300,114.43,114.43,114.43,114.43,4
        USDJPY,20010102,230400,114.44,114.44,114.44,114.44,4
        :param file_name:
        :return:
        """
        count = 0
        date = None
        current_rec_date = None
        prev_line = None
        cor_mtx = dict()
        try:

            with open(file_name, "r") as file_handle:
                for line in file_handle:
                    count += 1
                    if count == 1:
                        continue
                    tmp_arr = line.rstrip('\n').split(',')
                    if len(tmp_arr) < 6:
                        continue
                    rec = tmp_arr[0]
                    ticker1 = tmp_arr[1]
                    ticker2 = tmp_arr[2]
                    lag = tmp_arr[3]
                    corr = tmp_arr[4]
                    ticker1_mtx = cor_mtx.get(ticker1, None)
                    if not ticker1_mtx:
                        ticker1_mtx = dict()
                        cor_mtx[ticker1] = ticker1_mtx
                    corr_lag_tpl = ticker1_mtx.get(ticker2, None)
                    if not corr_lag_tpl or abs(Decimal(corr)) > abs(Decimal(corr_lag_tpl[0])):
                        ticker1_mtx[ticker2] = (Decimal(corr), int(lag))

        except Exception as ex:
            logger_.error("Failed. Msg: {}".format(ex))
            return


        try:
            for ticker1, val in cor_mtx.items():
                pass
#                ticker2_mtx = cor_mtx.get(ticker2, None)
#                if not ticker2_mtx:
#                    ticker2_mtx = dict()
#                    cor_mtx[ticker2] = ticker2_mtx
#                corr_lag_tpl = ticker2_mtx.get(ticker1, None)
#                if not corr_lag_tpl or abs(Decimal(corr)) > abs(Decimal(corr_lag_tpl[0])):
#                    ticker2_mtx[ticker1] = (1/Decimal(corr), int(lag))




        except Exception as ex:
            logger_.error("Failed. Msg: {}".format(ex))
            return

        foo = 10
        try:
            with open(out_file_name, 'w') as out_file:
                with open(file_name, "r") as file_handle:
                    for line in file_handle:
                        count += 1
                        if count == 1:
                            out_file.write("AUDUSD,EURUSD,GBPUSD,USDCAD,USDCHF,USDJPY,USDPLN\n")
                            continue
                        tmp_arr = line.rstrip('\n').split(',')
                        if len(tmp_arr) < 8:
                            continue
                        ticker = tmp_arr[0]
                        current_rec_date = tmp_arr[1]
                        if int(current_rec_date) < 20100101:
                            continue
                        if not date:
                            date = current_rec_date
                        #time = tmp_arr[2]

                        open_price = tmp_arr[3]
                        high_price = tmp_arr[4]
                        low_price = tmp_arr[5]
                        close_price = tmp_arr[6]
                        volume = tmp_arr[7]

                        # logger_.info("{}".format(line))
                        if current_rec_date != date:
                            date = current_rec_date
                            out_file.write(prev_line)
                        prev_line = "{},{},{},{},{},{},{}\n".format(ticker,
                                                                    current_rec_date,
                                                                    open_price, high_price,
                                                                    low_price, close_price,
                                                                    volume)
                        if count % 500000 == 0:
                            logger_.info("Processed {} records ..".format(count))
                out_file.write(prev_line)
        except Exception as ex:
            logger_.error("Failed. Msg: {}".format(ex))
            return        
        return



class MarketDataLoader(object):
    FX_SPOT_LOAD_SQL = "INSERT INTO GT_TICKER_PRICE (TICKER, COB_DATE, BID_TIMESTAMP, BID_OPEN, BID_HIGH, " \
                       "BID_LOW,BID_CLOSE, BID_VOLUME, ASK_TIMESTAMP, ASK_OPEN, ASK_HIGH, ASK_LOW, ASK_CLOSE," + \
                       "ASK_VOLUME, IS_ENABLED, LOAD_TIME, LAST_UPDATE, LAST_ID, IS_ACTIVE) VALUES " + \
                       "('{}', {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, 1, CURRENT_TIMESTAMP," \
                       "CURRENT_TIMESTAMP, 'gitenio', {}) ON CONFLICT (TICKER, COB_DATE) " + \
                       "DO UPDATE SET BID_TIMESTAMP={}, BID_OPEN={}, BID_HIGH={}, BID_LOW={}," + \
                       "BID_CLOSE={}, BID_VOLUME={}, ASK_TIMESTAMP={}, ASK_OPEN={}, ASK_HIGH={}, " + \
                       "ASK_LOW={}, ASK_CLOSE={}, ASK_VOLUME={}, IS_ENABLED=1, LAST_UPDATE=CURRENT_TIMESTAMP, " + \
                       "LAST_ID='gitenio', IS_ACTIVE={} "


    GT_CALENDAR_LOAD_SQL_2 = "INSERT INTO GT_CALENDAR (DATE_KEY,DATE_TYPE,CALENDAR_DATE,DAY_NUM_OF_WEEK," + \
                           "DAY_NUM_OF_MONTH,DAY_NUM_OF_QUARTER,DAY_NUM_OF_YEAR,DAY_NUM_ABSOLUTE," + \
                           "DAY_OF_WEEK_NAME,DAY_OF_WEEK_SHORT,JULIAN_DAY_NUM_OF_YEAR," + \
                           "JULIAN_DAY_NUM_ABSOLUTE,IS_WEEKDAY,IS_US_CIVIL_HOLIDAY,IS_LAST_DAY_OF_WEEK,"+ \
                           "IS_LAST_DAY_OF_MONTH,IS_LAST_DAY_OF_QUARTER,IS_LAST_DAY_OF_YEAR," + \
                           "WEEK_OF_YEAR_BEGIN_DATE,WEEK_OF_YEAR_BEGIN_DATE_KEY,WEEK_OF_YEAR_END_DATE," + \
                           "WEEK_OF_YEAR_END_DATE_KEY,WEEK_OF_MONTH_BEGIN_DATE," + \
                           "WEEK_OF_MONTH_BEGIN_DATE_KEY,WEEK_OF_MONTH_END_DATE," + \
                           "WEEK_OF_MONTH_END_DATE_KEY,WEEK_OF_QUARTER_BEGIN_DATE," + \
                           "WEEK_OF_QUARTER_BEGIN_DATE_KEY,WEEK_OF_QUARTER_END_DATE," + \
                           "WEEK_OF_QUARTER_END_DATE_KEY,WEEK_NUM_OF_MONTH,WEEK_NUM_OF_QUARTER," + \
                           "WEEK_NUM_OF_YEAR,MONTH_NUM_OF_YEAR,MONTH_NAME,MONTH_NAME_SHORT," + \
                           "MONTH_BEGIN_DATE,MONTH_BEGIN_DATE_KEY,MONTH_END_DATE,MONTH_END_DATE_KEY," + \
                           "QUARTER_NUM_OF_YEAR,QUARTER_BEGIN_DATE,QUARTER_BEGIN_DATE_KEY," + \
                           "QUARTER_END_DATE,QUARTER_END_DATE_KEY,YEAR_NUM,YEAR_BEGIN_DATE," + \
                           "YEAR_BEGIN_DATE_KEY,YEAR_END_DATE,YEAR_END_DATE_KEY,YYYYMMDD, CREATE_TIME," + \
                             "LAST_UPDATE, LAST_ID, IS_ACTIVE) VALUES " + \
                             "({},'{}',{},{},{},{},{},{},'{}','{}',{},{},{},"+ \
                             "{},{},{},{},{},{},{},{},{},{},{},{},{},{}," + \
                             "{},{},{},{},{},{},{},'{}','{}',{},{},{},{},{},{},{},{}," + \
                             "{},{},{},{},{},{},'{}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'gitenio', {}) " \
                             "ON CONFLICT (CALENDAR_DATE) DO UPDATE SET LAST_UPDATE=CURRENT_TIMESTAMP, " \
                             "LAST_ID='gitenio', IS_ACTIVE={}"


    GT_CALENDAR_LOAD_SQL = "INSERT INTO GT_CALENDAR (DATE_KEY,DATE_TYPE,FULL_DATE,DAY_NUM_OF_WEEK," + \
                           "DAY_NUM_OF_MONTH,DAY_NUM_OF_QUARTER,DAY_NUM_OF_YEAR,DAY_NUM_ABSOLUTE," + \
                           "DAY_OF_WEEK_NAME,DAY_OF_WEEK_ABBREVIATION,JULIAN_DAY_NUM_OF_YEAR," + \
                           "JULIAN_DAY_NUM_ABSOLUTE,IS_WEEKDAY,IS_US_CIVIL_HOLIDAY,IS_LAST_DAY_OF_WEEK,"+\
                           "IS_LAST_DAY_OF_MONTH,IS_LAST_DAY_OF_QUARTER,IS_LAST_DAY_OF_YEAR," + \
                           "WEEK_OF_YEAR_BEGIN_DATE,WEEK_OF_YEAR_BEGIN_DATE_KEY,WEEK_OF_YEAR_END_DATE," + \
                           "WEEK_OF_YEAR_END_DATE_KEY,WEEK_OF_MONTH_BEGIN_DATE," + \
                           "WEEK_OF_MONTH_BEGIN_DATE_KEY,WEEK_OF_MONTH_END_DATE," + \
                           "WEEK_OF_MONTH_END_DATE_KEY,WEEK_OF_QUARTER_BEGIN_DATE," + \
                           "WEEK_OF_QUARTER_BEGIN_DATE_KEY,WEEK_OF_QUARTER_END_DATE," + \
                           "WEEK_OF_QUARTER_END_DATE_KEY,WEEK_NUM_OF_MONTH,WEEK_NUM_OF_QUARTER," + \
                           "WEEK_NUM_OF_YEAR,MONTH_NUM_OF_YEAR,MONTH_NAME,MONTH_NAME_ABBREVIATION," + \
                           "MONTH_BEGIN_DATE,MONTH_BEGIN_DATE_KEY,MONTH_END_DATE,MONTH_END_DATE_KEY," + \
                           "QUARTER_NUM_OF_YEAR,QUARTER_BEGIN_DATE,QUARTER_BEGIN_DATE_KEY," + \
                           "QUARTER_END_DATE,QUARTER_END_DATE_KEY,YEAR_NUM,YEAR_BEGIN_DATE," + \
                           "YEAR_BEGIN_DATE_KEY,YEAR_END_DATE,YEAR_END_DATE_KEY,YYYYMMDD) VALUES " + \
                           "({},'{}',{},{},{},{},{},{},'{}','{}',{},{},'{}',"+ \
                           "'{}','{}','{}','{}','{}',{},{},{},{},{},{},{},{},{}," + \
                           "{},{},{},{},{},{},{},'{}','{}',{},{},{},{},{},{},{},{}," + \
                           "{},{},{},{},{},{},'{}')"

    GT_CALENDAR_LOAD_SQL_= "INSERT INTO GT_CALENDAR (DATE_KEY,DATE_TYPE,FULL_DATE,DAY_NUM_OF_WEEK," + \
                           "DAY_NUM_OF_MONTH,DAY_NUM_OF_QUARTER,DAY_NUM_OF_YEAR,DAY_NUM_ABSOLUTE," + \
                           "DAY_OF_WEEK_NAME,DAY_OF_WEEK_ABBREVIATION,JULIAN_DAY_NUM_OF_YEAR," + \
                           "JULIAN_DAY_NUM_ABSOLUTE,IS_WEEKDAY,IS_US_CIVIL_HOLIDAY,IS_LAST_DAY_OF_WEEK,"+ \
                           "IS_LAST_DAY_OF_MONTH,IS_LAST_DAY_OF_QUARTER,IS_LAST_DAY_OF_YEAR," + \
                           "WEEK_OF_YEAR_BEGIN_DATE,WEEK_OF_YEAR_BEGIN_DATE_KEY,WEEK_OF_YEAR_END_DATE," + \
                           "WEEK_OF_YEAR_END_DATE_KEY,WEEK_OF_MONTH_BEGIN_DATE," + \
                           "WEEK_OF_MONTH_BEGIN_DATE_KEY,WEEK_OF_MONTH_END_DATE," + \
                           "WEEK_OF_MONTH_END_DATE_KEY,WEEK_OF_QUARTER_BEGIN_DATE," + \
                           "WEEK_OF_QUARTER_BEGIN_DATE_KEY,WEEK_OF_QUARTER_END_DATE," + \
                           "WEEK_OF_QUARTER_END_DATE_KEY,WEEK_NUM_OF_MONTH,WEEK_NUM_OF_QUARTER," + \
                           "WEEK_NUM_OF_YEAR,MONTH_NUM_OF_YEAR,MONTH_NAME,MONTH_NAME_ABBREVIATION," + \
                           "MONTH_BEGIN_DATE,MONTH_BEGIN_DATE_KEY,MONTH_END_DATE,MONTH_END_DATE_KEY," + \
                           "QUARTER_NUM_OF_YEAR,QUARTER_BEGIN_DATE,QUARTER_BEGIN_DATE_KEY," + \
                           "QUARTER_END_DATE,QUARTER_END_DATE_KEY,YEAR_NUM,YEAR_BEGIN_DATE," + \
                           "YEAR_BEGIN_DATE_KEY,YEAR_END_DATE,YEAR_END_DATE_KEY,YYYYMMDD) VALUES " + \
                           "({},'{}',{},{},{},{},{},{},'{}','{}',{},{},'{}',"+ \
                           "'{}','{}','{}','{}','{}',{},{},{},{},{},{},{},{},{}," + \
                           "{},{},{},{},{},{},{},'{}','{}',{},{},{},{},{},{},{},{}," + \
                           "{},{},{},{},{},{},'{}') ON CONFLICT (DATE_KEY) DO UPDATE " + \
                           "SET DATE_TYPE='{}',FULL_DATE={},DAY_NUM_OF_WEEK={}," + \
                           "DAY_NUM_OF_MONTH={},DAY_NUM_OF_QUARTER={},DAY_NUM_OF_YEAR={},DAY_NUM_ABSOLUTE={}," + \
                           "DAY_OF_WEEK_NAME='{}',DAY_OF_WEEK_ABBREVIATION='{}',JULIAN_DAY_NUM_OF_YEAR={}," + \
                           "JULIAN_DAY_NUM_ABSOLUTE={},IS_WEEKDAY='{}',IS_US_CIVIL_HOLIDAY='{}',IS_LAST_DAY_OF_WEEK='{}',"+\
                           "IS_LAST_DAY_OF_MONTH='{}',IS_LAST_DAY_OF_QUARTER='{}',IS_LAST_DAY_OF_YEAR='{}'," + \
                           "WEEK_OF_YEAR_BEGIN_DATE={},WEEK_OF_YEAR_BEGIN_DATE_KEY={},WEEK_OF_YEAR_END_DATE={}," + \
                           "WEEK_OF_YEAR_END_DATE_KEY={},WEEK_OF_MONTH_BEGIN_DATE={}," + \
                           "WEEK_OF_MONTH_BEGIN_DATE_KEY={},WEEK_OF_MONTH_END_DATE={}," + \
                           "WEEK_OF_MONTH_END_DATE_KEY={},WEEK_OF_QUARTER_BEGIN_DATE={}," + \
                           "WEEK_OF_QUARTER_BEGIN_DATE_KEY={},WEEK_OF_QUARTER_END_DATE={}," + \
                           "WEEK_OF_QUARTER_END_DATE_KEY={},WEEK_NUM_OF_MONTH={},WEEK_NUM_OF_QUARTER={}," + \
                           "WEEK_NUM_OF_YEAR={},MONTH_NUM_OF_YEAR={},MONTH_NAME='{}',MONTH_NAME_ABBREVIATION='{}'," + \
                           "MONTH_BEGIN_DATE={},MONTH_BEGIN_DATE_KEY={},MONTH_END_DATE={},MONTH_END_DATE_KEY={}," + \
                           "QUARTER_NUM_OF_YEAR={},QUARTER_BEGIN_DATE={},QUARTER_BEGIN_DATE_KEY={}," + \
                           "QUARTER_END_DATE={},QUARTER_END_DATE_KEY={},YEAR_NUM={},YEAR_BEGIN_DATE={}," + \
                           "YEAR_BEGIN_DATE_KEY={},YEAR_END_DATE={},YEAR_END_DATE_KEY={},YYYYMMDD='{}'"


    def parse_fx_spot(self, file_name, out_file_name):

        """
        Parsing file of the following format:
        <TICKER>,<DTYYYYMMDD>,<TIME>,<OPEN>,<HIGH>,<LOW>,<CLOSE>,<VOL>
        USDJPY,20010102,230300,114.43,114.43,114.43,114.43,4
        USDJPY,20010102,230400,114.44,114.44,114.44,114.44,4
        :param file_name:
        :return:
        """
        count = 0
        date = None
        current_rec_date = None
        prev_line = None
        try:
            with open(out_file_name, 'w') as out_file:
                with open(file_name, "r") as file_handle:
                    for line in file_handle:
                        count += 1
                        if line.startswith('<'):
                            out_file.write("TICKER,DATE,OPEN,HIGH,LOW,CLOSE,VOL\n")
                            continue
                        tmp_arr = line.rstrip('\n').split(',')
                        if len(tmp_arr) < 8:
                            continue
                        ticker = tmp_arr[0]
                        current_rec_date = tmp_arr[1]
                        if int(current_rec_date) < 20100101:
                            continue
                        if not date:
                            date = current_rec_date
                        #time = tmp_arr[2]

                        open_price = tmp_arr[3]
                        high_price = tmp_arr[4]
                        low_price = tmp_arr[5]
                        close_price = tmp_arr[6]
                        volume = tmp_arr[7]

                        # logger_.info("{}".format(line))
                        if current_rec_date != date:
                            date = current_rec_date
                            out_file.write(prev_line)
                        prev_line = "{},{},{},{},{},{},{}\n".format(ticker,
                                                                  current_rec_date,
                                                                  open_price, high_price,
                                                                  low_price, close_price,
                                                                  volume)
                        if count % 500000 == 0:
                            logger_.info("Processed {} records ..".format(count))
                out_file.write(prev_line)
        except Exception as ex:
            logger_.error("Failed. Msg: {}".format(ex))
            return
        return

    def db_load_fx_spot(self, file_name, is_active=1):
        cursor = None
        db_connection = None
        sql = MarketDataLoader.FX_SPOT_LOAD_SQL
        count = 0
        loaded = 0
        ticker = None
        try:
            db_connection = db_manager.connect()
            cursor = db_connection.cursor()
            with open(file_name, "r") as file_handle:
                for line in file_handle:
                    if count == 0:
                        # header:
                        # TICKER,BID_TIMESTAMP,BID_OPEN,BID_HIGH,BID_LOW,BID_CLOSE,BID_VOLUME,
                        #        ASK_TIMESTAMP,ASK_OPEN,ASK_HIGH,ASK_LOW,ASK_CLOSE,ASK_VOLUME
                        # AUDUSD,04.01.2010 22:00:00.000 GMT-0000,0.91243,0.91737,0.90916,0.91219,51971.34,
                        #        04.01.2010 22:00:00.000 GMT-0000,0.91275,0.91754,0.90934,0.91251,52587.0397
                        count += 1
                        continue
                    # example: # USDJPY,20100103,92.69,92.70,92.69,92.70,4
                    count += 1
                    tmp_arr = line.rstrip('\n').split(',')
                    if len(tmp_arr) < 13:
                        continue
                    ticker = tmp_arr[0]
                    cob_date = "TO_DATE('{}', 'DD.MM.YYYY')".format(tmp_arr[1])

                    # ------------- BID SIDE ----------------
                    bid_timestamp = "TO_TIMESTAMP('{}', 'DD.MM.YYYY HH24:MI:SS.sss GMT-0000')".format(tmp_arr[1])
                    bid_open = 'null'
                    try:
                        bid_open = Decimal(tmp_arr[2])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[2],
                                                                                               ex))
                    bid_high = 'null'
                    try:
                        bid_high = Decimal(tmp_arr[3])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[3],
                                                                                               ex))
                    bid_low = 'null'
                    try:
                        bid_low = Decimal(tmp_arr[4])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[4],
                                                                                               ex))
                    bid_close = 'null'
                    try:
                        bid_close = Decimal(tmp_arr[5])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[5],
                                                                                               ex))
                    bid_volume = 'null'
                    try:
                        bid_volume = Decimal(tmp_arr[6])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[6],
                                                                                               ex))

                    # ----------------- ASK SIDE ------------------------------
                    ask_timestamp = "TO_TIMESTAMP('{}', 'DD.MM.YYYY HH24:MI:SS.sss GMT-0000')".format(tmp_arr[7])
                    ask_open = 'null'
                    try:
                        ask_open = Decimal(tmp_arr[8])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[8],
                                                                                               ex))
                    ask_high = 'null'
                    try:
                        ask_high = Decimal(tmp_arr[9])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[9],
                                                                                               ex))
                    ask_low = 'null'
                    try:
                        ask_low = Decimal(tmp_arr[10])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[10],
                                                                                               ex))
                    ask_close = 'null'
                    try:
                        ask_close = Decimal(tmp_arr[11])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[11],
                                                                                               ex))
                    ask_volume = 'null'
                    try:
                        ask_volume = Decimal(tmp_arr[12])
                    except Exception as ex:
                        logger_.error("Line: {}. Failed converting '{}' to Decimal. {}".format(count,
                                                                                               tmp_arr[12],
                                                                                               ex))
                    

                    sql_exec = sql.format(ticker, cob_date, bid_timestamp, bid_open, bid_high, bid_low,
                                          bid_close, bid_volume, ask_timestamp, ask_open, ask_high, ask_low,
                                          ask_close, ask_volume, is_active,
                                          bid_timestamp, bid_open, bid_high, bid_low, bid_close,
                                          bid_volume,
                                          ask_timestamp, ask_open, ask_high, ask_low, ask_close,
                                          ask_volume, is_active)
                    
                    cursor.execute(sql_exec)
                    loaded += 1
                    if count % 250 == 0:
                        logger_.info("Processed {} data records .. Currently loaded {} ..".format(count-1, loaded))

        except Exception as ex:
            logger_.error("Unexpected exception while loading data from {}. Msg: {}".format(file_name, ex))
            if cursor:
                cursor.close()
                cursor = None
            if db_connection:
                db_connection.release(close=True)
                db_connection = None

        finally:
            if cursor:
                cursor.close()
            if db_connection:
                db_connection.commit()
                db_connection.release()

        logger_.info("Processed {} data records from file '{}'. Loaded {} successfully".format(count-1,
                                                                                               file_name,
                                                                                               loaded))
        return

    def db_load_calendar(self, file_name, is_active=1):
        cursor = None
        db_connection = None
        sql = MarketDataLoader.GT_CALENDAR_LOAD_SQL_2
        count = 0
        loaded = 0
        ticker = None
        try:
            db_connection = db_manager.connect()
            cursor = db_connection.cursor()
            with open(file_name, "r") as file_handle:
                for line in file_handle:
                    if count == 0:
                        count += 1
                        continue
                    # example: # DATE_KEY,DATE_TYPE,FULL_DATE,DAY_NUM_OF_WEEK,
                    #            DAY_NUM_OF_MONTH,DAY_NUM_OF_QUARTER,DAY_NUM_OF_YEAR,
                    #            DAY_NUM_ABSOLUTE,DAY_OF_WEEK_NAME,DAY_OF_WEEK_ABBREVIATION,
                    #            JULIAN_DAY_NUM_OF_YEAR,JULIAN_DAY_NUM_ABSOLUTE,IS_WEEKDAY,
                    #            IS_US_CIVIL_HOLIDAY,IS_LAST_DAY_OF_WEEK,IS_LAST_DAY_OF_MONTH,
                    #            IS_LAST_DAY_OF_QUARTER,IS_LAST_DAY_OF_YEAR,WEEK_OF_YEAR_BEGIN_DATE,
                    #            WEEK_OF_YEAR_BEGIN_DATE_KEY,WEEK_OF_YEAR_END_DATE,
                    #            WEEK_OF_YEAR_END_DATE_KEY,WEEK_OF_MONTH_BEGIN_DATE,
                    #            WEEK_OF_MONTH_BEGIN_DATE_KEY,WEEK_OF_MONTH_END_DATE,
                    #            WEEK_OF_MONTH_END_DATE_KEY,WEEK_OF_QUARTER_BEGIN_DATE,
                    #            WEEK_OF_QUARTER_BEGIN_DATE_KEY,WEEK_OF_QUARTER_END_DATE,
                    #            WEEK_OF_QUARTER_END_DATE_KEY,WEEK_NUM_OF_MONTH,WEEK_NUM_OF_QUARTER,
                    #            WEEK_NUM_OF_YEAR,MONTH_NUM_OF_YEAR,MONTH_NAME,MONTH_NAME_ABBREVIATION,
                    #            MONTH_BEGIN_DATE,MONTH_BEGIN_DATE_KEY,MONTH_END_DATE,MONTH_END_DATE_KEY,
                    #            QUARTER_NUM_OF_YEAR,QUARTER_NUM_OVERALL,QUARTER_BEGIN_DATE,
                    #            QUARTER_BEGIN_DATE_KEY,QUARTER_END_DATE,QUARTER_END_DATE_KEY,
                    #            YEAR_NUM,YEAR_BEGIN_DATE,YEAR_BEGIN_DATE_KEY,YEAR_END_DATE,
                    #            YEAR_END_DATE_KEY,YYYYMMDD
                    count += 1
                    tmp_arr = line.rstrip('\n').split(',')
                    if len(tmp_arr) < 7:
                        continue

                    date_key = int(tmp_arr[0])
                    date_type = tmp_arr[1]
                    full_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[2])
                    day_num_of_week = int(tmp_arr[3])
                    day_num_of_month = int(tmp_arr[4])
                    day_num_of_quarter = int(tmp_arr[5])
                    day_num_of_year = int(tmp_arr[6])
                    day_num_absolute = int(tmp_arr[7])
                    day_of_week_name = tmp_arr[8]
                    day_of_week_abbreviation = tmp_arr[9]
                    julian_day_num_of_year = int(tmp_arr[10])
                    julian_day_num_absolute = Decimal(tmp_arr[11])
#                    is_weekday = tmp_arr[12]
#                    is_us_civil_holiday = tmp_arr[13]
#                    is_last_day_of_week = tmp_arr[14]
#                    is_last_day_of_month = tmp_arr[15]
#                    is_last_day_of_quarter = tmp_arr[16]
#                    is_last_day_of_year = tmp_arr[17]

                    is_weekday = 0
                    if tmp_arr[12] == 'Y':
                        is_weekday = 1
                    is_us_civil_holiday = 0
                    if tmp_arr[13] == 'Y':
                        is_us_civil_holiday = 1
                    is_last_day_of_week = 0
                    if tmp_arr[14] == 'Y':
                        is_last_day_of_week = 1
                    is_last_day_of_month = 0
                    if tmp_arr[15] == 'Y':
                        is_last_day_of_month = 1
                    is_last_day_of_quarter = 0
                    if tmp_arr[16] == 'Y':
                        is_last_day_of_quarter = 1
                    is_last_day_of_year = 0
                    if tmp_arr[17] == 'Y':
                        is_last_day_of_year = 1

                    week_of_year_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[18])
                    week_of_year_begin_date_key = int(tmp_arr[19])
                    week_of_year_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[20])
                    week_of_year_end_date_key = int(tmp_arr[21])
                    week_of_month_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[22])
                    week_of_month_begin_date_key = int(tmp_arr[23])
                    week_of_month_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[24])
                    week_of_month_end_date_key = int(tmp_arr[25])
                    week_of_quarter_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[26])
                    week_of_quarter_begin_date_key = int(tmp_arr[27])
                    week_of_quarter_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[28])
                    week_of_quarter_end_date_key = int(tmp_arr[29])
                    week_num_of_month = int(tmp_arr[30])
                    week_num_of_quarter = int(tmp_arr[31])
                    week_num_of_year = int(tmp_arr[32])
                    month_num_of_year = int(tmp_arr[33])
                    month_name = tmp_arr[34]
                    month_name_abbreviation = tmp_arr[35]
                    month_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[36])

                    month_begin_date_key = int(tmp_arr[37])
                    month_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[38])
                    month_end_date_key = int(tmp_arr[39])
                    quarter_num_of_year = int(tmp_arr[40])
                    quarter_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[41])
                    quarter_begin_date_key = int(tmp_arr[42])
                    quarter_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[43])
                    quarter_end_date_key = int(tmp_arr[44])
                    year_num = int(tmp_arr[45])
                    year_begin_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[46])
                    year_begin_date_key = int(tmp_arr[47])
                    year_end_date = "TO_DATE('{}', 'DD/MM/YYYY')".format(tmp_arr[48])
                    year_end_date_key = int(tmp_arr[49])
                    yyyymmdd = tmp_arr[50]

                    sql_exec = sql.format(
                        date_key,
                        date_type,
                        full_date,
                        day_num_of_week,
                        day_num_of_month,
                        day_num_of_quarter,
                        day_num_of_year,
                        day_num_absolute,
                        day_of_week_name,
                        day_of_week_abbreviation,
                        julian_day_num_of_year,
                        julian_day_num_absolute,
                        is_weekday,
                        is_us_civil_holiday,
                        is_last_day_of_week,
                        is_last_day_of_month,
                        is_last_day_of_quarter,
                        is_last_day_of_year,
                        week_of_year_begin_date,
                        week_of_year_begin_date_key,
                        week_of_year_end_date,
                        week_of_year_end_date_key,
                        week_of_month_begin_date,
                        week_of_month_begin_date_key,
                        week_of_month_end_date,
                        week_of_month_end_date_key,
                        week_of_quarter_begin_date,
                        week_of_quarter_begin_date_key,
                        week_of_quarter_end_date,
                        week_of_quarter_end_date_key,
                        week_num_of_month,
                        week_num_of_quarter,
                        week_num_of_year,
                        month_num_of_year,
                        month_name,
                        month_name_abbreviation,
                        month_begin_date,
                        month_begin_date_key,
                        month_end_date,
                        month_end_date_key,
                        quarter_num_of_year,
                        quarter_begin_date,
                        quarter_begin_date_key,
                        quarter_end_date,
                        quarter_end_date_key,
                        year_num,
                        year_begin_date,
                        year_begin_date_key,
                        year_end_date,
                        year_end_date_key,
                        yyyymmdd,
                        is_active,
                        is_active)

                    #logger_.info("Executing SQL: {}".format(sql_exec))
                    cursor.execute(sql_exec)
                    loaded += 1
                    if count % 250 == 0:
                        logger_.info("Processed {} calendar data records .. Currently loaded {} ..".format(count-1, loaded))

        except Exception as ex:
            logger_.error("Unexpected exception while loading data from {}. Msg: {}".format(file_name, ex))
            if cursor:
                cursor.close()
                cursor = None
            if db_connection:
                db_connection.release(close=True)
                db_connection = None

        finally:
            if cursor:
                cursor.close()
            if db_connection:
                db_connection.commit()
                db_connection.release()

        logger_.info("Processed {} data records from file '{}'. Loaded {} successfully".format(count-1,
                                                                                               file_name,
                                                                                               loaded))
        return



def main(argv):

    mtx = CcyCorrelationMatrix()
    mtx.build('c:/dev/gitenio/src/R/data/cc_all_ccy_pairs_abs.csv',
              'c:/dev/gitenio/src/R/data/ccy_correlation_matrix.csv')
    if 1==1:
        return
    loader = MarketDataLoader()
    logger_.info("Starting parsing .. ")
    if 1==0:
        loader.parse_fx_spot('C:/Users/jack/Desktop/UEL-2/Dissertations/fx-data/AUDUSD.txt',
                             'C:/Users/jack/Desktop/UEL-2/Dissertations/fx-data/AUDUSD.csv')

    loader.db_load_calendar('C:/dev/gitenio/db/postgres/data/csv/gt_calendar.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/USDCAD.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/USDJPY.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/USDCHF.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/GBPUSD.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/EURUSD.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/AUDUSD.csv')
    loader.db_load_fx_spot('C:/dev/gitenio/db/postgres/data/csv/USDPLN.csv')


if __name__ == '__main__':

    main(sys.argv[1:])

