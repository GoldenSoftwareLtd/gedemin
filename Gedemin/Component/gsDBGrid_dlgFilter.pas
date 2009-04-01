unit gsDBGrid_dlgFilter;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  TdlgFilter_Grid = class(TForm)
    cbText: TComboBox;
    chbxRegExp: TCheckBox;
    Label1: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    ActionList: TActionList;
    actOk: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgFilter_Grid: TdlgFilter_Grid;

implementation

{$R *.DFM}

{$IFDEF GEDEMIN}
uses
  Storages;
{$ENDIF}

procedure TdlgFilter_Grid.FormCreate(Sender: TObject);
begin
  {$IFDEF GEDEMIN}
  if UserStorage <> nil then
    cbText.Items.CommaText := UserStorage.ReadString('Options', 'GrCont', '', False);
  if cbText.Items.Count > 0 then
    cbText.ItemIndex := 0;
  {$ENDIF}
end;

procedure TdlgFilter_Grid.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := cbText.Text > '';
end;

procedure TdlgFilter_Grid.actOkExecute(Sender: TObject);
{$IFDEF GEDEMIN}
var
  I: Integer;
  S: String;
{$ENDIF}
begin
  {$IFDEF GEDEMIN}
  if Trim(cbText.Text) > '' then
  begin
    S := cbText.Text;

    I := cbText.Items.IndexOf(S);
    if I <> 0 then
    begin
      if I > 0 then
        cbText.Items.Delete(I);
      cbText.Items.Insert(0, S);
    end;

    I := cbText.Items.Count - 1;
    if I > 10 then
      cbText.Items.Delete(I);

    cbText.Text := S; 

    if UserStorage <> nil then
      UserStorage.WriteString('Options', 'GrCont', cbText.Items.CommaText, False);
  end;
  {$ENDIF}

  ModalResult := mrOk;
end;

end.
