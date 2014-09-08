unit wiz_dlgCustumAnalytic_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, gsIBLookupComboBox, ActnList, IBDatabase, at_classes,
  gdcBase, TB2Item, TB2Dock, TB2Toolbar, gdcBaseInterface, gd_ClassList,
  Contnrs;

type
  TCustomAnalyticForm = class(TForm)
    bCancel: TButton;
    bOK: TButton;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    cbNeedId: TCheckBox;
    cbAnalyticValue: TgsIBLookupComboBox;
    Bevel1: TBevel;
    Transaction: TIBTransaction;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    cbBO: TComboBox;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure cbAnalyticNameChange(Sender: TObject);
    procedure cbBODropDown(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FValue: string;
    FSubTypeList: TStrings;
    procedure SetValue(const Value: string);
    function GetValue: string;
    { Private declarations }
  public
    { Public declarations }
    property Value: string read GetValue write SetValue;
    function BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
  end;

function CustomAnalyticForm: TCustomAnalyticForm;
implementation
var
  _CustomAnalyticForm: TCustomAnalyticForm;

function CustomAnalyticForm: TCustomAnalyticForm;
begin
  if _CustomAnalyticForm = nil then
  begin
    _CustomAnalyticForm := TCustomAnalyticForm.Create(nil);
  end;

  Result := _CustomAnalyticForm;
end;
{$R *.DFM}

procedure TCustomAnalyticForm.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk
end;

procedure TCustomAnalyticForm.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TCustomAnalyticForm.cbAnalyticNameChange(Sender: TObject);
var
  C: CgdcBase;
  Index: Integer;
begin
  cbAnalyticValue.Condition := '';
  cbAnalyticValue.gdClassName := '';
  cbAnalyticValue.ListTable := '';
  cbAnalyticValue.ListField := '';
  cbAnalyticValue.KeyField :=  '';
  cbAnalyticValue.Fields := '';

  if cbBO.ItemIndex > - 1 then
  begin
    Index := FSubTypeList.IndexOfName(cbBO.Items[cbBo.ItemIndex]);
    C := CgdcBase(FSubTypeList.Objects[Index]);

    cbAnalyticValue.SubType := FsubTypeList.Values[FSubTypeList.Names[Index]];
    cbAnalyticValue.gdClassName := C.ClassName;

    cbAnalyticValue.ListTable := C.GetListTable(cbAnalyticValue.SubType);
    cbAnalyticValue.ListField := C.GetListField(cbAnalyticValue.SubType);
    cbAnalyticValue.KeyField := C.GetKeyField(cbAnalyticValue.SubType);
    cbAnalyticValue.Text := '';

    cbAnalyticValue.Enabled := True;
  end else
  begin
    cbAnalyticValue.Enabled := False;
  end;
end;

procedure TCustomAnalyticForm.SetValue(const Value: string);
begin
  FValue := Value;
end;

function TCustomAnalyticForm.GetValue: string;
begin
  Result := '';
  if cbAnalyticValue.Enabled then
  begin
    if cbNeedId.Checked then
    begin
      Result := Format('gdcBaseManager.GetidByRUIDString("%s")',
        [gdcBaseManager.GetRUIDStringById(cbAnalyticValue.CurrentKeyInt)]);
    end else
    begin
      Result := Format('"%s"', [gdcBaseManager.GetRUIDStringById(cbAnalyticValue.CurrentKeyInt)]);
    end;
  end;
end;

function TCustomAnalyticForm.BuildClassTree(ACE: TgdClassEntry; AData: Pointer): Boolean;
var
  S: TStringList;
  CL: TClassList;
  J: Integer;
begin
  if (ACE <> nil) and (not (ACE.SubType > '')) then
  begin
    S := TStringList.Create;
    CL := TClassList.Create;

    try
      if not GetDescendants(ACE.gdcClass, CL, True) then
      begin
      if ACE.gdcClass.GetSubTypeList(S) then
        begin
          for J := 0 to S.Count - 1 do
          begin
            FSubTypeList.AddObject(Format('%s[%s]',
              [S.Names[J],
              ACE.gdcClass.ClassName]) + '=' +
              S.Values[S.Names[J]], Pointer(ACE.gdcClass));
            cbBo.Items.AddObject(Format('%s[%s]',
              [S.Names[J],
              ACE.gdcClass.ClassName]),
              Pointer(ACE.gdcClass));
          end;
        end else
        begin
          FSubTypeList.AddObject(Format('%s[%s]',
            [ACE.gdcClass.GetDisplayName(''),
            ACE.gdcClass.ClassName]) + '=',
            Pointer(ACE.gdcClass));
          cbBo.Items.AddObject(Format('%s[%s]',
            [ACE.gdcClass.GetDisplayName(''),
            ACE.gdcClass.ClassName]),
            Pointer(ACE.gdcClass));
        end;
      end;
    finally
      S.Free;
      CL.Free;
    end;
  end;
  Result := True;
end;

procedure TCustomAnalyticForm.cbBODropDown(Sender: TObject);
var
{  I, J: Integer;
  S: TStringList;
  CL: TClassList; }
  CE: TgdClassEntry;
begin
  if FSubTypeList = nil then
    FSubTypeList := TStringList.Create
  else
    FSubTypeList.Clear;

  cbBo.Items.BeginUpdate;
  try
    cbBo.Items.Clear;

    CE := gdClassList.Find(TgdcBase);
    if CE <> nil then
      CE.Traverse(BuildClassTree, nil);

{   S := TStringList.Create;
   CL := TClassList.Create;
   try
     cbBo.Items.Clear;
     for I := 0 to gdcClassList.Count - 1 do
     begin
       if not GetDescendants(gdcClassList[I], CL, True) then
       begin
         if gdcClassList[I].GetSubTypeList(S) then
         begin
           for J := 0 to S.Count - 1 do
           begin
             FSubTypeList.AddObject(Format('%s[%s]',
               [S.Names[J],
               gdcClassList[I].ClassName]) + '=' +
               S.Values[S.Names[J]], Pointer(gdcClassList[I]));
             cbBo.Items.AddObject(Format('%s[%s]',
               [S.Names[J],
               gdcClassList[I].ClassName]),
               Pointer(gdcClassList[I]));
           end;
         end else
         begin
           FSubTypeList.AddObject(Format('%s[%s]',
             [gdcClassList[I].GetDisplayName(''),
             gdcClassList[i].ClassName]) + '=',
             Pointer(gdcClassList[I]));
           cbBo.Items.AddObject(Format('%s[%s]',
             [gdcClassList[I].GetDisplayName(''),
             gdcClassList[i].ClassName]),
              Pointer(gdcClassList[I]));
         end;
       end;
     end;
   finally
     S.Free;
     CL.Free;
   end;}
  finally
    cbBo.Items.EndUpdate;
  end;
end;

procedure TCustomAnalyticForm.FormDestroy(Sender: TObject);
begin
  FSubTypeList.Free;
end;

initialization
finalization
  FreeAndNil(_CustomAnalyticForm);
end.
