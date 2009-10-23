
/*

  Copyright (c) 2003 by Golden Software of Belarus


  Script


  Abstract


  Author


  Revisions history


  Status


*/


/****************************************************/
/****************************************************/
/**                                                **/
/**   Copyright (c) 2003 by                        **/
/**   Golden Software of Belarus                   **/
/**                                                **/
/****************************************************/
/****************************************************/

/*

  ����� ����� ��������� �������� �������������.
  ���� ���� ��������� ��������:
    1 -- ����� ������
    2 -- ������
    3 -- ��� ����, �������
    4 -- �����
    5 -- ����� �����
    6 -- ���
    7 -- ��糢������
    8 -- �����
    9 -- ����
    10-- ��������

*/

CREATE TABLE gd_dispatchimage
(
  id         dintkey,
  name       dname,
  image      dbmp,

  CONSTRAINT gd_pk_dispatchimage PRIMARY KEY (id)
);

COMMIT;

CREATE TABLE gd_dispatchofficer
(
  id         dintkey,
  name       dname,
  image1     dforeignkey,
  reserved   dreserved,

  CONSTRAINT gd_pk_dispatchofficer_id PRIMARY KEY (id),
  CONSTRAINT gd_fk_dispatchofficer_image1 FOREIGN KEY (image1)
    REFERENCES gd_dispatchimage (id)
);

COMMIT;

CREATE TABLE gd_dispatchofficerimage
(
  officerkey dintkey,
  imagekey   dintkey,

  CONSTRAINT gd_pk_dispatchofficerimage PRIMARY KEY (officerkey, imagekey),
  CONSTRAINT gd_fk_doi_officerkey FOREIGN KEY (officerkey)
    REFERENCES gd_dispatchofficer (id),
  CONSTRAINT gd_fk_doi_imagekey FOREIGN KEY (imagekey)
    REFERENCES gd_dispatchimage (id)
);

COMMIT;

CREATE TABLE gd_dispatch
(
  id         dintkey,
  text       dblobtext80_1251,
  officerkey dintkey,
  color      dinteger,
  priority   dinteger,
  disporder  dinteger,
  datefrom   ddate_notnull,
  datetill   ddate_notnull,
  timefrom   dtime_notnull,
  timetill   dtime_notnull,

  reserved   dreserved,

  CONSTRAINT gd_pk_dispatch_id PRIMARY KEY (id),
  CONSTRAINT gd_fk_dispatch_officerkey FOREIGN KEY (officerkey)
    REFERENCES gd_dispatchofficer (id)
);

COMMIT;

