// ShlTanya, 20.02.2019

unit gd_dispatch;

interface

uses
  Classes, Windows, Graphics, Controls, JclDebug;

type
  TDispatch = class;
  TDispatches = class;
  TDispatchFolder = class;
  TDispatchFolders = class;
  TDispatchManager = class;
  TOfficers = class;
  TOfficer = class;
  TDispatchThread = class;

  TDispatchManager = class(TObject)
  end;

  TDispatchFolders = class(TCollection)
  private
    function GetItems(Index: Integer): TDispatchFolder;
    procedure SetItems(Index: Integer; const Value: TDispatchFolder);
    
  public
    constructor Create;

    function Add: TDispatchFolder;

    property Items[Index: Integer]: TDispatchFolder read GetItems write SetItems;
      default;
  end;

  TDispatchFolder = class(TCollectionItem)
  private
    FBrush: TBrush;
    FDispatches: TDispatches;
    FFont: TFont;
    FOfficer: TOfficer;

    function GetFont: TFont;
    procedure SetFont(const Value: TFont);
    function GetOfficer: TOfficer;
    procedure SetOfficer(const Value: TOfficer);
    function GetBrush: TBrush;
    procedure SetBrush(const Value: TBrush);
    function GetDispatches: TDispatches;
    procedure SetDispatches(const Value: TDispatches);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Brush: TBrush read GetBrush write SetBrush;
    property Dispatches: TDispatches read GetDispatches write SetDispatches;
    property Font: TFont read GetFont write SetFont;
    property Officer: TOfficer read GetOfficer write SetOfficer;
  end;

  TDispatches = class(TCollection)
  private
    function GetItems(Index: Integer): TDispatch;
    procedure SetItems(Index: Integer; const Value: TDispatch);

  public
    constructor Create;

    function Add: TDispatch;

    property Items[Index: Integer]: TDispatch read GetItems write SetItems;
      default;
  end;

  TDispatch = class(TCollectionItem)
  private
    FText: String;

  public
    property Text: String read FText write FText;
  end;

  TOfficers = class(TCollection)
  private
    function GetItems(Index: Integer): TOfficer;
    procedure SetItems(Index: Integer; const Value: TOfficer);
    
  public
    constructor Create;

    function Add: TOfficer;

    property Items[Index: Integer]: TOfficer read GetItems write SetItems;
      default;
  end;

  TOfficer = class(TCollectionItem)
  private
    FPhoto: TGraphic;

    function GetPhoto: TGraphic;
    procedure SetPhoto(const Value: TGraphic);

  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    property Photo: TGraphic read GetPhoto write SetPhoto;
  end;

  TDispatchControl = class(TCustomControl)
  private
    FDispatchFolders: TDispatchFolders;
    FCurrentDispatchIdx: Integer;
    FCurrentFolderIdx: Integer;
    FThread: TDispatchThread;

    procedure SetDispatchFolders(const Value: TDispatchFolders);

  public
    procedure Start;
    procedure Stop;

    procedure NextDispatch;
    procedure NextFolder;

    property CurrentFolderIdx: Integer read FCurrentFolderIdx write FCurrentFolderIdx;
    property CurrentDispatchIdx: Integer read FCurrentDispatchIdx write FCurrentDispatchIdx;
    property DispatchFolders: TDispatchFolders read FDispatchFolders write SetDispatchFolders;
  end;

  TDispatchThread = class(TJclDebugThread)
  private
    FDispatchControl: TDispatchControl;

  protected
    procedure Execute; override;

  public
    property DispatchControl: TDispatchControl read FDispatchControl write FDispatchControl;
  end;

implementation

uses
  SysUtils, JPEG;

{ TDispatchFolder }

constructor TDispatchFolder.Create(Collection: TCollection);
begin
  inherited;
  FBrush := TBrush.Create;
  FDispatches := TDispatches.Create;
  FFont := TFont.Create;
end;

destructor TDispatchFolder.Destroy;
begin
  FBrush.Free;
  FDispatches.Free;
  FFont.Free;
  inherited;
end;

function TDispatchFolder.GetBrush: TBrush;
begin
  Result := FBrush; 
end;

function TDispatchFolder.GetDispatches: TDispatches;
begin
  Result := FDispatches;
end;

function TDispatchFolder.GetFont: TFont;
begin
  Result := FFont;
end;

function TDispatchFolder.GetOfficer: TOfficer;
begin
  Result := FOfficer;
end;

procedure TDispatchFolder.SetBrush(const Value: TBrush);
begin
  FBrush.Assign(Value);
end;

procedure TDispatchFolder.SetDispatches(const Value: TDispatches);
begin
  FDispatches.Assign(Value);
end;

procedure TDispatchFolder.SetFont(const Value: TFont);
begin
  FFont.Assign(Value);
end;

procedure TDispatchFolder.SetOfficer(const Value: TOfficer);
begin
  FOfficer := Value;
end;

{ TDispatchControl }

procedure TDispatchControl.NextDispatch;
begin
  if (not Assigned(FDispatchFolders)) or (FDispatchFolders.Count = 0) then exit;

  Inc(FCurrentDispatchIdx);
  if FCurrentDispatchIdx >= FDispatchFolders[FCurrentFolderIdx].Dispatches.Count then
  begin
    FCurrentDispatchIdx := 0;
    Inc(FCurrentFolderIdx);
  end;
  if FCurrentFolderIdx >= FDispatchFolders.Count then
    FCurrentFolderIdx := 0;
end;

procedure TDispatchControl.NextFolder;
begin
  if (not Assigned(FDispatchFolders)) or (FDispatchFolders.Count = 0) then exit;

  Inc(FCurrentFolderIdx);
  if FCurrentFolderIdx >= FDispatchFolders.Count then
    FCurrentFolderIdx := 0;
end;

procedure TDispatchControl.SetDispatchFolders(
  const Value: TDispatchFolders);
begin
  if FDispatchFolders <> Value then
  begin
    FDispatchFolders := Value;
  end;
end;

procedure TDispatchControl.Start;
begin
  FThread := TDispatchThread.Create(True);
  with FThread do
  begin
    FreeOnTerminate := True;
    DispatchControl := Self;
    Resume;
  end;
end;

procedure TDispatchControl.Stop;
begin
  if Assigned(FThread) then
  begin
    FThread.Terminate;
    FThread := nil;
  end;
end;

{ TDispatchFolders }

function TDispatchFolders.Add: TDispatchFolder;
begin
  Result := TDispatchFolder(inherited Add);
end;

constructor TDispatchFolders.Create;
begin
  inherited Create(TDispatchFolder);
end;

function TDispatchFolders.GetItems(Index: Integer): TDispatchFolder;
begin
  Result := TDispatchFolder(inherited Items[Index]);
end;

procedure TDispatchFolders.SetItems(Index: Integer;
  const Value: TDispatchFolder);
begin
  TDispatchFolder(inherited Items[Index]).Assign(Value);
end;

{ TDispatches }

function TDispatches.Add: TDispatch;
begin
  Result := TDispatch(inherited Add);
end;

constructor TDispatches.Create;
begin
  inherited Create(TDispatch);
end;

function TDispatches.GetItems(Index: Integer): TDispatch;
begin
  Result := TDispatch(inherited Items[Index]);
end;

procedure TDispatches.SetItems(Index: Integer; const Value: TDispatch);
begin
  TDispatch(inherited Items[Index]).Assign(Value);
end;

{ TOfficers }

function TOfficers.Add: TOfficer;
begin
  Result := TOfficer(inherited Add);
end;

constructor TOfficers.Create;
begin
  inherited Create(TOfficer);
end;

function TOfficers.GetItems(Index: Integer): TOfficer;
begin
  Result := TOfficer(inherited Items[Index]);
end;

procedure TOfficers.SetItems(Index: Integer; const Value: TOfficer);
begin
  TOfficer(inherited Items[Index]).Assign(Value);
end;

{ TOfficer }

constructor TOfficer.Create;
begin
  inherited Create(Collection);
  FPhoto := TJPEGImage.Create;
end;

destructor TOfficer.Destroy;
begin
  FPhoto.Free;
  inherited;
end;

function TOfficer.GetPhoto: TGraphic;
begin
  Result := FPhoto;
end;

procedure TOfficer.SetPhoto(const Value: TGraphic);
begin
  FPhoto.Assign(Value);
end;

{ TDispatchThread }

procedure TDispatchThread.Execute;
var
  Bitmap: TBitmap;
  R: TRect;
  H, I: Integer;
  S: String;
begin
  if not Assigned(DispatchControl) then exit;

  Bitmap := TBitmap.Create;
  try
    BitMap.Width := 200 - 64;
    BitMap.Height := 1000;

    while not Terminated do
    begin
      with DispatchControl.DispatchFolders[DispatchControl.CurrentFolderIdx] do
      begin
        if Dispatches.Count < 1 then exit;

        if Officer <> nil then
        begin
          DispatchControl.Canvas.Lock;
          try
            with DispatchControl do
              for I := 64 downto 0 do
              begin
                Canvas.Draw(- I, 0, Officer.Photo);
                Sleep(10);
              end;
          finally
            DispatchControl.Canvas.UnLock;
          end;
        end;

        BitMap.Canvas.Font := Font;
        BitMap.Canvas.Brush := Brush;

        BitMap.Canvas.FillRect(Rect(0, 0, 200 - 64, 1000));

        S := '';
        for I := 0 to Dispatches.Count - 1 do
          S := S + Dispatches[I].Text + #13#10#13#10;

        R := Rect(5, 96, 195 - 64, 995);
        H := DrawText(Bitmap.Canvas.Handle,
          @S[1],
          Length(S),
          R,
          DT_CENTER or DT_WORDBREAK);

        I := 0;
        while (I < (H + 96)) and (not Terminated) do
        begin
          DispatchControl.Canvas.Lock;
          try
            DispatchControl.Canvas.Draw(64, 0 - I, Bitmap);
          finally
            DispatchControl.Canvas.Unlock;
          end;
          Sleep(60);
          Inc(I, 1);
        end;
      end;

      DispatchControl.NextFolder;
    end;

  finally
    BitMap.Free;
  end;
end;

end.
