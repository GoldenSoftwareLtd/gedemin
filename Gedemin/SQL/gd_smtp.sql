CREATE TABLE gd_smtp
(
  id               dintkey,                     /* ��������� ����          */
  name             dname,                       /* ���                     */
  description      dtext180,                    /* ��������                */
  email            demail NOT NULL,             /* ����� ����������� ����� */
  login            dusername,                   /* �����                   */
  passw            dtext254 NOT NULL,           /* ������                  */
  ipsec            dtext8 DEFAULT NULL,         /* �������� ������������   SSLV2, SSLV23, SSLV3, TLSV1 */
  timeout          dinteger_notnull DEFAULT -1,
  server           dtext80 NOT NULL,            /* SMTP Sever */
  port             dinteger_notnull,            /* SMTP Port */

  creatorkey       dforeignkey,
  creationdate     dcreationdate,
  editorkey        dforeignkey,
  editiondate      deditiondate,
  afull            dsecurity,
  achag            dsecurity,
  aview            dsecurity,
  disabled         ddisabled,

  CONSTRAINT gd_pk_smtp PRIMARY KEY (id),
  CONSTRAINT gd_chk_smtp_timeout CHECK (timeout >= -2),
  CONSTRAINT gd_chk_smtp_ipsec CHECK(ipsec IN ('SSLV2', 'SSLV23', 'SSLV3', 'TLSV1')),
  CONSTRAINT gd_chk_smtp_server CHECK (server > ''),
  CONSTRAINT gd_chk_smtp_port CHECK (port > 0)
);
 
COMMIT;