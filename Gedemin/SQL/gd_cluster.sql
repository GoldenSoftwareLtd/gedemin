
/*

  Copyright (c) 2007-2012 by Golden Software of Belarus

  Script

  Abstract

  Author

  Revisions history

  Status

*/

CREATE TABLE gd_cluster_server (
  id         dintkey,
  name       dtext255 NOT NULL,
  disabled   ddisabled NOT NULL,
  usergroups INTEGER DEFAULT 0 NOT NULL
);

ALTER TABLE gd_cluster_server ADD CONSTRAINT
  gd_pk_cluster_server PRIMARY KEY (id);

COMMIT;

SET TERM ^ ;

CREATE TRIGGER gd_bi_cluster_server FOR gd_cluster_server
  BEFORE INSERT
  POSITION 0
AS
BEGIN
  IF (NEW.id IS NULL) THEN
    NEW.id = GEN_ID(gd_g_unique, 1);
END

SET TERM ; ^

COMMIT;
