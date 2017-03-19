unit prp_TemplateFrame_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  prp_BaseFrame_unit, ActnList, Menus, Db, StdCtrls, DBCtrls, ComCtrls,
  gsIBLookupComboBox, DBClient, IBQuery, IBCustomDataSet, gdcBase,
  gdcTemplate, rp_BaseReport_unit, ExtCtrls, SuperPageControl, Mask,
  prpDBComboBox, Buttons, StdActns, TB2Dock, TB2Item, TB2Toolbar,
  IBSQL, gdcBaseInterface, clipbrd;

type

  TTemplateFrame = class(TBaseFrame)
    gdcTemplate: TgdcTemplate;
    dsTemplate: TDataSource;
    ibqryTemplate: TIBQuery;
    dsTemplateType: TDataSource;
    cdsTemplateType: TClientDataSet;
    cdsTemplateTypeTemplateType: TStringField;
    cdsTemplateTypeDescriptionType: TStringField;
    actEditTemplate: TAction;
    actDeleteTemplate: TAction;
    Label22: TLabel;
    dblcbType: TDBLookupComboBox;
    TBToolbar1: TTBToolbar;
    TBItem1: TTBItem;
    TBItem2: TTBItem;
    actNewTemplate: TAction;
    TBSeparatorItem1: TTBSeparatorItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    lblRUIDTemplate: TLabel;
    edtRUIDTemplate: TEdit;
    pnlRUIDTemplate: TPanel;
    btnCopyRUIDTemplate: TButton;
    TBSeparatorItem2: TTBSeparatorItem;
    TBItem5: TTBItem;
    Memo1: TMemo;
    procedure actEditTemplateUpdate(Sender: TObject);
    procedure dblcbTypeCloseUp(Sender: TObject);
    procedure dblcbTypeDropDown(Sender: TObject);
    procedure actDeleteTemplateUpdate(Sender: TObject);
    procedure dbeNameDeleteRecord(Sender: TObject);
    procedure dblcbTypeClick(Sender: TObject);
    procedure gdcTemplateAfterOpen(DataSet: TDataSet);
    procedure actNewTemplateUpdate(Sender: TObject);
    procedure actClosePageExecute(Sender: TObject);
    procedure pMainResize(Sender: TObject);
    procedure gdcTemplateAfterEdit(DataSet: TDataSet);
    procedure btnCopyRUIDTemplateClick(Sender: TObject);
    procedure dbeNameExit(Sender: TObject);
  private
    FKeyValue: Variant;
    { Private declarations }
  protected
    function GetMasterObject: TgdcBase;override;
    procedure DoOnCreate; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  public
    { Public declarations }
    procedure Cancel; override;
  end;

var
  TemplateFrame: TTemplateFrame;

implementation

uses
  rp_report_const,
  gdcConstants,
  prp_MessageConst
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;
  
{$R *.DFM}

{ TTemplateFrame }

procedure TTemplateFrame.actEditTemplateUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := dblcbType.KeyValue <> NULL;
  dblcbType.Enabled := (gdcTemplate.State = dsInsert) or
    (dblcbType.KeyValue = NULL);
end;

procedure TTemplateFrame.Cancel;
begin
  gdcTemplate.Cancel;
end;

procedure TTemplateFrame.DoOnCreate;
begin
  inherited;

  cdsTemplateType.Close;
  cdsTemplateType.CreateDataSet;
  cdsTemplateType.AppendRecord([ReportFR, 'Шаблон FastReport']);
  cdsTemplateType.AppendRecord([ReportXFR, 'Шаблон xFastReport']);
  cdsTemplateType.AppendRecord([ReportGRD, 'Шаблон Grid']);
  {$IFDEF FR4}
  cdsTemplateType.AppendRecord([ReportFR4, 'Шаблон FastReport4']);
  {$ENDIF}
  FShowDeleteQuestion := False;
end;

function TTemplateFrame.GetMasterObject: TgdcBase;
begin
  Result := gdcTemplate;
end;


procedure TTemplateFrame.dblcbTypeCloseUp(Sender: TObject);
begin
  if dblcbType.KeyValue <> FKeyValue then
    gdcTemplate.FieldByName(fnTemplateData).Clear;

  inherited;
end;

procedure TTemplateFrame.dblcbTypeDropDown(Sender: TObject);
begin
  FKeyValue := dblcbType.KeyValue;
  inherited;
end;

procedure TTemplateFrame.actDeleteTemplateUpdate(Sender: TObject);
begin
  inherited;
  TAction(Sender).Enabled := gdcTemplate.State = dsEdit;
end;

procedure TTemplateFrame.AlignControls(AControl: TControl;
  var Rect: TRect);
begin
  inherited;
end;

procedure TTemplateFrame.dbeNameDeleteRecord(Sender: TObject);
begin
  actDeleteTemplate.Execute;
end;

procedure TTemplateFrame.dblcbTypeClick(Sender: TObject);
var
  Str: TStream;
begin
  inherited;
  Str := gdcTemplate.CreateBlobStream(gdcTemplate.FieldByName('templatedata'), bmRead);
  try
    if Str.Size > 0 then
    begin
      if MessageBox(Application.Handle,
        'Шаблон содержит данные которые будут потеряны'#13#10+
        'при измнении типа шаблона. Изменить тип шаблона?', MSG_WARNING,
        MB_YESNO or MB_ICONWARNING or MB_TASKMODAL) = IDYES then
      begin
        gdcTemplate.FieldByName('templatedata').Clear;
      end else
      begin
        dblcbType.KeyValue := FKeyValue;
      end;
    end;
  finally
    Str.Free;
  end;
  FKeyValue := dblcbType.KeyValue;
end;

procedure TTemplateFrame.gdcTemplateAfterOpen(DataSet: TDataSet);
begin
  inherited;
  MasterObject.BaseState := MasterObject.BaseState + [sDialog];
end;

procedure TTemplateFrame.actNewTemplateUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := gdcTemplate.State = dsEdit;
end;

procedure TTemplateFrame.actClosePageExecute(Sender: TObject);
begin
  (Owner as TBaseFrame).Close;
end;

procedure TTemplateFrame.pMainResize(Sender: TObject);
begin
  edtRUIDTemplate.Width:= pMain.ClientWidth - edtRUIDTemplate.Left - 87;
  pnlRUIDTemplate.Left:= edtRUIDTemplate.Left + edtRUIDTemplate.Width + 2;
  pnlRUIDTemplate.Width:= 75;
end;

procedure TTemplateFrame.gdcTemplateAfterEdit(DataSet: TDataSet);
begin
  edtRUIDTemplate.Text:= gdcBaseManager.GetRUIDStringByID(gdcTemplate.ID);
end;

procedure TTemplateFrame.btnCopyRUIDTemplateClick(Sender: TObject);
begin
  Clipboard.AsText:= edtRUIDTemplate.Text;
end;

procedure TTemplateFrame.dbeNameExit(Sender: TObject);
begin
  if Pos('.', TprpDBComboBox(Sender).Text) = 0 then
  begin
    MessageBox(0,
      PChar('Всегда указывайте префикс (пространство имен) при именовании шаблона.'#13#10#13#10 +
      'Например, "Склад.Торговля.Оборотная ведомость", а не "Оборотная ведомость".'),
      'Внимание',
      MB_OK or MB_ICONEXCLAMATION or MB_TASKMODAL);
  end;
end;

initialization
  RegisterClass(TTemplateFrame);
finalization
  UnRegisterClass(TTemplateFrame);

end.
