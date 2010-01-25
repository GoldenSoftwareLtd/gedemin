unit flt_TextSQL_forFilter;

interface

implementation

// ������ 1. ���������� PRIMARY KEY

{
/* ���������� PRIMARY KEY */
SELECT
  isg1.RDB$FIELD_NAME PrimaryName
FROM
  RDB$INDEX_SEGMENTS isg1
  , RDB$RELATION_CONSTRAINTS rc1
WHERE
  rc1.RDB$RELATION_NAME = :tablename
  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME
  AND rc1.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
}



// ������ 2. ���������� ��� ���� ������� ������� ��������� �� ������ �������

{
/* ���������� ����� ����� � ������ (FOREIGN KEY) */
SELECT
  isg1.RDB$FIELD_NAME   SourceField
  , isg2.RDB$FIELD_NAME     TargetField
  , rc2.RDB$RELATION_NAME  TargetTable
  , (SELECT 1 FROM rdb$database WHERE
     rc1.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME) iscircle
FROM
  RDB$INDEX_SEGMENTS isg1
  , RDB$RELATION_CONSTRAINTS rc1
  , RDB$REF_CONSTRAINTS rfc
  , RDB$RELATION_CONSTRAINTS rc2
  , RDB$INDEX_SEGMENTS isg2 /*  */
WHERE
  rc1.RDB$RELATION_NAME = :tablename
  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME
  AND rc1.RDB$CONSTRAINT_TYPE = 'FOREIGN KEY'
  AND rfc.RDB$CONSTRAINT_NAME = rc1.RDB$CONSTRAINT_NAME
  AND rfc.RDB$CONST_NAME_UQ = rc2.RDB$CONSTRAINT_NAME
  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME
}



// ������ 3. ���������� ��� ������� ����.

{
/* ���������� ��� ������� ���� */
SELECT
  relf.RDB$FIELD_NAME FieldName
  , relf.RDB$DESCRIPTION RusName
  , f.RDB$FIELD_TYPE  FieldType
  , f.RDB$FIELD_NAME  DomainName
  , f.RDB$FIELD_SUB_TYPE  FieldSubType
FROM
  RDB$RELATION_FIELDS relf
  , RDB$FIELDS f
WHERE
  relf.RDB$RELATION_NAME = :tablename
  AND f.RDB$FIELD_NAME = relf.RDB$FIELD_SOURCE

  AND NOT relf.RDB$FIELD_NAME = 'AFULL'
  AND NOT relf.RDB$FIELD_NAME = 'ACHAG'
  AND NOT relf.RDB$FIELD_NAME = 'AVIEW'
  AND NOT relf.RDB$FIELD_NAME = 'LB'
  AND NOT relf.RDB$FIELD_NAME = 'RB'

  AND NOT relf.RDB$FIELD_NAME IN ('ID')
}



// ������ 4. ���������� ����������� ���� ���������.

{/* ���������� ��� ��������� ������
 �� ������ �������� ��������� �������, ���������� ����,
 � ����� ������ ���� � ���� ������� ���������� �������
 ��� � ����������� �� ������ �������. ������������ ������
 ������� � ���� � ��� ����� �����������. */
SELECT
  isg2.RDB$FIELD_NAME       FirstField
  , rc2.RDB$RELATION_NAME   NetTable
  , isg4.RDB$FIELD_NAME     SecondField
  , rc5.RDB$RELATION_NAME   TargetTable
  , isg6.RDB$FIELD_NAME     TargetField /*  */
FROM
  RDB$INDEX_SEGMENTS isg1
  , RDB$RELATION_CONSTRAINTS rc1
  , RDB$REF_CONSTRAINTS rfc1
  , RDB$RELATION_CONSTRAINTS rc2
  , RDB$INDEX_SEGMENTS isg2
  , RDB$INDEX_SEGMENTS isg3
  , RDB$RELATION_CONSTRAINTS rc3
  , RDB$INDEX_SEGMENTS isg4
  , RDB$INDEX_SEGMENTS isg5
  , RDB$RELATION_CONSTRAINTS rc4
  , RDB$REF_CONSTRAINTS rfc2
  , RDB$RELATION_CONSTRAINTS rc5
  , RDB$INDEX_SEGMENTS isg6 /*  */
WHERE
  rc1.RDB$RELATION_NAME = :tablename
  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME
/*  AND isg1.RDB$FIELD_NAME = 'ID'/**/
  AND rc1.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND rfc1.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME
  AND rfc1.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME
  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME
  AND rc1.RDB$RELATION_NAME <> rc2.RDB$RELATION_NAME
  AND isg3.RDB$FIELD_NAME = isg2.RDB$FIELD_NAME
  AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND rc3.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND rc3.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME
  AND isg4.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME
  AND isg2.RDB$FIELD_NAME <> isg4.RDB$FIELD_NAME
  AND isg5.RDB$FIELD_NAME = isg4.RDB$FIELD_NAME
  AND rc4.RDB$INDEX_NAME = isg5.RDB$INDEX_NAME
  AND rc4.RDB$CONSTRAINT_TYPE = 'FOREIGN KEY'
  AND rc4.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND rfc2.RDB$CONSTRAINT_NAME = rc4.RDB$CONSTRAINT_NAME
  AND rfc2.RDB$CONST_NAME_UQ = rc5.RDB$CONSTRAINT_NAME
  AND rc5.RDB$INDEX_NAME = isg6.RDB$INDEX_NAME /*  */
}



// ������ 5. ���������� ��������� ���� ��� ���������� �� ��������� ������� ���������

{/* ���������� ��� ��������� ������
 �� ������ �������� ��������� �������, ���������� ����,
 � ����� ������ ���� � �� ������ � ���� ������� ����������   ������� ��� � ���� ������� ��������� ��������� �� ��� ���� ��
 ������ ������� (FKey). */
SELECT
  isg2.RDB$FIELD_NAME       FirstField
  , rc2.RDB$RELATION_NAME   NetTable
  , isg4.RDB$FIELD_NAME     SecondField
  , relf.RDB$DESCRIPTION    RusName
  , f.RDB$FIELD_TYPE        SecondFieldType
  , (SELECT 1
     FROM RDB$INDEX_SEGMENTS isg7
      , RDB$RELATION_CONSTRAINTS rc7
      , RDB$REF_CONSTRAINTS rfc3
      , RDB$RELATION_CONSTRAINTS rc8
     WHERE
      isg7.RDB$FIELD_NAME = isg4.RDB$FIELD_NAME
      AND rc7.RDB$INDEX_NAME = isg7.RDB$INDEX_NAME
      AND rc7.RDB$CONSTRAINT_TYPE = 'FOREIGN KEY'
      AND rc7.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
      AND rfc3.RDB$CONSTRAINT_NAME = rc7.RDB$CONSTRAINT_NAME
      AND rfc3.RDB$CONST_NAME_UQ = rc8.RDB$CONSTRAINT_NAME
    ) FKey /*  */
FROM
  RDB$INDEX_SEGMENTS isg1
  , RDB$RELATION_CONSTRAINTS rc1
  , RDB$REF_CONSTRAINTS rfc1
  , RDB$RELATION_CONSTRAINTS rc2
  , RDB$INDEX_SEGMENTS isg2
  , RDB$INDEX_SEGMENTS isg3
  , RDB$RELATION_CONSTRAINTS rc3
  , RDB$INDEX_SEGMENTS isg4
  , RDB$RELATION_FIELDS relf
  , RDB$FIELDS f /*  */
WHERE
  /* ��� ���� PRIMARY KEY ������� */
  rc1.RDB$RELATION_NAME = :tablename
  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME
/*  AND isg1.RDB$FIELD_NAME = 'ID'*/
  AND rc1.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
  /* ���� ������ �� ������ ������� */
  AND rfc1.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME
  AND rfc1.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME
  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME
  /* ������ ������ �� �� ���� ���� */
  AND rc1.RDB$RELATION_NAME <> rc2.RDB$RELATION_NAME
  /* � �������� ������� ������ ���� �� PRIMARY KEY */
  AND isg3.RDB$FIELD_NAME = isg2.RDB$FIELD_NAME
  AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND rc3.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND rc3.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME

  AND isg4.RDB$INDEX_NAME = isg3.RDB$INDEX_NAME
  AND isg2.RDB$FIELD_NAME <> isg4.RDB$FIELD_NAME

  AND relf.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND relf.RDB$FIELD_NAME = isg4.RDB$FIELD_NAME
  AND f.RDB$FIELD_NAME = relf.RDB$FIELD_SOURCE
  AND relf.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND relf.RDB$FIELD_NAME = isg4.RDB$FIELD_NAME /*  */
}



// ������ 6. ���������� ������� ������� ������ �� ���� �������.

{/* ���������� ����� ���� �� ������, �.�. ��
������� ������� ����� ������ �� ���� */
SELECT
  isg1.RDB$FIELD_NAME   SourceField
  , isg2.RDB$FIELD_NAME     TargetField
  , rc2.RDB$RELATION_NAME  TargetTable
  , isg3.RDB$FIELD_NAME   TargetPrimary /*  */
  , (SELECT 1 FROM rdb$database WHERE
     rc1.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME) iscircle/*  */
FROM
  RDB$INDEX_SEGMENTS isg1
  , RDB$RELATION_CONSTRAINTS rc1
  , RDB$REF_CONSTRAINTS rfc
  , RDB$RELATION_CONSTRAINTS rc2
  , RDB$INDEX_SEGMENTS isg2 /*  */
  , RDB$RELATION_CONSTRAINTS rc3
  , RDB$INDEX_SEGMENTS isg3 /*  */
WHERE
  rc1.RDB$RELATION_NAME = :tablename
  AND rc1.RDB$INDEX_NAME = isg1.RDB$INDEX_NAME
  AND rfc.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME
  AND rfc.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME
  AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME
  AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME
  AND rc3.RDB$CONSTRAINT_TYPE = 'PRIMARY KEY'
  AND isg3.RDB$INDEX_NAME = rc3.RDB$INDEX_NAME
  AND NOT rc2.RDB$RELATION_NAME IN ('GD_CONTACTLIST') /*  */
}

end.
