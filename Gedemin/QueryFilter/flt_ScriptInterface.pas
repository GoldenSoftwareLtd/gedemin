// ShlTanya, 10.03.2019

{++

  Copyright (c) 2000-2001 by Golden Software of Belarus

  Module

    flt_ScriptInterface_unit.pas

  Abstract

    Gedemin project. It is describing interfaces of Global variables:
    FilterScript, ParamGlobalDlg.

    FilterScript - uses for Script Params in TgsQueryFilter and
    for Script Params in ParamGlobalDlg in flt_dlg_dlgQueryParam_unit.pas

    ParamGlobalDlg - uses for Entered Params in Reports and Filters.

  Author

    Andrey Shadevsky

  Revisions history

    1.00    15.10.01    JKL        Initial version.

--}

unit flt_ScriptInterface;

interface

uses
  prm_ParamFunctions_unit, gdcBaseInterface;

const
  GD_PRM_REPORT         = 100;
  GD_PRM_SCRIPT_DLG     = 200;

type
  IFilterScript = interface
  ['{DECDB281-B987-11D5-B5E8-00C0DF0E09D1}']
    function Get_Object: TObject;
    function GetScriptResult(const AnScriptText, AnLanguage: String;
     out AnSign: String): Variant;
  end;

type
  IFilterEnterData = interface
  ['{5D46F401-BC95-11D5-B5EC-00C0DF0E09D1}']
    function Get_Object: TObject;
    procedure QueryParams(const AnFirstKey, AnSecondKey: TID;
     const AnParamList: TgsParamList; var AnResult: Boolean;
     const AShowDlg: Boolean = True;
     const AFormName: string = ''; const AFilterName: string = '');
    function IsEventAssigned: Boolean;
  end;

var
  FilterScript: IFilterScript;
  ParamGlobalDlg: IFilterEnterData;

implementation

initialization
  FilterScript := nil;
  ParamGlobalDlg := nil;

finalization
//  FilterScript := nil;
//  ParamGlobalDlg := nil;

end.

