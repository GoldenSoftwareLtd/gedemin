unit mdf_AlterBankStatementTrigger;

interface

uses
  IBDatabase, gdModify, mdf_MetaData_unit, Windows, Controls, Sysutils, IBSQL;

procedure AlterBankStatementTrigger(IBDB: TIBDatabase; Log: TModifyLog);

implementation

const
  TriggerCount = 3;
  Triggers: array[0..TriggerCount - 1] of TmdfTrigger = (
    (TriggerName: 'GD_AU_DOCUMENT'; Description:
      'ACTIVE AFTER UPDATE POSITION 0'#13#10 +
      'AS'#13#10 +
      'begin'#13#10 +
      'IF (NEW.PARENT IS NULL) THEN '#13#10 +
      'BEGIN '#13#10 +
      '  IF (NEW.DOCUMENTTYPEKEY <> 800300) THEN '#13#10 +
      '    UPDATE gd_document SET documentdate = NEW.documentdate, '#13#10 +
      '      number = NEW.number, companykey = NEW.companykey '#13#10 +
      '    WHERE (parent = NEW.ID) '#13#10 +
      '      AND ((documentdate <> NEW.documentdate) '#13#10 +
      '       OR (number <> NEW.number) OR (companykey <> NEW.companykey)); '#13#10 +
      '  ELSE '#13#10 +
      '    UPDATE gd_document SET documentdate = NEW.documentdate, '#13#10 +
      '      companykey = NEW.companykey '#13#10 +
      '    WHERE (parent = NEW.ID) '#13#10 +
      '      AND ((documentdate <> NEW.documentdate) '#13#10 +
      '      OR  (companykey <> NEW.companykey)); '#13#10 +
      'END ELSE '#13#10 +
      'BEGIN '#13#10 +
      '  UPDATE gd_document SET editiondate = NEW.editiondate, '#13#10 +
      '    editorkey = NEW.editorkey '#13#10 +
      '  WHERE (ID = NEW.parent) AND (editiondate <> NEW.editiondate); '#13#10 +
      'END '#13#10 +
      'end'),
    (TriggerName: 'bn_ai_bsl'; Description:
      'ACTIVE AFTER INSERT POSITION 0'#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE ndsumncu NUMERIC(15, 4); '#13#10 +
      '  DECLARE VARIABLE ncsumncu NUMERIC(15, 4); '#13#10 +
      '  DECLARE VARIABLE ndsumcurr NUMERIC(15, 4); '#13#10 +
      '  DECLARE VARIABLE ncsumcurr NUMERIC(15, 4); '#13#10 +
      'BEGIN '#13#10 +
      '  IF (NEW.dsumncu IS NULL) THEN '#13#10 +
      '    ndsumncu = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    ndsumncu = NEW.dsumncu; '#13#10 +
      ' '#13#10 +
      '  IF (NEW.csumncu IS NULL) THEN '#13#10 +
      '    ncsumncu = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    ncsumncu = NEW.csumncu; '#13#10 +
      ' '#13#10 +
      '  IF (NEW.dsumcurr IS NULL) THEN '#13#10 +
      '    ndsumcurr = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    ndsumcurr = NEW.dsumcurr; '#13#10 +
      ' '#13#10 +
      '  IF (NEW.csumcurr IS NULL) THEN '#13#10 +
      '    ncsumcurr = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    ncsumcurr = NEW.csumcurr; '#13#10 +
      ' '#13#10 +
      '  UPDATE bn_bankstatement '#13#10 +
      '    SET linecount = linecount + 1, '#13#10 +
      '        dsumncu = dsumncu + :ndsumncu, '#13#10 +
      '        csumncu = csumncu + :ncsumncu, '#13#10 +
      '        dsumcurr = dsumcurr + :ndsumcurr, '#13#10 +
      '        csumcurr = csumcurr + :ncsumcurr '#13#10 +
      '    WHERE documentkey = NEW.bankstatementkey; '#13#10 +
      ' '#13#10 +
      '  UPDATE gd_document SET '#13#10 +
      '  number = iif(NEW.docnumber IS NULL, ''б\н'', NEW.docnumber) '#13#10 +
      '  WHERE id = NEW.id; '#13#10 +
      ' '#13#10 +
      'END '),
    (TriggerName: 'bn_au_bsl'; Description:
      'ACTIVE AFTER UPDATE POSITION 0'#13#10 +
      'AS '#13#10 +
      '  DECLARE VARIABLE change_csumcurr SMALLINT; '#13#10 +
      '  DECLARE VARIABLE change_csumncu  SMALLINT; '#13#10 +
      '  DECLARE VARIABLE change_dsumcurr SMALLINT; '#13#10 +
      '  DECLARE VARIABLE change_dsumncu  SMALLINT; '#13#10 +
      'BEGIN '#13#10 +
      '  IF ((NEW.csumcurr IS NULL AND OLD.csumcurr IS NULL) OR '#13#10 +
      '     (NEW.csumcurr = OLD.csumcurr)) THEN '#13#10 +
      '    change_csumcurr = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    change_csumcurr = 1; '#13#10 +
      '     '#13#10 +
      '  IF ((NEW.csumncu IS NULL AND OLD.csumncu IS NULL) OR '#13#10 +
      '     (NEW.csumncu = OLD.csumncu)) THEN '#13#10 +
      '    change_csumncu = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    change_csumncu = 1; '#13#10 +
      '   '#13#10 +
      '  IF ((NEW.dsumcurr IS NULL AND OLD.dsumcurr IS NULL) OR '#13#10 +
      '     (NEW.dsumcurr = OLD.dsumcurr)) THEN '#13#10 +
      '    change_dsumcurr = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    change_dsumcurr = 1; '#13#10 +
      '     '#13#10 +
      '  IF ((NEW.dsumncu IS NULL AND OLD.dsumncu IS NULL) OR '#13#10 +
      '     (NEW.dsumncu = OLD.dsumncu)) THEN '#13#10 +
      '    change_dsumncu = 0; '#13#10 +
      '  ELSE '#13#10 +
      '    change_dsumncu = 1; '#13#10 +
      ' '#13#10 +
      '  IF ((change_csumcurr = 1) OR '#13#10 +
      '  (change_csumncu = 1) OR '#13#10 +
      '  (change_dsumcurr = 1) OR '#13#10 +
      '  (change_dsumncu = 1)) THEN '#13#10 +
      '  EXECUTE PROCEDURE bn_p_update_bankstatement(NEW.bankstatementkey); '#13#10 +
      ' '#13#10 +
      '  UPDATE gd_document SET '#13#10 +
      '  number = iif(NEW.docnumber IS NULL, ''б\н'', NEW.docnumber) '#13#10 +
      '  WHERE id = NEW.id; '#13#10 +
      'END ')


  );

procedure AlterBankStatementTrigger(IBDB: TIBDatabase; Log: TModifyLog);
var
  I: Integer;
  ibtr: TIBTransaction;
  ibsql: TIBSQL;
begin
  for I := 0 to TriggerCount - 1 do
  begin
    if TriggerExist(Triggers[I], IBDB) then
    begin
      Log(Format('Изменение триггера %s ', [Triggers[i].TriggerName]));
      try
        AlterTrigger(Triggers[i], IBDB);
      except
        on E: Exception do
          Log(Format('Ошибка %s', [E.Message]));
      end;
    end;
  end;
  ibtr := TIBTransaction.Create(nil);
  ibsql := TIBSQL.Create(nil);
  try
    ibtr.DefaultDatabase := IBDB;
    ibsql.Transaction := ibtr;
    ibsql.SQL.Text := 'UPDATE bn_bankstatementline SET id = id';
    ibtr.StartTransaction;
    ibsql.ExecQuery;
  finally
    ibtr.Commit;
    ibsql.Free;
    ibtr.Free;
  end;
end;

end.
