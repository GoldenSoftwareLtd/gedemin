// ShlTanya, 25.02.2019

unit prp_frmLooseFunction_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  dmImages_unit, Db, TB2Item, ActnList, StdCtrls, ExtCtrls, ibsql,
  IBCustomDataSet, gdcBase, gdcCustomFunction, gdcFunction, Grids, DBGrids,
  gsDBGrid, gsIBGrid, TB2Dock, TB2Toolbar, IBDatabase, gdcBaseInterface,
  gdc_createable_form;

type
  TfrmLooseFunctions = class(TgdcCreateableForm)
    ibgrMain: TgsIBGrid;
    gdcFunction: TgdcFunction;
    pnlBottom: TPanel;
    btnOkChoose: TButton;
    btnCancelChoose: TButton;
    alMain: TActionList;
    actEdit: TAction;
    actDelete: TAction;
    actOk: TAction;
    actCancel: TAction;
    dsFunction: TDataSource;
    ibtrMain: TIBTransaction;
    TBDock: TTBDock;
    tb: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    actRun: TAction;
    TBItem3: TTBItem;
    TBSeparatorItem1: TTBSeparatorItem;
    TBControlItem2: TTBControlItem;
    chkEvent: TCheckBox;
    TBControlItem3: TTBControlItem;
    chkMethod: TCheckBox;
    TBControlItem4: TTBControlItem;
    chkReport: TCheckBox;
    TBControlItem5: TTBControlItem;
    chkOther: TCheckBox;
    TBSeparatorItem2: TTBSeparatorItem;
    TBControlItem1: TTBControlItem;
    Label1: TLabel;
    TBSeparatorItem3: TTBSeparatorItem;
    procedure actOkExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actEditUpdate(Sender: TObject);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actRunUpdate(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure chkEventClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  cModuleReport = 'module LIKE ''REPORT%''';
  cModuleEvent = 'module = ''EVENTS''';
  cModuleMethod = 'module = ''METHOD''';
  cModuleUnknown = 'module = ''UNKNOWN''';

var
  frmLooseFunctions: TfrmLooseFunctions;

implementation

{$R *.DFM}

uses
  ContNrs, at_classes;

procedure TfrmLooseFunctions.FormCreate(Sender: TObject);
begin
  ibtrMain.DefaultDataBase:= gdcBaseManager.Database;
  ibtrMain.StartTransaction;
//  gdcFunction.Extraconditions.Add('z.id = 0');
//  gdcFunction.Open;
  actRun.Execute;
end;

procedure TfrmLooseFunctions.actOkExecute(Sender: TObject);
begin
  ibtrMain.Commit;
  ModalResult:= mrOk;
end;

procedure TfrmLooseFunctions.actCancelExecute(Sender: TObject);
begin
  ibtrMain.Rollback;
  ModalResult:= mrCancel;
end;

procedure TfrmLooseFunctions.actEditExecute(Sender: TObject);
begin
  gdcFunction.EditDialog('');
end;

procedure TfrmLooseFunctions.actEditUpdate(Sender: TObject);
begin
  actEdit.Enabled:= gdcFunction.ID > 0;
end;

procedure TfrmLooseFunctions.actDeleteExecute(Sender: TObject);
begin
  gdcFunction.Delete;
end;

procedure TfrmLooseFunctions.ibgrMainDblClick(Sender: TObject);
begin
  actEdit.Execute;
end;

procedure TfrmLooseFunctions.actRunExecute(Sender: TObject);
var
  sTmp, sRel, sType: string;
  i: integer;
  Lst: TObjectList;
  FK: TatForeignKey;
begin
  gdcFunction.Close;

  Lst := TObjectList.Create(False);
  try
    atDatabase.ForeignKeys.ConstraintsByReferencedRelation('GD_FUNCTION', Lst);
    for I := 0 to Lst.Count - 1 do
    begin
      FK := Lst[I] as TatForeignKey;

      if (FK.Relation.RelationName = 'RP_ADDITIONALFUNCTION') and
         (FK.ConstraintFields[0].FieldName = 'MAINFUNCTIONKEY') then
        continue;

      sTmp:= sTmp + ' AND '#13#10;
      sRel:= ' rel' + IntToStr(i);
      sTmp:= sTmp + ' NOT EXISTS (SELECT * FROM ' + FK.Relation.RelationName + sRel +
        ' WHERE z.id =' + sRel + '.' + FK.ConstraintFields[0].FieldName + ') ';
    end;
  finally
    Lst.Free;
  end;

  sTmp:= sTmp +
    ' AND NOT EXISTS (SELECT * FROM gd_command gdc JOIN gd_p_getruid(z.id) gdpruid ON ' +
    'gdc.cmd = gdpruid.XID || ''_'' || gdpruid.dbid AND gdc.cmdtype = 1)';

  sType:= '';
  if chkEvent.Checked then
    sType:= cModuleEvent;
  if chkReport.Checked then begin
    if sType <> '' then
      sType:= sType + ' OR ';
    sType:= sType + cModuleReport;
  end;
  if chkMethod.Checked then begin
    if sType <> '' then
      sType:= sType + ' OR ';
    sType:= sType + cModuleMethod;
  end;
  if chkOther.Checked then begin
    if sType <> '' then
      sType:= sType + ' OR ';
    sType:= sType + cModuleUnknown;
  end;
  if sType > '' then
    sTmp := '(' + sType + ')' + sTmp
  else
    sTmp := 'z.id = 0';
  gdcFunction.Extraconditions.Clear;
  gdcFunction.Extraconditions.Add(sTmp);
  gdcFunction.Open;
end;

procedure TfrmLooseFunctions.actRunUpdate(Sender: TObject);
begin
  //TAction(Sender).Enabled:= chkEvent.Checked or chkReport.Checked or chkMethod.Checked or chkOther.Checked
end;

procedure TfrmLooseFunctions.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled:= gdcFunction.ID > 0;
end;

procedure TfrmLooseFunctions.chkEventClick(Sender: TObject);
begin
  actRun.Execute;
end;

end.
