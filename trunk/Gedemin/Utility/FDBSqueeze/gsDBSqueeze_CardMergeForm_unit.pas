unit gsDBSqueeze_CardMergeForm_unit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Grids;

type
  TgsDBSqueeze_CardMergeForm = class(TForm)
    strngrdIgnoreDocTypes: TStringGrid;
    txt5: TStaticText;
    txt1: TStaticText;
    tvDocTypes: TTreeView;
    mIgnoreDocTypes: TMemo;
    txt2: TStaticText;
    mmo1: TMemo;
    btnMergeGo: TButton;
    dtpClosingDate: TDateTimePicker;
    btn1: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  gsDBSqueeze_CardMergeForm: TgsDBSqueeze_CardMergeForm;

implementation

{$R *.DFM}

end.
