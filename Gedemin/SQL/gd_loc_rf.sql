
/*

  Attention! Cross field doesnt belongs to Cross table!

*/

ALTER TABLE at_relation_fields ADD CONSTRAINT at_fk_relation_fields_cf
  FOREIGN KEY (crossfield) REFERENCES at_relation_fields (fieldname);

COMMIT;

