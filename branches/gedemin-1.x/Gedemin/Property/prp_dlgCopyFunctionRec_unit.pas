unit prp_dlgCopyFunctionRec_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBCustomDataSet, StdCtrls, ExtCtrls, IBDatabase, Contnrs;

type
  TdlgCopyFunctionRec = class(TForm)
    stMessage: TStaticText;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    pExtraInfo: TPanel;
    stExtraInfo: TStaticText;
    DataSource: TDataSource;
    IBDataSet: TIBDataSet;
    sbInfoLines: TScrollBox;
    Button4: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FTransaction: TIBTransaction;
    FId: Integer;
    FInfoLines: TObjectList;
    procedure SetTransaction(const Value: TIBTransaction);
    procedure SetId(const Value: Integer);
    { Private declarations }

  public
    { Public declarations }
    property Transaction: TIBTransaction read FTransaction write SetTransaction;
    property Id: Integer read FId write SetId;
  end;

var
  dlgCopyFunctionRec: TdlgCopyFunctionRec;

implementation
uses prp_CopyFunctionRecInfoLine_unit;
{$R *.DFM}

procedure TdlgCopyFunctionRec.FormCreate(Sender: TObject);
begin
  Self.AdjustSize;
  FInfoLines := TObjectList.Create(True);
  IBDataSet.SelectSQl.Text :=
        ' SELECT ' +
        '     isg2.RDB$FIELD_NAME     TargetField ' +
        '   , rc2.RDB$RELATION_NAME  TargetTable ' +
        ' FROM ' +
        '     RDB$RELATION_CONSTRAINTS rc1 ' +
        '   , RDB$REF_CONSTRAINTS rfc ' +
        '   , RDB$RELATION_CONSTRAINTS rc2 ' +
        '   , RDB$INDEX_SEGMENTS isg2 ' +
        '   , RDB$RELATION_CONSTRAINTS rc3 ' +
        '   , rdb$ref_constraints rrc ' +
        ' WHERE ' +
        '   rc1.RDB$RELATION_NAME = UPPER(''' + 'GD_FUNCTION'{GetListTable(SubType)} + ''')' +
        '   AND rfc.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME ' +
        '   AND rfc.RDB$CONST_NAME_UQ = rc1.RDB$CONSTRAINT_NAME ' +
        '   AND rc2.RDB$INDEX_NAME = isg2.RDB$INDEX_NAME ' +
        '   AND rc3.RDB$RELATION_NAME = rc2.RDB$RELATION_NAME ' +
        '   AND rc3.RDB$CONSTRAINT_TYPE = ''PRIMARY KEY''' +
        '   AND rrc.RDB$CONSTRAINT_NAME = rc2.RDB$CONSTRAINT_NAME ' +
        '   AND rrc.RDB$DELETE_RULE = ''RESTRICT'' ' +
        ' ORDER BY ' +
        '   rc2.RDB$RELATION_NAME ';

end;

procedure TdlgCopyFunctionRec.Button3Click(Sender: TObject);
var
  ValDS: TIBDataSet;
  TableName: String;
  F: TCopyFunctionRecInfoLine;
begin
  pExtraInfo.Visible := not pExtraInfo.Visible;
  if pExtraInfo.Visible then
  begin
    FInfoLines.Clear;
    IBDataSet.Open;
    ValDS := TIBDataSet.Create(nil);
    try
      ValDS.Transaction := Transaction;
      while not IBDataSet.Eof do
      begin
        TableName := UpperCase(Trim(IBDataSet.FieldByName('targettable').AsString));
        ValDS.SelectSQL.Text := 'SELECT * FROM ' + TableName +
            ' WHERE ' + IBDataSet.FieldByName('TargetField').AsString +
            ' = ' + IntToStr(Id);
        ValDS.Open;
        if not ValDS.IsEmpty then
        begin
          F := TCopyFunctionRecInfoLine.Create(nil);
          F.Top := FInfoLines.Count * F.Height;
          F.Parent := sbInfoLines;
          F.stTableName.Caption := 'Таблица: ' + TableName;
          F.Transaction := Transaction;
          F.IBDataSet.SelectSQL.Add('SELECT ');
          F.IBDataSet.SelectSQL.Add('');
          F.IBDataSet.SelectSQL.Add(' FROM ' + TableName +
            ' WHERE ' + IBDataSet.FieldByName('TargetField').AsString +
            ' = ' + IntToStr(Id));
          if (TableName = 'EVT_MACROSLIST') or
            (TableName = 'RP_REPORTLIST') then
            F.IBDataSet.SelectSQL[1] := 'name'
          else if TableName = 'RP_ADDITIONALFUNCTION' then
          begin
            F.stTableName.Caption := 'Входит в функции по #INCLUDE:';
            F.IBDataSet.SelectSQL.Text := 'SELECT g.name FROM ' +
              'gd_function g, RP_ADDITIONALFUNCTION af WHERE (af.ADDFUNCTIONKEY = ' +
              IntToStr(Id) + ') AND (g.id = af.MAINFUNCTIONKEY)';
          end
          else if TableName = 'EVT_OBJECTEVENT' then
          begin
            F.IBDataSet.SelectSQL[1] := 'EVENTNAME';
          end else
            F.IBDataSet.SelectSQL[1] := '*';
          F.IBDataSet.Open;
          FInfoLines.Add(F);
          sbInfoLines.ClientHeight := F.Height;
          sbInfoLines.VertScrollBar.Increment := F.Height;
        end;
        ValDS.Close;
        IBDataSet.Next;
      end;
    finally
      ValDS.Free;
    end;
  end
  else
    IBDataSet.Close;
  AdjustSize;
end;

procedure TdlgCopyFunctionRec.SetTransaction(const Value: TIBTransaction);
begin
  if FTransaction <> Value then
  begin
    FTransaction := Value;
    IBDataSet.Transaction := FTransaction;
  end;
end;

procedure TdlgCopyFunctionRec.SetId(const Value: Integer);
begin
  FId := Value;
end;

end.
