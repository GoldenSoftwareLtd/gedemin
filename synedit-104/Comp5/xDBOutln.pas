
{++

  Copyright (c) 1995-98 by Golden Software

  Module name

    xdboutln.pas

  Abstract

    Delphi visual component. Extended outline control with link
    DataBases

  Author

    Michael Shoihet (15-Dec-95)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    5-Feb-96    michael    Initial version.
    1.10    23-Jul-96   michael    Make some change.
    1.11    7-Aug-96    michael    Make some change.
    1.12    23-Nov-97   michael    Added AutoOpen property.
    1.14    30-nov-97   andreik    Minor improvements.

--}

unit xDBOutln;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, XOutLine, DB, DBTables, DBGrids, StdCtrls, Menus,
  ExList, ExtCtrls, {xInplace, }dbctrls;

type
  TOnCustomFilter = procedure(Sender: TObject; Index: Integer) of object;

const
  DefDelayOpenLevel = 1000;

type
  TDBTreeInfo = class
  public
    Father: PString;
    Son: PString;

    constructor Create(AFather, ASon: String);
    destructor Destroy; override;
  end;

  TxDBOutline = class(TxCustomOutline)
  private
    FDBTreeInfos: TExList;
    FDataLink: TFieldDataLink;
    FTableDataLink: TFieldDataLink;
    FRootInsert: Boolean;
    FRootName: String;
    FDelayOpenLevel: Word;
    FIncludeAllRecord: Boolean;
    FNameSaveFile: TFileName;
    FCreateLevelCode: Boolean;

    FOnCustomFilter: TOnCustomFilter;
    FOnClearFilter: TOnCustomFilter;

    FTimer: TTimer;

    ExclusiveDel: Boolean;

    OldChange: TNotifyEvent;
    OldBeforeDelete: TDataSetNotifyEvent;
    OldAfterDelete: TDataSetNotifyEvent;
    OldBeforeEdit: TDataSetNotifyEvent;
    OldBeforePost: TDataSetNotifyEvent;
    OldAfterPost: TDataSetNotifyEvent;
    OldBeforeInsert: TDataSetNotifyEvent;
    OldBeforeCancel: TDataSetNotifyEvent;

    isLocalDelete: Boolean;
    isLocalPost: Boolean;
    OldOpenIndex: Integer;

    isSetNewFilter: Boolean;
    isFirst: Boolean;
    isNewRecord: Boolean;
    isModify: Boolean;
    isInsertLevel: Boolean;

    PostFather, NewFather: string;
    PostSon, NewSon: string;
    FFieldText: string;
    FAutoCreateKey: Boolean;
    FAutoOpen: Boolean;

    function GetDataSource: TDataSource;
    procedure SetDataSource(aDataSource: TDataSource);
    function GetDataField: string;
    procedure SetDataField(const Value: string);
    procedure SetRootInsert(aValue: Boolean);
    procedure SetRootName(const aValue: string);
    procedure SetDelayOpenLevel(aValue: Word);
    procedure SetIncludeAllRecord(aValue: Boolean);
    procedure SetLinkDataSource(aDataSource: TDataSource);
    function GetLinkDataSource: TDataSource;
    function GetCountViewLevel: Integer;

    function MakeTree(const Level: string; NumLevel: Integer): Boolean;
    procedure InsertNewRecord;
    procedure MoveSubTree(FromSon, ToFather: string);
    procedure SetExclusive(Value: Boolean);

    procedure WriteTreeFile;
    procedure DelTreeFile;
    function LoadTreeFile: boolean;
    procedure SetBitmapNumber;

    procedure SetFilter(Sender: TObject);

    procedure MakeBeforeDelete(DataSet: TDataSet);
    procedure MakeAfterDelete(DataSet: TDataSet);
    procedure MakeBeforeEdit(DataSet: TDataSet);
    procedure MakeBeforePost(DataSet: TDataSet);
    procedure MakeAfterPost(DataSet: TDataSet);
    procedure MakeBeforeInsert(DataSet: TDataSet);
    procedure MakeBeforeCancel(DataSet: TDataSet);

    procedure TimerOpenLevel(Sender: TObject);
    procedure wmKeyDown(var Message: TWMKeyDown);
      message WM_KEYDOWN;
    procedure wmKeyUp(var Message: TWMKeyUp);
      message WM_KEYUP;
    procedure wmKillFocus(var Message: TWMKillFocus);
      message WM_KILLFOCUS;
    procedure UpdateData;

  protected
    InsertSub: Boolean;

    procedure Loaded; override;
    destructor Destroy; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;
    procedure Paint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoExit; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
       X, Y: Integer); override;
    function GetEditText(ACol, ARow: Longint): string; override;
    procedure SetEditText(ACol, ARow: Longint; const Value: string); override;
    function GetEditLimit: Integer; override;
    function CanEditAcceptKey(Key: Char): Boolean; override;
    function GetEditMask(ACol, ARow: Longint): string; override;
    procedure xCancelRange;
    procedure SetNewFilter;

    property DBTreeInfos: TExList read FDBTreeInfos;

  public
    constructor Create(AnOwner: TComponent); override;

    function GetCurrentParent: string;
    function GetCurrentItem: string;
    procedure SetCurrentItem(Code: String);
    function GetLastCode(const Parent: String): string; virtual;
    procedure RebuildTree;
    procedure InsertLevel;
    procedure InsertSubLevel;
    procedure DeleteLevel;
    procedure EditLevel;
    procedure MoveTree(CodeItem, CodeParent, NewCodeParent: String);
    property CountViewLevel: Integer read GetCountViewLevel;

  published
    property AutoOpen: Boolean read FAutoOpen write FAutoOpen default True;
    property NameSaveFile: TFileName read FNameSaveFile write FNameSaveFile;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property LinkDataSource: TDataSource read GetLinkDataSource
      write SetLinkDataSource;
    property DataField: string read GetDataField write SetDataField;
    property RootInsert: Boolean read FRootInsert write SetRootInsert
      default true;
    property RootName: string read FRootName write SetRootName;
    property DelayOpenLevel: Word read FDelayOpenLevel write SetDelayOpenLevel
      default DefDelayOpenLevel;
    property IncludeAllRecord: Boolean read FIncludeAllRecord
      write SetIncludeAllRecord default false;
    property CreateLevelCode: Boolean read FCreateLevelCode
      write FCreateLevelCode default false;
    property AutoCreateKey: Boolean read FAutoCreateKey write FAutoCreateKey
      default True;

    property OnCustomFilter: TOnCustomFilter read FOnCustomFilter
      write FOnCustomFilter;
    property OnClearFilter: TOnCustomFilter read FOnClearFilter
      write FOnClearFilter;

    property SelectColor;
    property CustomBitmap;
    property Options;
    property Pen;
    property ItemIndex;
    property RowHeight;
    property EditOutline;
    property BorderStyle;

    property Color;
    property Font;
    property Width;
    property Height;
    property ScrollBars;
    property Align;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property Indent;
    property SquareSize;
    property DistBitmapText;
    property StretchBitmap;

    property OnGetBitmap;
    property OnGetEditText;
    property OnSetEditText;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

function GetNextAlphaCode(const S: String; Len: Integer): String;
function GetLevelLastCode(const Last: String): String;

procedure Register;

implementation

{ GetNextAlphaCode - function return new alpha code in ASCII sort }
{ S - string contain old alpha code                               }
{ Len - constain length code                                      }

function GetNextAlphaCode(const S: String; Len: Integer): String;
var
  I: Integer;
begin
  Result := S;

  if Result = '' then begin
    for I := 1 to Len do
      Result := Result + '@';
    exit;
  end;

  if Len < Length(S) then
    Len := Length(S);

  for I := Len downto 1 do
    if Result[I] = Chr(122) then
      Result[I] := Chr(64)
    else begin
      Result[I] := Succ(Result[I]);
      break;
    end;
end;

function GetLevelLastCode(const Last: String): String;
var
  Num: Integer;
begin
  Num := StrToInt(Copy(Last, Length(Last) - 1, 2));
  Result:= Copy(Last, 1, Length(Last) - 2) + Format('%2.2d', [Num + 1]);
end;

{ TDBTreeInfo--------------------------------------------- }

constructor TDBTreeInfo.Create(AFather, ASon: String);
begin
  AssignStr(Father, AFather);
  AssignStr(Son, ASon);
end;

destructor TDBTreeInfo.Destroy;
begin
  DisposeStr(Father);
  DisposeStr(Son);
end;

{ TxDBOutline--------------------------------------------- }

constructor TxDBOutline.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FAutoOpen:= True;

  FTableDataLink := TFieldDataLink.Create;
  FTableDataLink.Control:= Self;

  FAutoCreateKey:= True;

  {FLinkDataSource:= nil;}

  FRootInsert:= true;
  FRootName:= '\';

  FDBTreeInfos:= TExList.Create;
  FOnCustomFilter:= nil;
  FOnClearFilter:= nil;
  FDelayOpenLevel:= DefDelayOpenLevel;
  FIncludeAllRecord:= false;

  FTimer:= TTimer.Create(Self);
  FTimer.Interval:= FDelayOpenLevel;
  FTimer.OnTimer:= TimerOpenLevel;
  FTimer.Enabled:= false;

  OldBeforeDelete:= nil;
  OldAfterDelete:= nil;
  OldBeforeEdit:= nil;
  OldBeforePost:= nil;
  OldAfterPost:= nil;
  OldBeforeInsert:= nil;
  OldBeforeCancel:= nil;

  OldChange:= OnChange;
  OnChange:= SetFilter;

  ExclusiveDel:= true;

  OldOpenIndex:= -1;

  isFirst:= true;
  isLocalDelete:= false;
  isInsertLevel:= false;

  PostFather:= '';
  PostSon:= '';
  FFieldText:= '';
  isModify:= false;
  FCreateLevelCode:= false;

  isSetNewFilter:= true;
end;

function TxDBOutline.GetCurrentParent: string;
begin
  if (ItemIndex = -1) or (ItemIndex >= FDBTreeInfos.Count) then
    Result:= ''
  else
    with TDBTreeInfo(FDBTreeInfos[ItemIndex]) do
      Result:= Father^;
end;

function TxDBOutline.GetCurrentItem: string;
begin
  if (ItemIndex = -1) or (ItemIndex >= FDBTreeInfos.Count) then
    Result:= ''
  else
    with TDBTreeInfo(FDBTreeInfos[ItemIndex]) do
      Result:= Son^;
end;

procedure TxDBOutline.SetCurrentItem(Code: String);
var
  i: Integer;
begin
  for i:= 0 to FDBTreeInfos.Count - 1 do begin
    if TDBTreeInfo(FDBTreeInfos[i]).Son^ = Code then begin
      ItemIndex:= i;
    end;
  end;
end;

function TxDBOutline.GetLastCode(const Parent: String): string;
var
  i, Code: Integer;
  LastInt, PerInt: Longint;
  LastDoub, PerDoub: Double;
  OldActive: Boolean;
  aDataType: TFieldType;
begin

  Result:= '';

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;

  with DataSource.DataSet do begin

    aDataType:= Fields[1].DataType;

    case aDataType of
    ftSmallInt, ftInteger, ftWord: LastInt:= 0;
    ftFloat, ftCurrency: LastDoub:= 0;
    ftString: if FCreateLevelCode then
                Result:= Parent+'00'
              else
                Result:='';
    end;

    for i:= 0 to FDBTreeInfos.Count - 1 do begin
      with TDBTreeInfo(FDBTreeInfos[i]) do
        if not FCreateLevelCode or (Father^ = Parent) then begin
          case aDataType of
          ftSmallInt, ftInteger, ftWord:
            if Son <> nil then begin
              val(Son^, PerInt, Code);
              if PerInt > LastInt then LastInt:= PerInt;
            end;
          ftFloat, ftCurrency:
            if Son <> nil then begin
              val(Son^, PerDoub, Code);
              if PerDoub > LastDoub then LastDoub:= PerDoub;
            end;
          ftString:
            if (Son <> nil) and (Result < Son^) then Result:= Son^;
          end;
        end;
     end;

    case aDataType of
    ftSmallInt, ftInteger, ftWord:
      begin
        Inc(LastInt);
        str(LastInt, Result);
      end;
    ftFloat, ftCurrency:
      begin
        LastDoub:= LastDoub + 1;
        str(LastDoub, Result);
      end;
    ftString:
      if not FCreateLevelCode then begin
        Result:= GetNextAlphaCode(Result, Fields[1].Size - 1)
      end
      else
        Result:= GetLevelLastCode(Result);
    end;

  end;
  DataSource.DataSet.Active:= OldActive;
end;

procedure TxDBOutline.RebuildTree;
begin
  MakeTree('', 0);
  if not (csDesigning in ComponentState) then
    WriteTreeFile
  else
    DelTreeFile;
end;

procedure TxDBOutline.InsertLevel;
var
  S: string;
begin
  if (FRootInsert and (ItemIndex = 0)) or not EditOutline then
    exit;

  if Lines.Count > FDBTreeInfos.Count then exit;

  if ItemIndex >= 0 then begin
    NewFather:= TDBTreeInfo(FDBTreeInfos[ItemIndex]).Father^;
    S:= copy(Lines.Strings[ItemIndex], 1, Pos('/', Lines.Strings[ItemIndex])) +
      IntToStr(CountBitmap) + '/-/';
    Lines.Insert(ItemIndex, S);
  end
  else begin
    NewFather:= '';
    S:= '/'+IntToStr(CountBitmap)+'/-/';
    Lines.Insert(0, S);
  end;

  NewSon:=  GetLastCode(NewFather);

  RedrawWindow(HANDLE, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
  SetFocus;
  isInsertLevel:= true;
  ShowEditor;
  DelTreeFile;

end;

procedure TxDBOutline.DeleteLevel;
var
  OldActive: Boolean;
begin
  if (ItemIndex < 0) or (FRootInsert and (ItemIndex = 0)) or not EditOutline
  then exit;

  if Lines.Count > FDBTreeInfos.Count then exit;

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  with TTable(DataSource.DataSet), TDBTreeInfo(FDBTreeInfos[ItemIndex]) do begin
    DisableControls;
    xCancelRange;
    if FindKey([Father^, Son^]) then begin
      Delete;
    end;
    SetNewFilter;
    EnableControls;
  end;
  DataSource.DataSet.Active:= OldActive;
  DelTreeFile;
end;

procedure TxDBOutline.EditLevel;
begin
  SetFocus;
  ShowEditor;
end;

procedure TxDBOutline.MoveTree(CodeItem, CodeParent, NewCodeParent: String);
var
  OldActive: Boolean;
begin
  if (Lines.Count < 0) or ((CodeItem = '') and (CodeParent = '')) or
     (CodeParent = NewCodeParent) or not (DataSource.DataSet is TTable) then exit;

  if Lines.Count > FDBTreeInfos.Count then exit;

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  with TTable(DataSource.DataSet) do
  begin
    DisableControls;
    xCancelRange;

    if FindKey([CodeParent, CodeItem]) then begin
      Edit;
      Fields[0].AsString:= NewCodeParent;
      Post;
    end;

    SetNewFilter;
    EnableControls;
  end;
  DataSource.DataSet.Active:= OldActive;
end;

procedure TxDBOutline.InsertSubLevel;
var
  S: string;
begin
  if (ItemIndex < 0) or not EditOutline then exit;
  if Lines.Count > FDBTreeInfos.Count then exit;

  InsertSub:= true;
  NewFather:= TDBTreeInfo(FDBTreeInfos[ItemIndex]).Son^;
  NewSon:=  GetLastCode(NewFather);
  InsertSub:= false;

  S:= copy(Lines.Strings[ItemIndex], 1, Pos('/', Lines.Strings[ItemIndex]) - 1) +
      ' /'+IntToStr(CountBitmap) + '/-/';

  Lines[ItemIndex]:= copy(Lines.Strings[ItemIndex], 1, Pos('/', Lines.Strings[ItemIndex])) +
      '1/-/' + copy(Lines[ItemIndex], Pos('/', Lines.Strings[ItemIndex]) + 5, 255);

  Lines.Insert(ItemIndex + 1, S);


  if GetState(ItemIndex) <> oiOpenItem then
    SwitchState(Row);

  isSetNewFilter:= false;
  ItemIndex:= ItemIndex + 1;

  RedrawWindow(HANDLE, nil, 0, RDW_INVALIDATE or RDW_UPDATENOW);
  SetFocus;
  isInsertLevel:= true;
  ShowEditor;
  DelTreeFile;

end;

destructor TxDBOutline.Destroy;
begin
  WriteTreeFile;
  FDBTreeInfos.Free;
  FDataLink.Free;
  FTableDataLink.Free;
  inherited Destroy;
end;

procedure TxDBOutline.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then
    DataSource := nil;
  if (Operation = opRemove) and (AComponent = LinkDataSource) then
    LinkDataSource := nil;
end;

procedure TxDBOutline.Paint;
begin
  inherited Paint;
  isFirst:= false;
end;

procedure TxDBOutline.KeyDown(var Key: Word; Shift: TShiftState);
const
  ArrowKeys = [vk_Next, vk_Prior, vk_Up, vk_Down, vk_End, vk_Home];
begin
  if (Key = vk_Escape) and isEditState then begin
    isModify:= false;
    isRedrawGrid:= true;
    HideEditor;
    if isInsertLevel then begin
      Lines.Delete(ItemIndex);
      isInsertLevel:= false;
      NewFather:= '';
      NewSon:= '';
      SetBitmapNumber;
    end;
  end
  else
    if (Key in ArrowKeys) and isEditState then
      UpdateData;
  inherited KeyDown(Key, Shift);
end;

procedure TxDBOutline.KeyPress(var Key: Char);
begin
  if isModify and (Key = #13) and isEditState then UpdateData;
  inherited KeyPress(Key);
  if Key = #13 then begin
    FTimer.Enabled:= false;
    isSetNewFilter:= true;
    SetFilter(Self);
  end;
end;

procedure TxDBOutline.DoExit;
begin
  if isEditState then begin
    isModify:= false;
    isRedrawGrid:= true;
    HideEditor;
    if isInsertLevel then begin
      Lines.Delete(ItemIndex);
      isInsertLevel:= false;
      NewFather:= '';
      NewSon:= '';
    end;
  end;
  inherited DoExit;
end;

procedure TxDBOutline.MouseDown(Button: TMouseButton; Shift: TShiftState;
       X, Y: Integer);
var
  GridR: TGridCoord;
begin
  GridR:= MouseCoord(X, Y);
  if (Y <> Row) and isEditState then UpdateData;
  inherited MouseDown(Button, Shift, X, Y);
end;

function TxDBOutline.GetEditText(ACol, ARow: Longint): string;
begin
  Result:= inherited GetEditText(ACol, ARow);
  FFieldText:= Result;
end;

procedure TxDBOutline.SetEditText(ACol, ARow: Longint; const Value: string);
begin
  FFieldText:= Value;
  isModify:= true;
end;

function TxDBOutline.GetEditLimit: Integer;
var
  OldActive: Boolean;
begin
  Result:= 0;
  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  with DataSource.DataSet do
    if (FieldCount > 0) and (FieldByName(DataField) is TStringField) then
      Result:= TStringField(FieldByName(DataField)).Size;
  DataSource.DataSet.Active:= OldActive;
end;

function TxDBOutline.CanEditAcceptKey(Key: Char): Boolean;
var
  OldActive: Boolean;
begin
  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  Result:= ( FRootInsert and (ItemIndex = 0) ) or
      DataSource.DataSet.FieldByName(DataField).IsValidChar(Key);
  DataSource.DataSet.Active:= OldActive;
end;

function TxDBOutline.GetEditMask(ACol, ARow: Longint): string;
begin
  try
    Result:= DataSource.DataSet.FieldByName(DataField).EditMask;
  except
    Result:= '';
  end;
end;

procedure TxDBOutline.xCancelRange;
begin
  if not Assigned(FOnClearFilter) then begin
    if DataSource.DataSet is TTable then TTable(DataSource.DataSet).CancelRange
  end
  else
    FOnClearFilter(Self, ItemIndex);
end;

procedure TxDBOutline.SetNewFilter;
begin
  OldOpenIndex:= ItemIndex + 1;
  isSetNewFilter:= true;
  SetFilter(@Self);
end;

procedure TxDBOutline.UpdateData;
var
  i, l: Integer;
  S: String;
  OldActive: Boolean;
begin
  if (DataSource <> nil) and (DataSource.DataSet <> nil) and
     (DataSource.DataSet is TTable) then
  begin
    S:= Lines.Strings[ItemIndex];
    i:= 1;
    l:= 0;
    while (S[i] <> '/') or (L < 2) do begin
      if S[i] = '/' then Inc(l);
      Inc(i);
    end;

    if isInsertLevel or (FFieldText <> GetItemText(ItemIndex)) then begin
      isRedrawGrid:= true;
      HideEditor;

      if (ItemIndex = 0) and FRootInsert then begin
        Lines.Strings[ItemIndex]:= copy(S, 1, i) + FFieldText;
        exit;
      end;

      OldActive:= DataSource.DataSet.Active;
      if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
      with TTable(DataSource.DataSet) do
      begin
        isLocalPost:= true;

        DisableControls;

        if isInsertLevel then begin
          try
            Insert;
            Fields[0].AsString:= NewFather;
            Fields[1].AsString:= NewSon;

            FieldByName(FDataLink.FieldName).AsString:= FFieldText;
            if ItemIndex >= 0 then
              Lines.Strings[ItemIndex]:= copy(S, 1, i) +
                FieldByName(FDataLink.FieldName).AsString
            else
              Lines.Strings[0]:= copy(S, 1, i) +
                FieldByName(FDataLink.FieldName).AsString;

            if ItemIndex >= 0 then
              FDBTreeInfos.Insert(ItemIndex, TDBTreeInfo.Create(NewFather, NewSon))
            else
              FDBTreeInfos.Insert(0, TDBTreeInfo.Create(NewFather, NewSon));

            Post;

            SetNewFilter;

            isLocalPost:= false;
            IsInsertLevel:= false;
            NewFather:= '';
            NewSon:= '';
            EnableControls;
          except
            Lines.Delete(ItemIndex);
            isInsertLevel:= false;
            NewFather:= '';
            NewSon:= '';
          end;
          InvalidateRect(SELF.HANDLE, nil, true);
          exit;
        end;
        if ItemIndex < 0 then exit;
        xCancelRange;

        with TDBTreeInfo(FDBTreeInfos[ItemIndex]) do
          FindKey([Father^, Son^]);
        Edit;
        try
          FieldByName(FDataLink.FieldName).AsString:= FFieldText;
          Lines.Strings[ItemIndex]:= copy(S, 1, i) +
            FieldByName(FDataLink.FieldName).AsString;
        finally
          Post;
          SetNewFilter;
          EnableControls;
        end;
        isLocalPost:= false;
      end;
    end
    else
      if isInsertLevel then begin
        Lines.Delete(ItemIndex);
        isInsertLevel:= false;
        NewFather:= '';
        NewSon:= '';
      end;

    isRedrawGrid:= true;
    InvalidateRect(HANDLE, nil, true);
    isModify:= false;

    DataSource.DataSet.Active:= OldActive;
    DelTreeFile;
  end;
end;

procedure TxDBOutline.Loaded;
begin
  inherited Loaded;

  if (csDesigning in ComponentState) or not LoadTreeFile then
    MakeTree('', 0);

  if (DataSource <> nil) and (DataSource.DataSet <> nil) then
    EditOutline:= EditOutline and (DataSource.DataSet is TTable);

  if not (csDesigning in ComponentState) and (DataSource <> nil) and
     (DataSource.DataSet <> nil) and (DataSource.DataSet is TTable)
  then begin
    with TTable(FDataLink.DataSource.DataSet) do begin
      OldBeforeDelete:= BeforeDelete;
      BeforeDelete:= MakeBeforeDelete;
      OldAfterDelete:= AfterDelete;
      AfterDelete:= MakeAfterDelete;
      OldBeforeEdit:= BeforeEdit;
      BeforeEdit:= MakeBeforeEdit;
      OldBeforePost:= BeforePost;
      BeforePost:= MakeBeforePost;
      OldAfterPost:= AfterPost;
      AfterPost:= MakeAfterPost;
      OldBeforeInsert:= BeforeInsert;
      BeforeInsert:= MakeBeforeInsert;
      OldBeforeCancel:= BeforeCancel;
      BeforeCancel:= MakeBeforeCancel;
    end;
  end;
end;

function TxDBOutline.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TxDBOutline.SetDataSource(aDataSource: TDataSource);
var
  i: Integer;
  S: String;
begin
  FDataLink.DataSource := aDataSource;
  if (aDataSource <> nil) and (csDesigning in ComponentState) and not isFirst
  then begin
    RebuildTree;
    if (FNameSaveFile = '') and (DataSource.DataSet is TTable) then begin
      FNameSaveFile:= TTable(DataSource.DataSet).TableName;
      S:= ExtractFileExt(FNameSaveFile);
      FNameSaveFile:= copy(FNameSaveFile, 1, Pos(S, FNameSaveFile))+'tr';
    end;
  end;
end;

function TxDBOutline.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TxDBOutline.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
  if (csDesigning in ComponentState) and not isFirst then
    RebuildTree;
end;

procedure TxDBOutline.SetRootInsert(aValue: Boolean);
var
  i: Integer;
begin
  if FRootInsert <> aValue then begin
    FRootInsert:= aValue;
    if csDesigning in ComponentState then begin
      if aValue then begin
        Lines.Insert(0, '/1/+/'+FRootName);
        for i:= 1 to Lines.Count - 1 do
          Lines.Strings[i]:= ' ' + Lines.Strings[i];
        FDBTreeInfos.Insert(0, TDBTreeInfo.Create('', ''));
      end
      else
        if Lines.Count > 0 then begin
          Lines.Delete(0);
          FDBTreeInfos.DeleteAndFree(0);
        end;
      RebuildOutline;
      if not isFirst and (csDesigning in ComponentState) then
        DelTreeFile;
    end;
  end;
end;

procedure TxDBOutline.SetRootName(const aValue: string);
begin
  if FRootName <> aValue then begin
    FRootName:= aValue;
    if FRootInsert then begin
      if csDesigning in ComponentState then begin
        if Lines.Count > 0 then
          Lines.Delete(0);
        Lines.Insert(0, '/1/+/'+FRootName);
        RebuildOutline;
        if not isFirst and (csDesigning in ComponentState) then
          DelTreeFile;
      end;
    end;
  end;
end;

procedure TxDBOutline.SetDelayOpenLevel(aValue: Word);
begin
  if aValue <> FDelayOpenLevel then begin
    FDelayOpenLevel:= aValue;
    FTimer.Interval:= FDelayOpenLevel;
  end;
end;

procedure TxDBOutline.SetIncludeAllRecord(aValue: Boolean);
begin
  if aValue <> FIncludeAllRecord then begin
    FIncludeAllRecord:= aValue;
    if (csDesigning in ComponentState) and not isFirst then 
      RebuildTree;
  end;
end;

function TxDBOutline.GetLinkDataSource: TDataSource;
begin
  Result:= FTableDataLink.DataSource;
end;

function TxDBOutline.GetCountViewLevel: Integer;
begin
  GetCountViewLevel:= RowCount;
end;

procedure TxDBOutline.SetLinkDataSource(aDataSource: TDataSource);
begin
  FTableDataLink.DataSource:= aDataSource;
end;

type
  TVarInfo = class
  public
    Father: PString;
    Son: PString;
    Info: PString;
    constructor Create(aFather, ASon, aInfo: string);
    destructor Destroy; override;
  end;

constructor TVarInfo.Create;
begin
  AssignStr(Father, aFather);
  AssignStr(Son, aSon);
  AssignStr(Info, aInfo);
end;

destructor TVarInfo.Destroy;
begin
  DisposeStr(Father);
  DisposeStr(Son);
  DisposeStr(Info);
  inherited Destroy;
end;

procedure TxDBOutline.SetBitmapNumber;
var
  i: Integer;
begin
  if CountBitmap > 0 then begin
    for i:= 0 to Lines.Count - 2 do begin
      if Pos('/', Lines[i+1]) <= Pos('/', Lines[i]) then begin
        Lines[i]:= copy(Lines[i], 1, Pos('/', Lines[i])) + IntToStr(CountBitmap) +
          copy(Lines[i], Pos('/', Lines[i]) + 2, 255);
      end;
    end;
    if (Lines.Count > 1) then
      Lines[Lines.Count - 1]:= copy(Lines[Lines.Count - 1], 1, Pos('/', Lines[Lines.Count - 1])) +
          IntToStr(CountBitmap) +
          copy(Lines[Lines.Count - 1], Pos('/', Lines[Lines.Count - 1]) + 2, 255);
  end;

end;

function TxDBOutline.MakeTree;
var
  Index, Len, i, OldCount: Integer;
  S, OldIndex: ShortString;
  OldActive: Boolean;
  VarList: TExList;
  ParentField, ChildField: String;

function SearchIndex(const ToFather: String; var LenDist: Integer): Integer;
var
  i: Integer;
begin
  Result:= -1;
  LenDist:= -1;
  for i:= 0 to Lines.Count - 1 do begin
    with TDBTreeInfo(FDBTreeInfos[i]) do begin
      if (Son^ = ToFather) then begin
        LenDist:= Pos('/', Lines.Strings[i]);
        Result:= i;
      end
      else
        if LenDist = Pos('/', Lines.Strings[i]) - 1 then
          Result:= i
        else
          if LenDist <> -1 then Break;
    end;
  end;
end;

begin

  if (DataSource = nil) or (DataSource.DataSet = nil) or
     (DataField = '')
  then begin
    Lines.Clear;
    exit;
  end;

  Lines.Clear;
  FDBTreeInfos.Free;
  FDBTreeInfos:= TExList.Create;

  if not DataSource.DataSet.Active and not AutoOpen then exit;

  if FRootInsert then begin
    Lines.Insert(0, '/1/+/'+FRootName);
    FDBTreeInfos.Insert(0, TDBTreeInfo.Create('', ''));
  end;

  with DataSource.DataSet do begin
    OldActive:= Active;
    DisableControls;
    if not OldActive then begin
      try
        Active:= true;
      except
        exit;
      end;
    end
    else begin
      xCancelRange;
      First;
    end;
  end;

  VarList:= TExList.Create;

  try

    if DataSource.DataSet is TTable then begin
      OldIndex:= TTable(DataSource.DataSet).IndexFieldNames;
      try
        TTable(DataSource.DataSet).IndexFieldNames:=
            TTable(DataSource.DataSet).Fields[0].FieldName + ';' + DataField;
      except
        TTable(DataSource.DataSet).IndexFieldNames:= OldIndex;
      end;
    end;

    with DataSource.DataSet do begin

      First;
      while not Eof do begin

        ParentField:= Fields[0].AsString;
        ChildField:= Fields[1].AsString;
        if ChildField = '' then begin
          Next;
          Continue;
        end;

        Index:= SearchIndex(ParentField, Len);

        if (Index = -1) and (ParentField <> '') then
          VarList.Add(TVarInfo.Create(ParentField, ChildField,
            FieldByName(DataField).AsString))
        else begin
          if Len <> -1 then begin
            FillChar(S, Len + 1, ' ');
            S[0]:= chr( Len );
          end
          else
            S:= '';
          S:= S + '/1/-/' + FieldByName(DataField).AsString;
          if Index = -1 then
            Index:= Lines.Count - 1;
          Lines.Insert(Index + 1, S );
          FDBTreeInfos.Insert(Index + 1,
            TDBTreeInfo.Create(ParentField, ChildField));
        end;

        Next;

      end;

    end;

    if DataSource.DataSet is TTable then
      TTable(DataSource.DataSet).IndexFieldNames:= OldIndex;

    OldCount:= VarList.Count;
    while VarList.Count > 0 do begin

      i:= 0;
      while i < VarList.Count do begin

        with TVarInfo(VarList[i]) do begin

          Index:= SearchIndex(Father^, Len);
          if (Index = -1) and (Father^ <> '') then
            Inc(i)
          else begin
            if Len <> -1 then begin
              FillChar(S, Len + 1, ' ');
              S[0]:= chr( Len );
            end
            else
              S:= '';
            Lines.Insert(Index + 1, S + '/1/-/' + Info^ );
            FDBTreeInfos.Insert(Index + 1,
              TDBTreeInfo.Create(Father^, Son^));
            VarList.DeleteAndFree(i);
          end;

        end;

      end;

      if OldCount <> VarList.Count then
        OldCount:= VarList.Count
      else
        Break;

    end;

    SetBitmapNumber;

  finally

    VarList.Free;

  end;

  if not FIncludeAllRecord then begin
    i:= 0;
    while i < Lines.Count do begin
      Len:= Pos('/', Lines.Strings[i]);
      if (i = Lines.Count - 1) or (Len >= Pos('/', Lines.Strings[i+1])) then
      begin
        Lines.Delete(i);
        FDBTreeInfos.DeleteAndFree(i);
      end
      else
        Inc(i);
    end;

  end;

  TTable(DataSource.DataSet).Active:= OldActive;
  if OldActive then
    SetNewFilter;
  TTable(DataSource.DataSet).EnableControls;

  if csDesigning in ComponentState then
    RebuildOutline;

end;

procedure TxDBOutline.InsertNewRecord;
var
  i, Index: Integer;
  isInsert: Boolean;
  isParentInclude: Boolean;
  S: String;
  OldActive: Boolean;
begin
  isInsert:= false;
  isParentInclude:= false;
  Index:= 0;
  for i:= 0 to FDBTreeInfos.Count - 1 do
    with TDBTreeInfo(FDBTreeInfos[i]) do begin
      if Father^ = NewSon then
        isInsert:= true
      else
        if (Son^ = NewFather) or (Father^ = NewFather) then begin
          S:= copy(Lines.Strings[i], 1, Pos('/', Lines.Strings[i]) - 1);
          if Father^  = NewFather then begin
            Index:= i;
            if Son^ = '' then S:= S + ' ';
          end
          else begin
            Index:= i + 1;
            S:= S + ' ';
          end;
          if Son^ = NewFather then
            isParentInclude:= true;

        end;
    end;

  if IncludeAllRecord or isInsert then begin
    if (Index = 0) and FRootInsert then
      Inc(Index);
    FDBTreeInfos.Insert(Index, TDBTreeInfo.Create(NewFather, NewSon));
    OldActive:= DataSource.DataSet.Active;
    if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
    with TTable(DataSource.DataSet) do begin
      xCancelRange;
      FindKey([NewFather, NewSon]);
      S:= S + '/1/-/'+ FieldByName(FDataLink.FieldName).AsString;
    end;
    DataSource.DataSet.Active:= OldActive;
    Lines.Insert(Index, S);
  end
  else
    if not isParentInclude and (NewFather <> '') then
      MakeTree('', 0);

  DelTreeFile;

  SetNewFilter;

  isNewRecord:= false;

end;

procedure TxDBOutline.MoveSubTree(FromSon, ToFather: string);
var
  PerList: TStringList;
  PerInfo: TExList;
  i, Index: Integer;
  Lin: Integer;
  S, FromFather: ShortString;
  OldActive: Boolean;
begin

  PerList:= TStringList.Create;
  try
    PerInfo:= TExList.Create;
    try
      Lin:= 255;
      i:= 0;

      isDeleteSpace:= false;
      while i <= Lines.Count - 1 do begin
        with TDBTreeInfo(FDBTreeInfos[i]) do begin
          if (Son^ = FromSon) then begin
            FromFather:= Father^;
            Lin:= Pos('/', Lines.Strings[i]);
            S:= copy(Lines.Strings[i], Lin, 255);
            PerList.Add(S);
            PerInfo.Add(TDBTreeInfo.Create(ToFather, Son^));
            Lines.Delete(i);
            FDBTreeInfos.DeleteAndFree(i);
          end
          else
            if Lin < Pos('/', Lines.Strings[i]) then begin
              S:= copy(Lines.Strings[i], Lin, 255);
              PerList.Add(S);
              PerInfo.Add(TDBTreeInfo.Create(Father^, Son^));
              Lines.Delete(i);
              FDBTreeInfos.DeleteAndFree(i);
            end
            else begin
              Inc(i);
              if Lin <> 255 then Break;
            end;
        end;
      end;
      isDeleteSpace:= true;

      Index:= -2;
      Lin:= 0;
      for i:= 0 to Lines.Count - 1 do
        with TDBTreeInfo(FDBTreeInfos[i]) do
          if (Son^ = ToFather) or ((Son = nil) and (ToFather = '')) or
             ((ToFather = Father^) and (not FRootInsert))
          then begin
            if ((ToFather = Father^) and (not FRootInsert)) then
              Index:= i - 1
            else
              Index:= i;
            Lin:= Pos('/', Lines.Strings[i]);
            if (ToFather = Father^) and (not FRootInsert) then Dec(Lin);
            Break;
          end;

      if Index <> -2 then begin
        for i:= 0 to PerList.Count - 1 do begin
          FillChar(S, Lin + 1, ' ');
          S[0]:= chr(lin);
          S:= S + PerList.Strings[i];
          Lines.Insert(Index + i + 1, S);
          with TDBTreeInfo(PerInfo[i]) do
          FDBTreeInfos.Insert(Index + i + 1, TDBTreeInfo.Create(Father^, Son^));
        end;
      end;
    finally
      PerInfo.Free;
    end;
  finally
    PerList.Free;
  end;

  if Index = -2 then begin
    RebuildTree;
    exit;
  end;

  if not FIncludeAllRecord then begin
    i:= 0;
    while i < Lines.Count do begin
      Lin:= Pos('/', Lines.Strings[i]);
      if ((i = Lines.Count - 1) or (Lin >= Pos('/', Lines.Strings[i+1]))) and
         (TDBTreeInfo(FDBTreeInfos[i]).Son^ = PostFather)
      then
      begin
        OldActive:= DataSource.DataSet.Active;
        if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
        DataSource.DataSet.DisableControls;
        if LinkDataSource = DataSource then
          xCancelRange;
        if not TTable(DataSource.DataSet).FindKey(
           [TDBTreeInfo(FDBTreeInfos[i]).Son^])
        then begin
          Lines.Delete(i);
          FDBTreeInfos.DeleteAndFree(i);
        end
        else
          Inc(i);

        DataSource.DataSet.EnableControls;
        if LinkDataSource = DataSource then begin
          OldOpenIndex:= ItemIndex + 1;
          SetFilter(Self);
        end;
        DataSource.DataSet.Active:= OldActive;
      end
      else
        Inc(i);
    end;
  end;

end;

procedure TxDBOutline.SetExclusive(Value: Boolean);
var
  CountAll, Counts, i, j: Integer;
begin
  CountAll:= Application.ComponentCount;
  for j:= 0 to CountAll - 1 do begin
    if Application.Components[j] is TForm then begin
      Counts:= Application.Components[j].ComponentCount;
      for i:= 0 to Counts - 1 do begin
        if (Application.Components[j].Components[i] <> Self) and
           (Application.Components[j].Components[i] is TxDBOutline)
        then
          with Application.Components[j].Components[i] as TxDBoutline do
            ExclusiveDel:= Value;
      end;
    end;
  end;
end;

procedure TxDBOutline.DelTreeFile;
var
  Pch: array [0..255] of Char;
begin
  if FNameSaveFile <> '' then
    DeleteFile(StrPCopy(Pch, FNameSaveFile));
end;

procedure TxDBOutline.WriteTreeFile;
var
  NameFile: TFileName;
  i, L: Integer;
  F: Integer;
  S: String;
begin
  if IsFirst or (DataSource = nil) or (FNameSaveFile = '') then exit;

  if Pos('\', FNameSaveFile) = 0 then
    F:= FileCreate(ExtractFilePath(Application.ExeName) + FNameSaveFile)
  else
    F:= FileCreate(FNameSaveFile);

  if F < 0 then exit;

  for i:= 0 to Lines.Count - 1 do begin
    with TDBTreeInfo(FDBTreeInfos[i]) do begin
      L:= Length(Lines.Strings[i]);
      FileWrite(F, L, SizeOf(L));
      S:= Lines.Strings[i];
      FileWrite(F, S, Length(Lines.Strings[i])+1);
      L:= Length(Father^);
      FileWrite(F, L, SizeOf(L));
      FileWrite(F, Father^, Length(Father^) + 1);
      L:= Length(Son^);
      FileWrite(F, L, SizeOf(L));
      FileWrite(F, Son^, Length(Son^) + 1);
    end;
  end;

  FileClose(F);

end;

function TxDBOutline.LoadTreeFile: boolean;
var
  NameFile: TFileName;
  i: Integer;
  Counts: Longint;

  FileDate: Longint;

  F: Integer;
  L: Integer;
  S, S1: String;
begin

  Result:= false;
  if isFirst and (csDesigning in ComponentState) or (FNameSaveFile = '') then
    exit;

  if DataSource = nil then exit;

  if Pos('\', FNameSaveFile) = 0 then
    NameFile:= ExtractFilePath(Application.ExeName) + FNameSaveFile + #0
  else
    NameFile:= FNameSaveFile + #0;

  F:= _lOpen(@NameFile[1], OF_READ);
  if F < 0 then exit;

  FileDate:= FileGetDate(F);

  while True do begin

    Counts:= FileRead(F, L, SizeOf(L));
    if Counts <> SizeOf(L) then Break;
    Counts:= FileRead(F, S, L + 1);
    if Counts <> L + 1 then Break;
    Lines.Add(S);
    Counts:= FileRead(F, L, SizeOf(L));
    if Counts <> SizeOf(L) then Break;
    Counts:= FileRead(F, S, L + 1);
    if Counts <> L + 1 then Break;
    Counts:= FileRead(F, L, SizeOf(L));
    if Counts <> SizeOf(L) then Break;
    Counts:= FileRead(F, S1, L + 1);
    if Counts <> L + 1 then Break;
    FDBTreeInfos.Add(TDBTreeInfo.Create(S, S1));

  end;

  FileClose(F);


  Result:= true;

end;

procedure TxDBOutline.MakeBeforeDelete(DataSet: TDataSet);
var
  i: Integer;
  CountsAll, Counts: Integer;
  OldActive: Boolean;
begin
  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  if not isLocalDelete then begin
    PostFather:= DataSet.Fields[0].AsString;
    PostSon:= DataSet.Fields[1].AsString;
  end
  else
    exit;

  if ExclusiveDel then
    SetExclusive(false);
  DataSource.DataSet.Active:= OldActive;
  if Assigned(OldBeforeDelete) then OldBeforeDelete(DataSet);
end;

procedure TxDBOutline.MakeAfterDelete(DataSet: TDataSet);
var
  i, Index: Integer;
  Len: Integer;
  S1, S2: string;
  OldActive: Boolean;

function SearchIndex(const FromSon: String): Boolean;
var
  i: Integer;
begin
  Result:= false;
  for i:= 0 to Lines.Count - 1 do
    with TDBTreeInfo(FDBTreeInfos[i]) do
      if (Son^ = FromSon) then begin
        Result:= true;
        Break;
      end
end;

begin

  if Assigned(OldAfterDelete) then OldAfterDelete(DataSet);

  if isLocalDelete then exit;

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;

  with TTable(DataSource.DataSet) do begin
    DisableControls;
    xCancelRange;
  end;

  isLocalDelete:= true;

  Index:= -1;

  for i:= 0 to FDBTreeInfos.Count - 1 do
    with TDBTreeInfo(FDBTreeInfos[i]) do begin
      if (Father^ = PostFather) and (Son^ = PostSon)
      then begin
        Index:= i;
        Break;
      end;
    end;

  if Index <> -1 then begin
    isDeleteSpace:= false;
    Len:= Pos('/', Lines.Strings[Index]);
    for i:= Index to Lines.Count - 1 do

      if (i = Index) or (Len < Pos('/', Lines.Strings[Index])) then
      begin
        {S1:= Lines.Strings[Index];}
        Lines.Delete(Index);
        if (i <> Index) and ExclusiveDel then begin
          with TTable(DataSource.DataSet), TDBTreeInfo(FDBTreeInfos[Index]) do
          begin
            if FindKey([Father^, Son^]) then
              Delete;
          end;
        end;

        if ExclusiveDel and not FIncludeAllRecord and
           TTable(DataSource.DataSet).
           FindKey([TDBTreeInfo(FDBTreeInfos[Index]).Son^])
        then
          S1:= DataSource.DataSet.Fields[0].AsString;
          S2:= DataSource.DataSet.Fields[1].AsString;
          while not DataSource.DataSet.EOF and
          (S1 = TDBTreeInfo(FDBTreeInfos[Index]).Son^) do
            if not SearchIndex(S2) then
              DataSource.DataSet.Delete
            else
              DataSource.DataSet.Next;

        FDBTreeInfos.DeleteAndFree(Index);

      end
      else
        Break;
    isDeleteSpace:= true;
  end;

  FDBTreeInfos.Pack;

  isLocalDelete:= false;
  PostFather:= '';
  PostSon:= '';

  with TTable(DataSource.DataSet) do
    EnableControls;

  SetNewFilter;

  if ExclusiveDel then
    SetExclusive(true);

  DataSource.DataSet.Active:= OldActive;
  SetBitmapNumber;
  InvalidateRect(HANDLE, nil, true);


end;

procedure TxDBOutline.MakeBeforeEdit(DataSet: TDataSet);
var
  OldActive: Boolean;
begin
  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;
  if not isLocalPost then begin
    PostFather:= TTable(DataSet).Fields[0].AsString;
    PostSon:= TTable(DataSet).Fields[1].AsString;
  end;
  if Assigned(OldBeforeEdit) then OldBeforeEdit(DataSet);
  DataSource.DataSet.Active:= OldActive;
end;

procedure TxDBOutline.MakeBeforePost(DataSet: TDataSet);
var
  OldActive: Boolean;
begin
  if Assigned(OldBeforePost) then OldBeforePost(DataSet);

  if isLocalPost then exit;

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;

  with TTable(DataSet) do
    if Fields[0].AsString = Fields[1].AsString then
      raise Exception.Create('Error field value');

  NewSon:= TTable(DataSet).Fields[1].AsString;
  NewFather:= TTable(DataSet).Fields[0].AsString;
 
  DataSource.DataSet.Active:= true;
end;

procedure TxDBOutline.MakeAfterPost(DataSet: TDataSet);
var
  i, Index, l: Integer;
  S: String;
  OldActive: Boolean;
begin
  if Assigned(OldAfterPost) then OldAfterPost(DataSet);

  if isLocalPost then exit;

  OldActive:= DataSource.DataSet.Active;
  if not DataSource.DataSet.Active then DataSource.DataSet.Active:= true;

  if isNewRecord then begin
    InsertNewRecord;
    exit;
  end;

  if PostSon <> NewSon then
    MakeTree('', 0)
  else begin

    if PostFather <> NewFather then
    begin
      MoveSubTree(PostSon, NewFather);
      exit;
    end;

    Index:= -1;
    for i:= 0 to FDBTreeInfos.Count - 1 do
      with TDBTreeInfo(FDBTreeInfos[i]) do begin
        if ((Father^ = NewFather) and (Son^ = NewSon))
        then begin
          Index:= i;
          Break;
        end;
      end;

    if Index <> -1 then begin
      i:= 1;
      l:= 0;
      while (Lines.Strings[Index][i] <> '/') or (l < 2) do begin
        if Lines.Strings[Index][i] = '/' then Inc(l);
        Inc(i);
      end;

      Lines.Strings[Index]:=
      copy(Lines.Strings[Index], 1, i) +
         TTable(DataSet).FieldByName(DataField).AsString;
    end
    else
      MakeTree('', 0);
  end;
  DataSource.DataSet.Active:= OldActive;
end;

procedure TxDBOutline.MakeBeforeInsert(DataSet: TDataSet);
begin
  if Assigned(OldBeforeInsert) then OldBeforeInsert(DataSet);
  if not isLocalPost then
    isNewRecord:= true;
end;

procedure TxDBOutline.MakeBeforeCancel(DataSet: TDataSet);
begin
  if Assigned(OldBeforeCancel) then OldBeforeCancel(DataSet);
  isNewRecord:= false;
end;

procedure TxDBOutline.SetFilter(Sender: TObject);
var
  S: String;
  i: Integer;

  function GetNextKod(Table: TTable; S: String): String;
  var
    i, Code: Integer;
    NumLongint: Longint;
    NumFloat: Double;
    aDataType: TFieldType;
  begin
    Result:= S;
    aDataType:= Table.Fields[0].DataType;

    case aDataType of
    ftString:
      if S = '' then
        Result:= #1
      else
        Result:= GetNextAlphaCode(S, Length(S));
    ftSmallint, ftInteger, ftWord:
      begin
        val(S, NumLongint, Code);
        Inc(NumLongint);
        str(NumLongint, Result);
      end;
    ftFloat, ftCurrency:
      begin
        val(S, NumFloat, Code);
        NumFloat:= NumFloat + 1;
        str(NumFloat, Result);
      end;
    end;
  end;

begin
  try
    if (ItemIndex < 0) or (ItemIndex = OldOpenIndex) or not isSetNewFilter or
       (LinkDataSource = nil) or (DataSource = nil){ or
       (TTable(LinkDataSource.DataSet).TableName = '') or
       (TTable(DataSource.DataSet).TableName = '')}
    then 
      exit;
      
  except
    ShowMessage('Error in xDBOutln.pas at 1790.');
    raise;
  end;
  
  if Assigned(FOnCustomFilter) then begin
    FOnCustomFilter(Self, ItemIndex);
    isSetNewFilter:= true;
    OldOpenIndex:= ItemIndex;
    exit;
  end;


  if (LinkDataSource <> nil) and (DataSource <> nil)
      and (DataSource.DataSet <> nil)
  then begin
    OldOpenIndex:= ItemIndex;
    with TDBTreeInfo(FDBTreeInfos[ItemIndex]),
         TTable(LinkDataSource.DataSet) do
    begin

      if Son <> nil then
        S:= Son^
      else
        S:= '';

      SetRangeStart;
      Fields[0].AsString:= S;
      SetRangeEnd;
      if TTable(LinkDataSource.DataSet).IndexFieldCount > 1 then
        Fields[0].AsString:= GetNextKod(TTable(LinkDataSource.DataSet), S)
      else
        Fields[0].AsString:= S;
      ApplyRange;
    end;
  end;
  if Assigned(OldChange) then OldChange(Sender);
  isSetNewFilter:= true;
end;

procedure TxDBOutline.TimerOpenLevel(Sender: TObject);
begin
  isSetNewFilter:= true;
  SetFilter(@Self);
  FTimer.Enabled:= false;
end;

procedure TxDBOutline.wmKeyDown(var Message: TWMKeyDown);
var
  OldIndex: Longint;
begin
  if (Message.CharCode <> vk_Return) and (FDelayOpenLevel > 0) then
    isSetNewFilter:= false;
  inherited;
end;

procedure TxDBOutline.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;

  if (Message.CharCode <> vk_Return) and (FDelayOpenLevel > 0) then
    FTimer.Enabled := True;
end;

procedure TxDBOutline.WMKillFocus(var Message: TWMKillFocus);
begin
  if isEditState and (Message.FocusedWnd <> InplaceEditor.Handle) then
  begin
    isModify:= false;
    isRedrawGrid:= true;
    HideEditor;
    if isInsertLevel then begin
      Lines.Delete(ItemIndex);
      isInsertLevel:= false;
      NewFather:= '';
      NewSon:= '';
    end;
  end;

  inherited;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool', [TxDBOutline]);
end;

end.
