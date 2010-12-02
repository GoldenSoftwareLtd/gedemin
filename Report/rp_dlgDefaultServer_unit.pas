unit rp_dlgDefaultServer_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, IBQuery, StdCtrls, DBCtrls;

type
  TdlgDefaultServer = class(TForm)
    dblcDefaultServer: TDBLookupComboBox;
    Label1: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    ibqryServerList: TIBQuery;
    ibdsDefaultServer: TIBDataSet;
    dsDefaultServer: TDataSource;
    dsServerList: TDataSource;
    procedure dblcDefaultServerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    function SetDefaultServer: Boolean;
  end;

var
  dlgDefaultServer: TdlgDefaultServer;

implementation

uses
  gd_SetDatabase;

{$R *.DFM}

procedure TdlgDefaultServer.dblcDefaultServerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if Key = VK_DELETE then
    ibdsDefaultServer.FieldByName('serverkey').AsVariant := NULL;
end;

function TdlgDefaultServer.SetDefaultServer: Boolean;
var
  OldValue: Variant;
begin
  Result := False;
  ibdsDefaultServer.Close;
  ibdsDefaultServer.Params[0].AsString := rpGetComputerName;
  ibdsDefaultServer.Open;
  ibqryServerList.Open;
  if ibdsDefaultServer.Eof then
  begin
    ibdsDefaultServer.Insert;
    ibdsDefaultServer.FieldByName('clientname').AsString := rpGetComputerName;
  end else
    ibdsDefaultServer.Edit;
  OldValue := ibdsDefaultServer.FieldByName('serverkey').AsVariant;
  if ShowModal = mrOk then
  try
    Result := OldValue <> ibdsDefaultServer.FieldByName('serverkey').AsVariant;

    if ibdsDefaultServer.FieldByName('serverkey').AsVariant = NULL then
    begin
      if dsInsert <> ibdsDefaultServer.State then
      begin
        ibdsDefaultServer.Cancel;
        ibdsDefaultServer.Delete;
      end else
        ibdsDefaultServer.Cancel;
    end else
      ibdsDefaultServer.Post;
  except
    on E: Exception do
    begin
      MessageBox(Self.Handle, PChar('Произошла ошибка при выборе текущего сервера:'#13#10 +
       E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
      ibdsDefaultServer.Cancel;
      Result := True;
    end;
  end else
    ibdsDefaultServer.Cancel;
end;

end.
