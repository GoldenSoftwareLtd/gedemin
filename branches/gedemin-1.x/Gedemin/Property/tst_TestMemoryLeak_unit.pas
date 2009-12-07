unit tst_TestMemoryLeak_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Db, IBDatabase, gdcTree, gdcClasses, gdcInvDocument_unit,
  IBCustomDataSet, gdcBase, gd_createable_form;

type
  TTestMemoryLeak = class(TCreateableForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    gdcInvDocument1: TgdcInvDocument;
    gdcInvDocumentLine1: TgdcInvDocumentLine;
    IBTransaction1: TIBTransaction;
    DataSource1: TDataSource;
    Button3: TButton;
    Label3: TLabel;
    Button4: TButton;
    Label4: TLabel;
    ibdsDoc: TIBDataSet;
    ibdsDocLine: TIBDataSet;
    Button5: TButton;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
    destructor Destroy; override; 
  end;

var
  TestMemoryLeak: TTestMemoryLeak;

implementation

uses
  rp_ReportScriptControl, dmClientReport_unit, rp_BaseReport_unit,
  gd_i_ScriptFactory, gd_SetDatabase;

{$R *.DFM}

procedure TTestMemoryLeak.Button1Click(Sender: TObject);
var
  I, J, K: Integer;
  TmpRep: TrpCustomFunction;
  Res: Variant;
  TmpTime: TTime;
begin
  TmpTime := Now;
  TmpRep := TrpCustomFunction.Create;
  try
    for J := 0 to 100 do
    begin
      TmpRep.Script.Add(Format('function TestFunction%d', [J]));
      TmpRep.Script.Add(Format('  TestFunction%d = 12', [J]));
      for I := 0 to 1000 do
        TmpRep.Script.Add('  '' Spam');
      TmpRep.Script.Add('end function');
      TmpRep.Language := 'VBScript';
      TmpRep.Name := Format('TestFunction%d', [J]);
      TmpRep.FunctionKey := J;
      for I := 0 to 100 do
        with TReportScript.Create(nil) do
        try
          OnCreateObject := dmClientReport.ClientReport1CreateObject;
          OnCreateConst := dmClientReport.gdScriptFactory1CreateConst;
          OnCreateGlobalObj := dmClientReport.gdScriptFactory1CreateGlobalObj;
          Res := VarArrayOf([]);
          for K := 0 to 100 do
            ExecuteFunction(TmpRep, Res);
      //    OnCreateVBClasses := dmClientReport.gd`
        finally
          Free;
        end;
    end;
  finally
    TmpRep.Free;
  end;
  Label1.Caption := DateTimeToStr(Now - TmpTime);
end;

procedure TTestMemoryLeak.Button2Click(Sender: TObject);
var
  I, J: Integer;
  TmpRep: TrpCustomFunction;
  Res: Variant;
  TmpTime: TTime;
begin
  TmpTime := Now;
  TmpRep := TrpCustomFunction.Create;
  try
    for J := 0 to 100 do
    begin
      TmpRep.Script.Add(Format('function TestFunction%d', [J]));
      TmpRep.Script.Add(Format('  TestFunction%d = 12', [J]));
      for I := 0 to 1000 do
        TmpRep.Script.Add('  '' Spam');
      TmpRep.Script.Add('end function');
      TmpRep.Language := 'VBScript';
      TmpRep.Name := Format('TestFunction%d', [J]);
      TmpRep.FunctionKey := J;
      Res := VarArrayOf([]);
      for I := 0 to 100 do
        ScriptFactory.ExecuteFunction(TmpRep, Res);
    end;
  finally
    TmpRep.Free;
  end;
  Label2.Caption := DateTimeToStr(Now - TmpTime);
end;

procedure TTestMemoryLeak.Button3Click(Sender: TObject);
var
  TmpTime: TTime;
  I, J: Integer;
begin
  TmpTime := Now;
  if not IBTransaction1.InTransaction then
    IBTransaction1.StartTransaction;
  try
    gdcInvDocument1.SubType := '147681010_20093613';
    gdcInvDocumentLine1.SubType := '147681010_20093613';
    gdcInvDocument1.Open;
    gdcInvDocumentLine1.Open;        
    for I := 0 to 300 do
    begin
      GdcInvDocument1.Insert;
      GdcInvDocument1.FieldByName('Usr$CustomerKey').AsInteger := 150754423;
      GdcInvDocument1.Post;
{      for J := 0 to 10 do
      begin
        GdcInvDocumentLine1.Insert;
        GdcInvDocumentLine1.FieldByName('GoodName').AsString := '103 141 02 80';
        GdcInvDocumentLine1.FieldByName('GoodKey').AsInteger := 147009010;
        GdcInvDocumentLine1.FieldByName('Quantity').AsCurrency := ((7 * 15) + 1);


        GdcInvDocumentLine1.Post;
      end;}
    end;
  finally
    if IBTransaction1.InTransaction then
      IBTransaction1.Commit;
  end;
  Label3.Caption := TimeToStr(Now - TmpTime);
end;

class function TTestMemoryLeak.CreateAndAssign(AnOwner: TComponent): TForm;
begin
  if not FormAssigned(TestMemoryLeak) then
    TestMemoryLeak := TTestMemoryLeak.Create(AnOwner);
  Result := TestMemoryLeak;
end;

destructor TTestMemoryLeak.Destroy;
begin
  if TestMemoryLeak = Self then
    TestMemoryLeak := nil;

  inherited;
end;

procedure TTestMemoryLeak.Button4Click(Sender: TObject);
var
  TmpTime: TTime;
  I, J: Integer;
begin
  TmpTime := Now;
  if not IBTransaction1.InTransaction then
    IBTransaction1.StartTransaction;
  try
    ibdsDoc.Open;
    ibdsDocLine.Open;
    for I := 0 to 1000 do
    begin
      ibdsDoc.Insert;
      ibdsDoc.FieldByName('documenttypekey').AsInteger := 147681010;
      ibdsDoc.FieldByName('companyKey').AsInteger := 147000007;
      ibdsDoc.FieldByName('id').AsInteger := GetUniqueKey(IBTransaction1.DefaultDatabase, IBTransaction1);
      ibdsDoc.FieldByName('documentdate').AsDateTime := Now;
      ibdsDoc.FieldByName('creatorkey').AsInteger := 650002;
      ibdsDoc.FieldByName('editorkey').AsInteger := 650002;
      ibdsDoc.FieldByName('number').AsInteger := 1;
      ibdsDoc.Post;
{      for J := 0 to 10 do
      begin
        ibdsDocLine.Insert;
        ibdsDocLine.FieldByName('id').AsInteger := GetUniqueKey(IBTransaction1.DefaultDatabase, IBTransaction1);
        ibdsDocLine.FieldByName('parent').AsInteger := ibdsDoc.FieldByName('id').AsInteger;
        ibdsDocLine.FieldByName('documenttypekey').AsInteger := 147681010;
        ibdsDocLine.FieldByName('GoodName').AsString := '103 141 02 80';
        ibdsDocLine.FieldByName('GoodKey').AsInteger := 147009010;
        ibdsDocLine.FieldByName('Quantity').AsCurrency := ((7 * 15) + 1);
        ibdsDocLine.FieldByName('number').AsInteger := 1;
        ibdsDocLine.FieldByName('documentdate').AsDateTime := Now;
        ibdsDocLine.FieldByName('creatorkey').AsInteger := 650002;
        ibdsDocLine.FieldByName('editorkey').AsInteger := 650002;


        ibdsDocLine.Post;
      end;}
    end;
  finally
    if IBTransaction1.InTransaction then
      IBTransaction1.Commit;
  end;
  Label4.Caption := TimeToStr(Now - TmpTime);
end;

procedure TTestMemoryLeak.Button5Click(Sender: TObject);
var
  I: Integer;
  TmpTime: TTime;
begin
  TmpTime := Now;
  for I := 0 to 100000 do
    with TIBDataSet.Create(nil) do
    try
    finally
      Free;
    end;
  Label5.Caption := TimeToStr(Now - TmpTime);
end;

end.
