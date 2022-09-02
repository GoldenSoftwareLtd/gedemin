// ShlTanya, 10.03.2019

unit flt_i_SQLProposal;

interface

uses
  Classes, at_classes;

type
  ISQLProposal = interface
  ['{5BD7CB0B-EFAD-4454-A911-2643E745634A}']
    function GetInsertList: TStrings;
    function GetItemList: TStrings;
    function GetFieldItemList: TStrings;
    function GetFieldInsertList: TStrings;
    procedure FillItemList;
    procedure FillInsertList(SL: TStrings; Field: Boolean = False);
    procedure FillFieldItem(const atRelation: TatRelation);
    function FindTable(const Str: String; const SQL: TStrings): String;
    procedure PrepareSQL(Alias: String; const SQL: TStrings);
    function GetStatement(var Str: String; Pos: Integer): String;
    procedure Free;
    property FieldItemList: TStrings read GetFieldItemList;
    property FieldInsertList: TStrings read GetFieldInsertList;
    property ItemList: TStrings read GetItemList;
    property InsertList: TStrings read GetInsertList;
  end;

var
  SQLProposal: ISQLProposal;

implementation

end.
