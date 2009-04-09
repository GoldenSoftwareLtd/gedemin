unit gdv_frameBaseAnalitic_unit;

interface

uses 
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList;

type
  TframeBaseAnalitic = class(TFrame)
    gbGroup: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    lbAvail: TListBox;
    lbSelected: TListBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    ActionList1: TActionList;
    actUp: TAction;
    actDown: TAction;
    actInclude: TAction;
    actIncludeAll: TAction;
    actExclude: TAction;
    actExcludeAll: TAction;
    procedure actUpExecute(Sender: TObject);
    procedure actUpUpdate(Sender: TObject);
    procedure actDownExecute(Sender: TObject);
    procedure actDownUpdate(Sender: TObject);
    procedure actIncludeExecute(Sender: TObject);
    procedure actIncludeAllExecute(Sender: TObject);
    procedure actExcludeExecute(Sender: TObject);
    procedure actExcludeUpdate(Sender: TObject);
    procedure actExcludeAllExecute(Sender: TObject);
    procedure lbAvailDblClick(Sender: TObject);
    procedure lbSelectedDblClick(Sender: TObject);
    procedure actIncludeUpdate(Sender: TObject);
    procedure actIncludeAllUpdate(Sender: TObject);
    procedure actExcludeAllUpdate(Sender: TObject);
  private
    function GetAvail: TStrings;
    function GetSelected: TStrings;
  protected
    function GetValues: string; virtual;
    procedure SetValues(const Value: string);virtual;
  public
    { Public declarations }
    procedure UpdateAvail(IdList: TList); virtual;
    property Avail: TStrings read GetAvail;
    property Selected: TStrings read GetSelected;
    property Values: string read GetValues write SetValues;
  end;
  
implementation

{$R *.DFM}

procedure TframeBaseAnalitic.actUpExecute(Sender: TObject);
var
  S: String;
  P: Pointer;
begin
  if lbSelected.ItemIndex > 0 then
  begin
    S := lbSelected.Items[lbSelected.ItemIndex - 1];
    P := lbSelected.Items.Objects[lbSelected.ItemIndex - 1];

    lbSelected.Items[lbSelected.ItemIndex - 1] := lbSelected.Items[lbSelected.ItemIndex];
    lbSelected.Items.Objects[lbSelected.ItemIndex - 1] := lbSelected.Items.Objects[lbSelected.ItemIndex];

    lbSelected.Items[lbSelected.ItemIndex] := S;
    lbSelected.Items.Objects[lbSelected.ItemIndex] := P;

    lbSelected.ItemIndex := lbSelected.ItemIndex - 1;
  end;
end;

procedure TframeBaseAnalitic.actUpUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lbSelected.ItemIndex >= 0;
end;

procedure TframeBaseAnalitic.actDownExecute(Sender: TObject);
var
  S: String;
  P: Pointer;
begin
  if lbSelected.ItemIndex < lbSelected.Items.Count - 1 then
  begin
    S := lbSelected.Items[lbSelected.ItemIndex + 1];
    P := lbSelected.Items.Objects[lbSelected.ItemIndex + 1];

    lbSelected.Items[lbSelected.ItemIndex + 1] := lbSelected.Items[lbSelected.ItemIndex];
    lbSelected.Items.Objects[lbSelected.ItemIndex + 1] := lbSelected.Items.Objects[lbSelected.ItemIndex];

    lbSelected.Items[lbSelected.ItemIndex] := S;
    lbSelected.Items.Objects[lbSelected.ItemIndex] := P;

    lbSelected.ItemIndex := lbSelected.ItemIndex + 1;
  end;
end;

procedure TframeBaseAnalitic.actDownUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lbSelected.ItemIndex >= 0;
end;

procedure TframeBaseAnalitic.actIncludeExecute(Sender: TObject);
var
  I, J: Integer;
  Flag: Boolean;
begin
  for I := 0 to lbAvail.Items.Count - 1 do
  begin
    if lbAvail.Selected[I] then
    begin
      Flag := True;
      for J := 0 to lbSelected.Items.Count - 1 do
      begin
        if lbSelected.Items.Objects[J] = lbAvail.Items.Objects[I] then
        begin
          Flag := False;
          break;
        end;
      end;
      if Flag then
      begin
        lbSelected.Items.AddObject(lbAvail.Items[I], lbAvail.Items.Objects[I]);
      end;
    end;
  end;
end;

procedure TframeBaseAnalitic.actIncludeAllExecute(Sender: TObject);
var
  I, J: Integer;
  Flag: Boolean;
begin
  for I := 0 to lbAvail.Items.Count - 1 do
  begin
    Flag := True;
    for J := 0 to lbSelected.Items.Count - 1 do
    begin
      if lbSelected.Items.Objects[J] = lbAvail.Items.Objects[I] then
      begin
        Flag := False;
        break;
      end;
    end;
    if Flag then
    begin
      lbSelected.Items.AddObject(lbAvail.Items[I], lbAvail.Items.Objects[I]);
    end;
  end;
end;

procedure TframeBaseAnalitic.actExcludeExecute(Sender: TObject);
var
  I: Integer;
begin
  for I := lbSelected.Items.Count - 1 downto 0 do
  begin
    if lbSelected.Selected[I] then
      lbSelected.Items.Delete(I);
  end;
end;

procedure TframeBaseAnalitic.actExcludeUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lbSelected.ItemIndex > - 1;
end;

procedure TframeBaseAnalitic.actExcludeAllExecute(Sender: TObject);
begin
  lbSelected.Items.Clear;
end;

function TframeBaseAnalitic.GetAvail: TStrings;
begin
  Result := lbAvail.Items;
end;

function TframeBaseAnalitic.GetSelected: TStrings;
begin
  Result := lbSelected.Items;
end;

procedure TframeBaseAnalitic.lbAvailDblClick(Sender: TObject);
begin
  actInclude.Execute;
end;

procedure TframeBaseAnalitic.lbSelectedDblClick(Sender: TObject);
begin
  actExclude.Execute;
end;

function TframeBaseAnalitic.GetValues: string;
begin
  Result := '';
end;

procedure TframeBaseAnalitic.UpdateAvail(IdList: TList);
begin
  if Avail.Count = 0 then
    Selected.Clear;
end;

procedure TframeBaseAnalitic.SetValues(const Value: string);
begin

end;

procedure TframeBaseAnalitic.actIncludeUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := lbAvail.ItemIndex > - 1;
end;

procedure TframeBaseAnalitic.actIncludeAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Avail.Count > 0;
end;

procedure TframeBaseAnalitic.actExcludeAllUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := Selected.Count > 0;
end;

end.
