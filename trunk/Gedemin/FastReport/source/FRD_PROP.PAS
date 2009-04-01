
{******************************************}
{                                          }
{     FastReport v2.5 - Data storage       }
{       Object properties dialog           }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}

unit FRD_Prop;

interface

{$I FR.inc}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, DBCtrls, DB;

type
  TfrPropForm = class(TForm)
    FontB: TButton;
    Button2: TButton;
    Button3: TButton;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    CaptionE: TEdit;
    LookupGroup: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    DatasetCB: TComboBox;
    KeyCB: TComboBox;
    ListCB: TComboBox;
    KindGroup: TGroupBox;
    EditRB: TRadioButton;
    ComboRB: TRadioButton;
    LookupRB: TRadioButton;
    ComboGroup: TGroupBox;
    ComboStrings: TMemo;
    CB1: TCheckBox;
    procedure FontBClick(Sender: TObject);
    procedure DatasetCBClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure EditRBClick(Sender: TObject);
    procedure ComboRBClick(Sender: TObject);
    procedure LookupRBClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CB1Click(Sender: TObject);
  private
    { Private declarations }
    Lookup: TDBLookupComboBox;
    QueryOwner: TComponent;
    CB1Modified: Boolean;
    procedure ChangeControl(e: TControl);
  public
    { Public declarations }
  end;

implementation

uses FRD_Mngr, FRD_Form, FR_Const, FR_Utils;

{$R *.DFM}

type
  THackControl = class(TControl)
  end;

var
  Busy: Boolean;

procedure TfrPropForm.FormShow(Sender: TObject);
var
  c: TControl;
begin
  c := SelList[0];
  Busy := True;
  if SelList.Count = 1 then
  begin
    CaptionE.Text := THackControl(c).Text;
    EditRB.Checked := c is TEdit;
    ComboRB.Checked := c is TComboBox;
    LookupRB.Checked := c is TDBLookupComboBox;
  end;

  if (c is TLabel) or (SelList.Count > 1) then
    frEnableControls([EditRB, ComboRB, LookupRB], False);
  CB1.Visible := c is TLabel;
  CB1.Checked := CB1.Visible and (SelList.Count = 1) and TLabel(c).AutoSize;
  CB1Modified := False;

  CaptionE.SelectAll;
  CaptionE.Modified := False;
  if LookupRB.Checked then
  begin
    DatasetCB.Text := GetDataSetName(QueryOwner, Lookup.ListSource);
    DatasetCBCLick(nil);
    KeyCB.Text := Lookup.KeyField;
    ListCB.Text := Lookup.ListField;
  end
  else if ComboRB.Checked then
    ComboStrings.Lines.Assign((c as TComboBox).Items);
  Busy := False;
end;

procedure TfrPropForm.FormHide(Sender: TObject);
var
  i: Integer;
  c: TControl;
begin
  c := SelList[0];
  if ModalResult = mrOk then
  begin
    if LookupRB.Checked then
    begin
      Lookup.ListSource :=
        GetDataSource(frFindComponent(QueryOwner, DatasetCB.Text) as TDataset);
      Lookup.KeyField := KeyCB.Text;
      Lookup.ListField := ListCB.Text;
    end
    else if ComboRB.Checked then
      (c as TComboBox).Items.Assign(ComboStrings.Lines);
    if CaptionE.Modified then
      for i := 0 to SelList.Count - 1 do
        THackControl(SelList[i]).Text := CaptionE.Text;
    if CB1Modified then
      for i := 0 to SelList.Count - 1 do
        if TControl(SelList[i]) is TLabel then
        begin
          TLabel(SelList[i]).AutoSize := CB1.Checked;
          TLabel(SelList[i]).WordWrap := not CB1.Checked;
        end;
  end;
end;

procedure TfrPropForm.FontBClick(Sender: TObject);
var
  i: Integer;
begin
  with FontDialog1 do
  begin
    Font := THackControl(SelList[0]).Font;
    if Execute then
      for i := 0 to SelList.Count - 1 do
        THackControl(SelList[i]).Font := Font;
  end;
end;

procedure TfrPropForm.DatasetCBClick(Sender: TObject);
var
  d: TDataset;
begin
  d := frFindComponent(QueryOwner, DatasetCB.Text) as TDataset;
  if d <> nil then
  begin
    d.GetFieldNames(ListCB.Items);
    KeyCB.Items.Assign(ListCB.Items);
  end
  else
  begin
    ListCB.Items.Clear;
    KeyCB.Items.Clear;
    ListCB.Text := '';
    KeyCB.Text := '';
  end;
end;

procedure TfrPropForm.ChangeControl(e: TControl);
var
  c: TControl;
begin
  c := SelList[0];
  with THackControl(e) do
  begin
    Parent := c.Parent;
    SetBounds(c.Left, c.Top, c.Width, c.Height);
    Font.Assign(THackControl(c).Font);
    Tag := c.Tag;
    Cursor := crArrow;
    ControlStyle := [csClickEvents, csDoubleClicks];
  end;
  SelList[0] := e;
  c.Free;
end;

procedure TfrPropForm.EditRBClick(Sender: TObject);
begin
  Height := 190;
  Button2.Top := 134; Button3.Top := 134;
  ComboGroup.Hide;
  LookupGroup.Hide;
  if Busy then Exit;
  ChangeControl(TfrDesignEdit.Create(TControl(SelList[0]).Owner));
end;

procedure TfrPropForm.ComboRBClick(Sender: TObject);
begin
  Height := 300;
  Button2.Top := 246; Button3.Top := 246;
  ComboGroup.Show;
  LookupGroup.Hide;
  if Busy then Exit;
  ChangeControl(TfrDesignCombo.Create(TControl(SelList[0]).Owner));
  TComboBox(SelList[0]).Style := csOwnerDrawFixed;
end;

procedure TfrPropForm.LookupRBClick(Sender: TObject);
begin
  Height := 300;
  Button2.Top := 246; Button3.Top := 246;
  LookupGroup.Show;
  ComboGroup.Hide;
  Lookup := SelList[0];
  QueryOwner := PfrParamInfo(frParamList[Lookup.Tag])^.QueryRef.Owner;
  if Busy then Exit;
  ChangeControl(TfrDesignLookup.Create(Lookup.Owner));
  Lookup := SelList[0];
  QueryOwner := PfrParamInfo(frParamList[Lookup.Tag])^.QueryRef.Owner;
  frGetComponents(QueryOwner, TDataset, DatasetCB.Items, nil);
  DatasetCBClick(nil);
end;

procedure TfrPropForm.FormCreate(Sender: TObject);
begin
  Caption := frLoadStr(frRes + 3170);
  Label1.Caption := frLoadStr(frRes + 3171);
  FontB.Caption := frLoadStr(frRes + 3172);
  LookupGroup.Caption := frLoadStr(frRes + 3173);
  Label2.Caption := frLoadStr(frRes + 3174);
  Label3.Caption := frLoadStr(frRes + 3175);
  Label4.Caption := frLoadStr(frRes + 3176);
  KindGroup.Caption := frLoadStr(frRes + 3177);
  EditRB.Caption := frLoadStr(frRes + 3178);
  ComboRB.Caption := frLoadStr(frRes + 3179);
  LookupRB.Caption := frLoadStr(frRes + 3180);
  ComboGroup.Caption := frLoadStr(frRes + 3181);
  CB1.Caption := frLoadStr(frRes + 3182);
  Button2.Caption := frLoadStr(SOk);
  Button3.Caption := frLoadStr(SCancel);
end;

procedure TfrPropForm.CB1Click(Sender: TObject);
begin
  CB1Modified := True;
end;

end.

