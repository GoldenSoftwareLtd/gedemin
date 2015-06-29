unit boMeasure;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  boObject, DBTables;

type
  TboMeasure = class(TboObject)
  private
  public
    function AddMeasure(name: String; parent: Integer; var Key: Integer): Boolean;
    function EditMeasure(Measurekey: Integer): Boolean;
    function DeleteMeasure(Measurekey: Integer): Boolean;
    function Replacemeasure(measureKey, Groupmeasure: Integer): Boolean;
  published
  end;

  TboCollection = class(TboObject)
  private
  public
    function Addcollection(name: String; parent: Integer; var Key: Integer): Boolean;
    function Editcollection(collectionkey: Integer): Boolean;
    function Deletecollection(collectionkey: Integer): Boolean;
    function ReplaceCollection(CollectionKey, GroupCollection: Integer): Boolean;
  end;

procedure Register;

implementation

uses
  dlgMeasure_unit, dlgCollection_unit;

function TboMeasure.AddMeasure(name: String; parent: Integer;
  var Key: Integer): Boolean;
var
  dlgMeasure: TdlgMeasure;
begin
  dlgMeasure := TdlgMeasure.Create(nil);
  try
    dlgMeasure.tblMeasure.Open;
    dlgMeasure.tblMeasure.Append;
    if Parent <> 0 then
      dlgMeasure.tblMeasure.FieldByName('parent').AsInteger := Parent;
    dlgMeasure.Parent := Parent;
    dlgMeasure.tblMeasure.FieldByName('name').AsString := name;
    Result := dlgMeasure.ShowModal = mrOk;
    if Result then
    begin
      dlgMeasure.tblMeasure.Refresh;
      Key := dlgMeasure.tblMeasure.FieldByName('id').AsInteger
    end;
  finally
    dlgMeasure.Free;
  end;
end;

function TboMeasure.EditMeasure(Measurekey: Integer): Boolean;
var
  dlgMeasure: TdlgMeasure;
begin
  dlgMeasure := TdlgMeasure.Create(nil);
  try
    dlgMeasure.tblMeasure.Open;
    dlgMeasure.mbbNext.Visible := False;
    if dlgMeasure.tblMeasure.FindKey([Measurekey]) then
    begin
      dlgMeasure.tblMeasure.Edit;
      Result := dlgMeasure.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgMeasure.Free;
  end;
end;

function TboMeasure.DeleteMeasure(Measurekey: Integer): Boolean;
var
  tblMeasure: TTable;
begin
  Result := False;
  tblMeasure := TTable.Create(Self);
  try
    tblMeasure.DatabaseName := DataBaseName;
    tblMeasure.TableName := 'fin_measure';
    tblMeasure.Open;
    if tblMeasure.FindKey([Measurekey]) and
      (MessageBox(Application.Handle, 'Удалить запись?', 'Внимание',
          MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      try
        tblMeasure.Delete;
        Result := True;
      except
        MessageBox(Application.Handle, 'Данная запись уже где-то используется!', 'Внимание',
          MB_ICONEXCLAMATION);
      end;
    end
  finally
    tblMeasure.Free;
  end;
end;

function Tbomeasure.ReplaceMeasure(MeasureKey, Groupmeasure: Integer): Boolean;
var
  spTestReplacemeasure: TStoredProc;
  qryMeasure: TQuery;

begin
  Result := measureKey = Groupmeasure;
  if not Result then
  begin
    spTestReplacemeasure := TStoredProc.Create(Self);
    try
      spTestReplacemeasure.DataBaseName := DataBaseName;
      if Groupmeasure <> 0 then
      begin
        spTestReplacemeasure.StoredProcName := 'fin_p_testreplacemeasure';
        spTestReplacemeasure.Prepare;
        spTestReplacemeasure.ParamByName('measurekey').AsInteger := measureKey;
        spTestReplacemeasure.ParamByName('groupmeasure').AsInteger := Groupmeasure;
        spTestReplacemeasure.ExecProc;
        Result := spTestReplacemeasure.ParamByName('replace').AsInteger = 1;
      end
      else
        Result := True;
      if Result then
      begin
        qrymeasure := TQuery.Create(Self);
        try
          qrymeasure.DatabaseName := DataBaseName;
          if groupmeasure <> 0 then
            qrymeasure.SQL.Text := Format('UPDATE fin_measure SET fin_measure.parent = %d ' +
              'WHERE fin_measure.id = %d ', [groupmeasure, measurekey])
          else
            qrymeasure.SQL.Text := Format('UPDATE fin_measure SET fin_measure.parent = NULL ' +
              'WHERE fin_measure.id = %d ', [measurekey]);
          qrymeasure.ExecSQL;
        finally
          qrymeasure.Free;
        end;
      end;
    finally
      spTestReplacemeasure.Free;
    end;
  end;
end;

function TboCollection.ReplaceCollection(CollectionKey, GroupCollection: Integer): Boolean;
var
  spTestReplaceCollection: TStoredProc;
  qryCollection: TQuery;

begin
  Result := CollectionKey = GroupCollection;
  if not Result then
  begin
    spTestReplaceCollection := TStoredProc.Create(Self);
    try
      spTestReplaceCollection.DataBaseName := DataBaseName;
      if GroupCollection <> 0 then
      begin
        spTestReplaceCollection.StoredProcName := 'fin_p_testreplaceCollection';
        spTestReplaceCollection.Prepare;
        spTestReplaceCollection.ParamByName('Collectionkey').AsInteger := CollectionKey;
        spTestReplaceCollection.ParamByName('groupCollection').AsInteger := GroupCollection;
        spTestReplaceCollection.ExecProc;
        Result := spTestReplaceCollection.ParamByName('replace').AsInteger = 1;
      end
      else
        Result := True;
      if Result then
      begin
        qryCollection := TQuery.Create(Self);
        try
          qryCollection.DatabaseName := DataBaseName;
          if groupCollection <> 0 then
            qryCollection.SQL.Text := Format('UPDATE fin_Collection SET fin_Collection.parent = %d ' +
              'WHERE fin_Collection.id = %d ', [groupCollection, Collectionkey])
          else
            qryCollection.SQL.Text := Format('UPDATE fin_Collection SET fin_Collection.parent = NULL ' +
              'WHERE fin_Collection.id = %d ', [Collectionkey]);
          qryCollection.ExecSQL;
        finally
          qryCollection.Free;
        end;
      end;
    finally
      spTestReplaceCollection.Free;
    end;
  end;
end;

function Tbocollection.Addcollection(name: String; parent: Integer;
  var Key: Integer): Boolean;
var
  dlgcollection: TdlgCollection;
begin
  dlgcollection := Tdlgcollection.Create(nil);
  try
    dlgCollection.tblCollection.Open;
    dlgCollection.tblRelation.Open;
    dlgCollection.tblCollection.Append;
    dlgCollection.spGetCollection.ExecProc;
    dlgCollection.CollectionKey :=
      dlgCollection.spGetCollection.ParamByName('collectionkey').AsInteger;
    if Parent <> 0 then
      dlgCollection.tblCollection.FieldByName('parent').AsInteger := Parent;
    dlgCollection.tblCollection.FieldByName('id').AsInteger :=
      dlgCollection.CollectionKey;
    dlgCollection.tblCollection.FieldByName('name').AsString := name;
    dlgCollection.Parent := Parent;
    Result := dlgCollection.ShowModal = mrOk;
    if Result then
    begin
      dlgCollection.tblCollection.Refresh;
      Key := dlgCollection.tblCollection.FieldByName('id').AsInteger
    end;
  finally
    dlgCollection.Free;
  end;
end;

function Tbocollection.Editcollection(collectionkey: Integer): Boolean;
var
  dlgcollection: Tdlgcollection;
begin
  dlgcollection := Tdlgcollection.Create(nil);
  try
    dlgcollection.tblcollection.Open;
    dlgcollection.tblRelation.Open;
    dlgcollection.mbbNext.Visible := False;
    dlgcollection.CollectionKey := CollectionKey;
    if dlgcollection.tblcollection.FindKey([collectionkey]) then
    begin
      dlgcollection.tblCollection.Edit;
      Result := dlgcollection.ShowModal = mrOk;
    end
    else
      Result := False;
  finally
    dlgcollection.Free;
  end;
end;

function Tbocollection.Deletecollection(collectionkey: Integer): Boolean;
var
  tblcollection: TTable;
begin
  Result := False;
  tblcollection := TTable.Create(Self);
  try
    tblcollection.DatabaseName := DataBaseName;
    tblcollection.TableName := 'fin_collection';
    tblcollection.Open;
    if tblcollection.FindKey([collectionkey]) and
      (MessageBox(Application.Handle, 'Удалить запись?', 'Внимание',
          MB_ICONQUESTION + MB_YESNO) = mrYes) then
    begin
      try
        tblcollection.Delete;
        Result := True;
      except
        MessageBox(Application.Handle, 'Данная запись уже где-то используется!', 'Внимание',
          MB_ICONEXCLAMATION);
      end;
    end
  finally
    tblcollection.Free;
  end;
end;

procedure Register;
begin
  RegisterComponents('gsBO', [TboMeasure]);
  RegisterComponents('gsBO', [TboCollection]);
end;

end.
