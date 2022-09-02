// ShlTanya, 24.02.2019

{++

  Copyright (c) 2002-2014 by Golden Software of Belarus

  Module

    dlg_gsResizer_SetSize_unit

  Abstract

    Диалог выравнивания размеров для gsResizer

  Author

    Kornachenko Nikolai (nkornachenko@yahoo.com) (17-01-2002)

  Revisions history

    Initial  17-01-2002  Nick  Initial version.

--}

unit dlg_gsResizer_SetSize_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ActnList, ToolWin, ImgList, gsResizerInterface;

type
  Tdlg_gsResizer_SetSize = class(TForm)
    ilSize: TImageList;
    alSize: TActionList;
    ToolBar1: TToolBar;
    actGrowHoriz: TAction;
    actGrowVert: TAction;
    actGrowBoth: TAction;
    actShrinkHoriz: TAction;
    actShrinkVert: TAction;
    actShrinkBoth: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    procedure actGrowVertExecute(Sender: TObject);
    procedure actGrowBothExecute(Sender: TObject);
    procedure actShrinkHorizExecute(Sender: TObject);
    procedure actShrinkVertExecute(Sender: TObject);
    procedure actShrinkBothExecute(Sender: TObject);
    procedure actGrowHorizExecute(Sender: TObject);

  private
    FManager: IgsResizeManager;

    procedure SetControlSize(const ASizeType: TSizeChanger);

  public
    constructor Create(AnOwner: TComponent); override;
  end;

var
  dlg_gsResizer_SetSize: Tdlg_gsResizer_SetSize;

implementation

uses
  gsResizer;

{$R *.DFM}

{ Tdlg_gsResizer_SetSize }

constructor Tdlg_gsResizer_SetSize.Create(AnOwner: TComponent);
begin
  inherited;
  if AnOwner is TgsResizeManager then
    FManager := TgsResizeManager(AnOwner)
  else
    FManager := nil;
end;

procedure Tdlg_gsResizer_SetSize.SetControlSize(
  const ASizeType: TSizeChanger);
begin
  if Assigned(FManager) then
    FManager.SetControlSize(ASizeType)
end;

procedure Tdlg_gsResizer_SetSize.actGrowHorizExecute(Sender: TObject);
begin
  SetControlSize(scGrowHoriz);
end;

procedure Tdlg_gsResizer_SetSize.actGrowVertExecute(Sender: TObject);
begin
  SetControlSize(scGrowVert);
end;

procedure Tdlg_gsResizer_SetSize.actGrowBothExecute(Sender: TObject);
begin
  SetControlSize(scGrowBoth);
end;

procedure Tdlg_gsResizer_SetSize.actShrinkHorizExecute(Sender: TObject);
begin
  SetControlSize(scShrinkHoriz);
end;

procedure Tdlg_gsResizer_SetSize.actShrinkVertExecute(Sender: TObject);
begin
  SetControlSize(scShrinkVert);
end;

procedure Tdlg_gsResizer_SetSize.actShrinkBothExecute(Sender: TObject);
begin
  SetControlSize(scShrinkBoth);
end;

end.
