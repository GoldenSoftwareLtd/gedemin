unit amc_Base;

interface

uses
  Classes;

const
  amcClass  = ' CLASS(';
  amcClass2  = '=CLASS(';
  amcProc    = 'PROCEDURE';
  amcFunc    = 'FUNCTION';
  amcClassPF   = 'CLASS';
  amcPoint   = '.';
  amcBegin   = 'BEGIN';
  amcEnd     = 'END';
  amcFinal   = 'FINALIZATION';
  amcInitial = 'INITIALIZATION';
  amcEndEnd  = 'END.';
  amcVar     = 'VAR';

type
  TamcExecType = (amcAdd, amcDelete);

type
  TamcClassFileList = class;

  TamcObject = class(TObject)
  private
    FClassFileList: TamcClassFileList;
    FClassList: TStrings;
    FBaseClass: String;
//    FMethod: String;
    FParamsMethod: String;
    FBeginMethod: String;
    FEndMethod: String;
    FErrorLog: TStrings;
    FMethods: TStrings;

  public
    constructor Create;
    destructor  Destroy; override;

    procedure SearchClassHierarchy(APath: String);

    function  AddMacroCall(const ExecType: TamcExecType): Boolean;

    // Хранится список имен всех файлов, в которых
    // обнаружены наследники базового класса,
    // для каждого файла хранится список классов-наследников
    property  ClassFileList: TamcClassFileList read FClassFileList;
    property  ClassList: TStrings read FClassList;
    property  BaseClass: String read FBaseClass write FBaseClass;
//    property  Method: String read FMethod write FMethod;
    property  ParamsMethod: String read FParamsMethod write FParamsMethod;
    property  BeginMethod: String read FBeginMethod write FBeginMethod;
    property  EndMethod: String read FEndMethod write FEndMethod;
    property  ErrorLog: TStrings read FErrorLog;
    property  Methods: TStrings read FMethods write FMethods;
  end;

  // Класс для хранения списка имен всех файлов с классыми
  TamcClassFileList = class(TStringList)
  private
    FClassList: TStrings;

    function  GetClassList(Index: Integer): TStrings;

    procedure SetClassList(Index: Integer; Value: TStrings);
  public
    constructor Create;

    function  AddFile(const AFileName: String): Integer;
    function  AddClass(const AFileName, AClassName: String): Integer;

    property  ClassList[Index: Integer]: TStrings read GetClassList write SetClassList;
  end;

implementation

uses
  JclFileUtils, SysUtils, Windows, JclStrings, gdStrings, Dialogs,
  frm_AddGaude, amc_MainForm;

{ TamcObject }

function TamcObject.AddMacroCall(const ExecType: TamcExecType): Boolean;
var
  FileText: TStrings;
  i, k, n, j, v, m, s,
    EndPos, BeginSymbol, parPos: Integer;
  str, parPar, FirstSym: String;
  Saving, ErrorFlag: Boolean;

  procedure fff;
    procedure ddd;
      begin
      end;
  begin
  end;

  function FindEndPos(AFileText: TStrings; var ABeginPos,
    AParamPos: Integer; out AVarStr: String): Integer;
  var
    ei, en, eBeginCount, eBeginSymbol, ep, ef: Integer;
    estr, ev: String;
    varFlag: Boolean;
  begin
    Result := -1;
    // ищем начало метода
    eBeginCount := -1;
    Inc(ABeginPos);
    eBeginSymbol := 0;
    AParamPos := 0;
    AVarStr := '';
    varFlag := True;
    while ABeginPos < AFileText.Count do
    begin
      estr := StrWithoutComment(AFileText, ABeginPos, en, eBeginSymbol, True);
      if (TestOnFirstFullWord(amcVar, Trim(estr))) and (varFlag) then
      begin
        AParamPos := ABeginPos + 1;
        AVarStr := '';
        varFlag := False;
      end else
        if TestOnFirstFullWord(amcBegin, Trim(estr)) then
        begin
          eBeginCount := 1;
          if varFlag then
          begin
            AParamPos := ABeginPos;
            AVarStr := 'var';
          end;
          Break;
        end else
          if TestOnFirstFullWord(amcProc, Trim(estr)) then
          begin
            ef := ABeginPos;
            ei := FindEndPos(AFileText, ABeginPos, ep, ev);
            if varFlag then
              begin
                AParamPos := ef;
                AVarStr := 'var';
              end;
            en := ei;
          end else
            if TestOnFirstFullWord(amcFunc, Trim(FileText[ABeginPos])) then
            begin
              ef := ABeginPos;
              ei := FindEndPos(AFileText, ABeginPos, ep, ev);;
              if varFlag then
                begin
                  AParamPos := ef;
                  AVarStr := 'var';
                end;
              en := ei;
            end;
      ABeginPos := en;
    end;

    // ищем последний end метода
    eBeginSymbol := 0;
    if eBeginCount = 1 then
    begin
      ei := ABeginPos;
      eBeginCount := 0;
      while ei < AFileText.Count do
      begin
        estr := StrWithoutComment(AFileText, ei, en, eBeginSymbol, True);
        eBeginCount := eBeginCount + BeginCountInStr(estr);
        eBeginCount := eBeginCount - EndCountInStr(estr);
        if eBeginCount = 0 then
        begin
          Result := ei;
          Break;
        end;
        if eBeginCount < 0 then
          raise Exception.Create('Не могу определить конец логического блока.');
        ei := en;
      end;
    end;
  end;

begin
  Result := False;
  if Methods.Count = 0 then
  begin
    MessageBox(0, 'Необходимо задать имя метода', 'Ошибка',
      mb_Ok or MB_IconError or MB_TASKMODAL);
    Exit;
  end;
  if ExecType = amcAdd then
  begin
    if (Trim(ParamsMethod) = '') and (frmAddMacroCall.cbParam.Checked) then
    begin
      MessageBox(0, 'Необходимо задать имя макроса параметров', 'Ошибка',
        mb_Ok or MB_IconError or MB_TASKMODAL);
      Exit;
    end;
    if (Trim(BeginMethod) = '') and (frmAddMacroCall.cbBegin.Checked) then
    begin
      MessageBox(0, 'Необходимо задать имя первого макроса', 'Ошибка',
        mb_Ok or MB_IconError or MB_TASKMODAL);
      Exit;
    end;
    if (Trim(EndMethod) = '') and (frmAddMacroCall.cbEnd.Checked) then
    begin
      MessageBox(0, 'Необходимо задать имя заключительного макроса', 'Ошибка',
        mb_Ok or MB_IconError or MB_TASKMODAL);
      Exit;
    end;
  end;

  FileText := TStringList.Create;
  i := 0;
  m := 0;
  j := 0;
  try
    try
      frmAddGaude.Gauge1.MinValue := 0;
      frmAddGaude.Gauge1.MaxValue := ClassFileList.Count;
      m := 0;
      while m < Methods.Count do
//      for m := 0 to Methods.Count - 1 do
      begin
        if Length(Trim(Methods[m])) = 0 then
        begin
          Inc(m);
          Continue;
        end;
        case ExecType of
        amcAdd:
          begin
            if MessageDlg('Добавить в метод ' + Methods[m] + ' макросы'#10#13 +
              ParamsMethod + #10#13 + BeginMethod + #10#13 + EndMethod,
              mtWarning, [mbOK, mbCancel], 0) <> idOk then
            begin
              Inc(m);
              Continue;
            end;
          end;
        amcDelete:
          begin
            if MessageDlg('Удалить из метода ' + Methods[m] +
              ' вызовы макросов'#10#13 + ParamsMethod + #10#13 +
              BeginMethod + #10#13 + EndMethod,
              mtWarning, [mbOK, mbCancel], 0) <> idOk then
            begin
              Inc(m);
              Continue;
            end;
          end;
        end;
        frmAddGaude.Show;
        i := 0;
        while i < ClassFileList.Count do
//        for i := 0 to ClassFileList.Count - 1 do
        begin
          Saving := False;
          FileText.LoadFromFile(ClassFileList[i]);
          k := 0;
          BeginSymbol := 0;
          while k < FileText.Count do
          begin
            str := FileText[k];
            EndPos := -1;
            n := -1;
            for j := 0 to ClassFileList.ClassList[i].Count - 1 do
            begin
              if (SubStrCount(ClassFileList.ClassList[i][j] + amcPoint + Methods[m], str) = 1) then
              begin
                str :=  StrWithoutComment(FileText, k, n, BeginSymbol, True);
                FirstSym := Copy(StrAfter(ClassFileList.ClassList[i][j] +
                  amcPoint + Methods[m], str), 1, 1);
                if (SubStrCount(ClassFileList.ClassList[i][j] + amcPoint + Methods[m], str) = 1) and
                  (TestOnFirstFullWord(amcProc, Trim(UpperCase(str))) or
                  TestOnFirstFullWord(amcFunc, Trim(UpperCase(str))) or
                  (TestOnFirstFullWord(amcClassPF, Trim(UpperCase(str))) and
                   (TestOnFirstFullWord(amcProc, Trim(UpperCase(Copy(str,
                      Pos(amcClassPF, UpperCase(Str)) + 6, Length(Str))))) or
                    TestOnFirstFullWord(amcFunc, Trim(UpperCase(Copy(str,
                      Pos(amcClassPF, UpperCase(Str)) + 6, Length(Str)))))
                    )
                   )
                  ) and
                  ((FirstSym = '(') or (FirstSym = ' ') or
                  (FirstSym = ';') or (FirstSym = ':')) then
                begin
                  s := k;
                  EndPos := FindEndPos(FileText, k, parPos, parPar);
                  // если начало и конец метода найдены
                  if (EndPos > -1) and (k < EndPos) then
                  begin
                    case ExecType of
                    amcAdd:
                      begin
                        // а может в методе уже есть макрос
                        ErrorFlag := False;
                        for v := k to EndPos do
                        begin
                          if (Pos('{@CALL', Trim(FileText[v])) = 1) or
                            (Pos('{@UNFOLD', Trim(FileText[v])) = 1) then
                          begin
                            ErrorLog.Add('В файл ' + ClassFileList[i] + ' метод ' +
                              ClassFileList.ClassList[i][j] + amcPoint + Methods[m] +
                              ' вызов не добавлен. ');
                            ErrorLog.Add(' Обнаружена строка ' + FileText[v]);
                          ErrorFlag := True;
                          end;
                        end;
                        if ErrorFlag then
                          Break;
                        FileText.Insert(EndPos, '  {@CALL MACRO ' + EndMethod +
                          '(''' + ClassFileList.ClassList[i][j] + ''', ''' +
                          UpperCase(Methods[m]) + ''', key' + UpperCase(Methods[m]) + ')}');
                        FileText.Insert(k + 1, '  {@CALL MACRO ' + BeginMethod +
                          '(''' + ClassFileList.ClassList[i][j] + ''', ''' +
                          UpperCase(Methods[m]) + ''', key' + UpperCase(Methods[m]) + ')}');
                        FileText.Insert(parPos, '  {@CALL MACRO ' + ParamsMethod +
                          '(' + parPar + ')}');
                        Saving := True;
                        Break;
                      end;
                    amcDelete:
                      begin
                        for v := EndPos downto s do
                          if (Pos('{@CALL', Trim(FileText[v])) = 1) then
                          begin
                            FileText.Delete(v);
                            Saving := True;
                          end;
                      end;
                    end;
                  end;
                end;
              end;
            end;
            if EndPos > n then
            begin
              if EndPos > k then
                k := EndPos
              else
                Inc(k);
            end else
              begin
                if n > k then
                  k := n
                else
                  Inc(k);
              end;
          end;
          BeginSymbol := 0;
          if Saving then
            FileText.SaveToFile(ClassFileList[i]);
          frmAddGaude.Gauge1.Progress := i;
          Inc(i);
        end;
        Inc(m);
        frmAddGaude.Close;
      end;
    except
      on E: Exception do
        MessageBox(0, PChar(E.Message + ''#10#13 +
          'Файл: ' + ClassFileList[i] + ', для ' +
          ClassFileList.ClassList[i][j] + amcPoint + Methods[m]), 'Ошибка',
          MB_OK or MB_ICONERROR or MB_TOPMOST);

    end;
  finally
    FileText.Free;
  end;
end;

constructor TamcObject.Create;
begin
  FClassFileList := TamcClassFileList.Create;
  FClassList := TStringList.Create;
  FErrorLog := TStringList.Create;
  FMethods := TStringList.Create;
end;

destructor TamcObject.Destroy;
begin
  FClassFileList.Free;
  FClassList.Free;

  ErrorLog.SaveToFile('gdAddMacroCall.log');
  FErrorLog.Free;
  FMethods.Free;

  inherited;
end;

procedure TamcObject.SearchClassHierarchy(APath: String);
var
  FileList, FileText, DeclClassList: TStrings;
  i, k, j: Integer;
  TempStr, NextClass: String;
begin
  if Trim(BaseClass) = '' then
  begin
    MessageBox(0, 'Необходимо задать имя класса', 'Ошибка',
      mb_Ok or MB_IconError or MB_TASKMODAL);
    Exit;
  end;

  ClassList.Clear;
  ClassList.Add(UpperCase(Trim(BaseClass)));
  FileList := TStringList.Create;
  try
    ClassFileList.Clear;
    if not AdvBuildFileList(APath + '\*.pas',
      faAnyFile, FileList, [flRecursive, flFullNames]) then
    begin
      MessageBox(0, 'Не удалось создать список файлов', 'Ошибка',
        mb_Ok or MB_IconError or MB_TASKMODAL);
      exit;
    end;

    // создается список файлов, в которых есть объявление класса
    FileText := TStringList.Create;
    try
      i := 0;
      while i < FileList.Count do
      begin
        FileText.Clear;
        FileText.LoadFromFile(FileList[i]);
        FileList.Objects[i] := TStringList.Create;
        for k := 0 to FileText.Count - 1 do
        begin
          if ((SubStrCount(amcClass, UpperCase(FileText[k])) = 1) or
            (SubStrCount(amcClass2, UpperCase(FileText[k])) = 1) ) and
            (Pos('{',  Trim(FileText[k])) <> 1) and
            (Pos('//', Trim(FileText[k])) <> 1) and
            (Pos('(*', Trim(FileText[k])) <> 1) then
          begin
            if (Pos('{',  UpperCase(Trim(FileText[k]))) > 1) then
            begin
              TStrings(FileList.Objects[i]).Add(StrBefore('{', FileText[k]));
            end else
              if (Pos('//',  UpperCase(Trim(FileText[k]))) > 1) then
              begin
                TStrings(FileList.Objects[i]).Add(StrBefore('//',  FileText[k]));
              end else
                if (Pos('(*',  UpperCase(Trim(FileText[k]))) > 1) then
                begin
                  TStrings(FileList.Objects[i]).Add(StrBefore('(*',  FileText[k]));
                end else
                  TStrings(FileList.Objects[i]).Add(FileText[k]);
            if SubStrCount('=',
              TStrings(FileList.Objects[i])[TStrings(FileList.Objects[i]).Count - 1]) <> 1 then
              TStrings(FileList.Objects[i]).Delete(TStrings(FileList.Objects[i]).Count - 1);

          end;
        end;
        if TStrings(FileList.Objects[i]).Count = 0 then
          FileList.Delete(i)
        else
          Inc(i);
      end;

      // поиск в списке объявления классов
       // всех наследников базового класса
//      ClassFileList.AddClass(, BaseClass);
      while (FileList.Count > 0) and  (ClassList.Count > 0) do
      begin
        while ClassList.Count > 0 do
        begin
          i := 0;
          while i < FileList.Count do
          begin
            DeclClassList := TStrings(FileList.Objects[i]);
            j := 0;
            while j < DeclClassList.Count do
            begin
              TempStr := Trim(StrAfter(amcClass, DeclClassList[j]));
              if (Pos(',', TempStr) > 0) and
                (Pos(',', TempStr) < Pos(')', TempStr)) then
                TempStr := Trim(StrBefore(',', TempStr))
              else
                TempStr := Trim(StrBefore(')', TempStr));
              if (UpperCase(TempStr) = ClassList[0]) or
                (UpperCase(Trim(StrBefore('=', DeclClassList[j]))) = ClassList[0]) then
              begin
//                NextClass := Trim(StrBefore(amcClass, DeclClassList[j]));
                NextClass := Trim(StrBefore('=', DeclClassList[j]));
                if ClassList.IndexOf(NextClass) = -1 then
                  ClassList.Add(UpperCase(NextClass));
                ClassFileList.AddClass(FileList[i], NextClass);
                DeclClassList.Delete(j);

              end else
                Inc(j);
            end;
            if DeclClassList.Count = 0 then
              FileList.Delete(i)
            else
              Inc(i);
          end;
          ClassList.Delete(0);
        end;
      end;
    finally
      FileText.Free;
    end;
  finally
    FileList.Free;
  end;
end;

{ TamcClassFileList }

function TamcClassFileList.AddClass(const AFileName, AClassName: String): Integer;
begin
  Result := AddFile(AFileName);
  if ClassList[Result].IndexOf(AClassName) = -1 then
    ClassList[Result].Add(AClassName);

end;

function TamcClassFileList.AddFile(const AFileName: String): Integer;
begin
  Result := IndexOf(AFileName);
  if Result = -1 then
    Result := AddObject(AFileName, TStringList.Create);
end;

constructor TamcClassFileList.Create;
begin
  inherited Create;

  FClassList := TStringList.Create;
end;

function TamcClassFileList.GetClassList(Index: Integer): TStrings;
begin
  Result := nil;

  if (not (Index > Count)) and (Assigned(Objects[Index])) and
    (Objects[Index] is TStringList) then
    Result := TStrings(Objects[Index]);
end;

procedure TamcClassFileList.SetClassList(Index: Integer; Value: TStrings);
begin
  Objects[Index] := Value;
end;

end.
