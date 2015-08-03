  CREATE TABLE gd_smtp
  (
    id               dintkey,                     /* первичный ключ          */
    name             dname,                       /* имя                     */
    description      dtext180,                    /* описание                */
    email            demail NOT NULL,             /* адрес электронной почты */
    login            dname,                       /* логин                   */
    passw            VARCHAR(256) NOT NULL,       /* пароль                  */
    ipsec            dtext8,                      /* протокол безопасности   SSLV2, SSLV23, SSLV3, TLSV1 */
    timeout          dinteger_notnull DEFAULT -1,
    server           dtext80 NOT NULL,            /* SMTP Sever */
    port             dinteger_notnull DEFAULT 25, /* SMTP Port */
    principal        dboolean_notnull,

    creatorkey       dforeignkey,
    creationdate     dcreationdate,
    editorkey        dforeignkey,
    editiondate      deditiondate,
    afull            dsecurity,
    achag            dsecurity,
    aview            dsecurity,
    disabled         ddisabled,

    CONSTRAINT gd_pk_smtp PRIMARY KEY (id),
    CONSTRAINT gd_fk_smtp_ck
      FOREIGN KEY (creatorkey) REFERENCES gd_contact (id)
      ON UPDATE CASCADE,
    CONSTRAINT gd_fk_smtp_ek
      FOREIGN KEY (editorkey) REFERENCES gd_contact (id)
      ON UPDATE CASCADE,
    CONSTRAINT gd_smtp_chk_timeout CHECK (timeout >= -1),
    CONSTRAINT gd_smtp_chk_ipsec CHECK(ipsec IN ('SSLV2', 'SSLV23', 'SSLV3', 'TLSV1')),
    CONSTRAINT gd_smtp_chk_server CHECK (server > ''),
    CONSTRAINT gd_smtp_chk_port CHECK (port > 0 AND port < 65536)
  );

SET TERM ^ ;

CREATE OR ALTER TRIGGER gd_bi_smtp FOR gd_smtp
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1) + GEN_ID(gd_g_offset, 0);
END
^

CREATE OR ALTER TRIGGER gd_aiu_smtp FOR gd_smtp
  AFTER INSERT OR UPDATE
  POSITION 32000
AS
BEGIN
  IF (NEW.principal = 1) THEN
    UPDATE gd_smtp SET principal = 0 
	WHERE principal = 1 AND id <> NEW.id;
END
^

SET TERM ; ^
 
COMMIT;