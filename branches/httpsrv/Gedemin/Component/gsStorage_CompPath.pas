
(*

  ��� ���������� � ��������� �������� ���������� �� ���������� ����, �������
  ������ �� ����: ����������, ��� ���������, ��������� ��������� � �.�.

  � ��������� �������� ��� ������ �� ��������� ��������� ��� ����� �� ����.
  ����� ����, ����������� ��� ���������� ����� �� ����� ���� ��� ����������
  ������ �� ���������.

  �������� ����� �� ��������� �������� ���� ������ ���� ��� � ��������
  ��� � ������. ����� ����� ���� �������� ��������� ��������� ���� ���
  ������� ���������� �� ����� ����� ��� �� ������.

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

{var
  MainForm: TComponent;}

function BuildComponentPath(C: TComponent; const Context: String = ''): String;
{procedure RemoveComponentFromList(C: TComponent);}

implementation

uses
  Forms, SysUtils, gdc_createable_form, jclStrings, gd_strings
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{var
  RegisteredCompPath: TStringList;

procedure RemoveComponentFromList(C: TComponent);
var
  I: Integer;
begin
  if Assigned(RegisteredCompPath) then
  begin
    I := RegisteredCompPath.IndexOfObject(C);
    if I <> -1 then
      RegisteredCompPath.Delete(I);
  end;
end;}

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

{var
  S: String;}

begin
  try
    if not Assigned(C) then
      Result := Context
    else begin
      Result := _BuildComponentPath(C);

      if Context > '' then
        Result := Result + '\' + Context;
    end;

    {if not Assigned(C) then
    begin
      Result := Context;
      exit;
    end;

    if Assigned(RegisteredCompPath) and (RegisteredCompPath.IndexOfObject(C) > -1) then
    begin
      Result := RegisteredCompPath[RegisteredCompPath.IndexOfObject(C)];

      // ���� ��������� ������, ��� ���� ������������ ����, �� ��
      // ��������� � ��� ������. ����� ��������� ����� ���� ������
      // �� � ����� ������ �� ��� ����� ���������. ��������� �������
      // �������������� �������� � ���� ����������, ��� � ������
      // �������� ���� � ����� ���������� ����������, ������� (�����)
      // ��������� � ����������, �� ������� �� �� ������
      S := _BuildComponentPath(C);

      // ���� ����� ���������� ������ ������� ��-�� owner-��, �������
      // � ��������� ��������� ����� ���� ��������
      if Pos(S, Result) = Length(Result) - Length(S) + 1 then
      begin

        if Context > '' then
          Result := Result + '\' + Context;

        exit;
      end else
        RegisteredCompPath.Delete(RegisteredCompPath.IndexOfObject(C));
    end;

    Result := _BuildComponentPath(C);

    RegisteredCompPath.AddObject(Result, C);

    if Assigned(MainForm) then
      C.FreeNotification(MainForm);

    if Context > '' then
      Result := Result + '\' + Context;}
  except
    on E: Exception do
    begin
      MessageBox(0, PChar('��������� ������ ��� ���������� ���� ����������.' + E.Message),
       '��������', MB_OK or MB_ICONERROR or MB_TOPMOST or MB_TASKMODAL);
      Result := Context;
    end;
  end;
end;

{initialization
  RegisteredCompPath := TStringList.Create;
  RegisteredCompPath.Sorted := True;
  RegisteredCompPath.Duplicates := dupIgnore;

finalization
  FreeAndNil(RegisteredCompPath);}
end.
