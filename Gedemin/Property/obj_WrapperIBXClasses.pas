// ShlTanya, 25.02.2019

unit obj_WrapperIBXClasses;

interface

uses
  gdcOLEClassList, Gedemin_TLB, IBSQL, Classes, DB, ActiveX;

type
  TwrpObject = class(TWrapperAutoObject, IgsObject)
  protected
    function Get_Self: Integer; safecall;
    function Get_DelphiObject: Integer; safecall;
    function Get_SelfClass: TClass; virtual;
    function  ClassName: WideString; safecall;
    function  ClassParent: WideString; safecall;
    function  InheritsFrom(const AClass: WideString): WordBool; safecall;
    procedure DestroyObject; safecall;
  end;

  TwrpPersistent = class(TwrpObject, IgsPersistent)
  private
    function  GetPersistent: TPersistent;
  protected
    procedure Assign_(const Source: IgsPersistent); safecall;
  end;

  TwrpCollectionItem = class(TwrpPersistent, IgsCollectionItem)
  private
    function  GetCollectionItem: TCollectionItem;
  protected
    function  Get_Collection: IgsCollection; safecall;
    procedure Set_Collection(const Value: IgsCollection); safecall;
    function  Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const Value: WideString); safecall;
    function  Get_ID: Integer; safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Index(Value: Integer); safecall;
    function  GetNamePath: WideString; safecall;
  end;

  TwrpCollection = class(TwrpPersistent, IgsCollection)
  private
    function  GetCollection: TCollection;
  protected
    function  Get_Count: Integer; safecall;
    procedure BeginUpdate; safecall;
    procedure Clear; safecall;
    procedure Delete(Index: Integer); safecall;
    procedure EndUpdate; safecall;
    function  GetNamePath: WideString; safecall;
    function  FindItemID(ID: Integer): IgsCollectionItem; safecall;
    function  Insert(Index: Integer): IgsCollectionItem; safecall;
    function  Get_CollectionItems(Index: Integer): IgsCollectionItem; safecall;
    procedure Set_CollectionItems(Index: Integer; const Value: IgsCollectionItem); safecall;
    function  AddItem: IgsCollectionItem; safecall;
  end;

  TwrpComponent = class(TwrpPersistent, IgsComponent)
  protected
    function _GetComponent: TComponent;

    function  Get_Name: WideString; safecall;
    function  Get_ComponentState: WideString; safecall;
    function  Get_Tag: Integer; safecall;
    procedure Set_Tag(Value: Integer); safecall;
    function  Get_ComponentCount: Integer; safecall;
    function  Get_ComponentIndex: Integer; safecall;
    function  Get_Components(Index: Integer): IgsComponent; safecall;
    function  Get_DesignInfo: Integer; safecall;
    procedure Set_DesignInfo(Value: Integer); safecall;
    function  FindComponent(const ComponentName: WideString): IgsComponent; safecall;
    {Если компонент не найден, выдает эксепшн}
    function  GetComponent(const ComponentName: WideString): IgsComponent; safecall;
    function  Get_Owner: IgsComponent; safecall;
    function  Get_OwnerForm: IgsForm; safecall;
  public
    constructor Create(AObject: TComponent; const TypeLib: ITypeLib; const DispIntf: TGUID);
  end;

  TwrpIBXSQLVAR = class(TwrpObject, IgsIBXSQLVAR)
  private
    function GetIBXSQLVAR: TIBXSQLVAR;
  protected
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsTime: TDateTime; safecall;
    procedure Set_AsTime(Value: TDateTime); safecall;
    function  Get_AsTrimString: WideString; safecall;
    procedure Set_AsTrimString(const Value: WideString); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_IsNull: WordBool; safecall;
    procedure Set_IsNull(Value: WordBool); safecall;
    function  Get_Index: Integer; safecall;
    function  Get_IsNullable: WordBool; safecall;
    procedure Set_IsNullable(Value: WordBool); safecall;
    function  Get_Modified: WordBool; safecall;
    procedure Set_Modified(Value: WordBool); safecall;
    function  Get_Name: WideString; safecall;
    function  Get_Size: Integer; safecall;
    function  Get_SQLType: Integer; safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsDate: TDateTime; safecall;
    procedure Set_AsDate(Value: TDateTime); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
    function  Get_AsInteger: ATID; safecall;
    procedure Set_AsInteger(Value: ATID); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;

    function  Get_AsDouble: Double; safecall;
    procedure Set_AsDouble(Value: Double); safecall;
    function  Get_AsInt64: Int64; safecall;
    procedure Set_AsInt64(Value: Int64); safecall;
    function  Get_AsLong: Integer; safecall;
    procedure Set_AsLong(Value: Integer); safecall;
    function  Get_AsShort: Smallint; safecall;
    procedure Set_AsShort(Value: Smallint); safecall;

    procedure SaveToStream(const Param1: IgsStream); safecall;
    procedure LoadFromStream(const Param1: IgsStream); safecall;
  end;

  TwrpIBXSQLDA = class(TwrpObject, IgsIBXSQLDA)
  private
    function  GetIBXSQLDA: TIBXSQLDA;
  protected
    function  Get_Count: Integer; safecall;
    procedure Set_Count(Value: Integer); safecall;
    function  Get_Modified: WordBool; safecall;
    function  Get_Names: WideString; safecall;
    function  Get_RecordSize: Integer; safecall;
    function  Get_UniqueRelationName: WideString; safecall;
    function  Get_Vars(Idx: Integer): IgsIBXSQLVAR; safecall;
    procedure AddName(const FieldName: WideString; Idx: Integer); safecall;
    function  ByName(const Idx: WideString): IgsIBXSQLVAR; safecall;
  end;

  TwrpParam = class(TwrpCollectionItem, IgsParam)
  private
    function  GetParam: TParam;
  protected
    function  Get_Bound: WordBool; safecall;
    procedure Set_Bound(Value: WordBool); safecall;
    function  Get_DataType: TgsFieldType; safecall;
    procedure Set_DataType(Value: TgsFieldType); safecall;
    function  Get_IsNull: WordBool; safecall;
    function  Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    procedure AssignField(const Field: IgsFieldComponent); safecall;
    procedure AssignFieldValue(const Field: IgsFieldComponent; Value: OleVariant); safecall;
    procedure Clear; safecall;
    function  GetDataSize: Integer; safecall;
    function  Get_AsBCD: Currency; safecall;
    procedure Set_AsBCD(Value: Currency); safecall;
    function  Get_AsBlob: WideString; safecall;
    procedure Set_AsBlob(const Value: WideString); safecall;
    function  Get_AsBoolean: WordBool; safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsDate: TDateTime; safecall;
    procedure Set_AsDate(Value: TDateTime); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    function  Get_AsInteger: ATID; safecall;
    procedure Set_AsInteger(Value: ATID); safecall;
    function  Get_AsMemo: WideString; safecall;
    procedure Set_AsMemo(const Value: WideString); safecall;
    function  Get_AsSmallInt: Integer; safecall;
    procedure Set_AsSmallInt(Value: Integer); safecall;
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsTime: TDateTime; safecall;
    procedure Set_AsTime(Value: TDateTime); safecall;
    function  Get_AsWord: Integer; safecall;
    procedure Set_AsWord(Value: Integer); safecall;
    // Для совместимости
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_NativeStr: WideString; safecall;
    procedure Set_NativeStr(const Value: WideString); safecall;
    function  Get_ParamType: TgsParamType; safecall;
    procedure Set_ParamType(Value: TgsParamType); safecall;
  end;

  TwrpLookupList = class(TwrpObject, IgsLookupList)
  private
    function  GetLookupList: TLookupList;
  protected
    procedure Add(AKey: OleVariant; AValue: OleVariant); safecall;
    procedure Clear; safecall;
    function  ValueOfKey(AKey: OleVariant): OleVariant; safecall;
  end;

  TwrpField = class(TwrpComponent, IgsFieldComponent)
  private
    function  GetField: TField;
  protected
    function  Get_AsString: WideString; safecall;
    procedure Set_AsString(const Value: WideString); safecall;
    function  Get_AsInteger: ATID; safecall;
    procedure Set_AsInteger(Value: ATID); safecall;
    function  Get_AsVariant: OleVariant; safecall;
    procedure Set_AsVariant(Value: OleVariant); safecall;
    function  Get_FieldType: WideString; safecall;
    function  Get_FieldName: WideString; safecall;
    procedure Set_FieldName(const Value: WideString); safecall;
    function  Get_FieldSize: Integer; safecall;
    function  Get_Required: WordBool; safecall;
    procedure Set_Required(Value: WordBool); safecall;
    function  Get_AsFloat: Double; safecall;
    procedure Set_AsFloat(Value: Double); safecall;
    function  Get_Alignment: TgsAlignment; safecall;
    procedure Set_Alignment(Value: TgsAlignment); safecall;
    function  Get_AsBoolean: WordBool; safecall;
    procedure Set_AsBoolean(Value: WordBool); safecall;
    function  Get_AsCurrency: Currency; safecall;
    procedure Set_AsCurrency(Value: Currency); safecall;
    function  Get_AsDateTime: TDateTime; safecall;
    procedure Set_AsDateTime(Value: TDateTime); safecall;
    function  Get_AttributeSet: WideString; safecall;
    procedure Set_AttributeSet(const Value: WideString); safecall;
    function  Get_AutoGenerateValue: TgsAutoRefreshFlag; safecall;
    procedure Set_AutoGenerateValue(Value: TgsAutoRefreshFlag); safecall;
    function  Get_Calculated: WordBool; safecall;
    procedure Set_Calculated(Value: WordBool); safecall;
    function  Get_CanModify: WordBool; safecall;
    function  Get_ConstraintErrorMessage: WideString; safecall;
    procedure Set_ConstraintErrorMessage(const Value: WideString); safecall;
    function  Get_CurValue: OleVariant; safecall;
    function  Get_CustomConstraint: WideString; safecall;
    procedure Set_CustomConstraint(const Value: WideString); safecall;
    function  Get_DataSet: IgsDataSet; safecall;
    procedure Set_DataSet(const Value: IgsDataSet); safecall;
    function  Get_DataSize: Integer; safecall;
    function  Get_DataType: TgsFieldType; safecall;
    function  Get_DefaultExpression: WideString; safecall;
    procedure Set_DefaultExpression(const Value: WideString); safecall;
    function  Get_DisplayLabel: WideString; safecall;
    procedure Set_DisplayLabel(const Value: WideString); safecall;
    function  Get_DisplayName: WideString; safecall;
    function  Get_DisplayText: WideString; safecall;
    function  Get_DisplayWidth: Integer; safecall;
    procedure Set_DisplayWidth(Value: Integer); safecall;
    function  Get_EditMask: WideString; safecall;
    procedure Set_EditMask(const Value: WideString); safecall;
    function  Get_EditMaskPtr: WideString; safecall;
    function  Get_FieldKind: TgsFieldKind; safecall;
    procedure Set_FieldKind(Value: TgsFieldKind); safecall;
    function  Get_FieldNo: Integer; safecall;
    function  Get_FullName: WideString; safecall;
    function  Get_HasConstraints: WordBool; safecall;
    function  Get_ImportedConstraint: WideString; safecall;
    procedure Set_ImportedConstraint(const Value: WideString); safecall;
    function  Get_Index: Integer; safecall;
    procedure Set_Index(Value: Integer); safecall;
    function  Get_IsIndexField: WordBool; safecall;
    function  Get_IsNull: WordBool; safecall;
    function  Get_KeyFields: WideString; safecall;
    procedure Set_KeyFields(const Value: WideString); safecall;
    function  Get_Lookup: WordBool; safecall;
    procedure Set_Lookup(Value: WordBool); safecall;
    function  Get_LookupCache: WordBool; safecall;
    procedure Set_LookupCache(Value: WordBool); safecall;
    function  Get_LookupDataSet: IgsDataSet; safecall;
    procedure Set_LookupDataSet(const Value: IgsDataSet); safecall;
    function  Get_LookupKeyFields: WideString; safecall;
    procedure Set_LookupKeyFields(const Value: WideString); safecall;
    function  Get_LookupResultField: WideString; safecall;
    procedure Set_LookupResultField(const Value: WideString); safecall;
    function  Get_NewValue: OleVariant; safecall;
    procedure Set_NewValue(Value: OleVariant); safecall;
    function  Get_Offset: Integer; safecall;
    function  Get_OldValue: OleVariant; safecall;
    function  Get_Origin: WideString; safecall;
    procedure Set_Origin(const Value: WideString); safecall;
    function  Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function  Get_Size: Integer; safecall;
    procedure Set_Size(Value: Integer); safecall;
    function  Get_Text: WideString; safecall;
    procedure Set_Text(const Value: WideString); safecall;
    function  Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function  Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    procedure Clear; safecall;
    procedure FocusControl; safecall;
    function  GetParentComponent: IgsComponent; safecall;
    function  HasParent: WordBool; safecall;
    function  IsBlob: WordBool; safecall;
    function  IsValidChar(InputChar: Shortint): WordBool; safecall;
    procedure RefreshLookupList; safecall;
    procedure SetFieldType(Value: TgsFieldType); safecall;
    procedure Assign_(const Source: IgsPersistent); safecall;

    function  Get_LookupList: IgsLookupList; safecall;
    function  Get_ParentField: IgsObjectField; safecall;
    procedure Set_ParentField(const Value: IgsObjectField); safecall;
  end;

  TwrpBlobField = class(TwrpField, IgsBlobFieldComponent)
  private
    function  GetField: TBlobField;

  protected
    function  Get_BlobType: Integer; safecall;
    procedure Set_BlobType(Value: Integer); safecall;
    function  Get_BlobSize: Integer; safecall;
    procedure LoadFromFile(const Param1: WideString); safecall;
    procedure SaveToFile(const Param1: WideString); safecall;
    procedure SaveToStream(const Param1: IgsStream); safecall;
    procedure LoadFromStream(const Param1: IgsStream); safecall;
    function  Get_Modified: WordBool; safecall;
    procedure Set_Modified(Value: WordBool); safecall;
    function  Get_Transliterate: WordBool; safecall;
    procedure Set_Transliterate(Value: WordBool); safecall;
  end;

function VariantIsArray(const Value: OleVariant): Boolean;
procedure ErrorParamsCount(const ParamsCount: String);
procedure ErrorClassName(const ClassName: String);


implementation

uses
  prp_methods, ComServ, SysUtils, Forms, TypInfo, gdcBaseInterface, IBHeader, gdcBase;

const
  // Error messages
  cErrParamCountStr =
    'Несоответсвие массива параметров.'#13#10 +
    'Массив должен быть одномерный,'#13#10 +
    'начинаться с индекса 0 и иметь длину %s.';
  cErrClassNameStr =
    'Переданный класс не является наследником класса %s.';

function VariantIsArray(const Value: OleVariant): Boolean;
begin
  Result := (VarType(Value) and (not (VarType(Value) xor VarArray))) = VarArray;
end;

procedure ErrorParamsCount(const ParamsCount: String);
var
  ErrStr: String;
begin
  ErrStr := Format(cErrParamCountStr, [ParamsCount]);
  raise Exception.Create(ErrStr);
end;

procedure ErrorClassName(const ClassName: String);
var
  ErrStr: String;
begin
  ErrStr := Format(cErrClassNameStr, [ClassName]);
  raise Exception.Create(ErrStr);
end;


function GetStrFromFieldType(const AnFieldType: TFieldType): String;
begin
  Result := GetEnumName(TypeInfo(TFieldType), Integer(AnFieldType));
end;

{ TwrpObject }

function TwrpObject.ClassName: WideString;
begin
  Result := TObject(GetObject).ClassName;
end;

function TwrpObject.ClassParent: WideString;
begin
  Result := TObject(GetObject).ClassParent.ClassName;
end;

procedure TwrpObject.DestroyObject;
begin
  DestroyDelphiObject;
end;

function TwrpObject.Get_DelphiObject: Integer;
begin
  Result := Integer(DelphiObject);
end;

function TwrpObject.Get_Self: Integer;
begin
  Result := Integer(GetObject);
end;

function TwrpObject.Get_SelfClass: TClass;
begin
  Result := GetObject.ClassType;
end;

function TwrpObject.InheritsFrom(const AClass: WideString): WordBool;
begin
  Result := TObject(GetObject).InheritsFrom(GetClass(AClass));
end;

{ TwrpPersistent }

procedure TwrpPersistent.Assign_(const Source: IgsPersistent);
begin
  GetPersistent.Assign(InterfaceToObject(Source) as TPersistent);
end;

function TwrpPersistent.GetPersistent: TPersistent;
begin
  Result := GetObject as TPersistent;
end;

{ TwrpCollectionItem }

function TwrpCollectionItem.Get_Collection: IgsCollection;
begin
  Result := GetGdcOLEObject(GetCollectionItem.Collection) as IgsCollection;
end;

function TwrpCollectionItem.Get_DisplayName: WideString;
begin
  Result := GetCollectionItem.DisplayName;
end;

function TwrpCollectionItem.Get_ID: Integer;
begin
  Result := GetCollectionItem.ID;
end;

function TwrpCollectionItem.Get_Index: Integer;
begin
  Result := GetCollectionItem.Index;
end;

function TwrpCollectionItem.GetCollectionItem: TCollectionItem;
begin
  Result := GetObject as TCollectionItem;
end;

function TwrpCollectionItem.GetNamePath: WideString;
begin
  Result := GetCollectionItem.GetNamePath;
end;

procedure TwrpCollectionItem.Set_Collection(const Value: IgsCollection);
begin
  GetCollectionItem.Collection := InterfaceToObject(Value) as TCollection;
end;

procedure TwrpCollectionItem.Set_DisplayName(const Value: WideString);
begin
  GetCollectionItem.DisplayName := Value;
end;

procedure TwrpCollectionItem.Set_Index(Value: Integer);
begin
  GetCollectionItem.Index := Value;
end;

{ TwrpCollection }

procedure TwrpCollection.BeginUpdate;
begin
  GetCollection.BeginUpdate;
end;

procedure TwrpCollection.Clear;
begin
  GetCollection.Clear;
end;

procedure TwrpCollection.Delete(Index: Integer);
begin
  GetCollection.Delete(Index);
end;

procedure TwrpCollection.EndUpdate;
begin
  GetCollection.EndUpdate
end;

function TwrpCollection.Get_Count: Integer;
begin
  Result := GetCollection.Count;
end;

function TwrpCollection.GetCollection: TCollection;
begin
  Result := GetObject as TCollection;
end;

function TwrpCollection.GetNamePath: WideString;
begin
  Result := GetCollection.GetNamePath;
end;

function TwrpCollection.FindItemID(ID: Integer): IgsCollectionItem;
begin
  Result := GetGdcOLEObject(GetCollection.FindItemID(ID)) as IgsCollectionItem;
end;

function TwrpCollection.Insert(Index: Integer): IgsCollectionItem;
begin
  Result := GetGdcOLEObject(GetCollection.Insert(Index)) as IgsCollectionItem;
end;

function TwrpCollection.AddItem: IgsCollectionItem;
begin
  Result := GetGdcOLEObject(GetCollection.Add) as IgsCollectionItem;
end;

function TwrpCollection.Get_CollectionItems(
  Index: Integer): IgsCollectionItem;
begin
  Result := GetGdcOLEObject(GetCollection.Items[Index]) as IgsCollectionItem;
end;

procedure TwrpCollection.Set_CollectionItems(Index: Integer;
  const Value: IgsCollectionItem);
begin
  GetCollection.Items[Index] := InterfaceToObject(Value) as TCollectionItem;
end;

{ TwrpComponent }

function TwrpComponent.Get_ComponentCount: Integer;
begin
  Result := _GetComponent.ComponentCount;
end;

function TwrpComponent.Get_ComponentIndex: Integer;
begin
  Result := _GetComponent.ComponentIndex;
end;

function TwrpComponent.Get_Components(Index: Integer): IgsComponent;
begin
  Result := GetGdcOLEObject(_GetComponent.Components[Index]) as IgsComponent;
end;

function TwrpComponent.Get_Name: WideString;
begin
  Result := _GetComponent.Name;
end;

function TwrpComponent.Get_Tag: Integer;
begin
  Result := _GetComponent.Tag;
end;

function TwrpComponent._GetComponent: TComponent;
begin
  Result := GetObject as TComponent;
end;

constructor TwrpComponent.Create(AObject: TComponent; const TypeLib: ITypeLib;
  const DispIntf: TGUID);
begin
  inherited Create(AObject, TypeLib, DispIntf);
end;

function TwrpComponent.Get_DesignInfo: Integer;
begin
  Result := _GetComponent.DesignInfo;
end;

procedure TwrpComponent.Set_DesignInfo(Value: Integer);
begin
  _GetComponent.DesignInfo := Value;
end;


function TwrpComponent.FindComponent(const ComponentName: WideString): IgsComponent;
var
  LComponent: TComponent;
begin
  LComponent := _GetComponent.FindComponent(ComponentName);
  if Assigned(LComponent) then
    Result := GetGdcOLEObject(LComponent) as IgsComponent
  else
    Result := nil;
end;

function TwrpComponent.Get_Owner: IgsComponent;
begin
  Result := GetGdcOLEObject(_GetComponent.Owner) as IgsComponent;
end;

function TwrpComponent.Get_ComponentState: WideString;
begin
  Result := ' ';
  if csLoading in _GetComponent.ComponentState then
    Result := Result + 'csLoading ';
  if csReading in _GetComponent.ComponentState then
    Result := Result + 'csReading ';
  if csWriting in _GetComponent.ComponentState then
    Result := Result + 'csWriting ';
  if csDestroying in _GetComponent.ComponentState then
    Result := Result + 'csDestroying ';
  if csDesigning in _GetComponent.ComponentState then
    Result := Result + 'csDesigning ';
  if csAncestor in _GetComponent.ComponentState then
    Result := Result + 'csAncestor ';
  if csUpdating in _GetComponent.ComponentState then
    Result := Result + 'csUpdating ';
  if csFixups in _GetComponent.ComponentState then
    Result := Result + 'csFixups ';
  if csFreeNotification in _GetComponent.ComponentState then
    Result := Result + 'csFreeNotification ';
  if csInline in _GetComponent.ComponentState then
    Result := Result + 'csInline ';
end;

function TwrpComponent.Get_OwnerForm: IgsForm;
var
  LOwnerForm: TComponent;
begin
  LOwnerForm := _GetComponent;
  while (LOwnerForm <> nil) and (not (LOwnerForm is TForm)) and (LOwnerForm <> Application) do
    LOwnerForm := LOwnerForm.Owner;
  if (LOwnerForm is TForm) then
    Result := GetGdcOLEObject(LOwnerForm) as IgsForm
  else
    Result := nil;
end;

procedure TwrpComponent.Set_Tag(Value: Integer);
begin
  _GetComponent.Tag := Value;
end;

function TwrpComponent.GetComponent(
  const ComponentName: WideString): IgsComponent;
begin
  Result := FindComponent(ComponentName);
  if not Assigned(Result) then
    raise Exception.Create(Format('%s: Компонент %s не найден!', [_GetComponent.Name,
      ComponentName]));
end;

{ TwrpField }

function TwrpField.Get_AsFloat: Double;
begin
  Result := GetField.AsFloat;
end;

function TwrpField.Get_AsInteger: ATID;
begin
  Result := GetTID(GetField.AsFloat);
end;

function TwrpField.Get_AsString: WideString;
begin
  Result := GetField.AsString;
end;

function TwrpField.Get_AsVariant: OleVariant;
begin
{$IFDEF VER130}
 if (GetField.DataType = ftLargeInt) and not GetField.IsNull then
   Result := GetField.AsFloat
 else
{$ENDIF}
   Result := GetField.AsVariant;
end;

function TwrpField.Get_FieldName: WideString;
begin
  Result := GetField.FieldName;
end;

function TwrpField.Get_FieldSize: Integer;
begin
  Result := GetField.Size;
end;

function TwrpField.Get_FieldType: WideString;
begin
  Result := GetStrFromFieldType(GetField.DataType);
end;

function TwrpField.Get_Required: WordBool;
begin
  Result := GetField.Required;
end;

function TwrpField.GetField: TField;
begin
  Result := GetObject as TField;
end;

procedure TwrpField.Set_AsFloat(Value: Double);
begin
  GetField.AsFloat := Value;
end;

procedure TwrpField.Set_AsInteger(Value: ATID);
begin
  GetField.AsFloat := Value;
end;

procedure TwrpField.Set_AsString(const Value: WideString);
begin
  GetField.AsString := Value;
end;

procedure TwrpField.Set_AsVariant(Value: OleVariant);
begin
  SetVar2Field(GetField, Value);
end;

function TwrpField.Get_Alignment: TgsAlignment;
begin
  Result := TgsAlignment(GetField.Alignment);
end;

function TwrpField.Get_AsBoolean: WordBool;
begin
  Result := GetField.AsBoolean;
end;

procedure TwrpField.Set_Alignment(Value: TgsAlignment);
begin
  GetField.Alignment := TAlignment(Value);
end;

procedure TwrpField.Set_AsBoolean(Value: WordBool);
begin
  GetField.AsBoolean := Value;
end;

function TwrpField.Get_AsCurrency: Currency;
begin
  Result := GetField.AsCurrency;
end;

function TwrpField.Get_AsDateTime: TDateTime;
begin
  Result := GetField.AsDateTime;
end;

function TwrpField.Get_AttributeSet: WideString;
begin
  Result := GetField.AttributeSet;
end;

function TwrpField.Get_AutoGenerateValue: TgsAutoRefreshFlag;
begin
  Result := TgsAutoRefreshFlag(GetField.AutoGenerateValue);
end;

function TwrpField.Get_Calculated: WordBool;
begin
  Result := GetField.Calculated;
end;

function TwrpField.Get_CanModify: WordBool;
begin
  Result := GetField.CanModify;
end;

function TwrpField.Get_ConstraintErrorMessage: WideString;
begin
  Result := GetField.ConstraintErrorMessage;
end;

function TwrpField.Get_CurValue: OleVariant;
begin
  Result := GetField.CurValue;
end;

function TwrpField.Get_CustomConstraint: WideString;
begin
  Result := GetField.CustomConstraint;
end;

function TwrpField.Get_DataSet: IgsDataSet;
begin
  Result := GetGdcOLEObject(GetField.DataSet) as IgsDataSet;
end;

function TwrpField.Get_DataSize: Integer;
begin
  Result := GetField.DataSize;
end;

function TwrpField.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(GetField.DataType);
end;

function TwrpField.Get_DefaultExpression: WideString;
begin
 Result := GetField.DefaultExpression;
end;

function TwrpField.Get_DisplayLabel: WideString;
begin
 Result := GetField.DisplayLabel;
end;

function TwrpField.Get_DisplayName: WideString;
begin
 Result := GetField.DisplayName;
end;

function TwrpField.Get_DisplayText: WideString;
begin
 Result := GetField.DisplayText;
end;

function TwrpField.Get_DisplayWidth: Integer;
begin
 Result := GetField.DisplayWidth;
end;

function TwrpField.Get_EditMask: WideString;
begin
 Result := GetField.EditMask;
end;

function TwrpField.Get_EditMaskPtr: WideString;
begin
 Result := GetField.EditMaskPtr;
end;

function TwrpField.Get_FieldKind: TgsFieldKind;
begin
 Result := TgsFieldKind(GetField.FieldKind);
end;

function TwrpField.Get_FieldNo: Integer;
begin
 Result := GetField.FieldNo;
end;

function TwrpField.Get_FullName: WideString;
begin
 Result := GetField.FullName;
end;

function TwrpField.Get_HasConstraints: WordBool;
begin
 Result := GetField.HasConstraints;
end;

function TwrpField.Get_ImportedConstraint: WideString;
begin
 Result := GetField.ImportedConstraint;
end;

function TwrpField.Get_Index: Integer;
begin
 Result := GetField.Index;
end;

function TwrpField.Get_IsIndexField: WordBool;
begin
 Result := GetField.IsIndexField;
end;

function TwrpField.Get_IsNull: WordBool;
begin
 Result := GetField.IsNull;
end;

function TwrpField.Get_KeyFields: WideString;
begin
 Result := GetField.KeyFields;
end;

function TwrpField.Get_Lookup: WordBool;
begin
 Result := GetField.Lookup;
end;

function TwrpField.Get_LookupCache: WordBool;
begin
 Result := GetField.LookupCache;
end;

function TwrpField.Get_LookupDataSet: IgsDataSet;
begin
 Result := GetGdcOLEObject(GetField.LookupDataSet) as IgsDataSet
end;

function TwrpField.Get_LookupKeyFields: WideString;
begin
 Result := GetField.LookupKeyFields;
end;

function TwrpField.Get_LookupResultField: WideString;
begin
 Result := GetField.LookupResultField;
end;

function TwrpField.Get_NewValue: OleVariant;
begin
 Result := Get_Value;
end;

function TwrpField.Get_Offset: Integer;
begin
 Result := GetField.Offset;
end;

function TwrpField.Get_OldValue: OleVariant;
begin
 if GetField.DataSet is TgdcBase then
 begin
   {$IFDEF VER130}
   if (GetField.DataType = ftLargeInt) and not GetField.IsNull then
     Result := StrToFloat((GetField.DataSet as TgdcBase).GetOldFieldValue_Str(GetField.FieldName))
   else
  {$ENDIF}
     Result := GetField.OldValue
 end    
 else
   Result := GetField.OldValue;
end;

function TwrpField.Get_Origin: WideString;
begin
 Result := GetField.Origin;
end;

function TwrpField.Get_ReadOnly: WordBool;
begin
 Result := GetField.ReadOnly;
end;

function TwrpField.Get_Size: Integer;
begin
 Result := GetField.Size;
end;

function TwrpField.Get_Text: WideString;
begin
 Result := GetField.Text;
end;

function TwrpField.Get_Value: OleVariant;
begin
{$IFDEF VER130}
 if (GetField.DataType = ftLargeInt) and not GetField.IsNull then
   Result := GetField.AsFloat
 else
{$ENDIF}
   Result := GetField.Value;

end;

function TwrpField.Get_Visible: WordBool;
begin
 Result := GetField.Visible;
end;

procedure TwrpField.Set_AsCurrency(Value: Currency);
begin
  GetField.AsCurrency := Value;
end;

procedure TwrpField.Set_AsDateTime(Value: TDateTime);
begin
  GetField.AsDateTime := Value;
end;

procedure TwrpField.Set_AttributeSet(const Value: WideString);
begin
  GetField.AttributeSet := Value;
end;

procedure TwrpField.Set_AutoGenerateValue(Value: TgsAutoRefreshFlag);
begin
  GetField.AutoGenerateValue := TAutoRefreshFlag(Value);
end;

procedure TwrpField.Set_Calculated(Value: WordBool);
begin
  GetField.Calculated := Value;
end;

procedure TwrpField.Set_ConstraintErrorMessage(const Value: WideString);
begin
  GetField.ConstraintErrorMessage := Value;
end;

procedure TwrpField.Set_CustomConstraint(const Value: WideString);
begin
  GetField.CustomConstraint := Value;
end;

procedure TwrpField.Set_DataSet(const Value: IgsDataSet);
begin
  GetField.DataSet := InterfaceToObject(Value) as TDataSet;
end;

procedure TwrpField.Set_DefaultExpression(const Value: WideString);
begin
  GetField.DefaultExpression := Value;
end;

procedure TwrpField.Set_DisplayLabel(const Value: WideString);
begin
  GetField.DisplayLabel := Value;
end;

procedure TwrpField.Set_DisplayWidth(Value: Integer);
begin
  GetField.DisplayWidth := Value;
end;

procedure TwrpField.Set_EditMask(const Value: WideString);
begin
  GetField.EditMask := Value;
end;

procedure TwrpField.Set_FieldKind(Value: TgsFieldKind);
begin
  GetField.FieldKind := TFieldKind(Value);
end;

procedure TwrpField.Set_ImportedConstraint(const Value: WideString);
begin
  GetField.ImportedConstraint := Value;
end;

procedure TwrpField.Set_Index(Value: Integer);
begin
  GetField.Index := Value;
end;

procedure TwrpField.Set_KeyFields(const Value: WideString);
begin
  GetField.KeyFields := Value;
end;

procedure TwrpField.Set_Lookup(Value: WordBool);
begin
  GetField.Lookup := Value;
end;

procedure TwrpField.Set_LookupCache(Value: WordBool);
begin
  GetField.LookupCache := Value;
end;

procedure TwrpField.Set_LookupDataSet(const Value: IgsDataSet);
begin
  GetField.LookupDataSet := InterfaceToObject(Value) as TDataSet;
end;

procedure TwrpField.Set_LookupKeyFields(const Value: WideString);
begin
  GetField.LookupKeyFields := Value;
end;

procedure TwrpField.Set_LookupResultField(const Value: WideString);
begin
  GetField.LookupResultField := Value;
end;

procedure TwrpField.Set_NewValue(Value: OleVariant);
begin
  GetField.NewValue := Value;
end;

procedure TwrpField.Set_Origin(const Value: WideString);
begin
  GetField.Origin := Value;
end;

procedure TwrpField.Set_ReadOnly(Value: WordBool);
begin
  GetField.ReadOnly := Value;
end;

procedure TwrpField.Set_Size(Value: Integer);
begin
  GetField.Size := Value;
end;

procedure TwrpField.Set_Text(const Value: WideString);
begin
  GetField.Text := Value;
end;

procedure TwrpField.Set_Value(Value: OleVariant);
begin
  SetVar2Field(GetField, Value);
end;

procedure TwrpField.Set_Visible(Value: WordBool);
begin
  GetField.Visible := Value;
end;

procedure TwrpField.Clear;
begin
  GetField.Clear;
end;

procedure TwrpField.FocusControl;
begin
  GetField.FocusControl;
end;

function TwrpField.GetParentComponent: IgsComponent;
begin
  Result := GetGdcOLEObject(GetField.GetParentComponent) as IgsComponent;
end;

function TwrpField.HasParent: WordBool;
begin
  Result := GetField.HasParent;
end;

function TwrpField.IsBlob: WordBool;
begin
  Result := GetField.IsBlob;
end;

function TwrpField.IsValidChar(InputChar: Shortint): WordBool;
begin
  Result := GetField.IsValidChar(chr(InputChar));
end;

procedure TwrpField.RefreshLookupList;
begin
  GetField.RefreshLookupList;
end;

procedure TwrpField.SetFieldType(Value: TgsFieldType);
begin
  GetField.SetFieldType(TFieldType(Value));
end;

function TwrpField.Get_LookupList: IgsLookupList;
begin
  Result := GetGdcOLEObject(GetField.LookupList) as IgsLookupList;
end;

function TwrpField.Get_ParentField: IgsObjectField;
begin
  Result := GetGdcOLEObject(GetField.ParentField) as IgsObjectField;
end;

procedure TwrpField.Set_ParentField(const Value: IgsObjectField);
begin
  GetField.ParentField := InterfaceToObject(Value) as TObjectField;
end;

procedure TwrpField.Set_FieldName(const Value: WideString);
begin
  GetField.FieldName := Value;
end;

procedure TwrpField.Set_Required(Value: WordBool);
begin
  GetField.Required := Value;
end;

procedure TwrpField.Assign_(const Source: IgsPersistent);
begin
  {$IFDEF ID64}
   if (GetField.DataType = ftLargeInt) and not (InterfaceToObject(Source) as TField).IsNull then
     GetField.AsFloat := (InterfaceToObject(Source) as TField).AsFloat
   else
     GetField.Assign(InterfaceToObject(Source) as TPersistent);
  {$ELSE}
    GetField.Assign(InterfaceToObject(Source) as TPersistent)
  {$ENDIF}
end;

{ TwrpIBXSQLVAR }

function TwrpIBXSQLVAR.Get_AsCurrency: Currency;
begin
  Result := GetIBXSQLVAR.AsCurrency;
end;

function TwrpIBXSQLVAR.Get_AsDateTime: TDateTime;
begin
  Result := GetIBXSQLVAR.AsDateTime;
end;

function TwrpIBXSQLVAR.Get_AsDate: TDateTime;
begin
  Result := GetIBXSQLVAR.AsDate;
end;

function TwrpIBXSQLVAR.Get_AsString: WideString;
begin
  Result := GetIBXSQLVAR.AsString;
end;

function TwrpIBXSQLVAR.Get_AsTime: TDateTime;
begin
  Result := GetIBXSQLVAR.AsTime;
end;

function TwrpIBXSQLVAR.Get_AsTrimString: WideString;
begin
  Result := GetIBXSQLVAR.AsTrimString;
end;

function TwrpIBXSQLVAR.Get_AsVariant: OleVariant;
begin
{$IFDEF VER130}
 if (GetIBXSQLVAR.SQLType = SQL_INT64) and not GetIBXSQLVAR.IsNull then
   Result := GetIBXSQLVAR.AsDouble
 else
{$ENDIF}
  Result := GetIBXSQLVAR.AsVariant;
end;

function TwrpIBXSQLVAR.Get_Index: Integer;
begin
  Result := GetIBXSQLVAR.Index;
end;

function TwrpIBXSQLVAR.Get_IsNull: WordBool;
begin
  Result := GetIBXSQLVAR.IsNull;
end;

function TwrpIBXSQLVAR.Get_IsNullable: WordBool;
begin
  Result := GetIBXSQLVAR.IsNullable;
end;

function TwrpIBXSQLVAR.Get_Modified: WordBool;
begin
  Result := GetIBXSQLVAR.Modified;
end;

function TwrpIBXSQLVAR.Get_Name: WideString;
begin
  Result := GetIBXSQLVAR.Name;
end;

function TwrpIBXSQLVAR.Get_Size: Integer;
begin
  Result := GetIBXSQLVAR.Size;
end;

function TwrpIBXSQLVAR.Get_SQLType: Integer;
begin
  Result := GetIBXSQLVAR.SQLType;
end;

function TwrpIBXSQLVAR.Get_Value: OleVariant;
begin
{$IFDEF VER130}
 if (GetIBXSQLVAR.SQLType = SQL_INT64) and not GetIBXSQLVAR.IsNull then
   Result := GetIBXSQLVAR.AsDouble
 else
{$ENDIF}
  Result := GetIBXSQLVAR.Value;
end;

function TwrpIBXSQLVAR.GetIBXSQLVAR: TIBXSQLVAR;
begin
  Result := GetObject as TIBXSQLVAR;
end;

procedure TwrpIBXSQLVAR.Set_AsCurrency(Value: Currency);
begin
  GetIBXSQLVAR.AsCurrency := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsDateTime(Value: TDateTime);
begin
  GetIBXSQLVAR.AsDateTime := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsDate(Value: TDateTime);
begin
  GetIBXSQLVAR.AsDate := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsString(const Value: WideString);
begin
  GetIBXSQLVAR.AsString := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsTime(Value: TDateTime);
begin
  GetIBXSQLVAR.AsTime := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsTrimString(const Value: WideString);
begin
  GetIBXSQLVAR.AsTrimString := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsVariant(Value: OleVariant);
begin
  SetVar2Param(GetIBXSQLVAR, Value);
end;

procedure TwrpIBXSQLVAR.Set_IsNull(Value: WordBool);
begin
  GetIBXSQLVAR.IsNull := Value;
end;

procedure TwrpIBXSQLVAR.Set_IsNullable(Value: WordBool);
begin
  GetIBXSQLVAR.IsNullable := Value;
end;

procedure TwrpIBXSQLVAR.Set_Modified(Value: WordBool);
begin
  GetIBXSQLVAR.Modified := Value;
end;

procedure TwrpIBXSQLVAR.Set_Value(Value: OleVariant);
begin
  SetVar2Param(GetIBXSQLVAR, Value);
end;

function TwrpIBXSQLVAR.Get_AsInteger: ATID;
begin
  Result := GetTID(GetIBXSQLVAR.AsDouble);
end;

procedure TwrpIBXSQLVAR.Set_AsInteger(Value: ATID);
begin
  SetTID(GetIBXSQLVAR, Trunc(Value));
end;

function TwrpIBXSQLVAR.Get_AsFloat: Double;
begin
  Result := GetIBXSQLVAR.AsFloat;
end;

procedure TwrpIBXSQLVAR.Set_AsFloat(Value: Double);
begin
  GetIBXSQLVAR.AsFloat := Value;
end;

function TwrpIBXSQLVAR.Get_AsDouble: Double;
begin
  Result := GetIBXSQLVAR.AsDouble;
end;

function TwrpIBXSQLVAR.Get_AsInt64: Int64;
begin
  Result := GetIBXSQLVAR.AsInt64;
end;

function TwrpIBXSQLVAR.Get_AsLong: Integer;
begin
  Result := GetIBXSQLVAR.AsLong
end;

function TwrpIBXSQLVAR.Get_AsShort: Smallint;
begin
  Result := GetIBXSQLVAR.AsShort;
end;

procedure TwrpIBXSQLVAR.Set_AsDouble(Value: Double);
begin
  GetIBXSQLVAR.AsDouble := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsInt64(Value: Int64);
begin
  GetIBXSQLVAR.AsInt64 := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsLong(Value: Integer);
begin
  GetIBXSQLVAR.AsLong := Value;
end;

procedure TwrpIBXSQLVAR.Set_AsShort(Value: Smallint);
begin
  GetIBXSQLVAR.AsShort := Value;
end;

procedure TwrpIBXSQLVAR.LoadFromStream(const Param1: IgsStream);
begin
  GetIBXSQLVAR.LoadFromStream(InterfaceToObject(Param1) as TStream);
end;

procedure TwrpIBXSQLVAR.SaveToStream(const Param1: IgsStream);
begin
  GetIBXSQLVAR.SaveToStream(InterfaceToObject(Param1) as TStream);
end;

{ TwrpIBXSQLDA }

procedure TwrpIBXSQLDA.AddName(const FieldName: WideString; Idx: Integer);
begin
  GetIBXSQLDA.AddName(FieldName, Idx);
end;

function TwrpIBXSQLDA.ByName(const Idx: WideString): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBXSQLDA.ByName(Idx)) as IgsIBXSQLVAR;
end;

function TwrpIBXSQLDA.Get_Count: Integer;
begin
  Result := GetIBXSQLDA.Count;
end;

function TwrpIBXSQLDA.Get_Modified: WordBool;
begin
  Result := GetIBXSQLDA.Modified;
end;

function TwrpIBXSQLDA.Get_Names: WideString;
begin
  Result := GetIBXSQLDA.Names;
end;

function TwrpIBXSQLDA.Get_RecordSize: Integer;
begin
  Result := GetIBXSQLDA.RecordSize;
end;

function TwrpIBXSQLDA.Get_UniqueRelationName: WideString;
begin
  Result := GetIBXSQLDA.UniqueRelationName;
end;

function TwrpIBXSQLDA.Get_Vars(Idx: Integer): IgsIBXSQLVAR;
begin
  Result := GetGdcOLEObject(GetIBXSQLDA.Vars[Idx]) as IgsIBXSQLVAR;
end;

function TwrpIBXSQLDA.GetIBXSQLDA: TIBXSQLDA;
begin
  Result := GetObject as TIBXSQLDA;
end;

procedure TwrpIBXSQLDA.Set_Count(Value: Integer);
begin
  GetIBXSQLDA.Count := Value;
end;

{ TwrpParam }

procedure TwrpParam.AssignField(const Field: IgsFieldComponent);
begin
  GetParam.AssignField(InterfaceToObject(Field) as TField);
end;

procedure TwrpParam.AssignFieldValue(const Field: IgsFieldComponent;
  Value: OleVariant);
begin
  GetParam.AssignFieldValue(InterfaceToObject(Field) as TField, Value);
end;

procedure TwrpParam.Clear;
begin
  GetParam.Clear;
end;

function TwrpParam.Get_Bound: WordBool;
begin
  Result := GetParam.Bound;
end;

function TwrpParam.Get_DataType: TgsFieldType;
begin
  Result := TgsFieldType(GetParam.DataType);
end;

function TwrpParam.Get_IsNull: WordBool;
begin
  Result := GetParam.IsNull;
end;

function TwrpParam.Get_Name: WideString;
begin
  Result := GetParam.Name;
end;

function TwrpParam.Get_Text: WideString;
begin
  Result := GetParam.Text;
end;

function TwrpParam.Get_Value: OleVariant;
begin
  Result := GetParam.Value;
end;

function TwrpParam.GetDataSize: Integer;
begin
  Result := GetParam.GetDataSize;
end;

function TwrpParam.GetParam: TParam;
begin
  Result := GetObject as TParam;
end;

procedure TwrpParam.Set_Bound(Value: WordBool);
begin
  GetParam.Bound := Value;
end;

procedure TwrpParam.Set_DataType(Value: TgsFieldType);
begin
  GetParam.DataType := TFieldType(Value);
end;

procedure TwrpParam.Set_Name(const Value: WideString);
begin
  GetParam.Name := Value;
end;

procedure TwrpParam.Set_Text(const Value: WideString);
begin
  GetParam.Text := Value;
end;

procedure TwrpParam.Set_Value(Value: OleVariant);
begin
  GetParam.Value := Value;
end;

function TwrpParam.Get_AsBCD: Currency;
begin
  Result := GetParam.AsBCD;
end;

function TwrpParam.Get_AsBlob: WideString;
begin
  Result := GetParam.AsBlob;
end;

function TwrpParam.Get_AsBoolean: WordBool;
begin
  Result := GetParam.AsBoolean;
end;

function TwrpParam.Get_AsCurrency: Currency;
begin
  Result := GetParam.AsCurrency;
end;

function TwrpParam.Get_AsDate: TDateTime;
begin
  Result := GetParam.AsDate;
end;

function TwrpParam.Get_AsDateTime: TDateTime;
begin
  Result := GetParam.AsDateTime;
end;

function TwrpParam.Get_AsFloat: Double;
begin
  Result := GetParam.AsFloat;
end;

function TwrpParam.Get_AsInteger: ATID;
begin
  Result := GetTID(GetParam.AsFloat);
end;

function TwrpParam.Get_AsMemo: WideString;
begin
  Result := GetParam.AsMemo;
end;

function TwrpParam.Get_AsSmallInt: Integer;
begin
  Result := GetParam.AsSmallInt;
end;

function TwrpParam.Get_AsString: WideString;
begin
  Result := GetParam.AsString;
end;

function TwrpParam.Get_AsTime: TDateTime;
begin
  Result := GetParam.AsTime;
end;

function TwrpParam.Get_AsWord: Integer;
begin
  Result := GetParam.AsWord;
end;

procedure TwrpParam.Set_AsBCD(Value: Currency);
begin
  GetParam.AsBCD := Value;
end;

procedure TwrpParam.Set_AsBlob(const Value: WideString);
begin
  GetParam.AsBlob := Value;
end;

procedure TwrpParam.Set_AsBoolean(Value: WordBool);
begin
  GetParam.AsBoolean := Value;
end;

procedure TwrpParam.Set_AsCurrency(Value: Currency);
begin
  GetParam.AsCurrency := Value;
end;

procedure TwrpParam.Set_AsDate(Value: TDateTime);
begin
  GetParam.AsDate := Value;
end;

procedure TwrpParam.Set_AsDateTime(Value: TDateTime);
begin
  GetParam.AsDateTime := Value;
end;

procedure TwrpParam.Set_AsFloat(Value: Double);
begin
  GetParam.AsFloat := Value;
end;

procedure TwrpParam.Set_AsInteger(Value: ATID);
begin
  GetParam.AsFloat := Value;
end;

procedure TwrpParam.Set_AsMemo(const Value: WideString);
begin
  GetParam.AsMemo := Value;
end;

procedure TwrpParam.Set_AsSmallInt(Value: Integer);
begin
  GetParam.AsSmallInt := Value;
end;

procedure TwrpParam.Set_AsString(const Value: WideString);
begin
  GetParam.AsString := Value;
end;

procedure TwrpParam.Set_AsTime(Value: TDateTime);
begin
  GetParam.AsTime := Value;
end;

procedure TwrpParam.Set_AsWord(Value: Integer);
begin
  GetParam.AsWord := Value;
end;

function TwrpParam.Get_AsVariant: OleVariant;
begin
  Result := Get_Value;
end;

procedure TwrpParam.Set_AsVariant(Value: OleVariant);
begin
  Set_Value(Value);
end;

function TwrpParam.Get_NativeStr: WideString;
begin
  Result := GetParam.NativeStr;
end;

function TwrpParam.Get_ParamType: TgsParamType;
begin
  Result := TgsParamType(GetParam.ParamType);
end;

procedure TwrpParam.Set_NativeStr(const Value: WideString);
begin
  GetParam.NativeStr := Value;
end;

procedure TwrpParam.Set_ParamType(Value: TgsParamType);
begin
  GetParam.ParamType := TParamType(Value);
end;

{ TwrpBlobField }

function TwrpBlobField.GetField: TBlobField;
begin
  Result := GetObject as TBlobField;
end;

function TwrpBlobField.Get_BlobSize: Integer;
begin
  Result := GetField.BlobSize;
end;

function TwrpBlobField.Get_BlobType: Integer;
begin
  Result := Integer(GetField.BlobType);
end;

function TwrpBlobField.Get_Modified: WordBool;
begin
  Result := GetField.Modified;
end;

function TwrpBlobField.Get_Transliterate: WordBool;
begin
  Result := GetField.Transliterate;
end;

procedure TwrpBlobField.LoadFromFile(const Param1: WideString);
begin
  GetField.LoadFromFile(Param1);
end;

procedure TwrpBlobField.LoadFromStream(const Param1: IgsStream);
begin
  GetField.LoadFromStream(InterfaceToObject(Param1) as TStream);
end;

procedure TwrpBlobField.SaveToFile(const Param1: WideString);
begin
  GetField.SaveToFile(Param1);
end;

procedure TwrpBlobField.SaveToStream(const Param1: IgsStream);
begin
  GetField.SaveToStream(InterfaceToObject(Param1) as TStream);
end;

procedure TwrpBlobField.Set_BlobType(Value: Integer);
begin
  GetField.BlobType := TBlobType(Value);
end;

procedure TwrpBlobField.Set_Modified(Value: WordBool);
begin
  GetField.Modified := Value;
end;

procedure TwrpBlobField.Set_Transliterate(Value: WordBool);
begin
  GetField.Transliterate := Value;
end;

{ TwrpLookupList }

procedure TwrpLookupList.Add(AKey, AValue: OleVariant);
begin
  GetLookupList.Add(AKey, AValue);
end;

procedure TwrpLookupList.Clear;
begin
  GetLookupList.Clear;
end;

function TwrpLookupList.GetLookupList: TLookupList;
begin
  Result := GetObject as TLookupList;
end;

function TwrpLookupList.ValueOfKey(AKey: OleVariant): OleVariant;
begin
  Result := GetLookupList.ValueOfKey(AKey);
end;

initialization
  RegisterGdcOLEClass(TObject, TwrpObject, ComServer.TypeLib, IID_IgsObject);
  RegisterGdcOLEClass(TPersistent, TwrpPersistent, ComServer.TypeLib, IID_IgsPersistent);
  RegisterGdcOLEClass(TComponent, TwrpComponent, ComServer.TypeLib, IID_IgsComponent);
  RegisterGdcOLEClass(TCollectionItem, TwrpCollectionItem, ComServer.TypeLib, IID_IgsCollectionItem);
  RegisterGdcOLEClass(TCollection, TwrpCollection, ComServer.TypeLib, IID_IgsCollection);
  RegisterGdcOLEClass(TField, TwrpField, ComServer.TypeLib, IID_IgsFieldComponent);
  RegisterGdcOLEClass(TBlobField, TwrpBlobField, ComServer.TypeLib, IID_IgsBlobFieldComponent);
  RegisterGdcOLEClass(TIBXSQLVAR, TwrpIBXSQLVAR, ComServer.TypeLib, IID_IgsIBXSQLVAR);
  RegisterGdcOLEClass(TIBXSQLDA, TwrpIBXSQLDA, ComServer.TypeLib, IID_IgsIBXSQLDA);
  RegisterGdcOLEClass(TParam, TwrpParam, ComServer.TypeLib, IID_IgsParam);
  RegisterGdcOLEClass(TLookupList, TwrpLookupList, ComServer.TypeLib, IID_IgsLookupList);

end.
