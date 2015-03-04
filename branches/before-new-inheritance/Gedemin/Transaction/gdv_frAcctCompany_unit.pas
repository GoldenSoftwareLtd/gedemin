unit gdv_frAcctCompany_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, gsIBLookupComboBox, ExtCtrls, gdvParamPanel, gdcBaseInterface,
  IBDatabase, gd_security, IBSQL, gd_common_functions, AcctUtils;

type
  TfrAcctCompany = class(TFrame)
    ppMain: TgdvParamPanel;
    cbAllCompanies: TCheckBox;
    lCompany: TLabel;
    iblCompany: TgsIBLookupComboBox;
    Transaction: TIBTransaction;
    procedure ppMainResize(Sender: TObject);
    procedure iblCompanyChange(Sender: TObject);

  private
    FHoldingList: string;
    function GetCompanyList: string;
    function GetCompanyKey: integer;
    procedure SetAllHoldingCompanies(const Value: boolean);
    function GetAllHoldingCompanies: boolean;
    procedure SetCompanyKey(const Value: integer);

  protected
    procedure Loaded; override;

  public
    constructor Create(AOwner: TComponent); override;

    procedure SaveToStream(const Stream: TStream);
    procedure LoadFromStream(const Stream: TStream);

    property CompanyList: string read GetCompanyList;
    property CompanyKey: integer read GetCompanyKey write SetCompanyKey;
    property AllHoldingCompanies: boolean read GetAllHoldingCompanies write SetAllHoldingCompanies;
  end;

implementation

{$R *.DFM}

constructor TfrAcctCompany.Create(AOwner: TComponent);
begin
  inherited;

  Transaction.DefaultDataBase := gdcBaseManager.Database;
  iblCompany.CurrentKeyInt := IbLogin.CompanyKey;
  cbAllCompanies.Checked := IbLogin.IsHolding;
end;

procedure TfrAcctCompany.ppMainResize(Sender: TObject);
begin
  SetBounds(Left, Top, ppMain.Width, ppMain.Height);
end;

function TfrAcctCompany.GetCompanyList: string;
begin
  Result := '';
  if (cbAllCompanies.Enabled and cbAllCompanies.Checked) or (iblCompany.CurrentKey = '') then
    Result := FHoldingList
  else
    Result := iblCompany.CurrentKey;
end;

procedure TfrAcctCompany.iblCompanyChange(Sender: TObject);
var
  SQL: TIBSQL;
begin
  Assert(gdcBaseManager <> nil);

  if iblCompany.CurrentKey = '' then
    FHoldingList := ''
  else begin
    if iblCompany.CurrentKeyInt = IBLogin.CompanyKey then
      FHoldingList := IBLogin.HoldingList
    else begin
      FHoldingList := iblCompany.CurrentKey;
      SQL := TIBSQL.Create(nil);
      try
        SQL.Transaction := gdcBaseManager.ReadTransaction;
        SQL.SQL.Text :=
          'SELECT LIST(companykey, '','') ' +
          'FROM gd_holding ' +
          'WHERE holdingkey = :holdingkey';
        SQL.ParamByName('holdingkey').AsInteger := iblCompany.CurrentKeyInt;
        SQL.ExecQuery;
        if not SQL.Eof then
          FHoldingList := FHoldingList + ',' + SQL.Fields[0].AsString;
      finally
        SQL.Free;
      end;
    end;
  end;

  if Pos(',', FHoldingList) > 0 then
  begin
    cbAllCompanies.Enabled := True;
    cbAllCompanies.Checked := True;
  end else
  begin
    cbAllCompanies.Enabled := False;
    cbAllCompanies.Checked := False;
  end;
end;

procedure TfrAcctCompany.Loaded;
begin
  inherited;
  iblCompany.Width := ppMain.ClientWidth - 5 - iblCompany.Left;
end;

procedure TfrAcctCompany.LoadFromStream(const Stream: TStream);
begin
  iblCompany.CurrentKey := ReadStringFromStream(Stream);
  cbAllCompanies.Checked := ReadBooleanFromStream(Stream);
end;

procedure TfrAcctCompany.SaveToStream(const Stream: TStream);
begin
  SaveStringToStream(iblCompany.CurrentKey, Stream);
  SaveBooleanToStream(cbAllCompanies.Checked, Stream);
end;

function TfrAcctCompany.GetCompanyKey: integer;
begin
  Result := iblCompany.CurrentKeyInt;
end;

procedure TfrAcctCompany.SetAllHoldingCompanies(const Value: boolean);
begin
  cbAllCompanies.Checked := Value;
end;

function TfrAcctCompany.GetAllHoldingCompanies: boolean;
begin
  Result := cbAllCompanies.Checked;
end;

procedure TfrAcctCompany.SetCompanyKey(const Value: integer);
begin
  iblCompany.CurrentKeyInt := Value
end;

end.
