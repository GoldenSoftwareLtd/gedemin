unit dbf_str;

{ German }

interface

{$I dbf_common.inc}
{$I dbf_str.inc}

implementation

initialization

  STRING_FILE_NOT_FOUND               := '�ffnen: Datei nicht gefunden: "%s"';

  STRING_RECORD_LOCKED                := 'Datensatz gesperrt.';
  STRING_READ_ERROR                   := 'Lesefehler.';
  STRING_WRITE_ERROR                  := 'Schreibfehler (Festplatte voll?)';
  STRING_WRITE_INDEX_ERROR            := 'Schreibfehler; Indizes wahrscheinlich besch�digt. (Festplatte voll?)';
  STRING_KEY_VIOLATION                := 'Indexverletzung (Indexschl�ssel bereits vorhanden)'+#13+#10+
                                         'Index: %s'+#13+#10+'Record=%d Schl�ssel=''%s''';

  STRING_INVALID_DBF_FILE             := 'Ung�ltige DBF-Datei.';
  STRING_FIELD_TOO_LONG               := 'Wert ist zu lang: %d Zeichen (maximal erlaubt: %d).';
  STRING_INVALID_FIELD_COUNT          := 'Ung�ltige Anzahl von Feldern: %d (muss zwischen 1 und 4095 sein).';
  STRING_INVALID_FIELD_TYPE           := 'Ung�ltiger Feldtyp ''%s'' f�r das Feld ''%s''.';
  STRING_INVALID_VCL_FIELD_TYPE       := 'Feld "%s" kann nicht erzeugt werden: VCL-Feldtyp %x wird nicht von DBF unterst�tzt.';

  STRING_INVALID_MDX_FILE             := 'Ung�ltige MDX-Datei.';
  STRING_PARSER_UNKNOWN_FIELD         := 'Unbekanntem Feld "%s".';
  STRING_PARSER_INVALID_FIELDTYPE     := 'Ung�ltiger Feldtyp f�r das Feld ''%s''.';
  STRING_INDEX_EXPRESSION_TOO_LONG    := 'Das Ergebnis des Index-Ausdrucks "%s" ist zu lang, >100 Zeichen (%d).';
  STRING_INVALID_INDEX_TYPE           := 'Ung�ltiger Indextyp: nur Zeichen oder Numerisch erlaubt.';
  STRING_CANNOT_OPEN_INDEX            := '�ffnen des Index ist gescheitert: "%s".';
  STRING_TOO_MANY_INDEXES             := 'Erzeugen eines Index nicht m�glich: Zu viele Indizes in der Datei.';
  STRING_INDEX_NOT_EXIST              := 'Index "%s" existiert nicht.';
  STRING_NEED_EXCLUSIVE_ACCESS        := 'Exclusivzugriff f�r diese Aktion n�tig.';

  STRING_PROGRESS_PACKINGRECORDS      := 'Packt datens�tzen';
  STRING_PROGRESS_READINGRECORDS      := 'Liest datens�tzen';
  STRING_PROGRESS_APPENDINGRECORDS    := 'Anh�ngt datens�tzen';
  STRING_PROGRESS_SORTING_RECORDS     := 'Sortiert datens�tzen';
  STRING_PROGRESS_WRITING_RECORDS     := 'Schreibt datens�tzen';
end.

