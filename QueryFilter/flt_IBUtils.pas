unit flt_IBUtils;

interface

uses
  Controls;

const
  {$IFNDEF GEDEMIN}
  cPrimaryFieldSQL =    '/* Вытягиваем PRIMARY KEY */ '#13#10 +
                        'SELECT '#13#10 +
                        '  isg1.RDB$FIELD_NAME PrimaryName '#13#10 +
                        'FROM '#13#10 +
                        '  RDB$INDEX_SEGMENTS isg1 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc1 '#13#10 +
                        'WHERE '#13#10 +
                        '  rc1.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME '#13#10 +
                        '  AND rc1.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''';

  cForeignFieldSQL =    '/* Вытягиваем связи много к одному (FOREIGN KEY) */ '#13#10 +
                        'SELECT '#13#10 +
                        '  isg1.RDB$FIELD_NAME   SourceField '#13#10 +
                        '  , isg2.RDB$FIELD_NAME     TargetField '#13#10 +
                        '  , rc2.RDB$RELATION_NAME  TargetTable '#13#10 +
                        '  , (SELECT 1 FROM rdb$database WHERE '#13#10 +
                        '     rc1.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME) iscircle '#13#10 +
                        '  , (SELECT 1 '#13#10 +
                        '    FROM RDB$DATABASE '#13#10 +
                        '    WHERE '#13#10 +
                        '      EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc2.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''LB'') '#13#10 +
                        '      AND EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc2.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''RB'')) IsTree /**/ '#13#10 +
                        'FROM '#13#10 +
                        '  RDB$INDEX_SEGMENTS isg1 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc1 '#13#10 +
                        '  , RDB$REF_CONSTRAINTS rfc '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc2 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg2 /*  */ '#13#10 +
                        'WHERE '#13#10 +
                        '  rc1.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME '#13#10 +
                        '  AND rc1.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' '#13#10 +
                        '  AND rfc.RDB$CONSTRAINT_NAME = rc1.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rfc.RDB$CONST_NAME_UQ = rc2.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME';

  cSimpleFieldSQL =     '/* Вытягивает все простые поля */ '#13#10 +
                        'SELECT '#13#10 +
                        '  relf.RDB$FIELD_NAME FieldName '#13#10 +
                        '  , relf.RDB$DESCRIPTION RusName '#13#10 +
                        '  , f.RDB$FIELD_TYPE  FieldType '#13#10 +
                        '  , f.RDB$FIELD_NAME  DomainName '#13#10 +
                        '  , f.RDB$FIELD_SUB_TYPE  FieldSubType '#13#10 +
                        '  , f.RDB$FIELD_LENGTH FieldLength'#13#10 +
                        'FROM '#13#10 +
                        '  RDB$RELATION_FIELDS relf '#13#10 +
                        '  , RDB$FIELDS f '#13#10 +
                        'WHERE '#13#10 +
                        '  relf.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND f.RDB$FIELD_NAME = relf.RDB$FIELD_SOURCE '#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''AFULL'''#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''ACHAG'''#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''AVIEW'''#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''LB'''#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''RB'''#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME IN (''ID'')';
  {$ENDIF}                      


  cProcedureFieldSQL =  ' SELECT '#13#10 +
                        '    relf.RDB$PARAMETER_NAME FieldName '#13#10 +
                        '    , relf.RDB$DESCRIPTION RusName '#13#10 +
                        '    , f.RDB$FIELD_TYPE  FieldType '#13#10 +
                        '    , f.RDB$FIELD_NAME  DomainName '#13#10 +
                        '    , f.RDB$FIELD_SUB_TYPE  FieldSubType '#13#10 +
                        '    , f.RDB$FIELD_LENGTH FieldLength '#13#10 +
                        '  FROM '#13#10 +
                        '    rdb$procedure_parameters relf '#13#10 +
                        '    , RDB$FIELDS f '#13#10 +
                        '  WHERE '#13#10 +
                        '    relf.RDB$PROCEDURE_NAME = :tablename '#13#10 +
                        '    AND f.RDB$FIELD_NAME = relf.RDB$FIELD_SOURCE '#13#10 +
                        '    AND relf.RDB$PARAMETER_TYPE <> 0 ';

  {$IFNDEF GEDEMIN}
  cSetFieldSQL =        '/* Вытягивает при отношении многий '#13#10 +
                        ' ко многим название связующей таблицы, связующего поля, '#13#10 +
                        ' а также другие поля в этой таблице являющиеся примари '#13#10 +
                        ' кей и ссылающиеся на вторую таблицу. Наименование второй '#13#10 +
                        ' таблицы и поля в ней также указывается. */ '#13#10 +
                        'SELECT '#13#10 +
                        '  isg2.RDB$FIELD_NAME       FirstField '#13#10 +
                        '  , rc2.RDB$RELATION_NAME   NetTable '#13#10 +
                        '  , isg4.RDB$FIELD_NAME     SecondField '#13#10 +
                        '  , rc5.RDB$RELATION_NAME   TargetTable '#13#10 +
                        '  , isg6.RDB$FIELD_NAME     TargetField /*  */ '#13#10 +
                        '  , (SELECT 1 '#13#10 +
                        '    FROM RDB$DATABASE '#13#10 +
                        '    WHERE '#13#10 +
                        '      EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc5.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''LB'') '#13#10 +
                        '      AND EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc5.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''RB'')) IsTree '#13#10 +
                        'FROM '#13#10 +
                        '  RDB$INDEX_SEGMENTS isg1 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc1 '#13#10 +
                        '  , RDB$REF_CONSTRAINTS rfc1 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc2 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg2 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg3 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc3 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg4 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg5 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc4 '#13#10 +
                        '  , RDB$REF_CONSTRAINTS rfc2 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc5 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg6 /*  */ '#13#10 +
                        'WHERE '#13#10 +
                        '  rc1.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME '#13#10 +
                        '/*  AND isg1.RDB$FIELD_NAME = ''ID''/**/ '#13#10 +
                        '  AND rc1.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
                        '  AND rfc1.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rfc1.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME '#13#10 +
                        '  AND rc1.RDB$RELATION_NAME <> rc2.RDB$RELATION_NAME '#13#10 +
                        '  AND isg3.RDB$FIELD_NAME = isg2.RDB$FIELD_NAME '#13#10 +
                        '  AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME '#13#10 +
                        '  AND rc3.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
                        '  AND rc3.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME '#13#10 +
                        '  AND isg4.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME '#13#10 +
                        '  AND isg2.RDB$FIELD_NAME <> isg4.RDB$FIELD_NAME '#13#10 +
                        '  AND isg5.RDB$FIELD_NAME = isg4.RDB$FIELD_NAME '#13#10 +
                        '  AND rc4.RDB$INDEX_NAME = isg5.RDB$INDEX_NAME '#13#10 +
                        '  AND rc4.RDB$CONSTRAINT_TYPE = ''FOREIGN KEY'' '#13#10 +
                        '  AND rc4.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME '#13#10 +
                        '  AND rfc2.RDB$CONSTRAINT_NAME = rc4.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rfc2.RDB$CONST_NAME_UQ = rc5.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rc5.RDB$INDEX_NAME = isg6.RDB$INDEX_NAME /*  */ ';



  cChildSetSQL =        '/* Вытягиваем связи один ко многим, т.е. те '#13#10 +
                        'таблицы которые имеют ссылку на нашу */ '#13#10 +
                        'SELECT '#13#10 +
                        '  isg1.RDB$FIELD_NAME   SourceField '#13#10 +
                        '  , isg2.RDB$FIELD_NAME     TargetField '#13#10 +
                        '  , rc2.RDB$RELATION_NAME  TargetTable '#13#10 +
                        '  , isg3.RDB$FIELD_NAME   TargetPrimary /*  */ '#13#10 +
                        '  , (SELECT 1 FROM rdb$database WHERE '#13#10 +
                        '     rc1.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME) iscircle/*  */ '#13#10 +
                        '  , (SELECT 1 '#13#10 +
                        '    FROM RDB$DATABASE '#13#10 +
                        '    WHERE '#13#10 +
                        '      EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc2.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''LB'') '#13#10 +
                        '      AND EXISTS(SELECT * '#13#10 +
                        '             FROM RDB$RELATION_FIELDS rf '#13#10 +
                        '             WHERE rc2.RDB$RELATION_NAME = rf.RDB$RELATION_NAME '#13#10 +
                        '              AND rf.RDB$FIELD_NAME = ''RB'')) IsTree /**/ '#13#10 +
                        'FROM '#13#10 +
                        '  RDB$INDEX_SEGMENTS isg1 '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc1 '#13#10 +
                        '  , RDB$REF_CONSTRAINTS rfc '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc2 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg2 /*  */ '#13#10 +
                        '  , RDB$RELATION_CONSTRAINTS rc3 '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg3 /*  */ '#13#10 +
                        'WHERE '#13#10 +
                        '  rc1.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME '#13#10 +
                        '  AND rfc.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rfc.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME '#13#10 +
                        '  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME '#13#10 +
                        '  AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME '#13#10 +
                        '  AND rc3.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY'' '#13#10 +
                        '  AND isg3.RDB$INDEX_NAME = rc3.RDB$INDEX_NAME '#13#10 +
                        '  AND NOT rc2.RDB$RELATION_NAME IN (''GD_CONTACTLIST'') /*  */ ';
  {$ENDIF}


  cSortFieldSQL =       '/* Вытягивает все поля для сортировки */ '#13#10 +
                        'SELECT '#13#10 +
                        '  relf.RDB$FIELD_NAME FieldName '#13#10 +
                        '  , relf.RDB$DESCRIPTION RusName '#13#10 +
                        '  , ind.RDB$INDEX_TYPE AscType '#13#10 +
                        'FROM '#13#10 +
                        '  RDB$RELATION_FIELDS relf '#13#10 +
                        '  , RDB$INDICES ind '#13#10 +
                        '  , RDB$INDEX_SEGMENTS isg '#13#10 +
                        'WHERE '#13#10 +
                        '  relf.RDB$RELATION_NAME = :tablename '#13#10 +
                        '  AND ind.RDB$RELATION_NAME = relf.RDB$RELATION_NAME '#13#10 +
                        '  AND ind.RDB$INDEX_NAME = isg.RDB$INDEX_NAME '#13#10 +
                        '  AND isg.RDB$FIELD_NAME = relf.RDB$FIELD_NAME '#13#10 +
                        '  AND ind.RDB$SEGMENT_COUNT = 1 '#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''AFULL'' '#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''ACHAG'' '#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''AVIEW'' '#13#10 +
                        '/*  AND NOT relf.RDB$FIELD_NAME = ''LB'' '#13#10 +
                        '  AND NOT relf.RDB$FIELD_NAME = ''RB''*/ ';



  cFunctionSQL =        'SELECT '#13#10 +
                        '  rf.rdb$function_name fname '#13#10 +
                        '  , rf.rdb$description rusname '#13#10 +
                        '  , (SELECT COUNT(*) '#13#10 +
                        '     FROM rdb$function_arguments '#13#10 +
                        '     WHERE rdb$function_name = rf.rdb$function_name '#13#10 +
                        '       AND rdb$mechanism = 1) argcount '#13#10 +
                        'FROM '#13#10 +
                        '  rdb$functions rf';


function IBDateToStr(const AnDate: TDate): String;
function IBDateTimeToStr(const AnDateTime: TDateTime): String;
function IBTimeToStr(const AnTime: TTime): String;

implementation

uses
  SysUtils;

function IBDateToStr(const AnDate: TDate): String;
begin
  DateTimeToString(Result, 'dd.mm.yyyy', AnDate);
end;

function IBDateTimeToStr(const AnDateTime: TDateTime): String;
begin
  if Trunc(AnDateTime) <> AnDateTime then
    DateTimeToString(Result, 'dd.mm.yyyy hh:mm:ss', AnDateTime)
  else
    DateTimeToString(Result, 'dd.mm.yyyy', AnDateTime);
end;

function IBTimeToStr(const AnTime: TTime): String;
begin
  DateTimeToString(Result, 'hh:mm:ss', AnTime);
end;

end.
 