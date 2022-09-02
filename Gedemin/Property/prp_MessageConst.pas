// ShlTanya, 26.02.2019

unit prp_MessageConst;

interface

const
  // Предопределенные в VB функции
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
  MSG_DATASET_NOT_ASSIGNED = 'ДатаСет неинициализирован';
  MSG_STREAM_DO_NOT_INIT = 'Поток неинициализирован';
  MSG_WRONG_DATA = 'Поток содержит ошибочные данные';
  MSG_CAN_NOT_DELETE_FOULDER = 'Папка содержит другие папки, отчёты или макросы. Немогу удалить папку';
  MSG_CAN_NOT_DELETE_MACROS = 'Немогу удалить макрос';
  MSG_CAN_NOT_DELETE_EVENT = 'Немогу удалить событие';
  MSG_CAN_NOT_DELETE_REPORT = 'Немогу удалить отчёт';
  MSG_CANNOT_DELETE_REPORTFUNCTION = 'Немогу удалить функцию %s т.к. она используется в других отчётах.' + Char(13)+
    'Для продолжения нажмите ОК';
  MSG_CANNOT_DELETE_REPORTTEMPLATE = 'Немогу удалить шаблон %s т.к. он используется в других отчётах.' + Char(13)+
    'Для продолжения нажмите ОК';
  MSG_CAN_NOT_DELETE_FUNCTION = 'Немогу удалить функцию %s т.к. на неё имеются ссылки.' + Char(13)+
    'Для продолжения нажмите ОК';
  MSG_WARNING = 'Внимание';
  MSG_ERROR = 'Ошибка';
  MSG_QUESTION = 'Вопрос';
  MSG_YOU_ARE_SURE = 'Удаленные данные восстановить нельзя!' + Char(13) +
     'Вы хотите продолжить?';
  MSG_EMPTY_NAME_FUNCTION ='Не введено наименование функции.';
  MSG_NAME_FUNCTION_NUMBER ='Наименование функции не может начинаться с цифры.';
  MSG_UNKNOWN_NAME_FUNCTION ='Неправильно введено наименование функции.'#13#10#13#10 +
    'Если Вы изменили наименование функции непосредственно в тексте, то необходимо ввести такое же имя в поле "Наименование функции" на закладке "Свойства"';
  MSG_CORRECT_NAME_FUNCTION ='Изменено наименование функции. Скорректировать?';
  MSG_ERROR_SAVE = 'Произошла ошибка при сохранении:';
  MSG_ERROR_CREATE_OBJECT = 'Произошла ошибка при создании объекта: ';
  MSG_ERROR_FIND_OBJECT = 'Произошла ошибка при поиске объекта: ';
  MSG_ERROR_SAVE_EVENT = 'Произошла ошибка при сохранении события: ';
  MSG_ERROR_SAVE_REPORT = 'Произошла ошибка при сохранении отчёта: ';
  MSG_ERROR_ROLLBACK = 'Произошла ошибка при откате:';
  MSG_SAVE_CHANGES = 'Сохранить изменения?';
  MSG_FIND_EMPTY_STRING = 'Нельзя искать пустую строку!';
  MSG_SEACHING_TEXT = 'Искомый текст ''';
  MSG_NOT_FIND = ''' не найден!';
  MSG_REPLACE_EMPTY_STRING = 'Нельзя заменить пустую строку!';
  MSG_NOT_REPLACE = ''' не может быть заменен!';
  MSG_SURE_TO_COPY = '%s %s в папку "%s"?';
  MSG_COPY = 'Скопировать';
  MSG_CUT = 'Переместить';
  MSG_COPY_FOLDER = 'папку "%s"'; // пробел и двойные ковычки
  MSG_COPY_MACROS = 'макрос "%s"';// в конце
  MSG_COPY_REPORT = 'отчёт "%s"';// необходим
  MSG_NEED_MAIN_FORMULA_KEY = 'Неопределена главная функция';
  MSG_NO_DATA_IN_TABLE = 'Нет данных в таблицe %s';
  MSG_PASTE_ERROR = 'Ошибка при вcтавке';
  MSG_REPORT_GROUP = 'Группа отчетов';
  MSG_INVALID_DATA = 'Ошибочные данные';
  MSG_QUESTION_FOR_COPY = '  Внимание. "%s" ссылается на функцию "%s"' +
    ' на которую имеются ссылки из других таблиц.'#13#10 +
    '  Для создания копии этой функции нажмите кнопку "Создать копию".'#13#10 +
    '  Для сохранения изменений в текущей функции нажмите кнопку "Изменить".'#13#10 +
    '  Для просмотра ссылок на функцию нажмите кнопку "Подробнее"' ;

  MSG_ERROR_IN_SCRIPT = '[Ошибка] %s %s';
  MSG_ERROR_UNINAME    =
    '[Ошибка имени] Недопустимое имя. Имя ''%s'' не уникально в пределах модуля (обнаруженно в СФ с ИД = %d).';
  MSG_ERROR_PREDEFINED =
    '[Ошибка имени] Недопустимое имя. Имя ''%s'' зарезервировано под стандартную функцию.';
  MSG_ERROR_CYCLICREF =
    '[Ошибка] Обнаружена циклическая ссылка на СФ ''%s'' с ИД = %d.';
  MSG_HINT             =
    '[Предупреждение] Имя ''%s'' не уникально в пределах проекта (обнаруженно в СФ с ИД = %d).';
const
  ROOT_LOCAL_MACROS = 'Локальные макросы';
  NEW_MACROS_NAME = 'Макрос';
  NEW_FOLDER_NAME = 'Новая папка';
  NEW_REPORT_NAME = 'Отчёт';
  NEW_SCRIPTFUNCTION = 'ScriptFunction';
  NEW_CONST = 'Const';
  NEW_GLOBALOBJECT = 'GlobalObject';
  NEW_VBCLASS     = 'TVBClass';
  NEW_PROLOG = 'PrologScript';
  MAIN_FUNCTION = 'Основная функция';
  PARAM_FUNCTION = 'Функция параметров';
  EVENT_FUNCTION = 'Функция события';
  TEMPLATE = 'Шаблон';
  REPORTS  = 'Отчёты';
  SCRIPT_FUNCTIONS = 'Скрипт-функции';
  ROOT_CONST = 'Гл.константы и переменные';
  ROOT_GLOBAL_OBJECT = 'Глобальные VB-объекты';
  ROOT_CLASSES = 'GDC классы';
  ROOT_OBJECT = 'Объекты';
  VBCLASSES = 'VB классы';

const
  VB_MACROS_TEMPLATE = 'Option Explicit'#13#10'Sub %s(OwnerForm)'#13#10'End Sub';
  VB_OWNERFORM = 'OWNERFORM';

  VB_PARAMFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(OwnerForm)'#13#10 +
    '  ''Функция параметров должна возвращать массив с размерностью,'#13#10 +
    '  ''соответствующей кол-ву входных параметров основной функции.'#13#10 +
    '  ''dim A(<Кол-во входных параметров осн. ф.>-1)'#13#10 +
    '  ''%s = A'#13#10 +
    'End Function';

  VB_MAINFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(OwnerForm)'#13#10 +
    '  BaseQueryList.Clear'#13#10 +
    ''#13#10 +
    '  Dim q'#13#10 +
    '  Set q = BaseQueryList.Query(BaseQueryList.Add("q", 0))'#13#10 +
    '  q.SQL = "введите текст запроса"'#13#10 +
    '  q.Open'#13#10 +
    ''#13#10 +
    '  Set %s = BaseQueryList'#13#10 +
    'End Function';

  VB_EVENTFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s(Params, Value, Name)'#13#10 +
    '  ''Результат возвращаемый функцией должен быть True или False'#13#10 +
    '  ''  Если функция вернет True, то произойдет закрытие окна предварительного просмотра'#13#10 +
    '  %s = False'#13#10 +
    'End Function';

  VB_SCRIPTFUNCTION_TEMPLATE =
    'Option Explicit'#13#10 +
    'Function %s'#13#10 +
    'End Function';

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
    '''Константы и переменные';

  VB_GLOBAL_OBJECT =
    'Option Explicit'#13#10''' объявление глобального объекта'#13#10 +
    'Public %s'#13#10 + #13#10 +
    ''' создание глобального объекта'#13#10 +
    'Sub %s_Initialize'#13#10 +
    '  '' возврат глобального объекта'#13#10 +
    '  set %s = nil''инициализация объекта'#13#10 +
    'End Sub'#13#10 + #13#10 +
    ''' уничтожение глобального объекта'#13#10 +
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
