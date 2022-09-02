// ShlTanya, 09.03.2019

unit gd_frmWindowsList_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gd_createable_form;

type
  Tgd_frmWindowsList = class(TCreateableForm)
    lb: TListBox;
    btnOk: TButton;
    btnClose: TButton;
    btnHelp: TButton;
    btnRefresh: TButton;
    Label1: TLabel;
    chbxHidden: TCheckBox;
    chbxName: TCheckBox;
    btnShow: TButton;
    btnHide: TButton;
    procedure btnOkClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure chbxHiddenClick(Sender: TObject);
    procedure btnShowClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);

  private
    procedure Refresh;

  public
    class function CreateAndAssign(AnOwner: TComponent): TForm; override;
  end;

var
  gd_frmWindowsList: Tgd_frmWindowsList;

implementation

{$R *.DFM}

{ Tgd_frmWindowsList }

class function Tgd_frmWindowsList.CreateAndAssign(
  AnOwner: TComponent): TForm;
begin
  if not FormAssigned(gd_frmWindowsList) then
    gd_frmWindowsList := Tgd_frmWindowsList.Create(AnOwner);

  Result := gd_frmWindowsList;
end;

procedure Tgd_frmWindowsList.btnOkClick(Sender: TObject);
var
  F: TForm;
begin
  if Assigned(lb.Items.Objects[lb.ItemIndex]) then
  begin
    F := lb.Items.Objects[lb.ItemIndex] as TForm;

    if F = Self then
      exit;

    ShowWindow(F.Handle, SW_SHOW);
    PostMessage(F.Handle, WM_SETFOCUS, 0, 0);
  end;

  Close;
end;

procedure Tgd_frmWindowsList.FormActivate(Sender: TObject);
begin
  Refresh;
end;

procedure Tgd_frmWindowsList.btnRefreshClick(Sender: TObject);
begin
  Refresh;
end;

procedure Tgd_frmWindowsList.Refresh;
var
  I: Integer;
  S: String;
begin
  S := '';
  lb.Items.Clear;
  for I := 0 to Screen.FormCount - 1 do
  begin
    if chbxName.Checked then
      S := ' - ' + Screen.Forms[I].Name + '/' + Screen.Forms[I].ClassName;
    if Screen.Forms[I].Visible then
      lb.Items.AddObject(Screen.Forms[I].Caption + S, Screen.Forms[I])
    else if chbxHidden.Checked then
      if Screen.Forms[I].Caption > '' then
        lb.Items.AddObject(Screen.Forms[I].Caption + S + ' (скрыта)', Screen.Forms[I])
      else
        lb.Items.AddObject(Screen.Forms[I].Name + '/' + Screen.Forms[I].ClassName + ' (скрыта)', Screen.Forms[I]);
  end;
  lb.ItemIndex := 0;

  ActiveControl := lb;
end;

procedure Tgd_frmWindowsList.chbxHiddenClick(Sender: TObject);
begin
  Refresh;
end;

procedure Tgd_frmWindowsList.btnShowClick(Sender: TObject);
var
  F: TForm;
begin
  if Assigned(lb.Items.Objects[lb.ItemIndex]) then
  begin
    F := lb.Items.Objects[lb.ItemIndex] as TForm;

    if F = Self then
      exit;

    ShowWindow(F.Handle, SW_SHOWNORMAL);
  end;
end;

procedure Tgd_frmWindowsList.btnHideClick(Sender: TObject);
var
  F: TForm;
begin
  if Assigned(lb.Items.Objects[lb.ItemIndex]) then
  begin
    F := lb.Items.Objects[lb.ItemIndex] as TForm;

    if F = Self then
      exit;

    ShowWindow(F.Handle, SW_HIDE);
  end;
end;

procedure Tgd_frmWindowsList.btnCloseClick(Sender: TObject);
begin
  Close;
end;

end.
