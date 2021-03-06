DROP TABLE IF EXISTS GT_TICKER_PRICE CASCADE ;


DROP TABLE IF EXISTS GT_CALENDAR CASCADE ;


CREATE TABLE GT_CALENDAR
(
	CALENDAR_DATE  DATE  NOT NULL ,
	DATE_KEY  INTEGER  NOT NULL ,
	DATE_TYPE  VARCHAR(20)  NULL ,
	DAY_NUM_OF_WEEK  INTEGER  NULL ,
	DAY_NUM_OF_MONTH  INTEGER  NULL ,
	DAY_NUM_OF_QUARTER  INTEGER  NULL ,
	DAY_NUM_OF_YEAR  INTEGER  NULL ,
	DAY_NUM_ABSOLUTE  INTEGER  NULL ,
	DAY_OF_WEEK_NAME  VARCHAR(10)  NULL ,
	DAY_OF_WEEK_SHORT  VARCHAR(3)  NULL ,
	JULIAN_DAY_NUM_OF_YEAR  INTEGER  NULL ,
	JULIAN_DAY_NUM_ABSOLUTE  DECIMAL(18,0)  NULL ,
	IS_WEEKDAY  INTEGER  NULL ,
	IS_US_CIVIL_HOLIDAY  INTEGER  NULL ,
	IS_LAST_DAY_OF_WEEK  INTEGER  NULL ,
	IS_LAST_DAY_OF_MONTH  INTEGER  NULL ,
	IS_LAST_DAY_OF_QUARTER  INTEGER  NULL ,
	IS_LAST_DAY_OF_YEAR  INTEGER  NULL ,
	WEEK_OF_YEAR_BEGIN_DATE  DATE  NULL ,
	WEEK_OF_YEAR_BEGIN_DATE_KEY  INTEGER  NULL ,
	WEEK_OF_YEAR_END_DATE  DATE  NULL ,
	WEEK_OF_YEAR_END_DATE_KEY  INTEGER  NULL ,
	WEEK_OF_MONTH_BEGIN_DATE  DATE  NULL ,
	WEEK_OF_MONTH_BEGIN_DATE_KEY  INTEGER  NULL ,
	WEEK_OF_MONTH_END_DATE  DATE  NULL ,
	WEEK_OF_MONTH_END_DATE_KEY  INTEGER  NULL ,
	WEEK_OF_QUARTER_BEGIN_DATE  DATE  NULL ,
	WEEK_OF_QUARTER_BEGIN_DATE_KEY  INTEGER  NULL ,
	WEEK_OF_QUARTER_END_DATE  DATE  NULL ,
	WEEK_OF_QUARTER_END_DATE_KEY  INTEGER  NULL ,
	WEEK_NUM_OF_MONTH  INTEGER  NULL ,
	WEEK_NUM_OF_QUARTER  INTEGER  NULL ,
	WEEK_NUM_OF_YEAR  INTEGER  NULL ,
	MONTH_NUM_OF_YEAR  INTEGER  NULL ,
	MONTH_NAME  VARCHAR(10)  NULL ,
	MONTH_NAME_SHORT  VARCHAR(3)  NULL ,
	MONTH_BEGIN_DATE  DATE  NULL ,
	MONTH_BEGIN_DATE_KEY  INTEGER  NULL ,
	MONTH_END_DATE  DATE  NULL ,
	MONTH_END_DATE_KEY  INTEGER  NULL ,
	QUARTER_NUM_OF_YEAR  INTEGER  NULL ,
	QUARTER_NUM_OVERALL  INTEGER  NULL ,
	QUARTER_BEGIN_DATE  DATE  NULL ,
	QUARTER_BEGIN_DATE_KEY  INTEGER  NULL ,
	QUARTER_END_DATE  DATE  NULL ,
	QUARTER_END_DATE_KEY  INTEGER  NULL ,
	YEAR_NUM  INTEGER  NULL ,
	YEAR_BEGIN_DATE  DATE  NULL ,
	YEAR_BEGIN_DATE_KEY  INTEGER  NULL ,
	YEAR_END_DATE  DATE  NULL ,
	YEAR_END_DATE_KEY  INTEGER  NULL ,
	YYYYMMDD  VARCHAR(8)  NULL ,
	CREATE_TIME  TIMESTAMP  NOT NULL ,
	LAST_UPDATE  TIMESTAMP  NOT NULL ,
	LAST_ID  VARCHAR(16)  NOT NULL ,
	IS_ACTIVE  INTEGER  NOT NULL ,
CONSTRAINT  XPKCT_CALENDAR PRIMARY KEY (CALENDAR_DATE)
);


CREATE TABLE GT_TICKER_PRICE
(
	TICKER  VARCHAR(6)  NOT NULL ,
	COB_DATE  DATE  NOT NULL ,
	BID_TIMESTAMP  TIMESTAMP  NOT NULL ,
	BID_OPEN  DECIMAL(12,6)  NOT NULL ,
	BID_HIGH  DECIMAL(12,6)  NOT NULL ,
	BID_LOW  DECIMAL(12,6)  NOT NULL ,
	BID_CLOSE  DECIMAL(12,6)  NOT NULL ,
	BID_VOLUME  DECIMAL(12,2)  NULL ,
	ASK_TIMESTAMP  TIMESTAMP  NOT NULL ,
	ASK_OPEN  DECIMAL(12,6)  NOT NULL ,
	ASK_HIGH  DECIMAL(12,6)  NOT NULL ,
	ASK_LOW  DECIMAL(12,6)  NOT NULL ,
	ASK_CLOSE  DECIMAL(12,6)  NOT NULL ,
	ASK_VOLUME  DECIMAL(12,2)  NULL ,
	IS_ENABLED  INTEGER  NOT NULL ,
	LOAD_TIME  TIMESTAMP  NOT NULL ,
	LAST_UPDATE  TIMESTAMP  NOT NULL ,
	LAST_ID  VARCHAR(16)  NOT NULL ,
	IS_ACTIVE  INTEGER  NOT NULL ,
CONSTRAINT  XPKGT_POSITION PRIMARY KEY (TICKER,COB_DATE),
CONSTRAINT  R_77 FOREIGN KEY (COB_DATE) REFERENCES GT_CALENDAR(CALENDAR_DATE)
);


