{++


  Copyright (c) 2001-2015 by Golden Software of Belarus, Ltd

  Module

    tax_frmAvailableTaxFunc_unit.pas

  Abstract

    Form for selection function of financial report.

  Author

    Dubrovnik Alexander (DAlex)

  Revisions history

    1.00    07.02.03    DAlex      Initial version.

--}

unit tax_frmAvailableTaxFunc_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_Createable_Form, dmImages_unit, ComCtrls, ExtCtrls, StdCtrls, contnrs,
  ActnList;

const
  // В массиве описаны стандартные функции VB доступные в списке
  // Добавление стандартных функций VB
  // Увеличить вторую длину массива,
  // добавить имя, синтаксис функции и описание ее
  VBFunctions: array[0..2, 0..7] of String =
    (('Abs',
      'CBool',
      'Date',
      'Day',
      'Month',
      'MonthName',
      'Null',
      'Year'),
     ('Abs(Значение)',
      'CBool(Выражение)',
      'Date()',
      'Day(Дата)',
      'Month(Дата)',
      'MonthName(Дата, Аббревиатура)',
      'Null',
      'Year(Дата)'),
     ('Возвращает абсолютное значение числа.',
      'Возвращает истино или ложно выражение.',
      'Возвращает текущую системную дату.',
      'Возвращает день переданной даты.',
      'Возвращает номер месяца переданной даты.',
      'Возвращает имя месяца',
      'Пустое значение. Используется, если объявляется функция, но она временно не определа',
      'Возвращает год переданной даты.'));

type
  tnFuncType = (ftAll, ftVB, ftCF, ftSF, ftGS, ftSFGl, ftSFLoc, ftGSNCU, ftGSCur, ftGSQuant, ftGSDate, ftGSOther);

type
  PFuncDescr = ^TFuncDescr;
  TFuncDescr = record
    Name: String;
    Descr: String;
    ShHelp: String;
    FType: tnFuncType;
    ParamArray: array of String;
  end;

  TTaxFuncArray = array of TFuncDescr;

  ItaxGSProp = interface(IDispatch)
    procedure CreateGSFuncArray;
    function  GetGSFuncArray: TTaxFuncArray;
  end;

type
  TfrmAvailableTaxFunc = class(TCreateableForm)
    pnlMain: TPanel;
    pnlButton: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    pnlHelp: TPanel;
    pnlDecr: TPanel;
    mmDescription: TMemo;
    pnlFuncParam: TPanel;
    lblFuncParam: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter2: TSplitter;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    tvTypeFunction: TTreeView;
    lvFunction: TListView;
    Splitter1: TSplitter;
    procedure tvTypeFunctionChange(Sender: TObject; Node: TTreeNode);
    procedure lvFunctionSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure FormCanResize(Sender: TObject; var NewWidth,
      NewHeight: Integer; var Resize: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure lvFunctionDblClick(Sender: TObject);
  private
    FVBFuncArray: TTaxFuncArray;// array of TFuncDescr;
    FGSFuncArray: TTaxFuncArray;// array of TFuncDescr;
    FCFFuncArray: TTaxFuncArray;// array of TFuncDescr;
    FSFFuncArray: TTaxFuncArray;// array of TFuncDescr;
    FSFGlFuncArray: TTaxFuncArray;// array of TFuncDescr;
    FSFLocFuncArray: TTaxFuncArray;// array of TFuncDescr;

    FActualTaxKey: Integer;
    FCurrentFunctionName: String;
    FSelectedFunction: String;
    FOtherFunc: String;

    procedure AddAllFunctions;
    procedure AddVBFunctions;
    procedure AddSFFunctions;

    procedure AddSFGlFunctions;
    procedure AddSFLocFunctions;

    procedure AddGSFunctions;
    procedure AddSubGSFunctions(const NameListStr: String);

    procedure CreateVBFuncArray;
    procedure CreateGSFuncArray;
    procedure CreateCFFuncArray;
    procedure CreateSFFuncArray;

    procedure SetActualTaxKey(const Value: Integer);
    procedure SetCurrentFunctionName(const Value: String);
  protected
    procedure AddCFFunctions; virtual;

    function GetAddParamsFuncForm: TFormClass; virtual;
    procedure InitAddParamsFuncForm(F: TForm); virtual;
    procedure AddFunctions(const FuncArray: array of TFuncDescr; const NameListStr: String = '');
  public
    constructor CreateWithParams(const Owner: TComponent;
      const ActualTaxKey: Integer = 0 ; const CurrentFunctionName: String = ''); virtual;

    property  SelectedFunction: String read FSelectedFunction;
    property  ActualTaxKey: Integer read FActualTaxKey write SetActualTaxKey;
    property  CurrentFunctionName: String read FCurrentFunctionName write SetCurrentFunctionName;
  end;

var
  frmAvailableTaxFunc: TfrmAvailableTaxFunc;
  taxGSProp: ItaxGSProp;

implementation

uses
  gdcTaxFunction, prp_frmClassesInspector_unit, IBSQL, gdcBaseInterface,
  gd_security_operationconst, gd_ClassList, gdc_Createable_Form,
  scr_i_FunctionList, rp_BaseReport_unit, IBQuery, rp_report_const, tax_frmAddParamsFunc_unit;

const
  outFunc = '[%s.%s%s]';

  //Наименования функций для веток
  cNCUFunc =
    'OD'#13#10 +
    'OK'#13#10 +
    'O'#13#10 +
    'SK'#13#10 +
    'SD'#13#10;
  cCurFunc =
    'V_SK'#13#10 +
    'V_OK'#13#10 +
    'V_SD'#13#10 +
    'V_OD'#13#10 +
    'V_O'#13#10;
  cQuantFunc =
    'K_O'#13#10 +
    'K_SK'#13#10 +
    'K_OK'#13#10 +
    'K_SD'#13#10 +
    'K_OD'#13#10;
  cDateFunc =
    'NP'#13#10 +
    'OP'#13#10 +
    'IncMonth'#13#10 +
    'NM'#13#10 +
    'KM'#13#10 +
    'NK'#13#10 +
    'NG'#13#10;





{$R *.DFM}

procedure TfrmAvailableTaxFunc.CreateVBFuncArray;
var
  I: Integer;

  procedure FillParamsArray(var FuncDescr: TFuncDescr);
  var
    LI, LBPos: Integer;
    LPrevSymb: Char;

  const
    bParamDecl = '(';
    eParamDecl = ')';
    sParamDecl = ',';
  begin
    SetLength(FuncDescr.ParamArray, 0);
    LI := Pos(bParamDecl, FuncDescr.Descr);
    if LI > 0 then
    begin
      LBPos := LI + 1;
      LPrevSymb := bParamDecl;
      for LI := LBPos to Length(FuncDescr.Descr) do
      begin
        case FuncDescr.Descr[LI] of
          eParamDecl:
          begin
            if (LPrevSymb = bParamDecl) and
              (Length(Trim(Copy(FuncDescr.Descr, LBPos, LI - LBPos -1))) = 0) then
              Exit
            else
              begin
                SetLength(FuncDescr.ParamArray, Length(FuncDescr.ParamArray) + 1);
                FuncDescr.ParamArray[Length(FuncDescr.ParamArray) - 1] :=
                  Trim(Copy(FuncDescr.Descr, LBPos, LI - LBPos));
              end;
          end;
          sParamDecl:
          begin
            SetLength(FuncDescr.ParamArray, Length(FuncDescr.ParamArray) + 1);
            FuncDescr.ParamArray[Length(FuncDescr.ParamArray) - 1] :=
              Trim(Copy(FuncDescr.Descr, LBPos, LI - LBPos));
            LPrevSymb := sParamDecl;
          end;
        end;
      end;
    end;
  end;

begin
  SetLength(FVBFuncArray, Length(VBFunctions[0]));
  for I := 0 to Length(VBFunctions[0]) - 1 do
  begin
    FVBFuncArray[I].Name   := VBFunctions[0][I];
    FVBFuncArray[I].Descr  := VBFunctions[1][I];
    FVBFuncArray[I].ShHelp := VBFunctions[2][I];
    FVBFuncArray[I].FType  := ftVB;
    FillParamsArray(FVBFuncArray[I]);
  end;
end;

procedure TfrmAvailableTaxFunc.tvTypeFunctionChange(Sender: TObject;
  Node: TTreeNode);

  procedure BeforeAddFunc;
  begin
    lvFunction.Items.Clear;
    lblFuncParam.Color := clWindow;
    lblFuncParam.Caption := ' ';
    mmDescription.Lines.Text := 'Для вставки функции выберете ее и нажмите кнопку "Ок".';
  end;
begin
  BeforeAddFunc;
  case tnFuncType(Node.Data) of
    ftAll:     AddAllFunctions;
    ftVB:      AddVBFunctions;
    ftCF:      AddCFFunctions;
    ftSFGl:    AddSFGlFunctions;
    ftSF:      AddSFFunctions;
    ftSFLoc:   AddSFLocFunctions;
    ftGS:      AddGSFunctions;
    ftGSNCU:   AddSubGSFunctions(cNCUFunc);
    ftGSCur:   AddSubGSFunctions(cCurFunc);
    ftGSQuant: AddSubGSFunctions(cQuantFunc);
    ftGSDate:  AddSubGSFunctions(cDateFunc);
    ftGSOther: AddSubGSFunctions(FOtherFunc);
  end;
end;

procedure TfrmAvailableTaxFunc.AddAllFunctions;
begin
  AddVBFunctions;
  AddCFFunctions;
  AddSFFunctions;
  AddGSFunctions;
end;

procedure TfrmAvailableTaxFunc.AddCFFunctions;
begin
  AddFunctions(FCFFuncArray);
end;

procedure TfrmAvailableTaxFunc.AddSFFunctions;
begin
  AddFunctions(FSFFuncArray);


  AddSFGlFunctions;
  AddSFLocFunctions;
end;

procedure TfrmAvailableTaxFunc.AddGSFunctions;
begin
  AddFunctions(FGSFuncArray);
end;

procedure TfrmAvailableTaxFunc.AddVBFunctions;
begin
  AddFunctions(FVBFuncArray);
end;

procedure TfrmAvailableTaxFunc.lvFunctionSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  FTStr: String;
begin
  lblFuncParam.Caption := PFuncDescr(Item.Data)^.Descr;
  lblFuncParam.Hint := PFuncDescr(Item.Data)^.Descr;
  mmDescription.Lines.Text := PFuncDescr(Item.Data)^.ShHelp;

  if ModalResult <> idOk then
  begin
    case PFuncDescr(Item.Data)^.FType of
      ftVB: FTStr := tfVBF;
      ftCF: FTStr := tfCFF;
      ftSF: FTStr := tfSFF;
      ftGS: FTStr := tfGSF;
    end;
    if Length(FTStr) > 0 then
      FSelectedFunction := Format(outFunc, [FTStr, Item.Caption, '']);
  end;
end;

procedure TfrmAvailableTaxFunc.CreateGSFuncArray;
var
  DefList, OtherList: TStrings;
  I: Integer;
begin
  taxGSProp.CreateGSFuncArray;
  FGSFuncArray := taxGSProp.GetGSFuncArray;

  DefList :=  TStringList.Create;
  try
    DefList.Text := cNCUFunc + cCurFunc + cQuantFunc + cDateFunc;

    OtherList := TStringList.Create;
    try
      FOtherFunc := '';
      for I := 0 to Length(FGSFuncArray) - 1 do
      begin
        if DefList.IndexOf(FGSFuncArray[I].Name) = -1 then
          OtherList.Add(FGSFuncArray[I].Name);
      end;
      FOtherFunc := OtherList.Text;
    finally
      OtherList.Free;
    end;
  finally
    DefList.Free;
  end;
end;

procedure TfrmAvailableTaxFunc.AddFunctions(
  const FuncArray: array of TFuncDescr; const NameListStr: String);
var
  I: Integer;
  LI: TListItem;
  NameList: TStrings;
begin
  NameList := nil;
  if NameListStr > '' then  NameList := TStringList.Create;
  try
    if NameList <> nil then NameList.Text := NameListStr;
    for I := 0 to Length(FuncArray) - 1 do
    begin
      if (NameList = nil) or ((NameList <> nil) and (NameList.IndexOf(FuncArray[I].Name) > -1)) then
      begin
        LI := lvFunction.Items.Add;
        LI.Caption := FuncArray[I].Name;
        LI.ImageIndex := 4;
        LI.Data := @FuncArray[I];
      end;
    end;
  finally
    NameList.Free;
  end;
end;

procedure TfrmAvailableTaxFunc.CreateCFFuncArray;
var
  IBSQL: TIBSQL;
  CFArrayLength: Integer;
begin
  CFArrayLength := 0;
  SetLength(FCFFuncArray, CFArrayLength);
  if FActualTaxKey <= 0 then
    Exit;

  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := gdcBaseManager.ReadTransaction;
    IBSQL.SQL.Text :=
      'SELECT * FROM gd_taxfunction WHERE taxactualkey = ' + IntToStr(FActualTaxKey);
    IBSQL.ExecQuery;

    while not IBSQL.Eof do
    begin

      if AnsiUpperCase(Trim(FCurrentFunctionName)) <>
        AnsiUpperCase(Trim(IBSQL.FieldByName('name').AsString)) then
      begin
        Inc(CFArrayLength);
        SetLength(FCFFuncArray, CFArrayLength);

        with FCFFuncArray[CFArrayLength - 1] do
          begin
            Name   := IBSQL.FieldByName('name').AsString;
            Descr  := Name + '()';
            ShHelp := IBSQL.FieldByName('description').AsString;
            FType  := ftCF;
            SetLength(ParamArray, 0);
          end;
      end;

      IBSQL.Next;
    end;
  finally
    IBSQL.Free;
  end;
end;

procedure TfrmAvailableTaxFunc.SetActualTaxKey(const Value: Integer);
begin
  FActualTaxKey := Value;
end;

procedure TfrmAvailableTaxFunc.SetCurrentFunctionName(const Value: String);
begin
  FCurrentFunctionName := Value;
end;

procedure TfrmAvailableTaxFunc.CreateSFFuncArray;
var
  IBQuery: TIBQuery;
//  SFArrayLength, I: Integer;
  RevList: TStringList;
  CalcFrmName: String;
  CustomFunction: TrpCustomFunction;

  procedure AddSF(const FuncArray: TTaxFuncArray; const DataSet: TIBQuery);
  var
    AI: Integer;
  begin
    with FuncArray[Length(FuncArray) - 1] do
    begin
      CustomFunction :=
        glbFunctionList.FindFunctionWithoutDB(DataSet.FieldByName('id').AsInteger);
      if CustomFunction = nil then
      begin
        CustomFunction := TrpCustomFunction.Create;
        CustomFunction.ReadFromDataSet(DataSet);
        glbFunctionList.AddFunction(CustomFunction);
      end;
      Name   := DataSet.FieldByName('name').AsString;
      Descr  := Name + '(';
      SetLength(ParamArray, CustomFunction.EnteredParams.Count);
      for AI := 0 to CustomFunction.EnteredParams.Count - 1 do
      begin
        ParamArray[AI] := CustomFunction.EnteredParams.Params[AI].RealName;
        if AI > 0 then
          Descr  := Descr + ', ' + ParamArray[AI]
        else
          Descr  := Descr + ParamArray[AI];
      end;
      Descr  := Descr + ')';
      ShHelp := DataSet.FieldByName('comment').AsString;
      FType  := ftSF;
    end;
  end;

begin
  SetLength(FSFFuncArray, 0);
  CalcFrmName := AnsiUpperCase('');

  IBQuery := TIBQuery.Create(Self);
  try
    IBQuery.Transaction := gdcBaseManager.ReadTransaction;

    CalcFrmName :=  AnsiUpperCase(Trim(TgdcTaxDesignDate.GetViewFormName));
    RevList := TStringList.Create;
    try
      IBQuery.SQL.Text :=
        'SELECT f.* FROM evt_object e1 ' +
        'LEFT JOIN gd_function f  ON f.modulecode = e1.id ' +
        'WHERE ' +
        '  UPPER(e1.objectname) = ''' + CalcFrmName + ''' AND ' +
        '  f.module = ''' + scrUnkonownModule + '''';

      IBQuery.Open;

      while not IBQuery.Eof do
      begin
        RevList.Add(IBQuery.FieldByName('name').AsString);
//        SetLength(FSFFuncArray, Length(FSFFuncArray) + 1);
        SetLength(FSFLocFuncArray, Length(FSFLocFuncArray) + 1);
        AddSF(FSFLocFuncArray, IBQuery);

        IBQuery.Next;
      end;

      IBQuery.Close;
      IBQuery.SQL.Text :=
        'SELECT f.* FROM gd_function f ' +
        'WHERE ' +
        '  f.modulecode = ' + IntToStr(OBJ_APPLICATION) + ' AND ' +
        '  f.module = ''' + scrUnkonownModule  + '''';

      IBQuery.Open;
      while not IBQuery.Eof do
      begin
        if RevList.IndexOf(IBQuery.FieldByName('name').AsString) = -1 then
        begin
          SetLength(FSFGlFuncArray, Length(FSFGlFuncArray) + 1);
          AddSF(FSFGlFuncArray, IBQuery);
        end;
        IBQuery.Next;
      end;
    finally
      RevList.Free;
    end;
  finally
    IBQuery.Free;
  end;
end;

constructor TfrmAvailableTaxFunc.CreateWithParams(const Owner: TComponent;
  const ActualTaxKey: Integer = 0; const CurrentFunctionName: String = '');
var
  RootNode, ChildNode, Node: TTreeNode;
begin
  Create(Owner);

  SetLength(FVBFuncArray, 0);
  SetLength(FSFFuncArray, 0);
  SetLength(FCFFuncArray, 0);
  FGSFuncArray := taxGSProp.GetGSFuncArray;

  FActualTaxKey := ActualTaxKey;
  FCurrentFunctionName := CurrentFunctionName;

  RootNode := tvTypeFunction.Items.AddFirst(nil, 'Все функции');
  RootNode.Data := Pointer(ftAll);
  RootNode.ImageIndex := 3;
  RootNode.SelectedIndex := 3;
  if ActualTaxKey > 0 then
  begin
    Node := tvTypeFunction.Items.AddChild(RootNode, '(CF) Текущего отчета');
    Node.Data := Pointer(ftCF);
    Node.ImageIndex := 0;
    Node.SelectedIndex := 0;
  end;
  Node := tvTypeFunction.Items.AddChild(RootNode, '(GS) GS-функции');
  Node.Data := Pointer(ftGS);
  Node.ImageIndex := 0;
  Node.SelectedIndex := 0;
  begin
    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Рублевые');
    ChildNode.Data := Pointer(ftGSNCU);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;

    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Валютные');
    ChildNode.Data := Pointer(ftGSCur);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;

    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Количественные');
    ChildNode.Data := Pointer(ftGSQuant);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;

    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Даты');
    ChildNode.Data := Pointer(ftGSDate);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;

    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Прочие');
    ChildNode.Data := Pointer(ftGSOther);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;      
  end;

  Node := tvTypeFunction.Items.AddChild(RootNode, '(SF) Скрипт-функции');
  Node.Data := Pointer(ftSF);
  Node.ImageIndex := 0;
  Node.SelectedIndex := 0;

  ChildNode := tvTypeFunction.Items.AddChild(Node, 'Глобальные');
  ChildNode.Data := Pointer(ftSFGl);
  ChildNode.ImageIndex := 0;
  ChildNode.SelectedIndex := 0;
  if ActualTaxKey > 0 then
  begin
    ChildNode := tvTypeFunction.Items.AddChild(Node, 'Локальные');
    ChildNode.Data := Pointer(ftSFLoc);
    ChildNode.ImageIndex := 0;
    ChildNode.SelectedIndex := 0;
  end;

  Node := tvTypeFunction.Items.AddChild(RootNode, '(VB) Стандартные');
  Node.Data := Pointer(ftVB);
  Node.ImageIndex := 0;
  Node.SelectedIndex := 0;
  tvTypeFunction.FullExpand;

  CreateVBFuncArray;
  CreateGSFuncArray;
  CreateCFFuncArray;
  CreateSFFuncArray;
end;

procedure TfrmAvailableTaxFunc.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  if (NewHeight < 300) or (NewWidth < 460) then
    Resize := False;
end;

procedure TfrmAvailableTaxFunc.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  FTStr: String;
  frmAddParamsFunc: TfrmAddParamsFunc;
begin
  if (ModalResult = mrOk) and (lvFunction.Selected = nil) then
    raise Exception.Create('Не выбрана функция.');

  if (ModalResult = idOk) and
    (Length(PFuncDescr(lvFunction.Selected.Data)^.ParamArray) > 0) then
  begin
    frmAddParamsFunc :=  TfrmAddParamsFunc(GetAddParamsFuncForm.Create(nil));
    InitAddParamsFuncForm(frmAddParamsFunc);
    with frmAddParamsFunc do
    try
      SetParams(lblFuncParam.Caption, Self.mmDescription.Lines.Text,
        Self.FActualTaxKey, PFuncDescr(lvFunction.Selected.Data)^);
      ShowModal;
      case PFuncDescr(lvFunction.Selected.Data)^.FType of
        ftVB: FTStr := tfVBF;
        ftCF: FTStr := tfCFF;
        ftSF: FTStr := tfSFF;
        ftGS: FTStr := tfGSF;
      end;
      if Length(FTStr) > 0 then
        FSelectedFunction := Format(outFunc, [FTStr, lvFunction.Selected.Caption,
          '(' + ParamsStr + ')']);
    finally
      Free;
    end;
  end;
end;

procedure TfrmAvailableTaxFunc.AddSFGlFunctions;
begin
  AddFunctions(FSFGlFuncArray);
end;

procedure TfrmAvailableTaxFunc.AddSFLocFunctions;
begin
  AddFunctions(FSFLocFuncArray);
end;

procedure TfrmAvailableTaxFunc.lvFunctionDblClick(Sender: TObject);
begin
  if lvFunction.Selected <> nil then
    ModalResult := mrOk;
end;

function TfrmAvailableTaxFunc.GetAddParamsFuncForm: TFormClass;
begin
  Result := TfrmAddParamsFunc;
end;

procedure TfrmAvailableTaxFunc.InitAddParamsFuncForm(F: TForm);
begin

end;

procedure TfrmAvailableTaxFunc.AddSubGSFunctions(
  const NameListStr: String);
begin
  AddFunctions(FGSFuncArray, NameListStr);
end;

end.
