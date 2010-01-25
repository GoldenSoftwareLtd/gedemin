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
  q: TIBSQL;
  sTmp, sRel, sType: string;
  i: integer;
begin
  gdcFunction.Close;
  q:= TIBSQL.Create(self);
  try
    q.Transaction:= gdcBaseManager.ReadTransaction;
    q.SQL.Text:=
      'SELECT                                                                                         ' +
      '  i_s1.rdb$field_name as fieldname,                                                            ' +
      '  rc1.rdb$relation_name as relationname                                                        ' +
      'FROM                                                                                           ' +
      '  RDB$RELATION_CONSTRAINTS RC                                                                  ' +
      '  JOIN rdb$ref_constraints ref_c ON ref_c.rdb$const_name_uq = rc.rdb$constraint_name           ' +
      '  JOIN rdb$relation_constraints rc1 ON rc1.rdb$constraint_name = ref_c.rdb$constraint_name AND ' +
      '    rc1.rdb$constraint_type = ''FOREIGN KEY''                                                  ' +
      '  JOIN rdb$index_segments i_s ON i_s.rdb$index_name = rc.rdb$index_name                        ' +
      '  JOIN rdb$index_segments i_s1 On i_s1.rdb$index_name = rc1.rdb$index_name                     ' +
      'WHERE                                                                                          ' +
      '  RC.RDB$RELATION_NAME = ''GD_FUNCTION'' AND i_s.rdb$field_name = ''ID''';
    q.ExecQuery;
    i:= 0;
    sTmp:= '';
    while not q.Eof do begin
      if (AnsiUpperCase(Trim(q.FieldByName('relationname').AsString)) = 'RP_ADDITIONALFUNCTION') and
         (AnsiUpperCase(Trim(q.FieldByName('fieldname').AsString)) = 'MAINFUNCTIONKEY') then begin
        q.Next;
        Continue;
      end;
      sTmp:= sTmp + ' AND '#13#10;
      sRel:= ' rel' + IntToStr(i);
      Inc(i);
      sTmp:= sTmp + ' NOT EXISTS (SELECT * FROM ' + q.FieldByName('relationname').AsString + sRel +
        ' WHERE z.id =' + sRel + '.' + q.FieldByName('fieldname').AsString + ') ';
      q.Next;
    end;
  finally
    q.Free;
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
