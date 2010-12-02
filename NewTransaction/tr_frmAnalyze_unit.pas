unit tr_frmAnalyze_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ToolWin, ComCtrls, Grids, DBGrids, gsDBGrid, gsIBGrid, Db, gd_createable_form,
  IBDatabase, IBCustomDataSet, dmDatabase_unit,  ActnList,
  at_classes;

type
  TfrmAnalyze = class(TCreateableForm)
    ToolBar1: TToolBar;
    Panel1: TPanel;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    gsibgrAnalyze: TgsIBGrid;
    dsAnalyzeField: TDataSource;
    ibdsAnalyze: TIBDataSet;
    IBTransaction: TIBTransaction;
    ToolButton3: TToolButton;
    ActionList1: TActionList;
    actNew: TAction;
    actEdit: TAction;
    actDelete: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;

    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  frmAnalyze: TfrmAnalyze;

implementation

{$R *.DFM}

uses
  tr_dlgAnalyze_unit, Storages;

class function TfrmAnalyze.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(frmAnalyze) then
    frmAnalyze := TfrmAnalyze.Create(AnOwner);

  Result := frmAnalyze;
end;

procedure TfrmAnalyze.LoadSettings;
begin
  inherited;
  UserStorage.LoadComponent(gsibgrAnalyze, gsibgrAnalyze.LoadFromStream);
end;

procedure TfrmAnalyze.SaveSettings;
begin
  inherited;
  UserStorage.SaveComponent(gsibgrAnalyze, gsibgrAnalyze.SaveToStream);
end;

procedure TfrmAnalyze.FormCreate(Sender: TObject);
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;

  ibdsAnalyze.Open;
end;

procedure TfrmAnalyze.actNewExecute(Sender: TObject);
begin
  with TdlgAnalyze.Create(Self) do
    try
      SetupDialog('');
      if ShowModal = mrOK then
      begin
        ibdsAnalyze.Close;
        ibdsAnalyze.Open;
      end;
    finally
      Free;
    end;
end;

procedure TfrmAnalyze.actEditExecute(Sender: TObject);
begin
  with TdlgAnalyze.Create(Self) do
    try
      SetupDialog(ibdsAnalyze.FieldByName('FieldName').AsString);
      if ShowModal = mrOK then
        ibdsAnalyze.Refresh;
    finally
      Free;
    end;
end;

procedure TfrmAnalyze.actDeleteExecute(Sender: TObject);
{var
  R: TatRelationField;}
begin
  if (MessageBox(HANDLE, PChar(Format('Удалить аналитику ''%s''?', [ibdsAnalyze.FieldByName('lname').AsString])),
    'Внимание',
     mb_YesNo or mb_IconQuestion) = idYes) and
     (MessageBox(HANDLE,
       PChar('Удаление аналитики приведет к потере всей информации по данному полю в ЖХО.'#13#10 +
             #13#10#9'Продожить?'), 'Внимание', mb_YesNo or mb_IconQuestion) = idYes)
  then
  begin
{    R := atDatabase.FindRelationField('GD_ENTRY', ibdsAnalyze.FieldByName('FIELDNAME').AsString);
    if Assigned(R) and R.Drop then
    begin
      R := atDatabase.FindRelationField('GD_ENTRYS', ibdsAnalyze.FieldByName('FIELDNAME').AsString);
      if Assigned(R) and R.Drop then
      begin
        R := atDatabase.FindRelationField('GD_CARDACCOUNT', ibdsAnalyze.FieldByName('FIELDNAME').AsString);
        R.Drop;
        ibdsAnalyze.Close;
        ibdsAnalyze.Open;
      end;
    end;}
  end;
end;

procedure TfrmAnalyze.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled := ibdsAnalyze.FieldByName('FieldName').AsString > '';
end;

procedure TfrmAnalyze.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := ibdsAnalyze.FieldByName('FieldName').AsString > '';
end;

initialization
  RegisterClass(TfrmAnalyze);

end.
