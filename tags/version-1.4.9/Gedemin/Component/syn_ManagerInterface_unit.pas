unit syn_ManagerInterface_unit;

interface

uses
  SynEditHighlighter, SynEdit, Classes, Graphics, SynEditKeyCmds;

type
  TSynEditProperty = record
    AutoIndentMode: Boolean;
    InsertMode: Boolean;
    SmartTab: Boolean;
    TabToSpaces: Boolean;
    GroupUndo: Boolean;
    CursorBeyondEOF: Boolean;
    UndoAfterSave: Boolean;
    KeepTrailingBlanks: Boolean;
    FindTextAtCursor: Boolean;
    UseSyntaxHilight: Boolean;
    VisibleRightMargine: Boolean;
    VisibleGutter: Boolean;
    RightMargin: Integer;
    GutterWidth: Integer;
    UndoLimit: Integer;
    TabWidth: Integer;
  end;

type
  ISynManager = interface
  ['{8092303F-CDFE-11D5-B60A-00C0DF0E09D1}']
    function Get_Component: TObject;
    procedure GetSynEditOptions(const ASynEdit: TSynEdit);
    procedure GetHighlighterOptions(const AnHighLighter: TSynCustomHighLighter);
    function GetHighlighterFont: TFont;
    procedure SaveToStream(const AnStream: TStream);
    procedure LoadFromStream(const AnStream: TStream);
    function ExecuteDialog: Boolean;
    //Возвращает текущую настройку кнопок
    function GetKeyStroke: TSynEditKeyStrokes;
  end;

var
  SynManager: ISynManager;
  SynEditProperty: TSynEditProperty;

implementation

initialization
  SynManager := nil;

finalization
//  SynManager := nil;

end.
