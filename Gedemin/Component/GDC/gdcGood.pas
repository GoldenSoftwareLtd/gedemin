
{
  Товары

  TgdcTNVD        - ТНВД
  TgdcGoodBarCode - Штрих код товара
  TgdcGoodGroup   - Группа товаров
  TgdcGood        - товар
  TgdcValue       - Единицы измерения
  TgdcTax         - Налоги
  TgdcMetal       - Драг металы

  Revisions history

    1.00    29.10.01    sai        Initial version.
    1.01    02.11.01    sai        Добавлены
                                     TgdcValue       - Единицы измерения
                                     TgdcTax         - Налоги
                                     TgdcMetal       - Драг металы
                                     TgdcGoodSet     - Комплекты
                                     ViewForm - ы для
    1.02    03.11.01    michael    Добавлен iherited в GetWhere_Clause для поддержки
                                   SubSet = 'ByID'
    1.03    05.11.01    sai        Переделаны методы ChooseElement
}

unit gdcGood;

interface

uses
  DB, Classes, IBCustomDataSet, gdcBase, gdcTree, Forms, gd_createable_form, Controls,
  gdcBaseInterface, contnrs;

const
  cst_byGroup     = 'byGroup';
  cst_byGood      = 'byGood';
  cst_GoodGroupID = 2000520;

type

  TgdcValue = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcTax = class(TgdcBase)
  protected
    function CheckTheSameStatement: String; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcMetal = class(TgdcBase)
  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcTNVD = class(TgdcBase)
  public
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const aSubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcGoodBarCode = class(TgdcBase)
  protected
    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;

    class function GetKeyField(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;

    class function GetSubSetList: String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcGoodGroup = class(TgdcLBRBTree)
  protected
    function GetOrderClause: String; override;

    function AcceptClipboard(CD: PgdcClipboardData): Boolean; override;

  public
    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
  end;

  TgdcGood = class(TgdcBase)
  private
    FGroupKey: Integer;

  protected
    function GetSelectClause: String; override;
    function GetFromClause(const ARefresh: Boolean = False): String; override;

    procedure _DoOnNewRecord; override;
    procedure DoBeforeInsert; override;
    procedure CreateFields; override;

    function GetGroupID: Integer; override;

    procedure GetWhereClauseConditions(S: TStrings); override;

  public
    constructor Create(AnOwner: TComponent); override;
             { TODO : Сделать функция с параметром код товара }
    function GetTaxRate(const TaxKey: Integer; const ForDate: TDateTime): Currency;
    function GetTaxRateOnName(const TaxName: String; const ForDate: TDateTime): Currency;
    function GetTaxRateByID(const aID: Integer; const TaxKey: Integer; const ForDate: TDateTime): Currency;
    function GetTaxRateOnNameByID(const aID: Integer; const TaxName: String; const ForDate: TDateTime): Currency;

    class function GetListTable(const ASubType: TgdcSubType): String; override;
    class function GetListField(const ASubType: TgdcSubType): String; override;
    class function GetViewFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetDialogFormClassName(const ASubType: TgdcSubType): String; override;
    class function GetSubSetList: String; override;
    class function GetChildrenClass(CL: TClassList): Boolean; override;

    property GroupKey: Integer read FGroupKey write FGroupKey;

    class function GetDisplayName(const ASubType: TgdcSubType): String; override;

  end;

  TgdcSelectedGood = class(TgdcGood)
  public
    class function GetSubTypeList(SubTypeList: TStrings): Boolean; override;
  end;

  procedure Register;

implementation

uses
  dmDataBase_unit, Sysutils, ibsql,

  gdc_dlgTNVD_unit,
  gdc_dlgGoodGroup_unit,
  gdc_dlgGood_unit,
  gdc_dlgGoodValue_unit,
  gdc_dlgGoodBarCode_unit,
  gdc_dlgGoodMetal_unit,
  gdc_dlgGoodTax_unit,

  gdc_frmMainGood_unit,
  gdc_frmValue_unit,
  gdc_frmTax_unit,
  gdc_frmMetal_unit,
  gdc_frmTNVD_unit,

  gd_ClassList,
  gd_directories_const,
  gdcInvDocument_unit;

procedure Register;
begin
  RegisterComponents('gdcGood', [TgdcTNVD]);
  RegisterComponents('gdcGood', [TgdcGoodBarCode]);
  RegisterComponents('gdcGood', [TgdcGoodGroup]);
  RegisterComponents('gdcGood', [TgdcGood]);
  RegisterComponents('gdcGood', [TgdcValue]);
  RegisterComponents('gdcGood', [TgdcTax]);
  RegisterComponents('gdcGood', [TgdcMetal]);
  RegisterComponents('gdcGood', [TgdcSelectedGood]);
end;

{ TgdcValue }

class function TgdcValue.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_VALUE'
end;

class function TgdcValue.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcValue.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmValue';
end;

class function TgdcValue.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Единица измерения';
end;

class function TgdcValue.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGoodValue';
end;

{ TgdcTax }

class function TgdcTax.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_TAX';
end;

class function TgdcTax.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcTax.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTax';
end;

class function TgdcTax.GetDisplayName(const ASubType: TgdcSubType): String;
begin
  Result := 'Налог';
end;

function TgdcTax.CheckTheSameStatement: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_CHECKTHESAMESTATEMENT('TGDCTAX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCTAX', KEYCHECKTHESAMESTATEMENT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCHECKTHESAMESTATEMENT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCTAX') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCTAX',
  {M}          'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'CHECKTHESAMESTATEMENT' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCTAX' then
  {M}        begin
  {M}          Result := Inherited CheckTheSameStatement;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  if State = dsInactive then
    Result :=
      'SELECT id FROM gd_good ' +
      'WHERE ' +
      '  (:barcode IS NOT NULL AND :barcode = barcode) ' +
      '  OR ' +
      '  (:barcode IS NULL AND barcode IS NULL AND UPPER(name)=UPPER(:name))'
  else if ID < cstUserIDStart then
    Result := inherited CheckTheSameStatement
  else if FieldByName('barcode').IsNull then
    Result := Format('SELECT id FROM gd_good WHERE UPPER(name)=UPPER(''%s'') ',
      [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll])])
  else
    Result := Format('SELECT id FROM gd_good WHERE UPPER(name)=UPPER(''%s'') ' +
      'AND barcode=''%s'' ',
      [StringReplace(FieldByName('name').AsString, '''', '''''', [rfReplaceAll]),
       StringReplace(FieldByName('barcode').AsString, '''', '''''', [rfReplaceAll])]);

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCTAX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCTAX', 'CHECKTHESAMESTATEMENT', KEYCHECKTHESAMESTATEMENT);
  {M}  end;
  {END MACRO}

end;

class function TgdcTax.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGoodTax';
end;

{ TgdcMetal }

class function TgdcMetal.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_PRECIOUSEMETAL';
end;

class function TgdcMetal.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcMetal.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmMetal';
end;

class function TgdcMetal.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Драгоценный металл';
end;

class function TgdcMetal.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGoodMetal';
end;

{ TgdcTNVD }

class function TgdcTNVD.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgTNVD';
end;

class function TgdcTNVD.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcTNVD.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_TNVD';
end;

class function TgdcTNVD.GetViewFormClassName(
  const aSubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmTNVD';
end;

constructor TgdcGoodBarCode.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  CustomProcess := [];
end;

class function TgdcGoodBarCode.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'barcode';
end;

class function TgdcGoodBarCode.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_GOODBARCODE';
end;

procedure TgdcGoodBarCode.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet('ByGood') then
    S.Add('z.goodkey = :goodkey');
end;

class function TgdcGoodBarCode.GetKeyField(
  const ASubType: TgdcSubType): String;
begin
  Result := 'id';
end;

class function TgdcGoodBarCode.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + 'ByGood;';
end;

class function TgdcGoodBarCode.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Штрих код товара';
end;

class function TgdcGoodBarCode.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGoodBarCode';
end;

{ TgdcGoodGroup }

class function TgdcGoodGroup.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcGoodGroup.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'gd_goodgroup';
end;

function TgdcGoodGroup.AcceptClipboard(CD: PgdcClipboardData): Boolean;
var
  i: Integer;
  LocalObj: TgdcGood;
begin
  if CD.Obj is TgdcGood then
  begin
    for I := 0 to CD.ObjectCount - 1 do
    begin
      if CD.Obj.Locate('ID', CD.ObjectArr[I].ID, []) then
      begin
        CD.Obj.Edit;
        try
          CD.Obj.FieldByName('groupkey').AsInteger := Self.ID;
          CD.Obj.Post;
        except
          CD.Obj.Cancel;
          raise;
        end;
      end else
      begin
        LocalObj := TgdcGood.CreateWithParams(nil,
          Database,
          Transaction,
          '',
          'ByID',
          CD.ObjectArr[I].ID);
        try
          CopyEventHandlers(LocalObj, CD.Obj);
          
          LocalObj.Open;
          if not LocalObj.IsEmpty then
          begin
            LocalObj.Edit;
            try
              LocalObj.FieldByName('groupkey').AsInteger := Self.ID;
              LocalObj.Post;
            except
              LocalObj.Cancel;
              raise;
            end;
          end;
        finally
          LocalObj.Free;
        end;
      end;
    end;
    Result := True;
  end else  
    Result := inherited AcceptClipboard(CD);
end;

function TgdcGoodGroup.GetOrderClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETORDERCLAUSE('TGDCGOODGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOODGROUP', KEYGETORDERCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETORDERCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOODGROUP') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOODGROUP',
  {M}          'GETORDERCLAUSE', KEYGETORDERCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETORDERCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOODGROUP' then
  {M}        begin
  {M}          Result := Inherited GetOrderClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result := '';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOODGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOODGROUP', 'GETORDERCLAUSE', KEYGETORDERCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcGoodGroup.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Группа товара';
end;

class function TgdcGoodGroup.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmMainGood';
end;

class function TgdcGoodGroup.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGoodGroup';
end;

{ TgdcGood }

class function TgdcGood.GetListField(const ASubType: TgdcSubType): String;
begin
  Result := 'name';
end;

class function TgdcGood.GetListTable(const ASubType: TgdcSubType): String;
begin
  Result := 'GD_GOOD';
end;

constructor TgdcGood.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  FGroupKey := -1;
end;

procedure TgdcGood.GetWhereClauseConditions(S: TStrings);
begin
  inherited;
  if HasSubSet(cst_byGroup) or HasSubSet('ByLBRB') then
    S.Add(' gg.lb >= :lb and gg.rb <= :rb ')
  else
    if HasSubSet('ByParent') then
      S.Add(' z.groupkey = :parent ');  
end;

procedure TgdcGood._DoOnNewRecord;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGOOD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOOD', KEY_DOONNEWRECORD);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEY_DOONNEWRECORD]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOOD',
  {M}          '_DOONNEWRECORD', KEY_DOONNEWRECORD, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited _DoOnNewRecord;

  if FGroupKey > 0 then
    FieldByName('GroupKey').AsInteger := FGroupKey;
  FieldByName('discipline').AsString := 'F';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOOD', '_DOONNEWRECORD', KEY_DOONNEWRECORD)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOOD', '_DOONNEWRECORD', KEY_DOONNEWRECORD);
  {M}  end;
  {END MACRO}
end;

function TgdcGood.GetFromClause(const ARefresh: Boolean = False): String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETFROMCLAUSE('TGDCGOOD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOOD', KEYGETFROMCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETFROMCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self), ARefresh]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOOD',
  {M}          'GETFROMCLAUSE', KEYGETFROMCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETFROMCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOOD' then
  {M}        begin
  {M}          Result := Inherited GetFromClause(ARefresh);
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  Result :=
    'FROM ' +
    ' GD_GOODGROUP GG ' +
    '  JOIN ' +
    ' GD_GOOD z ON z.GROUPKEY=GG.ID ' +
    '  LEFT JOIN ' +
    ' GD_VALUE V ON V.ID=z.VALUEKEY ' +
    '  LEFT JOIN ' +
    ' GD_TNVD T ON T.ID=z.TNVDKEY ';
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOOD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOOD', 'GETFROMCLAUSE', KEYGETFROMCLAUSE);
  {M}  end;
  {END MACRO}
end;

function TgdcGood.GetGroupID: Integer;
begin
  Result := cst_GoodGroupID;
end;

function TgdcGood.GetSelectClause: String;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_GETSELECTCLAUSE('TGDCGOOD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOOD', KEYGETSELECTCLAUSE);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYGETSELECTCLAUSE]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOOD',
  {M}          'GETSELECTCLAUSE', KEYGETSELECTCLAUSE, Params, LResult) then
  {M}          begin
  {M}            if (VarType(LResult) = varOleStr) or (VarType(LResult) = varString) then
  {M}              Result := String(LResult)
  {M}            else
  {M}              begin
  {M}                raise Exception.Create('Для метода ''' + 'GETSELECTCLAUSE' + ' ''' +
  {M}                  ' класса ' + Self.ClassName + TgdcBase(Self).SubType + #10#13 +
  {M}                  'Из макроса возвращен не строковый тип');
  {M}              end;
  {M}            exit;
  {M}          end;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOOD' then
  {M}        begin
  {M}          Result := Inherited GetSelectClause;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  Result :=
    'SELECT ' +
    ' z.ID, ' +      
    ' z.GROUPKEY, ' +
    ' z.NAME, ' +
    ' z.ALIAS, ' +
    ' z.SHORTNAME, ' +
    ' z.DESCRIPTION, ' +
    ' z.BARCODE, ' +
    ' z.VALUEKEY, ' +
    ' z.TNVDKEY, ' +
    ' z.ISASSEMBLY, ' +
    ' z.RESERVED, ' +
    ' z.DISCIPLINE, ' +
    ' z.DISABLED, ' +
    ' z.EDITIONDATE, ' +
    ' z.EDITORKEY, ' +
    ' z.CREATIONDATE, ' +
    ' z.CREATORKEY, ' +
    ' z.AFULL, ' +
    ' z.ACHAG, ' +
    ' z.AVIEW, ' +
    ' T.NAME AS TNVD, ' +
    ' V.NAME AS VALUENAME ';

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOOD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOOD', 'GETSELECTCLAUSE', KEYGETSELECTCLAUSE);
  {M}  end;
  {END MACRO}
end;

class function TgdcGood.GetSubSetList: String;
begin
  Result := inherited GetSubSetList + cst_ByGroup + ';ByLBRB;ByParent;';
end;

function TgdcGood.GetTaxRate(const TaxKey: Integer;
  const ForDate: TDateTime): Currency;
begin
  if Active then
    Result := GetTaxRateByID(FieldByName('ID').AsInteger, TaxKey, ForDate)
  else
    Result := 0;
end;

function TgdcGood.GetTaxRateOnName(const TaxName: String;
  const ForDate: TDateTime): Currency;
begin
  Result := GetTaxRateOnNameByID(ID, TaxName, ForDate);
end;

class function TgdcGood.GetViewFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_frmMainGood';
end;

function TgdcGood.GetTaxRateByID(const aID, TaxKey: Integer;
  const ForDate: TDateTime): Currency;
var
  ibsql: TIBSQL;
begin
  ibsql := TIBSQL.Create(nil);
  try
    if Transaction.Active then
      ibsql.Transaction := Transaction
    else
      ibsql.Transaction := ReadTransaction;

    ibsql.SQL.Text := 'SELECT tax.rate FROM gd_goodtax tax WHERE tax.goodkey = :goodkey ' +
       ' and tax.taxkey = :taxkey and tax.datetax = (SELECT max(tax1.datetax) FROM gd_goodtax tax1 ' +
       ' WHERE tax1.goodkey = :goodkey and tax1.taxkey = :taxkey and tax1.datetax <= :datetax) ';
    ibsql.ParamByName('goodkey').AsInteger := aID;
    ibsql.ParamByName('taxkey').AsInteger := TaxKey;
    ibsql.ParamByName('datetax').AsDateTime := ForDate;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
      Result := ibsql.FieldByName('rate').AsCurrency
    else
      Result := 0;
  finally
    ibsql.Free;
  end;
end;

function TgdcGood.GetTaxRateOnNameByID(const aID: Integer;
  const TaxName: String; const ForDate: TDateTime): Currency;
var
  ibsql: TIBSQL;
begin
  Result := 0;
  ibsql := TIBSQL.Create(nil);
  try
    ibsql.Transaction := ReadTransaction;
    ibsql.SQL.Text := 'SELECT id FROM gd_tax WHERE name = :name';
    ibsql.ParamByName('name').AsString := TaxName;
    ibsql.ExecQuery;
    if ibsql.RecordCount > 0 then
    begin
      Result := GetTaxRateByID(aID, ibsql.FieldByName('id').AsInteger, ForDate);
    end
    else
      raise EgdcIBError.Create('Не найден указанный налог');
  finally
    ibsql.Free;
  end;
end;

procedure TgdcGood.DoBeforeInsert;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGOOD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOOD', KEYDOBEFOREINSERT);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYDOBEFOREINSERT]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOOD',
  {M}          'DOBEFOREINSERT', KEYDOBEFOREINSERT, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  inherited;
  if Assigned(MasterSource) and Assigned(MasterSource.Dataset) and
    (MasterSource.DataSet is TgdcBase)
  then
    FGroupKey := (MasterSource.DataSet as TgdcBase).ID;
  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOOD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOOD', 'DOBEFOREINSERT', KEYDOBEFOREINSERT);
  {M}  end;
  {END MACRO}
end;

class function TgdcGood.GetDisplayName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Товар';
end;

class function TgdcGood.GetDialogFormClassName(
  const ASubType: TgdcSubType): String;
begin
  Result := 'Tgdc_dlgGood';
end;

class function TgdcGood.GetChildrenClass(CL: TClassList): Boolean;
begin
  Result := inherited GetChildrenClass(CL);

  if Result then
  begin
    CL.Remove(TgdcSelectedGood);
  end;
end;

{ TgdcSelectedGood }

procedure TgdcGood.CreateFields;
  {@UNFOLD MACRO INH_ORIG_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_ORIG_WITHOUTPARAM('TGDCGOOD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  try
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDCGOOD', KEYCREATEFIELDS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYCREATEFIELDS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDCGOOD') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcBaseMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDCGOOD',
  {M}          'CREATEFIELDS', KEYCREATEFIELDS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDCGOOD' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}

  inherited;

  FieldByName('valuekey').Required := True;
  FieldByName('groupkey').Required := True;

  {@UNFOLD MACRO INH_ORIG_FINALLY('TGDCGOOD', 'CREATEFIELDS', KEYCREATEFIELDS)}
  {M}  finally
  {M}    if (not FDataTransfer) and Assigned(gdcBaseMethodControl) then
  {M}      ClearMacrosStack2('TGDCGOOD', 'CREATEFIELDS', KEYCREATEFIELDS);
  {M}  end;
  {END MACRO}
end;

{ TgdcSelectedGood }

class function TgdcSelectedGood.GetSubTypeList(
  SubTypeList: TStrings): Boolean;
begin
  Result := TgdcInvBaseDocument.GetSubTypeList(SubTypeList);
end;

initialization
  RegisterGdcClass(TgdcTNVD);
  RegisterGdcClass(TgdcGoodBarCode);
  RegisterGdcClass(TgdcGoodGroup);
  RegisterGdcClass(TgdcGood);
  RegisterGdcClass(TgdcValue);
  RegisterGdcClass(TgdcTax);
  RegisterGdcClass(TgdcMetal);
  RegisterGdcClass(TgdcSelectedGood);


finalization
  UnRegisterGdcClass(TgdcTNVD);
  UnRegisterGdcClass(TgdcGoodBarCode);
  UnRegisterGdcClass(TgdcGoodGroup);
  UnRegisterGdcClass(TgdcGood);
  UnRegisterGdcClass(TgdcValue);
  UnRegisterGdcClass(TgdcTax);
  UnRegisterGdcClass(TgdcMetal);
  UnRegisterGdcClass(TgdcSelectedGood);
end.
