unit AutoImpl;

interface

// This Demo excersises the use of ActiveX Automation using Early Binding.

uses
  Windows, Classes, ActiveX, Word97;

type
  TWordEventSink = class(TInterfacedObject, IUnknown, IDispatch)
  private
    FOwner : TObject;
    FAppDispatch: IDispatch;
    FDocDispatch: IDispatch;
    FAppDispIntfIID: TGUID;
    FDocDispIntfIID: TGUID;
    FAppConnection: Integer;
    FDocConnection: Integer;
    FOnQuit : TNotifyEvent;
    FOnDocumentChange : TNotifyEvent;
    FOnNewDocument : TNotifyEvent;
    FOnOpenDocument : TNotifyEvent;
    FOnCloseDocument : TNotifyEvent;
  protected
    { IUnknown }
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    { IDispatch }
    function GetTypeInfoCount(out Count: Integer): HRESULT; stdcall;
    function GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT; stdcall;
    function GetIDsOfNames(const IID: TGUID; Names: Pointer;
      NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT; stdcall;
    function Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
      Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT; stdcall;
  public
    constructor Create(AnOwner: TObject; AnAppDispatch: IDispatch; const AnAppDispIntfIID, ADocDispIntfIID: TGUID);
    destructor Destroy; override;
    property OnQuit : TNotifyEvent read FOnQuit write FOnQuit;
    property OnDocumentChange : TNotifyEvent read FOnDocumentChange write FOnDocumentChange;
    property OnNewDocument : TNotifyEvent read FOnNewDocument write FOnNewDocument;
    property OnOpenDocument : TNotifyEvent read FOnOpenDocument write FOnOpenDocument;
    property OnCloseDocument : TNotifyEvent read FOnCloseDocument write FOnCloseDocument;
  end;

  TWordObject = class
  private
    FWordApp : _Application;
    FEventSink : TWordEventSink;
    function GetCaption : String;
    procedure SetCaption(Value : String);
    function GetVisible : Boolean;
    procedure SetVisible(Value : Boolean);
    function GetOnQuit : TNotifyEvent;
    procedure SetOnQuit(Value : TNotifyEvent);
    function GetOnDocumentChange : TNotifyEvent;
    procedure SetOnDocumentChange(Value : TNotifyEvent);
    function GetOnNewDocument: TNotifyEvent;
    procedure SetOnNewDocument(Value : TNotifyEvent);
    function GetOnOpenDocument: TNotifyEvent;
    procedure SetOnOpenDocument(Value : TNotifyEvent);
    function GetOnCloseDocument: TNotifyEvent;
    procedure SetOnCloseDocument(Value : TNotifyEvent);
  public
    constructor Create;
    destructor Destroy; override;
    procedure NewDoc(Template : String);
    procedure CloseDoc;
    procedure InsertText(Text : String);
    procedure Print;
    procedure SaveAs(Filename : String);
//!!! Добавлено
    procedure OpenDoc(Template: String; Format: OleVariant);
  published
    property Application : _Application read FWordApp;
    property Caption : String read GetCaption write SetCaption;
    property Visible : Boolean read GetVisible write SetVisible;
    property OnQuit : TNotifyEvent read GetOnQuit write SetOnQuit;
    property OnDocumentChange : TNotifyEvent read GetOnDocumentChange write SetOnDocumentChange;
    property OnNewDocument : TNotifyEvent read GetOnNewDocument write SetOnNewDocument;
    property OnOpenDocument : TNotifyEvent read GetOnOpenDocument write SetOnOpenDocument;
    property OnCloseDocument : TNotifyEvent read GetOnCloseDocument write SetOnCloseDocument;
  end;

implementation

uses
  ComObj;

{ TWordEventSink implementation }

constructor TWordEventSink.Create(AnOwner : TObject; AnAppDispatch: IDispatch; const AnAppDispIntfIID, ADocDispIntfIID: TGUID);
begin
  inherited Create;

  FOwner := AnOwner;
  FAppDispIntfIID := AnAppDispIntfIID;
  FDocDispIntfIID := ADocDispIntfIID;
  FAppDispatch := AnAppDispatch;

  // Hook the sink up to the automation server (Word97)
  InterfaceConnect(FAppDispatch,FAppDispIntfIID,Self,FAppConnection);
end;

destructor TWordEventSink.Destroy;
begin
  // Unhook the sink from the automation server (Word97)
  InterfaceDisconnect(FAppDispatch,FAppDispIntfIID,FAppConnection);

  inherited Destroy;
end;

function TWordEventSink.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  // We need to return the two event interfaces when they're asked for
  Result := E_NOINTERFACE;
  if GetInterface(IID,Obj) then
    Result := S_OK;
  if IsEqualGUID(IID,FAppDispIntfIID) and GetInterface(IDispatch,Obj) then
    Result := S_OK;
  if IsEqualGUID(IID,FDocDispIntfIID) and GetInterface(IDispatch,Obj) then
    Result := S_OK;
end;

function TWordEventSink._AddRef: Integer;
begin
// Skeleton implementation
  Result := 2;
end;

function TWordEventSink._Release: Integer;
begin
// Skeleton implementation
  Result := 1;
end;

function TWordEventSink.GetTypeInfoCount(out Count: Integer): HRESULT;
begin
// Skeleton implementation
  Count  := 0;
  Result := S_OK;
end;

function TWordEventSink.GetTypeInfo(Index, LocaleID: Integer; out TypeInfo): HRESULT;
begin
// Skeleton implementation
  Result := E_NOTIMPL;
end;

function TWordEventSink.GetIDsOfNames(const IID: TGUID; Names: Pointer;
  NameCount, LocaleID: Integer; DispIDs: Pointer): HRESULT;
begin
// Skeleton implementation
  Result := E_NOTIMPL;
end;

function TWordEventSink.Invoke(DispID: Integer; const IID: TGUID; LocaleID: Integer;
  Flags: Word; var Params; VarResult, ExcepInfo, ArgErr: Pointer): HRESULT;
begin
  // Fire the different event handlers when
  // the different event methods are invoked
  case DispID of
    2 : if Assigned(FOnQuit) then
          FOnQuit(FOwner);
    3 : begin
          if Assigned(FOnDocumentChange) then
            FOnDocumentChange(FOwner);
          // When we see a document change, we also need to disconnect the
          // sink from the old document, and hook it up to the new document
          InterfaceDisconnect(FDocDispatch,FDocDispIntfIID,FDocConnection);
          try
            FDocDispatch := _Application(FAppDispatch).ActiveDocument;
            InterfaceConnect(FDocDispatch,FDocDispIntfIID,Self,FDocConnection);
          except;
          end;
        end;
    4 : if Assigned(FOnNewDocument) then
          FOnNewDocument(FOwner);
    5 : if Assigned(FOnOpenDocument) then
          FOnOpenDocument(FOwner);
    6 : if Assigned(FOnCloseDocument) then
          FOnCloseDocument(FOwner);
  end;

  Result := S_OK;
end;

{ TWordObject implementation }

constructor TWordObject.Create;
begin
  // Fire off Word97 and create the event sink
  FWordApp := CoWordApplication.Create;
  FEventSink := TWordEventSink.Create(Self,FWordApp,ApplicationEvents,DocumentEvents);
end;

destructor TWordObject.Destroy;
var
  SaveChanges,
  OriginalFormat,
  RouteDocument  : OleVariant;
begin
  SaveChanges := WdDoNotSaveChanges;
  OriginalFormat := UnAssigned;
  RouteDocument := UnAssigned;
  try
    FWordApp.Quit(SaveChanges,OriginalFormat,RouteDocument);
  except
  end;
  FEventSink := nil;
  inherited Destroy;
end;

function TWordObject.GetVisible : Boolean;
begin
  Result := FWordApp.Visible;
end;

procedure TWordObject.SetCaption(Value : String);
begin
  FWordApp.Caption := Value;
end;

function TWordObject.GetCaption : String;
begin
  Result := FWordApp.Caption;
end;

procedure TWordObject.SetVisible(Value : Boolean);
begin
  FWordApp.Visible := Value;
end;

function TWordObject.GetOnQuit : TNotifyEvent;
begin
  Result := FEventSink.OnQuit;
end;

procedure TWordObject.SetOnQuit(Value : TNotifyEvent);
begin
  FEventSink.OnQuit := Value;
end;

function TWordObject.GetOnDocumentChange : TNotifyEvent;
begin
  Result := FEventSink.OnDocumentChange;
end;

procedure TWordObject.SetOnDocumentChange(Value : TNotifyEvent);
begin
  FEventSink.OnDocumentChange := Value;
end;

function TWordObject.GetOnNewDocument : TNotifyEvent;
begin
  Result := FEventSink.OnNewDocument;
end;

procedure TWordObject.SetOnNewDocument(Value : TNotifyEvent);
begin
  FEventSink.OnNewDocument := Value;
end;

function TWordObject.GetOnOpenDocument : TNotifyEvent;
begin
  Result := FEventSink.OnOpenDocument;
end;

procedure TWordObject.SetOnOpenDocument(Value : TNotifyEvent);
begin
  FEventSink.OnOpenDocument := Value;
end;

function TWordObject.GetOnCloseDocument : TNotifyEvent;
begin
  Result := FEventSink.OnCloseDocument;
end;

procedure TWordObject.SetOnCloseDocument(Value : TNotifyEvent);
begin
  FEventSink.OnCloseDocument := Value;
end;

procedure TWordObject.InsertText(Text : String);
begin
  FWordApp.Selection.TypeText(Text);
end;

procedure TWordObject.NewDoc(Template : String);
var
  DocTemplate,
  NewTemplate : OleVariant;
begin
  DocTemplate := Template;
  NewTemplate := False;
  FWordApp.Documents.Add(DocTemplate,NewTemplate);
end;

procedure TWordObject.OpenDoc(Template: String; Format: OleVariant);
var
  DocTemplate, DocTemplate1,
  NewTemplate, ReadOnly,
  AddToRecentFiles, PasswordDocument, PasswordTemplate,
  Revert, WritePasswordDocument, WritePasswordTemplate : OleVariant;
begin
  DocTemplate := Template;
  DocTemplate1 := '';
  NewTemplate := False;
  ReadOnly := False;
  AddToRecentFiles := False;
  PasswordDocument := '';
  PasswordTemplate := '';
  Revert := False;
  WritePasswordDocument := '';
  WritePasswordTemplate := '';
//  Format := wdOpenFormatRTF;
  FWordApp.Documents.Open(DocTemplate, NewTemplate, ReadOnly,
    AddToRecentFiles, PasswordDocument, PasswordTemplate,
    Revert, WritePasswordDocument, WritePasswordTemplate, Format);
  {FWordApp.Selection.Select;
  FWordApp.Selection.Copy;
  CloseDoc;
  FWordApp.Documents.Add(DocTemplate1, NewTemplate);
  FWordApp.Selection.Paste;}
end;

procedure TWordObject.CloseDoc;
var
  SaveChanges,
  OriginalFormat,
  RouteDocument  : OleVariant;
begin
  SaveChanges := WdDoNotSaveChanges;
  OriginalFormat := UnAssigned;
  RouteDocument := UnAssigned;
  FWordApp.ActiveDocument.Close(SaveChanges,OriginalFormat,RouteDocument);
end;

procedure TWordObject.Print;
begin
  OleVariant(FWordApp).PrintOut;
end;

procedure TWordObject.SaveAs(Filename : String);
begin
  OleVariant(FWordApp).ActiveDocument.SaveAs(FileName);
end;


end.

