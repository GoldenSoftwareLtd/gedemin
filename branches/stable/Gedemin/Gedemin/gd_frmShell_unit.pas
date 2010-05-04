
{ http://msdn2.microsoft.com/en-us/library/ms838576.aspx }

unit gd_frmShell_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  Tgd_frmShell = class(TForm)
    chbxUseShell: TCheckBox;
    chbxAuto: TCheckBox;
    edDatabase: TEdit;
    edUser: TEdit;
    edPassword: TEdit;
    btnOk: TButton;
    ActionList1: TActionList;
    actOk: TAction;
    edPath: TEdit;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gd_frmShell: Tgd_frmShell;

implementation

{$R *.DFM}

procedure Tgd_frmShell.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure Tgd_frmShell.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := FileExists(edPath.Text)
    and (not chbxAuto.Checked or (edDatabase.Text > ''));
end;

end.
