{++


  Copyright (c) 2001 by Golden Software of Belarus

  Module

    tax_frmAnalytics_unit.pas

  Abstract

    Form for forming analytics.

  Author

    Dubrovnik Alexander (DAlex)
    Karpuk Alexander(TiptTop
  Revisions history

    1.00    07.02.03    DAlex      Initial version.
    2.00    23.02.04    TipTop     Все нахрен переделано.
--}

unit tax_frmAnalytics_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, gsIBLookupComboBox, Buttons, Grids, ActnList,
  wiz_frAnalytics_unit, wiz_frFixedAnalytics_unit, wiz_FunctionBlock_unit;

type
  TfrmAnalytics = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    pnlMain: TPanel;
    ActionList: TActionList;
    actOk: TAction;
    actCancel: TAction;
    Panel3: TPanel;
    mValue: TMemo;
    cbAnalyticName: TCheckBox;
    frFixedAnalytics: TfrFixedAnalytics;
    Timer1: TTimer;
    procedure actOkExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FBlock: TVisualBlock;
    function GetAnalNameArrayStr: String;
    function GetAnalValueArrayStr: String;
    function GetAnalytics: String;
    procedure SetBlock(const Value: TVisualBlock);
    procedure ValueUpdate;
  public
    property AnalNameArrayStr: String read GetAnalNameArrayStr;
    property AnalValueArrayStr: String read GetAnalValueArrayStr;
    property Analytics: String read GetAnalytics;
    property Block: TVisualBlock read FBlock write SetBlock;
  end;

var
  frmAnalytics: TfrmAnalytics;

implementation

uses
  gdcBaseInterface, at_classes;

{$R *.DFM}

const
  taEquals = ' = ';
  taSepar  = '; ';

function TfrmAnalytics.GetAnalNameArrayStr: String;
begin
end;

function TfrmAnalytics.GetAnalValueArrayStr: String;
begin
end;

function TfrmAnalytics.GetAnalytics: String;
begin
  Result := frFixedAnalytics.Analytics;
end;


procedure TfrmAnalytics.actOkExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmAnalytics.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmAnalytics.SetBlock(const Value: TVisualBlock);
begin
  FBlock := Value;
  frFixedAnalytics.Block := FBlock;
  frFixedAnalytics.UpdateAnalytics;
end;

procedure TfrmAnalytics.ValueUpdate;
begin
  frFixedAnalytics.ShowAnalyticName := cbAnalyticName.Checked;
  mValue.Lines.text := GetAnalytics;
end;

procedure TfrmAnalytics.Timer1Timer(Sender: TObject);
begin
  ValueUpdate;
end;

end.
