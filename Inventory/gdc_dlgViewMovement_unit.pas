unit gdc_dlgViewMovement_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, IBDatabase, IBCustomDataSet, Grids, DBGrids, gsDBGrid, gsIBGrid, StdCtrls,
  ExtCtrls, ActnList, gdcClasses, gdc_createable_form, gdcInvDocument_unit,
  gdcBaseInterface, ibsql, gdcInvConsts_unit, at_classes;

type
  Tgdc_dlgViewMovement = class(TgdcCreateableForm)
    Panel1: TPanel;
    lHeader: TLabel;
    Panel2: TPanel;
    ibgrMovementList: TgsIBGrid;
    ibdsMovementList: TIBDataSet;
    dsMovementList: TDataSource;
    Button1: TButton;
    ActionList1: TActionList;
    actViewDocument: TAction;
    actClose: TAction;
    Button2: TButton;
    pnlMain: TPanel;
    Bevel1: TBevel;
    Button3: TButton;
    actInCardAll: TAction;
    actInCardSingle: TAction;
    Button4: TButton;
    procedure actCloseExecute(Sender: TObject);
    procedure actViewDocumentExecute(Sender: TObject);
    procedure actInCardAllExecute(Sender: TObject);
    procedure actInCardSingleExecute(Sender: TObject);
  private
    FContactKey: Integer;
    FDocumentKey: Integer;
    FGoodName: String;

    procedure SetTransaction(const Value: TIBTransaction);
    function GetTransaction: TIBTransaction;
    procedure SetGoodName(const Value: String);
    { Private declarations }
  public
    { Public declarations }
    procedure LoadSettings; override;
    procedure SaveSettings; override;


    property GoodName: String read FGoodName write SetGoodName;
    property DocumentKey: Integer read FDocumentKey write FDocumentKey;
    property ContactKey: Integer read FContactKey write FContactKey;
    property Transaction: TIBTransaction read GetTransaction write SetTransaction;
  end;

var
  gdc_dlgViewMovement: Tgdc_dlgViewMovement;

implementation

{$R *.DFM}

uses
  Storages, gd_ClassList, gdcInvMovement, gdc_dlgViewRemainsInvCards_unit;

procedure Tgdc_dlgViewMovement.actCloseExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

function Tgdc_dlgViewMovement.GetTransaction: TIBTransaction;
begin
  Result := ibdsMovementList.Transaction;
end;

procedure Tgdc_dlgViewMovement.SetTransaction(const Value: TIBTransaction);
begin
  ibdsMovementList.Transaction := Value;

  ibdsMovementList.ParamByName('documentkey').AsInteger := FDocumentKey;
  ibdsMovementList.ParamByName('contactkey').AsInteger := FContactKey;
  ibdsMovementList.Open;
end;

procedure Tgdc_dlgViewMovement.actViewDocumentExecute(Sender: TObject);
var
  Document: TgdcDocument;
begin
  Document := TgdcDocument.Create(Self);
  try
    Document.SubSet := 'ByID';
    Document.ID := ibdsMovementList.FieldByName('parent').AsInteger;
    Document.Open;
    Document.EditDialog;
  finally
    Document.Free;
  end;
end;

procedure Tgdc_dlgViewMovement.LoadSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGVIEWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGVIEWMOVEMENT', KEYLOADSETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYLOADSETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGVIEWMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGVIEWMOVEMENT',
  {M}          'LOADSETTINGS', KEYLOADSETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGVIEWMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  UserStorage.LoadComponent(ibgrMovementList, ibgrMovementList.LoadFromStream);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGVIEWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGVIEWMOVEMENT', 'LOADSETTINGS', KEYLOADSETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgViewMovement.SaveSettings;
  {@UNFOLD MACRO INH_CRFORM_PARAMS(VAR)}
  {M}VAR
  {M}  Params, LResult: Variant;
  {M}  tmpStrings: TStackStrings;
  {END MACRO}
begin
  {@UNFOLD MACRO INH_CRFORM_WITHOUTPARAMS('TGDC_DLGVIEWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}  try
  {M}    if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    begin
  {M}      SetFirstMethodAssoc('TGDC_DLGVIEWMOVEMENT', KEYSAVESETTINGS);
  {M}      tmpStrings := TStackStrings(ClassMethodAssoc.IntByKey[KEYSAVESETTINGS]);
  {M}      if (tmpStrings = nil) or (tmpStrings.IndexOf('TGDC_DLGVIEWMOVEMENT') = -1) then
  {M}      begin
  {M}        Params := VarArrayOf([GetGdcInterface(Self)]);
  {M}        if gdcMethodControl.ExecuteMethodNew(ClassMethodAssoc, Self, 'TGDC_DLGVIEWMOVEMENT',
  {M}          'SAVESETTINGS', KEYSAVESETTINGS, Params, LResult) then exit;
  {M}      end else
  {M}        if tmpStrings.LastClass.gdClassName <> 'TGDC_DLGVIEWMOVEMENT' then
  {M}        begin
  {M}          Inherited;
  {M}          Exit;
  {M}        end;
  {M}    end;
  {END MACRO}
  UserStorage.SaveComponent(ibgrMovementList, ibgrMovementList.SaveToStream);
  {@UNFOLD MACRO INH_CRFORM_FINALLY('TGDC_DLGVIEWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS)}
  {M}finally
  {M}  if Assigned(gdcMethodControl) and Assigned(ClassMethodAssoc) then
  {M}    ClearMacrosStack('TGDC_DLGVIEWMOVEMENT', 'SAVESETTINGS', KEYSAVESETTINGS);
  {M}end;
  {END MACRO}
end;

procedure Tgdc_dlgViewMovement.SetGoodName(const Value: String);
begin
  FGoodName := Value;
  lHeader.Caption := Format(lHeader.Caption, [FGoodName]);
end;

procedure Tgdc_dlgViewMovement.actInCardAllExecute(Sender: TObject);
var
  gdcIDL: TgdcInvDocumentLine;
  dlg: Tgdc_dlgViewRemainsInvCards;
  q, q1: TIBSQL;
  tr: TIBTransaction;
  iNewCardKey, iOldCardKey, iOldDocKey, i: integer;
  InvCardRel: TatRelation;
  sFieldName: string;

  procedure SetUpdateQuery(ASQL: string);
  begin
    q.Close;
    q.SQL.Text:= ASQL;
    q.ParamByName('old').AsInteger:= iOldCardKey;
    q.ParamByName('new').AsInteger:= iNewCardKey;
  end;

begin
  ibdsMovementList.First;
  i:= 0;
  while not ibdsMovementList.Eof do begin
    if ibdsMovementList.FieldByName('credit').AsInteger > 0 then
      i:= i + ibdsMovementList.FieldByName('credit').AsInteger;
    ibdsMovementList.Next;
  end;
  ibdsMovementList.First;
  gdcIDL:= TgdcInvDocumentLine.Create(self);
  tr:= TIBTransaction.Create(self);
  q1 := TIBSQL.Create(Self);
  try
    tr.DefaultDatabase:= gdcBaseManager.Database;
    tr.StartTransaction;
    q1.Transaction := tr;
    q1.SQL.Text := 'SELECT ruid FROM gd_documenttype WHERE id = :id';
    q1.ParamByNAme('id').AsInteger := ibdsMovementList.FieldByName('doctkey').AsInteger;
    q1.ExecQuery;
    gdcIDL.Transaction:= tr;
    gdcIDL.SubSet:= 'ByID';
    gdcIDL.SubType:= q1.FieldByNAme('ruid').AsString;
    q1.Close;
    gdcIDL.ID:= ibdsMovementList.FieldByName('dockey').AsInteger;
    gdcIDL.Open;
    dlg:= Tgdc_dlgViewRemainsInvCards.CreateAndAssign(self) as Tgdc_dlgViewRemainsInvCards;
    try
      dlg.OpenDataSet(gdcIDL, ibdsMovementList.FieldByName('contactkey').AsInteger, i);
      if dlg.ShowModal = mrOk then begin
        if dlg.ibgrInvCardList.CheckBox.CheckCount > 0 then begin
          iNewCardKey:= StrToInt(dlg.ibgrInvCardList.CheckBox.CheckList[0]);
          iOldCardKey:= ibdsMovementList.FieldByName('cardkey').AsInteger;
          q:= TIBSQL.Create(self);
          try
            q.Transaction:= tr;
            SetUpdateQuery(
              'UPDATE inv_movement SET cardkey = :new WHERE cardkey = :old AND documentkey <> :dockey');
            q.ParamByName('dockey').AsInteger:= DocumentKey;
            try
              q.ExecQuery;
              SetUpdateQuery(
                'UPDATE inv_card SET parent = :new WHERE parent = :old');
              q.ExecQuery;
              if gdcIDL.RelationType <> irtInvalid then begin
                SetUpdateQuery(
                  'UPDATE ' + gdcIDL.RelationLineName + ' SET fromcardkey = :new WHERE fromcardkey = :old');
                q.ExecQuery;
                if gdcIDL.RelationType = irtFeatureChange then begin
                  SetUpdateQuery(
                    'UPDATE ' + gdcIDL.RelationLineName + ' SET tocardkey = :new WHERE tocardkey = :old');
                  q.ParamByName('old').AsInteger:= iOldCardKey;
                  q.ParamByName('new').AsInteger:= iNewCardKey;
                  q.ExecQuery;
                end;
              end;
              InvCardRel:= atDatabase.Relations.ByRelationName('INV_CARD');
              if Assigned(InvCardRel) then begin
                for i:= 0 to InvCardRel.RelationFields.Count - 1 do begin
                  if not InvCardRel.RelationFields[i].IsUserDefined then
                    Continue;
                  if Assigned(InvCardRel.RelationFields[i].References) and
                      (InvCardRel.RelationFields[i].References.RelationName = 'GD_DOCUMENT') then begin
                    sFieldName:= InvCardRel.RelationFields[i].FieldName;
                    q.Close;
                    q.SQL.Text:=
                      'SELECT ' + sFieldName + ' FROM inv_card WHERE id=:old';
                    q.ParamByName('old').AsInteger:= iOldCardKey;
                    q.ExecQuery;
                    if q.Fields[0].IsNull then
                      Continue;
                    iOldDocKey:= q.Fields[0].AsInteger;
                    q.Close;
                    q.SQL.Text:=
                      'UPDATE inv_card SET ' + sFieldName + ' = :new WHERE ' + sFieldName + ' = :old AND ' +
                        sFieldName + ' <> documentkey';
                    q.ParamByName('old').AsInteger:= iOldDocKey;
                    if dlg.ibdsInvCardList.FieldByName(InvCardRel.RelationFields[i].FieldName).IsNull then
                      q.ParamByName('new').Clear
                    else
                      q.ParamByName('new').AsInteger:= dlg.ibdsInvCardList.FieldByName(InvCardRel.RelationFields[i].FieldName).AsInteger;
                    q.ExecQuery;
                  end;
                end;
              end;
              tr.Commit;
              ibdsMovementList.CLose;
              ibdsMovementList.Open;
              if ibdsMovementList.Eof then
                ModalResult:= mrOk;
            except
              tr.RollBack;
              Raise Exception.Create('Невозможно перенести движение.');
            end;
          finally
            q.Free;
          end;
        end;
      end;
    finally
      dlg.Free;
    end;
  finally
    tr.Free;
    q1.Free;
    gdcIDL.Free;
  end;
end;

procedure Tgdc_dlgViewMovement.actInCardSingleExecute(Sender: TObject);
var
  gdcIDL: TgdcInvDocumentLine;
  dlg: Tgdc_dlgViewRemainsInvCards;
  q: TIBSQL;
  tr: TIBTransaction;
  iNewCardKey, iOldCardKey, iOldDocKey, i, iMoveKey: integer;
  InvCardRel: TatRelation;
  sFieldName, sCardKeys, sDocFromKeys, sDocToKeys: string;

  function GetKeys(ASQL: string): string;
  begin
    Result:= '';
    q.Close;
    q.SQL.Text:= ASQL;
    q.ParamByName('old').AsInteger:= iOldCardKey;
    q.ParamByName('mkey').AsInteger:= iMoveKey;
    q.ExecQuery;
    while not q.Eof do begin
      if Result <> '' then
        Result:= Result + ', ';
      Result:= Result + IntToStr(q.Fields[0].AsInteger);
      q.Next;
    end;
  end;

  procedure SetUpdateQuery(ASQL: string);
  begin
    q.Close;
    q.SQL.Text:= ASQL;
    q.ParamByName('old').AsInteger:= iOldCardKey;
    q.ParamByName('new').AsInteger:= iNewCardKey;
  end;

begin
  gdcIDL:= TgdcInvDocumentLine.Create(self);
  tr:= TIBTransaction.Create(self);
  try
    tr.DefaultDatabase:= gdcBaseManager.Database;
    tr.StartTransaction;
    gdcIDL.Transaction:= tr;
    gdcIDL.SubSet:= 'ByID';
    gdcIDL.SubType:= gdcBaseManager.GetRUIDStringByID(ibdsMovementList.FieldByName('doctkey').AsInteger);
    gdcIDL.ID:= ibdsMovementList.FieldByName('dockey').AsInteger;
    gdcIDL.Open;
    dlg:= Tgdc_dlgViewRemainsInvCards.CreateAndAssign(self) as Tgdc_dlgViewRemainsInvCards;
    try
      if ibdsMovementList.FieldByName('credit').AsInteger > 0 then
        i:= ibdsMovementList.FieldByName('credit').AsInteger
      else
        i:= ibdsMovementList.FieldByName('debit').AsInteger;
      dlg.OpenDataSet(gdcIDL, ibdsMovementList.FieldByName('contactkey').AsInteger, i);
      if dlg.ShowModal = mrOk then begin
        if dlg.ibgrInvCardList.CheckBox.CheckCount > 0 then begin
          iNewCardKey:= StrToInt(dlg.ibgrInvCardList.CheckBox.CheckList[0]);
          iOldCardKey:= ibdsMovementList.FieldByName('cardkey').AsInteger;
          iMoveKey:= ibdsMovementList.FieldByName('mkey').AsInteger;
          q:= TIBSQL.Create(self);
          try
            q.Transaction:= tr;
            sCardKeys:= GetKeys(
              'SELECT c.id FROM inv_card c JOIN inv_movement m ON m.cardkey = c.id AND m.movementkey = :mkey ' +
              'WHERE c.id <> :old');
            if sCardKeys = '' then begin
              ShowMessage('Невозможно перенести движение.');
              Exit;
            end;
            sDocFromKeys:= '';
            sDocFromKeys:= GetKeys(
              'SELECT r.documentkey FROM ' + gdcIDL.RelationLineName + ' r' +
              '  JOIN inv_movement m ON m.documentkey = r.documentkey ' +
              '  JOIN inv_card c ON c.id = r.fromcardkey AND m.cardkey = c.id AND m.movementkey = :mkey ' +
              'WHERE r.fromcardkey = :old');
            sDocToKeys:= '';
            sDocToKeys:= GetKeys(
              'SELECT r.documentkey FROM ' + gdcIDL.RelationLineName + ' r' +
              '  JOIN inv_movement m ON m.documentkey = r.documentkey ' +
              '  JOIN inv_card c ON c.id = r.tocardkey AND m.cardkey = c.id AND m.movementkey = :mkey ' +
              'WHERE r.tocardkey = :old');

            SetUpdateQuery(
              'UPDATE inv_movement SET cardkey = :new ' +
              'WHERE cardkey = :old AND documentkey <> :dockey AND movementkey=:mkey');
            q.ParamByName('dockey').AsInteger:= DocumentKey;
            q.ParamByName('mkey').AsInteger:= iMoveKey;
            try
              q.ExecQuery;
              SetUpdateQuery(
                'UPDATE inv_card SET parent = :new WHERE parent = :old AND id IN (' + sCardKeys + ')');
              q.ExecQuery;
              if gdcIDL.RelationType <> irtInvalid then begin
                if sDocFromKeys <> '' then begin
                  q.Close;
                  q.SQL.Text:=
                    'UPDATE ' + gdcIDL.RelationLineName + ' SET fromcardkey = :new ' +
                    'WHERE documentkey IN (' + sDocFromKeys + ')';
                  q.ParamByName('new').AsInteger:= iNewCardKey;
                  q.ExecQuery;
                end;
                if (gdcIDL.RelationType = irtFeatureChange) and (sDocToKeys <> '') then begin
                  q.Close;
                  q.SQL.Text:=
                    'UPDATE ' + gdcIDL.RelationLineName + ' SET tocardkey = :new ' +
                    'WHERE documentkey IN (' + sDocToKeys + ')';
                  q.ParamByName('new').AsInteger:= iNewCardKey;
                  q.ExecQuery;
                end;
              end;
              InvCardRel:= atDatabase.Relations.ByRelationName('INV_CARD');
              if Assigned(InvCardRel) then begin
                for i:= 0 to InvCardRel.RelationFields.Count - 1 do begin
                  if not InvCardRel.RelationFields[i].IsUserDefined then
                    Continue;
                  if Assigned(InvCardRel.RelationFields[i].References) and
                      (InvCardRel.RelationFields[i].References.RelationName = 'GD_DOCUMENT') then begin
                    sFieldName:= InvCardRel.RelationFields[i].FieldName;
                    q.Close;
                    q.SQL.Text:=
                      'SELECT ' + sFieldName + ' FROM inv_card WHERE id=:old';
                    q.ParamByName('old').AsInteger:= iOldCardKey;
                    q.ExecQuery;
                    if q.Fields[0].IsNull then
                      Continue;
                    iOldDocKey:= q.Fields[0].AsInteger;
                    q.Close;
                    q.SQL.Text:=
                      'UPDATE inv_card SET ' + sFieldName + ' = :new WHERE ' + sFieldName + ' = :old AND ' +
                        sFieldName + ' <> documentkey AND id IN (' + sCardKeys + ')';
                    q.ParamByName('old').AsInteger:= iOldDocKey;
                    if dlg.ibdsInvCardList.FieldByName(InvCardRel.RelationFields[i].FieldName).IsNull then
                      q.ParamByName('new').Clear
                    else
                      q.ParamByName('new').AsInteger:= dlg.ibdsInvCardList.FieldByName(InvCardRel.RelationFields[i].FieldName).AsInteger;
                    q.ExecQuery;
                  end;
                end;
              end;
              tr.Commit;
              ibdsMovementList.CLose;
              ibdsMovementList.Open;
            except
              tr.RollBack;
              raise Exception.Create('Невозможно перенести движение.');
            end;
          finally
            q.Free;
          end;
        end;
      end;
    finally
      dlg.Free;
    end;
  finally
    tr.Free;
    gdcIDL.Free;
  end;
end;

initialization
  RegisterFRMClass(Tgdc_dlgViewMovement);

finalization
  UnRegisterFRMClass(Tgdc_dlgViewMovement);
end.
