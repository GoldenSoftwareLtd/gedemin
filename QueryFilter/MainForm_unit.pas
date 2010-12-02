unit MainForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_security, flt_sqlFilter, StdCtrls, Db, Grids, DBGrids,
  IBCustomDataSet, IBQuery, Menus, DBCommon, gsDBGrid, fcCombo, fctreecombo,
  gsComboElements, gsIBGrid, flt_sql_parser, IBTable, ActnList;

type
  TForm1 = class(TForm)
    Button1: TButton;
    IBQuery1: TIBQuery;
    DataSource1: TDataSource;
    PopupMenu1: TPopupMenu;
    gsQueryFilter1: TgsQueryFilter;
    Button2: TButton;
    fcTreeCombo1: TfcTreeCombo;
    Button3: TButton;
    gsComboButton1: TgsComboButton;
    MainMenu1: TMainMenu;
    N11: TMenuItem;
    N21: TMenuItem;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    gsIBGrid1: TgsIBGrid;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    IBDataSet1: TIBDataSet;
    IBTable1: TIBTable;
    ActionList1: TActionList;
    Action1: TAction;
    Action2: TAction;
    Button8: TButton;
    IBQuery2: TIBQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure IBQuery1BeforeOpen(DataSet: TDataSet);
    procedure IBQuery1BeforeDatabaseDisconnect(Sender: TObject);
    procedure IBQuery1BeforeTransactionEnd(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure gsComboButton1CloseUp(Sender: TObject; AnIndex: Integer);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    QueryFilter: TgsQueryFilter;
  end;

var
  Form1: TForm1;

implementation

uses flt_sqlfilter_condition_type, dmDataBase_unit, gd_security_OperationConst,
  flt_dlgFunctionMaster_unit, flt_dlgShowFilter_unit, flt_dlgCreateProcedure_unit,
  flt_frmSQLEditor_unit;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBLogin.SubSystemKey := GD_SYS_GADMIN;
//  QueryFilter := TgsQueryFilter.Create(Self);
  if not IBLogin.Login then
    Application.Terminate
  else
  begin
{    QueryFilter.Database := IBLogin.Database;
    QueryFilter.Transaction := IBLogin.Database.DefaultTransaction;
    QueryFilter.TableList.Add('GD_PEOPLE=gp.');
    QueryFilter.TableList.Add('GD_CONTACT=gc.');
    QueryFilter.SelectText.Text := 'SELECT DISTINCT(gc.id), gc.*, gp.* ';
    QueryFilter.FromText.Text := 'FROM gd_contact gc, gd_people gp';
    QueryFilter.WhereText.Text := 'WHERE gp.contactkey = gc.id';
    QueryFilter.IBQuery := IBQuery1;
    IBQuery1.Open;
    QueryFilter.FilterQuery;}

    dmDatabase.ibtrAttr.StartTransaction;
    IBDataSet1.ParamByName('lb').AsInteger := 40;
    IBDataSet1.ParamByName('rb').AsInteger := 640;
//    IBDataSet1.Open;
    IBQuery2.Open;

    {IBQuery1.ParamByName('lb').AsInteger := 40;
    IBQuery1.ParamByName('rb').AsInteger := 640;
    IBQuery1.Open;
    {with TgsPopupCustomBox.Create(Self) do
    begin
      Parent := Self;
      Items.Add('1');
      Items.Add('2');
      Items.Add('3');
      Items.Add('4');
      Items.Add('5');
      Items.Add('6');
      Items.Add('7');
      Items.Add('8');
      Left := 100;
      Height := 50;
    end;}
  end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
//  QueryFilter.Free;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  Str: TMemoryStream;
  SL: TStringList;
begin
  SL := TStringList.Create;
  try
    ExtractFieldLink(IBQuery1.SQL.Text, SL);
  finally
    SL.Free;
  end;

//  gsQueryFilter1.ShowDialogAndQuery;
{  QueryFilter.ShowDialogAndQuery;
  Str := TMemoryStream.Create;
  try
    QueryFilter.WriteToStream(Str);
    Str.Position := 0;
    QueryFilter.ReadFromStream(Str);
  finally
    Str.Free;
  end;}
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Start: PChar;
  Token: string;
  SQLToken, CurSection: TSQLToken;
  I: Integer;
begin
//  I := PR_LONG;
//  SaveDialog1.Execute;
{  Start := PChar(IBQuery1.SQL.Text);
  repeat
    SQLToken := NextSQLToken(Start, Token, CurSection);
    if SQLToken in SQLSections then CurSection := SQLToken;
  until SQLToken in [stEnd];}

//  ShowMessage(GetTableNameFromSQL(IBQuery1.SQL.Text));
end;

procedure TForm1.IBQuery1BeforeOpen(DataSet: TDataSet);
begin
  Beep;
end;

procedure TForm1.IBQuery1BeforeDatabaseDisconnect(Sender: TObject);
begin
//
end;

procedure TForm1.IBQuery1BeforeTransactionEnd(Sender: TObject);
begin
//
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if not Assigned(dlgFunctionMaster) then
  begin
    dlgFunctionMaster := TdlgFunctionMaster.Create(Self);
    dlgFunctionMaster.SetupDialog;
  end;

  dlgFunctionMaster.ShowModal;
end;

procedure TForm1.gsComboButton1CloseUp(Sender: TObject; AnIndex: Integer);
begin
  ShowMessage(gsComboButton1.Items[AnIndex]);
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  ShowMessage(IntToStr(gsQueryFilter1.RecordCount));
end;

procedure TForm1.Button5Click(Sender: TObject);
var
  F: TdlgShowFilter;
  CL: TFilterConditionList;
begin
  F := TdlgShowFilter.Create(Self);
  try
    CL := TFilterConditionList.Create;
    try
      F.Database := dmDatabase.ibdbGAdmin;
      F.Transaction := nil; // я удалил ibtr_GAdmin, так что тут надо поставить свою транзакцию -- andreik
      F.ShowLinkTableFilter(CL, 'MSG_TARGET', 'MESSAGEKEY');
      F.ShowLinkTableFilter(CL, 'MSG_TARGET', 'MESSAGEKEY');
    finally
      CL.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TForm1.Button6Click(Sender: TObject);
var
  F: TdlgCreateProcedure;
begin
  F := TdlgCreateProcedure.Create(Self);
  try
    F.ibsqlCreate.Database := IBLogin.Database;
    F.ibtrCreateProcedure.DefaultDatabase := IBLogin.Database;
    F.EditProcedure('GD_P_SEC_LOGINUSER');
  finally
    F.Free;
  end;
end;

procedure TForm1.Button7Click(Sender: TObject);
begin
  with TfrmSQLEditor.Create(Self) do
  try
    FDatabase := IBQuery1.Database;
    ShowSQL('SELECT * FROM gd_good');
  finally
    Free;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  PopupMenu1.Popup(ClientToScreen(Point((Sender as TButton).Left, (Sender as TButton).Top)).x,
   ClientToScreen(Point((Sender as TButton).Left, (Sender as TButton).Top)).y);
end;

end.
