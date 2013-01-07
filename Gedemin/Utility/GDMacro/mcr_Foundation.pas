unit mcr_Foundation;

interface

uses
  contnrs, classes, Sysutils, jclBase;


const
  mcr_Decl     = '@DECLARE';
  mcr_End      = 'END';
  mcr_Macro    = 'MACRO';
  mcr_Call     = '@CALL';
  mcr_ErrDecl  = 'Error macro declaration';
  mcr_ErrParam = 'Error parameters declaration';
  mcr_Unfold   = '@UNFOLD MACRO';
  mcr_EndMacro = 'END MACRO';
  mcr_Pref     = 'M';


type
  TUnFlag = (mcrCut, mcrCorrect);

type
  TmcrMacroList = class;
  TmcrMacro     = class;
  TmcrStrings = class;

  TmcrMacroList = class(TObjectList)
  private
    FPath: String;
    FFileMask: String;
    FFindFlag: Boolean;
    FFullFileList: TStrings;
    FBeginComment: String;
    FEndComment: String;
    FErrorStr: String;
    FLogList: TStrings;
    FIniFile: TStrings;
    FRecursiveSearch: Boolean;
    FIgnoreMacros: TStrings;
    FWorkMacros: TStrings;


    function  GetMacro(Index : Integer): TmcrMacro;
    function  ReturnSpace(ACountSpace: Integer): String;
    function  GetInputParams(AParams: String; AParamsList: TStrings): Boolean;
    function  InsertMacroBody(APos: Integer; ACountSp: Integer;
      AFileText: TStrings; AMacro: TmcrMacro): Boolean;
//    function  InsertMacroBody(var APos: Integer; ACountSp: Integer;
//      AFileText: TStrings; AMacro: TmcrMacro): Boolean;
    function ParamToStr(AMacro: TStrings): String;
    function  CutUnfoldMacros(AFlag: TUnFlag): Boolean;

(*    // функция проверяет, есть ли в строке AStr вызов макроса АMacroName
    // если нет, то Result = ''
    function  GetCallString(const AStr, AMacroName: String;
      out ANameWithParam: String): String;
      *)
    // функция возвращет имя макроса, если строка - начало развернутого макроса
    // если нет, то Result = ''
    function  GetUnfoldStringName(const AStr: String;
      out ANameWithParam: String): String;
    // функция ищет для окончания развернуто макроса
    // AFileText - файл с развернутым макросом
    // APos - позиция строки, в которой начало развернуто макроса
    // возращает позицию конца, если окончание не обнаружено, то -1
    function  GetUnfoldEnd(AFileText: TStrings; APos: Integer): Integer;
    function  CutMacroBody(AFileText: TStrings;
      var BeginPos, EndPos: Integer; AFileName: String): Boolean;


    procedure SetMacro(Index: Integer; Value: TmcrMacro);

    procedure ChangeParams(var AStrWithParams: String; AMacros: TmcrMacro;
      ACurParams: TStrings);
    procedure SetPath(Value: String);
    procedure SetFileMask(Value: String);
    procedure SetBeginComment(Value: String);
    procedure SetEndComment(Value: String);
//    function SetFullFileList: Boolean;

  public
    constructor Create;
    destructor  Destroy; override;

    function  IndexOf(const S: string): Integer;  overload;
    function  AddMacro(const S: string): Integer; overload;
    function  AddMacro(const Macro: TmcrMacro): Integer; overload;
    function  MacroByName(const S: string): TmcrMacro;
    function  SetFullFileList: Boolean;

    // поиск объявления макросов
    function  FindDeclares: Boolean;
    // разворачивание макросов
    function  UnfoldMacros(const CreateBackup: Boolean): Boolean;
    // сворачивание макросов
    function  CutMacros: Boolean;
    // заменити развернутые макросы
    function  ReplaceMacros: Boolean;
    // развернуть и заменить
    function  UnfoldAndReplace(const CreateBackup: Boolean): Boolean;
    // удаление вызова макроса
    function  DeleteMacroCall(MacroName: String): Boolean;

    property  Macro[Index : Integer]: TmcrMacro read GetMacro write SetMacro; default;
    property  Path: String read FPath write SetPath;
    property  FileMask: String read FFileMask write SetFileMask;
    property  BeginComment: String read FBeginComment write SetBeginComment;
    property  EndComment: String read FEndComment write SetEndComment;
    property  ErrorStr: String read FErrorStr write FErrorStr;
    property  LogList: TStrings read FLogList;
    property  RecursiveSearch: Boolean read FRecursiveSearch write FRecursiveSearch;
    property  WorkMacros: TStrings read FWorkMacros write FWorkMacros;
    property  IgnoreMacros: TStrings read FIgnoreMacros write FIgnoreMacros;
  end;


  TmcrStrings = class(TStringList)
  public
    constructor Create;
    function Add(const S: String): Integer; override;
  end;

  TmcrMacro = class(TPersistent)
  private
    FBody: TStrings;
    FCallFiles: TStrings;
    FDeclFile: String;
    FFiles: TStrings;
    FName: String;
    FParams: TStrings;
    FErrors: TStrings;
  public
    constructor Create;
    destructor  Destroy; override;

    property Body: TStrings read FBody;
    property CallFiles: TStrings read FCallFiles;
    property DeclFile: String read FDeclFile write FDeclFile;
    property Errors: TStrings read FErrors;
    property Name: String read FName;
    property Params: TStrings read FParams;
    property Files: TStrings read FFiles;
  end;

implementation

uses
  JclFileUtils, FileCtrl, JclStrings, Windows, mcr_frmGauge, Forms;
{ TmcrMacro }

constructor TmcrMacro.Create;
begin
  inherited;

  FBody := TStringList.Create;
  FCallFiles := TmcrStrings.Create;
  FErrors := TStringList.Create;
  FParams := TmcrStrings.Create;
  FFiles := TmcrStrings.Create;
end;

destructor TmcrMacro.Destroy;
begin
  FBody.Free;
  FErrors.Free;
  FParams.Free;
  FFiles.Free;
  FCallFiles.Free;

  inherited;
end;

{ TmcrMacroList }

function TmcrMacroList.AddMacro(const S: string): Integer;
var
  i: Integer;
begin
  i := IndexOf(S);
  if i > -1 then
    Result := i
  else
    Result := Add(TmcrMacro.Create);
  Macro[Result].FName := S;
end;

procedure TmcrMacroList.ChangeParams(var AStrWithParams: String;
  AMacros: TmcrMacro; ACurParams: TStrings);
var
  i, p: Integer;
begin
  for i := 0 to AMacros.Params.Count - 1 do
  begin
    while True do
    begin
      p := Pos(UpperCase(AMacros.Params[i]) , UpperCase(AStrWithParams));
      if p > 0 then
        AStrWithParams := Copy(AStrWithParams, 1, p - 1) +
          ACurParams[i] + Copy(AStrWithParams,
          p + Length(AMacros.Params[i]), Length(AStrWithParams))
      else
        Break;
    end
  end

end;

constructor TmcrMacroList.Create;
var
  i: Integer;
begin
  inherited;

  FLogList := TStringList.Create;
  FFullFileList := TStringList.Create;
  FFindFlag := False;
  Path := GetCurrentDir;
  FileMask := '*.*';
  FIniFile := TStringList.Create;
  if FileExists('gdMacro.ini') then
  begin
    FIniFile.LoadFromFile('gdMacro.ini');
    begin
      for i := 0 to FIniFile.Count - 1 do
      begin
        if Pos('PATH=', Trim(UpperCase(FIniFile[i]))) = 1 then
          Path := Copy(Trim(FIniFile[i]), Length('PATH=') + 1, Length(FIniFile[i]));
        if Pos('FILEMASK=', Trim(UpperCase(FIniFile[i]))) = 1 then
          FileMask := Copy(Trim(FIniFile[i]), Length('FILEMASK=') + 1, Length(FIniFile[i]));
        if Pos('BEGINCOMMENT=', Trim(UpperCase(FIniFile[i]))) = 1 then
          BeginComment := Copy(Trim(FIniFile[i]), Length('BEGINCOMMENT=') + 1, Length(FIniFile[i]));
        if Pos('ENDCOMMENT=', Trim(UpperCase(FIniFile[i]))) = 1 then
          EndComment := Copy(Trim(FIniFile[i]), Length('ENDCOMMENT=') + 1, Length(FIniFile[i]));
      end;
    end;
  end;
end;

destructor TmcrMacroList.Destroy;
begin
  FFullFileList.Free;
  LogList.SaveToFile('gdMacro.log');
  FLogList.Free;
  FIniFile.Clear;
  FIniFile.Add('PATH=' + Path);
  FIniFile.Add('FILEMASK=' + FileMask);
  FIniFile.Add('BEGINCOMMENT=' + BeginComment);
  FIniFile.Add('ENDCOMMENT=' + EndComment);
  FIniFile.SaveToFile('gdMacro.ini');
  FIniFile.Free;

  inherited;
end;

function TmcrMacroList.UnfoldMacros(const CreateBackup: Boolean): Boolean;
var
  i, k, j, subPos, PosInStr, ErrFile: Integer;
  LFileText: TStrings;
  LStr: String;
  Saving: Boolean;

  function ParamToStr(AMacro: TStrings): String;
  var
    iPS: Integer;
  begin
    Result := '';
    if AMacro.Count = 0 then
      exit;

    Result := '(';
    for iPS := 0 to AMacro.Count - 1 do
    begin
      Result := Result + AMacro[iPS];
      if iPS < AMacro.Count - 1 then
        Result := Result + ', ';
    end;
    Result := Result + ')';
  end;

begin
  Result := False;
  k := 0;

  ErrFile := -1;
  try
    LFileText := TStringList.Create;
    try
      LogList.Add('*** Разворачивание макросов ***'#10#13);
      frmGauge.ggMcr.MinValue := 0;
      frmGauge.ggMcr.MaxValue := FFullFileList.Count;
      frmGauge.Caption := 'Разворачивание макросов';
      frmGauge.Show;
      for i := 0 to FFullFileList.Count - 1 do
      begin
        frmGauge.ggMcr.Progress := i;
        ErrFile := i;
        LFileText.Clear;
        LFileText.LoadFromFile(FFullFileList[i]);
        Saving := False;
        k := 0;
  //      for k := 0 to LFileText.Count - 1 do
        while k < LFileText.Count do
        begin
          // проверка на наличие @CALL
          PosInStr := Pos(mcr_Call, UpperCase(LFileText[k]));
          if PosInStr > 0 then
            for j := 0 to WorkMacros.Count - 1 do
            begin
              // проверка по имени макроса
              subPos := Pos(MacroByName(WorkMacros[j]).Name, UpperCase(LFileText[k]));
  //            subPos := Pos(Macro[j].Name, UpperCase(LFileText[k]));
              if subPos > 0 then
              begin
              ////
                LStr := UpperCase(LFileText[k]);
                // проверка на наличие @CALL
                PosInStr := Pos(mcr_Call, LStr);
                if PosInStr > 0 then
                  LStr := Trim(Copy(LStr, PosInStr + Length(mcr_Call), Length(LStr)))
                else
                  Break;
                // проверка на MACRO после @CALL
                subPos := Pos(mcr_Macro, LStr);
                if subPos = 1 then
                  LStr := Trim(Copy(LStr, subPos + Length(mcr_Macro), Length(LStr)))
                else
                  Break;
                // проверка на полное имя после MACRO
                subPos := Pos(MacroByName(WorkMacros[j]).Name, LStr);
                LStr := Copy(LStr, SubPos + Length(MacroByName(WorkMacros[j]).Name), 1);
                if (subPos > 0) and ((LStr = ' ') or
                  (LStr = '(') or (LStr = EndComment)) then
                begin
                  Saving := InsertMacroBody(k, Pos(BeginComment, LFileText[k]),
                    LFileText, MacroByName(WorkMacros[j]));
                  if Saving then
                    LogList.Add('    Развернут макрос ' +
                      MacroByName(WorkMacros[j]).Name +
                      ' в файл ' + FFullFileList[i]);

    //              LStr := Trim(Copy(LStr, subPos + 1, Length(LStr)));
                  MacroByName(WorkMacros[j]).CallFiles.Add(FFullFileList[i]);
                end else
                  Break;

              end;
            end;
          Inc(k);
        end;
        if  Saving then
        begin
          if CreateBackup then
          begin
            DeleteFile(PChar(ChangeFileExt(FFullFileList[i], '.MBK')));
            if not RenameFile(FFullFileList[i], ChangeFileExt(FFullFileList[i], '.MBK')) then
              raise Exception.Create('Не удалось создать MBK - файл.');
          end;
          LFileText.SaveToFile(FFullFileList[i]);
          LogList.Add('  ! Файл ' + FFullFileList[i] + ' сохранен');
        end
      end;
    finally
      frmGauge.Close;
      LogList.Add('*** Конец разворачивания макросов ***'#10#13);
      LFileText.Free;
    end;

    Result := True;

  except
    on E: Exception do
      begin
        if ErrFile > -1 then
          MessageBox(0, PChar(E.Message + ''#10#13 +
            'Файл: ' + FFullFileList[ErrFile] + ', строка ' + IntToStr(k + 1)), 'Ошибка',
            MB_OK or MB_ICONERROR or MB_TOPMOST);
        Clear;
      end;
  end;
end;

function TmcrMacroList.FindDeclares: Boolean;
var
  i, k, subPos, ErrFile: Integer;
  LFileText: TStrings;
  LStr, MacroName: String;

  // если строка декларация макроса, возвращает имя, иначе ''
  function GetNameFromDeclare(AStr: String; out AParamStr: String): String;
  var
    mnSubPos: Integer;
    mnMacroName: String;
  begin
    Result := '';
    // поиск начала комментария
    mnSubPos := Pos(BeginComment, Trim(AStr));
    if mnSubPos = 1 then
    begin
      // после символа начала комментария - декларация
      AParamStr := UpperCase(Trim(Copy(AStr,
        mnSubPos + Length(BeginComment), Length(AStr))));
      if Pos(mcr_Decl, AParamStr) = 1 then
      begin
        // после декларации - макрос
        AParamStr := Trim(Copy(AParamStr,
          Length(mcr_Decl) + 1, Length(AStr)));
        mnSubPos := Pos(mcr_Macro, AParamStr);
        if mnSubPos = 1 then
        begin
          // после макроса, выделяем имя макроса
          AParamStr := UpperCase(Trim(Copy(AParamStr, mnSubPos +
            Length(mcr_Macro), Length(AParamStr))));
          mnSubPos := Pos('(', AParamStr);
          if mnSubPos > 0 then
          begin
            mnMacroName := Trim(Copy(AParamStr, 1, Pos('(', AParamStr) - 1));
          end else
            mnMacroName := Trim(Copy(AParamStr, 1, Length(AParamStr)));
          if (Length(mnMacroName) = 0) or (Pos(' ', mnMacroName) > 0) then
            raise Exception.Create('Ошибка в имени макроса');

          AParamStr := Trim(Copy(AParamStr, Length(mnMacroName) + 1,
            Length(AParamStr)));
        end;
      end;
    end;
    Result := mnMacroName;
  end;

  // заполнеине тела макроса
  procedure AddBodyMacro(LPos: Integer);
  var
    bm, em: Integer;
    Str: String;
  begin
    // проверка на конец объявления макроса
    for em := k + 1 to LFileText.Count - 1 do
    begin
      if GetNameFromDeclare(LFileText[em], Str) <> '' then
        raise Exception.Create('Обнаружено объявление макроса до окончания предыдущего');

      if Pos(mcr_End ,Trim(UpperCase(LFileText[em]))) = 1 then
      begin
        Str := UpperCase(Copy(Trim(LFileText[em]), pos(mcr_End ,UpperCase(Trim(LFileText[em]))) +
          Length(mcr_End), Length(LFileText[em])));
        if Pos(mcr_Macro, Trim(Str)) = 1 then
        begin
          if Pos(EndComment, Trim(Copy(Trim(Str),
            1 + Length(mcr_Macro), Length(Str)))) = 1 then
          Break;
        end;
      end;
    end;
    Macro[subPos].Body.Clear;
    if em < LFileText.Count then
    begin
      for bm := k + 1 to em  - 1 do
        Macro[subPos].Body.Add(LFileText[bm]);
    end else
    begin
//      Macro[subPos].Body.Clear;
      raise Exception.Create('Не обнаружено окончание для макроса');
      Macro[subPos].Errors.Add(mcr_ErrDecl);
    end
  end;

  // заполнение списка параметров
  procedure AddParamsMacro(const AStr: String);
  var
//    ePD: Integer;
    Str, ParamToStr: String;
  begin
    if Pos('(', AStr) = 0 then
      Exit;

    if Pos(')', AStr) > 1 then
      Str := Copy(AStr, 2, Pos(')', AStr) - 2)
    else
      begin
        Macro[subPos].Body.Clear;
        Macro[subPos].Errors.Add(mcr_ErrParam);
        raise Exception.Create('В объявлении макроса не найдено окончание параметров - ).');
//        Exit;
      end;
    while True do
    begin
      ParamToStr := '';
      // выделяет строку по первому %
      if Pos('%', Str) = 1 then
        Str := Copy(Str, 2, Length(Str))
      else
//        raise Exception.Create('Параметр в объявлении макроса должен начинаться с %.');
        Break;
      // выделяет строку по последнему %
      if (Pos('%', Str) > 1) then
      begin
        ParamToStr := Copy(Str, 1, Pos('%', Str) - 1);
        Str := Trim(Copy(Str, Pos('%', Str) + 1, Length(Str)));
        if Pos(',', Str) = 1 then
        begin
          Str := Trim(Copy(Str, Pos(',', Str) + 1, Length(Str)));
          if (Pos('%', Str) = 1) then
            Str := Trim(Copy(Str, 1, Length(Str)))
          else
            begin
              Macro[subPos].Body.Clear;
              Macro[subPos].Errors.Add(mcr_ErrParam);
              raise Exception.Create('Параметр в объявлении макроса должен оканчиваться %.');
      //        Exit;
            end;
        end;

        if (Trim(ParamToStr) <> '') or (Pos(' ', ParamToStr) > 0) then
          Macro[subPos].Params.Add(UpperCase('%' + ParamToStr + '%'))
        else
          begin
            Macro[subPos].Body.Clear;
            Macro[subPos].Errors.Add(mcr_ErrParam);
            raise Exception.Create('Ошибка в имени параметра.');
    //        Exit;
          end;
      end else
        begin
          Macro[subPos].Body.Clear;
          Macro[subPos].Errors.Add(mcr_ErrParam);
          raise Exception.Create('Параметр в объявлении макроса должен оканчиваться %.');
//          Exit;
        end;

    end;
  end;

begin
  Result := False;

  ErrFile := -1;
  try
    if not SetFullFileList then
    begin
      raise Exception.Create('Не удалось создать список файлов');
      exit;
    end;

    Clear;
    LFileText := TStringList.Create;
    try
      LogList.Add('*** Поиск объявлений макросов ***'#10#13);
      frmGauge.ggMcr.MinValue := 0;
      frmGauge.ggMcr.MaxValue := FFullFileList.Count;
      frmGauge.Caption := 'Поиск объявлений макросов';
      frmGauge.Show;
      for i := 0 to FFullFileList.Count - 1 do
      begin
        frmGauge.ggMcr.Progress := i;
        ErrFile := i;
        LFileText.Clear;
        LFileText.LoadFromFile(FFullFileList[i]);
        for k := 0 to LFileText.Count - 1 do
        begin
          MacroName := GetNameFromDeclare(LFileText[k], LStr);
          if MacroName = '' then
            Continue;

//          LStr := Trim(Copy(LStr, Length(MacroName) + 1, Length(LStr)));
          subPos := IndexOf(MacroName);
          if subPos = -1 then
            subPos := AddMacro(MacroName);
          Macro[subPos].Files.Add(FFullFileList[i]);
          Macro[subPos].DeclFile := FFullFileList[i];
          AddBodyMacro(k);
          AddParamsMacro(LStr);
          LogList.Add('    Найден макрос ' + MacroName + '   файл ' + FFullFileList[i]);
        end;
      end;
      Result := True;
    finally
      frmGauge.Close;
      LFileText.Free;
      LogList.Add('*** Конец поиска объявления макросов ***'#10#13);
    end;

  except
    on E: Exception do
      begin
        if ErrFile > -1 then
          MessageBox(0, PChar(E.Message + ''#10#13 +
            'Файл: ' + FFullFileList[ErrFile] + ', строка ' + IntToStr(k + 1)), 'Ошибка',
            MB_OK or MB_ICONERROR or MB_TOPMOST);
        Clear;
      end;
  end;
end;

function TmcrMacroList.SetFullFileList: Boolean;
var
  SearchOption: TFileListOptions;
begin
  if FFindFlag then
  begin
    Result := True;
    Exit;
  end;

  if RecursiveSearch then
    SearchOption := [flFullNames, flRecursive]
  else
    SearchOption := [flFullNames];

  Result := False;
  FFullFileList.Clear;
  if AdvBuildFileList(Path + '\' + FileMask, faAnyFile,
    FFullFileList, SearchOption) then
  begin
    Result := True;
    FFindFlag := True;
  end else
    MessageBox(0, PChar('Ошибка поиска файлов'),
      'Ошибка', MB_OK or MB_ICONWARNING or MB_TASKMODAL);
end;

function TmcrMacroList.GetMacro(Index : Integer): TmcrMacro;
begin
  Result := TmcrMacro(Items[Index]);
end;

function TmcrMacroList.IndexOf(const S: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count - 1 do
    if UpperCase(Macro[i].Name) = UpperCase(s) then
    begin
      Result := i;
      Break;
    end;
end;


procedure TmcrMacroList.SetFileMask(Value: String);
begin
  if Value <> FFileMask then
  begin
    FFindFlag := False;
    FFileMask := Value;
  end;
end;

procedure TmcrMacroList.SetPath(Value: String);
begin
  if Value <> FPath then
  begin
    FFindFlag := False;
    FPath := Value;
  end;
end;

function TmcrMacroList.CutMacros: Boolean;
begin
  Result := CutUnfoldMacros(mcrCut);
end;

function TmcrMacroList.CutUnfoldMacros(AFlag: TUnFlag): Boolean;
var
  LFileText: TStrings;
  i, k, j, ErrFile: Integer;
  str, MacroName: String;
  Saving: Boolean;

begin
  Result := False;
  // возможно надо разкомментеровать
  if FFullFileList.Count = 0 then
    if not SetFullFileList then
    begin
      exit;
    end;
//    exit;
//  if AFlag = mcrCorrect then
//    if not FindDeclares then
//      exit;

  ErrFile := -1;
  try
    LFileText := TStringList.Create;
    try
      case AFlag of
        mcrCut:
          begin
            LogList.Add('*** Сворачивание макросов ***'#10#13);
            frmGauge.Caption := 'Сворачивание макросов';
          end;
        mcrCorrect:
          begin
            LogList.Add('*** Замена макросов ***'#10#13);
            frmGauge.Caption := 'Замена макросов';
          end;
      end;

      frmGauge.ggMcr.MinValue := 0;
      frmGauge.ggMcr.MaxValue := FFullFileList.Count;
      frmGauge.Show;

      for i := 0 to FFullFileList.Count - 1 do
      begin
        try
          frmGauge.ggMcr.Progress := i;
          ErrFile := i;
          LFileText.Clear;
          LFileText.LoadFromFile(FFullFileList[i]);
          Saving := False;
          k := LFileText.Count - 1;
          while k > 0 do
//          k := 0;
//          while k < LFileText.Count do
          begin
            MacroName := GetUnfoldStringName(LFileText[k], str);
            if (AFlag = mcrCorrect) and
              (IgnoreMacros.IndexOf(MacroName) > -1) then
              begin
                Dec(k);
//                Inc(k);
                continue;
              end;

            if MacroName <> '' then
            begin
              // проверка на окончание макроса
              j := GetUnfoldEnd(LFileText, k);
              Saving := CutMacroBody(LFileText, k, j, FFullFileList[i]);
              {
              if j > -1 then
              begin
                PosStr := Pos(BeginComment, LFileText[k]);
                if (AFlag = mcrCut) or
                  ((AFlag = mcrCorrect) and (IndexOf(MacroName) > -1)) then
                begin
                  for s := 1 to j - k do
                    LFileText.Delete(k + 1);

                  LFileText.Insert(k + 1, ReturnSpace(PosStr) + '{' +
                    mcr_Call + ' ' + mcr_Macro + ' ' + str);
                  LFileText.Delete(k);
                  Saving := True;
                  Inc(k);
                  LogList.Add('    Удаленен макрос ' + MacroName + ' в файле ' +
                    FFullFileList[i]);
                end;
                }
                // если замена макросов, то добавляем их после удаления
                if AFlag = mcrCorrect then
                begin
                  if IndexOf(MacroName) > -1 then
                  begin
                    Dec(k);
                    Saving := InsertMacroBody(k, Pos(BeginComment, LFileText[k]),
                      LFileText, Macro[IndexOf(MacroName)]);
                    if Saving then
                      LogList.Add('    Вставлен макрос ' + MacroName + ' в файле ' +
                        FFullFileList[i]);
                  end else
                    MessageBox(0, PChar('Не найдено объявление макроса ' + MacroName),
                      'Ошибка', MB_OK or MB_ICONWARNING or MB_TASKMODAL);
      //          end;
              end;
            end;
            Dec(k);
          end;
          if Saving then
          begin
            LFileText.SaveToFile(FFullFileList[i]);
            LogList.Add('  ! Файл ' + FFullFileList[i] + ' cохранен');
          end;
        except
          on E: Exception do
            if MessageBox(0,
              PChar('В процессе обработки возникла ошибка: ' +
              E.Message + #10#13 +
              'Файл: ' + FFullFileList[ErrFile] + ', строка ' +
              IntToStr(k + 1) + #13#10#13#10 +
              'Продолжить обработку?'),
              'Ошибка',
              MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL) = IDNO then raise
            else
              LogList.Add('  !!! ' + E.Message + #10#13 +
                'Файл: ' + FFullFileList[ErrFile] + ', строка ' +
                IntToStr(k + 1));
        end;
      end;
      Result := True;
    finally
      frmGauge.Close;
      LFileText.Free;
      case AFlag of
        mcrCut:
          LogList.Add('*** Конец сворачивания макросов ***'#10#13);
        mcrCorrect:
          LogList.Add('*** Конец замены макросов ***'#10#13);
      end;
    end;
  except
    on E: Exception do
      begin
        if ErrFile > -1 then
          MessageBox(0, PChar(E.Message + ''#10#13 +
            'Файл: ' + FFullFileList[ErrFile] + ', строка ' + IntToStr(k + 1)), 'Ошибка',
            MB_OK or MB_ICONERROR or MB_TOPMOST);
        Clear;
      end;
  end;
end;

function TmcrMacroList.ReturnSpace(ACountSpace: Integer): String;
var
  isp: Integer;
begin
  Result := '';
  for isp := 0 to ACountSpace - 2 do
    Result := Result + ' ';
end;

function TmcrMacroList.GetInputParams(AParams: String;
  AParamsList: TStrings): Boolean;
var
  iPos: Integer;
  str: String;
begin
  Result := False;
  if not Assigned(AParamsList) then
    raise Exception.Create('Не передана переменная для передачи параметров.');

  AParamsList.Clear;
  if Pos('(', AParams) = 0 then
  begin
    Result := True;
    Exit;
  end;

  AParams := Copy(AParams, Pos('(', AParams) + 1, Length(AParams));
  if Pos(')', AParams) > 0 then
    AParams := Copy(AParams, 1, Pos(')', AParams) - 1)
  else
    begin
      raise Exception.Create('В вызове макроса не найдено окончание параметров - ).');
      // !!! Ошибка
    end;

  while True do
  begin
    iPos := Pos(',', AParams);
    if iPos > 1 then
    begin
      str := Trim(Copy(AParams, 1, iPos - 1));
      if Pos('%', str) = 1 then
//        raise Exception.Create('Параметр не должен начинаться с символа %.');
        exit;
      AParamsList.Add(AnsiUpperCase(str));
      AParams := Copy(AParams, iPos + 1, Length(AParams));
    end else
      begin
        AParamsList.Add(AnsiUpperCase(Trim(Copy(AParams, 1, Length(AParams)))));
        Result := True;
        Break;
      end;
  end;
end;

function TmcrMacroList.InsertMacroBody(APos: Integer;
   ACountSp: Integer; AFileText: TStrings; AMacro: TmcrMacro): Boolean;
var
  InParams: TStrings;
  Index, iPar: Integer;
  LStr: String;
begin
  Result := False;
  InParams := TStringList.Create;
  try
    if GetInputParams(Copy(AFileText[APos], Pos(AMacro.Name, AFileText[APos]) +
      Length(AMacro.Name), Length(AFileText[APos])), InParams) and
      (InParams.Count = AMacro.Params.Count) then
    begin
      // пишем начало макроса
      AFileText.Insert(APos, ReturnSpace(ACountSp) + BeginComment + mcr_Unfold +
        ' ' + AMacro.Name + ParamToStr(InParams) + EndComment);
      Inc(APos);
      // добавление кода
      for Index := 0 to AMacro.Body.Count - 1 do
      begin
        LStr := AMacro.Body[Index];
        for iPar := 0 to AMacro.Params.Count - 1 do
          ChangeParams(LStr, AMacro, InParams);
        AFileText.Insert(APos, ReturnSpace(ACountSp) + BeginComment +
          mcr_Pref + EndComment + LStr);
        Inc(APos);
      end;
      // пишем конец макроса
      AFileText.Insert(APos, ReturnSpace(ACountSp) +
        BeginComment + mcr_EndMacro + EndComment);
      // удаляем вызов
      AFileText.Delete(APos + 1);
      Result := True;
    end else
      raise Exception.Create('Количество параметров в объявлении макроса и в вызове макросе не равно');
  finally
    InParams.Free;
  end;

end;

function TmcrMacroList.ParamToStr(AMacro: TStrings): String;
var
  iPS: Integer;
begin
  Result := '';
  if AMacro.Count = 0 then
    exit;

  Result := '(';
  for iPS := 0 to AMacro.Count - 1 do
  begin
    Result := Result + AMacro[iPS];
    if iPS < AMacro.Count - 1 then
      Result := Result + ', ';
  end;
  Result := Result + ')';
end;

function TmcrMacroList.ReplaceMacros: Boolean;
begin
  Result := CutUnfoldMacros(mcrCorrect);
end;

procedure TmcrMacroList.SetBeginComment(Value: String);
begin
  FBeginComment := Trim(Value);
end;

procedure TmcrMacroList.SetEndComment(Value: String);
begin
  FEndComment := Trim(Value);
end;

function TmcrMacroList.GetUnfoldStringName(const AStr: String;
  out ANameWithParam: String): String;
var
  subPos: Integer;
begin
  Result := '';
  subPos := Pos(BeginComment, Trim(AStr));
  if subPos = 1 then
  begin
    ANameWithParam := Trim(Copy(UpperCase(Trim(AStr)), subPos +
      Length(BeginComment), Length(AStr)));
    subPos := Pos(mcr_Unfold, ANameWithParam);
    if subPos = 1 then
    begin
      ANameWithParam := Trim(UpperCase(Copy(ANameWithParam, subPos +
        Length(mcr_Unfold), Length(ANameWithParam))));
      if Pos('(', ANameWithParam) > 0 then
        Result := UpperCase(Trim(Copy(ANameWithParam, 1,
          Pos('(', ANameWithParam) - 1)))
      else
        Result := UpperCase(Trim(Copy(ANameWithParam, 1,
          Pos(EndComment, ANameWithParam) - 1)));
    end;
  end;
  if (Pos(' ', Result) > 0) or (Pos('(', Result) > 0) or
    (Pos(')', Result) > 0) then
    raise Exception.Create('Ошибка в имени макроса');
end;

function TmcrMacroList.GetUnfoldEnd(AFileText: TStrings;
  APos: Integer): Integer;
var
  j: Integer;
begin
//  Result := -1;

  for j := APos + 1 to AFileText.Count - 1 do
  begin
    if Pos(BeginComment + mcr_EndMacro, Trim(AFileText[j])) = 1 then
      Break
    else
      if Pos(BeginComment + mcr_Pref + EndComment, Trim(AFileText[j])) <> 1 then
      begin
        raise Exception.Create('Ошибка в теле макроса.');
      end;
  end;
  if j = AFileText.Count then
  begin
    raise Exception.Create('Не найдено окончание макроса.');
  end else
    Result := j;

end;

function TmcrMacroList.CutMacroBody(AFileText: TStrings;
  var BeginPos, EndPos: Integer; AFileName: String): Boolean;
var
  s, PosStr: Integer;
  MacroName, MacroNameWithParams: String;
begin
//  Result := False;
  if not ((BeginPos > -1) and (BeginPos < EndPos) and
    (EndPos > -1) and (EndPos < AFileText.Count)) then
    raise Exception.Create('Переданы неправильные параметры начала и конца макроса');

  PosStr := Pos(BeginComment, AFileText[BeginPos]);
  for s := 1 to EndPos - BeginPos do
    AFileText.Delete(BeginPos + 1);

  if (Pos(')', AFileText[BeginPos]) > 0) and (Pos('(', AFileText[BeginPos]) > 0)  then
  begin
    MacroNameWithParams := UpperCase(Trim(Copy(AFileText[BeginPos], Pos(mcr_Macro,
      AFileText[BeginPos]) + Length(mcr_Macro), Length(AFileText[BeginPos]))));
    MacroName := Copy(MacroNameWithParams, 1, Pos('(', MacroNameWithParams) - 1);
  end else
    begin
      MacroNameWithParams := UpperCase(Trim(Copy(AFileText[BeginPos], Pos(mcr_Macro,
        AFileText[BeginPos]) + Length(mcr_Macro), Length(AFileText[BeginPos]))));
      MacroName := Copy(MacroNameWithParams, 1, Pos(EndComment, MacroNameWithParams) - 1);
    end;

  AFileText.Insert(BeginPos + 1, ReturnSpace(PosStr) + BeginComment +
    mcr_Call + ' ' + mcr_Macro + ' ' + MacroNameWithParams{ + EndComment});
  AFileText.Delete(BeginPos);
  Inc(BeginPos);
  LogList.Add('    Свернут макрос ' + MacroNameWithParams + ' в файле ' + AFileName);
  Result := True;
end;

(*function TmcrMacroList.GetCallString(const AStr, AMacroName: String;
  out ANameWithParam: String): String;
begin
  // проверка по имени макроса
  subPos := Pos(Macro[j].Name, UpperCase(AStr));
  if subPos > 0 then
  begin
  ////
    LStr := UpperCase(LFileText[k]);
    // проверка на наличие @CALL
    PosInStr := Pos(mcr_Call, LStr);
    if PosInStr > 0 then
      LStr := Trim(Copy(LStr, PosInStr + Length(mcr_Call), Length(LStr)))
    else
      Break;
    // проверка на MACRO после @CALL
    subPos := Pos(mcr_Macro, LStr);
    if subPos = 1 then
      LStr := Trim(Copy(LStr, subPos + Length(mcr_Macro), Length(LStr)))
    else
      Break;
    // проверка на имя после MACRO
    subPos := Pos(Macro[j].Name, LStr);
    if subPos > 0 then
    ;
  end;
end;
  *)

function TmcrMacroList.DeleteMacroCall(MacroName: String): Boolean;
var
  LFileText: TStrings;
  ErrFile, k, i, subPos, PosInStr: Integer;
  LStr: String;
  Saving: Boolean;
begin
  Result := False;

  if Trim(MacroName) = '' then
  begin
    MessageBox(0, 'Необходимо задать имя макроса для удаления.',
      'Ошибка', mb_Ok or MB_IconError or MB_TASKMODAL);
    exit;
  end;

  if FFullFileList.Count = 0 then
    if not SetFullFileList then
      Exit;

  ErrFile := -1;
  k := 0;
  try
    LFileText := TStringList.Create;
    try
      LogList.Add('*** Удаление вызов макросов ***'#10#13);
      frmGauge.Caption := 'Удаление вызов макросов';
      frmGauge.ggMcr.MinValue := 0;
      frmGauge.ggMcr.MaxValue := FFullFileList.Count;
      frmGauge.Show;

      for i := 0 to FFullFileList.Count - 1 do
      begin
        frmGauge.ggMcr.Progress := i;
        ErrFile := i;
        LFileText.Clear;
        LFileText.LoadFromFile(FFullFileList[i]);
        Saving := False;
        k := 0;
        while k < LFileText.Count do
        begin
          begin
            // проверка по имени макроса
            subPos := Pos(UpperCase(MacroName), UpperCase(LFileText[k]));
            if subPos > 0 then
            begin
            ////
              LStr := Trim(UpperCase(Copy(LFileText[k], 1, subPos - 1)));
              // проверка на наличие @CALL
              PosInStr := Pos(mcr_Call, LStr);
              if PosInStr > 0 then
                LStr := Trim(Copy(LStr, PosInStr + Length(mcr_Call), Length(LStr)))
              else
                Break;
              if LStr = mcr_Macro then
              begin
                LFileText.Delete(k);
                if k > -1 then
                  Dec(k);
                LogList.Add('    Удален вызов макроса ' + MacroName +
                  ' в файле ' + FFullFileList[i]);
                Saving := True;
              end else
                Break;
            end;
          end;
          Inc(k);
        end;
        if Saving then
        begin
          LFileText.SaveToFile(FFullFileList[i]);
          LogList.Add('  ! Файл ' + FFullFileList[i] + ' сохранен');
        end
      end;
    finally
      frmGauge.Close;
      LogList.Add('*** Конец удаления вызовов макросов ***'#10#13);
      LFileText.Free;
    end;

    Result := True;

  except
    on E: Exception do
      begin
        if ErrFile > -1 then
          MessageBox(0, PChar(E.Message + ''#10#13 +
            'Файл: ' + FFullFileList[ErrFile] + ', строка ' + IntToStr(k + 1)), 'Ошибка',
            MB_OK or MB_ICONERROR or MB_TOPMOST);
        Clear;
      end;
  end;
end;

function TmcrMacroList.UnfoldAndReplace(const CreateBackup: Boolean): Boolean;
begin
  Result := ReplaceMacros and UnfoldMacros(CreateBackup);
end;

function TmcrMacroList.AddMacro(const Macro: TmcrMacro): Integer;
begin
  Result := Add(Macro);
end;

procedure TmcrMacroList.SetMacro(Index: Integer; Value: TmcrMacro);
begin
  Items[Index] := Value;
end;

function TmcrMacroList.MacroByName(const S: string): TmcrMacro;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
    if UpperCase(Trim(Macro[i].Name)) = UpperCase(Trim(S)) then
    begin
      Result := Macro[i];
      Break;
    end;

end;

{ TmcrStrings }

function TmcrStrings.Add(const S: String): Integer;
begin
  if IndexOf(S) > -1 then
    Result := IndexOf(S)
  else
    Result := inherited Add(S);
end;

constructor TmcrStrings.Create;
begin
  inherited Create;
end;

end.
