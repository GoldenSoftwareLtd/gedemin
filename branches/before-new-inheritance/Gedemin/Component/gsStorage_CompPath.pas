
(*

  ��� ���������� � ��������� �������� ���������� �� ���������� ����, �������
  ������ �� ����: ����������, ��� ���������, ��������� ��������� � �.�.

  � ��������� �������� ��� ������ �� ��������� ��������� ��� ����� �� ����.
  ����� ����, ����������� ��� ���������� ����� �� ����� ���� ��� ����������
  ������ �� ���������.

  Context:

  ������ ��������� ����, �� � ����������� �� ������������ ��������� ��
  ������������ �� �������. � ���� ������ ��� ���� ���-�� ���������
  ��� ��������� ����. �� ���������� ��������� �������� ��������.
  �������� ������ ������ ��������, ��� �������� �� ������������.

  �������� ������������ � ������� LoadComponent & SaveComponent in TgsStorage.

*)

unit gsStorage_CompPath;

interface

uses
  Classes, Windows;

function BuildComponentPath(C: TComponent; const Context: String = ''): String;

implementation

uses
  Forms, SysUtils, gdc_createable_form, jclStrings, gd_strings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

function BuildComponentPath(C: TComponent; const Context: String = ''): String;

  function RemoveLastNum(const Cmpnt: TComponent): String;
  var
    Tail: Integer;
    ST: String;
  begin
    Result := Cmpnt.Name;
    Tail := 0;

    // ���������� �� ����� ����� ������
    if Cmpnt is TgdcCreateableForm then
    begin
      ST := RemoveProhibitedSymbols((Cmpnt as TgdcCreateableForm).SubType);

      if ST > '' then
      begin
        Tail := StrIPos(ST, Result) + Length(ST);
      end;
    end;

    if Tail = 0 then
    begin
      Tail := Length(Result);
      while (Tail > 0) and (Result[Tail] <> '_') do
        Dec(Tail);
    end;

    if Tail > 0 then
    begin
      if StrIsDigit(Copy(Result, Tail + 1, 255)) then
        Result := Copy(Result, 1, Tail - 1);
    end;
  end;

  function _BuildComponentPath(C: TComponent): String;
  begin
    // �� ���������� ��������, �� ��� ���������� ��������
    // � ��������� � �������� ���� ���� ������ ������
    // ��� ������ Owner ��� Ͳ�, � �� ��������
    if (C.Owner = nil) or (C.Owner = Application) or (C is TCustomForm) then
      Result := Format('%s(%s)', [RemoveLastNum(C), C.ClassName])
    else
      Result := _BuildComponentPath(C.Owner) + '\' + Format('%s(%s)', [RemoveLastNum(C), C.ClassName]);
  end;

begin
  try
    if not Assigned(C) then
      Result := Context
    else begin
      Result := _BuildComponentPath(C);

      if Context > '' then
        Result := Result + '\' + Context;
    end;
  except
    on E: Exception do
    begin
      MessageBox(0, PChar('��������� ������ ��� ���������� ���� ����������.' + E.Message),
       '��������', MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      Result := Context;
    end;
  end;
end;

end.
