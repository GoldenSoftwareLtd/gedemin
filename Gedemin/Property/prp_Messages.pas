// ShlTanya, 25.02.2019

unit prp_Messages;

interface
uses comctrls, gdcBaseInterface;

type
  TMessageType = (mtUnknown, mtSearch, mtError, mtCallStack, mtWatch, mtCompile);
  TItemType = (itMacro, itReport, itOther);

  TCustomMessageItem = class
  private
    FMessage: string;
    FMsgType: TMessageType;
    FNode: TTreeNode;
    FLine: Integer;
    FFunctionKey: TID;
    FModule: String;
    FItemType: TItemType;
    procedure SetMessage(const Value: string);
    procedure SetNode(const Value: TTreeNode);
    procedure SetLine(const Value: Integer);
    procedure SetFunctionKey(const Value: TID);
    procedure SetModule(const Value: String);
    procedure SetItemType(const Value: TItemType);
  public
    constructor Create;
    property Message: string read FMessage write SetMessage;
    property MsgType: TMessageType read FMsgType;
    property Node: TTreeNode read FNode write SetNode;
    property Line: Integer read FLine write SetLine;
    property FunctionKey: TID read FFunctionKey write SetFunctionKey;
    property Module: String read FModule write SetModule;
    property ItemType: TItemType read FItemType write SetItemType;
  end;

  TSearchMessageItem = class(TCustomMessageItem)
  private
    FColumn: Integer;
    FMatchStart: Integer;
    FMatchLen: Integer;
    FReplaced: Boolean;
    procedure SetColumn(const Value: Integer);
    procedure SetMatchStart(const Value: Integer);
    procedure SetMatchLen(const Value: Integer);
    procedure SetReplaced(const Value: Boolean);
  public
    constructor Create;

    property Column: Integer read FColumn write SetColumn;
    property MatchStart: Integer read FMatchStart write SetMatchStart;
    property MatchLen: Integer read FMatchLen write SetMatchLen;
    property Replaced: Boolean read FReplaced write SetReplaced;
  end;

  TErrorMessageItem = class(TCustomMessageItem)
  public
    constructor Create;
  end;

  TCompileMessageItem = class(TCustomMessageItem)
  private
    FReferenceToSF: TID;
    FAutoClear: Boolean;

    procedure SetReferenceToSF(const Value: TID);
    procedure SetAutoClear(const Value: Boolean);
  public
    constructor Create;

    // ИД СФ, на кот. ссылка в ошибке или предупреждении
    property ReferenceToSF: TID read FReferenceToSF write SetReferenceToSF;
    property AutoClear: Boolean read FAutoClear write SetAutoClear default False;
  end;

  TCallStackMessageItem = class(TCustomMessageItem)
  public
    constructor Create;
  end;

  TWatchListMessageItem = class(TCustomMessageItem)
  private
    FEnabled: Boolean;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create;

    property Enabled: Boolean read FEnabled write SetEnabled;
  end;
implementation

{ TCustomMessageItem }

constructor TCustomMessageItem.Create;
begin
  FMsgType := mtUnknown;
end;

procedure TCustomMessageItem.SetFunctionKey(const Value: TID);
begin
  FFunctionKey := Value;
end;

procedure TCustomMessageItem.SetItemType(const Value: TItemType);
begin
  FItemType := Value;
end;

procedure TCustomMessageItem.SetLine(const Value: Integer);
begin
  FLine := Value;
end;

procedure TCustomMessageItem.SetMessage(const Value: string);
begin
  FMessage := Value;
end;

procedure TCustomMessageItem.SetModule(const Value: String);
begin
  FModule := Value;
end;

procedure TCustomMessageItem.SetNode(const Value: TTreeNode);
begin
  FNode := Value;
end;

{ TSearchMessageItem }

constructor TSearchMessageItem.Create;
begin
  FMsgType := mtSearch;
end;

procedure TSearchMessageItem.SetColumn(const Value: Integer);
begin
  FColumn := Value;
end;

procedure TSearchMessageItem.SetMatchLen(const Value: integer);
begin
  FMatchLen := Value;
end;

procedure TSearchMessageItem.SetMatchStart(const Value: Integer);
begin
  FMatchStart := Value;
end;

procedure TSearchMessageItem.SetReplaced(const Value: Boolean);
begin
  FReplaced := Value;
end;

{ TErrorMessageItem }

constructor TErrorMessageItem.Create;
begin
  FMsgType := mtError;
end;

{ TCallStackMessageItem }

constructor TCallStackMessageItem.Create;
begin
  FMsgType := mtCallStack;
end;

{ TWatchListMessageItem }

constructor TWatchListMessageItem.Create;
begin
  FMsgType := mtWatch;
end;

procedure TWatchListMessageItem.SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

{ TCompileMessageItem }

constructor TCompileMessageItem.Create;
begin
  FMsgType := mtCompile;
end;

procedure TCompileMessageItem.SetAutoClear(const Value: Boolean);
begin
  FAutoClear := Value;
end;

procedure TCompileMessageItem.SetReferenceToSF(const Value: TID);
begin
  FReferenceToSF := Value;
end;

end.
