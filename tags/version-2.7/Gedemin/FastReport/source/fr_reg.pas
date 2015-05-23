
{******************************************}
{                                          }
{             FastReport v2.53             }
{            Registration unit             }
{                                          }
{Copyright(c) 1998-2004 by FastReports Inc.}
{                                          }
{******************************************}


unit FR_reg;

interface

{$I FR.inc}

procedure Register;

implementation

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms
{$IFNDEF Delphi6}
, DsgnIntf
{$ELSE}
, DesignIntf, DesignEditors
{$ENDIF}
, Dialogs, FR_Class, FR_DSet, FR_DBSet,
  FR_OLE, FR_Rich, FR_ChBox, FR_Shape, FR_BarC, FR_RRect,
  FR_Desgn, FR_View, FR_Dock, FR_Ctrls, FR_Combo, FR_Utils, FR_Cross
{$IFDEF DATAMANAGER}
, FRD_Mngr, FR_DBOp
{$ENDIF}
, FR_E_TXT, FR_E_RTF, FR_E_CSV, FR_E_HTM, FR_Const, FR_PTabl, FR_DCtrl
{$IFNDEF Delphi3}
, frOLEExl
, frHTMExp
, frXMLExl
, frTXTExp
, frRtfExp
{$ENDIF}
, frexpimg, fr_e_html2_editors, fr_e_html2
{$IFNDEF Delphi2}
  {$IFDEF TeeChart}, FR_Chart {$ENDIF}
{$ENDIF}
  {$IFDEF RX}, FR_RxRTF {$ENDIF};

{-----------------------------------------------------------------------}
type
  TfrRepEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
    procedure DoDesign;
  end;

  TfrPrintTblEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): String; override;
    function GetVerbCount: Integer; override;
    procedure DoShow;
  end;

procedure TfrRepEditor.ExecuteVerb(Index: Integer);
begin
  DoDesign;
end;

function TfrRepEditor.GetVerb(Index: Integer): String;
begin
  Result := frLoadStr(SDesignReport);
end;

function TfrRepEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TfrRepEditor.DoDesign;
begin
  TfrReport(Component).DesignReport;
  if TfrReport(Component).StoreInDFM then
    if TfrReport(Component).ComponentModified then
      Designer.Modified;
end;

{----------------------------------------------------------------------------}
procedure TfrPrintTblEditor.ExecuteVerb(Index: Integer);
begin
  DoShow;
end;

function TfrPrintTblEditor.GetVerb(Index: Integer): String;
begin
  Result := frLoadStr(SPreview);
end;

function TfrPrintTblEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TfrPrintTblEditor.DoShow;
begin
  TfrCustomPrintDataSet(Component).ShowReport;
end;

{-----------------------------------------------------------------------}
procedure Register;
begin
  RegisterComponents('FastReport',
    [TfrReport, TfrCompositeReport, TfrDBDataSet, TfrUserDataset,
     TfrOLEObject, TfrRichObject, TfrCheckBoxObject,
     TfrShapeObject, TfrBarCodeObject,
{$IFNDEF Delphi2}
     {$IFDEF TeeChart} TfrChartObject, {$ENDIF}
{$ENDIF}
     {$IFDEF RX} TfrRxRichObject, {$ENDIF}
     TfrRoundRectObject, TfrCrossObject,
     TfrDesigner,
{$IFDEF DATAMANAGER}
     TfrDataStorage,
{$ENDIF}
     TfrPreview, TfrPrintTable,
     TfrPrintGrid,
     TfrDialogControls]);

  RegisterComponents('FastReport Exports', [TfrTextExport, TfrRTFExport,
     TfrCSVExport, TfrHTMExport, TfrHTML2Export
{$IFNDEF Delphi3}
     , TFrHTMLTableExport
     , TFrOLEExcelExport
     , TFrXMLExcelExport
     , TFrTextAdvExport  
     , TfrRtfAdvExport
{$ENDIF}
     , TfrBMPExport
{$IFDEF JPEG}
     , TfrJPEGExport
{$ENDIF}
     , TfrTIFFExport]);


  RegisterComponents('FastReport Tools',
    [TfrSpeedButton, TfrDock, TfrToolBar,
     TfrTBButton, TfrTBSeparator, TfrTBPanel,
     TfrComboEdit, TfrComboBox, TfrFontComboBox
{$IFDEF DATAMANAGER}
     , TfrOpenDBDialog
{$ENDIF}
    ]);

  RegisterPropertyEditor(TypeInfo(THNavigator), TfrHTML2Export, 'Navigator',
    THNavigatorProperty);


  RegisterComponentEditor(TfrReport, TfrRepEditor);
  RegisterComponentEditor(TfrPrintTable, TfrPrintTblEditor);
{$IFNDEF IBO}
  RegisterComponentEditor(TfrPrintGrid, TfrPrintTblEditor);
{$ENDIF}
end;

end.
