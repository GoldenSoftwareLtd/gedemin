unit gdv_frAcctAnalyticsGroup_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, gdvParamPanel, StdCtrls, ActnList, CheckLst, contnrs, IBSQL,
  gdcBaseInterface, AcctUtils, at_classes, gdv_AvailAnalytics_unit, AcctStrings,
  gd_common_functions, gdv_frAcctBaseAnalyticGroup;

type
  TfrAcctAnalyticsGroup = class(TfrAcctBaseAnalyticsGroup)
    ppMain: TgdvParamPanel;
    pClient: TPanel;
    bAvail: TBevel;
    lbAvail: TListBox;
    bIncludeAll: TButton;
    bExclude: TButton;
    bExcludeAll: TButton;
    bSelected: TBevel;
    bInclude: TButton;
    lAvail: TLabel;
    lSelected: TLabel;
    bUp: TButton;
    bDown: TButton;
    lbSelected: TCheckListBox;
    procedure pClientResize(Sender: TObject);
    procedure ppMainResize(Sender: TObject);
    procedure lbSelectedClickCheck(Sender: TObject);
  private
    { Private declarations }

    procedure ppMainAlignControls;
  protected
    procedure Loaded; override;
    function ListBoxSelected: TCheckListBox; override;
    function ListBoxAvail: TListBox; override;
  public
    { Public declarations }
    procedure SaveToStream(Stream: TStream);override;
    procedure LoadFromStream(Stream: TStream);override;
  end;

implementation

{$R *.DFM}

procedure TfrAcctAnalyticsGroup.pClientResize(Sender: TObject);
begin
  SetBounds(Left, Top, ppMain.Width, ppMain.Height);
end;

procedure TfrAcctAnalyticsGroup.ppMainResize(Sender: TObject);
begin
  ppMainAlignControls;
end;

procedure TfrAcctAnalyticsGroup.ppMainAlignControls;
var
  R: TRect;
  W, L: Integer;
begin
  SetBounds(Left, Top, ppMain.Width, ppMain.Height);
  R := pClient.ClientRect;
  W := R.Right - R.Left;
  bAvail.Left := 6;
  ListBoxAvail.Width := (W - bInclude.Width - (6 + 4) * 2) div 2;
  L := bAvail.Left + ListBoxAvail.Width + 4;
  bInclude.Left := L;
  bIncludeAll.Left := L;
  bExclude.Left := L;
  bExcludeAll.Left := L;
  L := 6 + bInclude.Width + bInclude.Left;
  ListBoxSelected.Left := L;
  ListBoxSelected.Width := ListBoxAvail.Width;
  bAvail.Left := ListBoxAvail.Left - 2;
  bAvail.Width := ListBoxAvail.Width + 4;
  bSelected.Left := ListBoxSelected.Left - 2;
  bSelected.Width := ListBoxSelected.Width + 4;

  bUp.Left := bSelected.Left;
  bUp.Width := (bSelected.Width - 2) div 2;
  L := bUp.Left + bUp.Width + 2;
  bDown.Left := L;
  bDown.Width := bUp.Width;

  lAvail.Left := bAvail.Left;
  lSelected.Left := bSelected.Left;
end;

procedure TfrAcctAnalyticsGroup.Loaded;
begin
  inherited;
  ppMainAlignControls;
end;

procedure TfrAcctAnalyticsGroup.LoadFromStream(Stream: TStream);
begin
  inherited;
end;

procedure TfrAcctAnalyticsGroup.SaveToStream(Stream: TStream);
begin
  inherited;
end;

function TfrAcctAnalyticsGroup.ListBoxAvail: TListBox;
begin
  Result := lbAvail;
end;

function TfrAcctAnalyticsGroup.ListBoxSelected: TCheckListBox;
begin
  Result := lbSelected;
end;


procedure TfrAcctAnalyticsGroup.lbSelectedClickCheck(Sender: TObject);
begin
  SelectedFieldListClear
end;

end.
