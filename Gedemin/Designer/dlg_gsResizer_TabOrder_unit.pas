// ShlTanya, 24.02.2019

{++
  Copyright (c) 2002-2014 by Golden Software of Belarus

  Module
    dlg_gsResizer_TabOrder_unit

  Abstract
    ƒиалог последовательности табул€ции дл€ gsResiser

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit dlg_gsResizer_TabOrder_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, gsResizerInterface;

type
  Tdlg_gsResizer_TabOrder = class(TForm)
    Bevel1: TBevel;
    lbControls: TListBox;
    btnControlUp: TSpeedButton;
    btnControlDown: TSpeedButton;
    btnOk: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    procedure btnControlUpClick(Sender: TObject);
    procedure btnControlDownClick(Sender: TObject);
    procedure lbControlsDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure lbControlsDragDrop(Sender, Source: TObject; X, Y: Integer);

  private
    FChanged: Boolean;
    FManager: IgsResizeManager;

  public
    constructor Create(AnOwner: TComponent); override;
    procedure ShowTabOrder(MainControl: TWinControl);
  end;

var
  dlg_gsResizer_TabOrder: Tdlg_gsResizer_TabOrder;

implementation

uses
  gsResizer, gsComponentEmulator;

{$R *.DFM}

{ Tdlg_gsResizer_TabOrder }

procedure Tdlg_gsResizer_TabOrder.ShowTabOrder(MainControl: TWinControl);
var
  I, J: Integer;
begin
  FChanged := False;
  lbControls.Items.Clear;

  for I := 0 to MainControl.ControlCount - 1 do
  begin
    if (MainControl.Controls[I].Name > '') and
       MainControl.Controls[I].InheritsFrom(TWinControl) and
       (not(MainControl.Controls[I] is TgsComponentEmulator))then
      lbControls.Items.AddObject(MainControl.Controls[I].Name + ': ' + MainControl.Controls[I].ClassName, MainControl.Controls[I]);
  end;

  for I := 0 to lbControls.Items.Count - 2 do
    for J := I + 1 to lbControls.Items.Count - 1 do
    begin
      if TWinControl(lbControls.Items.Objects[I]).TabOrder > TWinControl(lbControls.Items.Objects[J]).TabOrder then
        lbControls.Items.Move(J, I);
    end;

  if (ShowModal = mrOk) and FChanged then
  begin
    for I := 0 to lbControls.Items.Count - 1 do
    begin
      TWinControl(lbControls.Items.Objects[I]).TabOrder := I;
    end;
  end
end;

procedure Tdlg_gsResizer_TabOrder.btnControlUpClick(Sender: TObject);
var
  I: Integer;
begin
  I := lbControls.ItemIndex;
  if I <> 0 then
  begin
    lbControls.Items.Move(I, I - 1);
    lbControls.ItemIndex := I - 1;
    FChanged := True;
  end;
end;

procedure Tdlg_gsResizer_TabOrder.btnControlDownClick(Sender: TObject);
var
  I: Integer;
begin
  I := lbControls.ItemIndex;

  if I <> (lbControls.Items.Count - 1) then
  begin
    lbControls.Items.Move(I, I + 1);
    lbControls.ItemIndex := I + 1;
    FChanged := True;
  end;
end;

procedure Tdlg_gsResizer_TabOrder.lbControlsDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (Sender is TListBox) and (lbControls.ItemAtPos(Point(X, Y), False) <> lbControls.ItemIndex) then
    Accept := True
  else
    Accept := False;
end;

procedure Tdlg_gsResizer_TabOrder.lbControlsDragDrop(Sender,
  Source: TObject; X, Y: Integer);
var
  I: Integer;
begin
  if Sender is TListBox then
  begin
    I := lbControls.ItemAtPos(Point(X, Y), False);
    if I = lbControls.Items.Count then
      Dec(I);
    if I <> lbControls.ItemIndex then
    begin
      lbControls.Items.Move(lbControls.ItemIndex, I);
      lbControls.ItemIndex := I;
      FChanged := True;
    end;
  end;
end;

constructor Tdlg_gsResizer_TabOrder.Create(AnOwner: TComponent);
begin
  inherited;
  if AnOwner is TgsResizeManager then
    FManager := TgsResizeManager(AnOwner)
  else
    FManager := nil;
end;

end.
