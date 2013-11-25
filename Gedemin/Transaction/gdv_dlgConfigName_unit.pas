unit gdv_dlgConfigName_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ActnList, StdCtrls, gsIBLookupComboBox, ExtCtrls, IBDatabase, dmDataBase_unit;

type
  TdlgConfigName = class(TForm)
    Panel1: TPanel;
    lConfigName: TLabel;
    iblName: TgsIBLookupComboBox;
    Button1: TButton;
    Button2: TButton;
    ActionList: TActionList;
    actCancel: TAction;
    actOk: TAction;
    Transaction: TIBTransaction;
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
  private
    procedure SetConfigName(const Value: string);
    function GetConfigName: string;
  public
    property ConfigName: string  read GetConfigName write SetConfigName;
  end;

var
  dlgConfigName: TdlgConfigName;

implementation

{$R *.DFM}

procedure TdlgConfigName.actOkUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := iblName.Text <> '';
end;

function TdlgConfigName.GetConfigName: string;
begin
  Result := iblName.Text;
end;

procedure TdlgConfigName.SetConfigName(const Value: string);
begin
  iblName.Text := Value;
end;

procedure TdlgConfigName.FormCreate(Sender: TObject);
begin
  Transaction.DefaultDatabase := dmDatabase.ibdbGAdmin;
  iblName.NewObjIfNotFound := False;
end;

procedure TdlgConfigName.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk 
end;

procedure TdlgConfigName.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end; 
end.
