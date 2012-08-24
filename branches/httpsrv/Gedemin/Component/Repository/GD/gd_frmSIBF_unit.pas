

{ single dataset, interbase, filters }

unit gd_frmSIBF_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmG_unit, Menus, flt_sqlFilter, Db, IBCustomDataSet, IBDatabase,
  ActnList,  ExtCtrls, ComCtrls, ToolWin, StdCtrls, Grids,
  DBGrids, gsDBGrid, gsIBGrid,  gsReportManager, gdcBase, gdcConst;

type
  Tgd_frmSIBF = class(Tgd_frmG)
    IBTransaction: TIBTransaction;
    ibdsMain: TIBDataSet;
    dsMain: TDataSource;
    gsQFMain: TgsQueryFilter;
    pmMainFilter: TPopupMenu;
    ibgrMain: TgsIBGrid;
    tbMainGrid: TToolBar;
    gsMainReportManager: TgsReportManager;
    procedure FormCreate(Sender: TObject);
    procedure gsQFMainFilterChanged(Sender: TObject;
      const AnCurrentFilter: Integer);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actFilterExecute(Sender: TObject);
    procedure ibgrMainKeyPress(Sender: TObject; var Key: Char);
    procedure ibgrMainDblClick(Sender: TObject);
    procedure ibgrMainCellClick(Column: TColumn);
    procedure ibgrMainTitleClick(Column: TColumn);

  protected
    FInGrid: Boolean;

    procedure InternalStartTransaction; virtual;
    procedure InternalOpenMain; virtual;

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;

  end;

var
  gd_frmSIBF: Tgd_frmSIBF;

implementation

{$R *.DFM}

uses
  Storages, gsDesktopManager
  {must be placed after Windows unit!}
  {$IFDEF LOCALIZATION}
    , gd_localization_stub
  {$ENDIF}
  ;

{ Tgd_frmSIBF }

procedure Tgd_frmSIBF.InternalOpenMain;
begin
  ibdsMain.Open;
end;

procedure Tgd_frmSIBF.InternalStartTransaction;
begin
  if not IBTransaction.InTransaction then
    IBTransaction.StartTransaction;
end;

procedure Tgd_frmSIBF.FormCreate(Sender: TObject);
begin
  inherited;
  InternalStartTransaction;
  InternalOpenMain;
end;

procedure Tgd_frmSIBF.gsQFMainFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
begin
  sbMain.SimpleText := 'Установлен фильтр: ' + gsQFMain.FilterName;
end;

procedure Tgd_frmSIBF.actDeleteUpdate(Sender: TObject);
begin
  actDelete.Enabled := lmDelete in ibdsMain.LiveMode;
end;

procedure Tgd_frmSIBF.actDeleteExecute(Sender: TObject);
begin
  if MessageBox(Handle,
    'Вы действительно желаете удалить текущую запись?',
    'Внимание',
    MB_YESNO or MB_ICONQUESTION) = IDYES then
  begin
    ibdsMain.Delete;
  end;
end;

procedure Tgd_frmSIBF.LoadSettings;
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.LoadComponent(ibgrMain, ibgrMain.LoadFromStream);
end;

procedure Tgd_frmSIBF.SaveSettings;
begin
  inherited;
  if Assigned(UserStorage) then
    UserStorage.SaveComponent(ibgrMain, ibgrMain.SaveToStream);
end;

procedure Tgd_frmSIBF.actFilterExecute(Sender: TObject);
begin
  gsQFMain.PopupMenu;
end;

procedure Tgd_frmSIBF.ibgrMainKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    actEdit.Execute;
end;

procedure Tgd_frmSIBF.ibgrMainDblClick(Sender: TObject);
begin
  if FInGrid then
  begin
    actEdit.Execute;
    FInGrid := False;
  end;
end;

procedure Tgd_frmSIBF.ibgrMainCellClick(Column: TColumn);
begin
  FInGrid := True;
end;

procedure Tgd_frmSIBF.ibgrMainTitleClick(Column: TColumn);
begin
  FInGrid := False;
end;

end.
