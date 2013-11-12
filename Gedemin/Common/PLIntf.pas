unit PLIntf;

interface

uses
  Windows, PLHeader;

var
  PL_initialise: TPL_initialise;
  PL_is_initialised: TPL_is_initialised;
  PL_cleanup: TPL_cleanup;
  PL_halt: TPL_halt;
  // Foreign context frames
  PL_open_foreign_frame: TPL_open_foreign_frame;
  PL_close_foreign_frame: TPL_close_foreign_frame;
  PL_discard_foreign_frame: TPL_discard_foreign_frame;
  PL_rewind_foreign_frame: TPL_rewind_foreign_frame;
  //
  PL_open_query: TPL_open_query;
  PL_next_solution: TPL_next_solution;
  PL_close_query: TPL_close_query;
  PL_cut_query: TPL_cut_query;
  PL_call: TPL_call;
  PL_call_predicate: TPL_call_predicate;

  PL_new_term_refs: TPL_new_term_refs;
  PL_new_term_ref: TPL_new_term_ref;
  PL_copy_term_ref: TPL_copy_term_ref;
  PL_reset_term_refs: TPL_reset_term_refs;
  PL_new_atom: TPL_new_atom;
  PL_new_atom_nchars: TPL_new_atom_nchars;
  PL_atom_chars: TPL_atom_chars;
  PL_atom_nchars: TPL_atom_nchars;
  PL_register_atom: TPL_register_atom;
  PL_unregister_atom: TPL_unregister_atom;
  PL_new_functor: TPL_new_functor;
  PL_functor_name: TPL_functor_name;
  PL_functor_arity: TPL_functor_arity;
  PL_get_atom: TPL_get_atom;
  PL_get_bool: TPL_get_bool;
  PL_get_atom_chars: TPL_get_atom_chars;
  PL_get_string: TPL_get_string;
  PL_get_chars: TPL_get_chars;
  PL_get_list_chars: TPL_get_list_chars;
  PL_get_atom_nchars: TPL_get_atom_nchars;
  PL_get_list_nchars: TPL_get_list_nchars;
  PL_get_nchars: TPL_get_nchars;
  PL_get_integer: TPL_get_integer;
  PL_get_long : TPL_get_long;
  PL_get_pointer: TPL_get_pointer;
  PL_get_float: TPL_get_float;
  PL_get_functor: TPL_get_functor;
  PL_get_name_arity: TPL_get_name_arity;
  PL_get_module: TPL_get_module;
  PL_get_arg: TPL_get_arg;
  PL_get_list: TPL_get_list;
  PL_get_head: TPL_get_head;
  PL_get_tail: TPL_get_tail;
  PL_get_nil: TPL_get_nil;
  PL_quote: TPL_quote;
  PL_get_int64: TPL_get_int64;
  PL_cons_functor_v: TPL_cons_functor_v;
  PL_put_variable: TPL_put_variable;
  PL_put_atom: TPL_put_atom;
  PL_put_atom_chars: TPL_put_atom_chars;
  PL_put_string_chars: TPL_put_string_chars;
  PL_put_list_chars: TPL_put_list_chars;
  PL_put_list_codes: TPL_put_list_codes;
  PL_put_atom_nchars: TPL_put_atom_nchars;
  PL_put_string_nchars: TPL_put_string_nchars;
  PL_put_list_nchars: TPL_put_list_nchars;
  PL_put_list_ncodes: TPL_put_list_ncodes;
  PL_put_integer: TPL_put_integer;
  PL_put_pointer: TPL_put_pointer;
  PL_put_float: TPL_put_float;
  PL_put_functor: TPL_put_functor;
  PL_put_list: TPL_put_list;
  PL_put_nil: TPL_put_nil;
  PL_put_term: TPL_put_term;
  PL_put_int64: TPL_put_int64;
  PL_term_type: TPL_term_type;
  PL_predicate: TPL_predicate;
  PL_chars_to_term: TPL_chars_to_term;
  PL_exception: TPL_exception;
  PL_raise_exception: TPL_raise_exception;
  PL_throw: TPL_throw;
  PL_pred: TPL_pred;
  PL_predicate_info: TPL_predicate_info;

function LoadPLDependentLibraries: Boolean;
procedure FreePLDependentLibraries;
procedure LoadPLLibrary;
procedure FreePLLibrary;
function GetPath: String;
function TryPLLoad: Boolean;

implementation

uses
  Sysutils, Forms; 

var
  PLLibrary: THandle;
  PLLibgmp10Library: THandle;
  PLPthreadGC2Library: THandle; 

function GetPath: String;
begin
  Result := ExtractFilePath(Application.EXEName) + 'swipl\';
end;

function LoadPLDependentLibraries: Boolean;
begin
  if PLPthreadGC2Library <= HINSTANCE_ERROR then
    PLPthreadGC2Library := LoadLibrary(PChar(GetPath + PthreadGC2_dll));
  if PLLibgmp10Library <= HINSTANCE_ERROR then
    PLLibgmp10Library := LoadLibrary(PChar(GetPath + Libgmp10_dll));

  Result := (PLLibgmp10Library > HINSTANCE_ERROR) and (PLPthreadGC2Library > HINSTANCE_ERROR);
end;

procedure LoadPLLibrary;

  function GetProcAddr(ProcName: PChar): Pointer;
  begin
    Result := GetProcAddress(PLLibrary, ProcName);
    if not Assigned(Result) then
      raise Exception.Create('Invalid function address!');
  end;

begin  
  PLLibrary := LoadLibrary(PChar(GetPath + libswipl_dll));
  if (PLLibrary > HINSTANCE_ERROR) then
  begin
    PL_initialise := GetProcAddr('PL_initialise');
    PL_is_initialised := GetProcAddr('PL_is_initialised');
    PL_cleanup := GetProcAddr('PL_cleanup');
    PL_halt := GetProcAddr('PL_halt');
    // Foreign context frames
    PL_open_foreign_frame := GetProcAddr('PL_open_foreign_frame');
    PL_close_foreign_frame := GetProcAddr('PL_close_foreign_frame');
    PL_discard_foreign_frame := GetProcAddr('PL_discard_foreign_frame');
    PL_rewind_foreign_frame := GetProcAddr('PL_rewind_foreign_frame');
    //
    PL_open_query := GetProcAddr('PL_open_query');
    PL_next_solution := GetProcAddr('PL_next_solution');
    PL_close_query := GetProcAddr('PL_close_query');
    PL_cut_query := GetProcAddr('PL_cut_query');
    PL_call := GetProcAddr('PL_call');
    PL_call_predicate := GetProcAddr('PL_call_predicate');
    PL_new_term_refs := GetProcAddr('PL_new_term_refs');
    PL_new_term_ref := GetProcAddr('PL_new_term_ref');
    PL_copy_term_ref := GetProcAddr('PL_copy_term_ref');
    PL_reset_term_refs := GetProcAddr('PL_reset_term_refs');
    PL_new_atom := GetProcAddr('PL_new_atom');
    PL_new_atom_nchars := GetProcAddr('PL_new_atom_nchars');
    PL_atom_chars := GetProcAddr('PL_atom_chars');
    PL_atom_nchars := GetProcAddr('PL_atom_nchars');
    PL_register_atom := GetProcAddr('PL_register_atom');
    PL_unregister_atom := GetProcAddr('PL_unregister_atom');
    PL_new_functor := GetProcAddr('PL_new_functor');
    PL_functor_name := GetProcAddr('PL_functor_name');
    PL_functor_arity := GetProcAddr('PL_functor_arity');
    PL_get_atom := GetProcAddr('PL_get_atom');
    PL_get_bool := GetProcAddr('PL_get_bool');
    PL_get_atom_chars := GetProcAddr('PL_get_atom_chars');
    PL_get_string := GetProcAddr('PL_get_string');
    PL_get_chars := GetProcAddr('PL_get_chars');
    PL_get_list_chars := GetProcAddr('PL_get_list_chars');
    PL_get_atom_nchars := GetProcAddr('PL_get_atom_nchars');
    PL_get_list_nchars := GetProcAddr('PL_get_list_nchars');
    PL_get_nchars := GetProcAddr('PL_get_nchars');
    PL_get_integer := GetProcAddr('PL_get_integer');
    PL_get_long := GetProcAddr('PL_get_long');
    PL_get_pointer := GetProcAddr('PL_get_pointer');
    PL_get_float := GetProcAddr('PL_get_float');
    PL_get_functor := GetProcAddr('PL_get_functor');
    PL_get_name_arity := GetProcAddr('PL_get_name_arity');
    PL_get_module := GetProcAddr('PL_get_module');
    PL_get_arg := GetProcAddr('PL_get_arg');
    PL_get_list := GetProcAddr('PL_get_list');
    PL_get_head := GetProcAddr('PL_get_head');
    PL_get_tail := GetProcAddr('PL_get_tail');
    PL_get_nil := GetProcAddr('PL_get_nil');
    PL_quote := GetProcAddr('PL_quote');
    PL_get_int64 := GetProcAddr('PL_get_int64');
    PL_cons_functor_v := GetProcAddr('PL_cons_functor_v');
    PL_put_variable := GetProcAddr('PL_put_variable');
    PL_put_atom := GetProcAddr('PL_put_atom');
    PL_put_atom_chars := GetProcAddr('PL_put_atom_chars');
    PL_put_string_chars := GetProcAddr('PL_put_string_chars');
    PL_put_list_chars := GetProcAddr('PL_put_list_chars');
    PL_put_list_codes := GetProcAddr('PL_put_list_codes');
    PL_put_atom_nchars := GetProcAddr('PL_put_atom_nchars');
    PL_put_string_nchars := GetProcAddr('PL_put_string_nchars');
    PL_put_list_nchars := GetProcAddr('PL_put_list_nchars');
    PL_put_list_ncodes := GetProcAddr('PL_put_list_ncodes');
    PL_put_integer := GetProcAddr('PL_put_integer');
    PL_put_pointer := GetProcAddr('PL_put_pointer');
    PL_put_float := GetProcAddr('PL_put_float');
    PL_put_functor := GetProcAddr('PL_put_functor');
    PL_put_list := GetProcAddr('PL_put_list');
    PL_put_nil := GetProcAddr('PL_put_nil');
    PL_put_term := GetProcAddr('PL_put_term');
    PL_put_int64 := GetProcAddr('PL_put_int64');
    PL_term_type := GetProcAddr('PL_term_type');
    PL_predicate := GetProcAddr('PL_predicate');
    PL_chars_to_term := GetProcAddr('PL_chars_to_term');
    PL_exception := GetProcAddr('PL_exception');
    PL_raise_exception := GetProcAddr('PL_raise_exception');
    PL_throw := GetProcAddr('PL_throw');
    PL_pred := GetProcAddr('PL_pred');
    PL_predicate := GetProcAddr('PL_predicate');
    PL_predicate_info := GetProcAddr('PL_predicate_info');
  end;
end;

procedure FreePLLibrary;
begin
  if PLLibrary > HINSTANCE_ERROR then
  begin
    FreeLibrary(PLLibrary);
    PLLibrary := 0;
  end;
end;

procedure FreePLDependentLibraries;
begin
  if PLPthreadGC2Library > HINSTANCE_ERROR then
  begin
    FreeLibrary(PLPthreadGC2Library);
    PLPthreadGC2Library := 0;
  end;

  if PLLibgmp10Library > HINSTANCE_ERROR then
  begin
    FreeLibrary(PLLibgmp10Library);
    PLLibgmp10Library := 0;
  end;  
end;

function TryPLLoad: Boolean;
begin
  Result := LoadPLDependentLibraries;

  if not Result then
    exit;

  if (PLLibrary <= HINSTANCE_ERROR) then
    LoadPLLibrary;

  Result := PLLibrary > HINSTANCE_ERROR;
end;

initialization

finalization
  FreePLLibrary;
  FreePLDependentLibraries;   
end.
