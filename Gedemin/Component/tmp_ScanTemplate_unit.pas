// ShlTanya, 20.02.2019

unit tmp_ScanTemplate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, Grids, DBGrids, StdCtrls, ExtCtrls, Buttons, gsTextTemplate_unit,
  ActnList, gd_createable_form;

type
  Ttmp_ScanTemplate = class(TCreateableForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Label1: TLabel;
    cbAreas: TComboBox;
    dbgrAreaFields: TDBGrid;
    cbTables: TComboBox;
    dbgrTableFields: TDBGrid;
    OpenDialog: TOpenDialog;
    dsFields: TDataSource;
    dsRecords: TDataSource;
    edTemplate: TEdit;
    edDocument: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    sbtnTemplate: TSpeedButton;
    sbtnDocument: TSpeedButton;
    Label4: TLabel;
    btnScan: TButton;
    alScanTemplate: TActionList;
    actScanTemplate: TAction;
    procedure sbtnTemplateClick(Sender: TObject);
    procedure sbtnDocumentClick(Sender: TObject);
    procedure cbAreasChange(Sender: TObject);
    procedure cbTablesChange(Sender: TObject);
    procedure actScanTemplateUpdate(Sender: TObject);
    procedure actScanTemplateExecute(Sender: TObject);

  private
    Converter: TgsTextConverter;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  tmp_ScanTemplate: Ttmp_ScanTemplate;

implementation


{$R *.DFM}

procedure Ttmp_ScanTemplate.sbtnTemplateClick(Sender: TObject);
begin
  OpenDialog.FileName := edTemplate.Text;
  OpenDialog.Filter := 'Все файлы (*.*)|*.*';
  OpenDialog.Title := 'Открытие файла шаблона';
  if OpenDialog.Execute then
  begin
    edTemplate.Text := OpenDialog.FileName;
  end;
end;

procedure Ttmp_ScanTemplate.sbtnDocumentClick(Sender: TObject);
begin
  OpenDialog.FileName := edDocument.Text;
  OpenDialog.Filter := 'Все файлы (*.*)|*.*';
  OpenDialog.Title := 'Открытие файла документа';
  if OpenDialog.Execute then
  begin
    edDocument.Text := OpenDialog.FileName;
  end;
end;

constructor Ttmp_ScanTemplate.Create(AOwner: TComponent);
begin
  inherited;
  Converter := TgsTextConverter.Create;
  UseDesigner := False;
  ShowSpeedButton := True;
end;

destructor Ttmp_ScanTemplate.Destroy;
begin
  Converter.Free;
  inherited;
end;

procedure Ttmp_ScanTemplate.cbAreasChange(Sender: TObject);
var
  I: Integer;
begin
  cbTables.Items.Clear;
  if cbAreas.Items.Count > 0 then
  begin
    dsFields.DataSet := Converter.Database.Areas[cbAreas.ItemIndex].AreaFields;
    for i := 0 to Converter.Database.Areas[cbAreas.ItemIndex].TableCount - 1 do
      cbTables.Items.Add(Converter.Database.Areas[cbAreas.ItemIndex].Tables[I].Name);
  end
  else
    dsFields.DataSet := nil;

  cbTables.ItemIndex := 0;
  cbTablesChange(Self)

end;

procedure Ttmp_ScanTemplate.cbTablesChange(Sender: TObject);
begin
  if cbTables.Items.Count > 0 then
    dsRecords.DataSet := Converter.Database.Areas[cbAreas.ItemIndex].Tables[cbTables.ItemIndex].Records
  else
    dsRecords.DataSet := nil;
end;

procedure Ttmp_ScanTemplate.actScanTemplateUpdate(Sender: TObject);
begin
  actScanTemplate.Enabled := (Trim(edTemplate.Text) > '') and (Trim(edDocument.Text) > '');
end;

procedure Ttmp_ScanTemplate.actScanTemplateExecute(Sender: TObject);
  var
  i: Integer;
begin
  Converter.LoadFromTempFile(Trim(edTemplate.Text));
  Converter.StartConvert(Trim(edDocument.Text));
  cbAreas.Items.Clear;

  for i := 0 to Converter.Database.AreasCount - 1 do
    cbAreas.Items.Add(Converter.Database.Areas[I].Name);

  cbAreas.ItemIndex := 0;
  cbAreasChange(Self);

end;

end.
