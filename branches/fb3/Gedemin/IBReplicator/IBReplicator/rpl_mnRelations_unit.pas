unit rpl_mnRelations_unit;

interface
uses rpl_BaseTypes_unit, IBSQL, rpl_const, SysUtils, rpl_ResourceString_unit,
  CheckTreeView, Classes, ComCtrls, ImgList, Contnrs, Windows, Forms, Controls,
  rpl_GlobalVars_unit, Dialogs, rpl_ReplicationServer_unit,
  rpl_frmEditTrigger_unit, XPComboBox;
{ TODO -cСделать :
Необходимо реализовать сортировку таблиц в соответствии со
ссылками и признаком установки соответствия }
type
  TmnCustomRelationWrap = class;
  TmnRelation = class;

  TmnField = class(TrpField)
  private
    FChecked: Boolean;
    FOnChange: TNotifyEvent;
    FIsKey: Boolean;
    FWrapList: TList;
    FIsComputed: Boolean;
    procedure SetChecked(const Value: Boolean);
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetCaption: string;
    procedure SetIsKey(const Value: Boolean);
    procedure SetIsComputed(const Value: Boolean);
  protected
    procedure DoChanged; virtual;
    procedure SetIsPrimeKey(const Value: Boolean); override;
    procedure SetConformity(const Value: Boolean);override;
    procedure AddWrap(W: TmnCustomRelationWrap);
    procedure RemoveWrap(W: TmnCustomRelationWrap);
  public
    destructor Destroy; override;
    //Признак участия поля в репликации
    property Checked: Boolean read FChecked write SetChecked;

    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property Caption: string read GetCaption;
    //Данное свойство равно тру если поле входит в ключ по
    //которому происходит поиск записи
    property IsKey: Boolean read FIsKey write SetIsKey;
    property IsComputed: Boolean read FIsComputed write SetIsComputed;
  end;

  TmnGenerator = class (TObject)
  private
    FValue: integer;
    FRelation: TmnRelation;
    FWrapList: TList;
    procedure SetRelation(const Value: TmnRelation);
  protected
    procedure DoChanged;
    procedure AddWrap(W: TmnCustomRelationWrap);
    procedure RemoveWrap(W: TmnCustomRelationWrap);
  public
    property Value: integer read FValue write FValue;
    property Relation: TmnRelation read FRelation write SetRelation;
  end;

  TmnTrigger = class(TrpTrigger)
  private
    FChecked: Boolean;
    FOnChange: TNotifyEvent;
    FWrapList: TList;
    FRelation: TmnRelation;
    procedure SetChecked(const Value: Boolean);
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetCaption: string;
    function GetIsCustom: boolean;
  protected
    function GetBody: string; override;
    procedure DoChanged; virtual;
    procedure AddWrap(W: TmnCustomRelationWrap);
    procedure RemoveWrap(W: TmnCustomRelationWrap);
    function GetDefBody: string;
  public
    property Checked: Boolean read FChecked write SetChecked;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property IsCustom: boolean read GetIsCustom;
    property Relation: TmnRelation read FRelation write FRelation;
    property TriggerCaption: string read GetCaption;
    property DefBody: string read GetDefBody;

    procedure Edit;
    function CreateDll: string;
    function AlterDll: string;
    function GetTriggerName: string;
  end;

  TmnRelation = class(TrpRelation)
  private
    FChecked: Boolean;
    FOnChange: TNotifyEvent;
    FErrorCode: Integer;
    FTriggerAI: TmnTrigger;
    FTriggerAU: TmnTrigger;
    FTriggerAD: TmnTrigger;
    FGenerator: TmnGenerator;

    procedure SetChecked(const Value: Boolean);
    procedure SetOnChange(const Value: TNotifyEvent);
    function GetErrorMessage: string;
    function GetErrorCode: Integer;
    function CheckRefEx(R: TmnRelation; L: TList): boolean;
    procedure GetDegreeOfFreedom(var C: Integer; const L: TList);
    function GetTriggerAD: TmnTrigger;
    function GetTriggerAI: TmnTrigger;
    function GetTriggerAU: TmnTrigger;
    function GetGenerator: TmnGenerator;
  protected
//    FPrepared: Boolean;

    procedure CheckGeneratorName;
    procedure CheckTriggers;
    procedure CheckTrigger(var ATrigger: TmnTrigger; APos: TTriggerActionPosition; AAction: TTriggerAction);
    procedure CheckGenerator;
    procedure CheckLoaded; override;
    procedure FieldChanged(Field: TmnField);
    //Процедура производит анализ и помечает поля как ключ для
    //поиска необходимой записи
    procedure SetPrimeKey;
    //Подготавливает таблицу к записи в базу
//    procedure Prepare(var Key: Integer);
    //Заполняет список таблиц с учетом ссылок.
//    procedure GetRefList(const List: TList);
    //Возвращает Тру если имеется ссылка на переданную таблицу
    function RefExist(R: TmnRelation): Boolean;
    function DegreeOfFreedom: Integer;

    procedure SetGeneratorName(const Value: string); override;
  public
    //Признак участия таблицы в репликации
    property Checked: Boolean read FChecked write SetChecked;
    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property ErrorMessage: string read GetErrorMessage;
    property ErrorCode: Integer read GetErrorCode;
    property TriggerAI: TmnTrigger read GetTriggerAI write FTriggerAI;
    property TriggerAU: TmnTrigger read GetTriggerAU write FTriggerAU;
    property TriggerAD: TmnTrigger read GetTriggerAD write FTriggerAD;
    property Generator: TmnGenerator read GetGenerator write FGenerator;
  end;

  TmnRelations = class(TrpRelations)
  private
    function GetRelations(Index: Integer): TmnRelation;
    function GetErrorCount: Integer;
  protected
    procedure CheckLoaded; override;
  public
    function IndexOfByName(RelationName: string): Integer;
    function FindRelation(RelationName: string): TmnRelation;
    procedure Prepare;

    property RelationsByIndex[Index: Integer]: TmnRelation read GetRelations; default;
    property ErrorCount: Integer read GetErrorCount;
  end;

  //Абстрактный класс объекта-обертки
  TmnCustomRelationWrap = class
  private
    FNode: TCheckTreeNode;
  protected
    procedure SetWrappedObject(const Value: TObject); virtual; abstract;
    function GetWrappedObject: TObject; virtual; abstract;
    procedure SetNode(const Value: TCheckTreeNode); virtual;

    procedure OnObjectChange(Sender: TObject); virtual; abstract;
  public
    destructor Destroy;  override;

    function ImageIndex: Integer; virtual; abstract;
    function SelectImageIndex: Integer; virtual; abstract;
    function OverlayIndex: Integer; virtual;
    function ErrorMessage: string; virtual;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode); virtual; abstract;
    property WrappedObject: TObject read GetWrappedObject write SetWrappedObject;
    property Node: TCheckTreeNode read FNode write SetNode;
  end;

  //Обёртка для поля
  TmnFieldWrap = class(TmnCustomRelationWrap)
  private
    FField: TmnField;
  protected
    procedure SetWrappedObject(const Value: TObject); override;
    function GetWrappedObject: TObject; override;
    procedure SetNode(const Value: TCheckTreeNode); override;

    procedure OnObjectChange(Sender: TObject); override;
  public
    destructor Destroy; override;
    function ImageIndex: Integer; override;
    function SelectImageIndex: Integer; override;
    function OverlayIndex: Integer; override;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode);override;
    property Field: TmnField read FField;
  end;

  //Обёртка для таблицы
  TmnRelationWrap = class(TmnCustomRelationWrap)
  private
    FRelation: TmnRelation;
  protected
    procedure SetWrappedObject(const Value: TObject); override;
    function GetWrappedObject: TObject; override;
    procedure SetNode(const Value: TCheckTreeNode); override;

    procedure OnObjectChange(Sender: TObject); override;
  public
    function ImageIndex: Integer; override;
    function SelectImageIndex: Integer; override;
    function OverlayIndex: Integer; override;
    function ErrorMessage: string; override;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode);override;
  end;

  TmnFieldConformityWrap = class(TmnCustomRelationWrap)
  private
    FField: TmnField;
  protected
    procedure SetWrappedObject(const Value: TObject); override;
    function GetWrappedObject: TObject; override;
    procedure SetNode(const Value: TCheckTreeNode); override;

    procedure OnObjectChange(Sender: TObject); override;
  public
    destructor Destroy; override;

    function ImageIndex: Integer; override;
    function SelectImageIndex: Integer; override;
    function OverlayIndex: Integer; override;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode);override;
    property Field: TmnField read FField;
  end;

  //Обёртка для триггера
  TmnTriggerWrap = class(TmnCustomRelationWrap)
  private
    FTrigger: TmnTrigger;
  protected
    procedure SetWrappedObject(const Value: TObject); override;
    function GetWrappedObject: TObject; override;
    procedure SetNode(const Value: TCheckTreeNode); override;

    procedure OnObjectChange(Sender: TObject); override;
  public
    destructor Destroy; override;
    function ImageIndex: Integer; override;
    function SelectImageIndex: Integer; override;
    function OverlayIndex: Integer; override;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode);override;
    property Trigger: TmnTrigger read FTrigger;
  end;

  TmnGeneratorWrap = class(TmnCustomRelationWrap)
  private
    FGenerator: TmnGenerator;
    FGenList: TXPComboBox;
  protected
    procedure SetWrappedObject(const Value: TObject); override;
    function GetWrappedObject: TObject; override;
    procedure SetNode(const Value: TCheckTreeNode); override;

    procedure OnGeneratorChange(Sender: TObject);
    procedure OnObjectChange(Sender: TObject); override;
  public
    destructor Destroy; override;
    function ImageIndex: Integer; override;
    function SelectImageIndex: Integer; override;
    function OverlayIndex: Integer; override;

    procedure OnNodeClick(Sender: TObject; Node: TTreeNode); overload; override;

    procedure SetSelected(Value: boolean);
    property Generator: TmnGenerator read FGenerator;
    property GeneratorList: TXPComboBox read FGenList write FGenList;
  end;

function FKCompare(Item1, Item2: Pointer): Integer;

implementation

uses rpl_ReplicationManager_unit, Math;

{ TmnRelation }
var
  _Keys: TList;

procedure PrevKey(var Key: Integer);
begin
  if _Keys = nil then
    _Keys := TList.Create;

  repeat
    Dec(Key);
  until _Keys.IndexOf(Pointer(Key)) = - 1;
  _Keys.Add(Pointer(Key));
end;

procedure NextKey(var Key: Integer);
begin
  if _Keys = nil then
    _Keys := TList.Create;

  repeat
    Inc(Key);
  until _Keys.IndexOf(Pointer(Key)) = - 1;
  _Keys.Add(Pointer(Key));
end;

procedure TmnRelation.CheckLoaded;
var
  SQL: TIBSQL;
  F: TmnField;
  R: TmnRelation;
  Index: Integer;
begin
  if not FLoaded then
  begin
    //Устанавливаем признак успешной загрузки для того чтобы мормально
    //происходила загрузка внешних ключей
    FLoaded := True;
    try
      if FFields =  nil then
        FFields := TrpFields.Create;

      if FKeys = nil then
      begin
        FKeys := TrpFields.Create;
        FKeys.OwnObjects := False;
      end;

      FKeys.Clear;
      FFields.Clear;

      SQL := IBSQL;
      SQL.SQL.Text :=
        'SELECT'#13#10 +
        '  rf.rdb$field_name as fieldname,'#13#10 +
        '  f.rdb$field_type AS fieldtype,'#13#10 +
        '  f.rdb$field_sub_type AS fieldsubtype,'#13#10 +
        '  (SELECT'#13#10 +
        '    1'#13#10 +
        '   FROM'#13#10 +
        '     rdb$relation_constraints rc'#13#10 +
        '     LEFT JOIN rdb$index_segments i_s ON rc.rdb$index_name = i_s.rdb$index_name'#13#10 +
        '   WHERE'#13#10 +
        '    rc.rdb$relation_name = rf.rdb$relation_name AND'#13#10 +
        '    rc.rdb$constraint_type = ''PRIMARY KEY'' AND'#13#10 +
        '    i_s.rdb$field_name = rf.rdb$field_name) AS IsPrimeKey,'#13#10 +
        '    rf.rdb$null_flag as notnull'#13#10 +
        'FROM'#13#10 +
        '  rdb$relation_fields rf'#13#10 +
        '  LEFT JOIN rdb$fields f ON f.rdb$field_name = rf.rdb$field_source'#13#10 +
        'WHERE'#13#10 +
        '  rf.rdb$relation_name = :relationname'#13#10 +
        'ORDER BY 3, 1';
      SQL.ParamByName(fnRelationName).AsString := RelationName;
      SQL.ExecQuery;

      while not SQL.Eof do
      begin
        F := TmnField.Create;
        F.FieldName := Trim(SQL.FieldByName(fnFieldName).AsString);
        F.FieldType := SQL.FieldByName(fnFieldType).AsInteger;
        F.IsPrimeKey := SQL.FieldByName(fnIsPrimeKey).AsInteger > 0;
        F.FNotNull := SQL.FieldByName(fnNotNull).AsInteger > 0;
        F.FieldSubType := SQL.FieldByName(fnFieldSubType).AsInteger;
        F.Relation := Self;
        FFields.Add(F);

        SQL.Next;
      end;

      LoadUniqeIndices;

      //Загрузка вычисляемых полей
      SQL.Close;
      SQL.SQl.Text := SELECT_COMPUTED_FIED;
      SQl.ParamByName(fnRelationName).AsString := RelationName;
      SQL.ExecQuery;

      while not SQL.Eof do
      begin
        Index := FFields.IndexOfField(Trim(SQL.FieldByName(fnFieldName).AsString));
        if Index > - 1 then
        begin
          F := TmnField(FFields[Index]);
          F.IsComputed := True;
        end else
          raise Exception.Create(InvalidFieldName);
        SQL.Next;  
      end;

      //Загрузка внешних ключей
      SQL.Close;

      SQL.SQL.Clear;
      //Загрузка внешних ключей
      SQL.SQL.Add(SELECT_FOREIGN_KEYS_BY_RELATIONNAME);
      SQL.ParamByName(fnRelationName).AsString := RelationName;
      SQL.ExecQuery;

      while not SQL.Eof do
      begin
        Index := FFields.IndexOfField(Trim(SQL.FieldByName(fnFieldName).AsString));
        if Index > - 1 then
        begin
          F := TmnField(FFields[Index]);
          R := ReplicationManager.Relations.FindRelation(Trim(SQL.FieldByName(fnRefRelationName).AsString));

          if R.RelationName <> RelationName then
            R.Load;

          Index := R.FFields.IndexOfField(Trim(SQL.FieldByName(fnRefFieldName).AsString));
          if Index > - 1 then
          begin
            F.ReferenceField := R.FFields[Index];
          end else
            raise Exception.Create(InvalidFieldName);
        end else
          raise Exception.Create(InvalidFieldName);

        SQL.Next;
      end;

      if ReplDataBase.TableExist(Tables[RPL_RELATION_INDEX]) and
        ReplDataBase.TableExist(Tables[RPL_FIELDS_INDEX]) and
        ReplDataBase.TableExist(Tables[RPL_KEYS_INDEX]) then
      begin
        //Загрузка старой схемы
        SQL.Close;

        SQL.SQL.Clear;
        SQL.SQL.Add('SELECT * FROM rpl$fields WHERE relationkey = :relationkey');
        SQL.ParamByName(fnRelationKey).AsInteger := RelationKey;
        SQL.ExecQuery;

        while not SQL.Eof do
        begin
          Index := FFields.IndexOfField(Trim(SQL.FieldByName(fnFieldName).AsString));
          if Index > - 1 then
          begin
            F := TmnField(FFields[Index]);
            F.Checked := True;
            F.IsKey := False;
          end;
          SQL.Next;
        end;

        SQL.Close;

        SQL.SQL.Clear;
        SQL.SQL.Add('SELECT * FROM rpl$keys WHERE relationkey = :relationkey');
        SQL.ParamByName(fnRelationKey).AsInteger := RelationKey;
        SQL.ExecQuery;

        while not SQL.Eof do
        begin
          Index := FFields.IndexOfField(Trim(SQL.FieldByName(fnKeyName).AsString));
          if Index > - 1 then
          begin
            F := TmnField(FFields[Index]);
            F.Checked := True;
            F.IsKey := True;
          end;
          SQL.Next;
        end;
      end;
//      FPrepared := False;
    except
      FLoaded := False;
    end;
  end;
  { DONE -cСделать : Загрузка старой схемы, если база уже подготовлена к репликации }
end;

function TmnRelation.CheckRefEx(R: TmnRelation; L: TList): boolean;
var
  I, Index: Integer;
  _R: TmnRelation;
begin
  Result := False;
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].IsForeign and
      (Fields[I].ReferenceField.Relation <> Self) then
    begin
      _R := TmnRelation(Fields[I].ReferenceField.Relation);
      Result := _R = R;
      if Result then
      begin
        Exit;
      end else
      begin
        Index := L.IndexOf(Self);
        if Index = - 1 then
        begin
          L.Add(Self);
          Result := _R.CheckRefEx(R, L);
          if Result then
            Exit;
        end;
      end;
    end;
  end;
end;

function TmnRelation.DegreeOfFreedom: Integer;
var
  L: TList;
begin
  L := TList.Create;
  try
    Result := 0;
    GetDegreeOfFreedom(Result, L);
  finally
    L.Free;
  end;
end;

procedure TmnRelation.FieldChanged(Field: TmnField);
begin
  FErrorCode := ERR_CODE_NOT_INIT;

  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TmnRelation.GetDegreeOfFreedom(var C: Integer; const L: TList);
var
  I, Index: Integer;
  R: TmnRelation;
begin
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].IsForeign and
      (Fields[i].ReferenceField.Relation <> Self) then
    begin
      R := TmnRelation(Fields[I].ReferenceField.Relation);
      Index := L.IndexOf(R);
      if Index = - 1 then
      begin
        Inc(C);
        L.Add(Self);
        R.GetDegreeOfFreedom(C, L);
      end;
    end;
  end;
end;

function TmnRelation.GetErrorCode: Integer;
var
  I: Integer;
  CheckedCount: Integer;
  PKCount, PKSelect: Integer;
begin
  if FErrorCode = ERR_CODE_NOT_INIT then
  begin
    FErrorCode := ERR_CODE_OK;
    if FChecked and (FFields <> nil) then
    begin
      CheckedCount := 0;
      PKCount := 0;
      PKSelect := 0;
      for I := 0 to FFields.Count - 1 do
      begin
        if TmnField(FFields[i]).Checked then
        begin
          Inc(CheckedCount);
          if TmnField(FFields[i]).IsKey then
            Inc(PKSelect);
        end;

        if TmnField(FFields[i]).IsKey then
          Inc(PKCount);

        if TmnField(FFields[I]).NotNull and
          not TmnField(FFields[i]).Checked then
        begin
          FErrorCode := ERR_CODE_NOTNULL_NOT_SELECTED;
        end;
      end;

      if CheckedCount = 0 then
        FErrorCode := ERR_CODE_NOONE_FIELD_SELECTED
      else if PKCount = 0 then
        FErrorCode := ERR_CODE_PK_NOT_MARK
      else if PKSelect = 0 then
        FErrorCode := ERR_CODE_PK_NOT_SELECT
      else if (ReplicationManager.PrimeKeyType = ptUniqueInRelation) and
        (GeneratorName = '') then
        FErrorCode := ERR_CODE_GENERATOR_NAME_MISSING;
    end;
  end;
  Result := FErrorCode;
end;

function TmnRelation.GetErrorMessage: string;
begin
  Result := '';
  case ErrorCode of
    ERR_CODE_OK: Result := ERR_OK;
    ERR_CODE_NOONE_FIELD_SELECTED: Result := ERR_NOONE_FIELD_SELECTED;
    ERR_CODE_PK_NOT_SELECT: Result := ERR_PK_NOT_SELECT;
    ERR_CODE_NOTNULL_NOT_SELECTED: Result := ERR_NOTNULL_NOT_SELECTED;
    ERR_CODE_PK_NOT_MARK: Result := ERR_PK_NOT_MARK;
    ERR_CODE_GENERATOR_NAME_MISSING: Result := ERR_GENERATOR_NAME_MISSING;
  end;
  Assert(Result <> '', 'Ненайдено собщение об ошибке');
end;


{procedure TmnRelation.GetRefList(const List: TList);
var
  Index, I, InsertIndex: Integer;
  R: TmnRelation;
begin
  Index := List.IndexOf(Self);
  if Index = - 1 then
  begin
    InsertIndex := 0;
    for I := 0 to Fields.Count - 1 do
    begin
      if Fields[I].IsForeign and
        (Fields[I].ReferenceField.Relation <> Self) then
      begin
        R := TmnRelation(Fields[I].ReferenceField.Relation);
        R.GetRefList(List);
        Index := List.IndexOf(R);
        if InsertIndex <= Index then
          InsertIndex := Index + 1;
      end;
    end;
    List.Insert(InsertIndex, Self);
  end;
end;}

{procedure TmnRelation.Prepare(var Key: Integer);
var
  I: Integer;
  R: TmnRelation;
begin
  if not FPrepared then
  begin
    FPrepared := True;
    PrevKey(Key);
    RelationKey := Key;

    for I := 0 to Fields.Count - 1 do
    begin
      if Fields[I].IsForeign then
      begin
        R := TmnRelation(Fields[I].ReferenceField.Relation);
        R.Prepare(Key);
      end;
    end;
  end;
end;}

procedure TmnRelation.CheckTrigger(var ATrigger: TmnTrigger; APos: TTriggerActionPosition; AAction: TTriggerAction);
begin
  if not Assigned(ATrigger) then begin
    ATrigger:= TmnTrigger.Create;
    ATrigger.Relation:= self;
    ATrigger.RelationName:= RelationName;
    ATrigger.Action:= AAction;
    ATrigger.ActionPosition:= APos;
    ATrigger.TriggerName:= ATrigger.GetTriggerName;
    ATrigger.Checked:= True;
  end;
end;

function TmnRelation.GetTriggerAD: TmnTrigger;
begin
  CheckTrigger(FTriggerAD, tapAfter, rpl_const.taDelete);
  Result := FTriggerAD;
end;

function TmnRelation.GetTriggerAI: TmnTrigger;
begin
  CheckTrigger(FTriggerAI, tapAfter, rpl_const.taInsert);
  Result := FTriggerAI;
end;

function TmnRelation.GetTriggerAU: TmnTrigger;
begin
  CheckTrigger(FTriggerAU, tapAfter, rpl_const.taUpdate);
  Result := FTriggerAU;
end;

function TmnRelation.RefExist(R: TmnRelation): Boolean;
var
  L: TList;
begin
  L := TList.Create;
  try
    Result := CheckRefEx(R, L);
  finally
    L.Free;
  end;
end;

procedure TmnRelation.SetChecked(const Value: Boolean);
var
  I, J: Integer;
  F: TmnField;
  RefCount: Integer;
  CheckedCount: Integer;
  mrRes, mrResB: TModalResult;
  b, b1: boolean;
begin
  if FChecked <> Value then
  begin
    FChecked := Value;
    FErrorCode := ERR_CODE_NOT_INIT;

    CheckGeneratorName;

    mrResB:= gvAskQuestionResult;
    b:= gvAskQuestion;
    b1:= gvAskQuestionBack;
    gvAskQuestionBack:= False;

    if FChecked then
    begin
      //Подсч. количество выбранных полей
      CheckedCount := 0;
      for I := 0 to Fields.Count - 1 do
      begin
        if TmnField(Fields[I]).Checked then
          Inc(CheckedCount);
      end;
      //Все нот нул поля должны реплецироваться
      for I := 0 to Fields.Count - 1 do
      begin
        if (TmnField(Fields[I]).NotNull) or (CheckedCount = 0) then begin
          TmnField(Fields[I]).Checked := True;
        end;

        if TmnField(Fields[I]).IsForeign and TmnField(Fields[I]).NotNull then
        begin
          if not (TmnField(Fields[I].ReferenceField).Checked and
            TmnRelation(Fields[I].ReferenceField.Relation).Checked) then
          begin
            mrRes:= AskQuestionResult(
              Format(MSG_SELECT_REFERENCE_FIELD,
              [Fields[I].ReferenceField.FieldName,
              Fields[I].ReferenceField.Relation.RelationName,
              Fields[I].FieldName, Fields[I].ReferenceField.FieldName,
              Fields[I].ReferenceField.Relation.RelationName]),
              mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll]);
            case mrRes of
              mrYes: begin
                  TmnRelation(Fields[I].ReferenceField.Relation).Checked := True;
                  TmnField(Fields[I].ReferenceField).Checked := True;
                end;
              mrYesToAll: begin
                  gvAskQuestionResult:= mrYes;
                  gvAskQuestion:= False;
                  TmnRelation(Fields[I].ReferenceField.Relation).Checked := True;
                  TmnField(Fields[I].ReferenceField).Checked := True;
                end;
              mrNo:
                  FChecked := False;
              mrNoToAll: begin
                  gvAskQuestionResult:= mrNo;
                  gvAskQuestion:= False;
                  FChecked := False;
                end;
            end;
          end;
        end;
      end;

      SetPrimeKey;
    end else
    begin
      RefCount := 0;
      for I := 0 to Fields.Count - 1 do
      begin
        F := TmnField(Fields[I]);
        //Подсчитываем кол-во внешних ссылок
        for J := 0 to F.ForeignFieldCount - 1 do
        begin
          if TmnField(F.ForeignFields[J]).Checked then
            Inc(RefCount);
        end;
      end;

      if RefCount > 0 then
      begin
        mrRes:= AskQuestionResult(
          Format(MSG_SELECT_REFERENCE_FIELDS, [RelationName]),
          mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll]);
        case mrRes of
          mrYes: begin
              for I:= 0 to Fields.Count - 1 do begin
                F:= TmnField(Fields[I]);
                for J:= 0 to F.ForeignFieldCount - 1 do begin
                  if TmnRelation(F.ForeignFields[J].Relation).Checked then begin
                    if TmnField(F.ForeignFields[J]).NotNull then
                      TmnRelation(F.ForeignFields[J].Relation).Checked:= False
                    else
                      TmnField(F.ForeignFields[J]).Checked:= False;
                  end;
                end;
              end;
              if gvAskQuestionResult <> mrYes then
                FChecked := True;
            end;
          mrYesToAll: begin
              gvAskQuestion:= False;
              gvAskQuestionBack:= False;
              gvAskQuestionResult:= mrYes;
              for I:= 0 to Fields.Count - 1 do begin
                F:= TmnField(Fields[I]);
                for J:= 0 to F.ForeignFieldCount - 1 do begin
                  if TmnRelation(F.ForeignFields[J].Relation).Checked then begin
                    if TmnField(F.ForeignFields[J]).NotNull then
                      TmnRelation(F.ForeignFields[J].Relation).Checked:= False
                    else
                      TmnField(F.ForeignFields[J]).Checked:= False;
                  end;
                end;
              end;
              if gvAskQuestionResult <> mrYes then
                FChecked := True;
            end;
          mrNo:
            FChecked := True;
          mrNoToAll: begin
              gvAskQuestion:= False;
              gvAskQuestionBack:= False;
              gvAskQuestionResult:= mrNo;
              FChecked := True;
            end;
        end;


{        if mrRes = mrNoToAll then begin
        end
        else if mrRes in [mrYes, mrYesToAll] then
        if AskQuestion(Format(MSG_SELECT_REFERENCE_FIELDS, [RelationName]))then
        begin
          for I := 0 to Fields.Count - 1 do
          begin
            F := TmnField(Fields[I]);
            for J := 0 to F.ForeignFieldCount - 1 do
            begin
              if TmnRelation(F.ForeignFields[J].Relation).Checked then
              begin
                if TmnField(F.ForeignFields[J]).NotNull then
                  TmnRelation(F.ForeignFields[J].Relation).Checked := False
                else
                  TmnField(F.ForeignFields[J]).Checked := False;
              end;
            end;
          end;
        end else
          FChecked := True;}
      end;
    end;

    if RelationName = gvNodeClicked then begin
      gvAskQuestion:= b;
      gvAskQuestionBack:= b1;
      gvAskQuestionResult:= mrResB;
    end;

    if Assigned(OnChange) then
      OnChange(Self);
  end;
end;

procedure TmnRelation.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TmnRelation.SetPrimeKey;
var
  I, Index: Integer;
  U1, U2: TrpUniqueIndex;
  PK: TmnField;
begin
  for I := 0 to Fields.Count - 1 do
  begin
    if TmnField(Fields[I]).IsKey then
    //Первичный ключ уже выблан поэтому выходим
      Exit;
  end;

  Pk := nil;
  for I := 0 to Fields.Count - 1 do
  begin
    if Fields[I].IsPrimeKey then
    begin
      PK := TmnField(Fields[I]);
      Break;
    end;
  end;

  if PK <> nil then
  begin
    Index := UniqueIndices.IndexOfByField(Pk.FieldName);
    Assert(Index > - 1, InvalidFieldName);
    U1 := UniqueIndices[Index];

    if (ReplicationManager.PrimeKeyType in [ptUniqueInDb, ptUniqueInRelation]) and
      (UniqueIndices.Count = 2) and
      AskQuestion(Format(MSG_SET_ALT_KEY_AS_PRIME_KEY, [RelationName])) then
    begin
      case Index of
        0:U2 := UniqueIndices[1];
      else
        U2 := UniqueIndices[0];
      end;

      for I := 0 to U2.Fields.Count - 1 do
      begin
        TmnField(U2.Fields[I]).IsKey := True;
        TmnField(U2.Fields[I]).Checked := True;
      end;

      for I := 0 to U1.Fields.Count - 1 do
      begin
        U1.Fields[i].Conformity := True;
      end;
    end else
    begin
      for I := 0 to U1.Fields.Count - 1 do
      begin
        TmnField(U1.Fields[I]).IsKey := True;
        TmnField(U1.Fields[I]).Conformity := False;
        TmnField(U1.Fields[I]).Checked := True;
      end;
    end;
  end else
  begin
    if UniqueIndices.Count > 0  then
    begin
      //Помечаем первый попавшийся альтернативный ключ
      //как ключ
      U1 := UniqueIndices[0];
      for I := 0 to U1.Fields.Count - 1 do
      begin
        TmnField(U1.Fields[I]).IsKey := True;
        TmnField(U1.Fields[I]).Conformity := False;
        TmnField(U1.Fields[I]).Checked := True;
      end;
    end;
  end;
end;

procedure TmnRelation.CheckTriggers;
begin
  CheckTrigger(FTriggerAD, tapAfter, rpl_const.taDelete);
  CheckTrigger(FTriggerAI, tapAfter, rpl_const.taInsert);
  CheckTrigger(FTriggerAU, tapAfter, rpl_const.taUpdate);
end;

function TmnRelation.GetGenerator: TmnGenerator;
begin
  CheckGenerator;
  Result := FGenerator;
end;

procedure TmnRelation.CheckGenerator;
begin
  if not Assigned(FGenerator) then begin
    FGenerator:= TmnGenerator.Create;
    FGenerator.Relation:= self;
  end; 
end;

procedure TmnRelation.CheckGeneratorName;
{$IFNDEF GEDEMIN}
var
  j: integer;
  F: TmnField;
  Gen: TGenerator;
{$ENDIF}
begin
  {$IFNDEF GEDEMIN}
    for J := 0 to Fields.Count - 1 do begin
      F := TmnField(Fields[J]);
      if F.IsPrimeKey then begin
        case ReplicationManager.PrimeKeyType of
          ptUniqueInDb: begin
              GeneratorName:= ReplicationManager.GeneratorName;
            end;
          ptUniqueInRelation: begin
              Gen.Name:= Copy(Format(ReplicationManager.GeneratorMask,
                [RelationName, F.FieldName]), 1, 31);
              if ReplDataBase.GeneratorExist(Gen) then begin
                GeneratorName:= Gen.Name;
              end
              else begin
                GeneratorName:= ReplicationManager.GeneratorName;
              end
            end;
          ptNatural:;
        end;
        Break;
      end;
    end;
  {$ENDIF}
end;

procedure TmnRelation.SetGeneratorName(const Value: string);
begin
  inherited;
  CheckGenerator;
  FGenerator.DoChanged;
end;

{ TmnRelations }

procedure TmnRelations.CheckLoaded;
var
  IBSQL: TIBSQL;
  R: TmnRelation;
  I: Integer;
  B: Boolean;
begin
  if DataBase = nil then
    DataBase := ReplDataBase;

  if not FLoaded then
  begin
    Clear;
    IBSQL := TIBSQL.Create(nil);
    try
      IBSQL.Transaction := DataBase.ReadTransaction;
      IBSQL.SQL.Add('SELECT DISTINCT r.rdb$relation_name as ' + fnRelation);
      {$IFDEF GEDEMIN}
        IBSQL.SQL.Add(', gr.lname as ' + fnRelationLName);
      {$ENDIF}
      IBSQL.SQL.Add(' FROM rdb$relations r ');
      {$IFDEF GEDEMIN}
        IBSQL.SQL.Add(' JOIN at_relations gr on gr.relationname=UPPER(r.rdb$relation_name) ');
      {$ENDIF}
      IBSQL.SQL.Add(' WHERE r.RDB$SYSTEM_FLAG = 0 AND r.rdb$view_blr IS NULL AND ');
      IBSQL.SQL.Add(' NOT r.rdb$relation_name IN (');
      for I := 0 to TableCount - 1 do
      begin
        IBSQL.SQL.Add(Format('''%s'',', [Tables[I].Name]));
      end;
      IBSQL.SQL.Add(QuotedStr('GD_RUID'));
      IBSQL.SQL.Add(')');
      IBSQL.ExecQuery;

      I := GetNewDBID;
      while not IBSQL.Eof do
      begin
        R := TmnRelation.Create;
        Add(R);
        R.RelationName := Trim(IBSQL.FieldByName(fnRelation).AsString);
        {$IFDEF GEDEMIN}
          R.RelationLocalName := Trim(IBSQL.FieldByName(fnRelationLName).AsString);
        {$ENDIF}
        R.DataBase := DataBase;
        R.RelationKey := I;
        Inc(I);
        R.CheckTriggers;
        IBSQL.Next;
      end;

      FLoaded := True;
      B := gvAskQuestion;
      gvAskQuestion := False;
      try
        IBSQL.Close;
        if ReplDataBase.TableExist(Tables[RPL_RELATION_INDEX]) then
        begin
          IBSQL.SQL.Text := 'SELECT * FROM rpl$relations';
          IBSQL.ExecQuery;

          while not IBSQL.Eof do
          begin
            R := TmnRelation(RelationsByIndex[IndexOfByName(IBSQL.FieldByName(fnRelation).AsString)]);
            if R <> nil then
            begin
              R.RelationKey := IBSQL.FieldByName(fnId).AsInteger;
              R.GeneratorName := IBSQL.FieldByName(fnGeneratorName).AsString;
              R.Checked := True;

              R.FTriggerAI.Checked:= ReplicationManager.TriggerExist(R.FTriggerAI.Trigger);
              R.FTriggerAD.Checked:= ReplicationManager.TriggerExist(R.FTriggerAD.Trigger);
              R.FTriggerAU.Checked:= ReplicationManager.TriggerExist(R.FTriggerAU.Trigger);

            end;

            IBSQL.Next;
          end;

        end;
      finally
        gvAskQuestion := B;
      end;
    finally
      IBSQL.Free;
    end;

  end;
end;

function TmnRelations.FindRelation(RelationName: string): TmnRelation;
var
  Index: Integer;
begin
  Index := IndexOfByName(RelationName);
  if Index > - 1 then
    Result := RelationsByIndex[Index]
  else
    raise Exception.Create(Format(InvalidRelationName, [RelationName]));  
end;

function TmnRelations.GetErrorCount: Integer;
var
  I: Integer;
  R: TmnRelation;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    R := TmnRelation(RelationsByIndex[I]);
    if R.ErrorCode <> ERR_CODE_OK then
      Inc(Result);
  end;
end;

function TmnRelations.GetRelations(Index: Integer): TmnRelation;
begin
  CheckLoaded;
  Result := TmnRelation(Items[Index])
end;


function TmnRelations.IndexOfByName(RelationName: string): Integer;
var
  I: integer;
begin
  Result := - 1;
  CheckLoaded;
  for I := 0 to Count - 1 do
  begin
    if RelationsByIndex[i].RelationName = RelationName then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function FKCompare(Item1, Item2: Pointer): Integer;
var
  R1, R2: TmnRelation;
  Ref1, Ref2: Integer;
  D1, D2: Integer;
begin
  R1 := TmnRelation(Item1);
  R2 := TmnRelation(Item2);
  Ref1 := Integer(R1.RefExist(R2));
  Ref2 := Integer(R2.RefExist(R1));
  Result := Ref1 - Ref2;
  if Result = 0 then
  begin
    D1 := R1.DegreeOfFreedom;
    D2 := R2.DegreeOfFreedom;
    Result := D1 - D2;
  end;
end;

procedure TmnRelations.Prepare;
var
  I, J, Key: Integer;
  R: TmnRelation;
  F: TmnField;
  L: TList;
begin
  for I := 0 to Count - 1 do
  begin
    R := TmnRelation(RelationsByIndex[I]);
    R.TriggerAI.Body:= '';
    R.TriggerAU.Body:= '';
    R.TriggerAD.Body:= '';
//    R.FPrepared := False;
//    if R.Checked then
//    begin
      //Заполняем списки ключей для таблиц
      R.Keys.Clear;
      for J := 0 to R.Fields.Count - 1 do
      begin
        F := TmnField(R.Fields[J]);
        if F.Checked then
        begin
          if F.IsKey then
            R.Keys.Add(F);
        end;
      end;
//    end;
  end;

  L := TList.Create;
  try
    for I := 0 to Count - 1 do
    begin
      R := TmnRelation(RelationsByIndex[I]);
//      if R.Checked then
        L.Add(R);
    end;

    L.Sort(@FKCompare);

    Key := GetNewDBID;
    for I := 0 to L.Count - 1 do
    begin
      R := TmnRelation(L[I]);
      R.RelationKey := Key;
//      R.FPrepared := True;
      Inc(Key);
    end;
  finally
    L.Free;
  end;
end;

{ TmnField }

procedure TmnField.DoChanged;
var
  I: Integer;
  W: TmnCustomRelationWrap;
begin
  if Assigned(OnChange) then
    OnChange(Self);

  if FWrapList <> nil then
  begin
    for I := 0 to FWrapList.Count - 1 do
    begin
      W := TmnCustomRelationWrap(FWrapList[I]);
      W.OnObjectChange(Self);
    end;
  end;

  if Relation <> nil then
    TmnRelation(Relation).FieldChanged(Self);
end;

function TmnField.GetCaption: string;
var
  S: string;
const
  cNotNull = 'NOT NULL';
  cUnique = 'UNIQUE';
begin
  S := '';
  if Unique then
    S := cUnique;
  if FNotNull then
  begin
    if Unique then S := S + ', ';
    S := S + cNotNull;
  end;
  if S = '' then
    Result := FieldName
  else
    Result := Format('%s (%s)', [FieldName, S]);
end;

procedure TmnField.SetChecked(const Value: Boolean);
var
  I: Integer;
  b, b1: boolean;
  mrRes, mrResB: TModalResult;
begin
  if FChecked <> value then
  begin
    FChecked := Value;
    mrResB:= gvAskQuestionResult;
    b:= gvAskQuestion;
    b1:= gvAskQuestionBack;

    if FChecked then
    begin
      if not TmnRelation(Relation).Checked then
        TmnRelation(Relation).Checked := True;
      if IsForeign and  not (TmnField(ReferenceField).Checked and
        TmnRelation(ReferenceField.Relation).Checked) then
      begin
        mrRes:= AskQuestionResult(
              Format(MSG_SELECT_REFERENCE_FIELD,
              [ReferenceField.FieldName,
              ReferenceField.Relation.RelationName,
              FieldName, ReferenceField.FieldName,
              ReferenceField.Relation.RelationName]),
              mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll]);
        case mrRes of
          mrYes: begin
              TmnRelation(ReferenceField.Relation).Checked := True;
              TmnField(ReferenceField).Checked := True;
            end;
          mrYesToAll: begin
              gvAskQuestionResult:= mrYes;
              gvAskQuestion:= False;
              TmnRelation(ReferenceField.Relation).Checked := True;
              TmnField(ReferenceField).Checked := True;
              if gvAskQuestionBack then begin
                gvAskQuestion:= b;
                gvAskQuestionResult:= mrRes;
              end;
            end;
          mrNo:
              FChecked := False;
          mrNoToAll: begin
              gvAskQuestionResult:= mrNo;
              gvAskQuestion:= False;
              FChecked := False;
            end;
        end;
      end;
    end else
    begin
      //Проверяем нет ли ссылки на данное поле
      if ForeignFieldCount > 0 then
      begin
        mrRes:= AskQuestionResult(
          Format(MSG_DESELECT_REFERENCE_FIELD, [FieldName]),
          mtConfirmation, [mbYes, mbYesToAll, mbNo, mbNoToAll]);
        case mrRes of
          mrYes: begin
              for I:= 0 to ForeignFieldCount - 1 do begin
                if TmnRelation(ForeignFields[I].Relation).Checked then begin
                  if TmnField(ForeignFields[I]).NotNull then
                    //Если поле нот нул то исключаем всю таблицу
                    TmnRelation(ForeignFields[I].Relation).Checked:= False
                  else
                    //в противном случае исключаем только поле
                    TmnField(ForeignFields[I]).Checked:= False;
                end;
              end;
              if gvAskQuestionResult <> mrYes then
                FChecked := True;
            end;
          mrYesToAll: begin
              gvAskQuestion:= False;
              gvAskQuestionBack:= False;
              gvAskQuestionResult:= mrYes;
              for I:= 0 to ForeignFieldCount - 1 do begin
                if TmnRelation(ForeignFields[I].Relation).Checked then begin
                  if TmnField(ForeignFields[I]).NotNull then
                    TmnRelation(ForeignFields[I].Relation).Checked:= False
                  else
                    TmnField(ForeignFields[I]).Checked:= False;
                end;
              end;
              if gvAskQuestionResult <> mrYes then
                FChecked := True;
            end;
          mrNo:
            FChecked := True;
          mrNoToAll: begin
              gvAskQuestion:= False;
              gvAskQuestionBack:= False;
              gvAskQuestionResult:= mrNo;
              FChecked := True;
            end;
        end;


{        if AskQuestion(Format(MSG_DESELECT_REFERENCE_FIELD, [FieldName])) then
        begin
          for I := 0 to ForeignFieldCount - 1 do
          begin
            if TmnRelation(ForeignFields[I].Relation).Checked then
            begin
              if TmnField(ForeignFields[I]).NotNull then
                //Если поле нот нул то исключаем всю таблицу
                TmnRelation(ForeignFields[I].Relation).Checked := False
              else
                //в противном случае исключаем только поле
                TmnField(ForeignFields[I]).Checked := False;
            end;
          end;
        end else
          FChecked := True;}
      end;
    end;

    if gvNodeClicked = Relation.RelationName + ' ' + FieldName then begin
      gvAskQuestion:= b;
      gvAskQuestionBack:= b1;
      gvAskQuestionResult:= mrResB;
    end;

    DoChanged;
  end;
end;

procedure TmnField.SetIsPrimeKey(const Value: Boolean);
begin
  if Value <> IsPrimeKey then
  begin
    inherited;
    DoChanged;
  end;
end;


procedure TmnField.SetIsKey(const Value: Boolean);
begin
  if FIsKey <> Value then
  begin
    FIsKey := Value;
    DoChanged;
  end;
end;

procedure TmnField.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TmnField.AddWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList = nil then
  begin
    FWrapList := TList.Create;
  end;

  if FWrapList.IndexOf(W) = - 1 then
    FWrapList.Add(W);
end;

procedure TmnField.RemoveWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList <> nil then
  begin
    FWrapList.Extract(W);
    if FWrapList.Count = 0 then
      FreeAndNil(FWrapList);
  end;
end;

destructor TmnField.Destroy;
var
  I: Integer;
begin
  if FWrapList <> nil then
  begin
    for I := 0 to FWrapList.Count - 1 do
    begin
      TmnFieldWrap(FWrapList[I]).WrappedObject := nil;
    end;
  end;

  FWrapList.Free;

  inherited;
end;

procedure TmnField.SetConformity(const Value: Boolean);
begin
  if Value <> Conformity then
  begin
    inherited;
    DoChanged;
  end;
end;

procedure TmnField.SetIsComputed(const Value: Boolean);
begin
  FIsComputed := Value;
end;

{ TmnCustomRelationWrap }

destructor TmnCustomRelationWrap.Destroy;
begin
  if Assigned(FNode.Data) then
    FNode.Data:= nil;

  inherited;
end;

function TmnCustomRelationWrap.ErrorMessage: string;
begin
  Result := ERR_OK;
end;

function TmnCustomRelationWrap.OverlayIndex: Integer;
begin
  Result := OVR_NONE;
end;

procedure TmnCustomRelationWrap.SetNode(const Value: TCheckTreeNode);
begin
  FNode := Value;
  if FNode <> nil then
    FNode.Data := Self;
end;

{ TmnFieldWrap }

destructor TmnFieldWrap.Destroy;
begin
  if Assigned(FField) then
    FField.RemoveWrap(Self);

  inherited;
end;

function TmnFieldWrap.GetWrappedObject: TObject;
begin
  Result := FField;
end;

function TmnFieldWrap.ImageIndex: Integer;
begin
  Assert(FField <> nil, '');
  if FField.IsKey then
    Result := ICN_KEY
  else
  begin
    if FField.IsPrimeKey then
      Result := ICN_PrimeKey
    else if FField.IsForeign then
      Result := ICN_FKEY
    else
      Result := ICN_DATA;
  end;
end;

procedure TmnFieldWrap.OnNodeClick(Sender: TObject; Node: TTreeNode);
begin
  Assert(FField <> nil, '');
  if gvNodeClicked = '' then
    gvNodeClicked:= FField.Relation.RelationName + ' ' + FField.FieldName;
  FField.Checked := TCheckTreeNode(Node).Checked;
  if gvNodeClicked = FField.Relation.RelationName + ' ' + FField.FieldName then
    gvNodeClicked:= '';
end;

procedure TmnFieldWrap.OnObjectChange(Sender: TObject);
begin
  Assert((FField <> nil) and (FNode <> nil), '');
  if FField.Checked <> FNode.Checked then
    FNode.Checked := FField.Checked;
  FNode.ImageIndex := ImageIndex;
  FNode.SelectedIndex :=  SelectImageIndex;
  FNode.OverlayIndex := OverlayIndex;
end;

function TmnFieldWrap.OverlayIndex: Integer;
begin
  Result := inherited OverlayIndex;
end;

function TmnFieldWrap.SelectImageIndex: Integer;
begin
  Result := ImageIndex
end;

procedure TmnFieldWrap.SetNode(const Value: TCheckTreeNode);
begin
  inherited;
  if FNode <> nil then
    with FNode as TCheckTreeNode do
    begin
      ShowChecked := True;
      if FField <> nil then
        Checked := FField.Checked;
    end;
end;

procedure TmnFieldWrap.SetWrappedObject(const Value: TObject);
begin
  FField := TmnField(Value);
  if FField <> nil then
  begin
    Assert(Value is TmnField, '');
    FField.AddWrap(Self);
    if FNode <> nil then
      (FNode as TCheckTreeNode).Checked := FField.Checked;
  end;
end;

{ TmnRelationWrap }

function TmnRelationWrap.ErrorMessage: string;
begin
  if FRelation <> nil then
    Result := FRelation.ErrorMessage
  else
    Result := inherited ErrorMessage;
end;

function TmnRelationWrap.GetWrappedObject: TObject;
begin
  Result := FRelation;
end;

function TmnRelationWrap.ImageIndex: Integer;
begin
  Result := ICN_RELATION;
end;

procedure TmnRelationWrap.OnNodeClick(Sender: TObject; Node: TTreeNode);
begin
  Assert(FRelation <> nil, '');

  if Node.TreeView.Name = 'tvRelations' then begin
    if gvNodeClicked = '' then
      gvNodeClicked:= FRelation.RelationName;
    FRelation.Checked := TCheckTreeNode(Node).Checked;
    if gvNodeClicked = FRelation.RelationName then
      gvNodeClicked:= '';
  end
  else begin
    FRelation.TriggerAI.Checked:= TCheckTreeNode(Node).Checked;
    FRelation.TriggerAU.Checked:= TCheckTreeNode(Node).Checked;
    FRelation.TriggerAD.Checked:= TCheckTreeNode(Node).Checked;
  end;
end;

procedure TmnRelationWrap.OnObjectChange(Sender: TObject);
begin
  Assert((FRelation <> nil) and (Node <> nil), '');
  if FRelation.Checked <> Node.Checked then
    Node.Checked := FRelation.Checked;
  FNode.ImageIndex := ImageIndex;
  FNode.SelectedIndex :=  SelectImageIndex;
  FNode.OverlayIndex := OverlayIndex;
end;

function TmnRelationWrap.OverlayIndex: Integer;
begin
  Result := OVR_NONE;
  if (FRelation <> nil) and (FRelation.ErrorCode <> ERR_CODE_OK) then
    Result := OVR_ATTENTION;
end;

function TmnRelationWrap.SelectImageIndex: Integer;
begin
  Result := ImageIndex
end;

procedure TmnRelationWrap.SetNode(const Value: TCheckTreeNode);
begin
  inherited;
  if FNode <> nil then
    with FNode as TCheckTreeNode do
    begin
      ShowChecked := True;
      if FRelation <> nil then
        Checked := FRelation.Checked;
    end;
end;

procedure TmnRelationWrap.SetWrappedObject(const Value: TObject);
begin
  Assert(Value is TmnRelation, '');
  FRelation := TmnRelation(Value);
  FRelation.OnChange := OnObjectChange;
  if FNode <> nil then
    (FNode as TCheckTreeNode).Checked := FRelation.Checked;
end;

{ TmnFieldConformityWrap }

destructor TmnFieldConformityWrap.Destroy;
begin
  if FField <> nil then
    FField.RemoveWrap(Self);
  inherited;
end;

function TmnFieldConformityWrap.GetWrappedObject: TObject;
begin
  Result := FField
end;

function TmnFieldConformityWrap.ImageIndex: Integer;
begin
  Result := - 1;
end;

procedure TmnFieldConformityWrap.OnNodeClick(Sender: TObject;
  Node: TTreeNode);
begin
  inherited;
  if FField <> nil then
  begin
    FField.Conformity := TCheckTreeNode(Node).Checked
  end;
end;

procedure TmnFieldConformityWrap.OnObjectChange(Sender: TObject);
begin
  inherited;
  if FNode.Checked <> FField.Conformity then
    FNode.Checked := FField.Conformity;
end;

function TmnFieldConformityWrap.OverlayIndex: Integer;
begin
  Result := - 1;
end;

function TmnFieldConformityWrap.SelectImageIndex: Integer;
begin
  Result := - 1;
end;

procedure TmnFieldConformityWrap.SetNode(const Value: TCheckTreeNode);
begin
  inherited;
  if FNode <> nil then
    with FNode as TCheckTreeNode do
    begin
      ShowChecked := True;
      if FField <> nil then
        Checked := FField.Conformity;
    end;
end;

procedure TmnFieldConformityWrap.SetWrappedObject(const Value: TObject);
begin
  inherited;
  FField := TmnField(Value);
  if FField <> nil then
  begin
    FField.AddWrap(Self);
    if FNode <> nil then
      Node.Checked := FField.Conformity
  end;
end;

{ TmnTrigger }

procedure TmnTrigger.AddWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList = nil then
  begin
    FWrapList := TList.Create;
  end;

  if FWrapList.IndexOf(W) = - 1 then
    FWrapList.Add(W);
end;

procedure TmnTrigger.Edit;
begin
  Application.CreateForm(TfrmEditTrigger, frmEditTrigger);
  try
    frmEditTrigger.edtName.Text:= GetTriggerName;
    frmEditTrigger.edtRelation.Text:= RelationName;
    case Action of
      rpl_Const.taInsert:
        if ActionPosition = tapBefore then
          frmEditTrigger.edtType.Text:= RelationTriggerBI
        else
          frmEditTrigger.edtType.Text:= RelationTriggerAI;
      rpl_Const.taUpdate:
        if ActionPosition = tapBefore then
          frmEditTrigger.edtType.Text:= RelationTriggerBU
        else
          frmEditTrigger.edtType.Text:= RelationTriggerAU;
      rpl_Const.taDelete:
        if ActionPosition = tapBefore then
          frmEditTrigger.edtType.Text:= RelationTriggerBD
        else
          frmEditTrigger.edtType.Text:= RelationTriggerAD;
    end;
    frmEditTrigger.memTriggerBody.Text:= GetBody;
    if frmEditTrigger.ShowModal = mrOK then begin
    end;
  finally
    frmEditTrigger.Free;
  end;
end;

function TmnTrigger.GetDefBody: string;
var
  sBody, sNewKeyLine, sOldKeyLine, sCond: string;
  q: TIBSQL;
  b: boolean;

  function GetKeyLine(KeyType: String): String;
  var
    I: Integer;
    LSep: string;
  begin
    Result:= '';
    LSep:= '||''' + ReplicationManager.KeyDivider + '''||';
    if Relation <> nil then
    begin
      for I:= 0 to Relation.Keys.Count - 1 do
      begin
        if Result > '' then
          Result:= Result + LSep;

        Result:= Result + KeyType + '.' + Relation.Keys[I].FieldName;
      end;
    end else
      raise Exception.Create(InvalidRelationKey);
  end;

  const
    cNew = 'NEW';
    cOLD = 'OLD';
    cNull = 'NULL';
begin
  sNewKeyLine:= GetKeyLine(cNew);
  sOldKeyLine:= GetKeyLine(cOld);
  case Action of
    rpl_Const.taInsert: begin
        sBody:= Format(cTriggerBody, [Relation.RelationKey,
          '''I''', sNewKeyLine, sNewKeyLine]);
      end;
    rpl_Const.taDelete: begin
        sBody:= Format(cTriggerBody, [Relation.RelationKey,
          '''D''', sOldKeyLine, sOldKeyLine]);
      end;
    rpl_Const.taUpdate: begin
        sBody:= Format(cTriggerBody, [Relation.RelationKey,
          '''U''', sOldKeyLine, sNewKeyLine]);
      end;
  end;

  sCond:= '';
  if (Action = taUpdate) and (ActionPosition = tapAfter) then
  begin
    q:= TIBSQL.Create(nil);
    b:= ReplDataBase.Transaction.InTransaction;
    try
      q.Transaction := ReplDataBase.Transaction;
      if not b then
        q.Transaction.StartTransaction;
      q.SQL.Text := 'SELECT rf.RDB$FIELD_NAME FROM rdb$relation_fields rf ' +
        'JOIN rdb$fields f ON rf.rdb$field_source = f.rdb$field_name AND f.rdb$computed_blr IS NULL ' +
        ' AND rf.rdb$relation_name = ''' + UpperCase(RelationName) + ''' ';
      q.ExecQuery;
      while not q.Eof do
      begin
        if sCond <> '' then
          sCond:= sCond + ' OR '#13#10'      ';
        sCond:= sCond +
          '((NEW.' + q.Fields[0].AsTrimString + ' <> OLD.' + q.Fields[0].AsTrimString + ') OR ' +
          '(NEW.' + q.Fields[0].AsTrimString + ' IS NOT NULL AND OLD.' + q.Fields[0].AsTrimString + ' IS NULL) OR ' +
          '(NEW.' + q.Fields[0].AsTrimString + ' IS NULL AND OLD.' + q.Fields[0].AsTrimString + ' IS NOT NULL))';
        q.Next;
      end;
    finally
      if not b then
        ReplDataBase.Transaction.Rollback;
      q.Free;
    end;
  end;
  if sCond <> '' then
    sCond := '  IF (' + sCond + ') THEN ';
  sBody:= 'AS'#13#10'BEGIN'#13#10 + sCond + #13#10 + sBody + #13#10'END';
  Result:= sBody;
end;

function TmnTrigger.GetBody: string;
begin
  if Trim(FBody) = '' then
    Result:= GetDefBody
  else
    Result:= FBody;
end;

function TmnTrigger.GetTriggerName: string;
begin
  Result:= 'RPL$';
  case ActionPosition of
    tapBefore: Result:= Result + 'B';
    tapAfter: Result:= Result + 'A';
  end;
  case Action of
    rpl_Const.taInsert: Result:= Result + 'I';
    rpl_Const.taUpdate: Result:= Result + 'U';
    rpl_Const.taDelete: Result:= Result + 'D';
  end;
  Result:= Result + '_' + RelationName;
  Result := Copy(Result, 1, 31);
end;

procedure TmnTrigger.RemoveWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList <> nil then
  begin
    FWrapList.Extract(W);
    if FWrapList.Count = 0 then
      FreeAndNil(FWrapList);
  end;
end;

procedure TmnTrigger.SetChecked(const Value: Boolean);
begin
  FChecked := Value;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TmnTrigger.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

function TmnTrigger.CreateDll: string;
var
  sAP, sA: string;
begin
  case Action of
    rpl_Const.taInsert: sA:= 'INSERT';
    rpl_Const.taUpdate: sA:= 'UPDATE';
    rpl_Const.taDelete: sA:= 'DELETE';
  end;

  case ActionPosition of
    tapBefore: sAP:= 'BEFORE';
    tapAfter: sAP:= 'AFTER';
  end;
  Result:= Format('CREATE TRIGGER %s FOR %s '#13#10'%s %s %s POSITION %d'#13#10 + GetBody,
          [TriggerName, RelationName, 'ACTIVE', sAP, sA, Trigger.Position]);
end;

function TmnTrigger.AlterDll: string;
var
  sAP, sA: string;
begin
  case Action of
    rpl_Const.taInsert: sA:= 'INSERT';
    rpl_Const.taUpdate: sA:= 'UPDATE';
    rpl_Const.taDelete: sA:= 'DELETE';
  end;

  case ActionPosition of
    tapBefore: sAP:= 'BEFORE';
    tapAfter: sAP:= 'AFTER';
  end;
  Result:= Format('ALTER TRIGGER %s FOR %s '#13#10'%s %s %s POSITION %d'#13#10 + GetBody,
          [TriggerName, RelationName, 'ACTIVE', sAP, sA, Trigger.Position]);
end;

function TmnTrigger.GetCaption: string;
begin
  case Action of
    rpl_Const.taInsert:
        case ActionPosition of
          tapBefore: Result:= RelationTriggerBI;
          tapAfter: Result:= RelationTriggerAI;
        end;
    rpl_Const.taUpdate:
        case ActionPosition of
          tapBefore: Result:= RelationTriggerBU;
          tapAfter: Result:= RelationTriggerAU;
        end;
    rpl_Const.taDelete:
        case ActionPosition of
          tapBefore: Result:= RelationTriggerBD;
          tapAfter: Result:= RelationTriggerAD;
        end;
  end;
end;

function TmnTrigger.GetIsCustom: boolean;
begin
  Result:= GetBody <> GetDefBody;
end;

procedure TmnTrigger.DoChanged;
var
  I: Integer;
  W: TmnCustomRelationWrap;
begin
  if Assigned(OnChange) then
    OnChange(Self);

  if FWrapList <> nil then
  begin
    for I := 0 to FWrapList.Count - 1 do
    begin
      W := TmnCustomRelationWrap(FWrapList[I]);
      W.OnObjectChange(Self);
    end;
  end;
end;

{ TmnTriggerWrap }

destructor TmnTriggerWrap.Destroy;
begin
  if Assigned(FTrigger) then
    FTrigger.RemoveWrap(Self);

  inherited;
end;

function TmnTriggerWrap.GetWrappedObject: TObject;
begin
  Result := FTrigger;
end;

function TmnTriggerWrap.ImageIndex: Integer;
begin
  Assert(FTrigger <> nil, '');
  if FTrigger.IsCustom then
    Result := ICN_TRIGGER_CUSTOM
  else
    Result := ICN_TRIGGER
end;

procedure TmnTriggerWrap.OnNodeClick(Sender: TObject; Node: TTreeNode);
begin
  Assert(FTrigger <> nil, '');
  FTrigger.Checked := TCheckTreeNode(Node).Checked;
end;

procedure TmnTriggerWrap.OnObjectChange(Sender: TObject);
begin
  Assert((FTrigger <> nil) and (FNode <> nil), '');
  if FTrigger.Checked <> FNode.Checked then
    FNode.Checked:= FTrigger.Checked;
  FNode.ImageIndex := ImageIndex;
  FNode.SelectedIndex :=  SelectImageIndex;
  FNode.OverlayIndex := OverlayIndex;
end;

function TmnTriggerWrap.OverlayIndex: Integer;
begin
  Result := inherited OverlayIndex;
end;

function TmnTriggerWrap.SelectImageIndex: Integer;
begin
  Result := ImageIndex
end;

procedure TmnTriggerWrap.SetNode(const Value: TCheckTreeNode);
begin
  inherited;
  if FNode <> nil then
    with FNode as TCheckTreeNode do
    begin
      ShowChecked := True;
      if FTrigger <> nil then
        Checked := FTrigger.Checked;
    end;
end;

procedure TmnTriggerWrap.SetWrappedObject(const Value: TObject);
begin
  Assert(Value is TmnTrigger, '');
  FTrigger:= TmnTrigger(Value);
  if FTrigger <> nil then begin
    FTrigger.AddWrap(Self);
    if FNode <> nil then
      (FNode as TCheckTreeNode).Checked:= FTrigger.Checked;
  end;
end;

{ TmnGenerator }

procedure TmnGenerator.AddWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList = nil then
  begin
    FWrapList := TList.Create;
  end;

  if FWrapList.IndexOf(W) = - 1 then
    FWrapList.Add(W);
end;

procedure TmnGenerator.DoChanged;
var
  I: Integer;
  W: TmnCustomRelationWrap;
begin
  if FWrapList <> nil then
  begin
    for I := 0 to FWrapList.Count - 1 do
    begin
      W := TmnCustomRelationWrap(FWrapList[I]);
      W.OnObjectChange(Self);
    end;
  end;
end;

procedure TmnGenerator.RemoveWrap(W: TmnCustomRelationWrap);
begin
  if FWrapList <> nil then
  begin
    FWrapList.Extract(W);
    if FWrapList.Count = 0 then
      FreeAndNil(FWrapList);
  end;
end;

procedure TmnGenerator.SetRelation(const Value: TmnRelation);
begin
  FRelation := Value;
end;

{ TmnGeneratorWrap }

destructor TmnGeneratorWrap.Destroy;
begin
  if Assigned(FGenerator) then
    FGenerator.RemoveWrap(Self);

  inherited;
end;

function TmnGeneratorWrap.GetWrappedObject: TObject;
begin
  Result := FGenerator;
end;

function TmnGeneratorWrap.ImageIndex: Integer;
begin
  Result:= ICN_GENERATOR;
end;

procedure TmnGeneratorWrap.OnGeneratorChange(Sender: TObject);
begin
  FGenerator.Relation.GeneratorName:= FGenList.Text;
  FNode.Text:= RelationGenerator + FGenList.Text;
  FGenerator.Relation.FErrorCode:= ERR_CODE_NOT_INIT;
end;

procedure TmnGeneratorWrap.OnNodeClick(Sender: TObject; Node: TTreeNode);
begin
  ;
end;

procedure TmnGeneratorWrap.OnObjectChange(Sender: TObject);
begin
  FNode.Text:= RelationGenerator + FGenerator.FRelation.GeneratorName;
  FGenList.ItemIndex:= FGenList.Items.IndexOf(FGenerator.FRelation.GeneratorName);
end;

function TmnGeneratorWrap.OverlayIndex: Integer;
begin
  Result := inherited OverlayIndex;
end;

function TmnGeneratorWrap.SelectImageIndex: Integer;
begin
  Result:= ImageIndex;
end;

procedure TmnGeneratorWrap.SetNode(const Value: TCheckTreeNode);
begin
  inherited;
end;

procedure TmnGeneratorWrap.SetSelected(Value: boolean);
begin
  if FNode.Text = RelationGeneratorCant then Exit;
  Assert(Assigned(FGenList));
  FGenList.Visible:= Value;
  if Value then begin
    FGenList.Left:= FNode.TreeView.Canvas.TextWidth(RelationGenerator) + 1 +
       FNode.DisplayRect(True).Left + FNode.TreeView.Left;
    FGenList.Top:= FNode.DisplayRect(True).Top + FNode.TreeView.Top;
      FGenList.ItemIndex:= FGenList.Items.IndexOf(FGenerator.Relation.GeneratorName);
    FGenList.OnChange:= OnGeneratorChange;
  end
  else
    FGenList.OnChange:= nil;
end;

procedure TmnGeneratorWrap.SetWrappedObject(const Value: TObject);
begin
  FGenerator:= TmnGenerator(Value);
  if FGenerator <> nil then
  begin
    Assert(Value is TmnGenerator, '');
    FGenerator.AddWrap(Self);
  end;
end;

initialization
finalization
  FreeAndNil(_Keys);
end.
