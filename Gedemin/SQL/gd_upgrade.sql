

/**********************************************************

  gd_v_user_generators

  Returns list of names of non-system generators.

***********************************************************/

CREATE VIEW gd_v_user_generators (generator_name)
  AS SELECT rdb$generator_name     
     FROM rdb$generators
     WHERE (rdb$system_flag = 0) OR (rdb$system_flag IS NULL);


/**********************************************************

  gd_v_user_triggers

  Returns list of names of active non-system user defined 
  triggers.

***********************************************************/

CREATE VIEW gd_v_user_triggers (trigger_name)
  AS SELECT rdb$trigger_name 
     FROM rdb$triggers 
     WHERE (rdb$trigger_name NOT IN (SELECT rdb$trigger_name FROM rdb$check_constraints)) 
       AND ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL)) 
       AND ((rdb$trigger_inactive = 0) OR (rdb$trigger_inactive IS NULL));

/**********************************************************

  gd_v_foreign_keys

  Returns list of foreign keys names together with
  corresponding index name and relation name.

***********************************************************/


CREATE VIEW gd_v_foreign_keys (constraint_name, index_name, relation_name)
  AS SELECT rdb$constraint_name, rdb$index_name, rdb$relation_name 
     FROM rdb$relation_constraints 
     WHERE rdb$constraint_type = 'FOREIGN KEY';


/**********************************************************

  gd_v_primary_keys

  Returns list of primary keys names together with
  corresponding index name and relation name.

***********************************************************/


CREATE VIEW gd_v_primary_keys (constraint_name, index_name, relation_name)
  AS SELECT rdb$constraint_name, rdb$index_name, rdb$relation_name 
     FROM rdb$relation_constraints 
     WHERE rdb$constraint_type = 'PRIMARY KEY';


/**********************************************************

  gd_v_user_indices

  Returns list of names of active non-system user defined 
  indices.

***********************************************************/

CREATE VIEW gd_v_user_indices (index_name)
  AS SELECT rdb$index_name 
     FROM rdb$indices
     WHERE ((rdb$system_flag = 0) OR (rdb$system_flag IS NULL))       
       AND (rdb$index_inactive = 0);



/**********************************************************

  gd_v_tables_wblob

  Returns list of names of all non-system tables
  which have at least one BLOB field.

***********************************************************/

create view gd_v_tables_wblob as
select distinct rf.rdb$relation_name
from
  rdb$relation_fields rf join rdb$fields f
    on rf.rdb$field_source = f.rdb$field_name
where
  f.rdb$field_type = 261
  and (not rf.rdb$relation_name LIKE 'RDB$%');

COMMIT;
