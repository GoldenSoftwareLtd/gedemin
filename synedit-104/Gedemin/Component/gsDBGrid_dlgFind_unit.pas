
unit gsDBGrid_dlgFind_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  TgsdbGrid_dlgFind = class(TForm)
    Button1: TButton;
    Button2: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    actCancel: TAction;
    cbFindText: TComboBox;
    GroupBox1: TGroupBox;
    rbDown: TRadioButton;
    rbUp: TRadioButton;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    chbxMatchCase: TCheckBox;
    chbxWholeWord: TCheckBox;
    GroupBox3: TGroupBox;
    rbCurrent: TRadioButton;
    rbBegin: TRadioButton;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gsdbGrid_dlgFind: TgsdbGrid_dlgFind;

implementation

{$R *.DFM}

uses
  Storages
  {$IFDEF LOCALIZATION}
  , gd_localization_stub, gd_localization
  {$ENDIF}
  ;

procedure TgsdbGrid_dlgFind.actOkExecute(Sender: TObject);
var
  I: Integer;
  S: String;
begin
  S := cbFindText.Text;
  I := cbFindText.Items.IndexOf(S);

  if I <> -1 then
    cbFindText.Items.Delete(I);

  if cbFindText.Items.Count >= 20 then
    cbFindText.Items.Delete(cbFindText.Items.Count - 1);

  if Trim(S) > '' then
  begin
    cbFindText.Items.Insert(0, S);
    cbFindText.ItemIndex := 0;
  end;

  if Assigned(UserStorage) then
    with UserStorage do
    begin
      WriteString('\Options\Search', 'FindText', cbFindText.Items.CommaText);
      WriteBoolean('\Options\Search', 'MatchCase', chbxMatchCase.Checked);
      WriteBoolean('\Options\Search', 'WholeWord', chbxWholeWord.Checked);
      WriteBoolean('\Options\Search', 'Down', rbDown.Checked);
      WriteBoolean('\Options\Search', 'Current', rbCurrent.Checked);
    end;

  ModalResult := mrOk;
end;

procedure TgsdbGrid_dlgFind.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TgsdbGrid_dlgFind.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := cbFindText.Text > '';
end;

procedure TgsdbGrid_dlgFind.FormCreate(Sender: TObject);
begin
  if Assigned(UserStorage) then
  with UserStorage do
  begin
    cbFindText.Items.CommaText := ReadString('\Options\Search', 'FindText', '');
    chbxMatchCase.Checked := ReadBoolean('\Options\Search', 'MatchCase', False);
    chbxWholeWord.Checked := ReadBoolean('\Options\Search', 'WholeWord', False);
    if ReadBoolean('\Options\Search', 'Down', True) then
      rbDown.Checked := True
    else
      rbUp.Checked := True;
    if ReadBoolean('\Options\Search', 'Current', True) then
      rbCurrent.Checked := True
    else
      rbBegin.Checked := True;
  end;

  {$IFDEF LOCALIZATION}
  LocalizeComponent(Self);
  {$ENDIF}
end;

procedure TgsdbGrid_dlgFind.FormActivate(Sender: TObject);
begin
  if cbFindText.Items.Count > 0 then
  begin
    cbFindText.ItemIndex := 0;
  end;
end;

end.
