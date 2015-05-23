
CREATE TABLE gd_link
(
  id            dintkey,
  objectkey     dintkey,
  linkedkey     dintkey,
  linkedclass   dclassname NOT NULL,
  linkedsubtype dclassname,
  linkedname    dname,
  linkedusertype dtext20,
  linkedorder   INTEGER,

  CONSTRAINT gd_pk_link_id PRIMARY KEY (id)
);

COMMIT;
