// ShlTanya, 17.02.2019

unit gsDBGrid_dlgColumnExpand;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, xSpin, StdCtrls, DB, DBGrids, gsDBGrid;

type
  TdlgColumnExpand = class(TForm)
    Panel2: TPanel;
    Panel1: TPanel;
    Label1: TLabel;
    lblColumn: TLabel;
    Label3: TLabel;
    cbColumn: TComboBox;
    cbLineCount: TCheckBox;
    editColumnLineCount: TxSpinEdit;
    Bevel1: TBevel;
    btnOk: TButton;
    Button1: TButton;
    btnHelp: TButton;
    procedure cbLineCountClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);

  private
    FColumns: TDBGridColumns; // Связь с источником данных для таблицы
    FExpand: TColumnExpand; // Элемент расширенного отображения
    FEdit: Boolean; // Редактирование или отображение
    FColumn: TColumn; // Поле, в котором будут отображаться данные

  public
    constructor Create(AnOwner: TComponent; Columns: TDBGridColumns; AColumn: TColumn;
      AnExpand: TColumnExpand; Edit: Boolean); reintroduce;
    destructor Destroy; override;

    function ShowModal: Integer; override;

  end;

var
  dlgColumnExpand: TdlgColumnExpand;

implementation

{$R *.DFM}

{
    --------------------------------------
    ----    TdlgColumnExpand Class    ----
    --------------------------------------
}

{
  *********************
  ***  Public Part  ***
  *********************
}

constructor TdlgColumnExpand.Create(AnOwner: TComponent; Columns: TDBGridColumns;
  AColumn: TColumn; AnExpand: TColumnExpand; Edit: Boolean);
begin
  inherited Create(AnOwner);

  FExpand := AnExpand;
  FColumns := Columns;
  FEdit := Edit;
  FColumn := AColumn;
end;

destructor TdlgColumnExpand.Destroy;
begin
  inherited Destroy;
end;

{
  Перед показом окна делаем свои установки.
}

function TdlgColumnExpand.ShowModal: Integer;
var
  I: Integer;
begin
  for I := 0 to FColumns.Count - 1 do
    cbColumn.Items.AddObject(FColumns[I].Title.Caption, FColumns[I]);

  lblColumn.Caption := FColumn.Title.Caption;

  editColumnLineCount.IntValue := FExpand.LineCount;
  cbLineCount.Checked := editColumnLineCount.IntValue > 1;
  editColumnLineCount.Enabled := cbLineCount.Checked;

  cbColumn.ItemIndex := -1;
  if FEdit then
  begin
    for I := 0 to cbColumn.Items.Count - 1 do
      if TColumn(cbColumn.Items.Objects[I]).FieldName = FExpand.FieldName then
      begin
        cbColumn.ItemIndex := I;
        break;
      end;
  end;

  Result := inherited ShowModal;

  if Result = mrOk then
  begin
    FExpand.FieldName := TColumn(cbColumn.Items.
      Objects[cbColumn.ItemIndex]).FieldName;

    if cbLineCount.Checked then
    begin
      FExpand.LineCount := editColumnLineCount.IntValue;

      if editColumnLineCount.IntValue > 1 then
        FExpand.Options := FExpand.Options + [ceoAddFieldMultiline];
    end else
      FExpand.LineCount := 1;
  end;
end;

{
  ************************
  ***  Protected Part  ***
  ************************
}

{
  **********************
  ***  Private Part  ***
  **********************
}

{
  *********************
  ***  Events Part  ***
  *********************
}


procedure TdlgColumnExpand.cbLineCountClick(Sender: TObject);
begin
  editColumnLineCount.Enabled := cbLineCount.Checked;
end;

procedure TdlgColumnExpand.btnOkClick(Sender: TObject);
begin
  if cbColumn.ItemIndex = -1 then
  begin
    ModalResult := mrNone;
    raise EgsDBgridException.Create('Choose Column');
  end;
end;

end.
