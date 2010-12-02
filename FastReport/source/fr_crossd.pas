unit fr_crossd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TDictionaryForm = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DictionaryForm: TDictionaryForm;

implementation

{$R *.DFM}

initialization
  DictionaryForm := TDictionaryForm.Create(nil);

finalization
  DictionaryForm.Free;

end.
