unit dlg_gsResizer_Components_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  PClassPalette = ^TClassPalette;
  TClassPalette = Record
    ClassType: TPersistentClass;
    FolderName: String;
  end;

  TClassPaletteArray = array of PClassPalette;

  Tdlg_gsResizer_Components = class(TForm)
    pnlTop: TPanel;
    lbl1: TLabel;
    edName: TEdit;
    lbComponents: TListBox;
    pnlBottom: TPanel;
    pnlBottomRight: TPanel;
    btnAdd: TButton;
    btnClose: TButton;
    procedure edNameChange(Sender: TObject);
    procedure lbComponentsDblClick(Sender: TObject);
    procedure edNameKeyPress(Sender: TObject; var Key: Char);
    procedure btnAddClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
    FEditForm: TCustomForm;
    function FindString(const S: String): Integer;
    function GetNewClassName: TPersistentClass;
    procedure InsertNew;
  public
    { Public declarations }
    constructor Create(Owner: TComponent; CompList: TClassPaletteArray; EditForm: TCustomForm); reintroduce;
    property NewControlClass: TPersistentClass read GetNewClassName;
  end;

var
  dlg_gsResizer_Components: Tdlg_gsResizer_Components;

implementation
uses gsResizerInterface;
{$R *.DFM}

{ Tdlg_gsResizer_Components }

constructor Tdlg_gsResizer_Components.Create(Owner: TComponent;
  CompList: TClassPaletteArray; EditForm: TCustomForm);
var
  I: Integer;
begin
  inherited Create(Owner);
  FEditForm := EditForm;
  for I := Low(CompList) to High(CompList) do
    lbComponents.Items.Add(CompList[I]^.ClassType.ClassName);
end;

function Tdlg_gsResizer_Components.FindString(const S: String): Integer;
var
  I: Integer;
  ST: String;
begin
  I := Length(S);
  ST := AnsiUpperCase(S);
  Result := -1;
  if I = 0 then
    Exit;

  for Result := 0 to lbComponents.Items.Count - 1 do
  begin
    if ST = AnsiUpperCase(Copy(lbComponents.Items[Result], 0, I)) then
      Exit;
  end;
  Result := -1;
end;

procedure Tdlg_gsResizer_Components.edNameChange(Sender: TObject);
begin
 lbComponents.ItemIndex := FindString(edName.TExt);
end;

function Tdlg_gsResizer_Components.GetNewClassName: TPersistentClass;
begin
  if lbComponents.ItemIndex > -1 then
    Result := GetClass(lbComponents.Items[lbComponents.ItemIndex])
  else
    Result := nil;
end;

procedure Tdlg_gsResizer_Components.lbComponentsDblClick(Sender: TObject);
begin
  InsertNew;
end;

procedure Tdlg_gsResizer_Components.edNameKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    InsertNew;
    Key := #0;
  end
end;

procedure Tdlg_gsResizer_Components.InsertNew;
begin
  if Assigned(FEditForm) and (lbComponents.ItemIndex > -1)then
  begin
    SendMessage(FEditForm.Handle, CM_INSERTNEW2, 0, 0);
    Self.SetFocus;
  end;
end;

procedure Tdlg_gsResizer_Components.btnAddClick(Sender: TObject);
begin
  InsertNew;
end;

procedure Tdlg_gsResizer_Components.btnCloseClick(Sender: TObject);
begin
  Self.Close;
end;

end.
