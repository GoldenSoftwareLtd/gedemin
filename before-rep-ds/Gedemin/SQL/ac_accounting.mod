ALTER TABLE ac_trentry ADD functionkey dforeignkey;
ALTER TABLE ac_trentry ADD functionstor dblob80 DEFAULT null;

COMMIT;

ALTER TABLE ac_trentry ADD CONSTRAINT ac_fk_trentry_function
  FOREIGN KEY (functionkey) REFERENCES gd_function(id)
  ON UPDATE CASCADE;

COMMIT;



ALTER TABLE ac_trrecord ADD functionkey dforeignkey
COMMIT;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_function
  FOREIGN KEY (functionkeykey) REFERENCES gd_function(id) 
  ON UPDATE CASCADE;



ALTER TABLE ac_trrecord ADD documenttypekey dintkey;

COMMIT;

ALTER TABLE ac_trrecord ADD CONSTRAINT ac_fk_trrecord_documenttype
  FOREIGN KEY (documenttypekey) REFERENCES gd_documenttype(id)
  ON UPDATE CASCADE;

COMMIT;

CREATE VIEW AC_V_TRENTRYRECORD(
    DEBITALIAS,
    CREDITALIAS,
    DESCRIPTION,
    TRANSACTIONKEY,
    ID,
    TRRECORDKEY,
    ACCOUNTKEY,
    ACCOUNTPART,
    AFULL,
    ACHAG,
    AVIEW,
    DISABLED,
    ISSAVENULL,
    FUNCTIONKEY,
    ENTRYFUNCTIONKEY,
    ENTRYFUNCTIONSTOR,
    DOCUMENTTYPEKEY)
AS
SELECT
  a.alias as debitalias, CAST('' AS VARCHAR(20)) as creditalias,
  a.name as accountname,
  r.transactionkey,
  e.id, e.trrecordkey, e.accountkey, e.accountpart,
  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey,
  e.functionkey, e.functionstor, r.documenttypekey
FROM
  ac_trrecord r
    JOIN ac_trentry e ON (r.id = e.trrecordkey)
    JOIN ac_account a ON (a.id = e.accountkey)

WHERE
  e.accountpart = 'D'

UNION

SELECT
  CAST('' AS VARCHAR(20)) as debitalias, a.alias as creditalias,
  a.name as accountname,
  r.transactionkey,
  e.id, e.trrecordkey, e.accountkey, e.accountpart,
  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey,
  e.functionkey, e.functionstor, r.documenttypekey
FROM
  ac_trrecord r
    JOIN ac_trentry e ON (r.id = e.trrecordkey)
    JOIN ac_account a ON (a.id = e.accountkey)

WHERE
  e.accountpart = 'C'

UNION

SELECT
  CAST(' ' AS VARCHAR(20)), CAST(' ' AS VARCHAR(20)),
  r.description,
  r.transactionkey,
  CAST(0 AS INTEGER),
  r.id, CAST(0 AS INTEGER), CAST('Z' AS VARCHAR(1)),
  r.afull, r.achag, r.aview, r.disabled, r.issavenull, r.functionkey,
  CAST(0 AS INTEGER), e.functionstor, r.documenttypekey

FROM
  ac_trrecord r
    LEFT JOIN ac_trentry e ON (e.id = -1);