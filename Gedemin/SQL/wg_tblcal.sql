
/*

  Copyright (c) 2000-2016 by Golden Software of Belarus, Ltd

  Script


  Abstract


  Author


  Revisions history


  Status

    Draft

*/

RECREATE TABLE wg_position
(
  id           dintkey,
  name         dname UNIQUE,
  editiondate  deditiondate,
  reserved     dreserved,

  CONSTRAINT wg_pk_position_id PRIMARY KEY (id)
);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER wg_bi_position FOR wg_position
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;

RECREATE TABLE wg_holiday
(
  id          dintkey,
  holidaydate ddate NOT NULL UNIQUE,
  name        dname,
  editiondate deditiondate,
  disabled    ddisabled,

  CONSTRAINT wg_pk_holiday_id PRIMARY KEY (id)
);

COMMIT;


RECREATE TABLE wg_tblcal
(
  id         dintkey,
  name       dname,

  /* працоўныя дні тыдня */
  mon        dboolean_notnull DEFAULT 1,
  tue        dboolean_notnull DEFAULT 1,
  wed        dboolean_notnull DEFAULT 1,
  thu        dboolean_notnull DEFAULT 1,
  fri        dboolean_notnull DEFAULT 1,
  sat        dboolean_notnull DEFAULT 0,
  sun        dboolean_notnull DEFAULT 0,

  /*Праздничные дни по умолчанию нерабочие*/
  holidayiswork  dboolean_notnull DEFAULT 0,

  /* інтэрвалы працоўнага часу */
  w1_offset   dinteger DEFAULT 0,
  w1_start1   dtime_notnull DEFAULT '00:00:00',
  w1_end1     dtime_notnull DEFAULT '00:00:00',
  w1_start2   dtime_notnull DEFAULT '00:00:00',
  w1_end2     dtime_notnull DEFAULT '00:00:00',
  w1_start3   dtime_notnull DEFAULT '00:00:00',
  w1_end3     dtime_notnull DEFAULT '00:00:00',
  w1_start4   dtime_notnull DEFAULT '00:00:00',
  w1_end4     dtime_notnull DEFAULT '00:00:00',

  w2_offset   dinteger DEFAULT 0,
  w2_start1   dtime_notnull DEFAULT '00:00:00',
  w2_end1     dtime_notnull DEFAULT '00:00:00',
  w2_start2   dtime_notnull DEFAULT '00:00:00',
  w2_end2     dtime_notnull DEFAULT '00:00:00',
  w2_start3   dtime_notnull DEFAULT '00:00:00',
  w2_end3     dtime_notnull DEFAULT '00:00:00',
  w2_start4   dtime_notnull DEFAULT '00:00:00',
  w2_end4     dtime_notnull DEFAULT '00:00:00',

  w3_offset   dinteger DEFAULT 0,
  w3_start1   dtime_notnull DEFAULT '00:00:00',
  w3_end1     dtime_notnull DEFAULT '00:00:00',
  w3_start2   dtime_notnull DEFAULT '00:00:00',
  w3_end2     dtime_notnull DEFAULT '00:00:00',
  w3_start3   dtime_notnull DEFAULT '00:00:00',
  w3_end3     dtime_notnull DEFAULT '00:00:00',
  w3_start4   dtime_notnull DEFAULT '00:00:00',
  w3_end4     dtime_notnull DEFAULT '00:00:00',

  w4_offset   dinteger DEFAULT 0,
  w4_start1   dtime_notnull DEFAULT '00:00:00',
  w4_end1     dtime_notnull DEFAULT '00:00:00',
  w4_start2   dtime_notnull DEFAULT '00:00:00',
  w4_end2     dtime_notnull DEFAULT '00:00:00',
  w4_start3   dtime_notnull DEFAULT '00:00:00',
  w4_end3     dtime_notnull DEFAULT '00:00:00',
  w4_start4   dtime_notnull DEFAULT '00:00:00',
  w4_end4     dtime_notnull DEFAULT '00:00:00',

  w5_offset    dinteger DEFAULT 0,
  w5_start1    dtime_notnull DEFAULT '00:00:00',
  w5_end1      dtime_notnull DEFAULT '00:00:00',
  w5_start2    dtime_notnull DEFAULT '00:00:00',
  w5_end2      dtime_notnull DEFAULT '00:00:00',
  w5_start3    dtime_notnull DEFAULT '00:00:00',
  w5_end3      dtime_notnull DEFAULT '00:00:00',
  w5_start4    dtime_notnull DEFAULT '00:00:00',
  w5_end4      dtime_notnull DEFAULT '00:00:00',

  w6_offset    dinteger DEFAULT 0,
  w6_start1    dtime_notnull DEFAULT '00:00:00',
  w6_end1      dtime_notnull DEFAULT '00:00:00',
  w6_start2    dtime_notnull DEFAULT '00:00:00',
  w6_end2      dtime_notnull DEFAULT '00:00:00',
  w6_start3    dtime_notnull DEFAULT '00:00:00',
  w6_end3      dtime_notnull DEFAULT '00:00:00',
  w6_start4    dtime_notnull DEFAULT '00:00:00',
  w6_end4      dtime_notnull DEFAULT '00:00:00',

  w7_offset    dinteger DEFAULT 0,
  w7_start1    dtime_notnull DEFAULT '00:00:00',
  w7_end1      dtime_notnull DEFAULT '00:00:00',
  w7_start2    dtime_notnull DEFAULT '00:00:00',
  w7_end2      dtime_notnull DEFAULT '00:00:00',
  w7_start3    dtime_notnull DEFAULT '00:00:00',
  w7_end3      dtime_notnull DEFAULT '00:00:00',
  w7_start4    dtime_notnull DEFAULT '00:00:00',
  w7_end4      dtime_notnull DEFAULT '00:00:00',

  /* перад святочны дзень */
  w8_offset    dinteger DEFAULT 0,
  w8_start1    dtime_notnull DEFAULT '00:00:00',
  w8_end1      dtime_notnull DEFAULT '00:00:00',
  w8_start2    dtime_notnull DEFAULT '00:00:00',
  w8_end2      dtime_notnull DEFAULT '00:00:00',
  w8_start3    dtime_notnull DEFAULT '00:00:00',
  w8_end3      dtime_notnull DEFAULT '00:00:00',
  w8_start4    dtime_notnull DEFAULT '00:00:00',
  w8_end4      dtime_notnull DEFAULT '00:00:00',

  editiondate  deditiondate,

  CONSTRAINT wg_pk_tblcal PRIMARY KEY (id)
);

COMMIT;

RECREATE TABLE wg_tblcalday
(
  id         dintkey,
  tblcalkey  dintkey,
  theday     ddate_notnull,
  workday    dboolean_notnull DEFAULT 1,
  wstart1    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend1      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart2    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend2      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart3    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend3      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wstart4    dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',
  wend4      dtimestamp_notnull DEFAULT '1900-01-01 00:00:00',

  editiondate deditiondate,

  WDURATION  COMPUTED BY (G_M_ROUNDNN(((wend1 - wstart1) + (wend2 - wstart2) + (wend3 - wstart3) + (wend4 - wstart4))*24, 0.01)),

  dow COMPUTED BY (EXTRACT(weekday FROM theday)),

  CONSTRAINT wg_pk_tblcalday PRIMARY KEY (id),
  CONSTRAINT wg_fk_tblcalday_tblcal FOREIGN KEY (tblcalkey) REFERENCES wg_tblcal (id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT wg_unq_tblcalday_1 UNIQUE (tblcalkey, theday),
  CONSTRAINT wg_chk_tblcalday_1 CHECK (wend1 >= wstart1),
  CONSTRAINT wg_chk_tblcalday_2 CHECK (wend2 >= wstart2),
  CONSTRAINT wg_chk_tblcalday_3 CHECK (wend3 >= wstart3),
  CONSTRAINT wg_chk_tblcalday_4 CHECK (wend4 >= wstart4),
  CONSTRAINT wg_chk_tblcalday_5 CHECK ((wstart2 = '1900-01-01 00:00:00') OR (wstart2 >= wend1)),
  CONSTRAINT wg_chk_tblcalday_6 CHECK ((wstart3 = '1900-01-01 00:00:00') OR (wstart3 >= wend2)),
  CONSTRAINT wg_chk_tblcalday_7 CHECK ((wstart4 = '1900-01-01 00:00:00') OR (wstart4 >= wend3))

);

SET TERM ^ ;

CREATE TRIGGER wg_bi_holiday FOR wg_holiday
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER wg_bi_tblcal FOR wg_tblcal
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE TRIGGER wg_bi_tblcalday FOR wg_tblcalday
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

SET TERM ; ^

COMMIT;


