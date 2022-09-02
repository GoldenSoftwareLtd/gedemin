// ShlTanya, 26.02.2019

{++

  Copyright (c) 2001 by Golden Software of Belarus

  Module

    prp_i_VBProposal.pas

  Abstract

    Gedemin project. IVBProposal.

  Author

    Karpuk Alexander

  Revisions history

    1.00    08.08.01    tiptop        Initial version.

--}

unit prp_i_VBProposal;

interface
uses classes;
type
  IVBProposal = interface
  ['{5362ED7D-3509-4B24-9D94-9F6CCDEC97E7}']
    function GetFKObjects: TStrings;
    function GetInsertList: TStrings;
    function GetItemList: TStrings;
    function GetOnCreateObject: TNotifyEvent;
    function GetReservedDesignators: TStrings;
    function GetReservedWords: TStrings;
    procedure SetOnCreateObject(const Value: TNotifyEvent);
    procedure SetFKObjects(const Value: TStrings);
    function GetComponentName: String;
    function GetDefiniteVaryList: TStrings;
    function GetObjects: TStrings;
    function GetComponent: TComponent;
    procedure SetComponent(const Value: TComponent);
    procedure SetComponentName(const Value: String);
    procedure CreateObject;

    procedure PrepareScript(const ScriptName: String; const Script: TStrings;
      AtLine: Integer = - 1);
    procedure AddObject(Name: string; const Object_: IDispatch; AddMembers: Boolean);
    procedure ShowDefaultProposal;
    procedure Free;
    procedure AddFKObject(Name: String; AObject: TObject);
    procedure ClearFKObjects;

    property DefiniteVaryList: TStrings read GetDefiniteVaryList;
    property Objects: TStrings read GetObjects;
    property ComponentName: String read GetComponentName write SetComponentName;
    property ItemList: TStrings read GetItemList;
    property InsertList: TStrings read GetInsertList;
{    property ReservedWords: TStrings read GetReservedWords;
    property ReservedDesignators: TStrings read GetReservedDesignators;
    property FKObjects: TStrings read GetFKObjects write SetFKObjects;}
    property OnCreateObject: TNotifyEvent read GetOnCreateObject write SetOnCreateObject;
    property Component: TComponent read GetComponent write SetComponent;
  end;

var
  VBProposal: IVBProposal;

implementation

end.
