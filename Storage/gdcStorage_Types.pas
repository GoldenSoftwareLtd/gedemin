
unit gdcStorage_Types;

interface

const
  cStorageGlobal  = 'G'; // корень глобального хранилища
  cStorageUser    = 'U'; // корень пользовательского хранилища, int_data -- ключ пользователя
  cStorageCompany = 'O'; // корень хранилища компании; int_data -- ключ компании
  cStorageDesktop = 'T'; // корень хранилища р.стола; int_data -- ключ р.стола
  cStorageFolder  = 'F'; // папка
  cStorageString  = 'S'; // строка
  cStorageInteger = 'I'; // целое число
  cStorageCurrency= 'C'; // дробное число
  cStorageBoolean = 'L'; // булевский тип
  cStorageDateTime= 'D'; // дата и время
  cStorageBLOB    = 'B'; // двоичный объект

  cStorageMaxNameLen = 120;
  cStorageMaxStrLen  = 120;

implementation

end.