unit TestObjectMain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  rp_ReportScriptControl, IBDatabase, Db, StdCtrls, ExtCtrls, rp_BaseReport_unit,
  rp_report_const, ActiveX, OleCtrls, MSScriptControl_TLB, rp_ReportServer,
  ComCtrls, to_fr_ReportPage, ToolWin, ActnList, ImgList, gd_security, Provider, DBClient;

const
  DefaultPage = 1;
  PageFileName = 'TestObject.tob';

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    IBDatabase1: TIBDatabase;
    IBTransaction1: TIBTransaction;
    Button2: TButton;
    PageControl1: TPageControl;
    tsMain: TTabSheet;
    frReportPage1: TfrReportPage;
    Button3: TButton;
    Button4: TButton;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ActionList1: TActionList;
    actLoad: TAction;
    actSave: TAction;
    actSQL: TAction;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ImageList1: TImageList;
    ClientDataSet1: TClientDataSet;
    DataSetProvider1: TDataSetProvider;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ReportScript1CreateObject(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure actLoadExecute(Sender: TObject);
    procedure actSaveExecute(Sender: TObject);
    procedure actSQLExecute(Sender: TObject);
  private
    FReportScript: TReportScript;
    FBaseReport: TBaseReport;
    FDefaultPages: TList;

    procedure ExecuteFunction(const AnLanguage, AnFunctionName, AnScriptText, AnModuleName: String);
    function AddPage(const AnUseQuery: Boolean = True): TTabSheet;
    procedure ClearPage;
    procedure DeletePage;
    procedure DeleteCurrentPage(var CurrentPage: TTabSheet);
    procedure LoadPages;
    procedure SavePages;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  Gedemin_TLB, obj_QueryList, rp_dlgEnterParam_unit, flt_frmSQLEditor_unit,
  {obj_Gedemin, }gd_security_OperationConst;

{$R *.DFM}

function TForm1.AddPage(const AnUseQuery: Boolean = True): TTabSheet;
var
  PageCaption: String;
begin
  Result := nil;
  if not AnUseQuery or InputQuery('Наименование страницы', 'Введите наименование страницы:', PageCaption) then
  begin
    Result := TTabSheet.Create(nil);
    try
      Result.Caption := PageCaption;
      Result.Parent := PageControl1;
      Result.PageControl := PageControl1;
      Result.Tag := Integer(TfrReportPage.Create(nil));
      TfrReportPage(Result.Tag).Parent := Result;
      TfrReportPage(Result.Tag).edName.Text := '';
      TfrReportPage(Result.Tag).mmScript.Lines.Text := '';
    except
      on E: Exception do
      begin
        MessageBox(Self.Handle, PChar(E.Message), 'Ошибка', MB_OK or MB_ICONERROR);
        FreeAndNil(Result);
      end;
    end;
  end;
end;

procedure TForm1.ClearPage;
var
  I: Integer;
  TempPage: TTabSheet;
begin
  for I := PageControl1.PageCount - 1 downto 0{DefaultPage - 1} do
  begin
    TempPage := PageControl1.Pages[I];
    DeleteCurrentPage(TempPage);
  end;
end;

procedure TForm1.DeletePage;
var
  TempPage: TTabSheet;
begin
  if PageControl1.ActivePage <> nil then
  begin
    TempPage := PageControl1.ActivePage;
    DeleteCurrentPage(TempPage);
  end;
end;

procedure TForm1.DeleteCurrentPage(var CurrentPage: TTabSheet);
begin
  if FDefaultPages.IndexOf(CurrentPage) = -1 then
  begin
    TfrReportPage(CurrentPage.Tag).Free;
    FreeAndNil(CurrentPage);
  end;
end;

procedure TForm1.LoadPages;
var
  FStr: TFileStream;
  LocPageCount, TempInt: Integer;
  TempStr: String;
  I: Integer;
  TempTabSheet: TTabSheet;
begin
  if FileExists(PageFileName) then
  begin
    FStr := TFileStream.Create(PageFileName, fmOpenRead);
    try
      TempInt := PageControl1.PageCount;
      FStr.ReadBuffer(LocPageCount, SizeOf(LocPageCount));
      for I := 0 to LocPageCount - 1 do
      begin
        TempTabSheet := AddPage(False);
        with TfrReportPage(TempTabSheet.Tag) do
        begin
          FStr.ReadBuffer(TempInt, SizeOf(TempInt));
          SetLength(TempStr, TempInt);
          FStr.Read(TempStr[1], TempInt);
          TempTabSheet.Caption := TempStr;

          FStr.Read(TempInt, SizeOf(TempInt));
          SetLength(TempStr, TempInt);
          FStr.Read(TempStr[1], TempInt);
          edName.Text := TempStr;

          FStr.Read(TempInt, SizeOf(TempInt));
          SetLength(TempStr, TempInt);
          FStr.Read(TempStr[1], TempInt);
          cbLanguage.Text := TempStr;

          FStr.Read(TempInt, SizeOf(TempInt));
          SetLength(TempStr, TempInt);
          FStr.Read(TempStr[1], TempInt);
          cbModule.Text := TempStr;

          FStr.Read(TempInt, SizeOf(TempInt));
          SetLength(TempStr, TempInt);
          FStr.Read(TempStr[1], TempInt);
          mmScript.Lines.Text := TempStr;
        end;
      end;
    finally
      FStr.Free;
    end;
  end;
end;

procedure TForm1.SavePages;
var
  FStr: TFileStream;
  TempInt: Integer;
  TempStr: String;
  I: Integer;
begin
  FStr := TFileStream.Create(PageFileName, fmCreate);
  try
    TempInt := PageControl1.PageCount - FDefaultPages.Count;
    FStr.Write(TempInt, SizeOf(TempInt));
    for I := 0 to PageControl1.PageCount - 1 do
      if FDefaultPages.IndexOf(PageControl1.Pages[I]) = -1 then
        with TfrReportPage(PageControl1.Pages[I].Tag) do
        begin
          TempStr := PageControl1.Pages[I].Caption;
          TempInt := Length(TempStr);
          FStr.Write(TempInt, SizeOf(TempInt));
          FStr.Write(TempStr[1], TempInt);

          TempStr := edName.Text;
          TempInt := Length(TempStr);
          FStr.Write(TempInt, SizeOf(TempInt));
          FStr.Write(TempStr[1], TempInt);

          TempStr := cbLanguage.Text;
          TempInt := Length(TempStr);
          FStr.Write(TempInt, SizeOf(TempInt));
          FStr.Write(TempStr[1], TempInt);

          TempStr := cbModule.Text;
          TempInt := Length(TempStr);
          FStr.Write(TempInt, SizeOf(TempInt));
          FStr.Write(TempStr[1], TempInt);

          TempStr := mmScript.Lines.Text;
          TempInt := Length(TempStr);
          FStr.Write(TempInt, SizeOf(TempInt));
          FStr.Write(TempStr[1], TempInt);
        end;
  finally
    FStr.Free;
  end;
end;

procedure TForm1.ExecuteFunction(const AnLanguage, AnFunctionName, AnScriptText, AnModuleName: String);
var
  LocFunction: TWriteFunction;
  LocReportResult: TReportResult;
  LocParam: Variant;
  ErrorMessage: String;
begin
  LocFunction := TWriteFunction.Create;
  try
    LocFunction.Name := AnFunctionName;
    LocFunction.Module := AnModuleName;
    LocFunction.Script.Text := AnScriptText;
    LocFunction.Language := AnLanguage;

    LocReportResult := TReportResult.Create;
    try
      if FBaseReport.ExecuteFunctionWithParam(LocFunction, LocReportResult, LocParam) then
        if AnModuleName = MainModuleName then
          LocReportResult.ViewResult
        else
          if AnModuleName = ParamModuleName then
            with TdlgEnterParam.Create(Self) do
            try
              ViewParam(LocParam);
            finally
              Free;
            end
          else
            if AnModuleName = EventModuleName then
              {}
            else
              {}
      else
      begin
        ErrorMessage := LocParam;
        MessageBox(Self.Handle, @ErrorMessage[1], 'Ошибка', MB_OK or MB_ICONERROR);
      end
    finally
      LocReportResult.Free;
    end;
  finally
    LocFunction.Free;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if PageControl1.ActivePage <> nil then
  with TfrReportPage(PageControl1.ActivePage.Tag) do
    ExecuteFunction(cbLanguage.Text, edName.Text, mmScript.Lines.Text, cbModule.Text);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  I: Integer;
begin
//  IBLogin.SubSystemKey := GD_SYS_GADMIN;
//  if IBLogin.Login then
  begin
    IBDatabase1.Connected := True;
    OleInitialize(nil);
    FDefaultPages := TList.Create;
    tsMain.Tag := Integer(frReportPage1);
    TfrReportPage(tsMain.Tag).cbLanguage.ItemIndex := 0;
    TfrReportPage(tsMain.Tag).cbModule.ItemIndex := 0;
    for I := 0 to PageControl1.PageCount - 1 do
      FDefaultPages.Add(PageControl1.Pages[I]);
    LoadPages;
  {  FReportScript := TReportScript.Create(Self);
    FReportScript.Transaction := IBTransaction1;
    FReportScript.Database := IBDatabase1;}
  //  FReportScript := ReportScript1;
    FBaseReport := TBaseReport.Create(Self);
    FBaseReport.OnCreateObject := ReportScript1CreateObject;
    FBaseReport.Database := IBDatabase1;
    FBaseReport.Refresh;
  end {else
    Application.Terminate};
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
//  if IBLogin.LoggedIn then
  begin
  //  FReportScript.Free;
    SavePages;
    ClearPage;

    FDefaultPages.Free;
    OleUninitialize;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
{var
  IQueryList: IgsQueryList;}
begin
{  IQueryList := ReportScript1.objQueryList;
  IQueryList.Add('www', False);
  IQueryList.Query[0].SQL := '';
  IQueryList.Query[0].IsResult := True;}
end;

procedure TForm1.ReportScript1CreateObject(Sender: TObject);
begin
  (Sender as TReportScript).AddObject(ReportObjectName,
   TgsQueryList.Create({(Sender as TReportScript).}IBDatabase1, IBTransaction1), False);
(*  (Sender as TReportScript).AddObject('System', TgsGedemin.Create(
   {(Sender as TReportScript).}IBDatabase1, IBTransaction1), False);*)
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  AddPage;
{
Function testfunction
  BaseQuery.Clear
  FQuery = BaseQuery.Add("ddd", 0)
  Set SourceQuery = BaseQuery.Query(FQuery)
  SourceQuery.SQL = "SELECT * FROM gd_user"
  SourceQuery.Open
  SourceQuery.IsResult = 1

  SQuery = BaseQuery.Add("ClientDataSet", 1)
  Set TargetTable = BaseQuery.Query(SQuery)
  Call TargetTable.AddField("id", "ftInteger", 0, 0)
  Call TargetTable.AddField("name", "ftString", 50, 0)
  TargetTable.Open

  SourceQuery.First
  Do While not SourceQuery.Eof
    TargetTable.Append
    TargetTable.FieldByName("name").AsString = SourceQuery.FieldByName("name").AsString
    TargetTable.FieldByName("id").AsInteger = SourceQuery.FieldByName("id").AsInteger
    TargetTable.Post

    SourceQuery.Next
  Loop

  TargetTable.IsResult = 1

  Set testfunction = BaseQuery
End Function
}
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  DeletePage;
end;

procedure TForm1.actLoadExecute(Sender: TObject);
begin
  if (PageControl1.ActivePage <> nil) and OpenDialog1.Execute then
    TfrReportPage(PageControl1.ActivePage.Tag).mmScript.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.actSaveExecute(Sender: TObject);
begin
  if (PageControl1.ActivePage <> nil) and SaveDialog1.Execute then
    TfrReportPage(PageControl1.ActivePage.Tag).mmScript.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.actSQLExecute(Sender: TObject);
begin
  if (PageControl1.ActivePage <> nil) then
    with TfrmSQLEditor.Create(nil) do
    try
      IBDatabase1.Connected := True;
      FDatabase := IBDatabase1;
      ShowSQL(TfrReportPage(PageControl1.ActivePage.Tag).mmScript.SelText);
    finally
      Free;
    end;
end;

end.
