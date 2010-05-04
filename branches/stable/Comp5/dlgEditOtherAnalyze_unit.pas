unit dlgEditOtherAnalyze_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, DBTables, StdCtrls, DBCtrls, Mask, xLabel, mBitButton, UserLogin;

type
  TfrmEditOtherAnalyze = class(TForm)
    Label1: TLabel;
    tblAnTableValue: TTable;
    dsAnTableValue: TDataSource;
    dbedName: TDBEdit;
    Label2: TLabel;
    dbmFullName: TDBMemo;
    xlblTitle: TxLabel;
    mbbNext: TmBitButton;
    mBitButton2: TmBitButton;
    mbbCancel: TmBitButton;
    spGetID: TStoredProc;
    procedure FormCreate(Sender: TObject);
    procedure mbbNextClick(Sender: TObject);
    procedure mBitButton2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    FAnalyzeTable: Integer;
    FValueID: Integer;
    FName: String;
    FNestedTransaction: Boolean;

    procedure AppendValue;
    procedure SaveValue;
  public
    { Public declarations }
    constructor Create(aOwner: TComponent; aAnalyzeTable, aValueID: Integer;
      const aName: String);  reintroduce;
  end;

var
  frmEditOtherAnalyze: TfrmEditOtherAnalyze;

implementation

{$R *.DFM}

{ TfrmEditOtherAnalyze }

procedure TfrmEditOtherAnalyze.AppendValue;
begin
  spGetID.ExecProc;
  tblAnTableValue.Append;
  tblAnTableValue.FieldByName('ID').AsInteger :=
    spGetID.ParamByName('ID').AsInteger;
  tblAnTableValue.FieldByName('AnalyzeKey').AsInteger := FAnalyzeTable;
  tblAnTableValue.FieldByName('Name').AsString := FName;
end;

constructor TfrmEditOtherAnalyze.Create(aOwner: TComponent;
  aAnalyzeTable, aValueID: Integer; const aName: String);
begin
  inherited Create(aOwner);
  FAnalyzeTable := aAnalyzeTable;
  FValueID := aValueID;
  FName := aName;

  FNestedTransaction := Database.InTransaction;
end;

procedure TfrmEditOtherAnalyze.FormCreate(Sender: TObject);
begin
  tblAnTableValue.Open;

  if not FNestedTransaction then
    Database.StartTransaction;

  if FValueID = -1 then
    AppendValue
  else
  begin
    if tblAnTableValue.FindKey([FValueID]) then
      tblAnTableValue.Edit;
    mbbNext.Visible := False;  
  end;
  mbbNext.Visible := FName = '';
end;

procedure TfrmEditOtherAnalyze.SaveValue;
begin
  if tblAnTableValue.State in [dsEdit, dsInsert] then
    tblAnTableValue.Post;

  if FNestedTransaction then
    Database.Commit;  
end;

procedure TfrmEditOtherAnalyze.mbbNextClick(Sender: TObject);
begin
  SaveValue;
  if not FNestedTransaction then
    Database.StartTransaction;
  AppendValue;
end;

procedure TfrmEditOtherAnalyze.mBitButton2Click(Sender: TObject);
begin
  SaveValue;
  ModalResult := mrOK;
end;

procedure TfrmEditOtherAnalyze.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if ModalResult <> mrOk then
  begin
    if tblAnTableValue.State in [dsEdit, dsInsert] then
      tblAnTableValue.Cancel;
    if not FNestedTransaction then
      Database.RollBack;  
  end;
end;

end.
