unit gsMethodInfo;

interface

uses sysutils, TypInfo, contnrs;

type
  PMethodInfo = ^TMethodInfo;
  TMethodInfo = packed record
    MethodID: Integer;
    MethodKind: TMethodKind;
    ParamCount: Byte;
    ParamList: array[0..1023] of Char;
  end;
       {ParamList: array[1..ParamCount] of
          record
            Flags: TParamFlags;
            ParamName: ShortString;
            TypeName: ShortString;
          end;
        ResultType: ShortString}

  EgsMethodInfoError = class(Exception);

type
  TgsMethodClass = class
  private
    FMethodName: ShortString;

    MethodID: Integer;
    MethodKind: TMethodKind;
    ParamCount: Byte;
    ParamList: array[0..1023] of Char;

    procedure ParseMethod(const aFullMethodStr: String);
  public
    constructor Create(const aFullMethodStr: String; aMethodID: Integer);
  end;

  TgsMethodList = class(TObjectList)
    procedure AddMethod(const aFullMethodStr: String);
  end;

var
  gsMethodList: TgsMethodList;  

implementation

{ TgsMethodClass }

constructor TgsMethodClass.Create(const aFullMethodStr: String; aMethodID: Integer);
begin
  MethodID := aMethodID;
  ParseMethod(aFullMethodStr);
end;

procedure TgsMethodClass.ParseMethod(const aFullMethodStr: String);
var
  S, S1: String;
  OutputType: ShortString;
  isClass: Boolean;
  L: Integer;

procedure AddToParamList(S: ShortString);
begin
  ParamList[L] := Chr(Length(S));
  Inc(L);
  StrCat(ParamList, @S[1]);
  Inc(L, Length(S));
  ParamList[L] := #0;
end;

procedure ParseParams(ParamStr: String);
var
  TempStr: String;
  TypeName, ParamName: ShortString;
  ParamFlag: TParamFlags;
  N: Byte;
begin
  ParamFlag := [];

  if Pos(':', ParamStr) > 0 then
  begin
    typeName := Trim(copy(ParamStr, Pos(':', ParamStr) + 1, Length(ParamStr)));
    if (Pos(' of ', typeName) > 0) then
    begin
      ParamFlag := ParamFlag + [pfArray];
      typeName := Trim(copy(typeName, Pos(' of ', typeName) + 1, Length(TypeName)));
    end;
    if Pos('var ', ParamStr) = 1 then
    begin
      N := 1;
      ParamFlag := ParamFlag + [pfVar];
      ParamStr := copy(ParamStr, Pos('var ', ParamStr) + 3, Length(ParamStr));
    end
    else
      if Pos('const ', ParamStr) = 1 then
      begin
        ParamFlag := ParamFlag + [pfConst];
        N := 2;
        ParamStr := copy(ParamStr, Pos('const ', ParamStr) + 5, Length(ParamStr));
      end
      else
        if Pos('out ', ParamStr) = 1 then
        begin
          ParamFlag := ParamFlag + [pfOut];
          N := 32;
          ParamStr := copy(ParamStr, Pos('out ', ParamStr) + 3, Length(ParamStr));
        end
        else
          N := 4;

    TempStr := Trim(copy(ParamStr, 1, Pos(':', ParamStr) - 1));
    while TempStr > '' do
    begin
      ParamList[L] := Chr(N);
      Inc(L);
      ParamList[L] := #0;

      if Pos(',', TempStr) > 0 then
      begin
        ParamName := Trim(copy(TempStr, 1, Pos(',', TempStr) - 1));
        TempStr := Trim(copy(TempStr, Pos(',', TempStr) + 1, Length(TempStr)));
      end
      else
      begin
        ParamName := TempStr;
        TempStr := '';
      end;
      AddToParamList(ParamName);
      AddToParamList(TypeName);
    end;
  end
  else
    raise EgsMethodInfoError.Create('Не верное описание мeтода');
end;

begin
  ParamCount := 0;
  L := 0;
  ParamList[0] := #0;

  S := LowerCase(Trim(aFullMethodStr));
  S1 := copy(S, 1, Pos(' ', S) - 1);
  isClass := S1 = 'class';
  if isClass then
  begin
    S := Trim(copy(S, Pos(' ', S) + 1, Length(S)));
    S1 := copy(S, 1, Pos(' ', S) - 1);
  end;

  if S1 = 'function' then
  begin
    if not isClass then
      MethodKind := mkFunction
    else
      MethodKind := mkClassFunction
  end
  else
    if S1 = 'procedure' then
    begin
      if not isClass then
        MethodKind := mkProcedure
      else
        MethodKind := mkClassProcedure
    end
    else
      if S1 = 'constructor' then
        MethodKind := mkConstructor
      else
        if S1 = 'destructor' then
          MethodKind := mkDestructor
        else
          raise EgsMethodInfoError.Create('Не верное описание мeтода');

  if (MethodKind = mkClassFunction) or (MethodKind = mkFunction) then
  begin
    if Pos(')', S) > 0 then
      S1 := copy(S, Pos(')', S) + 1, Length(S))
    else
      S1 := S;
    if Pos(':', S1) > 0 then
      OutputType := Trim(copy(S1, Pos(':', S1) + 1, Length(S1)))
    else
      raise EgsMethodInfoError.Create('Не верное описание мeтода');
  end
  else
    OutputType := '';

  S := Trim(copy(S, Pos(' ', S) + 1, Length(S)));
  if Pos('(', S) > 0 then
  begin
    FMethodName := Trim(copy(S, 1, Pos('(', S) - 1));
    if Pos(')', S) > 0 then
    begin
      S := Trim(copy(S, Pos('(', S) + 1, Pos(')', S) - Pos('(', S) - 1));
      while S > '' do
      begin
        if Pos(';', S) > 0 then
        begin
          S1 := trim(copy(S, 1, Pos(';', S) - 1));
          S := trim(copy(S, Pos(';', S) + 1, Length(S)));
        end
        else
        begin
          S1 := S;
          S := '';
        end;
        ParseParams(S1);

      end;
    end
    else
      raise EgsMethodInfoError.Create('Не верное описание мeтода');
  end
  else
    FMethodName := S;

  if OutputType > '' then
    AddToParamList(OutputType);
end;

{ TgsMethodList }

procedure TgsMethodList.AddMethod(const aFullMethodStr: String);
begin
  Add(TgsMethodClass.Create(aFullMethodStr, Count + 1));
end;

initialization

  gsMethodList := TgsMethodList.Create;

  gsMethodList.AddMethod('function GetListNameByID(const AID: String): String');

finalization

  FreeAndNil(gsMethodList);  

end.
