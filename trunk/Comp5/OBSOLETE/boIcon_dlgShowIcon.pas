
unit boIcon_dlgShowIcon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtDlgs, mBitButton, DBCtrls, StdCtrls, Mask, DB, DBTables, boObject;

type
  TdlgShowIcon = class(TForm)
    dbedName: TDBEdit;
    Label1: TLabel;
    dbimIcon: TDBImage;
    mbbLoad: TmBitButton;
    OpenPictureDialog: TOpenPictureDialog;
    mbbCancel: TmBitButton;
    mbbOk: TmBitButton;
    Label3: TLabel;
    DBEdit1: TDBEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    mbbSwitch: TmBitButton;
    dsIcon: TboDataSource;
    procedure mbbLoadClick(Sender: TObject);
    procedure mbbOkClick(Sender: TObject);
    procedure mbbCancelClick(Sender: TObject);
    procedure mbbSwitchClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgShowIcon: TdlgShowIcon;

implementation

{$R *.DFM}

procedure TdlgShowIcon.mbbLoadClick(Sender: TObject);
var
  F: TField;
  D: TDataSet;
begin
  if OpenPictureDialog.Execute then
  begin
    D := dsIcon.DataSet;

    if not (D.State in [dsEdit, dsInsert]) then
      D.Edit;

    F := D.FieldByName('data');
    (F as TBlobField).BlobType := ftGraphic;
    (F as TBlobField).LoadFromFile(OpenPictureDialog.FileName);

    D.FieldByName('width').AsInteger := dbimIcon.Picture.Width;
    D.FieldByName('height').AsInteger := dbimIcon.Picture.Height;
  end;
end;

procedure TdlgShowIcon.mbbOkClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TdlgShowIcon.mbbCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TdlgShowIcon.mbbSwitchClick(Sender: TObject);
begin
  if Height > 106 then
  begin
    dbimIcon.Visible := False;
    Height := 106;
    mbbSwitch.Caption := 'Показать';
  end else
  begin
    Height := 360;
    dbimIcon.Visible := True;
    mbbSwitch.Caption := 'Скрыть';
  end;
end;

end.

