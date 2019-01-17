// andreik, 15.01.2019


{++

   Copyright (c) 2000-2019 by Golden Software of Belarus, Ltd

   Модуль

     gdc_ab_frmmain_unit

   Описание

     Справочник контактов

   Автор

     Anton
     Julia

   История

     ver    date    who    what

     1.00 - 15.06.2001 - Anton - Первая версия
            01.03.2002   Julia

 --}

unit gdc_ab_frmmain_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, Menus, ComCtrls, ToolWin, gdc_frmMDV_unit, Grids,
  DBGrids, gsDBGrid, gsIBGrid, gsDBTreeView, flt_sqlFilter, ActnList,
  ExtCtrls, IBCustomDataSet, gdcBase, gdcContacts, gdc_frmMDVTree_unit,
  gsReportManager, gdcConst, ImgList, TB2Item, TB2Dock, TB2Toolbar, gdcTree,
  StdCtrls, gd_MacrosMenu;

type
  Tgdc_ab_frmmain = class(Tgdc_frmMDVTree)
    gdcContacts: TgdcBaseContact;
    actAddContact: TAction;
    actAddBank: TAction;
    actAddCompany: TAction;
    actAddGroup: TAction;
    actAddFolder: TAction;
    nAddCompany2: TMenuItem;
    nAddContact2: TMenuItem;
    nAddBank2: TMenuItem;
    ilSmall: TImageList;
    TBSubmenuItem2: TTBSubmenuItem;
    TBItem3: TTBItem;
    TBItem4: TTBItem;
    TBItem5: TTBItem;
    TBItem1: TTBItem;
    gdcFolder: TgdcFolder;
    TBItem2: TTBItem;
    actAddEmployee: TAction;
    TBSeparatorItem2: TTBSeparatorItem;
    TBSeparatorItem3: TTBSeparatorItem;
    TBSeparatorItem4: TTBSeparatorItem;
    procedure FormCreate(Sender: TObject);
    procedure actAddFolderExecute(Sender: TObject);
    procedure actAddContactExecute(Sender: TObject);
    procedure actAddBankExecute(Sender: TObject);
    procedure actAddCompanyExecute(Sender: TObject);
    procedure actAddGroupExecute(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actAddEmployeeExecute(Sender: TObject);

  protected
    procedure SetgdcDetailObject(const Value: TgdcBase); override;
  end;

var
  gdc_ab_frmmain: Tgdc_ab_frmmain;

implementation

{$R *.DFM}

uses
  gdcBaseInterface,  gd_ClassList;

procedure Tgdc_ab_frmmain.FormCreate(Sender: TObject);
begin
  gdcObject := gdcFolder;
  gdcDetailObject := gdcContacts;

  inherited;
end;

procedure Tgdc_ab_frmmain.SetgdcDetailObject(const Value: TgdcBase);
begin
  inherited;

  TBSubmenuItem2.Visible := False;
  tbiDetailNew.Visible := True;

  nDetailNew.Clear;
  nDetailNew.Action := actDetailNew;
end;

procedure Tgdc_ab_frmmain.actNewExecute(Sender: TObject);
begin
  gdcObject.CreateDialog(TgdcFolder);
end;

procedure Tgdc_ab_frmmain.actAddFolderExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

procedure Tgdc_ab_frmmain.actAddContactExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

procedure Tgdc_ab_frmmain.actAddBankExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

procedure Tgdc_ab_frmmain.actAddCompanyExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

procedure Tgdc_ab_frmmain.actAddGroupExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

procedure Tgdc_ab_frmmain.actAddEmployeeExecute(Sender: TObject);
begin
  // Не удалять!!! Нужен для поддержки dfm до наследования!!!
end;

initialization
  RegisterFrmClass(Tgdc_ab_frmmain);

finalization
  UnRegisterFrmClass(Tgdc_ab_frmmain);
end.


