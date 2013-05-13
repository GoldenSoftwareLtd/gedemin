/*������������ ���������*/

/* GD_SUBSYSTEM */
/*1 .. 50000 */

/* �����������*/
/*GD_REF*/
/* 50001 .. 100000*/

/* �������� */
/* 100001 .. 150000 */
/* ������������ */
/* GD_USER */
/* 150001.. 200000*/
       
/*������*/
/* GD_CURR */
/* 200001 .. 250000 */

/*��������*/
/* 250001 .. 300000 */
	
/*GD_CARDACCOUNT*/
/* 300001 .. 350000  */

/* GD_TAXTYPE */
/*350001..360000*/

/* gd_trtype */
/* 400001 .. 450000*/

/* msg_box  */
/* 450001 .. 500000 */

/* ��������� ��� ���������� ��������� "����������� ������" */
/* gd_trtypevariable */
/* 500001 .. 550000*/

/*bn_paymentspec*/
/*600001 650001 */

/* gd_contact */
/* 650001 .. 700000*/

/* ���� */
/* gd_command*/
/* 700001 .. 800000 */

/* gd_documenttype */
/* 800001 .. 850000 */

/* flt_funcgroup  */
/* 850001..850099 */

/* globalstorage */
/* 880000        */

/* flt_function */
/* 900001..950001 */


/*1000001 .. 1010000*/

/* evt_object */
/* 1010001-1050000 */

/* gd_compacctype */
/* 1799900-1799999 */

/* gd_place */
/* 1800000-1900000 */

/*  gd_value */
/*2000001 .. 3000000*/

/*3100000 .. 3200000*/


/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    Constants.sql

  Abstract

    An Interbase script with Constants for GEDEMIN  system.

  Author

    Nikolai Kornachenko (18.05.00)

  Revisions history

    Initial  18.05.00  NK    Initial version

  Status 
    
    Draft

*/

/* ���������� */

/* GD_SUBSYSTEM */
/*99 .. 50000 */
/* INSERT INTO gd_subsystem(id, name, disabled, description, reserved) VALUES (,,,,,)*/

INSERT INTO gd_subsystem(id, name, description, reserved)
  VALUES (1000, '�����������������', '����������������� �������', NULL);

/* 49000 - ������� Deparatment dp_contacts.sql*/

COMMIT;

/* ������ */

/* GD_USERGROUP */

/* INSERT INTO gd_usergroup (id, name, description) VALUES (,,); */

INSERT INTO gd_usergroup (id, name, description)
  VALUES (1, '��������������', '��������� ��������������');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (2, '������� ������������', '������� ������������');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (3, '������������', '������� ������������');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (4, '��������� ������', '��������� ������');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (5, '��������� ������', '��������� ������');
INSERT INTO gd_usergroup (id, name, description)
  VALUES (6, '�����', '����� �������');

COMMIT;

/* ������� ��������� */

INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000001, '��.', '�����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000002, '��', '���������', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000003, '��.�.', '���������� ����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000004, '���.�.', '���������� ����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000005, '�', '�����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000006, '�', '����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000007, '�����', '�����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000008, '�����', '�����', 1);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000009, '��.', '��������', 1);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000010, '����.', '��������', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000011, '���', '����', 0);
INSERT INTO GD_VALUE (ID, NAME, DESCRIPTION, ISPACK) VALUES (3000012, '����', '����', 1);

COMMIT;


/* ������������ */

/* GD_USER */
/* 150001.. 200000*/
/*INSERT INTO gd_user(id, name, passw, ingroup, fullname, description, ibname,
                      ibpassword, externalkey, disabled, lockedout, mustchange,
                      cantchangepassw, passwneverexp, expdate, workstart,
                      workend, icon, reserved)
       VALUES (,,,,,,,,,,,,,,,,,,);
*/

INSERT INTO gd_contact(id, contacttype, name)
    VALUES(650001, 0, '��������');
INSERT INTO gd_contact(id, parent, contacttype, name)
    VALUES(650002, 650001, 2, '�������������');
INSERT INTO gd_people(contactkey, surname) VALUES(650002, '�������������');

INSERT INTO gd_user (id, name, passw, ingroup, fullname, description, ibname,
                      ibpassword, externalkey, lockedout, mustchange,
                      cantchangepassw, passwneverexp, expdate, workstart,
                      workend, icon, reserved, contactkey)
VALUES (150001, 'Administrator', 'Administrator', -1, '�������������', '������������� �������',
          'SYSDBA', 'masterkey', NULL, 0, 0, 0, 1, NULL, NULL, NULL, NULL, NULL, 650002);

COMMIT;


/*****************************************************************************/
/*    ���� ������ ����                                                       */
/*****************************************************************************/


/* gd_compacctype */
/* 1799900-1799999 */

INSERT INTO gd_compacctype (id, name)
   VALUES(1799900, '��������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799910, '������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799920, '���������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799930, '��������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799940, '�������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799950, '���������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799960, '����������������� ����');
INSERT INTO gd_compacctype (id, name)
   VALUES(1799970, '������� ������');

COMMIT;


/*������*/
/* 200001 .. 250000 */



INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200010, 0, 1, 'BYR', '����������� �����', 'BYR', 'Br',
     1, 0, '�������', '���.', 1, NULL, NULL, '����������� ������', '����������� �����', '������', '�������');

INSERT INTO gd_curr
  (id, disabled, isNCU, isEq, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200020, 0, 0, 1, 'USD', '������ ���', 'USD', '$',
     0, 2, '����', '�.', 1, NULL, NULL, '�������� ���', '������� ���', '������', '�����');

INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200040, 0, 0, 'EUR', '����', 'EUR', 'EUR',
     1, 2, '����', '�.', 1, NULL, NULL, '����', '����', '������', '�����');

INSERT INTO gd_curr
  (id, disabled, isNCU, code, name, shortname, sign, place, decdigits,
     fullcentname, shortcentname, centbase, icon, reserved, name_0, name_1, centname_0, centname_1)
  VALUES (200050, 0, 0, 'RUB', '���������� �����', 'RUB', '�.',
     1, 2, '�������', '�.', 1, NULL, NULL, '���������� ������', '���������� �����', '������', '�������');

COMMIT;

INSERT INTO GD_CONTACT
  (ID,PARENT,CONTACTTYPE,NAME)
  VALUES
  (650010,650001,3,'<������ ������������ �����������>');

INSERT INTO GD_COMPANY
  (CONTACTKEY,FULLNAME)
  VALUES
  (650010,'<������ ������������ �����������>');

INSERT INTO GD_OURCOMPANY
  (COMPANYKEY)
  VALUES
  (650010);

INSERT INTO GD_CONTACT
  (ID,PARENT,CONTACTTYPE,NAME)
  VALUES
  (650015,650001,5,'<������ ������������ �����>');

INSERT INTO GD_COMPANY
  (CONTACTKEY,FULLNAME)
  VALUES
  (650015,'<������ ������������ �����>');

INSERT INTO GD_BANK
  (BANKKEY,BANKCODE)
  VALUES
  (650015,'<������ ��� �����>');

INSERT INTO GD_COMPANYACCOUNT
  (ID, COMPANYKEY, BANKKEY, ACCOUNT, ACCOUNTTYPEKEY, CURRKEY)
  VALUES
  (650100, 650010, 650015, '<������ ����>', 1799900, 200010);

UPDATE GD_COMPANY
  SET COMPANYACCOUNTKEY = 650100
  WHERE CONTACTKEY = 650010;

/* �������� */
/* 100001 .. 150000 */

COMMIT;

/*AC_ACCOUNT*/
/* 300001 .. 350000  */

INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300001, NULL, '���� ������', '���� ������', 'A', 'C', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (399000, 300001, '���������� �����', '���������� �����', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300002, 300001, '������������ �����', '������������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300003, 300002, '�������', '00', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300010, 399000, '1. ������������ ������', '1. ������������ ���', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (310000, 399000, '2. ���������������� ������', '2. ��������. ������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (320000, 399000, '3. ������� �� ������������', '3. ������� �� �����.', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (340000, 399000, '4. ������� ��������� � ����������', '4. ������� ���������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (350000, 399000, '5. �������� ��������', '5. �������� ��������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (360000, 399000, '6. �������', '6. �������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380000, 399000, '7. ��������� ����������� �������', '7. ������. �����.', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385000, 399000, '8. ���������� ����������', '8. ��� ����������', 'A', 'F', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300100, 300010, '�������� ��������', '01', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300101, 300100, '����������� �������� ��������', '01.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300102, 300100, '������� �������� �������', '01.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300200, 300010, '����� �������� �������', '02', 'P', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300201, 300200, '����� ����������� �������� �������', '02.01', 'P', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300202, 300200, '����� ��������� �������� � ������', '02.02', 'P', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300300, 300010, '�������� �������� � ������������ ��������', '03', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300301, 300300, '��������� ��� ����� � ������', '03.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300302, 300300, '���������, ��������������� �� ��������', '03.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300400, 300010, '�������������� ������', '04', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300500, 300010, '����������� �������������� �������', '05', 'P', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300700, 300010, '������������ � ���������', '07', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300701, 300700, '������������ � ��������� �������������', '07.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300702, 300700, '������������ � ��������� ���������', '07.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300800, 300010, '����������� ��������', '08', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300801, 300800, '������������ ��������� ��������', '08.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300802, 300800, '������������ �������� ������������������', '08.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300803, 300800, '������������� �������� �������� �������', '08.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300804, 300800, '������������ ��������� �������� �������� �������', '08.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300805, 300800, '�������, �� ������������� ��������� �������� �������', '08.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300806, 300800, '������������ �������������� �������', '08.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300807, 300800, '������� ��������� �������� � �������� �����', '08.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300808, 300800, '������������ �������� ��������', '08.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (300809, 300800, '���������� ������-�����������������, ������-��������������� � ��������������� �����', '08.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311000, 310000, '���������', '10', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311001, 311000, '����� � ���������', '10.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311002, 311000, '�������� ������������� � ������������� �������, ����������� � ������', '10.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311003, 311000, '�������', '10.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311004, 311000, '���� � ������ ���������', '10.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311005, 311000, '�������� �����', '10.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311006, 311000, '������ ���������', '10.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311007, 311000, '���������, ���������� � ����������� �� �������', '10.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311008, 311000, '������������ ���������', '10.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311009, 311000, '��������� � ������������ ��������������', '10.09', NULL, 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311100, 310000, '�������� �� ����������� � �������', '11', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311010, 311000, '����������� �������� � ����������� ������ �� ������', '10.10', NULL, 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311011, 311000, '����������� �������� � ����������� ������ � ������������', '10.11', NULL, 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311400, 310000, '������� ��� �������� ��������� ������������ ���������', '14', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311500, 310000, '������������ � ������������ ����������', '15', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311600, 310000, '���������� � ��������� ����������', '16', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393001, 300002, '����������� �������� ��������', '001', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311900, 310000, '����� �� ����������� ��������� �� ������������� �������, �������, �������', '18', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311901, 311900, '��� �� ������������� ��', '18.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311902, 311900, '��� �� ������������� �������������� �������', '18.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393002, 300002, '�������-������������ ��������, �������� �� ������������� ��������', '002', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393003, 300002, '���������, �������� � �����������', '003', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393004, 300002, '������, �������� �� ��������', '004', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322000, 320000, '�������� ������������', '20', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322100, 320000, '������������� ������������ ������������', '21', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322300, 320000, '��������������� ������������', '23', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322500, 320000, '�������������������� �������', '25', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322600, 320000, '����������������� �������', '26', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322800, 320000, '���� � ������������', '28', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322900, 320000, '������������� ������������ � ���������', '29', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (323100, 385000, '������� ������� ��������', '97', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393005, 300002, '������������, �������� ��� �������', '005', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344000, 340000, '������ ��������� �����, �����', '40', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344100, 340000, '������', '41', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344101, 344100, '������ �� �������', '41.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344102, 344100, '������ � ��������� ��������', '41.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344103, 344100, '���� ��� ������� � ��������', '41.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344104, 344100, '�������� �������', '41.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344200, 340000, '�������� �������', '42', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344201, 344200, '�������� ������� (������, �������)', '42.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344202, 344200, '������ �����������', '42.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344300, 340000, '������� ���������', '43', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344400, 340000, '�������� ���������', '44', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344500, 340000, '������ �����������', '45', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344501, 344500, '������ ����������� � ������� �����', '45.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344502, 344500, '������ ����������� � ��������� �����', '45.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344600, 385000, '���������� ��������� (�����, �����)', '90', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344700, 385000, '������������ ������ � �������', '91', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355000, 350000, '�����', '50', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355100, 350000, '��������� ����', '51', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355200, 350000, '�������� ����', '52', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355201, 355200, '������ ������', '52.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355202, 355200, '�� �������', '52.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355500, 350000, '����������� ����� � ������', '55', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355501, 355500, '�����������', '55.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355502, 355500, '������� ������', '55.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355700, 350000, '�������� � ����', '57', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355800, 350000, '������������� ���������� ��������', '58', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355801, 355800, '��������� � ������ ������ ������', '58.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355802, 355800, '��������', '58.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355803, 355800, '��������������� �����', '58.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355804, 355800, '������', '58.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366000, 360000, '������� � ������������ � ������������', '60', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366200, 360000, '������� � ������������ � �����������', '62', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366201, 366200, '������� � ������� �������', '62.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366202, 366200, '������� ��������� ���������', '62.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366203, 366200, '������� ����������', '62.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366800, 360000, '������� � ��������', '68', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366900, 360000, '������� �� ����������� ����������� � �����������', '69', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366901, 366900, '������� �� ���. �����������', '69.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366902, 366900, '������� �� ����������� �����������', '69.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367000, 360000, '������� �� ������ �����', '70', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393006, 300002, '������ ������� ����������', '006', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367100, 360000, '������� � ������������ ������', '71', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367300, 360000, '������� � ���������� �� ������ ���������', '73', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367301, 367300, '������� �� ������, ������. � ������', '73.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367302, 367300, '������� �� ����������. ������', '73.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367303, 367300, '������� �� ������. ���. ������', '73.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367500, 360000, '������� � ������������', '75', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367501, 367500, '������� �� ������� � ��', '75.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367502, 367500, '������� �� �������', '75.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367600, 360000, '������� � ����. ���������� � �����������', '76', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367900, 360000, '������������������� �������', '79', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367901, 367900, '�� ����������� ��������', '79.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367902, 367900, '�� ������� ���������', '79.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380001, 385000, '������� � ������', '99', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380002, 380000, '����������� ����� (����)', '81', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380004, 360000, '������� �� ������������ ������', '63', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380005, 385000, '������ ������� ��������', '98', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (380006, 385000, '��������� �� ����� ���.���������', '94', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385001, 380000, '�������� ����', '80', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385002, 380000, '��������� ����', '82', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385012, 380000, '���������� ����', '83', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385003, 380000, '���������������� �������', '84', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385004, 385000, '����������������� ������ � �������', '92', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (385005, 385000, '������� ���������. ��������', '96', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390001, 360000, '������������� ������� ������', '66', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390007, 360000, '������������ ������� ������', '67', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (390005, 380000, '������� ��������������', '86', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322001, 322000, '������������ ������������', '20.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322002, 322000, '�������������������� ������������', '20.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322003, 322000, '������������ ���������� � ������� �����', '20.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322004, 322000, '������������ ������������ � ��������� �����', '20.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322005, 322000, '������������ ��������� � ������������� �����', '20.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322006, 322000, '������������ ������������������ �����', '20.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322007, 322000, '������������ ������ ����������� � ��������������� �����', '20.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322008, 322000, '���������� � ������ ������������� �����', '20.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322009, 322000, '������������ �������', '20.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322301, 322300, '������������ ���������� ������ �������', '23.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322302, 322300, '��������������� ������������ ������������', '23.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322303, 322300, '������ �������� �������', '23.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322304, 322300, '������������ ������������, �������, �������� ������, ������������ ������� � �����������', '23.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322305, 322300, '������������ ������ ������������ ��������', '23.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322306, 322300, '���������� ��������� (�����������) ����������', '23.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322307, 322300, '������ �������� ����������', '23.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322308, 322300, '������������� � �����������', '23.08', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322309, 322300, '����������� �������������������� ���������', '23.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322901, 322900, '������� ����������� ��������', '29.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322902, 322900, '��������� �������� ���������', '29.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322903, 322900, '������� ������������', '29.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322904, 322900, '���������� ������� ���������� ����������', '29.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322905, 322900, '���������� ����� ������, ���������� � ������ ���������� ���������������� ����������', '29.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322906, 322900, '���������� ���������� ��������', '29.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (322907, 322900, '���������� ������������� ������������� �������', '29.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344203, 344200, '����� �� ����������� ��������� � ���� �������', '42.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344204, 344200, '����� � ������', '42.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344401, 344400, '������������ �������', '44.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344402, 344400, '�������� ���������', '44.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355001, 355000, '����� �����������', '50.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355002, 355000, '������������ �����', '50.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355003, 355000, '�������� ���������', '50.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355004, 355000, '�������� �����', '50.04', 'A', 'S', 1, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355005, 355000, '����� ��������', '50.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355503, 355500, '���������� ����� � ����������� �������� ������� ���������� ��������', '55.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355504, 355500, '���������� ����� � ����������� ������', '55.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355505, 355500, '����������� ���� �������� ��������������', '55.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355506, 355500, '������� ���� �������', '55.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355507, 355500, '���������� �����', '55.07', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355701, 355700, '��������������� �������� ��������', '57.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355702, 355700, '�������� �������� ��� ������� ������', '57.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355703, 355700, '�������� �������� ��� �������', '57.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (355704, 355700, '�������� � ���� �� ���������� ������', '57.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (392000, 350000, '������� ��� ����������� ���������� �������� � ������ ������', '59', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366204, 366200, '������ ����������', '62.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366801, 366800, '������ � ���������� ���������� � ������������� �������, ���������, �����, �����', '68.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366802, 366800, '������, ������������ �� ������� �� ���������� �������, ���������, �����, �����', '68.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366803, 366800, '������ ������������ �� �������', '68.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366804, 366800, '������ �� ������ ���������� ���', '68.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (366805, 366800, '������ ������, ����� � ����������', '68.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367601, 367600, '������� � ������������� � ������ �� �������������� ����������', '76.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367602, 367600, '������� �� �������������� � ������� �����������', '76.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367603, 367600, '������� �� ����������', '76.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367604, 367600, '������� �� ����������� ���������� � ������ �������', '76.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367605, 367600, '������� �� �������������� ������', '76.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367606, 367600, '������� �� ������, ��������� � ������', '76.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (367903, 367900, '������� �� �������� �������������� ���������� ����������', '79.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344601, 344600, '������� �� ����������', '90.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344602, 344600, '������������� ����������', '90.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344603, 344600, '����� �� ����������� ���������', '90.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344604, 344600, '������', '90.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344605, 344600, '������ ������ � ����� �� �������', '90.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344606, 344600, '���������� �������', '90.06', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344609, 344600, '�������/������ �� ����������', '90.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344701, 344700, '������������ ������', '91.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344702, 344700, '������������ �������', '91.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344703, 344700, '����� �� ����������� ���������', '91.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344704, 344700, '������ ������ � ����� �� ������������ �������', '91.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344709, 344700, '������ ������������ ������� � ��������', '91.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386001, 385004, '����������������� ������', '92.01', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386002, 385004, '����������������� �������', '92.02', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386003, 385004, '����� �� ����������� ���������', '92.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386004, 385004, '������ ������ � ����� �� ����������������� �������', '92.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (386009, 385004, '������ ����������������� ������� � ��������', '92.09', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393007, 300002, '��������� � ������ ������������� ������������������ ���������', '007', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393008, 300002, '����������� ������������ � �������� ����������', '008', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311903, 311900, '��� �� ������������� �������-������������ ���������, �������, �������', '18.03', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (311904, 311900, '��� �� ������������� �������', '18.04', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (344105, 344100, '��������� ���������� ��������� �-��', '41.05', 'A', 'S', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (391000, 340000, '����������� ����� �� ������������� �������', '46', 'A', 'A', 0, 0, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393010, 300002, '��������������� ���� ��������������� �������� �������', '010', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393011, 300002, '�������� ��������, ������� � ������', '011', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393012, 300002, '�������������� ������, ���������� � �����������', '012', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393013, 300002, '��������������� ���� ��������������� �������������� �������', '013', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393014, 300002, '������ ��������� �������� �������', '014', 'A', 'A', 0, 1, -1, -1, -1);
INSERT INTO AC_ACCOUNT (ID, PARENT, NAME, ALIAS, ACTIVITY, ACCOUNTTYPE, MULTYCURR, OFFBALANCE, AFULL, ACHAG, AVIEW) VALUES (393009, 300002, '����������� ������������ � �������� ��������', '009', 'A', 'A', 0, 1, -1, -1, -1);


COMMIT;

/* gd_documenttype */
/* 800001 .. 850000 */

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype)
  VALUES (800001, '800001_17', '������� � ���������', '������� � ���������', 'B');

INSERT INTO gd_documenttype(id, ruid, parent, name, description)
  VALUES (800300, '800300_17', 800001, '���������� �������', '���������� �������');

INSERT INTO gd_documenttype(id, ruid, parent, name, description)
  VALUES (800350, '800350_17', 800001, '���������� ���������', '���������� ���������');

/* ��������� ��������� */

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype, classname)
  VALUES (804000, '804000_17', '��������� ���������',
    '��������� �� ������, ����������� � �������� ��� � �����', 'B', 'TgdcInvDocumentType');

INSERT INTO gd_documenttype(id, ruid, name, description, documenttype, classname)
  VALUES (805000, '805000_17', '�����-�����', '������ �����-������', 'B', 'TgdcInvPriceListType');

/* ������������� ��������� */

INSERT INTO gd_documenttype(id,
    ruid,
    name,
    description,
    documenttype,
    classname)
  VALUES (806000,
    '806000_17',
    '������������� ���������',
    '��������� ��� �����������',
    'B',
    'TgdcDocumentType');

INSERT INTO gd_documenttype(id, ruid, parent, name, description, documenttype, classname)
  VALUES (806001, '806001_17', 806000,
    '������������� ��������', '��������� ��� ��������� ������������ ������������� ��������', 'D', 'TgdcInvDocumentType');

/* ������ ����������� */

INSERT INTO gd_documenttype(id, parent, ruid, name, description, documenttype)
  VALUES (807005, 806000, '807005_17', '������ �����������', '��������� ��� ������� ������� ������� �����������', 'D');

/* ������� �������� */

INSERT INTO ac_transaction(id, name) VALUES (807001, '������������ ��������');

INSERT INTO ac_trrecord(id, transactionkey, documenttypekey, description) VALUES (807100, 807001, 806001, '������������ ��������');

/*849000 - 850000 ��������������� ��� ������� DEPARTMENT */

/* gd_trtype */
/* 400001 .. 450000*/

/* 459001 .. 450000 ��������������� ��� ������� DEPARTMENT */

/*
INSERT INTO gd_goodgroup (name) VALUES ('<������ ������������ ������>');
*/


COMMIT;

/* gd_contact */
/* 650001 .. 700000*/

COMMIT;

/*
 *
 * ����
 *
 *
 */
/* gd_command*/
/* 700001 .. 800000 */


/*
 *
 * �������������
 *
 *
 */

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex, aview)
    VALUES (
      710000,
      NULL,
      '�������������',
      'explorer',
      NULL,
      0,
      1
    );

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      714000,
      710000,
      '�����������',
      'accountancy',
      NULL,
      0
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730300,
        714000,
        '���� ������',
        'ref_card_account',
        'TgdcAcctAccount',
        NULL,
        219
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730700,
        714000,
        '������� ���. ��������',
        'ref_tr_type',
        'TgdcAcctTransaction',
        NULL,
        59
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714050,
        714000,
        '�������������� ���. ��������',
        '',
        'Tgdc_frmAutoTransaction',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714010,
        714000,
        '������ ������������� ��������',
        'acc_journal',
        'TgdcAcctViewEntryRegister',
        NULL,
        53
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714022,
        714000,
        '������-�����',
        '',
        'Tgdv_frmAcctLedger',
        NULL,
        186
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714030,
        714000,
        '������ �����',
        '',
        'Tgdv_frmAcctAccReview',
        NULL,
        220
      );

    INSERT INTO GD_COMMAND (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,
       CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
       VALUES (
         714098,
         714000,
         '����� �����',
         'acc_AccountCard',
         0,
         NULL,
         220,
         NULL,
         'Tgdv_frmAcctAccCard',
         NULL,
         -1,
         -1,
         -1,
         0,
         NULL);

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714025,
        714000,
        '������� �����',
        '',
        'Tgdv_frmGeneralLedger',
        NULL,
        85
      );
      
      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714200,
        714000,
        '������� �� ����� �����',
        '',
        'TfrmCalculateBalance',
        NULL,
        87
      );

/*    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        714020,
        714021,
        '��������� ������-������',
        '',
        'TgdcLedger',
        NULL,
        0
      );*/

    INSERT INTO GD_COMMAND
      (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
    VALUES
      (714090,714000,'��������� ���������','acc_CirculationList',0,NULL,61,NULL,'Tgdv_frmAcctCirculationList',NULL,-1,-1,-1,0,NULL);

    INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      715000,
      710000,
      '����',
      'bank',
      NULL,
      104
    );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        715020,
        715000,
        '������� �� �/�',
        'bn_bank_statement',
        'TgdcBankStatement',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        715025,
        715000,
        '��������� �� �/�',
        'bn_bank_catalogue',
        'TgdcBankCatalogue',
        NULL,
        0
      );


  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      730000,
      710000,
      '�����������',
      'references',
      NULL,
      7
    );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730100,
        730000,
        '�������',
        'ref_contact',
        'TgdcBaseContact',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730110,
        730100,
        '�����������',
        '',
        'TgdcCompany',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730115,
        730110,
        '�����',
        '',
        'TgdcBank',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730117,
        730110,
        '��������� �����',
        '',
        'TgdcAccount',
        NULL,
        0
      );

      /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730119,
        730110,
        '������� �����������',
        '',
        'TgdcOurCompany',
        NULL,
        0
      );
      */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730120,
        730100,
        '����',
        '',
        'TgdcContact',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730130,
        730100,
        '������',
        '',
        'TgdcGroup',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730900,
        730110,
        '�������������',
        'ref_department',
        'TgdcDepartment',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730902,
        730110,
        '����������',
        'ref_employee',
        'TgdcEmployee',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730200,
        730000,
        '����� �����',
        'ref_curr_rate',
        'TgdcCurrRate',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730210,
        730200,
        '������',
        '',
        'TgdcCurr',
        NULL,
        0
      );

    /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730600,
        730000,
        '������� �����������',
        'ref_work_company',
        'TgdcOurCompany',
        NULL,
        0
      );
    */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730800,
        730000,
        '���������� ���',
        'ref_dir_good',
        'TgdcGood',
        NULL,
        181
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730805,
        730800,
        '������ ���',
        '',
        'TgdcGoodGroup',
        NULL,
        142
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730810,
        730800,
        '�����������',
        '',
        'TgdcMetal',
        NULL,
        165
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730820,
        730800,
        '������',
        '',
        'TgdcTax',
        NULL,
        185
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730830,
        730800,
        '���� ����',
        '',
        'TgdcTNVD',
        NULL,
        75
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730840,
        730800,
        '������� ���������',
        '',
        'TgdcValue',
        NULL,
        201
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        730950,
        730000,
        '���.-����. �������',
        'ref_place',
        'TgdcPlace',
        NULL,
        147
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731050,
        730000,
        '���� ���������� ������',
        'ref_compacctype',
        'TgdcCompanyAccountType',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731100,
        730000,
        '������ �������� �������',
        'ref_tablecalendar',
        'TgdcTableCalendar',
        NULL,
        92
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731150,
        730000,
        '��������������� ���������',
        'ref_holiday',
        'TgdcHoliday',
        NULL,
        236
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        731200,
        730000,
        '���������',
        'ref_position',
        'TgdcWgPosition',
        NULL,
        0
      );
  /* 739500 - 74000 ����������� DEPARTMENT */

  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      740000,
      710000,
      '������',
      'service',
      NULL,
      144
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740050,
        740000,
        '�������������',
        'srv_administrator',
        '',
        NULL,
        155,
        1 /* ������ �������������� �������� */
      );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740055,
          740050,
          '������������',
          'adm_user',
          'TgdcUser',
          NULL,
          0,
          1 /* ������ �������������� �������� */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740060,
          740050,
          '������ �������������',
          'adm_user_group',
          'TgdcUserGroup',
          NULL,
          0,
          1 /* ������ �������������� �������� */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740065,
          740050,
          '��������',
          'adm_operation',
          'TgdcOperation',
          NULL,
          0,
          1 /* ������ �������������� �������� */
        );

      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740070,
          740050,
          '������ �������',
          'srv_eventlog',
          'TgdcJournal',
          NULL,
          256,
          1
        );
		
      INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
        VALUES (
          740080,
          740050,
          '���������� ���������',
          '',
          'TgdcBlockRule',
          NULL,
          256,
          1
        );
		

        /*
    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740100,
        740000,
        '����������� ������',
        'srv_bugbase',
        'TgdcBugBase',
        NULL,
        0
      );
        */

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740300,
        740000,
        '���������',
        'srv_storage',
        'Tst_frmMain',
        NULL,
        255,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740302,
        740300,
        '��������� (�/�)',
        'srv_storage_new',
        'TgdcStorage',
        NULL,
        255,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740350,
        740000,
        '�������',
        'TgdcComponentFilter',
        'TgdcComponentFilter',
        NULL,
        20,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex, aview)
      VALUES (
        740400,
        740000,
        '��������',
        'srv_attribute',
        '',
        NULL,
        0,
        1
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740500,
        740000,
        '������������ ���������',
        'regionalsettings',
        'TdlgRegionalSettings',
        NULL,
        154
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740600,
        740000,
        '������� ���������',
        'documenttypes',
        'TgdcDocumentType',
        NULL,
        0
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740900,
        740000,
        '���������',
        'constants',
        'TgdcConst',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740910,
        740000,
        '�����',
        'Files',
        'TgdcFile',
        NULL,
        85
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740915,
        740000,
        '������������',
        'LinkedObjects',
        'TgdcLink',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        740920,
        740000,
        '�������������',
        'explorer',
        'TgdcExplorer',
        NULL,
        260
      );

  /*
  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      750000,
      710000,
      '���������',
      'TgdcBaseMessage',
      'TgdcBaseMessage',
      NULL,
      0
    );
  */


  /*
  INSERT INTO gd_command (id, parent, name, cmd, hotkey, imgindex)
    VALUES (
      760000,
      710000,
      '����������',
      'realization',
      NULL,
      0
    );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760100,
        760000,
        '�����-����',
        'ref_price',
        'TfrmPrice',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760150,
        760000,
        '�����-�������',
        'bill_uni',
        'TfrmBills',
        NULL,
        0
      );


    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760200,
        760000,
        '��������� �� ������ ���',
        'billgood',
        'TfrmRealizationBill',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760300,
        760000,
        '������������ ����������',
        'makedemand',
        'TfrmMakeDemand',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760400,
        760000,
        '��������',
        'contractsell',
        'TfrmContractSell',
        NULL,
        0
      );

    INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
      VALUES (
        760500,
        760000,
        '��������� �� �������',
        'returnsell',
        'TfrmReturnBill',
        NULL,
        0
      );
  */

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      770000,
      710000,
      '������',
      'report',
      'Tgdc_frmReportList',
      NULL,
      15
    );

  /*
  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780000,
      710000,
      '������� � ������������ �����',
      'Cattle',
      '',
      NULL,
      0
    );


  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780010,
      780000,
      '����������� ����� ����������� �����',
      'CattleRef',
      'Tctl_frmReferences',
      NULL,
      0
    );

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780020,
      780000,
      '���������� ����� � ����',
      'CattleRefGood',
      'Tctl_frmCattle',
      NULL,
      0
    );

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780030,
      780000,
      '���������� ����������� ����',
      'CattleRefClient',
      'Tctl_frmClient',
      NULL,
      0
    );

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780040,
      780000,
      '�����-���������',
      'CattleInvoice',
      'Tctl_frmCattlePurchasing',
      NULL,
      0
    );

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780050,
      780000,
      '�������� ���������',
      'CattleReceipt',
      'Tctl_frmCattleReceipt',
      NULL,
      0
    );

  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      780060,
      780000,
      '������������ ������',
      'CattleTraffic',
      'Tctl_frmTransportCoeff',
      NULL,
      0
    );
  */

  /*  �����  */

/*  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      714030,
      714000,
      '�������� �� ���������',
      '714030_17',
      'TfrmProcessingAnalitics',
      NULL,
      0
    );*/

/*  INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
    VALUES (
      714040,
      714000,
      '����� �� ���������',
      '714040_17',
      'Tgdv_frmMapOfAnalitic',
      NULL,
      0
    );*/


INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741101,'gdcField',0,740400,NULL,'������',250,NULL,'TgdcField',NULL,1,1,1,0,NULL);
INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741102,'gdcTable',0,740400,NULL,'�������',251,NULL,'TgdcTable',NULL,1,1,1,0,NULL);

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741103,'gdcView',0,740400,NULL,'�������������',252,NULL,'TgdcView',NULL,1,1,1,0,NULL);

INSERT INTO GD_COMMAND
  (ID,CMD,CMDTYPE,PARENT,HOTKEY,NAME,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED)
VALUES
  (741104,'gdcStoredProc',0,740400,NULL,'���������',253,NULL,'TgdcStoredProc',NULL,1,1,1,0,NULL);
INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741105,740400,'����������','gdcExceptions',0,NULL,254,NULL,'TgdcException',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741106,740400,'���������','gdcSetting',0,NULL,80,NULL,'TgdcSetting',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741107,740400,'����������','gdcGenerator',0,NULL,236,NULL,'TgdcGenerator',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741120,740400,'������� �����','gdcFKManager',0,NULL,228,NULL,'TgdcFKManager',NULL,1,1,1,0,NULL);

INSERT INTO gd_command
  (ID,PARENT,NAME,CMD,CMDTYPE,HOTKEY,IMGINDEX,ORDR,CLASSNAME,SUBTYPE,AVIEW,ACHAG,AFULL,DISABLED,RESERVED)
VALUES
  (741108,740400,'������������ ����','gdcNamespace',0,NULL,80,NULL,'TgdcNamespace',NULL,1,1,1,0,NULL);

INSERT INTO gd_command (id, parent, name, cmd, classname, hotkey, imgindex)
  VALUES (
    741109,
    740400,
    '������������� ��',
    '',
    'Tat_frmSyncNamespace',
    NULL,
    0
  );

/* 799000 - 800000 Department */

COMMIT;

/* msg_box  */
/* 450001 .. 500000 */
INSERT INTO msg_box (id, parent, name) VALUES (450010, NULL, 'inbox');
INSERT INTO msg_box (id, parent, name) VALUES (450020, NULL, 'outbox');
INSERT INTO msg_box (id, parent, name) VALUES (450025, NULL, 'sent');
INSERT INTO msg_box (id, parent, name) VALUES (450030, NULL, 'draft');
INSERT INTO msg_box (id, parent, name) VALUES (450040, NULL, 'trash');


/*
 ��������� ��� ������ ����� ������ 2000000 - 3000000
*/


/* ���������� ��������  */

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000100, '���������� �������', '2000100');

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000101, '���������', '2000101');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000500, NULL, '�����������', '2000500');
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000510, 2000500, '�������', '2000510');
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000520, 2000500, '������', '2000520');


/* ����                */
INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000300, '���������� ���������', '2000300');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000310, 2000300, '��������� �� ������� ������', '2000310');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000311, 2000300, '������� �� ������� ������', '2000311');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000312, 2000300, '��������� �� ������� ������', '2000312');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000313, 2000300, '������ ������������� ������', '2000313');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000314, 2000300, '������� �� ������� ������', '2000314');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000315, 2000300, '�������� �� ����������� �����', '2000315');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000201, 2000300, '��������� ���������', '2000201');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000202, 2000300, '��������� ����������', '2000202');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000203, 2000300, '��������� ���������� - ���������', '2000203');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000204, 2000300, '��������� ������������', '2000204');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000206, 2000300, '������ �����', '2000206');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000207, 2000300, '������� ��������� ���������', '2000207');

  /*
INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000301, '��������� ��������� (����)', '2000301');
  */

/* ����������� */

INSERT INTO rp_reportgroup (id, name, usergroupname)
  VALUES (2000600, '����������� ', '2000600');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000601, 2000600, '���� ������', '2000601');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000602, 2000600, '�������', '2000602');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000603, 2000600, '������ ������������� ��������', '2000603');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000604, 2000600, '������� ��������', '2000604');

/* ���� */

/*
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000700, NULL, '����', '2000700');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000710, 2000700, '����� ���������', '2000710');

INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000720, 2000700, '�������� ���������', '2000720');
*/

/* ����������� */


/*
INSERT INTO rp_reportgroup (id, parent, name, usergroupname)
  VALUES (2000400, NULL, '������������', '2000400');
*/


/*DEPARTAMENT 1009900..1010000*/

/*1009501..1010000 ��������������� ��� Department */

/*****************************************************************************/
/*    �������� � �������� ������������ �� ���������                          */
/*****************************************************************************/

/*

INSERT INTO GD_LISTTRTYPE (ID, NAME, DESCRIPTION)
   VALUES(1000, '�������', '�������� ��� ����� ��������');

*/

COMMIT;

/***********************************************************/
/*     ������ ���������� ��������                          */
/***********************************************************/

INSERT INTO EVT_MACROSGROUP (ID, LB, RB, NAME, ISGLOBAL)
  VALUES (1020001, 1, 2, '���������� �������', 1);

/*���� name ������ ����� �������*/
INSERT INTO EVT_OBJECT (ID, NAME, LB, RB, AFULL, ACHAG, AVIEW, OBJECTTYPE, MACROSGROUPKEY, OBJECTNAME)
  VALUES (1010001, 'APPLICATION', 1, 2, -1, -1, -1, 0, 1020001, 'APPLICATION');

COMMIT;
