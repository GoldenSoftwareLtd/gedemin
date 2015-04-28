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
    chbxAlwaysOverwrite: TCheckBox;
    chbxDontRemove: TCheckBox;
    mLoadList: TMemo;
    Label1: TLabel;
    gbSave: TGroupBox;
    Label3: TLabel;
    mSaveList: TMemo;
    lSaveRecords: TLabel;
    chbxIncVersion: TCheckBox;
    ActionList: TActionList;
    actOk: TAction;
    actLoadObjects: TAction;
    pnlLoadObjects: TPanel;
    chbxLoadObjects: TCheckBox;
    pnlSaveObjects: TPanel;
    chbxSaveObjects: TCheckBox;
    actSaveObjects: TAction;
    chbxTerminate: TCheckBox;
    chbxIgnoreMissedFields: TCheckBox;
    procedure actOkExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure actLoadObjectsExecute(Sender: TObject);
    procedure actSaveObjectsExecute(Sender: TObject);
    procedure actLoadObjectsUpdate(Sender: TObject);
    procedure actSaveObjectsUpdate(Sender: TObject);
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

procedure TdlgCheckOperation.actLoadObjectsExecute(Sender: TObject);
begin
  actLoadObjects.Checked := not actLoadObjects.Checked;
end;

procedure TdlgCheckOperation.actSaveObjectsExecute(Sender: TObject);
begin
  actSaveObjects.Checked := not actSaveObjects.Checked;
end;

procedure TdlgCheckOperation.actLoadObjectsUpdate(Sender: TObject);
begin
  gbLoad.Visible := actLoadObjects.Checked;
end;

procedure TdlgCheckOperation.actSaveObjectsUpdate(Sender: TObject);
begin
  gbSave.Visible := actSaveObjects.Checked;
end;

end.
