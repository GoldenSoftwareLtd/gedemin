
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{             Datasets list                }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_List;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DB, StdCtrls, ComCtrls, ExtCtrls, FR_Const, FR_DBRel
  {$IFDEF Delphi4}, ImgList {$ENDIF};

type
  TfrDatasetsForm = class(TForm)
    LV1: TListView;
    PropB: TButton;
    NewTableB: TButton;
    RemoveB: TButton;
    ExitB: TButton;
    ImageList1: TImageList;
    NewQueryB: TButton;
    Label1: TLabel;
    NewDatabaseB: TButton;
    OpenDB: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure LV1Change(Sender: TObject; Item: TListItem;
      Change: TItemChange);
    procedure NewTableBClick(Sender: TObject);
    procedure RemoveBClick(Sender: TObject);
    procedure PropBClick(Sender: TObject);
    procedure NewQueryBClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure NewDatabaseBClick(Sender: TObject);
    procedure LV1Editing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
  private
    { Private declarations }
    procedure FillList;
  public
    { Public declarations }
  end;


implementation

uses
  FR_Class, FR_DSet, FR_DBSet, FRD_Mngr, FRD_DB, FRD_Tbl, FRD_Tbl1,
  FRD_Form, FRD_Wrap, FRD_Qry, FR_Utils
{$IFDEF ADO}
, ADODB, ADOInt
{$ENDIF};

{$R *.DFM}

procedure TfrDatasetsForm.FormCreate(Sender: TObject);
begin
  FillList;
  PropB.Enabled := False;
  RemoveB.Enabled := False;

  Caption := frLoadStr(frRes + 3000);
  PropB.Caption := frLoadStr(frRes + 3001);
  NewTableB.Caption := frLoadStr(frRes + 3002);
  NewQueryB.Caption := frLoadStr(frRes + 3003);
  RemoveB.Caption := frLoadStr(frRes + 3004);
  ExitB.Caption := frLoadStr(frRes + 3005);
  NewDatabaseB.Caption := frLoadStr(frRes + 3006);
end;

procedure TfrDatasetsForm.FillList;
var
  i: Integer;
  c: TComponent;
  li: TListItem;
begin
  LV1.Items.Clear;
  for i := 0 to frDataModule.ComponentCount - 1 do
  begin
    c := frDataModule.Components[i];
    if c is TfrTable then
    begin
      li := LV1.Items.Add;
      li.Caption := c.Name;
      li.ImageIndex := 0;
    end
    else if c is TfrQuery then
    begin
      li := LV1.Items.Add;
      li.Caption := c.Name;
      li.ImageIndex := 1;
    end
    else if c is TfrDatabase then
    begin
      li := LV1.Items.Add;
      li.Caption := c.Name;
      li.ImageIndex := 2;
    end;
  end;
end;

procedure TfrDatasetsForm.LV1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
var
  c: TComponent;
  s: String;
begin
  c := frDataModule.FindComponent(Item.Caption);
  s := '';
  if c <> nil then
    if c is TDataSet then
      s := GetDataPath(c as TDataSet) else
      s := TfrDatabase(c).frDatabaseName;
  if LV1.Selected <> nil then
  begin
    PropB.Enabled := True;
    RemoveB.Enabled := True;
  end
  else
  begin
    PropB.Enabled := False;
    RemoveB.Enabled := False;
  end;
  if s <> '' then
    Label1.Caption := ' ' + frLoadStr(SPath) + ': ' + s else
    Label1.Caption := '';
end;

procedure TfrDatasetsForm.RemoveBClick(Sender: TObject);
var
  c: TComponent;
  d: TDataSet;
  ds: TDataSource;
  ds1: TfrDataSet;
begin
  if LV1.Selected <> nil then
    if MessageBox(0, PChar(frLoadStr(SRemoveDS)), PChar(frLoadStr(SConfirm)),
      mb_YesNo + mb_IconQuestion) = mrYes then
    begin
      frDesigner.Modified := True;
      c := frDataModule.FindComponent(LV1.Selected.Caption);
      if c is TDataSet then
      begin
        d := c as TDataSet;
        if d <> nil then
        begin
          ds1 := GetFRDataset(d);
          if ds1 <> nil then
            ds1.Free;
          ds := GetDataSource(d);
          if ds <> nil then
            ds.Free;
          d.Free;
        end;
      end
      else
        c.Free;
      FillList;
    end;
end;

procedure TfrDatasetsForm.PropBClick(Sender: TObject);
var
  c: TComponent;
  d: TDataSet;
  db: TfrDatabase;
  d1: TfrDBDataSet;
  ds: TDataSource;
  li: TListItem;
  TablePropForm: TfrTablePropForm;
  QueryPropForm: TfrQueryPropForm;
  DBPropForm: TfrDBPropForm;
begin
  if LV1.Selected <> nil then
  begin
    li := LV1.Selected;
    c := frDataModule.FindComponent(li.Caption);
    if c is TDataSet then
    begin
      d := c as TDataSet;
      d1 := GetFRDataSet(d);
      ds := GetDataSource(d);
      if d is TfrTable then
      begin
        TablePropForm := TfrTablePropForm.Create(nil);
        with TablePropForm do
        begin
          Table := d as TfrTable;
          if ShowModal = mrOk then
            frDesigner.Modified := True;
          Free;
        end;
      end
      else
      begin
        QueryPropForm := TfrQueryPropForm.Create(nil);
        with QueryPropForm do
        begin
          Query := d as TfrQuery;
          if ShowModal = mrOk then
            frDesigner.Modified := True;
          Free;
        end;
      end;
      d1.Name := '_' + d.Name;
      ds.Name := 'S' + d.Name;
      li.Caption := d.Name;
      LV1.SetFocus;
    end
    else
    begin
      db := c as TfrDatabase;
      DBPropForm := TfrDBPropForm.Create(nil);
      with DBPropForm do
      begin
        Database := db;
        if ShowModal = mrOk then
          frDesigner.Modified := True;
        Free;
      end;
      li.Caption := db.Name;
      LV1.SetFocus;
    end;
  end;
end;

procedure TfrDatasetsForm.NewDatabaseBClick(Sender: TObject);
var
  i: Integer;
  d: TfrDatabase;
  DBPropForm: TfrDBPropForm;
begin
  i := 1;
  while frDataModule.FindComponent('Database' + IntToStr(i)) <> nil do
    Inc(i);
  d := TfrDatabase.Create(frDataModule);
  d.Name := 'Database' + IntToStr(i);

  DBPropForm := TfrDBPropForm.Create(nil);
  with DBPropForm do
  begin
    Database := d;
    if ShowModal <> mrOk then
      d.Free else
      frDesigner.Modified := True;
    Free;
  end;
  FillList;
end;

procedure TfrDatasetsForm.NewTableBClick(Sender: TObject);
var
  i: Integer;
  t: TfrTable;
  d: TDataSource;
  d1: TfrDBDataSet;
  TablePropForm: TfrTablePropForm;
  SelectTblForm: TfrSelectTblForm;
begin
  SelectTblForm := TfrSelectTblForm.Create(nil);
  if SelectTblForm.ShowModal = mrOk then
  begin
    i := 1;
    while frDataModule.FindComponent('Table' + IntToStr(i)) <> nil do
      Inc(i);
    t := TfrTable.Create(frDataModule);
    t.Name := 'Table' + IntToStr(i);
    t.frDatabaseName := SelectTblForm.DBName;
    t.TableName := SelectTblForm.TableName;

    d := TDataSource.Create(frDataModule);
    d.DataSet := t;
    d.Name := 'S' + t.Name;

    d1 := TfrDBDataSet.Create(frDataModule);
    d1.DataSource := d;
    d1.Name := '_' + t.Name;
    d1.CloseDataSource := True;

    TablePropForm := TfrTablePropForm.Create(nil);
    with TablePropForm do
    begin
      Table := t;
      if ShowModal <> mrOk then
      begin
        d1.Free;
        d.Free;
        t.Free;
      end
      else
      begin
        d.Name := 'S' + t.Name;
        d1.Name := '_' + t.Name;
        frDesigner.Modified := True;
      end;
      Free;
    end;
    FillList;
  end;
  SelectTblForm.Free;
end;

procedure TfrDatasetsForm.NewQueryBClick(Sender: TObject);
var
  i: Integer;
  q: TfrQuery;
  d: TDataSource;
  d1: TfrDBDataSet;
  QueryPropForm: TfrQueryPropForm;
begin
  i := 1;
  while frDataModule.FindComponent('Query' + IntToStr(i)) <> nil do
    Inc(i);
  q := TfrQuery.Create(frDataModule);
  q.Name := 'Query' + IntToStr(i);
  q.frDatabaseName := '';

  d := TDataSource.Create(frDataModule);
  d.DataSet := q;
  d.Name := 'S' + q.Name;

  d1 := TfrDBDataSet.Create(frDataModule);
  d1.DataSource := d;
  d1.Name := '_' + q.Name;
  d1.CloseDataSource := True;

  QueryPropForm := TfrQueryPropForm.Create(nil);
  with QueryPropForm do
  begin
    Query := q;
    if ShowModal <> mrOk then
    begin
      d1.Free;
      d.Free;
      q.Free;
    end
    else
    begin
      d.Name := 'S' + q.Name;
      d1.Name := '_' + q.Name;
      frDesigner.Modified := True;
    end;
    Free;
  end;
  FillList;
end;

procedure TfrDatasetsForm.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i, n: Integer;
  s, qname, pname: String;
  q: TfrQuery;
begin
  i := 0;
  while i < frSpecialParams.Count do
  begin
    s := frSpecialParams.Name[i];
    n := Pos('.', s);
    qname := Copy(s, 1, n - 1);
    pname := Copy(s, n + 1, 255);
    q := frDataModule.FindComponent(qname) as TfrQuery;
    if (q <> nil) and (q.frParams.ParamIndex(pname) <> -1) then
      Inc(i) else
      frSpecialParams.Delete(i);
  end;
end;

procedure TfrDatasetsForm.LV1Editing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := False;
end;

end.

