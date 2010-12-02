{++
   Project GDReference
   Copyright © 2000- by Golden Software

   Модуль

     dlgCurrRate_unit

   Описание

     Добавление курса валюты

   Автор

     Smirnov Anton
     

   История

     ver    date         who    what
     1.00 - 27.08.2000 - SAI - Первая версия
     2.00 - 18.06.2002 - Julie - Modification

 --}

unit gdc_dlgCurrRate_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, IBCustomDataSet, IBUpdateSQL, Db, IBQuery, ActnList,
  DBCtrls, xDateEdits, ExtCtrls, IBDatabase, gd_resourcestring,
  gsIBLookupComboBox, gdcBase, gdcCurr, Menus,
  gdc_dlgTR_unit, xCalculatorEdit;

type
  Tgdc_dlgCurrRate = class(Tgdc_dlgTR)
    Label1: TLabel;
    xdbForDate: TxDateDBEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    dbeCoeff: TxDBCalculatorEdit;
    dblcbFromCurr: TgsIBLookupComboBox;
    dblcbToCurr: TgsIBLookupComboBox;
  end;

var
  gdc_dlgCurrRate: Tgdc_dlgCurrRate;

implementation
uses
  gd_ClassList;

{$R *.DFM}

initialization
  RegisterFrmClass(Tgdc_dlgCurrRate);

finalization
  UnRegisterFrmClass(Tgdc_dlgCurrRate);

end.
