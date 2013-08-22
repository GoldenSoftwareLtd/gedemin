
/*
 *  Данная таблица содержит список ссылок на компании
 *  по которым ведется учет в программе.
 */
CREATE TABLE gd_ourcompany
(
  companykey   dintkey,
  afull        dsecurity,
  achag        dsecurity,
  aview        dsecurity,

  disabled     dboolean  DEFAULT 0
);

COMMIT;

ALTER TABLE gd_ourcompany ADD CONSTRAINT gd_companykey_ourcompany
  PRIMARY KEY (companykey);

ALTER TABLE gd_ourcompany ADD CONSTRAINT gd_fk_oc_companykey
  FOREIGN KEY (companykey) REFERENCES gd_contact(id) ON UPDATE CASCADE;

COMMIT;

/*  Список компаний, по которым ведется учет */

CREATE VIEW GD_V_OURCOMPANY
(
  ID,
  COMPNAME,
  COMPFULLNAME,
  COMPANYTYPE,
  COMPLB,
  COMPRB,
  AFULL,
  ACHAG,
  AVIEW,
  ADDRESS,
  CITY,
  COUNTRY,
  PHONE,
  FAX,
  ACCOUNT,
  BANKCODE,
  BANKMFO,
  BANKNAME,
  BANKADDRESS,
  BANKCITY,
  BANKCOUNTRY,
  TAXID,
  OKULP,
  OKPO,
  LICENCE,
  OKNH,
  SOATO,
  SOOU
)
AS
SELECT
  C.ID, C.NAME, COMP.FULLNAME, COMP.COMPANYTYPE,
  C.LB, C.RB, O.AFULL, O.ACHAG, O.AVIEW,
  C.ADDRESS, C.CITY, C.COUNTRY, C.PHONE, C.FAX,
  AC.ACCOUNT, BANK.BANKCODE, BANK.BANKMFO,
  BANKC.NAME, BANKC.ADDRESS, BANKC.CITY, BANKC.COUNTRY,
  CC.TAXID, CC.OKULP, CC.OKPO, CC.LICENCE, CC.OKNH, CC.SOATO, CC.SOOU

FROM
  GD_OURCOMPANY O
    JOIN GD_CONTACT C ON (O.COMPANYKEY = C.ID)
    JOIN GD_COMPANY COMP ON (COMP.CONTACTKEY = O.COMPANYKEY)
    LEFT JOIN GD_COMPANYACCOUNT AC ON COMP.COMPANYACCOUNTKEY = AC.ID
    LEFT JOIN GD_BANK BANK ON AC.BANKKEY = BANK.BANKKEY
    LEFT JOIN GD_COMPANYCODE CC ON COMP.CONTACTKEY = CC.COMPANYKEY
    LEFT JOIN GD_CONTACT BANKC ON BANK.BANKKEY = BANKC.ID;

COMMIT;


/*
 *  У каждого пользователя системы есть своя фирма
 *  "по-умолчанию".
 */
CREATE TABLE gd_usercompany
(
  userkey	dintkey,
  companykey	dforeignkey
);

ALTER TABLE gd_usercompany
  ADD CONSTRAINT gd_pk_usercompany PRIMARY KEY (userkey);

ALTER TABLE gd_usercompany ADD CONSTRAINT gd_fk_uc_userkey
  FOREIGN KEY (userkey) REFERENCES gd_user(id)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

ALTER TABLE gd_usercompany ADD CONSTRAINT gd_fk_uc_companykey
  FOREIGN KEY (companykey) REFERENCES gd_ourcompany(companykey)
  ON DELETE CASCADE
  ON UPDATE CASCADE;

COMMIT;


