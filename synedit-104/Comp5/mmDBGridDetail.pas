
{++

  Copyright (c) 1999 by Golden Software of Belarus

  Module

    mmDBGridCondition.pas

  Abstract

    A part of a visual component mmDBGrid.
    Common grid options setup.

  Author

    Romanovski Denis (05-03-99)

  Revisions history

    Initial  05-03-99  Dennis  Initial version.

    Beta1    20-03-99  Dennis  Some bugs fixed.
--}

unit mmDBGridDetail;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, CheckLst, xYellabl, mBitButton, mmDBGrid, gsMultilingualSupport;

type
  TfrmDetail = class(TForm)
    clbFields: TCheckListBox;
    btnOk: TmBitButton;
    btnCancel: TmBitButton;
    gbDisplayFormat: TGroupBox;
    lblFormat: TLabel;
    edFormat: TEdit;
    xylDisplayFormat: TxYellowLabel;
    lblDisplayIn: TLabel;
    lblFieldName: TLabel;
    Label1: TLabel;
    edFieldFormat: TEdit;
    gsMultilingualSupport1: TgsMultilingualSupport;

    procedure btnOkClick(Sender: TObject);
    procedure clbFieldsClick(Sender: TObject);

  private
    FGrid: TmmDBGrid; // Таблица, из которой берем детальное отображение
    FDetailField: String; // Поле, в котором отображаем детальность
    FDetails: TStringList; // Поля-детали отображения

    Formats: TStringList; // Список форматов детального отображения
    OldIndex: Integer; // Индекс ранее выделенного элемента полей детального отображения

    procedure SetGrid(const Value: TmmDBGrid);
    procedure SetDetails(const Value: TStringList);

  public
    constructor Create(AnOwner: TComponent); override;
    destructor Destroy; override;

    property Grid: TmmDBGrid write SetGrid;
    property DetailField: String read FDetailField write FDetailField;
    property Details: TStringList read FDetails write SetDetails;

  end;

var
  frmDetail: TfrmDetail;

implementation

{$R *.DFM}

uses DB;

{
  ***********************
  ***   Public Part   ***
  ***********************
}

{
  Делаем начальные установки.
}

constructor TfrmDetail.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);

  Formats := TStringList.Create;

  OldIndex := -1;
  FGrid := nil;
  FDetails := nil;
end;

{
  Высвобождаем память.
}

destructor TfrmDetail.Destroy;
begin
  Formats.Free;
  
  inherited Destroy;
end;

{
  ************************
  ***   Private Part   ***
  ************************
}

{
  Устанавливаем таблицу детального отображения.
}

procedure TfrmDetail.SetGrid(const Value: TmmDBGrid);
begin
  FGrid := Value;

  Color := FGrid.ColorDialogs;
end;

{
  Устанавливаем детали отображения.
}

procedure TfrmDetail.SetDetails(const Value: TStringList);
var
  I, K: Integer;
  Fmt: String;

  // Содержится ли данное поле в деталях
  function IsInDetails(AField: String; var DetailFormat: String): Boolean;
  var
    K: Integer;
  begin
    Result := False;
    DetailFormat := '';

    for K := 0 to FDetails.Count - 1 do
      // Если поле содержит формат
      if (Pos('%s', FDetails[K]) > 0) and
        (AnsiCompareText(Copy(FDetails[K], 1, Pos(' ', FDetails[K]) - 1), AField) = 0) then
      begin
        DetailFormat := Copy(FDetails[K], Pos(' ', FDetails[K]) + 1,  Length(FDetails[K]));
        Result := True;
        Break;
      // Если оно не содержит формат
      end else if AnsiCompareText(FDetails[K], AField) = 0 then
      begin
        Result := True;
        Break;
      end;
  end;

begin
  FDetails := Value;

  if (FGrid <> nil) and (FDetailField <> '') then
  begin
    for I := 0 to FGrid.DataSource.DataSet.Fields.Count - 1 do
      if not (FGrid.DataSource.DataSet.Fields[I].DataType in [ftUnknown, ftBCD,
        ftBytes, ftVarBytes, ftBlob, ftMemo, ftGraphic,
        ftFmtMemo, ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor,
        ftADT, ftArray, ftReference, ftDataSet]) then
      begin
        clbFields.Items.Add(FGrid.DataSource.DataSet.Fields[I].DisplayLabel);
        clbFields.Items.Objects[clbFields.Items.Count - 1] := Pointer(I);

        if IsInDetails(FGrid.DataSource.DataSet.Fields[I].FieldName, Fmt) then
          clbFields.State[clbFields.Items.Count - 1] := cbChecked;

        Formats.Add(Fmt);
      end;

    lblFieldName.Caption := FGrid.DataSource.DataSet.FieldByName(FDetailField).DisplayLabel;

    if FDetails.Count > 0 then
    begin
      K := Pos('format ', FDetails[0]);
      if K > 0 then edFieldFormat.Text := Copy(FDetails[0], K + 7, Length(FDetails[0]));
    end;
  end;
end;

{
  По нажатию кноки Ok производим щзапись деталей обратно.
}

procedure TfrmDetail.btnOkClick(Sender: TObject);
var
  I: Integer;
begin
  // Проверяем корректность ввода информации

  if (Length(edFieldFormat.Text) > 0) and (Pos('%s', edFieldFormat.Text) = 0) then
  begin
    clbFields.ItemIndex := OldIndex;
    edFieldFormat.SetFocus;
    ModalResult := mrNone;
    raise Exception.Create('Строка не содержит "%s"!');
  end;

  if OldIndex <> -1 then
  begin
    if (Length(edFormat.Text) > 0) and (Pos('%s', edFormat.Text) = 0) then
    begin
      clbFields.ItemIndex := OldIndex;
      edFormat.SetFocus;
      ModalResult := mrNone;
      raise Exception.Create('Строка не содержит "%s"!');
    end;

    Formats[OldIndex] := edFormat.Text;
  end;

  // Удаляем старые данные
  Details.Clear;

  // Сохраняем новые данные
  if edFieldFormat.Text <> '' then
    Details.Add('format ' + edFieldFormat.Text);

  for I := 0 to clbFields.Items.Count - 1 do
    if clbFields.State[I] = cbChecked then
    begin
      if Length(Formats[I]) > 0 then
        Details.Add(FGrid.DataSource.DataSet.Fields[Integer(clbFields.Items.Objects[I])].FieldName + ' ' +
          Formats[I])
      else
        Details.Add(FGrid.DataSource.DataSet.Fields[Integer(clbFields.Items.Objects[I])].FieldName);
    end;
end;

{
  По выбору элемента в списке полей производим
  добавление текста в edFormat.
}

procedure TfrmDetail.clbFieldsClick(Sender: TObject);
begin
  // Сохраняем введенный формат
  if OldIndex <> -1 then
  begin
    if (Length(edFormat.Text) > 0) and (Pos('%s', edFormat.Text) = 0) then
    begin
      clbFields.ItemIndex := OldIndex;
      edFormat.SetFocus;
      raise Exception.Create('Строка не содержит "%s"!');
    end;

    Formats[OldIndex] := edFormat.Text;
  end;

  // Вставляем новый формат
  edFormat.Text := Formats[clbFields.ItemIndex];

  OldIndex := clbFields.ItemIndex;
end;

end.
