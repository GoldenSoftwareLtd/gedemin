
{++

   Project gdcBaseClass
   Copyright c 2000-2001 by Golden Software

   Модуль

     gdc_ab_frmmain_unit

   Описание

     Главная форма

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
    ilSmall: TImageList;
    gdcFolder: TgdcFolder;
    actAddEmployee: TAction;
    procedure FormCreate(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
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

procedure Tgdc_ab_frmmain.actNewExecute(Sender: TObject);
begin
  gdcObject.CreateDialog(TgdcFolder);
end;

initialization
  RegisterFrmClass(Tgdc_ab_frmmain);

finalization
  UnRegisterFrmClass(Tgdc_ab_frmmain);
end.


