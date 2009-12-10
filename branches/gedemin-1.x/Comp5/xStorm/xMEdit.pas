{++

  Component xMultiEdit
  Copyrighht c) 1996 by Golden Software

  Module
    xMEdit.pas

  Abstract
  
    Control which possesses multiple edit boxes with labels.

  Author

    Vladimir Belyi (4-oct-1996)

  Uses

  Revisions history

    1.00   4-Oct-1996  belyi   Initial version.
    1.01   9-oct-1996  belyi   OnChange event added.
    1.02  26-nov-1996  belyi   Scrollers added.
    1.03  22-dec-1996    >     Some std properties published.
    1.04   9-sep-1997  belyi   Delphi 3.0; some bugs killed 

  Known bugs

    -

  Wishes

    -

--}

unit xMEdit;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls;

type
  TMEChangeEvent = procedure(Sender: TObject; EditNo: Integer) of object;

  TMEOption = (meStretchEdits, meAutoColumns);
  TMEOptions = set of TMEOption;

type
  TxMultiEdit = class(TCustomControl)
  private
    { Private declarations }

    FCaptions: TStringList;
    FTexts: TStringList; { for swap purposes only. May contain values not
                           corresponding to those in edits }
    FOptions: TMEOptions;
    FColumns: Integer;
    FOnChange: TMEChangeEvent;
    FOnChanged: TMEChangeEvent;

    Scroll: TScrollBox;

    LabelsList: TList;
    EditsList: TList;
    LastParent: TWinControl;

    procedure SetCaptions(Value: TStringList);
    function GetTexts: TStringList;
    procedure SetTexts(Value: TStringlist);
    procedure SetOptions(Value: TMEOptions);
    procedure SetColumns(Value: Integer);

    procedure DeleteControls; { deletes all labels and edits }
    procedure InsertControls; { inserts all labels and edits }
    procedure TextsChange(Sender: TObject);
    procedure CaptionsChange(Sender: TObject);

  protected
    { Protected declarations }

    procedure WMSize(var Msg: TMessage); message WM_SIZE;
    procedure Loaded; override;
    procedure EditChange(Sender: TObject);
    procedure EditExit(Sender: TObject);
    procedure AlignElements; 
    procedure Paint; override;

  public
    { Public declarations }

    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

  published
    { Published declarations }
    property Captions: TStringList read FCaptions write SetCaptions
      stored True;
    property Texts: TStringList read GetTexts write SetTexts
      stored True;
    property Options: TMEOptions read FOptions write SetOptions;
    property Columns: Integer read FColumns write SetColumns;
    property Align;
    property TabOrder;
    property TabStop;

    property OnChange: TMEChangeEvent read FOnChange write FOnChange;
    property OnChanged: TMEChangeEvent read FOnChanged write FOnChanged;
  end;

procedure Register;

implementation

{ ================ TxMultiEdit ========================= }
constructor TxMultiEdit.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FOptions := [meAutoColumns];
  FColumns := 0;

  FCaptions := TStringList.Create;
  FCaptions.Add('Default');
  FCaptions.OnChange := CaptionsChange;

  FTexts := TStringList.Create;
  FTexts.OnChange := TextsChange;

  LabelsList := TList.Create;
  EditsList := TList.Create;

  Scroll := TScrollBox.Create(self);
  Scroll.Align := alClient;
  Scroll.BorderStyle := bsNone;
  InsertControl(Scroll);

  LastParent := nil;

  InsertControls;
end;

destructor TxMultiEdit.Destroy;
begin
  EditsList.Free;
  LabelsList.Free;
  FTexts.Free;
  FCaptions.Free;
  inherited Destroy;
end;

procedure TxMultiEdit.SetCaptions(Value: TStringList);
begin
  DeleteControls;
  FCaptions.Assign(Value);
  InsertControls;
end;

procedure TxMultiEdit.CaptionsChange(Sender: TObject);
begin
  DeleteControls;
  InsertControls;
end;

procedure TxMultiEdit.DeleteControls;
var
  i: Integer;
begin
  for i := 0 to LabelsList.Count - 1 do
    TLabel(LabelsList.Items[i]).Free;
  LabelsList.Clear;

  for i := 0 to EditsList.Count - 1 do
    TEdit(EditsList.Items[i]).Free;
  EditsList.Clear;
end;

procedure TxMultiEdit.InsertControls;
var
  i: Integer;
  E: TEdit;
  L: TLabel;
begin
  if (LabelsList.Count > 0) or (EditsList.Count > 0) then
    DeleteControls;{ normally this line should be executed - but God knows }

  if FCaptions.Count = 0 then exit; { no edits to display }

  for i := 0 to FCaptions.Count - 1 do
    begin
      L := TLabel.Create(self);
      L.Caption := FCaptions[i];
      Scroll.insertControl(L);
      LabelsList.Add(L);

      E := TEdit.Create(self);
      E.Tag := 0;
      E.OnChange := EditChange;
      E.OnExit := EditExit;
      Scroll.insertControl(E);
      EditsList.Add(E);
    end;

  AlignElements;
end;

procedure TxMultiEdit.AlignElements;
var
  i: Integer;
  E: TEdit;
  L: TLabel;
  h, TotalH, w: Integer;
  NextOffset: Integer;
  CurCol: Integer;
  MaxN: Integer;
begin
  if FCaptions.Count = 0 then exit; { no edits to display }

  if meStretchEdits in FOptions then
    h := Height div FCaptions.Count { vertical space for one control }
  else
    h := Round( 1.2 * TLabel(LabelsList.Items[0]).Height) +
      TEdit(Editslist.Items[0]).Height;

  if Scroll.HandleAllocated then
    TotalH := Scroll.ClientHeight
  else
    TotalH := Scroll.Height;

  if meAutoColumns in FOptions then
  begin
    MaxN := TotalH div h;
    if MaxN = 0 then MaxN := 1;
    FColumns := (FCaptions.Count - 1) div MaxN + 1;
  end;

  if Scroll.HandleAllocated then
    w := Scroll.ClientWidth
  else
    w := Scroll.Width;
  if Columns > 0 then w := w div FColumns;

  CurCol := 0;
  NextOffset := 0;
  for i := 0 to FCaptions.Count - 1 do
    begin
      L := LabelsList.Items[i];
      L.Top := NextOffset * h;
      L.Left := CurCol * w + 3;
      L.Width := w - 7;
      L.Caption := FCaptions[i];

      E := Editslist.Items[i];
      E.Top := NextOffset * h + L.Height;
      E.Left := CurCol * w + 3;
      E.Width := w - 7;

      inc(NextOffset);
      if Columns > 0 then
       begin
         if NextOffset * h + L.Height + E.Height > TotalH then
          begin
            inc(CurCol);
            NextOffset := 0;
          end;
       end;
    end;
end;

procedure TxMultiEdit.Paint;
begin
  if (Parent <> LastParent) or (csDesigning in ComponentState) then
  begin
    LastParent := Parent;
    AlignElements; { may be scroleers had appeared }
  end;
  inherited Paint;
end;

procedure TxMultiEdit.EditChange(Sender: TObject);
begin
  (Sender as TEdit).Tag := 1;
  if Assigned(FOnChange) then
    FOnChange(self, EditsList.IndexOf(Sender));
end;

procedure TxMultiEdit.EditExit(Sender: TObject);
begin
  if (Sender as TEdit).Tag = 1 then
    if Assigned(FOnChanged) then
      FOnChanged(self, EditsList.IndexOf(Sender));
  (Sender as TEdit).Tag := 0;
end;

procedure TxMultiEdit.WMSize(var Msg: TMessage);
begin
  inherited;
  AlignElements;
end;

procedure TxMultiEdit.Loaded;
var
  i: Integer;
begin
  inherited Loaded;

  DeleteControls;
  InsertControls;

  for i := 0 to EditsList.Count - 1 do
    if i < FTexts.Count then
      TEdit(EditsList.Items[i]).Text := FTexts[i];
end;

function TxMultiEdit.GetTexts: TStringList;
var
  I: Integer;
begin
  FTexts.Clear;
  for i := 0 to EditsList.Count - 1 do
    FTexts.Add( TEdit(EditsList.Items[i]).Text );
  Result := FTexts;
end;

procedure TxMultiEdit.SetTexts(Value: TStringList);
var
  i: Integer;
begin
  FTexts.Assign(Value);

  for i := 0 to EditsList.Count - 1 do
    if i < Value.Count then
      TEdit(EditsList.Items[i]).Text := Value[i];
end;

procedure TxMultiEdit.TextsChange(Sender: TObject);
var
  i: Integer;
begin
  if csLoading in ComponentState then exit;
  for i := 0 to EditsList.Count - 1 do
    if i < FTexts.Count then
      TEdit(EditsList.Items[i]).Text := FTexts[i];
end;

procedure TxMultiEdit.SetOptions(Value: TMEOptions);
var
  Swap: TMEOptions;
begin
  if Value = FOptions then exit;
  Swap := Value;
  if (meAutoColumns in Value) and not (meAutoColumns in FOptions) then
    Swap := Swap - [meStretchEdits]
  else if (meStretchEdits in Value) and not (meStretchEdits in FOptions) then
    swap := swap - [meAutoColumns];
  FOptions := Swap;
  AlignElements;
end;

procedure TxMultiEdit.SetColumns(Value: Integer);
begin
  if Value <> FColumns then
  begin
    FColumns := Value;
    FOptions := FOptions - [meAutoColumns]; 
    AlignElements;
  end;
end;


{ ============== registration section ============= }
procedure Register;
begin
  RegisterComponents('xWind', [TxMultiEdit]);
end;

end.
