
/*

  Copyright (c) 2000-2012 by Golden Software of Belarus

  Script

    gd_productivity.sql

  Abstract

    ƒобавление индексов на системные таблицы дл€ увеличени€
    производительности.

  Author

    ¬з€то из инета.

  Revisions history

    15-02-02    andreik    Initial version.

*/

CREATE INDEX RDB$D_DNON ON RDB$DEPENDENCIES (RDB$DEPENDENT_NAME, RDB$DEPENDED_ON_NAME);
CREATE INDEX RDB$LF_FS ON RDB$LOG_FILES (RDB$FILE_SEQUENCE);
CREATE INDEX RDB$T_FN ON RDB$TYPES (RDB$FIELD_NAME);
CREATE INDEX RDB$UP_G ON RDB$USER_PRIVILEGES (RDB$GRANTOR);
CREATE INDEX RDB$UP_UG ON RDB$USER_PRIVILEGES (RDB$USER, RDB$GRANTOR);
CREATE INDEX RDB$VR_VN ON RDB$VIEW_RELATIONS (RDB$VIEW_NAME);
CREATE INDEX RDB$RC_RN ON RDB$RELATION_CONSTRAINTS (RDB$RELATION_NAME);

COMMIT;

