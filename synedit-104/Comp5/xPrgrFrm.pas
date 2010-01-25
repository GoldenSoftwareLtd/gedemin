
{++

  Copyright (c) 1996-97 by Golden Software of Belarus

  Module

    xprgrfrm.pas

  Abstract

    A progress form.

  Author

    Andrei Kireev (28-Sep-96)

  Contact address

    andreik@gs.minsk.by

  Revisions history

    1.00    28-Sep-96    andreik    Initial version.
    1.01    17-Feb-97    andreik    Minor change.
    1.02    25-Feb-97    andreik    Prepare query added.
    1.03    05-Apr-97    andreik    Reopen has been changed so it opens
                                    just active data sets.
    1.04    07-Apr-97    andreik    Minor change.
    1.05    01-Jun-97    andreik    Cancel button added.
    1.06    02-Aug-97    andreik    Debug info added.
    1.07    12-Aug-97    andreik    Minor change. 
    1.08    25-Nov-97    andreik    Minor change. 

--}

unit xPrgrFrm;

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, DB, DBTables, xProgr, ExtCtrls;

type
  TxProgressBox = class(TForm)
    RunningMan: TxRunningMan;
    lWait: TLabel;

  private
    function GetParam(Index: Integer): Integer;
    procedure SetParam(Index: Integer; AParam: Integer);

  public
    property Value: Integer index 1 read GetParam write SetParam;
    property Min: Integer index 2 read GetParam write SetParam;
    property Max: Integer index 3 read GetParam write SetParam;
  end;

type
  TxProgressForm = class(TComponent)
  private
    ProgressBox: TxProgressBox;

    procedure SetParam(Index: Integer; Param: Integer);
    function GetParam(Index: Integer): Integer;

    function GetCaption: String;
    procedure SetCaption(ACaption: String);
    function GetWaitMessage: String;
    procedure SetWaitMessage(AWaitMessage: String);

  public
    constructor Create(AnOwner: TComponent); override;

    procedure Show;
    procedure Hide;

    property Value: Integer index 1 read GetParam write SetParam;
    property Min: Integer index 2 read GetParam write SetParam;
    property Max: Integer index 3 read GetParam write SetParam;

  published
    property Caption: String read GetCaption write SetCaption;
    property WaitMessage: String read GetWaitMessage write SetWaitMessage;
  end;

procedure OpenDataSets(const DataSets: array of TDBDataSet;
  const PrepareQueries, CancelAble: Boolean);
procedure ReopenDataSets(const DataSets: array of TDBDataSet; ForceOpen: Boolean);

var
  OpenDataSetsDebug: Boolean;

procedure Register;

implementation

{$R *.DFM}

procedure OpenDataSets(const DataSets: array of TDBDataSet;
  const PrepareQueries, CancelAble: Boolean);
var
  I: Integer;
  ProgressForm: TxProgressForm;
  Time: LongInt;
begin
  for I := Low(DataSets) to High(DataSets) do
    if not DataSets[I].Active then break;

  if (I = High(DataSets)) and DataSets[High(DataSets)].Active then
    exit; { all are open already }

  Time := GetCurrentTime;

  ProgressForm := TxProgressForm.Create(Application);
  ProgressForm.WaitMessage := 'Идет открытие баз данных...';
  try
    ProgressForm.Min := Low(DataSets);
    ProgressForm.Max := High(DataSets);
    ProgressForm.Value := Low(DataSets);

    ProgressForm.Show;

    for I := Low(DataSets) to High(DataSets) do
    begin
      ProgressForm.Value := I;
      if OpenDataSetsDebug then
      begin
        ProgressForm.WaitMessage :=
          Format('Идет открытие баз данных (%s, %d)...',
          [DataSets[I].Name, (GetCurrentTime - Time) div 1000]);
      end;
      Application.ProcessMessages;

      if PrepareQueries and (DataSets[I] is TQuery) 
          and (not (DataSets[I] as TQuery).Prepared) then
      begin
        if not (DataSets[I] as TQuery).Active then
        begin
          (DataSets[I] as TQuery).Prepare;
          Application.ProcessMessages;
        end;
      end;

      DataSets[I].Open;
    end;
  finally
    ProgressForm.Hide;
    ProgressForm.Free;
  end;
end;

procedure ReopenDataSets(const DataSets: array of TDBDataSet; ForceOpen: Boolean);
var
  I: Integer;
  ProgressForm: TxProgressForm;
begin
  if High(DataSets) - Low(DataSets) = 0 then
  begin
    if DataSets[0].Active or ForceOpen then
    begin
      DataSets[0].Close;
      DataSets[0].Open;
    end;

    exit;
  end;

  ProgressForm := TxProgressForm.Create(Application);
  ProgressForm.WaitMessage := 'Идет обновление баз данных...';
  try
    ProgressForm.Min := Low(DataSets);
    ProgressForm.Max := High(DataSets);
    ProgressForm.Value := Low(DataSets);

    ProgressForm.Show;

    for I := Low(DataSets) to High(DataSets) do
    begin
      ProgressForm.Value := I;
      Application.ProcessMessages;

      if DataSets[I].Active or ForceOpen then
      begin
        DataSets[I].Close;
        DataSets[I].Open;
      end;
    end;
  finally
    ProgressForm.Hide;
    ProgressForm.Free;
  end;
end;

{ TxProgressForm -----------------------------------------}

constructor TxProgressForm.Create(AnOwner: TComponent);
begin
  inherited Create(AnOwner);
  ProgressBox := TxProgressBox.Create(Self);
  ProgressBox.Visible := False;
end;

procedure TxProgressForm.Show;
begin
  ProgressBox.Show;
end;

procedure TxProgressForm.Hide;
begin
  ProgressBox.Hide;
end;

procedure TxProgressForm.SetParam(Index: Integer; Param: Integer);
begin
  ProgressBox.SetParam(Index, Param);
end;

function TxProgressForm.GetParam(Index: Integer): Integer;
begin
  Result := ProgressBox.GetParam(Index);
end;

function TxProgressForm.GetCaption: String;
begin
  Result := ProgressBox.Caption;
end;

procedure TxProgressForm.SetCaption(ACaption: String);
begin
  ProgressBox.Caption := ACaption;
end;

function TxProgressForm.GetWaitMessage: String;
begin
  Result := ProgressBox.lWait.Caption;
end;

procedure TxProgressForm.SetWaitMessage(AWaitMessage: String);
begin
  ProgressBox.lWait.Caption := ' ' + AWaitMessage;
end;

{ TxProgressBox ------------------------------------------}

function TxProgressBox.GetParam(Index: Integer): Integer;
begin
  case Index of
    1: Result := RunningMan.Value;
    2: Result := RunningMan.Min;
    3: Result := RunningMan.Max;
  else
    raise Exception.Create('Invalid index');
  end;
end;

procedure TxProgressBox.SetParam(Index: Integer; AParam: Integer);
begin
  case Index of
    1: RunningMan.Value := AParam;
    2: RunningMan.Min := AParam;
    3: RunningMan.Max := AParam;
  end;
end;

{ Registration -------------------------------------------}

procedure Register;
begin
  RegisterComponents('xTool-3', [TxProgressForm]);
end;

initialization
  OpenDataSetsDebug := True;
end.

