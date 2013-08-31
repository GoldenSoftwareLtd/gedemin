unit at_dlgCheckOperation_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ActnList;

type
  TdlgCheckOperation = class(TForm)
    pnlWorkArea: TPanel;
    pnlLoad: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    gbLoad: TGroupBox;
    lLoadRecords: TLabel;
    cbAlwaysOverwrite: TCheckBox;
    cbDontRemove: TCheckBox;
    mLoadList: TMemo;
    Label1: TLabel;
    gbSave: TGroupBox;
    Label3: TLabel;
    mSaveList: TMemo;
    lSaveRecords: TLabel;
    chbxIncVersion: TCheckBox;
    ActionList: TActionList;
    actOk: TAction;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgCheckOperation: TdlgCheckOperation;

implementation

{$R *.DFM}

procedure TdlgCheckOperation.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgCheckOperation.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (mLoadList.Lines.Count > 0) or (mSaveList.Lines.Count > 0);
end;

end.
