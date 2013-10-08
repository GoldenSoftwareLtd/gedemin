unit prp_MessageConst;

interface

const
  // ���������������� � VB �������
  PredefinedNames =
    'ABS'#13#10 +
    'ARRAY'#13#10 +
    'ASC'#13#10 +
    'ATN'#13#10 +
    'CBOOL'#13#10 +
    'CBYTE'#13#10 +
    'CCUR'#13#10 +
    'CDATE'#13#10 +
    'CDBL'#13#10 +
    'CHR'#13#10 +
    'CINT'#13#10 +
    'CLNG'#13#10 +
    'COS'#13#10 +
    'CREATEOBJECT'#13#10 +
    'CSNG'#13#10 +
    'CSTR'#13#10 +
    'DATE'#13#10 +
    'DATEADD'#13#10 +
    'DATEDIFF'#13#10 +
    'DATEPART'#13#10 +
    'DATESERIAL'#13#10 +
    'DATEVALUE'#13#10 +
    'DAY'#13#10 +
    'EVAL'#13#10 +
    'EXP'#13#10 +
    'FILTER'#13#10 +
    'FIX'#13#10 +
    'FORMATCURRENCY'#13#10 +
    'FORMATDATETIME'#13#10 +
    'FORMATNUMBER'#13#10 +
    'FORMATPERCENT'#13#10 +
    'GETLOCALE'#13#10 +
    'GETOBJECT'#13#10 +
    'GETREF'#13#10 +
    'HEX'#13#10 +
    'HOUR'#13#10 +
    'INPUTBOX'#13#10 +
    'INSTR'#13#10 +
    'INSTRREV'#13#10 +
    'INT'#13#10 +
    'ISARRAY'#13#10 +
    'ISDATE'#13#10 +
    'ISEMPTY'#13#10 +
    'ISNULL'#13#10 +
    'ISNUMERIC'#13#10 +
    'ISOBJECT'#13#10 +
    'JOIN'#13#10 +
    'LBOUND'#13#10 +
    'LCASE'#13#10 +
    'LEFT'#13#10 +
    'LEN'#13#10 +
    'LOADPICTURE'#13#10 +
    'LOG'#13#10 +
    'LTRIM'#13#10 +
    'MID'#13#10 +
    'MINUTE'#13#10 +
    'MONTH'#13#10 +
    'MONTHNAME'#13#10 +
    'MSGBOX'#13#10 +
    'NOW'#13#10 +
    'OCT'#13#10 +
    'REPLACE'#13#10 +
    'RGB'#13#10 +
    'RIGHT'#13#10 +
    'RND'#13#10 +
    'ROUND'#13#10 +
    'RTRIM'#13#10 +
    'SCRIPTENGINE'#13#10 +
    'SCRIPTENGINEBUILDVERTION'#13#10 +
    'SCRIPTENGINEMAJORVERTION'#13#10 +
    'SCRIPTENGINEMINORVERTION'#13#10 +
    'SECOND'#13#10 +
    'SGN'#13#10 +
    'SIN'#13#10 +
    'SPACE'#13#10 +
    'SPLIT'#13#10 +
    'SQR'#13#10 +
    'STRCOMP'#13#10 +
    'STRING'#13#10 +
    'STRREVERSE'#13#10 +
    'TAN'#13#10 +
    'TIME'#13#10 +
    'TIMER'#13#10 +
    'TIMESERIAL'#13#10 +
    'TIMEVALUE'#13#10 +
    'TRIM'#13#10 +
    'TYPENAME'#13#10 +
    'UBOUND'#13#10 +
    'UCASE'#13#10 +
    'VARTYPE'#13#10 +
    'WEEKDAY'#13#10 +
    'WEEKDAYNAME'#13#10 +
    'YEAR';

const
  MSG_DATASET_NOT_ASSIGNED = '������� �����������������';
  MSG_STREAM_DO_NOT_INIT = '����� �����������������';
  MSG_WRONG_DATA = '����� �������� ��������� ������';
  MSG_CAN_NOT_DELETE_FOULDER = '����� �������� ������ �����, ������ ��� �������. ������ ������� �����';
  MSG_CAN_NOT_DELETE_MACROS = '������ ������� ������';
  MSG_CAN_NOT_DELETE_EVENT = '������ ������� �������';
  MSG_CAN_NOT_DELETE_REPORT = '������ ������� �����';
  MSG_CANNOT_DELETE_REPORTFUNCTION = '������ ������� ������� %s �.�. ��� ������������ � ������ �������.' + Char(13)+
    '��� ����������� ������� ��';
  MSG_CANNOT_DELETE_REPORTTEMPLATE = '������ ������� ������ %s �.�. �� ������������ � ������ �������.' + Char(13)+
    '��� ����������� ������� ��';
  MSG_CAN_NOT_DELETE_FUNCTION = '������ ������� ������� %s �.�. �� �� ������� ������.' + Char(13)+
    '��� ����������� ������� ��';
  MSG_WARNING = '��������';
  MSG_ERROR = '������';
  MSG_QUESTION = '������';
  MSG_YOU_ARE_SURE = '��������� ������ ������������ ������!' + Char(13) +
     '�� ������ ����������?';
  MSG_EMPTY_NAME_FUNCTION ='�� ������� ������������ �������.';
  MSG_NAME_FUNCTION_NUMBER ='������������ ������� �� ����� ���������� � �����.';
  MSG_UNKNOWN_NAME_FUNCTION ='����������� ������� ������������ �������.'#13#10#13#10 +
    '���� �� �������� ������������ ������� ��������������� � ������, �� ���������� ������ ����� �� ��� � ���� "������������ �������" �� �������� "��������"';
  MSG_CORRECT_NAME_FUNCTION ='�������� ������������ �������. ���������������?';
  MSG_ERROR_SAVE = '��������� ������ ��� ����������:';
  MSG_ERROR_CREATE_OBJECT = '��������� ������ ��� �������� �������: ';
  MSG_ERROR_FIND_OBJECT = '��������� ������ ��� ������ �������: ';
  MSG_ERROR_SAVE_EVENT = '��������� ������ ��� ���������� �������: ';
  MSG_ERROR_SAVE_REPORT = '��������� ������ ��� ���������� ������: ';
  MSG_ERROR_ROLLBACK = '��������� ������ ��� ������:';
  MSG_SAVE_CHANGES = '��������� ���������?';
  MSG_FIND_EMPTY_STRING = '������ ������ ������ ������!';
  MSG_SEACHING_TEXT = '������� ����� ''';
  MSG_NOT_FIND = ''' �� ������!';
  MSG_REPLACE_EMPTY_STRING = '������ �������� ������ ������!';
  MSG_NOT_REPLACE = ''' �� ����� ���� �������!';
  MSG_SURE_TO_COPY = '%s %s � ����� "%s"?';
  MSG_COPY = '�����������';
  MSG_CUT = '�����������';
  MSG_COPY_FOLDER = '����� "%s"'; // ������ � ������� �������
  MSG_COPY_MACROS = '������ "%s"';// � �����
  MSG_COPY_REPORT = '����� "%s"';// ���������
  MSG_NEED_MAIN_FORMULA_KEY = '������������ ������� �������';
  MSG_NO_DATA_IN_TABLE = '��� ������ � ������e %s';
  MSG_PASTE_ERROR = '������ ��� �c�����';
  MSG_REPORT_GROUP = '������ �������';
  MSG_INVALID_DATA = '��������� ������';
  MSG_QUESTION_FOR_COPY = '  ��������. "%s" ��������� �� ������� "%s"' +
    ' �� ������� ������� ������ �� ������ ������.'#13#10 +
    '  ��� �������� ����� ���� ������� ������� ������ "������� �����".'#13#10 +
    '  ��� ���������� ��������� � ������� ������� ������� ������ "��������".'#13#10 +
    '  ��� ��������� ������ �� ������� ������� ������ "���������"' ;

  MSG_ERROR_IN_SCRIPT = '[������] %s %s';
  MSG_ERROR_UNINAME    =
    '[������ �����] ������������ ���. ��� ''%s'' �� ��������� � �������� ������ (����������� � �� � �� = %d).';
  MSG_ERROR_PREDEFINED =
    '[������ �����] ������������ ���. ��� ''%s'' ��������������� ��� ����������� �������.';
  MSG_ERROR_CYCLICREF =
    '[������] ���������� ����������� ������ �� �� ''%s'' � �� = %d.';
  MSG_HINT             =
    '[��������������] ��� ''%s'' �� ��������� � �������� ������� (����������� � �� � �� = %d).';
const
  ROOT_LOCAL_MACROS = '��������� �������';
  NEW_MACROS_NAME = '������';
  NEW_FOLDER_NAME = '����� �����';
  NEW_REPORT_NAME = '�����';
  NEW_SCRIPTFUNCTION = 'ScriptFunction';
  NEW_CONST = 'Const';
  NEW_GLOBALOBJECT = 'GlobalObject';
  NEW_VBCLASS     = 'TVBClass';
  NEW_PROLOG = 'PrologScript';
  MAIN_FUNCTION = '�������� �������';
  PARAM_FUNCTION = '������� ����������';
  EVENT_FUNCTION = '������� �������';
  TEMPLATE = '������';
  REPORTS  = '������';
  SCRIPT_FUNCTIONS = '������-�������';
  ROOT_CONST = '��.��������� � ����������';
  ROOT_GLOBAL_OBJECT = '���������� VB-�������';
  ROOT_CLASSES = 'GDC ������';
  ROOT_OBJECT = '�������';
  VBCLASSES = 'VB ������';

const
  VB_MACROS_TEMPLATE = 'Option Explicit'#13#10'Sub %s(OwnerForm)'#13#10'End Sub';
  VB_OWNERFORM = 'OWNERFORM';

  VB_PARAMFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(OwnerForm)'#13#10 +
    '  ''������� ���������� ������ ���������� ������ � ������������,'#13#10 +
    '  ''��������������� ���-�� ������� ���������� �������� �������.'#13#10 +
    '  ''dim A(<���-�� ������� ���������� ���. �.>-1)'#13#10 +
    '  ''%s = A'#13#10 +
    'End Function';

  VB_MAINFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(OwnerForm)'#13#10 +
    '  BaseQueryList.Clear'#13#10 +
    ''#13#10 +
    '  Dim q'#13#10 +
    '  Set q = BaseQueryList.Query(BaseQueryList.Add("q", 0))'#13#10 +
    '  q.SQL = "������� ����� �������"'#13#10 +
    '  q.Open'#13#10 +
    ''#13#10 +
    '  Set %s = BaseQueryList'#13#10 +
    'End Function';

  VB_EVENTFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(Params, Value, Name)'#13#10 +
    '  ''��������� ������������ �������� ������ ���� True ��� False'#13#10 +
    '  ''  ���� ������� ������ True, �� ���������� �������� ���� ���������������� ���������'#13#10 +
    '  %s = False'#13#10 +
    'End Function';

  VB_SCRIPTFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s'#13#10 +
    'End function';

  VBClASS_TEMPLATE =
    'Option Explicit'#13#10 +
    'Class %s'#13#10 +
    '  Private Sub Class_Initialize'#13#10 +
    '  ''Setup Initialize event.'#13#10#13#10 +
    '  End Sub'#13#10#13#10 +
    '  Private Sub Class_Terminate'#13#10 +
    '  ''Setup Terminate event.'#13#10#13#10 +
    '  End Sub'#13#10 +
    'End Class';

  VB_CONST =
    'Option Explicit'#13#10 +
    '''��������� � ����������';

  VB_GLOBAL_OBJECT =
    'Option Explicit'#13#10''' ���������� ����������� �������'#13#10 +
    'Public %s'#13#10 + #13#10 +
    ''' �������� ����������� �������'#13#10 +
    'Sub %s_Initialize'#13#10 +
    '  '' ������� ����������� �������'#13#10 +
    '  set %s = nil''������������� �������'#13#10 +
    'End Sub'#13#10 + #13#10 +
    ''' ����������� ����������� �������'#13#10 +
    'Sub %s_Terminate'#13#10 + #13#10 +
    'End Sub';

  GL_OBJ_INIT = '_INITIALIZE';
  GL_OBJ_TERM = '_TERMINATE';

  JS_MACROS_TEMPLATE = 'function %s {'#13#10'}';
  JS_PARAMFUNCTION_TEMPLATE = 'function %s{'#13#10'  a = new array(0);'#13#10'  return(a);'#13#10'}';
  JS_MAINFUNCTION_TEMPLATE = 'function %s{'#13#10'  return(BaseQuery);'#13#10'}';
  JS_EVENTFUNCTION_TEMPLATE = 'function %s(Params, Value, Name){'#13#10'  return(1);'#13#10'}';
  JS_SCRIPTFUNCTION_TEMPLATE = 'function %s{'#13#10'}';

  BYREF = 'BYREF';
  BYVAL = 'BYVAL';


implementation

end.
