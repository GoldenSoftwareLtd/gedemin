
unit ct_pascal_parser;

interface

uses
  ct_input_parser, ct_class, Classes;

type
  TFileArea = (faUnit, faInterface, faType, faClass, faRecord, faTypeInterface,
    faImplementation, faConst, faVar, faComment, faNone);

  TFileAreaStack = class(TObject)
  private
    FStack: array of TFileArea;
    FCount: Integer;

    function GetCount: Integer;
    function GetEmpty: Boolean;
    function GetOnTop: TFileArea;

  public
    constructor Create;
    destructor Destroy; override;

    procedure Put(const FA: TFileArea);
    function Get: TFileArea;

    property Empty: Boolean read GetEmpty;
    property OnTop: TFileArea read GetOnTop;
    property Count: Integer read GetCount;
  end;

type
  TctFileParser = class(TObject)
  private

  public
  end;

function ParseUnit(const AFileName: String): TctUnit;

implementation

uses
  SysUtils, gs_Exception;

function ParseUnit(const AFileName: String): TctUnit;
var
  Stream: TMemoryStream;
  IP: TctInputParser;
  Stack: TFileAreaStack;
  Tokem: TctTokem;
  Cl: TctClass;
  ClS: TctClassSection;
  Mt: TctMethod;
  Fld: TctField;
  Rt: TctRoutine;
  Comment: String;
  Ct: TctConst;
  Buf, Id: String;
begin
  Stream := TMemoryStream.Create;
  Stream.LoadFromFile(AFileName);

  Stack := TFileAreaStack.Create;
  IP := TctInputParser.Create(Stream);
  Result := TctUnit.Create;
  Result.FileName := AFileName;

  // захаваем тэкст of unit
  SetLength(Buf, Stream.Size);
  Stream.ReadBuffer(Buf[1], Stream.Size);
  Result.Decloration := Buf;
  SetLength(Buf, 0);
  Stream.Position := 0;

  try
    Comment := '';
    Stack.Put(faNone);

    while not (IP.GetNext = ttEOF) do
    begin

      if Stack.OnTop = faImplementation then
      begin
        // we skip all implementation section
        IP.ClearStack;
        continue;
      end;

      if (IP.TokemType = ttSymbol) and (IP.Tokem = '{') then
      begin
        IP.GetNextUntil('}');
        if Stack.OnTop = faComment then
          Comment := Comment + #13#10 + IP.Tokem
        else
        begin
          Comment := IP.Tokem;
          Stack.Put(faComment);
        end;
        IP.GetNext;
        continue;
      end;

      if (IP.TokemType = ttSymbol) and (IP.Tokem = '*') and (IP.Stream.Position > 1) and (IP.GetPrev.Tokem = '(') then
      begin
        if Stack.OnTop <> faComment then
        begin
          Comment := '';
          Stack.Put(faComment);
        end;
        repeat
          IP.GetNextUntil(')');
          Comment := Comment + #13#10 + IP.Tokem;
        until IP.GetPrev.Tokem = '*';
        IP.GetNext;
        if Length(Comment) > 0 then
          SetLength(Comment, Length(Comment) - 1);
        continue;
      end;

      if (IP.TokemType = ttSymbol) and (IP.Tokem = '/') and (IP.Stream.Position > 1) and (IP.GetPrev.Tokem = '/') then
      begin
        IP.GetNextUntilEOL;
        if Stack.OnTop <> faComment then
        begin
          Comment := IP.Tokem;
          Stack.Put(faComment);
        end else
          Comment := Comment + #13#10 + IP.Tokem;
        IP.GetNext;
        continue;
      end;

      // nothing to go for any farther
      if IP.TokemType = ttSpace then
      begin
        continue;
      end;

      // мы аб'ядноўваем некалькі паслядоўных каментараў у адзін
      // трэба адсочваць калі ён скончваецца
      if (IP.TokemType <> ttSpace) and (Stack.OnTop = faComment) then
      begin
        Stack.Get;
      end;

      if (Stack.OnTop in [faNone]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'unit') then
      begin
        Stack.Put(faUnit);
        IP.GetNext;
        IP.GetNextUntil(';');
        Result.Name := IP.Tokem;
        Result.Comment := Comment;
        Comment := '';
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faUnit, faInterface, faImplementation]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'uses') then
      begin
        IP.GetNext;
        IP.GetNextUntil(';');
        Result.SectionUses.Decloration := IP.Tokem + ';';
        Result.SectionUses.Comment := Comment;
        Comment := '';
        IP.GetNext; // ;
        IP.GetNext; // space
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faUnit]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'interface') then
      begin
        Stack.Put(faInterface);
        Comment := '';
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faInterface, faType, faConst, faVar]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'implementation') then
      begin
        Stack.Put(faImplementation);
        Comment := '';
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faType]) and (IP.TokemType = ttIdentifier) then
      begin
        Id := IP.Tokem;
        IP.GetNext;

        if IP.TokemType = ttSpace then
          IP.GetNext;

        if IP.Tokem <> '=' then
        begin
          repeat
            IP.Rollback;
          until IP.Tokem = Id;
        end else
        begin
          IP.GetNext;
          if IP.TokemType = ttSpace then
            IP.GetNext;
          if (IP.LowerTokem = 'class') or (IP.LowerTokem = 'record') then
          begin
            repeat
              IP.Rollback;
            until IP.Tokem = Id;
          end else
          begin
            IP.Rollback;
            IP.GetNextUntil(';', '(', ')');
            IP.GetNext;
            IP.GetNext;
            IP.ClearStack;
            continue;
          end;
        end;
      end;

      if (Stack.OnTop in [faInterface, faType, faVar]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'const') then
      begin
        if (Stack.OnTop in [faType, faVar]) then
        begin
          Stack.Get;
          if Stack.OnTop <> faInterface then
          begin
            // we are not in the interface section
            // get rid of it
            continue;
          end;
        end;

        Stack.Put(faConst);
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faConst]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem <> 'type') and (IP.LowerTokem <> 'var')
        and (IP.LowerTokem <> 'procedure') and (IP.LowerTokem <> 'function')
      then
      begin
        Ct := TctConst.Create;
        Ct.Name := IP.Tokem;
        Ct.Decloration := IP.Tokem;

        IP.GetNextUntil(';', '''(', ''')');
        Ct.Decloration := Ct.Decloration + IP.Tokem + ';';
        Ct.Comment := Comment;
        Comment := '';
        Result.Consts.Add(Ct);
        IP.GetNext; // ;
        IP.GetNext; // space
        IP.ClearStack;
        continue;
      end;

      // сустрэлі аб'яўленьне працэдуры, ці функцыі
      // выходзім з сэкцыяў зьменных, канстантаў ці тыпу
      if (Stack.OnTop in [faVar, faConst, faType]) and ((IP.TokemType = ttIdentifier) and (
        (IP.LowerTokem = 'procedure') or (IP.LowerTokem = 'function'))) then
      begin
        Stack.Get;
      end;

      if (Stack.OnTop in [faInterface, faType, faConst]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'var') then
      begin
        if (Stack.OnTop in [faType, faConst]) then
        begin
          Stack.Get;
          if Stack.OnTop <> faInterface then
          begin
            // we are not in the interface section
            // get rid of it
            continue;
          end;
        end;

        Stack.Put(faVar);
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faVar]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem <> 'end') then
      begin
        IP.GetNextUntil(';');
        Result.Vars.CreateVarsFromDecloration(IP.GetPrev.Tokem + IP.Tokem + ';', Comment);
        Comment := '';

        IP.GetNext; // skip ;
        IP.GetNext; // skip space

        continue;
      end;

      if (Stack.OnTop in [faInterface]) and (IP.TokemType = ttIdentifier)
        and ((IP.LowerTokem = 'procedure') or (IP.LowerTokem = 'function')) then
      begin
        if Stack.OnTop <> faInterface then
          Stack.Get;

        Rt := TctRoutine.Create;
        Rt.Decloration := IP.Tokem;

        IP.GetNext;
        Rt.Decloration := Rt.Decloration + IP.Tokem;

        IP.GetNext;
        Rt.Decloration := Rt.Decloration + IP.Tokem;
        Rt.Name := IP.Tokem;

        IP.GetNextUntil(';', '(''', ')''');
        Rt.Decloration := Rt.Decloration + IP.Tokem + ';';
        IP.GetNext;

        Rt.Comment := Comment;
        Comment := '';

        Result.Routines.Add(Rt);
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop in [faInterface, faVar, faConst]) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'type') then
      begin
        if (Stack.OnTop in [faVar, faConst]) then
          Stack.Get;

        Stack.Put(faType);
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop = faType) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'interface') then
      begin
        Stack.Put(faTypeInterface);
        IP.GetNext;
        IP.ClearStack;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'class') then
      begin
        // previous was a forward class decloration
      end;

      if (Stack.OnTop = faType) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'record') then
      begin
        //...
        IP.GetNext;
        Stack.Put(faRecord);
        continue;
      end;

      if (Stack.OnTop = faType) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'class') then
      begin
        Tokem := IP.GetPrev;

        if Tokem.TokemType = ttSpace then
          Tokem := IP.GetPrev;

        if (Tokem.TokemType <> ttSymbol) or (Tokem.Tokem <> '=') then
          raise Exception.Create(GetGsException(Self, 'syntax error'));

        Tokem := IP.GetPrev;

        if Tokem.TokemType = ttSpace then
          Tokem := IP.GetPrev;

        if (Tokem.TokemType <> ttIdentifier) then
          raise Exception.Create(GetGsException(Self, 'syntax error'));

        // try to find forwarded class
        Cl := Result.Classes.Find(Tokem.Tokem);

        if Cl = nil then
        begin
          Cl := TctClass.Create(Tokem.Tokem, Result);
          Result.Classes.Add(Cl);
        end;

        Cl.Comment := Comment;
        Comment := '';

        Cls := Cl.Sections.PublicSection;

        if IP.GetNext = ttSpace then
          IP.GetNext;

        if IP.TokemType = ttIdentifier then
        begin
          // гэта клас ад TObject але праграміст не паказаў гэта яўна
          Cl.Parent := Result.Classes.Find('TObject');
          if Cl.Parent = nil then
            Cl.ParentName := 'TObject';
          IP.Rollback;
          Stack.Put(faClass);
          continue;
        end;

        if (IP.TokemType = ttSymbol) and (IP.Tokem = ';') then
        begin
          // forward decloration
          continue;
        end;

        if (IP.TokemType = ttSymbol) and (IP.Tokem = '(') then
        begin
          // parent class
          IP.GetNextUntil(')');
          Cl.Parent := Result.Classes.Find(IP.Tokem);
          if Cl.Parent = nil then
            Cl.ParentName := IP.Tokem;
          IP.GetNext;
        end;

        if (IP.GetNext = ttSymbol) and (IP.Tokem = ';') then
        begin
          // empty class declaration
          Cl := nil;
          Cls := nil;
          continue;
        end;

        Stack.Put(faClass);
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier) then
      begin
        // skip these
        if (IP.LowerTokem = 'abstract')
          or (IP.LowerTokem = 'virtual')
          or (IP.LowerTokem = 'dynamic')
          or (IP.LowerTokem = 'override')
          or (IP.LowerTokem = 'reintroduce')
          or (IP.LowerTokem = 'default')
          or (IP.LowerTokem = 'overload')
          or (IP.LowerTokem = 'safecall')
          then
        begin
          if IP.GetNext = ttSpace then
            IP.GetNext;
          if (IP.TokemType <> ttSymbol) and (IP.Tokem <> ';') then
            raise Exception.Create(GetGsException(Self, 'syntax error'));
          continue;
        end;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'private') then
      begin
        Cls := Cl.Sections.PrivateSection;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'protected') then
      begin
        Cls := Cl.Sections.ProtectedSection;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'public') then
      begin
        Cls := Cl.Sections.PublicSection;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'published') then
      begin
        Cls := Cl.Sections.PublishedSection;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'automated') then
      begin
        raise Exception.Create(GetGsException(Self, 'feature not supported'));
        Cls := Cl.Sections.PublishedSection;
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem = 'function') then
      begin
        Assert(Assigned(Cl));
        Assert(Assigned(Cls));
        Mt := TctMethod.Create(Cls);
        Mt.Decloration := IP.Tokem;
        if IP.GetNext <> ttSpace then
          raise Exception.Create(GetGsException(Self, 'syntax error'));
        Mt.Decloration := Mt.Decloration + IP.Tokem;
        if IP.GetNext <> ttIdentifier then
          raise Exception.Create(GetGsException(Self, 'syntax error'));
        Mt.Name := IP.Tokem;
        Mt.Decloration := Mt.Decloration + IP.Tokem;
        IP.GetNextUntil(';', '(''', ')''');
        Mt.Decloration := Mt.Decloration + IP.Tokem + ';';
        IP.GetNext;

        Mt.Comment := Comment;
        Comment := '';

        Cls.Methods.Add(Mt);
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and ((IP.LowerTokem = 'procedure') or (IP.LowerTokem = 'constructor') or (IP.LowerTokem = 'destructor')) then
      begin
        Assert(Assigned(Cl));
        Assert(Assigned(Cls));
        Mt := TctMethod.Create(Cls);
        Mt.Decloration := IP.Tokem;
        if IP.GetNext <> ttSpace then
          raise Exception.Create(GetGsException(Self, 'syntax error'));
        Mt.Decloration := Mt.Decloration + IP.Tokem;
        if IP.GetNext <> ttIdentifier then
          raise Exception.Create(GetGsException(Self, 'syntax error'));
        Mt.Name := IP.Tokem;
        Mt.Decloration := Mt.Decloration + IP.Tokem;
        IP.GetNextUntil(';', '(''', ')''');
        Mt.Decloration := Mt.Decloration + IP.Tokem + ';';
        IP.GetNext;

        Mt.Comment := Comment;
        Comment := '';

        Cls.Methods.Add(Mt);
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.Tokem = 'property') then
      begin
        // property
        Assert(Assigned(Cl));
        Assert(Assigned(Cls));
        Fld := TctField.Create(Cls);
        Fld.IsProperty := True;
        Fld.Decloration := IP.Tokem;
        if IP.GetNext = ttSpace then
          IP.GetNext;
        Fld.Name := IP.Tokem;
        Fld.Decloration := Fld.Decloration + ' ' + IP.Tokem;
        IP.GetNextUntil(';');
        Fld.Decloration := Fld.Decloration + IP.Tokem + ';';
        IP.GetNext;
        Fld.Comment := Comment;
        Comment := '';
        Cls.Fields.Add(Fld);
        continue;
      end;

      if (Stack.OnTop = faClass) and (IP.TokemType = ttIdentifier)
        and (IP.LowerTokem <> 'end')then
      begin
        // field
        Assert(Assigned(Cl));
        Assert(Assigned(Cls));
        Fld := TctField.Create(Cls);
        Fld.IsProperty := False;
        Fld.Name := IP.Tokem;
        Fld.Decloration := IP.Tokem;
        IP.GetNextUntil(';');
        Fld.Decloration := Fld.Decloration + IP.Tokem + ';';
        IP.GetNext;
        Cls.Fields.Add(Fld);
        continue;
      end;

      if (IP.TokemType = ttIdentifier) and (IP.LowerTokem = 'end') then
      begin
        if Stack.OnTop = faComment then
          Stack.Get;

        case Stack.OnTop of
          faClass:
          begin
            Stack.Get;
            IP.GetNext;
            if (IP.TokemType <> ttSymbol) or (IP.LowerTokem <> ';') then
              raise Exception.Create(GetGsException(Self, 'syntax error'));
            Cl := nil;
            Cls := nil;
          end;

          faRecord:
          begin
            Stack.Get;
            IP.GetNext;
            if (IP.TokemType <> ttSymbol) or (IP.LowerTokem <> ';') then
              raise Exception.Create(GetGsException(Self, 'syntax error'));
            IP.GetNext;
            IP.ClearStack;
            Comment := '';
          end;

          faTypeInterface:
          begin
            Stack.Get;
          end;

          faImplementation:
          begin
            Stack.Get;
            if (IP.GetNext <> ttSymbol) or (IP.LowerTokem <> '.') then
              raise Exception.Create(GetGsException(Self, 'syntax error'));
          end;

        end;
      end;

    end;

  finally
    Stream.Free;
    IP.Free;
  end;
end;

{ TFileAreaStack }

constructor TFileAreaStack.Create;
begin
  inherited;
  FCount := 0;
  SetLength(FStack, 10000);
end;

destructor TFileAreaStack.Destroy;
begin
  inherited;
  SetLength(FStack, 0);
end;

function TFileAreaStack.Get: TFileArea;
begin
  Dec(FCount);
  Result := FStack[FCount];
end;

function TFileAreaStack.GetCount: Integer;
begin
  Result := FCount;
end;

function TFileAreaStack.GetEmpty: Boolean;
begin
  Result := FCount = 0;
end;

function TFileAreaStack.GetOnTop: TFileArea;
begin
  Result := FStack[FCount - 1];
end;

procedure TFileAreaStack.Put(const FA: TFileArea);
begin
  if FCount >= High(FStack) then
    SetLength(FStack, High(FStack) + 1000);

  FStack[FCount] := FA;
  Inc(FCount);
end;

end.
