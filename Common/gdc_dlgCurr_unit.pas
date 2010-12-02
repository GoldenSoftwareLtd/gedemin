{++
   Project GDReference
   Copyright � 2000- by Golden Software

   ������

     gdc_dlgCurr_unit

   ��������

     ���������� ������

   �����

     Smirnov Anton

   �������

     ver    date         who    what
     1.00 - 21.07.2000 - SAI - ������ ������

 --}


unit gdc_dlgCurr_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, StdCtrls, Mask, DBCtrls, ExtCtrls, ActnList,
  IBCustomDataSet, IBUpdateSQL, IBQuery, gd_security, gd_security_OperationConst,
  IBDatabase, gdc_dlgG_unit, Menus;

type
  Tgdc_dlgCurr = class(Tgdc_dlgG)
    mmlFullName: TLabel;
    mmlShortName: TLabel;
    mmlCode: TLabel;
    mmlSign: TLabel;
    mmlFullCentName: TLabel;
    mmlShortCentName: TLabel;
    mmlDecdigits: TLabel;
    mmlCentbase: TLabel;
    dbeFullName: TDBEdit;
    dbeShortName: TDBEdit;
    dbeCode: TDBEdit;
    dbeSign: TDBEdit;
    dbeFullCentName: TDBEdit;
    dbeShortCentName: TDBEdit;
    dbeDecdigits: TDBEdit;
    dbeCentbase: TDBEdit;
    Bevel1: TBevel;
    dbrgPlace: TDBRadioGroup;
    dbcbIsNCU: TDBCheckBox;
    dbcbDisabled: TDBCheckBox;
    dbcbEq: TDBCheckBox;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Label1: TLabel;
    dbeISO: TDBEdit;
    Bevel4: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    dbeName_0: TDBEdit;
    dbeName_1: TDBEdit;
    Label5: TLabel;
    Bevel5: TBevel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    dbeCentName_0: TDBEdit;
    dbeCentName_2: TDBEdit;
    Bevel6: TBevel;
    Memo1: TMemo;
  end;

var
  gdc_dlgCurr: Tgdc_dlgCurr;

implementation
{$R *.DFM}

uses
  dmDataBase_unit, gd_ClassList;

initialization
  RegisterFrmClass(Tgdc_dlgCurr);

finalization
  UnRegisterFrmClass(Tgdc_dlgCurr);

end.
