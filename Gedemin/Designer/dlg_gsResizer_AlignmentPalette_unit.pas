{++
  Copyright (c) 2002 by Golden Software of Belarus

  Module

    dlg_gsResizer_AlignmentPalette_unit

  Abstract

     Диалог выравнивания к gsResizer

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.
--}

unit dlg_gsResizer_AlignmentPalette_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ActnList, ImgList, gsResizerInterface;

type
  Tdlg_gsResizer_AlignmentPalette = class(TForm)
    ilAlignment: TImageList;
    alAlignment: TActionList;
    actAlignLeft: TAction;
    actAlignRight: TAction;
    actAlignTop: TAction;
    actAlignBottom: TAction;
    actAlignCenterVert: TAction;
    actAlignCenterHoriz: TAction;
    actCenterFormHoriz: TAction;
    actCenterFormVert: TAction;
    actSpaceEqualHoriz: TAction;
    actSpaceEqualVert: TAction;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    procedure actAlignLeftExecute(Sender: TObject);
    procedure actAlignRightExecute(Sender: TObject);
    procedure actAlignTopExecute(Sender: TObject);
    procedure actAlignBottomExecute(Sender: TObject);
    procedure actAlignCenterVertExecute(Sender: TObject);
    procedure actAlignCenterHorizExecute(Sender: TObject);
    procedure actCenterFormHorizExecute(Sender: TObject);
    procedure actCenterFormVertExecute(Sender: TObject);
    procedure actSpaceEqualHorizExecute(Sender: TObject);
    procedure actSpaceEqualVertExecute(Sender: TObject);
  private
    { Private declarations }
    FManager: IgsResizeManager;
    procedure SetAlignment(const AnAlignment: TPositionAlignment);
  public
    { Public declarations }
    constructor Create(AnOwner: TComponent); override;
  end;

var
  dlg_gsResizer_AlignmentPalette: Tdlg_gsResizer_AlignmentPalette;

implementation
uses gsResizer;
{$R *.DFM}

{ Tdlg_gsResizer_AlignmentPalette }

constructor Tdlg_gsResizer_AlignmentPalette.Create(AnOwner: TComponent);
begin
  inherited;
  if AnOwner is TgsResizeManager then
    FManager := TgsResizeManager(AnOwner)
  else
    FManager := nil;
end;

procedure Tdlg_gsResizer_AlignmentPalette.SetAlignment(
  const AnAlignment: TPositionAlignment);
begin
  if Assigned(FManager) then
    FManager.SetAlignment(AnAlignment);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignLeftExecute(
  Sender: TObject);
begin
  SetAlignment(paLeft);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignRightExecute(
  Sender: TObject);
begin
  SetAlignment(paRight);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignTopExecute(
  Sender: TObject);
begin
  SetAlignment(paTop);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignBottomExecute(
  Sender: TObject);
begin
  SetAlignment(paBottom);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignCenterVertExecute(
  Sender: TObject);
begin
  SetAlignment(paCenterVert);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actAlignCenterHorizExecute(
  Sender: TObject);
begin
  SetAlignment(paCenterHoriz);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actCenterFormHorizExecute(
  Sender: TObject);
begin
  SetAlignment(paCenterFormHoriz);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actCenterFormVertExecute(
  Sender: TObject);
begin
  SetAlignment(paCenterFormVert);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actSpaceEqualHorizExecute(
  Sender: TObject);
begin
  SetAlignment(paSpaceEqualHoriz);
end;

procedure Tdlg_gsResizer_AlignmentPalette.actSpaceEqualVertExecute(
  Sender: TObject);
begin
  SetAlignment(paSpaceEqualVert);
end;
end.

