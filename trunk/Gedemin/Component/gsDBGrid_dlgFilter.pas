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
    chbxConvertSQL: TCheckBox;
    actRegExp: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actOkExecute(Sender: TObject);
    procedure actRegExpExecute(Sender: TObject);
    procedure actRegExpUpdate(Sender: TObject);
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
var
  S: String;
begin
  {$IFDEF GEDEMIN}
  if UserStorage <> nil then
  begin
    chbxRegExp.Checked := UserStorage.ReadBoolean('Options', 'GrContRE', False, False);

    S := UserStorage.ReadString('Options', 'GrCont', '', False);

    if chbxConvertSQL.Enabled and chbxConvertSQL.Checked then
      S := StringReplace(StringReplace(S, '.*', '%', [rfReplaceAll]), '.{1}', '_', [rfReplaceAll]);

    cbText.Items.CommaText := S;
  end;
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

    if chbxConvertSQL.Enabled and chbxConvertSQL.Checked then
      S := StringReplace(StringReplace(S, '%', '.*', [rfReplaceAll]), '_', '.{1}', [rfReplaceAll]);

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
    begin
      UserStorage.WriteString('Options', 'GrCont', cbText.Items.CommaText, False);
      UserStorage.WriteBoolean('Options', 'GrContRE', chbxRegExp.Checked, False);
    end;
  end;
  {$ENDIF}

  ModalResult := mrOk;
end;

procedure TdlgFilter_Grid.actRegExpExecute(Sender: TObject);
begin
  //...
end;

procedure TdlgFilter_Grid.actRegExpUpdate(Sender: TObject);
begin
  chbxConvertSQL.Enabled := chbxRegExp.Checked;
end;

end.
