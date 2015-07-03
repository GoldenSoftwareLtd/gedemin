CREATE TABLE gd_smtp
(
  id               dintkey,                     /* первичный ключ          */
  name             dname,                       /* имя                     */
  description      dtext180,                    /* описание                */
  email            demail NOT NULL,             /* адрес электронной почты */
  login            dusername,                   /* логин                   */
  passw            VARCHAR(256) NOT NULL,       /* пароль                  */
  ipsec            dtext8 DEFAULT NULL,         /* протокол безопасности   SSLV2, SSLV23, SSLV3, TLSV1 */
  timeout          dinteger_notnull DEFAULT -1,
  server           dtext80 NOT NULL,            /* SMTP Sever */
  port             dinteger_notnull DEFAULT 25, /* SMTP Port */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  editorkey        dforeignkey,
  editiondate      deditiondate,
  afull            dsecurity,
  achag            dsecurity,
  aview            dsecurity,
  disabled         ddisabled,

  CONSTRAINT gd_pk_smtp PRIMARY KEY (id),
  CONSTRAINT gd_chk_smtp_timeout CHECK (timeout >= -1),
  CONSTRAINT gd_chk_smtp_ipsec CHECK(ipsec IN ('SSLV2', 'SSLV23', 'SSLV3', 'TLSV1')),
  CONSTRAINT gd_chk_smtp_server CHECK (server > ''),
  CONSTRAINT gd_chk_smtp_port CHECK (port > 0 AND port < 65536)
);
 
COMMIT;