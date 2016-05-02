unit dbf_str;

{ Polish }

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := 'Open: brak pliku: "%s"';

  STRING_RECORD_LOCKED                := 'Rekord zablokowany.';
  STRING_READ_ERROR                   := 'Nieprzeczytane.';
  STRING_WRITE_ERROR                  := 'Niezapisano(Brak miejsca na dysku?)';
  STRING_WRITE_INDEX_ERROR            := 'Niezapisano; prawdopodobnie uszkodzone indeksy. (Disk full?)';
  STRING_KEY_VIOLATION                := 'Konflikt klucza. (Klucz obecny w pliku).'+#13+#10+
                                         'Indeks: %s'+#13+#10+'Rekord=%d Klucz=''%s''';

  STRING_INVALID_DBF_FILE             := 'Uszkodzony plik bazy.';
  STRING_FIELD_TOO_LONG               := 'Dana za d�uga : %d znak�w (dopuszczalne do %d).';
  STRING_INVALID_FIELD_COUNT          := 'Z�a liczba p�l: %d (dozwolone 1 do 4095).';
  STRING_INVALID_FIELD_TYPE           := 'B��dny typ pola ''%c'' dla pola ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Nie mog� tworzy� pola "%s", typ pola VCL %x nie wspierany przez DBF.';

  STRING_INVALID_MDX_FILE             := 'Uszkodzony plik bazy.';
  STRING_PARSER_UNKNOWN_FIELD         := '"%s" nie istnieje';
  STRING_PARSER_INVALID_FIELDTYPE     := 'B��dny typ pola dla pola ''%s''.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Zbyt d�ugi wynik "%s", >100 znak�w (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Z�y typ indeksu: tylko string lub float';
  STRING_CANNOT_OPEN_INDEX            := 'Nie mog� otworzy� indeksu: "%s"';
  STRING_TOO_MANY_INDEXES             := 'Nie mog� stworzy� indeksu: za du�o w pliku.';
  STRING_INDEX_NOT_EXIST              := 'Brak indeksu "%s".';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Operacja wymaga dost�pu w trybie Exclusive.';

  STRING_PROGRESS_PACKINGRECORDS      := 'Pakuje rekordy';
  STRING_PROGRESS_READINGRECORDS      := 'Czyta rekordy';
  STRING_PROGRESS_APPENDINGRECORDS    := 'Docza rekordy';
  STRING_PROGRESS_SORTING_RECORDS     := 'Sortuje rekordy';
  STRING_PROGRESS_WRITING_RECORDS     := 'Pisze rekordy';
end.

