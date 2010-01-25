{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    gsIBGrid_dlgPictureDialog.pas

  Abstract

    Форма для просмотра загрузки и сохранения рисунка
    поле с рисунком присваевается в PictureField
    вызывается ShowPictureDialog

  Author

    Корначенко Николай (02-11-2001)

  Revisions history

    Initial  02-11-2001  Nick  Initial version.
--}
unit dlgPictureDialog_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtDlgs, ActnList, StdCtrls, ExtCtrls, Menus, db;

type
  TdlgPictureDialog = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    btnHelp: TButton;
    btnLoad: TButton;
    btnSave: TButton;
    btnClear: TButton;
    alPictureBox: TActionList;
    aHelp: TAction;
    aLoad: TAction;
    aSave: TAction;
    aClear: TAction;
    opdLoad: TOpenPictureDialog;
    spdSave: TSavePictureDialog;
    sbImage: TScrollBox;
    Image: TImage;
    pmImage: TPopupMenu;
    aStretch: TAction;
    aFullSize: TAction;
    N1: TMenuItem;
    N2: TMenuItem;
    lbEmpty: TLabel;

    procedure aLoadExecute(Sender: TObject);
    procedure aSaveExecute(Sender: TObject);
    procedure aClearExecute(Sender: TObject);
    procedure aStretchExecute(Sender: TObject);
    procedure aFullSizeExecute(Sender: TObject);
    procedure aLoadUpdate(Sender: TObject);
    procedure aSaveUpdate(Sender: TObject);

  private
    { Private declarations }
    FPictureField: TBlobField;

  public
    { Public declarations }
    property PictureField: TBlobField read FPictureField write FPictureField;
    procedure ShowPictureDialog;
    function Edit(Value: TBitmap): Boolean;
    function EditPicture(Value: TPicture): Boolean;
    function EditIcon(Value: TIcon): Boolean;
  end;

var
  dlgPictureDialog: TdlgPictureDialog;

implementation

{$R *.DFM}

procedure TdlgPictureDialog.aLoadExecute(Sender: TObject);
begin
  if opdLoad.Execute then
  begin
    lbEmpty.Visible := False;
    try
    Image.Picture.LoadFromFile(opdLoad.FileName);
    except
      aClearExecute(nil)
    end;
    Image.Align := alClient;
    if (Image.Picture.Height <= sbImage.ClientHeight) or
       (Image.Picture.Width <= sbImage.ClientWidth) then
      aFullSizeExecute(nil)
    else
      aStretchExecute(nil)

  end
end;

procedure TdlgPictureDialog.aSaveExecute(Sender: TObject);
begin
  if spdSave.Execute then
    Image.Picture.SaveToFile(spdSave.FileName);
end;

procedure TdlgPictureDialog.aClearExecute(Sender: TObject);
begin
  Image.Picture.Graphic := nil;
  lbEmpty.Visible := True;
end;

procedure TdlgPictureDialog.aStretchExecute(Sender: TObject);
begin
  Image.Align := alClient;
  Image.Stretch := True;
  aStretch.Checked := True;
  aFullSize.Checked := False;
end;

procedure TdlgPictureDialog.aFullSizeExecute(Sender: TObject);
begin

  if (Image.Picture.Height <= sbImage.ClientHeight) or
     (Image.Picture.Width <= sbImage.ClientWidth) then
  begin
    Image.Align := alClient;
  end
  else
  begin
    Image.Align := alNone;
    IMage.AutoSize := True;
  end;

  Image.Stretch := False;

  aStretch.Checked := False;
  aFullSize.Checked := True;

end;

procedure TdlgPictureDialog.ShowPictureDialog;
begin
  Assert(Assigned(FPictureField), 'Не указано поле базы данных');
  lbEmpty.Visible := True;
  Image.Align := alClient;
  if Assigned(FPictureField) then
  begin
    if not FPictureField.IsNull then
    begin
      lbEmpty.Visible := False;
      Image.Picture.Bitmap.Assign(FPictureField);
      if (Image.Picture.Height <= sbImage.ClientHeight) or
        (Image.Picture.Width <= sbImage.ClientWidth) then
        aFullSizeExecute(Nil)
      else
        aStretchExecute(Nil)
    end;
  end;

  if lbEmpty.Visible then
    aClearExecute(nil);

  if ShowModal = mrOk then
  begin
    if FPictureField.DataSet.CanModify then
    begin
      if not (FPictureField.DataSet.State in [dsEdit, dsInsert]) then
        FPictureField.DataSet.Edit;
      FPictureField.Assign(Image.Picture.Bitmap);
    end;
  end
end;

procedure TdlgPictureDialog.aLoadUpdate(Sender: TObject);
begin
  if Assigned(FPictureField) then
  begin
    (Sender As TAction).Enabled := FPictureField.DataSet.CanModify;
     aClear.Enabled := (not lbEmpty.Visible) and FPictureField.DataSet.CanModify;
  end
  else
  begin
    (Sender As TAction).Enabled := True;
     aClear.Enabled := (not lbEmpty.Visible);
  end;

end;

procedure TdlgPictureDialog.aSaveUpdate(Sender: TObject);
begin
  (Sender As TAction).Enabled := not lbEmpty.Visible;
  if Assigned(FPictureField) then
    aClear.Enabled := (not lbEmpty.Visible) and FPictureField.DataSet.CanModify
  else
    aClear.Enabled := (not lbEmpty.Visible);
end;

function TdlgPictureDialog.Edit(Value: TBitmap): Boolean;
begin
  Result := False;
  lbEmpty.Visible := True;
  Image.Align := alClient;

  if not Value.Empty then
  begin
    lbEmpty.Visible := False;
    Image.Picture.Bitmap.Assign(Value);
    if (Image.Picture.Height <= sbImage.ClientHeight) or
       (Image.Picture.Width <= sbImage.ClientWidth) then
      aFullSizeExecute(Nil)
    else
      aStretchExecute(Nil)
  end;

  if lbEmpty.Visible then
    aClearExecute(nil);

  if ShowModal = mrOk then
  begin
    if lbEmpty.Visible then
    begin
      Value.Width := 0;
      Value.Height := 0;
    end
    else
      Value.Assign(Image.Picture.Bitmap);
    Result := True;
  end

end;

function TdlgPictureDialog.EditPicture(Value: TPicture): Boolean;
begin
  Assert(Assigned(Value));

  Result := False;
  lbEmpty.Visible := True;
  Image.Align := alClient;

  if (Value.Graphic <> nil) and (not Value.Graphic.Empty) then
  begin
    lbEmpty.Visible := False;
    Image.Picture.Assign(Value);
    if (Image.Picture.Height <= sbImage.ClientHeight) or
       (Image.Picture.Width <= sbImage.ClientWidth) then
      aFullSizeExecute(Nil)
    else
      aStretchExecute(Nil)
 end;

  if lbEmpty.Visible then
    aClearExecute(nil);

  if ShowModal = mrOk then
  begin
    if lbEmpty.Visible then
    begin
      Value.Bitmap.Width := 0;
      Value.Bitmap.Height := 0;
    end
    else
    begin
      Value.Assign(Image.Picture)
    end;
    Result := True;
  end
end;

function TdlgPictureDialog.EditIcon(Value: TIcon): Boolean;
begin
  Result := False;
  lbEmpty.Visible := True;
  Image.Align := alClient;
  spdSave.Filter:= 'All (*.*)|*.*|ICO(*.ico)|*.ico';
  spdSave.DefaultExt:= 'ico';
  opdLoad.Filter:= 'All (*.*)|*.*|ICO(*.ico)|*.ico';
  opdLoad.DefaultExt:= 'ico';

  if not Value.Empty then
  begin
    lbEmpty.Visible := False;
    Image.Picture.Icon.Assign(Value);
    if (Image.Picture.Height <= sbImage.ClientHeight) or
       (Image.Picture.Width <= sbImage.ClientWidth) then
      aFullSizeExecute(Nil)
    else
      aStretchExecute(Nil)
  end;

  if lbEmpty.Visible then
    aClearExecute(nil);

  if ShowModal = mrOk then
  begin
    if lbEmpty.Visible then
    begin
//      Value.Assign(Image.Picture.Icon);
    end
    else
      Value.Assign(Image.Picture.Icon);
    Result := True;
  end

end;

end.
