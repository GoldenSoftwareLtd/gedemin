unit inst_dlgRenameFile_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TRenameResult = (rrNone, rrRename, rrReplace, rrDelete);

type
  TdlgRenameFile = class(TForm)
    lblFindFile: TLabel;
    Image1: TImage;
    Label1: TLabel;
    lblRename: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button3: TButton;
    Button1: TButton;
    Button2: TButton;
    Image2: TImage;
    Image3: TImage;
    lblSize1: TLabel;
    lblDate1: TLabel;
    lblSize2: TLabel;
    lblDate2: TLabel;
    Button4: TButton;
    Label2: TLabel;
    Bevel1: TBevel;
    eOldName: TEdit;
    eNewName: TEdit;
    Button5: TButton;
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    function ShowModalEx(const AnFindFile, AnInstallFile, AnNewName: String): TRenameResult;
  end;

var
  dlgRenameFile: TdlgRenameFile;

implementation

uses
  jclShell, JclGraphics, ShellApi;

{$R *.DFM}

{ TdlgRenameFile }

function TdlgRenameFile.ShowModalEx(const AnFindFile,
  AnInstallFile, AnNewName: String): TRenameResult;
var
  S: String;
  IconHandle: HICON;
  IconHeight, IconWidth: Integer;

  function FormatSize(const AnSize: Integer): String;
  var
    TempRes: Double;
  begin
    TempRes := AnSize;
    if TempRes / 1024 > 1 then
    begin
      TempRes := TempRes / 1024;
      if TempRes / 1024 > 1 then
      begin
        TempRes := TempRes / 1024;
        Result := FormatFloat('0.##', TempRes) + ' Мб';
      end else
        Result := FormatFloat('0.##', TempRes) + ' Кб';
    end else
      Result := FormatFloat('0.##', TempRes) + ' байт';
  end;

  function GetFileSize(const AnFileName: String): Integer;
  var
    F: File;
    B: Byte;
  begin
    AssignFile(F, AnFileName);
    try
      B := FileMode;
      FileMode := 0;
      Reset(F, 1);
      try
        Result := FileSize(F);
      finally
        CloseFile(F);
        FileMode := B;
      end;
    except
      Result := -1;
    end;
  end;

  function GetFileSizeStr(const AnFileName: String): String;
  var
    FSize: Integer;
  begin
    FSize := GetFileSize(AnFileName);
    if FSize = -1 then
      Result := 'Ошибка при определении размера.'
    else
      Result := FormatSize(FSize);
  end;
begin
  eOldName.Text := AnFindFile;
  eNewName.Text := AnNewName;
  eOldName.Hint := AnFindFile;
  eNewName.Hint := AnNewName;

  try
    lblSize1.Caption := GetFileSizeStr(AnFindFile);
    DateTimeToString(S, LongDateFormat + ', ' + LongTimeFormat, FileDateToDateTime(FileAge(AnFindFile)));
    lblDate1.Caption := 'дата изменения: ' + S;

    lblSize2.Caption := GetFileSizeStr(AnInstallFile);
    DateTimeToString(S, LongDateFormat + ', ' + LongTimeFormat, FileDateToDateTime(FileAge(AnInstallFile)));
    lblDate2.Caption := 'дата изменения: ' + S;

    IconHeight := GetSystemMetrics(SM_CYICON);
    IconWidth := GetSystemMetrics(SM_CXICON);
    IconHandle := GetFileNameIcon(AnFindFile, SHGFI_ICON);
    Image2.Picture.Bitmap.Height := IconHeight;
    Image2.Picture.Bitmap.Width := IconWidth;
    DrawIcon(Image2.Picture.Bitmap.Canvas.Handle, 0, 0, IconHandle);

    IconHandle := GetFileNameIcon(AnInstallFile);
    Image3.Picture.Bitmap.Height := IconHeight;
    Image3.Picture.Bitmap.Width := IconWidth;
    DrawIcon(Image3.Picture.Bitmap.Canvas.Handle, 0, 0, IconHandle);

    MessageBeep(MB_ICONEXCLAMATION);
    { TODO : Надо вставить проверку по версии. }
    if ( FileAge(AnInstallFile) <> FileAge(AnFindFile) ) or    
       ( GetFileSize(AnInstallFile) <> GetFileSize(AnFindFile) ) then
      ShowModal
    else
      ModalResult := mrCancel;
  except
    on E: Exception do
    begin 
      MessageBox(Handle, PChar(E.Message), 'Ошибка', MB_OK);
      ShowModal;
    end;
  end;

  if ModalResult = mrYes then
    Result := rrRename
  else
    if ModalResult = mrNo then
      Result := rrReplace
    else
      if ModalResult = mrCancel then
        Result := rrNone
      else
        if ModalResult = mrOk then
          Result := rrDelete
        else
          raise Exception.Create('Тип действия не поддерживается');
end;


procedure TdlgRenameFile.Button5Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;


end.
