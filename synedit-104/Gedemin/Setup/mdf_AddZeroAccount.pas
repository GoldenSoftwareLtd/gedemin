unit mdf_AddZeroAccount;

interface

uses
  IBDatabase, gdModify;

procedure AddZeroAccount(IBDB: TIBDatabase; Log: TModifyLog);


implementation

uses
  IBSQL, SysUtils;

procedure AddZeroAccount(IBDB: TIBDatabase; Log: TModifyLog);
var
  FTransaction: TIBTransaction;
  FIBSQL: TIBSQL;
begin
  Log('���������� ����� 00');
  FTransaction := TIBTransaction.Create(nil);
  try
    FTransaction.DefaultDatabase := IBDB;
    FTransaction.StartTransaction;
    try
      FIBSQL := TIBSQL.Create(nil);
      try
        FIBSQL.Transaction := FTransaction;
        FIBSQL.SQL.Text :=
'INSERT INTO AC_ACCOUNT '#13#10 +
'  (ID,PARENT,LB,RB,NAME,ALIAS,ACTIVITY,ACCOUNTTYPE,MULTYCURR,OFFBALANCE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED,ANALYTICALFIELD) '#13#10 +
'VALUES '#13#10 +
'  (300002,300001,1,1550,''0. ������������ �����'',''0. ������������'',''A'',''F'',0,0,-1,-1,-1,0,NULL,NULL); '#13#10;

        try
          FIBSQL.ExecQuery;
          Log('���������� ������� ������ �������');
        except
          Log('������ ��� ���������� � ����');
        end;
        FIBSQL.Close;

        FIBSQL.SQL.Text :=
'INSERT INTO AC_ACCOUNT '#13#10 +
'  (ID,PARENT,NAME,ALIAS,ACTIVITY,ACCOUNTTYPE,MULTYCURR,OFFBALANCE,AFULL,ACHAG,AVIEW,DISABLED,RESERVED,ANALYTICALFIELD) '#13#10 +
'VALUES '#13#10 +
'  (300003,300002, ''�������'',''00'',''A'',''A'',0,1,-1,-1,-1,0,NULL,NULL); '#13#10;
        try
          FIBSQL.ExecQuery;
          Log('���������� ����� ������ �������');
        except
          Log('���� ��� ���������� � ����');
        end;
        FTransaction.Commit;
      finally
        FIBSQL.Free;
      end;
    except
      on E: Exception do
      begin
        FTransaction.Rollback;
        Log(E.Message);
      end;
    end;
  finally
    FTransaction.Free;
  end;
end;

end.
