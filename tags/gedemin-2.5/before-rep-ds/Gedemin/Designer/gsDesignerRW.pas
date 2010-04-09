
unit gsDesignerRW;

interface

uses
  Classes, SysUtils, gsResizer, Controls, typinfo, Forms;
const
  FilerSignature: array[1..4] of Char = 'TPF0';
type

  TDesignReader = class(TReader)
  private
    FDesigner: TgsResizeManager;
    FResolving: TStringList;
    FAttributes: Boolean;
    procedure BufOnSetName(Reader: TReader; Component: TComponent; var Name: string);
    procedure BufOnReferenceName(Reader: TReader; var Name: string);
    procedure BufOnFindMethod(Reader: TReader; const MethodName: string; var Address: Pointer; var Error: Boolean);

  public
    procedure ProcessComponents(AnOwner: TComponent; const ASubType: string = '');

//    procedure ReadProperty(AInstance: TPersistent); reintroduce;
    property Designer: TgsResizeManager read FDesigner write FDesigner;
    property Attributes: boolean read FAttributes write FAttributes;
    procedure ReadBufComponents(AOwner, AParent: TComponent; ACreatedList: TList);


  end;

  TgsPersistentCracker = class(TPersistent);

  TgsComponentCracker = class(TComponent);
  TgsWinControlCracker = class(TWinControl);

  TDesignWriter = Class;

  TgsWriter = class(TWriter)
  protected
    DesignWriter: TDesignWriter;
  public
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, WriteData: TStreamProc;
      HasData: Boolean); override;
  end;

  TDesignFiler = class(TFiler)
  private
    FWriter: TgsWriter;
  protected
  public
    constructor Create(Stream: TStream; BufSize: Integer); virtual;
    destructor Destroy; override;
  end;

  TDesignWriter = class(TDesignFiler)
  private
    FPropPath: string;
    FDesigner: TgsResizeManager;
    FRootAncestor: TComponent;
    FAncestorList: TList;
    FAncestorPos: Integer;
    FChildPos: Integer;
    FCurrentObject: TObject;
    FWriteAll: Boolean;
    procedure AddAncestor(Component: TComponent);
    procedure WriteData(Instance: TComponent); virtual; // linker optimization
    function NeedStore(AnOwner:TObject; const APropName: String; PropInfo: PPropInfo): Boolean;

  protected
    procedure SetRoot(Value: TComponent); override;
    procedure WriteProperties(Instance: TPersistent);
    procedure WriteProperty(Instance: TPersistent; PropInfo: Pointer);

  public
    constructor Create(Stream: TStream; BufSize: Integer); override;
    destructor Destroy; override;
    procedure DefineProperty(const Name: string;
      ReadData: TReaderProc; WriteData: TWriterProc;
      HasData: Boolean); override;
    procedure DefineBinaryProperty(const Name: string;
      ReadData, WriteData: TStreamProc;
      HasData: Boolean); override;

    procedure FlushBuffer; override;
    procedure WriteComponent(Component: TComponent);
    procedure WriteDescendent(Root: TComponent; AAncestor: TComponent);
    property Designer: TgsResizeManager read FDesigner write FDesigner;
  end;
  procedure ClipboardTextToBinary(Input, Output: TStream);

implementation
uses consts, contnrs,  comctrls, ActnList, gd_createable_form,
     gdc_createable_form, gsResizerInterface, at_Container, TB2Item, TB2Toolbar, Menus, evt_Base, evt_i_Base;

{ TDesignWriter }

destructor TDesignWriter.Destroy;
begin
  FWriter.FlushBuffer;
  inherited Destroy;
end;

procedure TDesignWriter.AddAncestor(Component: TComponent);
begin
  FAncestorList.Add(Component);
end;

procedure TDesignWriter.WriteProperty(Instance: TPersistent; PropInfo: Pointer);
var
  PropType: PTypeInfo;

  function AncestorValid: Boolean;
  begin
    Result := (Ancestor <> nil) and ((Instance.ClassType = Ancestor.ClassType) or
      (Instance = Root));
  end;

  procedure WritePropPath;
  begin
    FWriter.WritePropName(FPropPath + PPropInfo(PropInfo)^.Name);
  end;

  procedure WriteSet(Value: Longint);
  var
    I: Integer;
    BaseType: PTypeInfo;
  begin
    BaseType := GetTypeData(PropType)^.CompType^;
    FWriter.WriteValue(vaSet);
    for I := 0 to SizeOf(TIntegerSet) * 8 - 1 do
      if I in TIntegerSet(Value) then FWriter.WriteStr(GetEnumName(BaseType, I));
    FWriter.WriteStr('');
  end;

  procedure WriteIntProp(IntType: PTypeInfo; Value: Longint);
  var
    Ident: string;
    IntToIdent: TIntToIdent;
  begin
    IntToIdent := FindIntToIdent(IntType);
    if Assigned(IntToIdent) and IntToIdent(Value, Ident) then
      FWriter.WriteIdent(Ident)
    else
      FWriter.WriteInteger(Value);
  end;

  procedure WriteCollectionProp(Collection: TCollection);
  var
    SavePropPath: string;
  begin
    WritePropPath;
    SavePropPath := FPropPath;
    try
      FPropPath := '';
      FWriter.WriteCollection(Collection);
    finally
      FPropPath := SavePropPath;
    end;
  end;

  procedure WriteOrdProp;
  var
    Value: Longint;
  begin
    Value := GetOrdProp(Instance, PropInfo);
{    if Value = PPropInfo(PropInfo)^.Default then
      Exit;}
    WritePropPath;
      case PropType^.Kind of
        tkInteger:
          WriteIntProp(PPropInfo(PropInfo)^.PropType^, Value);
        tkChar:
          FWriter.WriteChar(Chr(Value));
        tkSet:
          WriteSet(Value);
        tkEnumeration:
          FWriter.WriteIdent(GetEnumName(PropType, Value));
      end;
  end;

  procedure WriteFloatProp;
  var
    Value: Extended;

  begin
    Value := GetFloatProp(Instance, PropInfo);
    WritePropPath;
    FWriter.WriteFloat(Value);
  end;

  procedure WriteInt64Prop;
  var
    Value: Int64;
  begin
    Value := GetInt64Prop(Instance, PropInfo);
{    if Value = PPropInfo(PropInfo)^.Default then
      Exit;}
    WritePropPath;
    FWriter.WriteInteger(Value);
  end;

  procedure WriteStrProp;
  var
    Value: string;
  begin
    Value := GetStrProp(Instance, PropInfo);
    WritePropPath;
    FWriter.WriteString(Value);
  end;

  procedure WriteObjectProp;
  var
    Value: TObject;
    OldAncestor: TPersistent;
    SavePropPath, ComponentValue: string;

    function GetComponentValue(Component: TComponent): string;
    begin
      if Component.Owner = FWriter.LookupRoot then
        Result := Component.Name
      else if Component = FWriter.LookupRoot then
        Result := 'Owner'                                                       { Do not translate }
      else if (Component.Owner <> nil) and (Component.Owner.Name <> '') and
        (Component.Name <> '') then
        Result := Component.Owner.Name + '.' + Component.Name
      else if Component.Name <> '' then
        Result := Component.Name + '.Owner'                                     { Do not translate }
      else Result := '';
    end;

  begin
    Value := TObject(GetOrdProp(Instance, PropInfo));
    if (Value = nil) then
    begin
      WritePropPath;
      FWriter.WriteValue(vaNil);
    end
    else if Value is TPersistent then
      if Value is TComponent then
      begin
        ComponentValue := GetComponentValue(TComponent(Value));
        if ComponentValue <> '' then
        begin
          WritePropPath;
          FWriter.WriteIdent(ComponentValue);
        end
      end else if Value is TCollection then
      begin
        if not AncestorValid or
          not CollectionsEqual(TCollection(Value),
            TCollection(GetOrdProp(Ancestor, PropInfo))) then
            try
              FWriteAll := True;
              WriteCollectionProp(TCollection(Value));
              FWriteAll := False;
            finally
            end
      end else
      begin
        OldAncestor := Ancestor;
        SavePropPath := FPropPath;
        try
          FPropPath := FPropPath + PPropInfo(PropInfo)^.Name + '.';
          if AncestorValid then
            Ancestor := TPersistent(GetOrdProp(Ancestor, PropInfo));
          WriteProperties(TPersistent(Value));
        finally
          Ancestor := OldAncestor;
          FPropPath := SavePropPath;
        end;
      end
  end;

  procedure WriteMethodProp;
  var
    Value: TMethod;

    function IsDefaultValue: Boolean;
    var
      DefaultCode: Pointer;
      EvtObj: TEventObject;
      EvtCtrl: TEventControl;
      EvtItem: TEventItem;

      function FindEvtObj(AComp: TComponent): TEventObject;
      begin
        Result:= nil;
        if not Assigned(AComp) then Exit;
        if AComp is TCustomForm then begin
          Result:= EvtCtrl.EventObjectList.FindObject(AComp.Name);
          Exit;
        end
        else
          Result:= FindEvtObj(AComp.Owner);
        if not Assigned(Result) then Exit;
        Result:= Result.ChildObjects.FindObject(AComp.Name);
      end;

    begin
      DefaultCode := nil;
      if AncestorValid then
        DefaultCode := GetMethodProp(Ancestor, PropInfo).Code;
      Result := (Value.Code = DefaultCode) or
        ((Value.Code <> nil) and (FWriter.LookupRoot.MethodName(Value.Code) = ''));
      EvtCtrl:= EventControl.Get_Self as TEventControl;
      if Instance is TComponent then
        EvtObj:= FindEvtObj(TComponent(Instance))
      else
        EvtObj := nil;
      if Assigned(EvtObj) then begin
        EvtItem:= EvtObj.EventList.Find(PPropInfo(PropInfo)^.Name);
        if Assigned(EvtItem) then begin
          Result:= (Result and (EvtItem.OldEvent.Code = DefaultCode)) or
            ((EvtItem.OldEvent.Code <> nil) and (FWriter.LookupRoot.MethodName(EvtItem.OldEvent.Code) = ''));
          if not Result and (EvtItem.OldEvent.Code <> nil) then
            Value:= EvtItem.OldEvent;
        end;
      end;
    end;
  begin
    Value := GetMethodProp(Instance, PropInfo);
    if not IsDefaultValue then
    begin
      WritePropPath;
      if Value.Code = nil then
        FWriter.WriteValue(vaNil)
      else
        FWriter.WriteIdent(FWriter.LookupRoot.MethodName(Value.Code));
    end;
  end;

  procedure WriteVariantProp;
  var
    Value: Variant;
    VType: Integer;
  begin
    Value := GetVariantProp(Instance, PropInfo);
    if VarIsArray(Value) then raise EWriteError.CreateRes(@SWriteError);
    WritePropPath;
    VType := VarType(Value);
    case VType and varTypeMask of
      varEmpty: FWriter.WriteValue(vaNil);
      varNull: FWriter.WriteValue(vaNull);
      varOleStr: FWriter.WriteWideString(Value);
      varString: FWriter.WriteString(Value);
      varByte, varSmallInt, varInteger: FWriter.WriteInteger(Value);
      varSingle: FWriter.WriteSingle(Value);
      varDouble: FWriter.WriteFloat(Value);
      varCurrency: FWriter.WriteCurrency(Value);
      varDate: FWriter.WriteDate(Value);
      varBoolean:
        if Value then
          FWriter.WriteValue(vaTrue) else
          FWriter.WriteValue(vaFalse);
    else
      try
        FWriter.WriteString(Value);
      except
        raise EWriteError.CreateRes(@SWriteError);
      end;
    end;
  end;

begin
  if (PPropInfo(PropInfo)^.SetProc <> nil) and
    (PPropInfo(PropInfo)^.GetProc <> nil) then
  begin
    PropType := PPropInfo(PropInfo)^.PropType^;
    case PropType^.Kind of
      tkInteger, tkChar, tkEnumeration, tkSet: WriteOrdProp;
      tkFloat: WriteFloatProp;
      tkString, tkLString, tkWString: WriteStrProp;
      tkClass: WriteObjectProp;
      tkMethod:
        if (cfsUserCreated in TCreateableForm(FDesigner.EditForm).CreateableFormState) and
          not (((Instance is TComponent) and
            ((Pos(USERCOMPONENT_PREFIX, TComponent(Instance).Name) = 1) or
            ((Pos(GLOBALUSERCOMPONENT_PREFIX, TComponent(Instance).Name) = 1))))) then
          WriteMethodProp;
      tkVariant: WriteVariantProp;
      tkInt64: WriteInt64Prop;
    end;
  end;
end;

procedure TgsWriter.DefineProperty(const Name: string;
  ReadData: TReaderProc; WriteData: TWriterProc; HasData: Boolean);
begin
  if HasData and Assigned(WriteData) {and DesignWriter.NeedStore(DesignWriter.FCurrentObject, DesignWriter.FPropPath + Name, nil)} then
  begin
    Self.WritePropName(DesignWriter.FPropPath + Name);
    WriteData(Self);
  end;
end;

procedure TgsWriter.DefineBinaryProperty(const Name: string;
  ReadData, WriteData: TStreamProc; HasData: Boolean);
begin
  if HasData and Assigned(WriteData) and DesignWriter.NeedStore(DesignWriter.FCurrentObject, DesignWriter.FPropPath + Name, nil) then
  begin
    Self.WritePropName(DesignWriter.FPropPath + Name);
    Self.WriteBinary(WriteData);
  end;
end;

procedure TDesignWriter.FlushBuffer;
begin
  FWriter.FlushBuffer;
end;

procedure TDesignWriter.SetRoot(Value: TComponent);
begin
  FWriter.Root := Value;
end;

procedure TDesignWriter.WriteComponent(Component: TComponent);

  function FindAncestor(const Name: string): TComponent;
  var
    I: Integer;
  begin
    for I := 0 to FAncestorList.Count - 1 do
    begin
      Result := FAncestorList[I];
      if SameText(Result.Name, Name) then Exit;
    end;
    Result := nil;
  end;

var
  OldAncestor: TPersistent;
  OldRootAncestor: TComponent;
begin
  if Component.InheritsFrom(TCreateableForm) and (Component <> FWriter.Root) then
    exit;

  FCurrentObject := Component;
  OldAncestor := Ancestor;
  OldRootAncestor := FRootAncestor;
  try
    if Assigned(FAncestorList) then
      Ancestor := FindAncestor(Component.Name);
    WriteData(Component);
  finally
    Ancestor := OldAncestor;
    FRootAncestor := OldRootAncestor;
  end;
end;

procedure TDesignWriter.WriteData(Instance: TComponent);
var
  PreviousPosition, PropertiesPosition: Longint;
  OldAncestorList: TList;
  OldAncestorPos, OldChildPos: Integer;
  OldRoot, OldRootAncestor: TComponent;
  Flags: TFilerFlags;
begin
  if (Instance.Name = '') or (Pos(MACROSCOMPONENT_PREFIX, AnsiLowerCase(Instance.Name)) = 1) then
    Exit;

  FWriter.FlushBuffer;
     { Prefix + vaInt + integer + 2 end lists }
  PreviousPosition := FWriter.Position;
  Flags := [];
  if csInline in Instance.ComponentState then
    if (Ancestor <> nil) and (csAncestor in Instance.ComponentState) and (FAncestorList <> nil) then
      // If the AncestorList is not nil, this really came from an ancestor form
      Include(Flags, ffInherited)
    else
      // otherwise the Ancestor is the original frame
      Include(Flags, ffInline)
  else if Ancestor <> nil then
    Include(Flags, ffInherited);
  if (FAncestorList <> nil) and (FAncestorPos < FAncestorList.Count) and
    ((Ancestor = nil) or (FAncestorList[FAncestorPos] <> Ancestor)) then
    Include(Flags, ffChildPos);
  FWriter.WritePrefix(Flags, FChildPos);
  FWriter.WriteStr(Instance.ClassName);
  if Instance is TCreateableForm then
    FWriter.WriteStr(TCreateableForm(Instance).InitialName)
  else
    FWriter.WriteStr(Instance.Name);
  PropertiesPosition := FWriter.Position;
  if (FAncestorList <> nil) and (FAncestorPos < FAncestorList.Count) then
  begin
    if Ancestor <> nil then Inc(FAncestorPos);
    Inc(FChildPos);
  end;
  WriteProperties(Instance);
  FWriter.WriteListEnd;
  OldAncestorList := FAncestorList;
  OldAncestorPos := FAncestorPos;
  OldChildPos := FChildPos;
  OldRoot := FWriter.Root;
  OldRootAncestor := FRootAncestor;
  try
    FAncestorList := nil;
    FAncestorPos := 0;
    FChildPos := 0;
    if not IgnoreChildren then
      try
        if Ancestor is TComponent then
        begin
          if (Ancestor is TComponent) and (csInline in TComponent(Ancestor).ComponentState) then
            FRootAncestor := TComponent(Ancestor);
          FAncestorList := TList.Create;
          TgsComponentCracker(Ancestor).GetChildren(AddAncestor, FRootAncestor);
        end;
        if csInline in Instance.ComponentState then
          FWriter.Root := Instance;
        TgsComponentCracker(Instance).GetChildren(WriteComponent, FWriter.Root);
      finally
        FAncestorList.Free;
      end;
  finally
    FAncestorList := OldAncestorList;
    FAncestorPos := OldAncestorPos;
    FChildPos := OldChildPos;
    Root := OldRoot;
    FRootAncestor := OldRootAncestor;
  end;
  FWriter.WriteListEnd;
  if (Instance <> Root) and (Flags = [ffInherited]) and
    (FWriter.Position = PropertiesPosition + (1 + 1)) then { (1 + 1) is two end lists }
    FWriter.Position := PreviousPosition;
end;

procedure TDesignWriter.WriteDescendent(Root: TComponent; AAncestor: TComponent);
begin
  FWriter.Root := Root;
  FWriter.WriteSignature;

  WriteComponent(Root);
end;

procedure TDesignWriter.WriteProperties(Instance: TPersistent);
var
  I, Count: Integer;
  PropInfo: PPropInfo;
  PropList: PPropList;
begin
  Count := GetTypeData(Instance.ClassInfo)^.PropCount;
  if Count > 0 then
  begin
    GetMem(PropList, Count * SizeOf(Pointer));
    try
      GetPropInfos(Instance.ClassInfo, PropList);
      for I := 0 to Count - 1 do
      begin
        PropInfo := PropList^[I];
        if PropInfo = nil then break;
        if ((PropInfo^.PropType^.Kind <> tkMethod) or (cfsUserCreated in TCreateableForm(FDesigner.EditForm).CreateableFormState))
           and (IsStoredProp(Instance, PropInfo) or (PropInfo^.PropType^.Kind = tkSet)) and NeedStore(Instance, FPropPath + PropInfo^.Name, PropInfo) then
          WriteProperty(Instance, PropInfo);
      end;
    finally
      FreeMem(PropList, Count * SizeOf(Pointer));
    end;
  end;
//  FCurrentObject := Instance;
  TgsPersistentCracker(Instance).DefineProperties(FWriter);
end;


function TDesignWriter.NeedStore(AnOwner:TObject; const APropName: String; PropInfo: PPropInfo): Boolean;
var
  V: TObject;
begin
  Result := False;

  if FWriteAll or (cfsUserCreated in TgdcCreateableForm(FDesigner.EditForm).CreateableFormState) or
     ((AnOwner is TComponent) and
     ((Pos(USERCOMPONENT_PREFIX, TComponent(AnOwner).Name) = 1) or
      ((FDesigner.DesignerType = dtGlobal) and (Pos(GLOBALUSERCOMPONENT_PREFIX, TComponent(AnOwner).Name) = 1)))) then
  begin
    Result := True;
    Exit;
  end;

  if (PropInfo <> nil) and (PropInfo^.PropType^.Kind = tkClass) then
  begin
     V := TObject(GetOrdProp(AnOwner, PropInfo));
     if (V <> nil) and (V is TPersistent) and (not (V.InheritsFrom(TComponent))) then
     begin
       Result := True;
       Exit;
     end;
  end;

  if FDesigner.ChangedPropList.IndexByName(FCurrentObject, APropName) > -1 then
  begin
    Result := True;
    Exit;
  end;
end;

constructor TDesignWriter.Create(Stream: TStream; BufSize: Integer);
begin
  inherited;
  FWriter.DesignWriter := Self;
end;

procedure TDesignWriter.DefineBinaryProperty(const Name: string; ReadData,
  WriteData: TStreamProc; HasData: Boolean);
begin
  FWriter.DefineBinaryProperty(Name, ReadData, WriteData, HasData);
end;

procedure TDesignWriter.DefineProperty(const Name: string;
  ReadData: TReaderProc; WriteData: TWriterProc; HasData: Boolean);
begin
  FWriter.DefineProperty(Name, ReadData, WriteData, HasData);
end;

{ TgsComponentCracker }


{ TgsPersistentCracker }


{ TDesignFiler }

constructor TDesignFiler.Create(Stream: TStream; BufSize: Integer);
begin
  FWriter := TgsWriter.Create(Stream, BufSize);
end;


destructor TDesignFiler.Destroy;
begin
  FWriter.Free;
end;

{ TDesignReader }

procedure TDesignReader.BufOnFindMethod(Reader: TReader;
  const MethodName: string; var Address: Pointer; var Error: Boolean);
begin
  Error := False;
  Address := nil;
end;

procedure TDesignReader.BufOnReferenceName(Reader: TReader;
  var Name: string);
begin
  if FResolving.IndexOfName(Name) > -1 then
    Name := FResolving.Values[Name];
end;

procedure TDesignReader.BufOnSetName(Reader: TReader;
  Component: TComponent; var Name: string);
var
  OldName: String;
begin
  OldName := Name;
  Name := FDesigner.GetNewControlName(Component.ClassName);
  FResolving.Add(OldName + '=' + Name);
end;

procedure TDesignReader.ProcessComponents(AnOwner: TComponent; const ASubType: string);
var
  CompClass: String;
  CompName: String;
  Flags: TFilerFlags;
  C: TComponent;
  ParentList: TComponentList;
  PageControls: TComponentList;
  ObjClass: TPersistentClass;
  PageArray: TStringList;
  I: Integer;
  CurrPos: Integer;
  PropPath: String;
  Skip: Boolean;
  FClientHeight: Integer;
  FClientWidth: Integer;
  FFormState: TComponentState;

  procedure SetLoading(AComponent: TComponent; const AState: boolean);
  var
    CS: TComponentState;
  begin
    if AComponent = AnOwner then
    begin
      if AState then
        FFormState := AComponent.ComponentState
      else
      begin
        Move(FFormState, PChar(AComponent)[SizeOf(LongInt) * 8], SizeOf(FFormState));
        Exit;
      end;
    end;
    Move(PChar(AComponent)[SizeOf(LongInt) * 8], CS, SizeOf(CS));
    if AState then
    begin
      Include(CS, csLoading);
      Include(CS, csReading);
    end
    else
    begin
      if ((Pos(USERCOMPONENT_PREFIX, AComponent.Name) = 1)
        or (((FDesigner.DesignerType = dtGlobal) or FDesigner.GlobalLoading)
         and (Pos(GLOBALUSERCOMPONENT_PREFIX, AComponent.Name) = 1))) then
        TgsComponentCracker(AComponent).Loaded;
         
      Exclude(CS, csLoading);
      Exclude(CS, csReading);
    end;
    Move(CS, PChar(AComponent)[SizeOf(LongInt) * 8], SizeOf(CS));
  end;

begin
  ParentList := TComponentList.Create(False);
  PageArray := TStringList.Create;
  PageControls := TComponentList.Create(False);
  FClientHeight := 0;
  FClientWidth := 0;
  Skip := False;
  try
    Root := AnOwner;
    BeginReferences;
    try
      ReadSignature;
      while not EndOfList do
      begin
        ReadPrefix(Flags, CurrPos);
        CompClass := ReadStr;
        CompName := ReadStr;
        if CompName <> '' then
        begin
          if (CompClass = AnOwner.ClassName) and (AnOwner is TCreateableForm) and
              ((UpperCase(TCreateableForm(AnOwner).InitialName) = UpperCase(CompName)) or
               (UpperCase(TCreateableForm(AnOwner).InitialName) = UpperCase(CompName + ASubType))) then
            C := AnOwner
          else
            C := GlobalFindComponent(CompName, AnOwner);
        end
        else
          C := nil;

        if (C <> nil)then
        begin
          if C is TgsResizeManager then
            C := nil
          else
          begin
            if (C is TControl) then
            begin
              if ParentList.Count > 0 then
              begin
                if (C is TControl) and (ParentList[ParentList.Count - 1] is TWinControl)
                  and (not (C is TTabSheet)) then
                  TControl(C).Parent := TWinControl(ParentList[ParentList.Count - 1]);
              end;
            end
            else
            begin
              if C.InheritsFrom(TContainedAction) and (ParentList[ParentList.Count - 1] is TCustomActionList)then
                TContainedAction(C).ActionList :=  TCustomActionList(ParentList[ParentList.Count - 1]);
            end;
          end;
        end else
        begin
          try
            if CompName <> '' then
            begin

              ObjClass := GetClass(CompClass);
              if Assigned(ObjClass) and
                ((Pos(USERCOMPONENT_PREFIX, CompName) = 1)
                 or (((FDesigner.DesignerType = dtGlobal) or FDesigner.GlobalLoading)
                    and
                    (Pos(GLOBALUSERCOMPONENT_PREFIX, CompName) = 1))) then
              begin
                TComponent(C) := CComponent(ObjClass).Create(AnOwner);
                TComponent(C).Name := CompName;
                if ObjClass = TTabSheet then
                begin
                  if ParentList[ParentList.Count - 1] is TPageControl then
                  begin
                    //TTabSheet(C).PageControl := (ParentList[ParentList.Count - 1] as TPageControl);
                  end else
                  begin
                    C.Free;
                    C := nil;
                  end
                end
                else if C is TControl then
                  TControl(C).Parent := (ParentList[ParentList.Count - 1] as TWinControl)
                else if C.InheritsFrom(TContainedAction) and (ParentList[ParentList.Count - 1] is TCustomActionList)then
                  TContainedAction(C).ActionList :=  TCustomActionList(ParentList[ParentList.Count - 1])
                else if C is TTBCustomItem then
                begin
                  if ParentList[ParentList.Count - 1] is TTBCustomItem then
                    TTBCustomItem(ParentList[ParentList.Count - 1]).Add(TTBCustomItem(C))
                  else if ParentList[ParentList.Count - 1] is TTBCustomToolbar then
                    TTBCustomToolbar(ParentList[ParentList.Count - 1]).Items.Add(TTBCustomItem(C));
                end
                else if C is TMenuItem then
                begin
                  if ParentList[ParentList.Count - 1] is TMenuItem then
                    TMenuItem(ParentList[ParentList.Count - 1]).Add(TMenuItem(C))
                  else if ParentList[ParentList.Count - 1] is TMenu then
                    TMenu(ParentList[ParentList.Count - 1]).Items.Add(TMenuItem(C));
                end;

              end else
                C := nil;
            end;
          except
            C := nil;
          end;
        end;

        if (C = nil) and (CompClass = 'TatPanel') then
        begin
          C := ParentList[ParentList.Count - 1];
        end;

        if C <> nil then
        begin
          if C is TPageControl then
          begin
            PageArray.Add('0');
            PageControls.Add(C);
          end;
          ParentList.Add(C);

          SetLoading(C, True);

          if C is TatContainer then
            Skip := True;

          if not EndOfList then
          begin
            try
              if C is TControl then
                TControl(C).ControlState := TControl(C).ControlState + [csReadingState];
              if ((FAttributes and (not Skip)) or (CompClass = 'TatPanel')) and (not (Pos(ATCOMPONENT_PREFIX, CompName) = 1)) then
              begin
                while not EndOfList do
                  try
                    SkipProperty;
                  except
                  end;
              end
              else
              begin
                while not EndOfList do
                begin
                  CurrPos := Position;
                  PropPath := ReadStr;
                  if (Pos(USERCOMPONENT_PREFIX, CompName) <> 1) and (Pos(GLOBALUSERCOMPONENT_PREFIX, CompName) <> 1) then
                  begin
                    if (PropPath = 'ImageIndex') or (PropPath = 'Images') then
                    begin
                      Position := CurrPos;
                      SkipProperty;
                      Continue;
                    end;
                  end;

                  if (C = Root) then
                  begin
                    if PropPath = 'ClientHeight' then
                      FClientHeight := ReadInteger
                    else if PropPath = 'ClientWidth' then
                      FClientWidth := ReadInteger;
                  end;

                  Position := CurrPos;
                  try
                    ReadProperty(C);
                    FDesigner.ChangedPropList.Add(C, PropPath);
                  except
                  end;
                  if (C = FDesigner.EditForm) and (PropPath = 'Position') then
                  begin
                    FDesigner.FormPositionChanged := True;
                    FDesigner.FormPosition := FDesigner.EditForm.Position;
                  end;
                end;
              end;
              if C is TControl then
                TControl(C).ControlState := TControl(C).ControlState - [csReadingState];
              if (C = Root) then
              begin
                if (FClientHeight > 0) then
                  TControl(C).ClientHeight := FClientHeight;
                if (FClientWidth > 0) then
                  TControl(C).ClientWidth := FClientWidth;
              end;
              ReadListEnd;
            except
              SkipComponent(False);
            end;
          end
          else
            ReadListEnd;

          if C is TTabSheet then
          begin
            if (ParentList.Count > 1) and (ParentList[ParentList.Count - 2] is TPageControl) then
              TTabSheet(C).PageControl := (ParentList[ParentList.Count - 2] as TPageControl);
            TTabSheet(C).Visible := False;
            TTabSheet(C).PageIndex := StrToInt(PageArray[PageArray.Count - 1]);
            PageArray[PageArray.Count - 1] := IntToStr(StrToInt(PageArray[PageArray.Count - 1]) + 1);
          end;
          while (ParentList.Count > 0) and EndOfList do
          begin
            if ParentList[ParentList.Count - 1] is TPageControl then
              PageArray.Delete(PageArray.Count - 1);
            if (ParentList[ParentList.Count - 1] is TWinControl) and
              (csAcceptsControls in TWinControl(ParentList[ParentList.Count - 1]).ControlStyle) then
              TgsWinControlCracker(ParentList[ParentList.Count - 1]).FixupTabList;
            if ParentList[ParentList.Count - 1] is TatContainer then
              Skip := False;


            SetLoading(ParentList[ParentList.Count - 1], False);

            ParentList.Delete(ParentList.Count - 1);
            ReadListEnd;
          end
        end
        else
        begin
          SkipComponent(False);
          while (ParentList.Count > 0) and EndOfList do
          begin
            if ParentList[ParentList.Count - 1] is TPageControl then
            begin
              PageArray.Delete(PageArray.Count - 1);
            end;
            if (ParentList[ParentList.Count - 1] is TWinControl) and
               (csAcceptsControls in TWinControl(ParentList[ParentList.Count - 1]).ControlStyle) then
              TgsWinControlCracker(ParentList[ParentList.Count - 1]).FixupTabList;

            SetLoading(ParentList[ParentList.Count - 1], False);
            ParentList.Delete(ParentList.Count - 1);
            ReadListEnd;
          end
        end;
        if ParentList.Count  = 0 then Break;
      end;

      FixupReferences;
    finally
      EndReferences;
    end;
    for I := 0 to PageControls.Count - 1 do
    begin
      if Assigned(TPageControl(PageControls[I]).ActivePage) then
        TPageControl(PageControls[I]).ActivePage.Visible := True;
    end;
  finally
    PageControls.Free;
    PageArray.Free;
    ParentList.Free;
  end;
end;

procedure TDesignReader.ReadBufComponents(AOwner, AParent: TComponent; ACreatedList: TList);
var
  Component: TComponent;
  R: Integer;
begin
  if Assigned(ACreatedList) then
    ACreatedList.Clear;

  FResolving := TStringList.Create;
  OnSetName := BufOnSetName;
  OnReferenceName := BufOnReferenceName;
  OnFindMethod := BufOnFindMethod;
  try
    Root := AOwner;
    Owner := AOwner;
    Parent := AParent;
    BeginReferences;
    try
      ReadSignature;
      R := FDesigner.RemovalList.GetRemoval(AParent);
      while not EndOfList do
      begin
        Component := ReadComponent(nil);
        if (Component is TControl) and Assigned(TControl(Component).Parent) then
        begin

          TControl(Component).Left := TControl(Component).Left + R;
          TControl(Component).Top := TControl(Component).Top + R;
          if TControl(Component).Left > TControl(Component).Parent.Width then
            TControl(Component).Left := TControl(Component).Parent.Width - TControl(Component).Width;
          if TControl(Component).Top > TControl(Component).Parent.Height then
            TControl(Component).Top := TControl(Component).Parent.Height - TControl(Component).Height;
        end;
        if Assigned(ACreatedList) then
          ACreatedList.Add(Component);
      end;
      ReadListEnd;


      FixupReferences;
    finally
      EndReferences;
    end;
  finally
    OnSetName := nil;
    OnReferenceName := nil;
    OnFindMethod := nil;
    FResolving.Free;
  end;
end;



{ TgsWinControlCracker }


procedure ClipboardTextToBinary(Input, Output: TStream);
var
  SaveSeparator: Char;
  Parser: TParser;
  Writer: TgsWriter;

  function ConvertOrderModifier: Integer;
  begin
    Result := -1;
    if Parser.Token = '[' then
    begin
      Parser.NextToken;
      Parser.CheckToken(toInteger);
      Result := Parser.TokenInt;
      Parser.NextToken;
      Parser.CheckToken(']');
      Parser.NextToken;
    end;
  end;

  procedure ConvertHeader(IsInherited, IsInline: Boolean);
  var
    ClassName, ObjectName: string;
    Flags: TFilerFlags;
    Position: Integer;
  begin
    Parser.CheckToken(toSymbol);
    ClassName := Parser.TokenString;
    ObjectName := '';
    if Parser.NextToken = ':' then
    begin
      Parser.NextToken;
      Parser.CheckToken(toSymbol);
      ObjectName := ClassName;
      ClassName := Parser.TokenString;
      Parser.NextToken;
    end;
    Flags := [];
    Position := ConvertOrderModifier;
    if IsInherited then
      Include(Flags, ffInherited);
    if IsInline then
      Include(Flags, ffInline);
    if Position >= 0 then
      Include(Flags, ffChildPos);
    Writer.WritePrefix(Flags, Position);
    Writer.WriteStr(ClassName);
    Writer.WriteStr(ObjectName);
  end;

  procedure ConvertProperty; forward;

  procedure ConvertValue;
  var
    Order: Integer;

    function CombineString: string;
    begin
      Result := Parser.TokenString;
      while Parser.NextToken = '+' do
      begin
        Parser.NextToken;
        Parser.CheckToken(toString);
        Result := Result + Parser.TokenString;
      end;
    end;

    function CombineWideString: WideString;
    begin
      Result := Parser.TokenWideString;
      while Parser.NextToken = '+' do
      begin
        Parser.NextToken;
        Parser.CheckToken(toWString);
        Result := Result + Parser.TokenWideString;
      end;
    end;

  begin
    if Parser.Token = toString then
      Writer.WriteString(CombineString)
    else if Parser.Token = toWString then
      Writer.WriteWideString(CombineWideString)
    else
    begin
      case Parser.Token of
        toSymbol:
          Writer.WriteIdent(Parser.TokenComponentIdent);
        toInteger:
          Writer.WriteInteger(Parser.TokenInt);
        toFloat:
          begin
            case Parser.FloatType of
              's', 'S': Writer.WriteSingle(Parser.TokenFloat);
              'c', 'C': Writer.WriteCurrency(Parser.TokenFloat / 10000);
              'd', 'D': Writer.WriteDate(Parser.TokenFloat);
            else
              Writer.WriteFloat(Parser.TokenFloat);
            end;
          end;
        '[':
          begin
            Parser.NextToken;
            Writer.WriteValue(vaSet);
            if Parser.Token <> ']' then
              while True do
              begin
                if Parser.Token <> toInteger then
                  Parser.CheckToken(toSymbol);
                Writer.WriteStr(Parser.TokenString);
                if Parser.NextToken = ']' then Break;
                Parser.CheckToken(',');
                Parser.NextToken;
              end;
            Writer.WriteStr('');
          end;
        '(':
          begin
            Parser.NextToken;
            Writer.WriteListBegin;
            while Parser.Token <> ')' do ConvertValue;
            Writer.WriteListEnd;
          end;
        '{':
          Writer.WriteBinary(Parser.HexToBinary);
        '<':
          begin
            Parser.NextToken;
            Writer.WriteValue(vaCollection);
            while Parser.Token <> '>' do
            begin
              Parser.CheckTokenSymbol('item');
              Parser.NextToken;
              Order := ConvertOrderModifier;
              if Order <> -1 then Writer.WriteInteger(Order);
              Writer.WriteListBegin;
              while not Parser.TokenSymbolIs('end') do ConvertProperty;
              Writer.WriteListEnd;
              Parser.NextToken;
            end;
            Writer.WriteListEnd;
          end;
      else
        Parser.Error(SInvalidProperty);
      end;
      Parser.NextToken;
    end;
  end;

  procedure ConvertProperty;
  var
    PropName: string;
  begin
    Parser.CheckToken(toSymbol);
    PropName := Parser.TokenString;
    Parser.NextToken;
    while Parser.Token = '.' do
    begin
      Parser.NextToken;
      Parser.CheckToken(toSymbol);
      PropName := PropName + '.' + Parser.TokenString;
      Parser.NextToken;
    end;
    Writer.WriteStr(PropName);
    Parser.CheckToken('=');
    Parser.NextToken;
    ConvertValue;
  end;

  procedure ConvertObject;
  var
    InheritedObject: Boolean;
    InlineObject: Boolean;
  begin
    InheritedObject := False;
    InlineObject := False;
    if Parser.TokenSymbolIs('INHERITED') then
      InheritedObject := True
    else if Parser.TokenSymbolIs('INLINE') then
      InlineObject := True
    else
      Parser.CheckTokenSymbol('OBJECT');
    Parser.NextToken;
    ConvertHeader(InheritedObject, InlineObject);
    while not Parser.TokenSymbolIs('END') and
      not Parser.TokenSymbolIs('OBJECT') and
      not Parser.TokenSymbolIs('INHERITED') and
      not Parser.TokenSymbolIs('INLINE') do
      ConvertProperty;
    Writer.WriteListEnd;
    while not Parser.TokenSymbolIs('END') do ConvertObject;
    Writer.WriteListEnd;
    Parser.NextToken;

  end;

begin
  Parser := TParser.Create(Input);
  SaveSeparator := DecimalSeparator;
  DecimalSeparator := '.';
  try
    Writer := TgsWriter.Create(Output, 4096);
    try
      Writer.WriteSignature;
      while Parser.TokenSymbolIs('OBJECT') do
        ConvertObject;
      Writer.WriteListEnd;
    finally
      Writer.Free;
    end;
  finally
    DecimalSeparator := SaveSeparator;
    Parser.Free;
  end;
end;

end.
