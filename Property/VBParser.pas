{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    VBParser.pas

  Abstract

    Gedemin project. TCustomParser, TVBParser.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.04.01    tiptop        Initial version.

--}

unit VBParser;

interface
uses Classes, Comctrls;

type
  TOnStatament = procedure (Line: Integer) of object;

type
  TCustomParser = class(TComponent)
  protected
    FComponent: TComponent;
    procedure SetComponent(const Value: TComponent);
    function GetComponent: TComponent;
  public
    procedure PrepareScript(const ScriptName: String;
      const Script: TStrings; AtLine: Integer = - 1);virtual; abstract;

    property Component: TComponent read GetComponent write SetComponent;
  end;

type
  //разборщик ВБ-скрипта
  TVBParser = class(TCustomParser)
  private
    FIsEvent: Boolean;
    FSenderAllocated: Boolean;
    procedure SetIsEvent(const Value: Boolean);
  protected
    FOnBeforeStatament: TOnStatament;
    FOnAfterStatament: TOnStatament;
    FObjects: TStrings;
    FDefiniteVaryList: TStrings;
    FStr: string;
    FLineAdd: Integer;
    FCurrentLine, FInsertLine: Integer;
    FCursorPos: Integer;
    FErrorListView: TListView;
    FScript: TStrings;
    FInFunction: Boolean;
    FInClass: Boolean;
    FComponentName: String;
    FScriptName: String;
    FParagraph: Integer;
    //Указывает на необходимость добавления определителя
    FAddDesignator: Boolean;
    FAtLine: Integer;
    FProcedureId: Integer;
    FSubFunction: string;
    FArgumentList: TStrings;
    FDesignator: String;
    FFieldsList: TStrings;
    FFunctionName: String;
    FClassName: String;

    procedure SetOnBeforeStatament(const Value: TOnStatament);
    procedure SetOnAfterStatament(const Value: TOnStatament);
    function GetComponentName: String;
    function GetDefiniteVaryList: TStrings;
    function GetErrorListView: TListView;
    function GetObjects: TStrings;
    function GetOnAfterStatament: TOnStatament;
    function GetOnBeforeStatament: TOnStatament;
    //Возвращает подготовленную к обработке строку
    function GetPrepareStr: String; virtual;
    //Возвращает TRUE если Name является именем зарегестрированного объекта
    function IsObject(Name: string): Boolean;
    //регестритует имя объекта
    function DefiniteVary(Name: string): Boolean;
    //Устанавливает кутсор на начало след. слова
    function NextWord: Integer;
    //Устанавливает кутсор на начало перд. слова
//    function PrevWord: Integer;
    //Возвращает текущее слово
    function GetCurrentWord: String;
    //Пропускает пробелы начиная с текущей позиции курсора
    procedure TrimSpace;
    //Устанавливает флаг выполняемости строки (для дебагера)
    procedure SetExecutable; virtual;
    //Обработка определения
    procedure WorkDesignator; virtual;
    //обработка множителя
    procedure WorkFactor;
    //Обработка термина
    procedure WorkTerm;
    //Операция умножения
    function IsMulOp: Boolean;
    //Операция сложения
    function IsAddOp: Boolean;
    //Логическая операция
    function IsRepOp: Boolean;
    //Обработка простого выражения
    procedure WorkSimpleExpression;
    //Обработка выражения
    procedure WorkExpression;
    //Обработка списка выражений
    procedure WorkExprList;
    //Обработка списка аргументов
    procedure WorkArgumentList;
    //Обработка аргумента
    procedure WorkArgument;
    //Возвращает Тру если переданная спрока явлся модиф.
    function IsArgModificator(Str: String): Boolean;
    //Обработка простого оператора
    procedure SimpleStatement;virtual;
    //Обработка оператора
    procedure Statament; virtual;
    //Добавляет сообщение об ошибке
    procedure AddError(Caption: String; Line: Integer);
    //Возвращает величину отступа
    function GetParagraph: Integer;
    function GetFindComponentString: String;
    procedure SetErrorListView(const Value: TListView);
    procedure SetComponentName(const Value: String);
    procedure DoBeforeStatament; virtual;
    procedure DoAfterStatament;  virtual;

    procedure DoProcBegin; virtual;
    procedure DoProcEnd; virtual;
    procedure DoExit(P: Integer); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareScript(const ScriptName: String; const Script: TStrings;
      AtLine: Integer = - 1); override;

    property DefiniteVaryList: TStrings read GetDefiniteVaryList;
    property Objects: TStrings read GetObjects;
    property ErrorListView: TListView read GetErrorListView write SetErrorListView;
    property ComponentName: String read GetComponentName write SetComponentName;
    property IsEvent: Boolean read FIsEvent write SetIsEvent;
    property OnBeforeStatament: TOnStatament read GetOnBeforeStatament write SetOnBeforeStatament;
    property OnAfterStatament: TOnStatament read GetOnAfterStatament write SetOnAfterStatament;
  end;

const
  Separators = ':(),.[] =+-<>'#10#13;
  Letters = '1234567890_qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM';
  Numbers = '0123456789';

  MSG_ADD_WITH_PARSER = ''' Добавлено парсером';

//Сообщения об ошибках генерируемые парсером
  MSG_ER_NOT_FIND_FUNCTION_END = 'Ненайден конец функции';
  MSG_ER_NOT_FIND_END_OF_STATAMENT = 'Ненайден конец оператора';
  MSG_ER_NOT_ALLOW_TAKE_UP_FUNCTION = 'Недопускаются вложенные функции';
  MSG_ER_NOT_FIND_THEN = 'Не найден оператор Then';
  MSG_ER_VIOLATION_balance_bracket = 'Нарушен баланс скобок';
  MSG_ER_IMPOSSIBLE_SYMBOL = 'Недопустимый символ';

implementation
uses Sysutils, Forms, Windows, gd_createable_form;
{ TVBParser }

procedure TVBParser.AddError(Caption: String; Line: Integer);
{var
  LI: TListItem;}
begin
{  if Assigned(FErrorListView) then
  begin
    LI := FErrorListView.Items.Add;
    Inc(Line);
    LI.Data := Pointer(Line);
    LI.Caption := Caption + '(строка: ' + IntToStr(Line) + ')';
  end;}
end;

constructor TVBParser.Create(AOwner: TComponent);
begin
  inherited;

  FDefiniteVaryList := TStringList.Create;
  FObjects := TStringList.Create;
  FScript := TStringList.Create;
  FArgumentList := TStringList.Create;
  FFieldsList := TStringList.Create;
end;

function TVBParser.DefiniteVary(Name: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to DefiniteVaryList.Count - 1 do
  begin
    if  UpperCase(Name) = UpperCase(DefiniteVaryList[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

destructor TVBParser.Destroy;
begin
  FDefiniteVaryList.Free;
  FObjects.Free;
  FScript.Free;
  FArgumentList.Free;
  FFieldsList.Free;
end;

procedure TVBParser.DoAfterStatament;
begin
  if Assigned(FOnAfterStatament) then
    FOnAfterStatament(FCurrentLine);
end;

procedure TVBParser.DoBeforeStatament;
begin
  if Assigned(FOnBeforeStatament) then
    FOnBeforeStatament(FCurrentLine);
end;

procedure TVBParser.DoExit(P: Integer);
begin

end;

procedure TVBParser.DoProcBegin;
begin

end;

procedure TVBParser.DoProcEnd;
begin

end;

function TVBParser.GetComponentName: String;
begin
  Result := FComponentName;
end;

function TVBParser.GetCurrentWord: String;
var
  BeginPos, EndPos: Integer;
  L: Integer;
begin
{  BeginPos := FCursorPos;
  EndPos := FCursorPos;
  if FStr <> '' then
  begin
    while (Pos(FStr[BeginPos - 1], Letters) > 0) and (BeginPos > 0) do
      Dec(BeginPos);
    while (EndPos <= Length(FStr)) and (Pos(FStr[EndPos], Letters) > 0) do
      Inc(EndPos);
  end;
  if EndPos > BeginPos then
  begin
      Result := System.Copy(FStr, BeginPos, EndPos - BeginPos);
  end else
    Result := '';}

  BeginPos := FCursorPos;
  EndPos := FCursorPos;
  L := Length(FStr);
  while BeginPos > 1 do
  begin
    if FStr[BeginPos - 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
      Dec(BeginPos)
    else
      Break;
  end;
  while (EndPos + 1 <= L) and (L > 0) do
  begin
    if FStr[EndPos + 1] in ['0'..'9','a'..'z', 'A'..'Z', '_'] then
      Inc(EndPos)
    else
      Break;
  end;

  if EndPos >= BeginPos then
    Result := System.Copy(FStr, BeginPos, EndPos - BeginPos + 1)
  else
    Result := '';
end;

function TVBParser.GetDefiniteVaryList: TStrings;
begin
  Result := FDefiniteVaryList;
end;

function TVBParser.GetErrorListView: TListView;
begin
  Result := FErrorListView;
end;

function TVBParser.GetFindComponentString: String;
var
  TmpComp: TComponent;
  Str: string;
begin
  TmpComp := FComponent;
  Str := '';
  while (TmpComp.Owner <> nil) and  (TmpComp.Owner <> Application) do
  begin
    if TmpComp is TCreateableForm then
      Str :=  '.FindComponent("' + TCreateableForm(TmpComp).InitialName + '")' + Str
    else
      Str :=  '.FindComponent("' + TmpComp.Name + '")' + Str;
    TmpComp := TmpComp.Owner;
  end;

  if TmpComp is TCreateableForm then
    Result := 'Application.FindComponent("' + TCreateableForm(TmpComp).InitialName + '")' + Str
  else
    Result := 'Application.FindComponent("' + TmpComp.Name + '")' + Str;
end;

function TVBParser.GetObjects: TStrings;
begin
  Result := FObjects;
end;

function TVBParser.GetOnAfterStatament: TOnStatament;
begin
  Result := FOnAfterStatament;
end;

function TVBParser.GetOnBeforeStatament: TOnStatament;
begin
  Result := FOnBeforeStatament;
end;

function TVBParser.GetParagraph: Integer;
var
  lCurrentLine: Integer;
  Str: String;
begin
  Result := 0;
  lCurrentLine := FCurrentLine;
  if lCurrentLine < FScript.Count then
  begin
    //Пропускаем пустые строки
    while (lCurrentLine < FScript.Count) and (FScript[lCurrentLine] = '') do
      Inc(lCurrentLine);
    //Подсчитываем кол-во пробелов
    if lCurrentLine < FScript.Count then
    begin
      Str := FScript[lCurrentLine];
      while (Str[Result + 1] = ' ') and
        (Result < Length(Str) - 1) do
        Inc(Result);
    end;
  end;
end;

function TVBParser.GetPrepareStr: String;
begin
  if FCurrentLine < FScript.Count then
  begin
    FLineAdd:= 1;
    Result := Trim(FScript[FCurrentLine]);
    //Пропускаем пустые строки
    while (Result = '') and (FCurrentLine < FScript.Count) do
    begin
      Inc(FCurrentLine, FLineAdd);
      if FCurrentLine < FScript.Count then
      begin
        Result := Trim(FScript[FCurrentLine]);
      end;
    end;
    //Если строка состоит из нескольких то сшиваем их
    while (Result <> '') and (Result[Length(Result)] = '_') and
      (FCurrentLine + FLineAdd < FScript.Count) do
    begin
      Delete(Result, Length(Result), 1);
      Result := Result + ' ' + Trim(FScript[FCurrentLine + FLineAdd]);
      Inc(FLineAdd);
    end;
//    Result := UpperCase(Result);
    FCursorPos := 1;
  end else
    Result := '';
end;

function TVBParser.IsAddOp: Boolean;
var
  LStr: string;
begin
  LStr := UpperCase(FStr);
  Delete(LStr, 1, FCursorPos - 1);
  if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '+') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '-') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if Pos('OR',LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end
  else if Pos('XOR',LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else
    Result := False;
end;

function TVBParser.IsArgModificator(Str: String): Boolean;
begin
  Str := UpperCase(Str);
  Result := (Str = 'BYVAL') or (Str = 'BYREF'); 
end;

function TVBParser.IsMulOp: Boolean;
var
  LStr: string;
begin
  LStr := UpperCase(FStr);
  Delete(LStr, 1, FCursorPos - 1);
  if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '*') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '/') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '\') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if Pos('DIV', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else if Pos('MOD', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else if Pos('AND', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else if Pos('SHL', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else if Pos('SHR', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 3);
  end
  else
    Result := False;
end;

function TVBParser.IsObject(Name: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  if Name <> '' then
    for I := 0 to Objects.Count - 1 do
    begin
      if  UpperCase(Name) = UpperCase(Objects[I]) then
      begin
        Result := True;
        Break;
      end;
    end;
end;

function TVBParser.IsRepOp: Boolean;
var
  LStr: String;
begin
  {Вводим локальную строку т.к обрабатываемая строка может содержать несколько
  одинаковых операций а ф. Pos будет возвращать позицию первой}
  LStr := UpperCase(FStr);
  Delete(LStr, 1, FCursorPos - 1);
  if Pos('<=', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end
  else if Pos('>=', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end else if Pos('<>', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end else   if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '=') then
  begin
    Result := True;
    Inc(FCursorPos);
  end
  else if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '>') then
  begin
    Result := True;
    Inc(FCursorPos);
  end else if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '<') then
  begin
    Result := True;
    Inc(FCursorPos);
  end else if Pos('IN', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end else if Pos('IS', LStr) = 1 then
  begin
    Result := True;
    Inc(FCursorPos, 2);
  end else
    Result := False;
end;

function TVBParser.NextWord: Integer;
begin
  Result := FCursorPos;

  Inc(Result);
  while (Result < Length(FStr))
    and ((Pos(FStr[Result - 1], Separators) = 0) or (Pos(FStr[Result], Letters) = 0)) do
  begin
    if FStr[Result] = '"' then
    begin
      Inc(Result);
      while (Result < Length(FStr)) and (FStr[Result] <> '"') do
      begin
        Inc(Result);
      end;
      if FStr[Result] = '"' then
        Inc(Result);
    end else
      Inc(Result);
  end;
  if Result > Length(FStr) then
    Result := -1;
end;

procedure TVBParser.PrepareScript(const ScriptName: String;
  const Script: TStrings; AtLine: Integer = - 1);
begin
  FScript.Assign(Script);
  FInFunction := False;
  FScriptName := ScriptName;
  FAtLine := AtLine;
  FProcedureId := 0;
  FLineAdd := 0;
  FInClass := False;
  FCurrentLine := 0;
  try
    while (FCurrentLine < FScript.Count) and ((AtLine  = - 1) or
      (FCurrentLine <= AtLine)) do
    begin
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
      Statament;
    end;
    Script.Assign(FScript);
  except
//    MessageBox(Application.Handle, 'Подготовка не возможна из-за ошибок в коде',
//      'Ошибка', MB_OK or MB_ICONERROR or MB_TASKMODAL);
  end;
end;

procedure TVBParser.SetComponentName(const Value: String);
begin
  FComponentName := Value;
end;

procedure TVBParser.SetErrorListView(const Value: TListView);
begin
  FErrorListView := Value;
end;

procedure TVBParser.SetExecutable;
begin
end;

procedure TVBParser.SetIsEvent(const Value: Boolean);
begin
  FIsEvent := Value;
end;

procedure TVBParser.SetOnAfterStatament(const Value: TOnStatament);
begin
  FOnAfterStatament := Value;
end;

procedure TVBParser.SetOnBeforeStatament(const Value: TOnStatament);
begin
  FOnBeforeStatament := Value;
end;

procedure TVBParser.SimpleStatement;
begin
  TrimSpace;
  FAddDesignator := True;
  try
    FDesignator := '';
    WorkDesignator;
  finally
    FAddDesignator := False;
  end;  
  TrimSpace;
  if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '=') then
  begin
    Inc(FCursorPos);
    WorkExpression;
  end else
    FDesignator:= '';
end;

procedure TVBParser.Statament;
var
  CurrentWord: String;
  ObjectVar: String;
  DropDesignator: boolean;
  P: Integer;
begin
  DoBeforeStatament;
  CurrentWord := UpperCase(GetCurrentWord);
  if (CurrentWord = 'PUBLIC') then
  begin
    FCursorPos := NextWord;
    if FInClass then
    begin
      CurrentWord := UpperCase(GetCurrentWord);
      if (CurrentWord = 'DEFAULT') then
        FCursorPos := NextWord;
    end;
    if FInClass and not FInFunction then
    begin
      CurrentWord := UpperCase(GetCurrentWord);
      if (CurrentWord <> 'PROPERTY') and (CurrentWord <> 'SUB') and
        (CurrentWord <> 'FUNCTION') then
      begin
        FFieldsList.Add(CurrentWord);
        Inc(FCurrentLine, FLineAdd);
      end else
        Statament;
    end else
      Statament;
  end else
  if (CurrentWord = 'PRIVATE') then
  begin
    FCursorPos := NextWord;
    if FInClass and not FInFunction then
    begin
      CurrentWord := UpperCase(GetCurrentWord);
      if (CurrentWord <> 'PROPERTY') and (CurrentWord <> 'SUB') and
        (CurrentWord <> 'FUNCTION') then
      begin
        FFieldsList.Add(CurrentWord);
        Inc(FCurrentLine, FLineAdd);
      end else
        Statament;
    end else
      Statament;
  end else
  if CurrentWord = 'SET' then
  begin
    FCursorPos := 1;
    TrimSpace;
    if UpperCase(GetCurrentWord) = 'SET' then
    begin
      SetExecutable;
      FCursorPos := NextWord;
      ObjectVar := GetCurrentWord;
      DropDesignator := False;
      if FStr[FCursorPos + Length(ObjectVar)] <> '.' then
      begin
        if IsObject(ObjectVar) and not DefiniteVary(ObjectVar) then
        begin
          DefiniteVaryList.Add(ObjectVar);
        end;
      end else
        DropDesignator :=True;
      SimpleStatement;
      if DropDesignator then
        Fdesignator := '';
      DoAfterStatament;
      Inc(FCurrentLine, FLineAdd);
    end;
  end
  else if CurrentWord ='CALL' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    SimpleStatement;
    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
  end
  else if CurrentWord = 'DO' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    CurrentWord := UpperCase(GetCurrentWord);
    if (CurrentWord = 'WHILE') or (CurrentWord = 'UNTIL') then
    begin
      FCursorPos := NextWord;
      WorkExpression;
      DoAfterStatament;
    end;
    if (FCurrentLine < FScript.Count) then
    begin
      Inc(FCurrentLine, FLineAdd);
      FStr := GetPrepareStr;
      CurrentWord := UpperCase(GetCurrentWord);
      while (CurrentWord <> 'LOOP') and (CurrentWord <> 'WEND') and
        (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FStr := GetPrepareStr;
        CurrentWord := UpperCase(GetCurrentWord);
      end;
      if CurrentWord = 'LOOP' then
      begin
        FCursorPos := NextWord;
        if (CurrentWord = 'WHILE') or (CurrentWord = 'UNTIL') then
        begin
          FCursorPos := NextWord;
          WorkExpression;
          DoAfterStatament;
        end;
      end else
         Abort;
//         AddError(MSG_ER_NOT_FIND_END_OF_STATAMENT  ,FCurrentLine);
      Inc(FCurrentLine, FLineAdd);
    end;
  end
  else if CurrentWord = 'WHILE' then
  begin
    FCursorPos := NextWord;
    WorkExpression;
    DoAfterStatament;

    if (FCurrentLine < FScript.Count) then
    begin
      Inc(FCurrentLine, FLineAdd);
      FStr := GetPrepareStr;
      CurrentWord := UpperCase(GetCurrentWord);
      while (CurrentWord <> 'WEND') and
        (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FStr := GetPrepareStr;
        CurrentWord := UpperCase(GetCurrentWord);
      end;
      if CurrentWord <> 'WEND' then
         Abort;
//         AddError(MSG_ER_NOT_FIND_END_OF_STATAMENT  ,FCurrentLine);
      Inc(FCurrentLine, FLineAdd);
    end
  end
  else if CurrentWord = 'EXECUTE' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    Statament;
  end
  else if CurrentWord = 'EXECUTEGLOBAL' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    Statament;
  end
  else if CurrentWord = 'EXIT' then
  begin
    SetExecutable;
    P := FCursorPos;
    FCursorPos := NextWord;
    CurrentWord := UpperCase(GetCurrentWord);
    if (CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION') or
      (CurrentWord = 'PROPERTY') then
    begin
//      FInFunction := False;
//      FCursorPos := P;
      DoExit(P);
    end;
    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
  end
  else if CurrentWord = 'FOR' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    SimpleStatement;
    TrimSpace;
    if UpperCase(GetCurrentWord) = 'TO' then
    begin
      FCursorPos := NextWord;
      WorkSimpleExpression;
    end;
    if UpperCase(GetCurrentWord) = 'STEP' then
    begin
      FCursorPos := NextWord;
      WorkSimpleExpression;
    end;
    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
    FStr := GetPrepareStr;
    while (UpperCase(GetCurrentWord) <> 'NEXT') and (FCurrentLine < FScript.Count) do
    begin
      Statament;
      FStr := GetPrepareStr;
    end;
    if UpperCase(GetCurrentWord) <> 'NEXT' then
    begin
      Abort;
//      AddError(MSG_ER_NOT_FIND_END_OF_STATAMENT,FCurrentLine);
    end;
    if (FCurrentLine < FScript.Count) then
      Inc(FCurrentLine, FLineAdd);
  end
  else if CurrentWord = 'IF' then
  begin
    SetExecutable;
    FCursorPos := FCursorPos + Length('IF');
    TrimSpace;
    WorkExpression;

    TrimSpace;
    if  UpperCase(GetCurrentWord) = 'THEN' then
    begin
      FCursorPos := NextWord;
      if FCursorPos = - 1 then
      begin
        //Оператор записан в одну строку
        DoAfterStatament;
        Inc(FCurrentLine, FLineAdd);
        FStr := GetPrepareStr;
        while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
        begin
          Statament;
          FStr := GetPrepareStr;
          if (UpperCase(GetCurrentWord) = 'ELSEIF') and (FCurrentLine < FScript.Count) then
          begin
            FCursorPos := FCursorPos + Length('ELSEIF');
            TrimSpace;
            WorkExpression;
            Inc(FCurrentLine, FLineAdd);
            FStr := GetPrepareStr;
          end else
          if (UpperCase(GetCurrentWord) = 'ELSE') and (FCurrentLine < FScript.Count) then
          begin
            Inc(FCurrentLine, FLineAdd);
            FStr := GetPrepareStr;
          end;
        end;
        if UpperCase(GetCurrentWord) <> 'END' then
        begin
          FCursorPos := NextWord;
          if UpperCase(GetCurrentWord) <> 'IF' then
          begin
 //           AddError(MSG_ER_NOT_FIND_END_OF_STATAMENT,FCurrentLine);
            Abort;
          end
        end;
        if (FCurrentLine < FScript.Count) then
         Inc(FCurrentLine, FLineAdd);
      end else
      begin
        Statament;
        //!!! 13/11/2002
//        SimpleStatement;
//        DoAfterStatament;
//        Inc(FCurrentLine, FLineAdd);
        //!!!
      end;
    end else
    begin
      Abort;
//      AddError(MSG_ER_NOT_FIND_THEN, FCurrentLine);
    end
  end
  else if CurrentWord = 'SELECT' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    If UpperCase(GetCurrentWord) = 'CASE' then
      FCursorPos := NextWord;
    WorkSimpleExpression;

    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
    FStr := GetPrepareStr;
    while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
    begin
      CurrentWord := UpperCase(GetCurrentWord);
      if CurrentWord = 'CASE' then
      begin
        FCursorPos := NextWord;
        if UpperCase(GetCurrentWord) = 'ELSE' then
          FCursorPos := NextWord;
        WorkExprList;
      end;
      Inc(FCurrentLine, FLineAdd);
      FStr := GetPrepareStr;
      CurrentWord := UpperCase(GetCurrentWord);
      while (CurrentWord <> 'END') and (CurrentWord <> 'CASE') and
        (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FParagraph := GetParagraph;
        FInsertLine := FCurrentLine;
        FStr := GetPrepareStr;
        CurrentWord := UpperCase(GetCurrentWord);
      end;
    end;
    if FCurrentLine < FScript.Count then
      Inc(FCurrentLine, FLineAdd);
  end
  else if CurrentWord = 'WITH' then
  begin
    SetExecutable;
    FCursorPos := NextWord;
    WorkDesignator;
    DoAfterStatament;
    Inc(FCurrentLine, FLineAdd);
    FStr := GetPrepareStr;
    while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
    begin
      Statament;
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
    end;
    if UpperCAse(GetCurrentWord) <> 'END' then
    begin
      FCursorPos := NextWord;
      if UpperCase(GetCurrentWord) <> 'WITH' then
        Abort;
//        AddError(MSG_ER_NOT_FIND_END_OF_STATAMENT ,FCurrentLine);
    end;
    if FCurrentLine < FScript.Count then
      Inc(FCurrentLine, FLineAdd);
  end else
  if ((CurrentWord = 'SUB') or (CurrentWord = 'FUNCTION')) and
     (FCurrentLine < FScript.Count) then
  begin
    if not FInFunction then
    begin
      Inc(FProcedureId);
      DefiniteVaryList.Clear;
      FInFunction := True;
      FSubFunction := CurrentWord;
      FCursorPos := NextWord;
      //Имя процедуры
      FFunctionName := GetCurrentWord;
      FCursorPos := FCursorPos + Length(FFunctionName);
      TrimSpace;

      FArgumentList.Clear;
      //Обрабатываем список аргументов
      if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '(') then
      begin
        Inc(FCursorPos);
        WorkArgumentList;
        TrimSpace;
        if (FCursorPos > Length(FStr)) or (FStr[FCursorPos] <> ')') then
          Abort;
//          AddError(MSG_ER_VIOLATION_balance_bracket, FCurrentLine);
      end;

      DoProcBegin;
      Inc(FCurrentLine, FLineAdd);
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
      while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FParagraph := GetParagraph;
        FInsertLine := FCurrentLine;
        FStr := GetPrepareStr;
      end;
      if UpperCase(GetCurrentWord) = 'END' then
      begin
        FCursorPos := NextWord;
        if (UpperCase(GetCurrentWord) = 'SUB') or
          (UpperCase(GetCurrentWord) = 'FUNCTION') then
        begin
          SetExecutable;
          DoProcEnd;
          DoAfterStatament;
          FInFunction := False;
          Inc(FCurrentLine);
        end else
          Abort;
      end else
        Abort;
    end else
    begin
      Inc(FCurrentLine, FLineAdd);
      Abort;
    end;
  end else
  if (CurrentWord = 'PROPERTY') and (FCurrentLine < FScript.Count) then
  begin
    if not FInFunction then
    begin
      Inc(FProcedureId);
      DefiniteVaryList.Clear;
      FInFunction := True;
      FSubFunction := CurrentWord;
      FCursorPos := NextWord;
      CurrentWord := UpperCase(GetCurrentWord);
      //Тип спойства
      if (CurrentWord <> 'GET') and (CurrentWord <> 'LET') and
         (CurrentWord <> 'SET') then
        Exit;
      FCursorPos := NextWord;
      //Имя свойства
      FFunctionName := GetCurrentWord;
      FCursorPos := FCursorPos + Length(FFunctionName);
      TrimSpace;

      FArgumentList.Clear;
      //Обрабатываем список аргументов
      if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '(') then
      begin
        Inc(FCursorPos);
        WorkArgumentList;
        TrimSpace;
        if (FCursorPos > Length(FStr)) or (FStr[FCursorPos] <> ')') then
          AddError(MSG_ER_VIOLATION_balance_bracket, FCurrentLine);
      end;

      DoProcBegin;
      Inc(FCurrentLine, FLineAdd);
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
      while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FParagraph := GetParagraph;
        FInsertLine := FCurrentLine;
        FStr := GetPrepareStr;
      end;
      if UpperCAse(GetCurrentWord) = 'END' then
      begin
        FCursorPos := NextWord;
        if UpperCase(GetCurrentWord) = 'PROPERTY' then
        begin
          SetExecutable;
          DoProcEnd;
          DoAfterStatament;
          FInFunction := False;
          Inc(FCurrentLine);
        end else
          Abort;
          //AddError(MSG_ER_NOT_FIND_FUNCTION_END, FCurrentLine);
          //raise Exception.Create(MSG_ER_NOT_FIND_FUNCTION_END);
      end else
        Abort;
        //AddError(MSG_ER_NOT_FIND_FUNCTION_END, FCurrentLine)
        //raise Exception.Create(MSG_ER_NOT_FIND_FUNCTION_END);
    end else
    begin
      Inc(FCurrentLine, FLineAdd);
      Abort;
//      AddError(MSG_ER_NOT_ALLOW_TAKE_UP_FUNCTION, FCurrentLine);
      //raise Exception.Create(MSG_ER_NOT_ALLOW_TAKE_UP_FUNCTION);
    end;
  end else
  if (CurrentWord = 'CLASS') and (FCurrentLine < FScript.Count) then
  begin
    if not FInClass then
    begin
      DefiniteVaryList.Clear;
      FFieldsList.Clear;
      FInClass := True;
      FCursorPos := NextWord;
      //Имя класса
      FClassName := GetCurrentWord;
      Inc(FCurrentLine, FLineAdd);
      FParagraph := GetParagraph;
      FInsertLine := FCurrentLine;
      FStr := GetPrepareStr;
      while (UpperCase(GetCurrentWord) <> 'END') and (FCurrentLine < FScript.Count) do
      begin
        Statament;
        FParagraph := GetParagraph;
        FInsertLine := FCurrentLine;
        FStr := GetPrepareStr;
      end;
      if UpperCase(GetCurrentWord) = 'END' then
      begin
        FCursorPos := NextWord;
        if UpperCase(GetCurrentWord) = 'CLASS' then
        begin
          FInClass := False;
          Inc(FCurrentLine);
        end else
          Abort;
          //raise Exception.Create('Нет END CLASS');
      end
    end else
    begin
      Inc(FCurrentLine, FLineAdd);
    end;
  end else
  begin
 //   if FInFunction then
 //   begin
    SimpleStatement;
    DoAfterStatament;
 //   end;
    Inc(FCurrentLine, FLineAdd);
  end;
 FDesignator := '';
end;

procedure TVBParser.TrimSpace;
begin
  while (FCursorPos < Length(FStr) - 1) and ((FStr[FCursorPos] = ' ') or
    (FStr[FCursorPos] = #10) or (FStr[FCursorPos] = #13))do
    Inc(FCursorPos);
end;

procedure TVBParser.WorkArgument;
var
  CurrentWord: String;
begin
  TrimSpace;
  CurrentWord := GetCurrentWord;
  if IsArgModificator(CurrentWord) then
    FCursorPos := NextWord;
  if Length(FStr) < FCursorPos then
    Exit;

  CurrentWord := GetCurrentWord;
  FArgumentList.Add(CurrentWord);
  if FIsEvent then
    FSenderAllocated := UpperCase(CurrentWord) = 'SENDER'; 
  FCursorPos := FCursorPos + Length(CurrentWord)
  { TODO :
  В ВБ после имени аргумента могут следовать скобки.
  Необходимо это реализовать }
end;

procedure TVBParser.WorkArgumentList;
begin
  TrimSpace;
  WorkArgument;
  TrimSpace;
  while (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = ',') do
  begin
    Inc(FCursorPos);
    WorkArgument;
    TrimSpace;
  end;
end;

procedure TVBParser.WorkDesignator;
var
  ObjectVar: String;
begin
  if (FCursorPos <= Length(FStr)) and (Pos(FStr[FCursorPos], Letters + '''') = 0) then
    AddError(MSG_ER_IMPOSSIBLE_SYMBOL, FCurrentLine);
  ObjectVar := GetCurrentWord;
  if ObjectVar = '' then Exit;
  SetExecutable;

  if FAddDesignator then
  begin
    FDesignator := ObjectVar;
    FAddDesignator := False;
  end;

  if IsObject(ObjectVar) then
  begin
    if not DefiniteVary(ObjectVar) then
    begin
      FScript.Insert(FInsertLine, StringOfChar(' ', FParagraph) + MSG_ADD_WITH_PARSER);
      if FIsEvent and FSenderAllocated then
      begin
        if ObjectVar = UpperCase(FComponentName) then
        begin
          FScript.Insert(FInsertLine + 1,
            StringOfChar(' ', FParagraph) +
            'set ' + ObjectVar + ' = ' + 'Sender.OwnerForm.GetComponent("' +
            ObjectVar + '")');
        end else
        begin
          FScript.Insert(FInsertLine + 1,
            StringOfChar(' ', FParagraph) +
            'set ' + ObjectVar + ' = ' + 'Sender.OwnerForm.GetComponent("' +
            ObjectVar + '")');
        end;
      end else
      begin
        FScript.Insert(FInsertLine + 1,
          StringOfChar(' ', FParagraph) +
          'set ' + ObjectVar + ' = ' + GetFindComponentString +
          '.GetComponent("' + ObjectVar + '")');
      end;
      FScript.Insert(FInsertLine + 1,
        StringOfChar(' ', FParagraph) +
        'dim ' + ObjectVar);
      Inc(FCurrentLine, 3);
      Inc(FInsertLine, 3);
      DefiniteVaryList.Add(ObjectVar);
    end;
  end;

  if FStr <> '' then
  begin
    while (FCursorPos <= Length(FStr)) and (Pos(FStr[FCursorPos], Letters + '.') > 0) do
      Inc(FCursorPos);

    TrimSpace;
    if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '(') then
    begin
      Inc(FCursorPos);
      WorkExprList;
      TrimSpace;
      if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = ')') then
      begin
        Inc(FCursorPos);
        if (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = '.') then
        begin
          Inc(FCursorPos);
          WorkDesignator;
        end;
      end else
        AddError(MSG_ER_VIOLATION_balance_bracket, FCurrentLine);
    end
  end;
end;

procedure TVBParser.WorkExpression;
begin
  WorkSimpleExpression;
  TrimSpace;
  while IsRepOp do
  begin
    WorkSimpleExpression;
    TrimSpace;
  end;
end;

procedure TVBParser.WorkExprList;
begin
  TrimSpace;
  WorkExpression;
  TrimSpace;
  while (FCursorPos <= Length(FStr)) and (FStr[FCursorPos] = ',') do
  begin
    Inc(FCursorPos);
    WorkExpression;
    TrimSpace;
  end;
end;

procedure TVBParser.WorkFactor;
var
  LStr: String;
begin
  TrimSpace;
  LStr := UpperCase(FStr);
  Delete(LStr, 1, FCursorPos - 1);
  if Pos('NOT', LStr) = 1 then
  begin
    FCursorPos := NextWord;
    WorkFactor;
  end else
  if Pos('NULL', LStr) = 1 then
    Exit
  else if Pos(FStr[FCursorPos], Numbers) > 0 then
    //Обработка числа
    while (FCursorPos < Length(FStr)) and (Pos(FStr[FCursorPos], Numbers) > 0) do
      Inc(FCursorPos)
  else if Pos(FStr[FCursorPos], Letters) > 0 then
    WorkDesignator
  else if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = '"') then
  begin
    //Обработка стринга
    Inc(FCursorPos);
    while (FCursorPos < Length(FStr)) and (FStr[FCursorPos] <> '"') do
      Inc(FCursorPos);
    if (FCursorPos < Length(FStr)) then
      Inc(FCursorPos);
  end
  else if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = '(') then
  begin
    Inc(FCursorPos);
    WorkExpression;
    TrimSpace;
     if (FCursorPos < Length(FStr)) and (FStr[FCursorPos] = ')') then
      Inc(FCursorPos)
    else
      AddError(MSG_ER_VIOLATION_balance_bracket, FCurrentLine);
  end;
end;

procedure TVBParser.WorkSimpleExpression;
begin
  TrimSpace;
  if (FCursorPos <= Length(FStr)) and (Pos(FStr[FCursorPos], '+-') > 0) then
    Inc(FCursorPos);
  WorkTerm;
  TrimSpace;
  while IsAddOp do
  begin
    WorkTerm;
    TrimSpace;
  end;
end;

procedure TVBParser.WorkTerm;
begin
  TrimSpace;
  WorkFactor;
  TrimSpace;
  while IsMulOp do
  begin
    WorkFactor;
    TrimSpace;
  end;
end;

{ TCustomParser }

function TCustomParser.GetComponent: TComponent;
begin
  Result := FComponent;
end;

procedure TCustomParser.SetComponent(const Value: TComponent);
begin
  FComponent := Value;
end;

end.
