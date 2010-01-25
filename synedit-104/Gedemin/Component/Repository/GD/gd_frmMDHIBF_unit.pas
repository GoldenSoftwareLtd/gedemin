

{ MasterDetail Horz layout IB datasets used IBGrids used Filters used }


unit gd_frmMDHIBF_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gd_frmSIBF_unit,  ActnList, ComCtrls, ToolWin, ExtCtrls,
  Grids, DBGrids, gsDBGrid, gsIBGrid, Db, IBCustomDataSet, IBDatabase,
  flt_sqlFilter, dmDatabase_unit, Menus, StdCtrls, DBClient, 
  dmImages_unit, gsReportManager, gdcBase, gdcConst;

type
  Tgd_frmMDHIBF = class(Tgd_frmSIBF)
    ibdsDetails: TIBDataSet;
    dsDetail: TDataSource;
    gsQFDetail: TgsQueryFilter;
    pmDetailFilter: TPopupMenu;
    Splitter: TSplitter;
    pnlDetails: TPanel;
    ibgrDetails: TgsIBGrid;
    cbDetails: TControlBar;
    tbDetails: TToolBar;
    tbtDetailNew: TToolButton;
    tbtDetailEdit: TToolButton;
    tbtDetailDelete: TToolButton;
    tbtDetailDuplicate: TToolButton;
    tbtDetailFilter: TToolButton;
    tbDetailGrid: TToolBar;
    actDetailNew: TAction;
    actDetailEdit: TAction;
    actDetailDelete: TAction;
    actDetailDuplicate: TAction;
    actDetailFilter: TAction;
    actDetailPrint: TAction;
    tbtDetailPrint: TToolButton;
    DetailReportManager: TgsReportManager;
    pmDetailReport: TPopupMenu;
    procedure FormCreate(Sender: TObject);
    procedure actDetailFilterExecute(Sender: TObject);
    procedure actDetailNewUpdate(Sender: TObject);
    procedure gsQFMainFilterChanged(Sender: TObject;
      const AnCurrentFilter: Integer);
    procedure actDetailPrintExecute(Sender: TObject);

  private
    procedure InternalOpenDetail; virtual;

  public
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

var
  gd_frmMDHIBF: Tgd_frmMDHIBF;

implementation

{$R *.DFM}

uses
  gsStorage_CompPath, Storages;

procedure Tgd_frmMDHIBF.InternalOpenDetail;
begin
  ibdsDetails.Open;
end;

procedure Tgd_frmMDHIBF.FormCreate(Sender: TObject);
begin
  inherited;
  InternalOpenDetail;
end;

procedure Tgd_frmMDHIBF.actDetailFilterExecute(Sender: TObject);
begin
  gsQFDetail.PopupMenu;
end;

procedure Tgd_frmMDHIBF.LoadSettings;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.LoadComponent(ibgrDetails, ibgrDetails.LoadFromStream);
    pnlMain.Height := UserStorage.ReadInteger(BuildComponentPath(Self), 'MainHeight', pnlMain.Height);
  end;  
end;

procedure Tgd_frmMDHIBF.SaveSettings;
begin
  inherited;
  if Assigned(UserStorage) then
  begin
    UserStorage.WriteInteger(BuildComponentPath(Self), 'MainHeight', pnlMain.Height);
    UserStorage.SaveComponent(ibgrDetails, ibgrDetails.SaveToStream);
  end;  
end;

procedure Tgd_frmMDHIBF.actDetailNewUpdate(Sender: TObject);
begin
  Enabled := ibdsMain.Active;// and (ibdsMain.RecordCount > 0);// and (not (ibdsMain.EOF and ibdsMain.BOF));
end;

procedure Tgd_frmMDHIBF.gsQFMainFilterChanged(Sender: TObject;
  const AnCurrentFilter: Integer);
begin
  sbMain.SimpleText := gsQFMain.FilterName + ', ' + gsQFDetail.FilterName;
end;

procedure Tgd_frmMDHIBF.actDetailPrintExecute(Sender: TObject);
begin
  //...
end;

end.
