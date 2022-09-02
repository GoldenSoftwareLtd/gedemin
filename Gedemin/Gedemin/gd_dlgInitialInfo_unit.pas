// ShlTanya, 08.03.2019

unit gd_dlgInitialInfo_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ActnList, IBDatabase, gsIBLookupComboBox, gdcContacts, Db,
  IBCustomDataSet, gdcBase, gdcTree, IBSQL, gdcUser, ExtCtrls;

type
  Tgd_dlgInitialInfo = class(TForm)
    btnOk: TButton;
    Post: TActionList;
    actOk: TAction;
    gbCompany: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    edName: TEdit;
    edPhone: TEdit;
    edTaxID: TEdit;
    cbCountry: TComboBox;
    edZIP: TEdit;
    edArea: TEdit;
    edCity: TEdit;
    edAddress: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    edDirector: TEdit;
    edAccountant: TEdit;
    gbBank: TGroupBox;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label21: TLabel;
    iblkupCurr: TgsIBLookupComboBox;
    ibTr: TIBTransaction;
    gbLogin: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    edBankName: TEdit;
    edBankCode: TEdit;
    edAccount: TEdit;
    edBankArea: TEdit;
    edBankCity: TEdit;
    edBankAddress: TEdit;
    cbBankCountry: TComboBox;
    edUser: TEdit;
    edLogin: TEdit;
    edPassword: TEdit;
    edPassword2: TEdit;
    Label24: TLabel;
    edBankZIP: TEdit;
    btnCancel: TButton;
    actCancel: TAction;
    gdcEmployee: TgdcEmployee;
    q: TIBSQL;
    Label25: TLabel;
    edDistrict: TEdit;
    gdcFolder: TgdcFolder;
    gdcDepartment: TgdcDepartment;
    gdcUser: TgdcUser;
    gdcBank: TgdcBank;
    Label26: TLabel;
    edBankDistrict: TEdit;
    gdcCompany: TgdcOurCompany;
    Label27: TLabel;
    edBranch: TEdit;
    gdcAccount: TgdcAccount;
    pnlInfo: TPanel;
    Label20: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    edLicence: TEdit;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label33: TLabel;
    ibtrLookup: TIBTransaction;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actOkUpdate(Sender: TObject);
    procedure edNameDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

var
  gd_dlgInitialInfo: Tgd_dlgInitialInfo;

implementation

{$R *.DFM}

uses
  AcctUtils, gd_security, gd_common_functions, gdcBaseInterface;

procedure Tgd_dlgInitialInfo.actOkExecute(Sender: TObject);

  procedure SetFieldValue(F: TField; const V: String; const Def: String);
  begin
    if Trim(V) = '' then
      F.AsString := Def
    else
      F.AsString := Copy(V, 1, F.Size);
  end;

var
  UserID, AccID: TID;
  SL: TStringList;
begin
  ibtr.StartTransaction;
  try
    SL := TStringList.Create;
    try
      q.Close;
      q.SQL.Text := 'SELECT id FROM gd_place WHERE UPPER(name) = :N ' +
        'AND placetype = ''Страна'' ';
      q.ParamByName('N').AsString := AnsiUpperCase(cbCountry.Text);
      q.ExecQuery;

      gdcCompany.Open;
      gdcCompany.Insert;
      SetTID(gdcCompany.FieldByName('parent'), 650001);
      SetFieldValue(gdcCompany.FieldByName('name'), edName.Text, '<Название не указано>');
      gdcCompany.FieldByName('fullname').AsString := gdcCompany.FieldByName('name').AsString;
      SetFieldValue(gdcCompany.FieldByName('phone'), edPhone.Text, '<Номер не указан>');
      SetFieldValue(gdcCompany.FieldByName('taxid'), edTaxID.Text, '<УНП не указан>');
      if not q.EOF then
        SetTID(gdcCompany.FieldByName('placekey'), q.FieldByName('id'));
      SetFieldValue(gdcCompany.FieldByName('zip'), edZip.Text, '<Индекс не указан>');
      SetFieldValue(gdcCompany.FieldByName('country'), cbCountry.Text, '<Не указано>');
      SetFieldValue(gdcCompany.FieldByName('district'), edDistrict.Text, '<Не указано>');
      SetFieldValue(gdcCompany.FieldByName('region'), edArea.Text, '<Не указано>');
      SetFieldValue(gdcCompany.FieldByName('city'), edCity.Text, '<Не указано>');
      SetFieldValue(gdcCompany.FieldByName('address'), edAddress.Text, '<Адрес не указан>');
      gdcCompany.Post;

      gdcDepartment.Open;
      gdcDepartment.Insert;
      SetTID(gdcDepartment.FieldByName('parent'), gdcCompany.ID);
      gdcDepartment.FieldByName('name').AsString := 'Офис';
      gdcDepartment.Post;

      gdcEmployee.Open;

      if Trim(edDirector.Text) > '' then
      begin
        SL.Text :=
          StringReplace(
            StringReplace(Trim(edDirector.Text), '  ', ' ', [rfReplaceAll]),
            ' ', #13#10, [rfReplaceAll]);

        gdcEmployee.Insert;
        SetTID(gdcEmployee.FieldByName('parent'), gdcDepartment.ID);
        SetFieldValue(gdcEmployee.FieldByName('surname'), SL[0], '');
        if SL.Count > 1 then
          SetFieldValue(gdcEmployee.FieldByName('firstname'), SL[1], '');
        if SL.Count > 2 then
          SetFieldValue(gdcEmployee.FieldByName('middlename'), SL[2], '');
        gdcEmployee.Post;

        gdcCompany.Edit;
        SetTID(gdcCompany.FieldByName('directorkey'), gdcEmployee.ID);
        gdcCompany.Post;
      end;

      if Trim(edAccountant.Text) > '' then
      begin
        SL.Text :=
          StringReplace(
            StringReplace(Trim(edAccountant.Text), '  ', ' ', [rfReplaceAll]),
            ' ', #13#10, [rfReplaceAll]);

        gdcEmployee.Insert;
        SetTID(gdcEmployee.FieldByName('parent'), gdcDepartment.ID);
        SetFieldValue(gdcEmployee.FieldByName('surname'), SL[0], '');
        if SL.Count > 1 then
          SetFieldValue(gdcEmployee.FieldByName('firstname'), SL[1], '');
        if SL.Count > 2 then
          SetFieldValue(gdcEmployee.FieldByName('middlename'), SL[2], '');
        gdcEmployee.Post;

        gdcCompany.Edit;
        SetTID(gdcCompany.FieldByName('chiefaccountantkey'), gdcEmployee.ID);
        gdcCompany.Post;
      end;

      if Trim(edLogin.Text) > '' then
      begin
        if Trim(edUser.Text) > '' then
        begin
          SL.Text :=
            StringReplace(
              StringReplace(Trim(edUser.Text), '  ', ' ', [rfReplaceAll]),
              ' ', #13#10, [rfReplaceAll]);

          q.Close;
          q.SQL.Text := 'SELECT contactkey FROM gd_people WHERE UPPER(surname) = :N ';
          q.ParamByName('N').AsString := AnsiUpperCase(SL[0]);
          q.ExecQuery;

          if not q.EOF then
            UserID := GetTID(q.FieldByName('contactkey'))
          else begin
            gdcEmployee.Insert;
            SetTID(gdcEmployee.FieldByName('parent'), gdcDepartment.ID);
            SetFieldValue(gdcEmployee.FieldByName('surname'), SL[0], '');
            if SL.Count > 1 then
              SetFieldValue(gdcEmployee.FieldByName('firstname'), SL[1], '');
            if SL.Count > 2 then
              SetFieldValue(gdcEmployee.FieldByName('middlename'), SL[2], '');
            gdcEmployee.Post;
            UserID := gdcEmployee.ID;
          end;
        end else
          UserID := 650002;

        gdcUser.Open;
        gdcUser.Insert;
        SetFieldValue(gdcUser.FieldByName('name'), Trim(edLogin.Text), '');
        SetFieldValue(gdcUser.FieldByName('passw'), edPassword.Text, '');
        SetTID(gdcUser.FieldByName('contactkey'), UserID);
        gdcUser.Post;
      end;

      if (Trim(edBankCode.Text) > '') and (Trim(edBankName.Text) > '') then
      begin
        q.Close;
        q.SQL.Text := 'SELECT bankkey FROM gd_bank WHERE bankcode = :C ' +
          'AND COALESCE(bankbranch, '''') = :B ';
        q.ParamByName('C').AsString := Copy(Trim(edBankCode.Text), 1, q.ParamByName('C').Size);
        q.ParamByName('B').AsString := Copy(Trim(edBranch.Text), 1, q.ParamByName('B').Size);
        q.ExecQuery;

        if not q.EOF then
        begin
          gdcBank.ID := GetTID(q.FieldByName('bankkey'));
          gdcBank.Open;
          if gdcBank.EOF then
            gdcBank.Insert
          else
            gdcBank.Edit;
        end else
        begin
          gdcBank.Open;
          gdcBank.Insert;
        end;

        if gdcBank.State = dsInsert then
        begin
          SetFieldValue(gdcBank.FieldByName('bankcode'), edBankCode.Text, '');
          SetFieldValue(gdcBank.FieldByName('bankbranch'), edBranch.Text, '');
        end;

        q.Close;
        q.SQL.Text := 'SELECT id FROM gd_place WHERE UPPER(name) = :N ' +
          'AND placetype = ''Страна'' ';
        q.ParamByName('N').AsString := AnsiUpperCase(cbBankCountry.Text);
        q.ExecQuery;

        SetTID(gdcBank.FieldByName('parent'), 650001);
        SetFieldValue(gdcBank.FieldByName('name'), edBankName.Text, '<Название не указано>');
        gdcBank.FieldByName('fullname').AsString := gdcBank.FieldByName('name').AsString;
        if not q.EOF then
          SetTID(gdcBank.FieldByName('placekey'), q.FieldByName('id'));
        SetFieldValue(gdcBank.FieldByName('zip'), edBankZip.Text, '<Индекс не указан>');
        SetFieldValue(gdcBank.FieldByName('country'), cbBankCountry.Text, '<Не указано>');
        SetFieldValue(gdcBank.FieldByName('district'), edBankDistrict.Text, '<Не указано>');
        SetFieldValue(gdcBank.FieldByName('region'), edBankArea.Text, '<Не указано>');
        SetFieldValue(gdcBank.FieldByName('city'), edBankCity.Text, '<Не указано>');
        SetFieldValue(gdcBank.FieldByName('address'), edBankAddress.Text, '<Адрес не указан>');
        gdcBank.Post;

        if Trim(edAccount.Text) > '' then
        begin
          gdcAccount.Open;
          gdcAccount.Insert;
          SetTID(gdcAccount.FieldByName('companykey'), gdcCompany.ID);
          SetTID(gdcAccount.FieldByName('bankkey'), gdcBank.ID);
          gdcAccount.FieldByName('account').AsString := Trim(edAccount.Text);
          if iblkupCurr.CurrentKey > '' then
            SetTID(gdcAccount.FieldByName('currkey'), iblkupCurr.CurrentKeyInt);
          gdcAccount.Post;

          gdcCompany.Edit;
          SetTID(gdcCompany.FieldByName('companyaccountkey'), gdcAccount.ID);
          gdcCompany.Post;
        end;

        if iblkupCurr.CurrentKey > '' then
        begin
          q.Close;
          q.SQL.Text := 'UPDATE gd_curr SET isncu = 1 WHERE id = :ID';
          SetTID(q.ParamByName('ID'), iblkupCurr.CurrentKeyInt);
          q.ExecQuery;
          ResetNCUCache;
        end;
      end;

      q.Close;
      q.SQL.Text :=
        'EXECUTE BLOCK (oldk DINTKEY = :oldk, newk DINTKEY = :newk)'#13#10 +
        'AS'#13#10 +
        '  DECLARE VARIABLE S VARCHAR(1024);'#13#10 +
        'BEGIN'#13#10 +
        '  FOR'#13#10 +
        '    SELECT'#13#10 +
        '      ''UPDATE '' || rc.rdb$relation_name ||'#13#10 +
        '      '' SET '' || iseg.rdb$field_name || ''='' || :newk ||'#13#10 +
        '      '' WHERE '' || iseg.rdb$field_name || ''='' || :oldk'#13#10 +
        '    FROM'#13#10 +
        '      rdb$relation_constraints rc'#13#10 +
        '      JOIN rdb$index_segments iseg'#13#10 +
        '        ON iseg.rdb$index_name = rc.rdb$index_name'#13#10 +
        '      JOIN rdb$ref_constraints rf'#13#10 +
        '        ON rf.rdb$constraint_name = rc.rdb$constraint_name'#13#10 +
        '      JOIN rdb$relation_constraints pr'#13#10 +
        '        ON pr.rdb$constraint_name = rf.rdb$const_name_uq'#13#10 +
        '      JOIN rdb$index_segments ipr'#13#10 +
        '        ON ipr.rdb$index_name = pr.rdb$index_name'#13#10 +
        '    WHERE'#13#10 +
        '      rc.rdb$constraint_type = ''FOREIGN KEY'' '#13#10 +
        '      AND'#13#10 +
        '      pr.rdb$relation_name = ''GD_OURCOMPANY'' '#13#10 +
        '    INTO :S'#13#10 +
        '  DO BEGIN'#13#10 +
        '    EXECUTE STATEMENT :S;'#13#10 +
        '  END'#13#10 +
        'END';
      SetTID(q.ParamByName('oldk'), IBLogin.CompanyKey);
      SetTID(q.ParamByName('newk'), gdcCompany.ID);
      q.ExecQuery;

      q.SQL.Text := 'UPDATE gd_contact SET disabled = 1 WHERE id IN (650002, 650010, 650015)';
      q.ExecQuery;

      q.SQL.Text := 'SELECT FIRST 1 id FROM ac_account WHERE parent IS NULL';
      q.ExecQuery;
      if not q.EOF then
      begin
        AccID := GetTID(q.FieldByName('id'));

        q.Close;
        q.SQL.Text :=
          'UPDATE OR INSERT INTO ac_companyaccount (accountkey, companykey, isactive) ' +
          'VALUES (:ac, :ck, 1) MATCHING (accountkey)';
        SetTID(q.ParamByName('ac'), AccID);
        SetTID(q.ParamByName('ck'), gdcCompany.ID);
        q.ExecQuery;
      end;

      if ibTr.InTransaction then
        ibTr.Commit;

      ibtr.StartTransaction;
      q.SQL.Text := 'DELETE FROM gd_ourcompany WHERE companykey = :CK';
      SetTID(q.ParamByName('CK'), IBLogin.CompanyKey);
      q.ExecQuery;
      ibtr.Commit;

      ModalResult := mrOk;
    finally
      SL.Free;
    end;
  except
    if ibTr.InTransaction then
      ibTr.Rollback;
    raise;
  end;
end;

procedure Tgd_dlgInitialInfo.actCancelExecute(Sender: TObject);
begin
  if ibTr.InTransaction then
    ibTr.Rollback;
  ModalResult := mrCancel;
end;

procedure Tgd_dlgInitialInfo.actOkUpdate(Sender: TObject);
begin
  actOk.Enabled := (Trim(edName.Text) > '')
    and (Trim(edUser.Text) > '')
    and (Trim(edLogin.Text) > '')
    and (edPassword.Text = edPassword2.Text);
end;

procedure Tgd_dlgInitialInfo.edNameDblClick(Sender: TObject);
begin
  edName.Text := '1';
  edUser.Text := '1';
  edLogin.Text := '1';
  edPassword.Text := '1';
  edPassword2.Text := '1';
  actOk.Execute;
end;

procedure Tgd_dlgInitialInfo.FormCreate(Sender: TObject);
begin
  ForceForegroundWindow(Self.Handle);
end;

end.
