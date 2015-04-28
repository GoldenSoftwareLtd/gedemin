unit xp_frmFKDropDown_unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, xp_frmDropDown_unit, Grids, DBGrids, DB, ExtCtrls, ActnList,
  Buttons, ComCtrls, SizePanel, xpDBGrid;

type
  TfrmFKDropDown = class(TfrmDropDown)
    pCaption: TPanel;
    DataSource: TDataSource;
    Panel1: TPanel;
    Grid: TxpDBGrid;
    SizePanel: TSizePanel;
    procedure SizePanelButtonClick(Sender: TObject);
    procedure GridDblClick(Sender: TObject);
    procedure GridKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FKeyField: string;
    procedure SetDataSet(const Value: TDataSet);
    function GetDataSet: TDataSet;
    procedure SetKeyField(const Value: string);
    { Private declarations }
  protected
    function GetInitBounds(ALeft, ATop, AWidth, AHeight: Integer; FirstTime: Boolean): TRect; override;
    function GetValue: Variant; override;
    procedure SetValue(const Value: Variant); override;
  public
    { Public declarations }
    property DataSet: TDataSet read GetDataSet write SetDataSet;
    property KeyField: string read FKeyField write SetKeyField;
  end;

var
  frmFKDropDown: TfrmFKDropDown;

implementation

{$R *.dfm}
{ TfrmFKDropDown }

function TfrmFKDropDown.GetDataSet: TDataSet;
begin
  Result := DataSource.DataSet;
end;

function TfrmFKDropDown.GetInitBounds(ALeft, ATop, AWidth,
  AHeight: Integer; FirstTime:Boolean): TRect;
const
  InitWidth = 400;
begin
  if FirstTime  then
    if InitWidth > AWidth then
      Result := Rect(0, 0 , InitWidth, Height)
    else
      Result := Rect(0, 0 , AWidth, Height)
  else
    Result := Rect(0, 0 , Width, Height);
end;

procedure TfrmFKDropDown.SetDataSet(const Value: TDataSet);
begin
  DataSource.DataSet := Value;
end;

procedure TfrmFKDropDown.SizePanelButtonClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmFKDropDown.GridDblClick(Sender: TObject);
begin
  ModalResult := mrOk

end;

function TfrmFKDropDown.GetValue: Variant;
begin
  Result := DataSet.FieldByName(KeyField).AsVariant;
end;

procedure TfrmFKDropDown.SetValue(const Value: Variant);
begin
  if not DataSet.Locate(keyField, VarArrayOf([Value]), []) then
    DataSet.First;
end;

procedure TfrmFKDropDown.SetKeyField(const Value: string);
begin
  FKeyField := Value;
end;

procedure TfrmFKDropDown.GridKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) and (Shift = []) then
  begin
    Key := 0;
    ModalResult := mrOk;
  end else
    inherited;
end;

end.
