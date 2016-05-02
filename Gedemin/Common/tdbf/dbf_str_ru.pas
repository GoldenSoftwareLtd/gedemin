unit dbf_str_ru;

// file is encoded in Windows-1251 encoding
// for using with Linux/Kylix must be re-coded to KOI8-R
// for use with DOS & OS/2 (if it will be possible with FreePascal or VirtualPascal)
//    file should be recoded to cp866

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := '���� "%s" �� ����������. ������� ����������.';

  STRING_RECORD_LOCKED                := '������ (������ �������) �������������.';
  STRING_READ_ERROR                   := '������ ������ � �����.';
  STRING_WRITE_ERROR                  := '������ ������ �� ���� (���� ��������?)';
  STRING_WRITE_INDEX_ERROR            := '������ ������ �� ����; ������� �������� ���������. ���� ��������?)';
  STRING_KEY_VIOLATION                := '�������� �������� �� ������ �����������!.'+#13+#10+
                                         '������: %s'+#13+#10+'������ (������)=%d  ����="%s".';

  STRING_INVALID_DBF_FILE             := '���� DBF ��������� ��� ��� ��������� �� DBF.';
  STRING_FIELD_TOO_LONG               := '����� �������� - %d ��������, ��� ������ ��������� - %d.';
  STRING_INVALID_FIELD_COUNT          := '���������� ����� � ������� (%d) ����������. ��������� �� 1 �� 4095.';
  STRING_INVALID_FIELD_TYPE           := '��� �������� "%s", ������������� ����� "%s" ����������.';
  STRING_INVALID_VCL_FIELD_TYPE       := '���������� ������� ���� "%s", ��� ������ VCL[%x] �� ����� ���� ������� � DBF.';

  STRING_INVALID_MDX_FILE             := '���� MDX ��������� ��� ��� ��������� �� MDX.';
  STRING_PARSER_UNKNOWN_FIELD         := '�������������� ���� "%s".';
  STRING_PARSER_INVALID_FIELDTYPE     := '��� ��������, ������������� ����� "%s" ����������.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := '%s: ������� ������� �������� ��� ������� (%d). ������ ���� �� ������ 100 ��������.';
  STRING_INVALID_INDEX_TYPE           := '����������� ��� �������: ���������� �������� ������ �� ����� ��� ������';
  STRING_CANNOT_OPEN_INDEX            := '���������� ������� ������ "%s".';
  STRING_TOO_MANY_INDEXES             := '���������� ������� ��� ���� ������. ���� �����.';
  STRING_INDEX_NOT_EXIST              := '������ "%s" �� ����������.';
  STRING_NEED_EXCLUSIVE_ACCESS        := '���������� ��������� - ������� ����� �������� ����������� ������.';

  STRING_PROGRESS_PACKINGRECORDS      := '����������� ������';
  STRING_PROGRESS_READINGRECORDS      := '��������� ������';
  STRING_PROGRESS_APPENDINGRECORDS    := '��������� ������';
  STRING_PROGRESS_SORTING_RECORDS     := '�� ��������� ������';
  STRING_PROGRESS_WRITING_RECORDS     := '����� ������';
end.

