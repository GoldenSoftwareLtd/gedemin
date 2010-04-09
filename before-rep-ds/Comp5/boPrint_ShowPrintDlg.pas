unit boPrint_ShowPrintDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  mBitButton, ComCtrls, ActnList, StdCtrls, Mask, DBCtrls,
  Db, DBTables, boPrint, boObject, boIcon;

type
  TdlgShowPrint = class(TForm)
    pc: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    mBitButton1: TmBitButton;
    mBitButton2: TmBitButton;
    mBitButton3: TmBitButton;
    mBitButton4: TmBitButton;
    ActionList: TActionList;
    actNext: TAction;
    actPrev: TAction;
    stName: TStaticText;
    dbedName: TDBEdit;
    Query1: TQuery;
    UpdateSQL1: TUpdateSQL;
    StaticText3: TStaticText;
    boDataSource1: TboDataSource;
    boIcon1: TboIcon;
    procedure actNextUpdate(Sender: TObject);
    procedure actNextExecute(Sender: TObject);
    procedure actPrevUpdate(Sender: TObject);
    procedure actPrevExecute(Sender: TObject);

  protected
    FboPrint: TboPrint;

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgShowPrint: TdlgShowPrint;

implementation

{$R *.DFM}

procedure TdlgShowPrint.actNextUpdate(Sender: TObject);
begin
  actNext.Enabled := pc.ActivePageIndex < pc.PageCount;
end;

procedure TdlgShowPrint.actNextExecute(Sender: TObject);
begin
  pc.ActivePageIndex := pc.ActivePageIndex + 1;
end;

procedure TdlgShowPrint.actPrevUpdate(Sender: TObject);
begin
  actPrev.Enabled := pc.ActivePageIndex > 0;
end;

procedure TdlgShowPrint.actPrevExecute(Sender: TObject);
begin
  pc.ActivePageIndex := pc.ActivePageIndex - 1;
end;

end.
