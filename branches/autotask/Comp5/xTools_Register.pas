
{++

  Copyright (c) 1995-97 by Golden Software of Belarus

  Module

    xTools_Register.pas

  Abstract

    Here we register all the components of package
    xtools.


  Author

    Denis Romanovski (12-jul-2001)

  Contact address

    support@gsbelarus.com

  Revisions history


--}

unit xTools_Register;

interface

procedure Register;

implementation

uses Classes, DesignEditors, DesignIntF, Dialogs, Forms,
     AboutDlg, ColCB, FrmPlSvr, Credit, MLbutton, SplitBar,
     xBmpEff, xBulbLabel, xCalculatorEdit, xColorTabSet,
     xDBase, xDBTreeView, xfrmEfct, xHint, xLabel, xlcdlbl,
     xLglPad, xMemTable, xPanel, xRestr, xSStart, xStrList,
     xTable, xTrspBtn;

type
  TWaveFileProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

  TxListProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValueList(List: TStrings); virtual; abstract;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TxSortedListProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
  end;



{ TWaveFileProperty --------------------------------------}

procedure TWaveFileProperty.Edit;
var
  FileOpen: TOpenDialog;
begin
  FileOpen := TOpenDialog.Create(Application);
  FileOpen.Filename := GetValue;
  FileOpen.Filter := 'Wave files (*.wav)|*.WAV|All files (*.*)|*.*';
  FileOpen.Options := FileOpen.Options + [ofPathMustExist, ofFileMustExist];
  try
    if FileOpen.Execute then SetValue(FileOpen.Filename);
  finally
    FileOpen.Free;
  end;
end;

function TWaveFileProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;


{ TxListProperty and TxSortedListProperty-----------------}

function TxListProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paMultiSelect];
end;

procedure TxListProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
  Values: TStringList;
begin
  Values := TStringList.Create;
  try
    GetValueList(Values);
    for I := 0 to Values.Count - 1 do Proc(Values[I]);
  finally
    Values.Free;
  end;
end;

function TxSortedListProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList, paMultiSelect];
end;



{
  Осуществляем регистрацию комнонентов.
}

procedure Register;
begin
  { gsDlg }

  RegisterComponents('gsDlg', [TAboutDialog]);

  { gsVC }

  RegisterComponents('gsVC', [TColorComboBox]);
  RegisterComponents('gsVC', [TSplitBar]);
  RegisterComponents('gsVC', [TxCalculatorEdit]);
  RegisterComponents('gsVC', [TxColorTabSet]);
  RegisterComponents('gsVC', [TxLabel]);
  RegisterComponents('gsVC', [TxLCDLabel]);
  RegisterComponents('gsVC', [TxPanel]);

  { gsMisc }

  RegisterComponents('gsMisc', [TCredit]);
  RegisterComponents('gsMisc', [TxBitmapEffect]);
  RegisterComponents('gsMisc', [TxBitmapEffectEx]);
  RegisterComponents('gsMisk', [TxBulbLabel]);
  RegisterComponents('gsMisc', [TxLegalPad]);

  { gsNonVisual }

  RegisterComponents('gsNonVisual', [TFormPlaceSaver]);
  RegisterComponents('gsNonVisual', [TxFormEffect]);
  RegisterComponents('gsNonVisual', [TxHint]);
  RegisterComponents('gsNonVisual', [TxRestructTable]);
  RegisterComponents('gsNonVisual', [TxSafeStart]);
  RegisterComponents('gsNonVisual', [TxStrList]);

  { gsBtn }

  RegisterComponents('gsBtn', [TMLButton]);
  RegisterComponents('gsBtn', [TxTransSpeedButton]);
  RegisterComponents('gsBtn', [TxCalendarSpeedButton]);

  { gsDB }

  RegisterComponents('gsDB', [TxDBCalculatorEdit]);
  RegisterComponents('gsDB', [TxDatabase]);
  RegisterComponents('gsDB', [TxDBTreeView]);
  RegisterComponents('gsDB', [TxMemTable]);
  RegisterComponents('gsDB', [TxTable]);


  { Property editors }

  RegisterPropertyEditor(TypeInfo(String), TCredit, 'WaveFile',
    TWaveFileProperty);
end;

end.
