
{++

  Copyright (c) 1998-99 by Golden Software of Belarus

  Module

    mmLabel.pas

  Abstract

    Visual components associated with data sources!

  Author

    Smirnov Anton (1-11-98)

  Revisions history

    Initial  31-12-98  Anton   Initial version.

    Update   20-03-99  Dennis  Complitely remaking component. TmmFieldDataLink Class added.
    
--}

unit mmLabel;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, DB, DBCtrls, Menus, mBitButton, mmCheckBoxEx;

type
  TmmFieldDataLink = class(TFieldDataLink)
  protected
    procedure LayoutChanged; override;
  end;

type
  TmmLabel = class(TLabel)
  private
    FDataSource: TDataSource;
    FDataLink: TmmFieldDataLink;
    FDataField: String;
    OldCaption: String;

    FPopup: TPopupMenu;

    procedure SetDataSource(const Value: TDataSource);

    function GetPopup: TPopupMenu;
    procedure SetPopupMenu(const Value: TPopupMenu);

    procedure DoOnChange(Sender: TObject);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LayoutChanged;

  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property DataField: String read FDataField write FDataField;
    property PopupMenu: TPopupMenu read GetPopup write SetPopupMenu;

  end;

  TmmCheckBox = class(TmmCheckBoxEx)
  private
    FDataSource: TDataSource;
    FDataLink: TmmFieldDataLink;
    FDataField: String;
    OldCaption: String;

    FPopup: TPopupMenu;

    procedure SetDataSource(const Value: TDataSource);

    function GetPopup: TPopupMenu;
    procedure SetPopupMenu(const Value: TPopupMenu);

    procedure DoOnChange(Sender: TObject);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    procedure LayoutChanged;

  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property DataField: String read FDataField write FDataField;
    property PopupMenu: TPopupMenu read GetPopup write SetPopupMenu;

  end;

implementation

function AddPopupItem(P: TPopupMenu): TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  Result.Caption := '��������...';
  P.Items.Add(Result);
end;

{
  ++++++++++++++++++++++++++++++++++
  +++   TmmFieldDataLink Class   +++
  ++++++++++++++++++++++++++++++++++
}

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  �� ��������� ���������� ���������� ���� ���������� ���������� �� ���� �����.
  ���������!
}

procedure TmmFieldDataLink.LayoutChanged;
begin
  inherited LayoutChanged;
  if Control <> nil then
  begin
    if Control is TmmLabel then
      (Control as TmmLabel).LayoutChanged
    else if Control is TmmCheckBox then
      (Control as TmmCheckBox).LayoutChanged;
  end;
end;

{
  ++++++++++++++++++++++++++
  +++   TmmLabel Class   +++
  ++++++++++++++++++++++++++
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������ ��������� ���������.
}

constructor TmmLabel.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := nil;
  FPopup := nil;
  OldCaption := '';

  if not (csDesigning in ComponentState) then
  begin
    FDataLink := TmmFieldDataLink.Create;
    FDataLink.Control := Self;
  end;
end;

{
  ������������ ������.
}

destructor TmmLabel.Destroy;
begin
  if FDataLink <> nil then FDataLink.Free;

  inherited Destroy;
end;

{
  �� ��������� ���������� ���� ���������� ��������� � ����������.
}

procedure TmmLabel.LayoutChanged;
var
  F: TField;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
  begin
    F := FDataSource.DataSet.FindField(FDataField);
    if F <> nil then Caption := F.DisplayLabel;
  end else
    Caption := OldCaption;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  ��������� �� ����������� ��������� ������.
}

procedure TmmLabel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DataSource) then
    DataSource := nil;
end;

{
  ����� ������� ������� ��������� ������ caption.
}

procedure TmmLabel.Loaded;
begin
  inherited Loaded;
  OldCaption := Caption;

  if not (csDesigning in ComponentState) and (PopupMenu = nil) then
    PopupMenu := nil;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  ������������� ����� �������� ������.
}

procedure TmmLabel.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);

  if FDataLink <> nil then FDataLink.DataSource := FDataSource;
end;

{
  �������������� ����.
}

function TmmLabel.GetPopup: TPopupMenu;
begin
  Result := inherited PopupMenu;
end;

{
  ������������ ����.
}

procedure TmmLabel.SetPopupMenu(const Value: TPopupMenu);
begin
  inherited PopupMenu := Value;

  if FPopup <> nil then FPopup.Free;

  if not (csDesigning in ComponentState) then
  begin
    if PopupMenu = nil then
    begin
      FPopup := TPopupMenu.Create(Self);
      inherited PopupMenu := FPopup;
    end;

    AddPopupItem(PopupMenu).OnClick := DoOnChange;
  end;
end;

{
  ���������� ��������� ����.
}

procedure TmmLabel.DoOnChange(Sender: TObject);
var
  AskTitle: TForm;
  editTitle: TEdit;
  btnOk, btnCancel: TmBitButton;
  F: TField;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
    F := FDataSource.DataSet.FindField(FDataField)
  else
    F := nil;

  if F = nil then
    raise Exception.Create('������������ ���� �� �������!');

  AskTitle := TForm.Create(Owner);
  try
    AskTitle.Width := 300;
    AskTitle.Height := 80;
    AskTitle.Caption := '������������';
    AskTitle.BorderStyle := bsDialog;
    AskTitle.Position := poScreenCenter;

    AskTitle.Color := Self.Color;

    editTitle := TEdit.Create(Owner);
    editTitle.ParentCtl3D := False;
    editTitle.Ctl3D := False;
    editTitle.Left := 4;
    editTitle.Top := 4;
    editTitle.Width := 286;

    btnOk := TmBitButton.Create(Owner);
    btnOk.Left := 4;
    btnOk.Top := 30;
    btnOk.Width := 100;
    btnOk.Height := 20;
    btnOk.Caption := '&������';
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Owner);
    btnCancel.Left := 114;
    btnCancel.Top := 30;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := '&��������';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    AskTitle.InsertControl(editTitle);
    AskTitle.InsertControl(btnOk);
    AskTitle.InsertControl(btnCancel);

    editTitle.Text := F.DisplayLabel;

    if AskTitle.ShowModal = mrOk then
      F.DisplayLabel := editTitle.Text;
  finally
    AskTitle.Free;
  end;
end;

{
  +++++++++++++++++++++++++++++
  +++   TmmCheckBox Class   +++
  +++++++++++++++++++++++++++++
}

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  ������ ��������� ���������.
}

constructor TmmCheckBox.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  FDataLink := nil;
  OldCaption := '';
  FPopup := nil;

  if not (csDesigning in ComponentState) then
  begin
    FDataLink := TmmFieldDataLink.Create;
    FDataLink.Control := Self;
  end;
end;

{
  ������������ ������.
}

destructor TmmCheckBox.Destroy;
begin
  if FDataLink <> nil then FDataLink.Free;

  inherited Destroy;
end;

{
  ��������� � ����. ������� ���������� ��������.
}

procedure TmmCheckBox.LayoutChanged;
var
  F: TField;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
  begin
    F := FDataSource.DataSet.FindField(FDataField);
    if F <> nil then Caption := F.DisplayLabel;
  end else
    Caption := OldCaption;
end;

{
  **************************
  ***   Protected Part   ***
  **************************
}

{
  �� ����������� ��������� ������ ���������� ��������.
}

procedure TmmCheckBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = DataSource) then
    DataSource := nil;
end;

{
  ����� ������� ������� ��������� ������ caption.
}

procedure TmmCheckBox.Loaded;
begin
  inherited Loaded;
  OldCaption := Caption;

  if not (csDesigning in ComponentState) and (PopupMenu = nil) then
    PopupMenu := nil;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  ������������� �������� ������.
}

procedure TmmCheckBox.SetDataSource(const Value: TDataSource);
begin
  FDataSource := Value;
  if Value <> nil then
    Value.FreeNotification(Self);

  if FDataLink <> nil then FDataLink.DataSource := FDataSource;
end;

{
  �������������� ����.
}

function TmmCheckBox.GetPopup: TPopupMenu;
begin
  Result := inherited PopupMenu;
end;

{
  ������������ ����.
}

procedure TmmCheckBox.SetPopupMenu(const Value: TPopupMenu);
begin
  inherited PopupMenu := Value;

  if FPopup <> nil then FPopup.Free;

  if not (csDesigning in ComponentState) then
  begin
    if PopupMenu = nil then
    begin
      FPopup := TPopupMenu.Create(Self);
      inherited PopupMenu := FPopup;
    end;

    AddPopupItem(PopupMenu).OnClick := DoOnChange;
  end;
end;

{
  ���������� ��������� ����.
}

procedure TmmCheckBox.DoOnChange(Sender: TObject);
var
  AskTitle: TForm;
  editTitle: TEdit;
  btnOk, btnCancel: TmBitButton;
  F: TField;
begin
  if (FDataSource <> nil) and (FDataSource.DataSet <> nil) then
    F := FDataSource.DataSet.FindField(FDataField)
  else
    F := nil;

  if F = nil then
    raise Exception.Create('������������ ���� �� �������!');

  AskTitle := TForm.Create(Owner);
  try
    AskTitle.Width := 300;
    AskTitle.Height := 80;
    AskTitle.Caption := '������������';
    AskTitle.BorderStyle := bsDialog;
    AskTitle.Position := poScreenCenter;

    AskTitle.Color := Self.Color;

    editTitle := TEdit.Create(Owner);
    editTitle.ParentCtl3D := False;
    editTitle.Ctl3D := False;
    editTitle.Left := 4;
    editTitle.Top := 4;
    editTitle.Width := 286;

    btnOk := TmBitButton.Create(Owner);
    btnOk.Left := 4;
    btnOk.Top := 30;
    btnOk.Width := 100;
    btnOk.Height := 20;
    btnOk.Caption := '&������';
    btnOk.ModalResult := mrOk;
    btnOk.Default := True;

    btnCancel := TmBitButton.Create(Owner);
    btnCancel.Left := 114;
    btnCancel.Top := 30;
    btnCancel.Width := 100;
    btnCancel.Height := 20;
    btnCancel.Caption := '&��������';
    btnCancel.ModalResult := mrCancel;
    btnCancel.Cancel := True;

    AskTitle.InsertControl(editTitle);
    AskTitle.InsertControl(btnOk);
    AskTitle.InsertControl(btnCancel);

    editTitle.Text := F.DisplayLabel;

    if AskTitle.ShowModal = mrOk then
      F.DisplayLabel := editTitle.Text;
  finally
    AskTitle.Free;
  end;
end;

end.

