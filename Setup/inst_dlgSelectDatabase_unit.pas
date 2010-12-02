{
  Author

    Andrey Shadevsky

  Revisions history
                                   
    1.00    dd.mm.yy    JKL        Initial version.
    1.1     04.11.03    Yuri       Убрал OpenDialog1 - некорректно работал под WinME
    1.2     25.11.03    Yuri       разбил Edit на 2 - имя сервера и имя файла БД 
                  
}

unit inst_dlgSelectDatabase_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TdlgSelectDatabase = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    eFileName: TEdit;
    btnSelect: TButton;
    Label1: TLabel;
    Bevel1: TBevel;
    eServerName: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    procedure btnSelectClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    function GetFileName: String;
    function AdjustServerName(const AServerName: String): String;
  public
    function Execute: Boolean;
    property FileName : String read GetFileName;
  end;

var
  dlgSelectDatabase: TdlgSelectDatabase;

implementation

{$R *.DFM}

function TdlgSelectDatabase.AdjustServerName(const AServerName: String): String;
begin
  Result := AServerName;
  if Copy(Result, 1, 2) = '\\' then
  begin
    Delete(Result, 1, 2);   
    eServerName.Text := Copy(Result, 1, Pos('\', Result)-1);
    Delete(Result, 1, Pos('\', Result));
    Insert(':', Result, Pos('\', Result));

{    Delete(Result, 1, 2);
    Insert(':', Result, Pos('\', Result) + 1);
    Delete(Result, Pos('\', Result), 1);
    Insert(':', Result, Pos('\', Result));}
  end;

  { else
    if GetDriveType(PChar(ExtractFileDrive(AServerName))) = DRIVE_REMOTE then
    begin
      ShowMessage('remote drive');
    end};
end;


procedure TdlgSelectDatabase.btnSelectClick(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
  begin
    Filter := 'БД Interbase|*.fdb;*.gdb';
    if Execute then      
    begin
//      edFileName.Text := AdjustServerName(FileName);
      eFileName.Text := AdjustServerName(FileName);
      if eServerName.Text = '' then
        eServerName.SetFocus
      else
        eFileName.SetFocus;
    end;
  end;
end;

function TdlgSelectDatabase.Execute: Boolean;
begin
  Result := ShowModal = mrOk;
end;

function TdlgSelectDatabase.GetFileName: String;
begin
  Result := eServerName.Text + ':' + eFileName.Text;
end; 

procedure TdlgSelectDatabase.btnOkClick(Sender: TObject);
{var
  S: String;
  SP: PChar;
  I: Integer;}
begin
  if eServerName.Text = '' then                                                                   
    MessageBox(Handle, 'Не указано имя сервера!', 'Внимание', MB_OK or MB_ICONSTOP)

{  S := GetFileName + #0;
  SP := @S[1];
  I := 0;
  while SP^ <> #0 do
  begin
    if SP^ = ':' then
      Inc(I);
    Inc(SP);
  end;

  if I <> 2 then
  begin
    MessageBox(Handle, 'Некорректный путь к базе данных! ' + #13#10 + 'Возможно, не указано имя сервера.',
      'Внимание', MB_OK or MB_ICONSTOP);
  end }else
    ModalResult := mrOk;
end;


end.
