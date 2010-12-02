unit MainForm4_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IBDatabase, Db, IBCustomDataSet, IBQuery, flt_sqlFilter, Menus, Grids,
  DBGrids, StdCtrls, prm_ParamFunctions_unit, flt_ScriptInterface_body;

type
  TForm1 = class(TForm)
    IBDatabase1: TIBDatabase;
    IBQuery1: TIBQuery;
    IBTransaction1: TIBTransaction;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    PopupMenu1: TPopupMenu;
    gsQueryFilter1: TgsQueryFilter;
    Button1: TButton;
    fltGlobalScript1: TfltGlobalScript;
    prmGlobalDlg1: TprmGlobalDlg;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure prmGlobalDlg1DlgCreate(const AnFirstKey,
      AnSecondKey: Integer; const AnParamList: TgsParamList;
      var AnResult: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  flt_dlg_dlgQueryParam_unit;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  IBDatabase1.Connected := True;
  IBTransaction1.StartTransaction; 
  IBQuery1.Open;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  gsQueryFilter1.PopupMenu;
end;

procedure TForm1.prmGlobalDlg1DlgCreate(const AnFirstKey,
  AnSecondKey: Integer; const AnParamList: TgsParamList;
  var AnResult: Boolean);
var
  FDlgForm: TdlgQueryParam;
begin
  FDlgForm := TdlgQueryParam.Create(nil);
  try
    FDlgForm.FDatabase := IBDatabase1;
    FDlgForm.FTransaction := IBTransaction1;
    AnResult := FDlgForm.QueryParams(AnParamList);
  finally
    FDlgForm.Free;
  end;
end;

end.
