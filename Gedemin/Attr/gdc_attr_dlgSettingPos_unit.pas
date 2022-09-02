// ShlTanya, 03.02.2019

unit gdc_attr_dlgSettingPos_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gdc_dlgG_unit, Menus, Db, ActnList, StdCtrls;

type
  Tgdc_dlgSettingPos = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lbxSettingType: TListBox;
    btnHelp: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);

  private
    FChooseObjectName: String;
    FObjectClassName: String;

  public
    constructor Create(AnOwner: TComponent); override;

    property ObjectClassName: String read FObjectClassName;
    property ChooseObjectName: String read FChooseObjectName;

  end;

var
  gdc_dlgSettingPos: Tgdc_dlgSettingPos;

implementation
type
  TSettingType = (stTable, stView, stField, stRelationField, stIndex, stTrigger,
    stException, stReport, stEvent, stMacros, stProcedure, stFilter,
    stScriptFunc, stDocument, stUserStorage);

const
  SettingType: array[TSettingType] of String = ('Таблица', 'Представление', 'Домен', 'Поле', 'Индекс', 'Триггер',
    'Исключение', 'Отчет', 'Событие', 'Макрос', 'Процедура', 'Фильтр',
    'Скрипт-функции', 'Документ', 'Хранилище пользователя');


{$R *.DFM}


procedure Tgdc_dlgSettingPos.FormCreate(Sender: TObject);
var
  Item: TSettingType;
begin
  lbxSettingType.Items.Clear;
  for Item := Low(SettingType) to High(SettingType) do
    lbxSettingType.Items.Add(SettingType[Item]);
  lbxSettingType.ItemIndex := 0;
end;

procedure Tgdc_dlgSettingPos.btnOkClick(Sender: TObject);
var
  Item: TSettingType;
begin
  if lbxSettingType.ItemIndex < 0 then
    lbxSettingType.ItemIndex := 0;

  for Item := Low(SettingType) to High(SettingType) do
    if lbxSettingType.Items[lbxSettingType.ItemIndex] = SettingType[Item] then
      Break;
  case Item of
    stTable: FObjectClassName := 'TgdcBaseTable';
    stView: FObjectClassName := 'TgdcView';
    stField: FObjectClassName := 'TgdcField';
    stRelationField:
    begin
      FObjectClassName := 'TgdcTableField';
      FChooseObjectName := 'gdcTableField';
    end;
    stIndex:
    begin
      FObjectClassName := 'TgdcIndex';
      FChooseObjectName := 'gdcIndex';
    end;
    stTrigger:
    begin
      FObjectClassName := 'TgdcTrigger';
      FChooseObjectName := 'gdcTrigger';
    end;
    stException: FObjectClassName := 'TgdcException';
    stReport:
    begin
      FObjectClassName := 'TgdcReport';
      FChooseObjectName := 'gdcReport';
    end;
    stEvent:
    begin
      FObjectClassName := 'TgdcEvent';
      FChooseObjectName := 'gdcEvent';
    end;
    stMacros: FObjectClassName := 'TgdcMacros';
    stProcedure: FObjectClassName := 'TgdcStoredProc';
    stScriptFunc:
    begin
      FObjectClassName := 'TgdcFunction';
      FChooseObjectName := 'gdcFunction';
    end;
    stFilter:
    begin
      FObjectClassName := 'TgdcSavedFilter';
      FChooseObjectName := 'gdcSavedFilter';
    end;
    stDocument:
    begin
      FObjectClassName := 'TgdcDocumentType';
      FChooseObjectName := 'gdcDocumentType';
    end;
    stUserStorage:
    begin
      FObjectClassName := 'TgdcUserStorage';
    end;
  end;

  ModalResult := mrOk;
end;

constructor Tgdc_dlgSettingPos.Create(AnOwner: TComponent);
begin
  inherited;
  FChooseObjectName := '';
  FObjectClassName := '';
end;

procedure Tgdc_dlgSettingPos.btnHelpClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
