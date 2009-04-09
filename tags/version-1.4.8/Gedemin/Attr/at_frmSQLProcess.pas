unit at_frmSQLProcess;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ActnList, TB2Dock, TB2Toolbar, TB2Item, ExtCtrls,
  at_Classes;

type
  TfrmSQLProcess = class(TForm)
    alSQLProcess: TActionList;
    actSaveToFile: TAction;
    pnlTop: TPanel;
    tbProcessSQL: TTBToolbar;
    tbiSaveToFile: TTBItem;
    stbSQLProcess: TStatusBar;
    actClose: TAction;
    tbiClose: TTBItem;
    pb: TProgressBar;
    Panel1: TPanel;
    SQLText: TMemo;

    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actSaveToFileExecute(Sender: TObject);
    procedure actCloseExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    FWasSpace: Boolean;
    FPrevText: String;
    FIsShowLog: Boolean;
    FAsked: Boolean;
    FSilent: Boolean;
    function GetIsError: Boolean;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property WasSpace: Boolean read FWasSpace write FWasSpace;
    //Сохраняет текст перед очисткой  RichEdita при превышении максимального размера RichEdita
    //Затем используется при сохранении данных в файл
    property PrevText: String read FPrevText write FPrevText;
    property IsError: Boolean read GetIsError;
    //если Silent = true, то лог будет вестись, но окно не будет выводится на экран
    property Silent: Boolean read FSilent write FSilent;
    property IsShowLog: Boolean read FIsShowLog write FIsShowLog;
  end;

var
  frmSQLProcess: TfrmSQLProcess;

procedure AddText(const T: String; C: TColor; const Necessary: Boolean = False);
function TranslateText(const T: String): String;
//параметр IsNecessarily указывает обязательно ли рисовать Space
//по умолчанию проверяется флаг FWasSpace,
//который указвает, является ли предыдущая строка Space
procedure Space(const IsNecessarily: Boolean = False);
procedure AddMistake(const T: String; C: TColor);

implementation

uses
  Storages, at_dlgLoadPackages_unit
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

const
  cstWasMistakes = 'В ходе процесса возникли ошибки';
  cstNeedReConnection = 'Необходимо переподключение к базе';

{$R *.DFM}

function TranslateText(const T: String): String;
var
  S: String;

  procedure WhatMetaData(Const FromAdd: Boolean = False);
  var
    I: Integer;
  begin
    if AnsiPos('TABLE', S) = 1 then
    begin
      Result := Result + 'таблицы ';
      S := Trim(Copy(S, 6, Length(S) - 5));
    end

    else if AnsiPos('INDEX', S) = 1 then
    begin
      Result := Result + 'индекса ';
      S := Trim(Copy(S, 6, Length(S) - 5));
    end

    else if AnsiPos('TRIGGER', S) = 1 then
    begin
      Result := Result + 'триггера ';
      S := Trim(Copy(S, 8, Length(S) - 7));
    end

    else if AnsiPos('EXCEPTION', S) = 1 then
    begin
      Result := Result + 'исключения ';
      S := Trim(Copy(S, 10, Length(S) - 9));
    end

    else if AnsiPos('VIEW', S) = 1 then
    begin
      Result := Result + 'представления ';
      S := Trim(Copy(S, 5, Length(S) - 4));
    end

    else if AnsiPos('DOMAIN', S) = 1 then
    begin
      Result := Result + 'домена ';
      S := Trim(Copy(S, 7, Length(S) - 6));
    end

    else if AnsiPos('PROCEDURE', S) = 1 then
    begin
      Result := Result + 'процедуры ';
      S := Trim(Copy(S, 10, Length(S) - 9));
    end

    else if AnsiPos('CONSTRAINT', S) = 1 then
    begin
      Result := Result + 'ограничения ';
      S := Trim(Copy(S, 11, Length(S) - 10));
    end

    else if AnsiPos('COLUMN', S) = 1 then
    begin
      Result := Result + 'поля ';
      S := Trim(Copy(S, 7, Length(S) - 6));
    end

    else if AnsiPos('UNIQUE', S) = 1 then
    begin
      S := Trim(Copy(S, 8, Length(S) - 7));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('ASC', S) = 1 then
    begin
      S := Trim(Copy(S, 4, Length(S) - 3));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('ASCENDING', S) = 1 then
    begin
      S := Trim(Copy(S, 10, Length(S) - 9));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('DESC', S) = 1 then
    begin
      S := Trim(Copy(S, 5, Length(S) - 4));
      WhatMetaData;
      Exit;
    end

    else if AnsiPos('DESCENDING', S) = 1 then
    begin
      S := Trim(Copy(S, 11, Length(S) - 10));
      WhatMetaData;
      Exit;
    end

    else if FromAdd then
      Result := Result + 'поля '

    else
      Exit;

    for I := 1 to Length(S) do
    begin
      if S[I] in [' ', #0, #13, #10] then
        Break;
    end;

    if I < Length(S) then
    begin
      Result := Result + Copy(S, 1, I - 1);
      S := Trim(Copy(S, I + 1, Length(S) - I));
    end

    else begin
      Result := Result + S;
      S := '';
    end;

  end;

  var
    AddS: String;

begin

  S := Trim(AnsiUpperCase(T));

  while AnsiPos('/*', S) = 1 do
  begin
    if AnsiPos('*/', S) > 0 then
    begin
      Delete(S, 1, AnsiPos('*/', S) + 1);
      S := Trim(S);
    end
    else
      Break;
  end;

  if AnsiPos('CREATE', S) = 1 then
  begin
    Result := 'Создание ';
    S := Trim(Copy(S, 7, Length(S) - 6));
    WhatMetaData;
  end

  else if AnsiPos('DROP', S) = 1 then
  begin
    Result := 'Удаление ';
    S := Trim(Copy(S, 5, Length(S) - 4));
    WhatMetaData(True);
  end

  else if AnsiPos('ADD', S) = 1 then
  begin
    Result := 'Добавление ';
    S := Trim(Copy(S, 4, Length(S) - 3));
    WhatMetaData(True);
  end

  else if AnsiPos('ALTER', S) = 1 then
  begin
    Result := 'Изменение ';
    S := Trim(Copy(S, 6, Length(S) - 5));
    WhatMetaData;
    if AnsiPos('ТАБЛИЦЫ', AnsiUpperCase(Result)) > 0 then
    begin
      AddS := TranslateText(S);
      Result := Result + ' ' + AnsiLowerCase(Copy(AddS, 1, 1)) + Copy(AddS, 2, Length(AddS) - 1);
    end;
  end

  else
    Result := '';

end;

procedure AddMistake(const T: String; C: TColor);
begin
  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);

  AddText(T,C,True);
  frmSQLProcess.stbSQLProcess.Panels[0].Text := cstWasMistakes;
end;

procedure AddText(const T: String; C: TColor; const Necessary: Boolean = False);
const
  Counter: Integer = 0;
{var
  OldSelStart: Integer;}
begin
  if not Assigned(frmSQLProcess) then
  begin
    frmSQLProcess := TfrmSQLProcess.Create(Application);
  end;

  if (T > '') and (Necessary or frmSQLProcess.IsShowLog) then
  begin
    Inc(Counter);

    with frmSQLProcess.SQLText do
    begin
      try
        if SelStart > 512*1024 then
        begin
          frmSQLProcess.PrevText :=
            frmSQLProcess.PrevText + #13#10 + Text;
          Clear;
          SelStart := 0;
        end;
        //OldSelStart := SelStart;
        Lines.Add(T);
      except
        //Возможно ошибка из-за превышения максимального размера RichEdit'a
        //Тогда сохраним предыдущий текст и очистим RichEdit
        if Length(Text) > 32*1024 then
        begin
          frmSQLProcess.PrevText :=
            frmSQLProcess.PrevText + #13#10 + Text;
          Clear;
          SelStart := 0;
          //OldSelStart := SelStart;
          Lines.Add(T);
        end else
          raise;
      end;

      {
      if DefAttributes.Color <> C then
      begin
        SelStart := OldSelStart;
        SelLength := Length(T);
        SelAttributes.Color := C;
      end;

      SelStart := SelStart + Length(T);
      SelLength := 0;
      }

      if Assigned(atDatabase) and atDatabase.InMultiConnection then
        frmSQLProcess.stbSQLProcess.Panels[1].Text := cstNeedReConnection
      else
        frmSQLProcess.stbSQLProcess.Panels[1].Text := '';

      if not frmSQLProcess.Silent then
      begin
        if not frmSQLProcess.Visible then
        begin
          frmSQLProcess.Show;
          Counter := 0;
        end;

        if (Counter mod 40) = 0 then
        begin
          frmSQLProcess.BringToFront;
          UpdateWindow(frmSQLProcess.Handle);
        end;
      end;  
    end;

    frmSQLProcess.WasSpace := False;
  end;
end;

procedure Space(const IsNecessarily: Boolean = False);
begin

  if not Assigned(frmSQLProcess) then
    frmSQLProcess := TfrmSQLProcess.Create(Application);

  if IsNecessarily or not frmSQLProcess.WasSpace then
  begin
    AddText
    (
      '---',
      clBlack, False
    );
  end;
  frmSQLProcess.WasSpace := True
end;

constructor TfrmSQLProcess.Create;
begin
  Assert(frmSQLProcess = nil, 'Может быть только одна форма frmSQLProcess');

  inherited;
  FWasSpace := False;
  FPrevText := '';
  FSilent := False;
  if Assigned(UserStorage) then
    FIsShowLog := UserStorage.ReadBoolean('Options', 'ShowLog', True, False)
  else
    FIsShowLog := True;
end;

procedure TfrmSQLProcess.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if IsError and
    (MessageBox(Handle, 'Во время выполнения скриптов возникли ошибки! Сохранить лог в файл?',
      'Внимание', MB_ICONQUESTION or MB_YESNO) = IDYES)
  then
  begin
    actSaveToFile.Execute;
  end;
  SQLText.Lines.Clear;
  SQLText.SelStart := 0;
  stbSQLProcess.Panels[0].Text := '';
  stbSQLProcess.Panels[1].Text := '';
  pb.Min := 0;
  pb.Max := 0;
  pb.Position := 0;
  FWasSpace := False;
  FPrevText := '';
  FAsked := False;

  if (not Visible) and ((frmSQLProcess = nil) or (frmSQLProcess = Self)) then
    Action := caFree;
end;

procedure TfrmSQLProcess.actSaveToFileExecute(Sender: TObject);
var
  SD: TSaveDialog;
  SL: TStringList;
begin
  SD := TSaveDialog.Create(Self);
  try
    SD.Title := 'Сохранить лог в файл ';
    SD.DefaultExt := 'txt';
    SD.Filter := 'Текстовые файлы (*.txt)|*.TXT|' +
      'Все файлы (*.*)|*.*';
    SD.FileName := 'Log';
    if SD.Execute then
    begin
      SL := TStringList.Create;
      try
        SL.Assign(SQLText.Lines);
        if PrevText > '' then
          SL.Insert(0, PrevText);
        SL.SaveToFile(SD.FileName);
      finally
        SL.Free;
      end;
    end;

  finally
    SD.Free;
  end;

end;

function TfrmSQLProcess.GetIsError: Boolean;
begin
  Result := stbSQLProcess.Panels[0].Text > '';
end;

procedure TfrmSQLProcess.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmSQLProcess.FormShow(Sender: TObject);
begin
  if at_dlgLoadPackages <> nil then
  begin
    if not FAsked then
    begin
      if Assigned(UserStorage) then
        FIsShowLog := UserStorage.ReadBoolean('Options', 'ShowLog', True, False);

      FIsShowLog := FIsShowLog and (MessageBox(Handle,
        'Выводить подробную информацию о ходе процесса?'#13#10#13#10 +
        'Данная опция способна существенно замедлить выполнение!',
        'Внимание',
        MB_YESNO or MB_ICONQUESTION or MB_TASKMODAL or MB_DEFBUTTON2) = IDYES);

      FAsked := True;
    end;
  end;
end;

destructor TfrmSQLProcess.Destroy;
begin
  if frmSQLProcess = Self then
    frmSQLProcess := nil;
  inherited;
end;

end.

