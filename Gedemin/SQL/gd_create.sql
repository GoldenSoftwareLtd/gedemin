
COMMIT;

CREATE ROLE administrator;

COMMIT;

CREATE GENERATOR gd_g_unique;
SET GENERATOR gd_g_unique TO 147000000;

CREATE GENERATOR gd_g_offset;
SET GENERATOR gd_g_offset TO 0;

CREATE GENERATOR gd_g_dbid;
SET GENERATOR gd_g_dbid TO 0;

/* в новой системе блокировки периода следующие два */
/* генератора не используютс€                       */
CREATE GENERATOR gd_g_block;
SET GENERATOR gd_g_block TO 0;

CREATE GENERATOR gd_g_block_group;
SET GENERATOR gd_g_block_group TO 0;

/*

  ¬нимание! “екст этого исключени€ нельз€ мен€ть,
  он используетс€ в программе в gdc_dlgG

*/
CREATE EXCEPTION gd_e_block 'Period zablokirovan!';

CREATE EXCEPTION tree_e_invalid_parent 'Invalid parent specified';

COMMIT;
