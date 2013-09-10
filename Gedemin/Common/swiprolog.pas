unit swiprolog;

{$DEFINE vsersionswin}


////////////////////////////////////////////////////////////////////////////////
//
// This file is a part of the Delphi - SWI-Prolog interface
//
// Author: Mikhail Balabanov
//
////////////////////////////////////////////////////////////////////////////////

{$IFNDEF PLVERSION}
{$DEFINE PLVERSION 50203}
{$ENDIF}



interface

{$IFDEF win32}uses windows; {$ENDIF}


////////////////////////////////////////////////////////////////////////////////
// TYPES
////////////////////////////////////////////////////////////////////////////////
type
  //PL_engine_t = ^PL_local_data; ???
  size_t = Cardinal;
  atom_t = LongWord; // Prolog atom
  module_t = Pointer; // Prolog module
  predicate_t = Pointer; // Prolog procedure
  record_t = Pointer; // Prolog recorded term
  term_t = LongWord; // opaque term handle
  qid_t = LongWord; // opaque query handle
  fid_t = LongWord; // opaque foreign context handle
  functor_t = LongWord; // Name/arity pair
  atomic_t = LongWord; // same a word
  control_t = LongWord; // non-deterministic control arg
  foreign_t = LongWord; // return type of foreign functions
// CPP:
  pl_function_t = Pointer; // can only pass function as void *
// C:
//  pl_function_t = function(): foreign_t; // foreign language functions

  term_value_t = packed record
    case Integer of
      0: (i: Integer); // PL_INTEGER
      1: (f: Double); // PL_FLOAT
      2: (s: PChar); // PL_STRING
      3: (a: atom_t); // PL_ATOM
      4: (t: record name: atom_t; arity: Integer; end) // PL_TERM
  end;

////////////////////////////////////////////////////////////////////////////////
// TERM TYPE CONSTANTS
////////////////////////////////////////////////////////////////////////////////
const
  // PL_unify_term() arguments
  PL_VARIABLE = 1; // nothing
  PL_ATOM = 2; // const char *
  PL_INTEGER = 3; // int
  PL_FLOAT = 4; // double
  PL_STRING = 5; // const char *
  PL_TERM = 6;

  // PL_unify_term ()
  PL_FUNCTOR = 10; // functor_t, arg ...
  PL_LIST = 11; // length, arg ...
  PL_CHARS = 12; // const char *
  PL_POINTER = 13; // void *

  // PlArg::PlArg = (text, type)
  PL_CODE_LIST = 14; // [ascii...]
  PL_CHAR_LIST = 15; // [h,e,l,l,o]
  PL_BOOL = 16; // PL_set_feature ()
  PL_FUNCTOR_CHARS = 17; // PL_unify_term ()
  _PL_PREDICATE_INDICATOR = 18; // predicate_t (Procedure)
  PL_SHORT = 19; // short
  PL_INT = 20; // int
  PL_LONG = 21; // long
  PL_DOUBLE = 22; // double
  PL_NCHARS = 23; // unsigned, const char *

////////////////////////////////////////////////////////////////////////////////
// DETERMINISTIC CALL/RETURN
////////////////////////////////////////////////////////////////////////////////
//#define	PL_succeed	return TRUE	/* succeed deterministically */
//#define PL_fail		return FALSE	/* fail */



////////////////////////////////////////////////////////////////////////////////
// NON-DETERMINISTIC CALL/RETURN
////////////////////////////////////////////////////////////////////////////////
// Note 1: Non-deterministic foreign functions may also use the deterministic
// return methods PL_succeed and PL_fail.
//
// Note 2: The argument to PL_retry is a 30 bits signed integer (long).

const
  PL_FIRST_CALL = 0;
  PL_CUTTED = 1;
  PL_REDO = 2;
{
#define PL_retry(n)		return _PL_retry(n)
#define PL_retry_address(a)	return _PL_retry_address(a)
function _PL_retry(P: LongInt): foreign_t; cdecl; external 'libswipl.dll';
function _PL_retry_address(A: Pointer): foreign_t; cdecl; external 'libswipl.dll';
}


{$IFDEF WIN32}



function _PL_retry(p: LongInt): foreign_t; cdecl; external 'libswipl.dll';
function _PL_retry_address(a: Pointer): foreign_t; cdecl; external 'libswipl.dll';
function PL_foreign_control(c: control_t): Integer; cdecl; external 'libswipl.dll';
function PL_foreign_context(c: control_t): LongInt; cdecl; external 'libswipl.dll';
function PL_foreign_context_address(c: control_t): Pointer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// REGISTERING FOREIGNS
////////////////////////////////////////////////////////////////////////////////
type
  PL_extension = packed record
    predicate_name: PChar; // Name of the predicate
    arity: SmallInt; // Arity of the predicate
    function_: pl_function_t; // Implementing functions
    flags: SmallInt; // Or of PL_FA_...
  end;

const
  PL_FA_NOTRACE = $01; // foreign cannot be traced
  PL_FA_TRANSPARENT = $02; // foreign is module transparent
  PL_FA_NONDETERMINISTIC = $04; // foreign is non-deterministic
  PL_FA_VARARGS = $08; // call using t0, ac, ctx


//extern PL_extension PL_extensions[]; /* not Win32! */
procedure PL_register_extensions(var e: PL_extension); cdecl; external 'libswipl.dll';
procedure PL_load_extensions(var e: PL_extension); cdecl; external 'libswipl.dll';
function PL_register_foreign(name: PChar;
  arity: Integer;
  func: pl_function_t;
  flags: Integer): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// LICENSE
////////////////////////////////////////////////////////////////////////////////

//procedure PL_license(license, module: PChar); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// MODULES
////////////////////////////////////////////////////////////////////////////////
function PL_context(): module_t; cdecl; external 'libswipl.dll';
function PL_module_name(module: module_t): atom_t; cdecl; external 'libswipl.dll';
function PL_new_module(name: atom_t): module_t; cdecl; external 'libswipl.dll';
function PL_strip_module(in_: term_t; var m: module_t; out_: term_t): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// CALL-BACK
////////////////////////////////////////////////////////////////////////////////
const
  PL_Q_DEBUG = $01; // (!) = TRUE for backward compatibility
  PL_Q_NORMAL = $02; // normal usage
  PL_Q_NODEBUG = $04; // use this one
  PL_Q_CATCH_EXCEPTION = $08; // handle exceptions in C
  PL_Q_PASS_EXCEPTION = $10; // pass to parent environment
  PL_Q_DETERMINISTIC = $20; // (!) call was deterministic
  MON_PL_Q = $04 + $20;

// Foreign context frames
function PL_open_foreign_frame(): fid_t; cdecl; external 'libswipl.dll';
procedure PL_rewind_foreign_frame(cid: fid_t); cdecl; external 'libswipl.dll';
procedure PL_close_foreign_frame(cid: fid_t); cdecl; external 'libswipl.dll';
procedure PL_discard_foreign_frame(cid: fid_t); cdecl; external 'libswipl.dll';

// Finding predicates
function PL_pred(f: functor_t; m: module_t): predicate_t; cdecl; external 'libswipl.dll';
function PL_predicate(name: PChar;
  arity: Integer;
  module: PChar): predicate_t; cdecl; external 'libswipl.dll';
function PL_predicate_info(pred: predicate_t;
  var name: atom_t;
  var arity: Integer;
  var module: module_t): Integer; cdecl; external 'libswipl.dll';

// Call-back
function PL_open_query(m: module_t;
  flags: Integer;
  pred: predicate_t;
  t0: term_t): qid_t; cdecl; external 'libswipl.dll';
function PL_next_solution(qid: qid_t): smallint; cdecl; external 'libswipl.dll';
procedure PL_close_query(qid: qid_t); cdecl; external 'libswipl.dll';
procedure PL_cut_query(qid: qid_t); cdecl; external 'libswipl.dll';

// Simplified (but less flexible) call-back
function PL_call(t: term_t; m: module_t): Integer; cdecl; external 'libswipl.dll';
function PL_call_predicate(m: module_t;
  debug: Integer;
  pred: predicate_t;
  t0: term_t): Integer; cdecl; external 'libswipl.dll';

// Handling exceptions
function PL_exception(qid: qid_t): term_t; cdecl; external 'libswipl.dll';
function PL_raise_exception(exception: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_throw(exception: term_t): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// TERM REFERENCES
////////////////////////////////////////////////////////////////////////////////

// Creating and destroying term-refs
function PL_new_term_refs(n: Integer): term_t; cdecl; external 'libswipl.dll';
function PL_new_term_ref(): term_t; cdecl; external 'libswipl.dll';
function PL_copy_term_ref(from: term_t): term_t; cdecl; external 'libswipl.dll';
procedure PL_reset_term_refs(r: term_t); cdecl; external 'libswipl.dll';

// Constants
function PL_new_atom(s: PChar): atom_t; cdecl; external 'libswipl.dll';
function PL_new_atom_nchars(len: Cardinal; s: PChar): atom_t; cdecl; external 'libswipl.dll';
function PL_atom_chars(a: atom_t): PChar; cdecl; external 'libswipl.dll';
function PL_atom_nchars(a: atom_t; var len: Cardinal): PChar; cdecl; external 'libswipl.dll';
{$IFNDEF O_DEBUG_ATOMGC}
procedure PL_register_atom(a: atom_t); cdecl; external 'libswipl.dll';
procedure PL_unregister_atom(a: atom_t); cdecl; external 'libswipl.dll';
{$ENDIF}
function PL_new_functor(f: atom_t; a: Integer): functor_t; cdecl; external 'libswipl.dll';
function PL_functor_name(f: functor_t): atom_t; cdecl; external 'libswipl.dll';
function PL_functor_arity(f: functor_t): Integer; cdecl; external 'libswipl.dll';

// Get C(Pascal) values from Prolog terms
function PL_get_atom(t: term_t; var a: atom_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_bool(t: term_t; var value: Integer): Integer; cdecl; external 'libswipl.dll';
function PL_get_atom_chars(t: term_t; var a: PChar): Integer; cdecl; external 'libswipl.dll';

// TODO
//#define PL_get_string_chars(t, s, l) PL_get_string(t,s,l)
//					/* PL_get_string() is depreciated */
function PL_get_string(t: term_t; var s: PChar; var len: Cardinal): Integer; cdecl; external 'libswipl.dll';
function PL_get_chars(t: term_t; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libswipl.dll';
function PL_get_list_chars(l: term_t; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libswipl.dll';
function PL_get_atom_nchars(t: term_t; var length: Cardinal; var a: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_get_list_nchars(l: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libswipl.dll';
function PL_get_nchars(t: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libswipl.dll';
function PL_get_integer(t: term_t; var i: Integer): Integer; cdecl; external 'libswipl.dll';
function PL_get_long(t: term_t; var i: LongInt): Integer; cdecl; external 'libswipl.dll';
function PL_get_pointer(t: term_t; var ptr: Pointer): Integer; cdecl; external 'libswipl.dll';
function PL_get_float(t: term_t; var f: double): Integer; cdecl; external 'libswipl.dll';
function PL_get_functor(t: term_t; var f: functor_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_name_arity(t: term_t; var name: atom_t; var arity: Integer): Integer; cdecl; external 'libswipl.dll';
function PL_get_module(t: term_t; var module: module_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_arg(index: Integer; t, a: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_list(l, h, t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_head(l, h: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_tail(l, t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_nil(l: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_get_term_value(t: term_t; var v: term_value_t): Integer; cdecl; external 'libswipl.dll';
function PL_quote(chr: Integer; data: PChar): PChar; cdecl; external 'libswipl.dll';
function PL_get_int64(t: term_t; var I64: Int64): Integer; cdecl; external 'libswipl.dll';

// Verify types
function PL_term_type(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_variable(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_atom(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_integer(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_string(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_float(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_compound(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_functor(t: term_t; f: functor_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_list(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_atomic(t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_is_number(t: term_t): Integer; cdecl; external 'libswipl.dll';

// Assign to term-references
procedure PL_put_variable(t: term_t); cdecl; external 'libswipl.dll';
procedure PL_put_atom(t: term_t; a: atom_t); cdecl; external 'libswipl.dll';
procedure PL_put_atom_chars(t: term_t; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_string_chars(t: term_t; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_list_chars(t: term_t; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_list_codes(t: term_t; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_atom_nchars(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_string_nchars(t: term_t; len: Cardinal; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_list_nchars(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_list_ncodes(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libswipl.dll';
procedure PL_put_integer(t: term_t; i: LongInt); cdecl; external 'libswipl.dll';
procedure PL_put_pointer(t: term_t; ptr: Pointer); cdecl; external 'libswipl.dll';
procedure PL_put_float(t: term_t; f: double); cdecl; external 'libswipl.dll';
procedure PL_put_functor(t: term_t; functor: functor_t); cdecl; external 'libswipl.dll';
procedure PL_put_list(l: term_t); cdecl; external 'libswipl.dll';
procedure PL_put_nil(l: term_t); cdecl; external 'libswipl.dll';
procedure PL_put_term(t1, t2: term_t); cdecl; external 'libswipl.dll';
procedure PL_put_int64(t: term_t; i: int64); cdecl; external 'libswipl.dll';

// construct a functor or list-cell
// !!!!!! TODO
//procedure PL_cons_functor(h: term_t; f: functor_t; ...); cdecl; external 'libswipl.dll';
procedure PL_cons_functor_v(h: term_t; fd: functor_t; a0: term_t); cdecl; external 'libswipl.dll';
procedure PL_cons_list(l, h, t: term_t); cdecl; external 'libswipl.dll';

// Unify term-references
function PL_unify(t1, t2: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_unify_atom(t: term_t; a: atom_t): Integer; cdecl; external 'libswipl.dll';
function PL_unify_atom_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_list_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_list_codes(t: term_t; chars: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_string_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_atom_nchars(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_list_ncodes(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_list_nchars(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_string_nchars(t: term_t; len: Cardinal; chars: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_unify_integer(t: term_t; n: LongInt): Integer; cdecl; external 'libswipl.dll';
function PL_unify_float(t: term_t; f: double): Integer; cdecl; external 'libswipl.dll';
function PL_unify_pointer(t: term_t; ptr: Pointer): Integer; cdecl; external 'libswipl.dll';
function PL_unify_functor(t: term_t; f: functor_t): Integer; cdecl; external 'libswipl.dll';
function PL_unify_list(l, h, t: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_unify_nil(l: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_unify_arg(index: Integer; t, a: term_t): Integer; cdecl; external 'libswipl.dll';
// !!!!!! TODO
//function PL_unify_term(t: term_t; ...): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// FILENAME SUPPORT
////////////////////////////////////////////////////////////////////////////////

const
  PL_FILE_ABSOLUTE = $01; // return absolute path
  PL_FILE_OSPATH = $02; // return path in OS notation
  PL_FILE_SEARCH = $04; // use file_search_path
  PL_FILE_EXIST = $08; // demand file to exist
  PL_FILE_READ = $10; // demand read-access
  PL_FILE_WRITE = $20; // demand write-access
  PL_FILE_EXECUTE = $40; // demand execute-access
  PL_FILE_NOERRORS = $80; // do not raise exceptions

function PL_get_file_name(n: term_t; var name: PChar; flags: Integer): Integer; cdecl; external 'libswipl.dll';
procedure PL_changed_cwd(); cdecl; external 'libswipl.dll'; // foreign code changed CWD
function PL_cwd(): PChar; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// QUINTUS WRAPPER SUPPORT
////////////////////////////////////////////////////////////////////////////////
function PL_cvt_i_integer(p: term_t; var c: LongInt): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_i_float(p: term_t; var c: double): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_i_single(p: term_t; var c: Single): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_i_string(p: term_t; var c: PChar): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_i_atom(p: term_t; var c: atom_t): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_o_integer(c: LongInt; p: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_o_float(c: double; p: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_o_single(c: Single; p: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_o_string(c: PChar; p: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_cvt_o_atom(c: atom_t; p: term_t): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// COMPARE
////////////////////////////////////////////////////////////////////////////////
function PL_compare(t1, t2: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_same_compound(t1, t2: term_t): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// MESSAGES !!!! TODO
////////////////////////////////////////////////////////////////////////////////
//function PL_warning(const char *fmt, ...): Integer; cdecl; external 'libswipl.dll';
//procedure PL_fatal_error(const char *fmt, ...); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// RECORDED DATABASE
////////////////////////////////////////////////////////////////////////////////
function PL_record(term: term_t): record_t; cdecl; external 'libswipl.dll';
procedure PL_recorded(rec: record_t; term: term_t); cdecl; external 'libswipl.dll';
procedure PL_erase(rec: record_t); cdecl; external 'libswipl.dll';

function PL_record_external(t: term_t; var size: Cardinal): PChar; cdecl; external 'libswipl.dll';
function PL_recorded_external(rec: PChar; term: term_t): Integer; cdecl; external 'libswipl.dll';
function PL_erase_external(rec: PChar): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// FEATURES !!!!!!!!! TODO
////////////////////////////////////////////////////////////////////////////////
//function PL_set_feature(name: PChar; type_: Integer; ...): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// INTERNAL FUNCTIONS !!! TODO
////////////////////////////////////////////////////////////////////////////////
function _PL_get_atomic(t: term_t): atomic_t; cdecl; external 'libswipl.dll';
procedure _PL_put_atomic(t: term_t; a: atomic_t); cdecl; external 'libswipl.dll';
function _PL_unify_atomic(t: term_t; a: atomic_t): Integer; cdecl; external 'libswipl.dll';
procedure _PL_copy_atomic(t: term_t; a: atomic_t); cdecl; external 'libswipl.dll';
//function _PL_get_name_arity(t: term_t; var name: atom_t; var arity: Integer): Integer; cdecl; external 'libswipl.dll';
procedure _PL_get_arg(index: Integer; t, a: term_t); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// CHAR BUFFERS !!!! TODO
////////////////////////////////////////////////////////////////////////////////
const
  CVT_ATOM = $0001;
  CVT_STRING = $0002;
  CVT_LIST = $0004;
  CVT_INTEGER = $0008;
  CVT_FLOAT = $0010;
  CVT_VARIABLE = $0020;
  CVT_NUMBER = CVT_INTEGER or CVT_FLOAT;
  CVT_ATOMIC = CVT_NUMBER or CVT_ATOM or CVT_STRING;
  CVT_WRITE = $0040; // as of version 3.2.10
  CVT_ALL = CVT_ATOMIC or CVT_LIST;
  CVT_MASK = $00FF;

  BUF_DISCARDABLE = $0000;
  BUF_RING = $0100;
  BUF_MALLOC = $0200;

  REP_UTF8 = $1000;
  FL_FPC = CVT_ALL or REP_UTF8;



//#ifdef SIO_MAGIC			/* defined from <SWI-Stream.h> */
////////////////////////////////////////////////////////////////////////////////
// STREAM SUPPORT !!!! TODO
////////////////////////////////////////////////////////////////////////////////
{
     /* Make IOSTREAM known to Prolog */
function PL_open_stream(t: term_t, var s: IOSTREAM): Integer; cdecl; external 'libswipl.dll'; /* compatibility */
function PL_unify_stream(t: term_t, var s: IOSTREAM): Integer; cdecl; external 'libswipl.dll';
function PL_get_stream_handle(t: term_t, IOSTREAM **s): Integer; cdecl; external 'libswipl.dll';
procedure PL_release_stream(var s: IOSTREAM); cdecl; external 'libswipl.dll';
function PL_open_resource(m: module_t, name, rc_class, mode: PChar): ^IOSTREAM; cdecl; external 'libswipl.dll';

const
  PL_WRT_QUOTED		$01 /* quote atoms */
  PL_WRT_IGNOREOPS	$02 /* ignore list/operators */
  PL_WRT_NUMBERVARS	$04 /* print $VAR(N) as a variable */
  PL_WRT_PORTRAY		$08 /* call portray */
  PL_WRT_CHARESCAPES	$10 /* Output ISO escape sequences */

function PL_write_term(var s: IOSTREAM,
         term: term_t,
         precedence: Integer ,
         flags: Integer): Integer;
const
  PL_NOTTY = 0;     // -tty in effect
  PL_RAWTTY = 1     // get_single_char/1
  PL_COOKEDTTY = 2; // Normal input

function PL_ttymode(vart s: IOSTREAM): Integer; cdecl; external 'libswipl.dll';
//#endif

}
function PL_chars_to_term(chars: PChar; term: term_t): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// EMBEDDING
////////////////////////////////////////////////////////////////////////////////
type PPChar = ^PChar;
function PL_initialise(argc: Integer; argv: array of PChar): Integer; cdecl; external 'libswipl.dll';
function PL_is_initialised(var argc: Integer; var argv: array of PChar): Integer; cdecl; external 'libswipl.dll';
procedure PL_install_readline(); cdecl; external 'libswipl.dll';
function PL_toplevel(): Integer; cdecl; external 'libswipl.dll';
function PL_cleanup(status: Integer): Integer; cdecl; external 'libswipl.dll';
procedure PL_halt(status: Integer); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// MEMORY ALLOCATION
////////////////////////////////////////////////////////////////////////////////
function PL_malloc(size: size_t): Pointer; cdecl; external 'libswipl.dll';
function PL_realloc(mem: Pointer; size: size_t): Pointer; cdecl; external 'libswipl.dll';
procedure PL_free(mem: Pointer); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// HOOKS
////////////////////////////////////////////////////////////////////////////////
const
  PL_DISPATCH_INPUT = 0; // There is input available
  PL_DISPATCH_TIMEOUT = 1; // Dispatch timeout

type
  PL_dispatch_hook_t = function(fd: Integer): PInteger;
  PL_abort_hook_t = function(): Pointer;
  PL_initialise_hook_t = function(argc: Integer; argv: array of PChar): Pointer;
  PL_async_hook_t = function(): Pointer; // Win32 only (O_ASYNC_HOOK)
  PL_agc_hook_t = function(a: atom_t): PInteger;

function PL_dispatch_hook(dh: PL_dispatch_hook_t): PL_dispatch_hook_t; cdecl; external 'libswipl.dll';
procedure PL_abort_hook(ah: PL_abort_hook_t); cdecl; external 'libswipl.dll';
procedure PL_initialise_hook(ih: PL_initialise_hook_t); cdecl; external 'libswipl.dll';
function PL_abort_unhook(ah: PL_abort_hook_t): Integer; cdecl; external 'libswipl.dll';
function PL_async_hook(n: Cardinal; ah: PL_async_hook_t): PL_async_hook_t; cdecl; external 'libswipl.dll';
function PL_agc_hook(ah: PL_agc_hook_t): PL_agc_hook_t; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// SIGNALS
////////////////////////////////////////////////////////////////////////////////
const PL_SIGSYNC = $00010000; // call handler synchronously

//TODO!!!!! function PL_signal(sig: Integer; void ( *func)(Integer)) (n: Integer): Pointer; cdecl; external 'libswipl.dll';
procedure PL_interrupt(sig: Integer); cdecl; external 'libswipl.dll';
procedure PL_raise(sig: Integer); cdecl; external 'libswipl.dll';
function PL_handle_signals(): Integer; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// PROLOG ACTION/QUERY
////////////////////////////////////////////////////////////////////////////////
const
  PL_ACTION_TRACE = 1; // switch to trace mode
  PL_ACTION_DEBUG = 2; // switch to debug mode
  PL_ACTION_BACKTRACE = 3; // show a backtrace (stack dump)
  PL_ACTION_BREAK = 4; // create a break environment
  PL_ACTION_HALT = 5; // halt Prolog execution
  PL_ACTION_ABORT = 6; // generate a Prolog abort
                                // 7: Obsolete PL_ACTION_SYMBOLFILE
  PL_ACTION_WRITE = 8; // write via Prolog i/o buffer
  PL_ACTION_FLUSH = 9; // Flush Prolog i/o buffer
  PL_ACTION_GUIAPP = 10; // Win32: set when this is a gui

//TODO!!!! function PL_action(action: Integer, ...): Integer; cdecl; external 'libswipl.dll';	// perform some action
//procedure PL_on_halt(void (*)(Integer, void *), void *); cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// QUERY PROLOG
////////////////////////////////////////////////////////////////////////////////
const
  PL_QUERY_ARGC = 1; // return main() argc
  PL_QUERY_ARGV = 2; // return main() argv
                          // 3: Obsolete PL_QUERY_SYMBOLFILE
                          // 4: Obsolete PL_QUERY_ORGSYMBOLFILE
  PL_QUERY_GETC = 5; // Read character from terminal
  PL_QUERY_MAX_INTEGER = 6; // largest integer
  PL_QUERY_MIN_INTEGER = 7; // smallest integer
  PL_QUERY_MAX_TAGGED_INT = 8; // largest tagged integer
  PL_QUERY_MIN_TAGGED_INT = 9; // smallest tagged integer
  PL_QUERY_VERSION = 10; // 207006 = 2.7.6

function PL_query(q: Integer): LongInt; cdecl; external 'libswipl.dll'; // get information from Prolog



////////////////////////////////////////////////////////////////////////////////
// PROLOG THREADS
////////////////////////////////////////////////////////////////////////////////
type
  PL_thread_attr_t = packed record
    local_size: LongWord; // Stack sizes
    global_size: LongWord;
    trail_size: LongWord;
    argument_size: LongWord;
    alias: PChar; // alias name
  end;

  PL_thread_exit_func_t = procedure;

function PL_thread_self(): Integer; cdecl; external 'libswipl.dll'; // Prolog thread id (-1 if none)
function PL_thread_attach_engine(var attr: PL_thread_attr_t): Integer; cdecl; external 'libswipl.dll';
function PL_thread_destroy_engine(): Integer; cdecl; external 'libswipl.dll';
function PL_thread_at_exit(function_: PL_thread_exit_func_t;
  closure: Pointer;
  global: Integer): Integer; cdecl; external 'libswipl.dll';

// Windows specific:
function PL_w32thread_raise(dwTid: LongWord; sig: Integer): Integer; cdecl; external 'libswipl.dll';


////////////////////////////////////////////////////////////////////////////////
// ENGINES (MT-ONLY)
////////////////////////////////////////////////////////////////////////////////
{
const
  PL_ENGINE_MAIN:    PL_engine_t = $01;
  PL_ENGINE_CURRENT: PL_engine_t = $02;

  PL_ENGINE_SET = 0;   // Engine set successfully
  PL_ENGINE_INVAL = 2; // Engine doesn't exist
  PL_ENGINE_INUSE = 3; // Engine is in use

function PL_create_engine(var attributes: PL_thread_attr_t): PL_engine_t; cdecl; external 'libswipl.dll';
function PL_set_engine(engine: PL_engine_t; var old: PL_engine_t): Integer; cdecl; external 'libswipl.dll';
function PL_destroy_engine(engine: PL_engine_t): Integer; cdecl; external 'libswipl.dll';
}


////////////////////////////////////////////////////////////////////////////////
// WINDOWS MESSAGES
////////////////////////////////////////////////////////////////////////////////

const
  PL_MSG_EXCEPTION_RAISED = -1;
  PL_MSG_IGNORED = 0;
  PL_MSG_HANDLED = 1;

  {
function PL_win_message_proc(h: HWND;
                             message: Cardinal;
                             wParam: Cardinal;
                             lParam: LongInt): Integer; cdecl; external 'libswipl.dll';

////////////////////////////////////////////////////////////////////////////////
// FAST XPCE SUPPORT
////////////////////////////////////////////////////////////////////////////////
type
  xpceref_t = packed record
    type_: Integer; // PL_INTEGER or PL_ATOM
    value: packed record
    case Integer of
      0: (i: LongWord); // integer reference value
      1: (a: atom_t); // atom reference value
    end;
  end;

function _PL_get_xpce_reference(t: term_t; var ref: xpceref_t): Integer; cdecl; external 'libswipl.dll';
function _PL_unify_xpce_reference(t: term_t; var ref: xpceref_t): Integer; cdecl; external 'libswipl.dll';
procedure _PL_put_xpce_reference_i(t: term_t; r: LongWord); cdecl; external 'libswipl.dll';
procedure _PL_put_xpce_reference_a(t: term_t; name: atom_t); cdecl; external 'libswipl.dll';

   }



 {
////////////////////////////////////////////////////////////////////////////////
// COMPATIBILITY
////////////////////////////////////////////////////////////////////////////////
(*#ifdef PL_OLD_INTERFACE

typedef term_t term;
typedef atomic_t atomic;

#ifndef _PL_INCLUDE_H
     /* renamed functions */
#define PL_is_var(t)		PL_is_variable(t)
#define PL_is_int(t)		PL_is_integer(t)
#define PL_is_term(t)		PL_is_compound(t)
#define PL_type(t)		PL_term_type(t)
#define PL_atom_value(a)	(char * )PL_atom_chars((atom_t)(a))
#define PL_predicate(f, m)	PL_pred(f, m)

     /* force undefined symbols */
     /* if PL_OLD_INTERFACE isn't set */
#define PL_strip_module(t, m)	_PL_strip_module(t, m)
#define PL_atomic(t)		_PL_atomic(t)
#define PL_float_value(t)	_PL_float_value(t)
#define PL_integer_value(t)	_PL_integer_value(t)
#define PL_string_value(t)	_PL_string_value(t)
#define PL_functor(t)		_PL_functor(t)
#define PL_arg(t, n)		_PL_arg(t, n)
#define PL_new_term()		_PL_new_term()
#define PL_new_integer(i)	_PL_new_integer(i)
#define PL_new_float(f)		_PL_new_float(f)
#define PL_new_string(s)	_PL_new_string(s)
#define PL_new_var()		_PL_new_var()
#define PL_term(a)		_PL_term(a)
#define PL_unify_atomic(t, a)	_PL_unify_atomic(t, (atomic_t) (a))

typedef fid_t			bktrk_buf;
#define PL_mark(b)		(*(b) = PL_open_foreign_frame())
#define PL_bktrk(b)		PL_discard_foreign_frame(*(b))
#endif /*_PL_INCLUDE_H*/
*)

////////////////////////////////////////////////////////////////////////////////
// ANALYSIS
////////////////////////////////////////////////////////////////////////////////
function _PL_atomic(t: term_t): atomic_t; cdecl; external 'libswipl.dll';
function _PL_integer_value(t: atomic_t): LongInt; cdecl; external 'libswipl.dll';
function _PL_float_value(t: atomic_t): double; cdecl; external 'libswipl.dll';
function _PL_string_value(t: atomic_t): PChar; cdecl; external 'libswipl.dll';
function _PL_list_string_value(t: term_t): PChar; cdecl; external 'libswipl.dll';
function _PL_functor(t: term_t): functor_t; cdecl; external 'libswipl.dll';
function _PL_arg(t: term_t; n: Integer): term_t; cdecl; external 'libswipl.dll';



////////////////////////////////////////////////////////////////////////////////
// CONSTRUCT
////////////////////////////////////////////////////////////////////////////////
function _PL_new_term(): term_t; cdecl; external 'libswipl.dll';
function _PL_new_integer(i: LongInt): atomic_t; cdecl; external 'libswipl.dll';
function _PL_new_float(f: double): atomic_t; cdecl; external 'libswipl.dll';
function _PL_new_string(const s: PChar): atomic_t; cdecl; external 'libswipl.dll';
function _PL_new_var(): atomic_t; cdecl; external 'libswipl.dll';
function _PL_term(a: atomic_t): term_t; cdecl; external 'libswipl.dll';


////////////////////////////////////////////////////////////////////////////////
// UNIFY
////////////////////////////////////////////////////////////////////////////////
//function _PL_unify_atomic(t: term_t; a: atomic_t): Integer; cdecl; external 'libswipl.dll';

////////////////////////////////////////////////////////////////////////////////
// MODULES
////////////////////////////////////////////////////////////////////////////////
function _PL_strip_module(t: term_t; var m: module_t): term_t; cdecl; external 'libswipl.dll';
//#endif /*PL_OLD_INTERFACE*/
  }


{$ELSE } // LINUX



function _PL_retry(p: LongInt): foreign_t; cdecl; external 'libpl.so';
function _PL_retry_address(a: Pointer): foreign_t; cdecl; external 'libpl.so';
function PL_foreign_control(c: control_t): Integer; cdecl; external 'libpl.so';
function PL_foreign_context(c: control_t): LongInt; cdecl; external 'libpl.so';
function PL_foreign_context_address(c: control_t): Pointer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// REGISTERING FOREIGNS
////////////////////////////////////////////////////////////////////////////////
type
  PL_extension = packed record
    predicate_name: PChar; // Name of the predicate
    arity: SmallInt; // Arity of the predicate
    function_: pl_function_t; // Implementing functions
    flags: SmallInt; // Or of PL_FA_...
  end;

const
  PL_FA_NOTRACE = $01; // foreign cannot be traced
  PL_FA_TRANSPARENT = $02; // foreign is module transparent
  PL_FA_NONDETERMINISTIC = $04; // foreign is non-deterministic
  PL_FA_VARARGS = $08; // call using t0, ac, ctx


//extern PL_extension PL_extensions[]; /* not Win32! */
procedure PL_register_extensions(var e: PL_extension); cdecl; external 'libpl.so';
procedure PL_load_extensions(var e: PL_extension); cdecl; external 'libpl.so';
function PL_register_foreign(name: PChar;
  arity: Integer;
  func: pl_function_t;
  flags: Integer): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// LICENSE
////////////////////////////////////////////////////////////////////////////////

//procedure PL_license(license, module: PChar); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// MODULES
////////////////////////////////////////////////////////////////////////////////
function PL_context(): module_t; cdecl; external 'libpl.so';
function PL_module_name(module: module_t): atom_t; cdecl; external 'libpl.so';
function PL_new_module(name: atom_t): module_t; cdecl; external 'libpl.so';
function PL_strip_module(in_: term_t; var m: module_t; out_: term_t): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// CALL-BACK
////////////////////////////////////////////////////////////////////////////////
const
  PL_Q_DEBUG = $01; // (!) = TRUE for backward compatibility
  PL_Q_NORMAL = $02; // normal usage
  PL_Q_NODEBUG = $04; // use this one
  PL_Q_CATCH_EXCEPTION = $08; // handle exceptions in C
  PL_Q_PASS_EXCEPTION = $10; // pass to parent environment
  PL_Q_DETERMINISTIC = $20; // (!) call was deterministic

// Foreign context frames
function PL_open_foreign_frame(): fid_t; cdecl; external 'libpl.so';
procedure PL_rewind_foreign_frame(cid: fid_t); cdecl; external 'libpl.so';
procedure PL_close_foreign_frame(cid: fid_t); cdecl; external 'libpl.so';
procedure PL_discard_foreign_frame(cid: fid_t); cdecl; external 'libpl.so';

// Finding predicates
function PL_pred(f: functor_t; m: module_t): predicate_t; cdecl; external 'libpl.so';
function PL_predicate(name: PChar;
  arity: Integer;
  module: PChar): predicate_t; cdecl; external 'libpl.so';
function PL_predicate_info(pred: predicate_t;
  var name: atom_t;
  var arity: Integer;
  var module: module_t): Integer; cdecl; external 'libpl.so';

// Call-back
function PL_open_query(m: module_t;
  flags: Integer;
  pred: predicate_t;
  t0: term_t): qid_t; cdecl; external 'libpl.so';
function PL_next_solution(qid: qid_t): Integer; cdecl; external 'libpl.so';
procedure PL_close_query(qid: qid_t); cdecl; external 'libpl.so';
procedure PL_cut_query(qid: qid_t); cdecl; external 'libpl.so';

// Simplified (but less flexible) call-back
function PL_call(t: term_t; m: module_t): Integer; cdecl; external 'libpl.so';
function PL_call_predicate(m: module_t;
  debug: Integer;
  pred: predicate_t;
  t0: term_t): Integer; cdecl; external 'libpl.so';

// Handling exceptions
function PL_exception(qid: qid_t): term_t; cdecl; external 'libpl.so';
function PL_raise_exception(exception: term_t): Integer; cdecl; external 'libpl.so';
function PL_throw(exception: term_t): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// TERM REFERENCES
////////////////////////////////////////////////////////////////////////////////

// Creating and destroying term-refs
function PL_new_term_refs(n: Integer): term_t; cdecl; external 'libpl.so';
function PL_new_term_ref(): term_t; cdecl; external 'libpl.so';
function PL_copy_term_ref(from: term_t): term_t; cdecl; external 'libpl.so';
procedure PL_reset_term_refs(r: term_t); cdecl; external 'libpl.so';

// Constants
function PL_new_atom(s: PChar): atom_t; cdecl; external 'libpl.so';
function PL_new_atom_nchars(len: Cardinal; s: PChar): atom_t; cdecl; external 'libpl.so';
function PL_atom_chars(a: atom_t): PChar; cdecl; external 'libpl.so';
function PL_atom_nchars(a: atom_t; var len: Cardinal): PChar; cdecl; external 'libpl.so';
{$IFNDEF O_DEBUG_ATOMGC}
procedure PL_register_atom(a: atom_t); cdecl; external 'libpl.so';
procedure PL_unregister_atom(a: atom_t); cdecl; external 'libpl.so';
{$ENDIF}
function PL_new_functor(f: atom_t; a: Integer): functor_t; cdecl; external 'libpl.so';
function PL_functor_name(f: functor_t): atom_t; cdecl; external 'libpl.so';
function PL_functor_arity(f: functor_t): Integer; cdecl; external 'libpl.so';

// Get C(Pascal) values from Prolog terms
function PL_get_atom(t: term_t; var a: atom_t): Integer; cdecl; external 'libpl.so';
function PL_get_bool(t: term_t; var value: Integer): Integer; cdecl; external 'libpl.so';
function PL_get_atom_chars(t: term_t; var a: PChar): Integer; cdecl; external 'libpl.so';



// TODO
//#define PL_get_string_chars(t, s, l) PL_get_string(t,s,l)
//					/* PL_get_string() is depreciated */


function PL_get_string(t: term_t; var s: PChar; var len: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_chars(t: term_t; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_wchars(t: term_t; var len: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_list_chars(l: term_t; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_atom_nchars(t: term_t; var length: Cardinal; var a: PChar): Integer; cdecl; external 'libpl.so';
function PL_get_list_nchars(l: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_nchars(t: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl; external 'libpl.so';
function PL_get_integer(t: term_t; var i: Integer): Integer; cdecl; external 'libpl.so';
function PL_get_long(t: term_t; var i: LongInt): Integer; cdecl; external 'libpl.so';
function PL_get_pointer(t: term_t; var ptr: Pointer): Integer; cdecl; external 'libpl.so';
function PL_get_float(t: term_t; var f: double): Integer; cdecl; external 'libpl.so';
function PL_get_functor(t: term_t; var f: functor_t): Integer; cdecl; external 'libpl.so';
function PL_get_name_arity(t: term_t; var name: atom_t; var arity: Integer): Integer; cdecl; external 'libpl.so';
function PL_get_module(t: term_t; var module: module_t): Integer; cdecl; external 'libpl.so';
function PL_get_arg(index: Integer; t, a: term_t): Integer; cdecl; external 'libpl.so';
function PL_get_list(l, h, t: term_t): Integer; cdecl; external 'libpl.so';
function PL_get_head(l, h: term_t): Integer; cdecl; external 'libpl.so';
function PL_get_tail(l, t: term_t): Integer; cdecl; external 'libpl.so';
function PL_get_nil(l: term_t): Integer; cdecl; external 'libpl.so';
function PL_get_term_value(t: term_t; var v: term_value_t): Integer; cdecl; external 'libpl.so';
function PL_quote(chr: Integer; data: PChar): PChar; cdecl; external 'libpl.so';

// Verify types
function PL_term_type(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_variable(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_atom(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_integer(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_string(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_float(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_compound(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_functor(t: term_t; f: functor_t): Integer; cdecl; external 'libpl.so';
function PL_is_list(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_atomic(t: term_t): Integer; cdecl; external 'libpl.so';
function PL_is_number(t: term_t): Integer; cdecl; external 'libpl.so';

// Assign to term-references
procedure PL_put_variable(t: term_t); cdecl; external 'libpl.so';
procedure PL_put_atom(t: term_t; a: atom_t); cdecl; external 'libpl.so';
procedure PL_put_atom_chars(t: term_t; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_string_chars(t: term_t; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_list_chars(t: term_t; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_list_codes(t: term_t; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_atom_nchars(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_string_nchars(t: term_t; len: Cardinal; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_list_nchars(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_list_ncodes(t: term_t; l: Cardinal; chars: PChar); cdecl; external 'libpl.so';
procedure PL_put_integer(t: term_t; i: LongInt); cdecl; external 'libpl.so';
procedure PL_put_pointer(t: term_t; ptr: Pointer); cdecl; external 'libpl.so';
procedure PL_put_float(t: term_t; f: double); cdecl; external 'libpl.so';
procedure PL_put_functor(t: term_t; functor: functor_t); cdecl; external 'libpl.so';
procedure PL_put_list(l: term_t); cdecl; external 'libpl.so';
procedure PL_put_nil(l: term_t); cdecl; external 'libpl.so';
procedure PL_put_term(t1, t2: term_t); cdecl; external 'libpl.so';

// construct a functor or list-cell
// !!!!!! TODO
//procedure PL_cons_functor(h: term_t; f: functor_t; ...); cdecl; external 'libpl.so';
procedure PL_cons_functor_v(h: term_t; fd: functor_t; a0: term_t); cdecl; external 'libpl.so';
procedure PL_cons_list(l, h, t: term_t); cdecl; external 'libpl.so';

// Unify term-references
function PL_unify(t1, t2: term_t): Integer; cdecl; external 'libpl.so';
function PL_unify_atom(t: term_t; a: atom_t): Integer; cdecl; external 'libpl.so';
function PL_unify_atom_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_list_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_list_codes(t: term_t; chars: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_string_chars(t: term_t; chars: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_atom_nchars(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_list_ncodes(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_list_nchars(t: term_t; l: Cardinal; s: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_string_nchars(t: term_t; len: Cardinal; chars: PChar): Integer; cdecl; external 'libpl.so';
function PL_unify_integer(t: term_t; n: LongInt): Integer; cdecl; external 'libpl.so';
function PL_unify_float(t: term_t; f: double): Integer; cdecl; external 'libpl.so';
function PL_unify_pointer(t: term_t; ptr: Pointer): Integer; cdecl; external 'libpl.so';
function PL_unify_functor(t: term_t; f: functor_t): Integer; cdecl; external 'libpl.so';
function PL_unify_list(l, h, t: term_t): Integer; cdecl; external 'libpl.so';
function PL_unify_nil(l: term_t): Integer; cdecl; external 'libpl.so';
function PL_unify_arg(index: Integer; t, a: term_t): Integer; cdecl; external 'libpl.so';
// !!!!!! TODO
//function PL_unify_term(t: term_t; ...): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// FILENAME SUPPORT
////////////////////////////////////////////////////////////////////////////////

const
  PL_FILE_ABSOLUTE = $01; // return absolute path
  PL_FILE_OSPATH = $02; // return path in OS notation
  PL_FILE_SEARCH = $04; // use file_search_path
  PL_FILE_EXIST = $08; // demand file to exist
  PL_FILE_READ = $10; // demand read-access
  PL_FILE_WRITE = $20; // demand write-access
  PL_FILE_EXECUTE = $40; // demand execute-access
  PL_FILE_NOERRORS = $80; // do not raise exceptions

function PL_get_file_name(n: term_t; var name: PChar; flags: Integer): Integer; cdecl; external 'libpl.so';
procedure PL_changed_cwd(); cdecl; external 'libpl.so'; // foreign code changed CWD
function PL_cwd(): PChar; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// QUINTUS WRAPPER SUPPORT
////////////////////////////////////////////////////////////////////////////////
function PL_cvt_i_integer(p: term_t; var c: LongInt): Integer; cdecl; external 'libpl.so';
function PL_cvt_i_float(p: term_t; var c: double): Integer; cdecl; external 'libpl.so';
function PL_cvt_i_single(p: term_t; var c: Single): Integer; cdecl; external 'libpl.so';
function PL_cvt_i_string(p: term_t; var c: PChar): Integer; cdecl; external 'libpl.so';
function PL_cvt_i_atom(p: term_t; var c: atom_t): Integer; cdecl; external 'libpl.so';
function PL_cvt_o_integer(c: LongInt; p: term_t): Integer; cdecl; external 'libpl.so';
function PL_cvt_o_float(c: double; p: term_t): Integer; cdecl; external 'libpl.so';
function PL_cvt_o_single(c: Single; p: term_t): Integer; cdecl; external 'libpl.so';
function PL_cvt_o_string(c: PChar; p: term_t): Integer; cdecl; external 'libpl.so';
function PL_cvt_o_atom(c: atom_t; p: term_t): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// COMPARE
////////////////////////////////////////////////////////////////////////////////
function PL_compare(t1, t2: term_t): Integer; cdecl; external 'libpl.so';
function PL_same_compound(t1, t2: term_t): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// MESSAGES !!!! TODO
////////////////////////////////////////////////////////////////////////////////
//function PL_warning(const char *fmt, ...): Integer; cdecl; external 'libpl.so';
//procedure PL_fatal_error(const char *fmt, ...); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// RECORDED DATABASE
////////////////////////////////////////////////////////////////////////////////
function PL_record(term: term_t): record_t; cdecl; external 'libpl.so';
procedure PL_recorded(rec: record_t; term: term_t); cdecl; external 'libpl.so';
procedure PL_erase(rec: record_t); cdecl; external 'libpl.so';

function PL_record_external(t: term_t; var size: Cardinal): PChar; cdecl; external 'libpl.so';
function PL_recorded_external(rec: PChar; term: term_t): Integer; cdecl; external 'libpl.so';
function PL_erase_external(rec: PChar): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// FEATURES !!!!!!!!! TODO
////////////////////////////////////////////////////////////////////////////////
//function PL_set_feature(name: PChar; type_: Integer; ...): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// INTERNAL FUNCTIONS !!! TODO
////////////////////////////////////////////////////////////////////////////////
function _PL_get_atomic(t: term_t): atomic_t; cdecl; external 'libpl.so';
procedure _PL_put_atomic(t: term_t; a: atomic_t); cdecl; external 'libpl.so';
function _PL_unify_atomic(t: term_t; a: atomic_t): Integer; cdecl; external 'libpl.so';
procedure _PL_copy_atomic(t: term_t; a: atomic_t); cdecl; external 'libpl.so';
//function _PL_get_name_arity(t: term_t; var name: atom_t; var arity: Integer): Integer; cdecl; external 'libpl.so';
procedure _PL_get_arg(index: Integer; t, a: term_t); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// CHAR BUFFERS !!!! TODO
////////////////////////////////////////////////////////////////////////////////
const
  CVT_ATOM = $0001;
  CVT_STRING = $0002;
  CVT_LIST = $0004;
  CVT_INTEGER = $0008;
  CVT_FLOAT = $0010;
  CVT_VARIABLE = $0020;
  CVT_NUMBER = CVT_INTEGER or CVT_FLOAT;
  CVT_ATOMIC = CVT_NUMBER or CVT_ATOM or CVT_STRING;
  CVT_WRITE = $0040; // as of version 3.2.10
  CVT_ALL = CVT_ATOMIC or CVT_LIST;
  CVT_MASK = $00FF;

  BUF_DISCARDABLE = $0000;
  BUF_RING = $0100;
  BUF_MALLOC = $0200;
  REP_UTF8 = $1000;
  FL_FPC = CVT_ALL or REP_UTF8;



//#ifdef SIO_MAGIC			/* defined from <SWI-Stream.h> */
////////////////////////////////////////////////////////////////////////////////
// STREAM SUPPORT !!!! TODO
////////////////////////////////////////////////////////////////////////////////
{
     /* Make IOSTREAM known to Prolog */
function PL_open_stream(t: term_t, var s: IOSTREAM): Integer; cdecl; external 'libpl.so'; /* compatibility */
function PL_unify_stream(t: term_t, var s: IOSTREAM): Integer; cdecl; external 'libpl.so';
function PL_get_stream_handle(t: term_t, IOSTREAM **s): Integer; cdecl; external 'libpl.so';
procedure PL_release_stream(var s: IOSTREAM); cdecl; external 'libpl.so';
function PL_open_resource(m: module_t, name, rc_class, mode: PChar): ^IOSTREAM; cdecl; external 'libpl.so';

const
  PL_WRT_QUOTED		$01 /* quote atoms */
  PL_WRT_IGNOREOPS	$02 /* ignore list/operators */
  PL_WRT_NUMBERVARS	$04 /* print $VAR(N) as a variable */
  PL_WRT_PORTRAY		$08 /* call portray */
  PL_WRT_CHARESCAPES	$10 /* Output ISO escape sequences */

function PL_write_term(var s: IOSTREAM,
         term: term_t,
         precedence: Integer ,
         flags: Integer): Integer;
const
  PL_NOTTY = 0;     // -tty in effect
  PL_RAWTTY = 1     // get_single_char/1
  PL_COOKEDTTY = 2; // Normal input

function PL_ttymode(vart s: IOSTREAM): Integer; cdecl; external 'libpl.so';
//#endif

}
function PL_chars_to_term(chars: PChar; term: term_t): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// EMBEDDING
////////////////////////////////////////////////////////////////////////////////
type PPChar = ^PChar;
function PL_initialise(argc: Integer; argv: array of PChar): Integer; cdecl; external 'libpl.so';
function PL_is_initialised(var argc: Integer; var argv: array of PChar): Integer; cdecl; external 'libpl.so';
procedure PL_install_readline(); cdecl; external 'libpl.so';
function PL_toplevel(): Integer; cdecl; external 'libpl.so';
function PL_cleanup(status: Integer): Integer; cdecl; external 'libpl.so';
procedure PL_halt(status: Integer); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// MEMORY ALLOCATION
////////////////////////////////////////////////////////////////////////////////
function PL_malloc(size: size_t): Pointer; cdecl; external 'libpl.so';
function PL_realloc(mem: Pointer; size: size_t): Pointer; cdecl; external 'libpl.so';
procedure PL_free(mem: Pointer); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// HOOKS
////////////////////////////////////////////////////////////////////////////////
const
  PL_DISPATCH_INPUT = 0; // There is input available
  PL_DISPATCH_TIMEOUT = 1; // Dispatch timeout

type
  PL_dispatch_hook_t = function(fd: Integer): PInteger;
  PL_abort_hook_t = function(): Pointer;
  PL_initialise_hook_t = function(argc: Integer; argv: array of PChar): Pointer;
  PL_async_hook_t = function(): Pointer; // Win32 only (O_ASYNC_HOOK)
  PL_agc_hook_t = function(a: atom_t): PInteger;

function PL_dispatch_hook(dh: PL_dispatch_hook_t): PL_dispatch_hook_t; cdecl; external 'libpl.so';
procedure PL_abort_hook(ah: PL_abort_hook_t); cdecl; external 'libpl.so';
procedure PL_initialise_hook(ih: PL_initialise_hook_t); cdecl; external 'libpl.so';
function PL_abort_unhook(ah: PL_abort_hook_t): Integer; cdecl; external 'libpl.so';
function PL_async_hook(n: Cardinal; ah: PL_async_hook_t): PL_async_hook_t; cdecl; external 'libpl.so';
function PL_agc_hook(ah: PL_agc_hook_t): PL_agc_hook_t; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// SIGNALS
////////////////////////////////////////////////////////////////////////////////
const PL_SIGSYNC = $00010000; // call handler synchronously

//TODO!!!!! function PL_signal(sig: Integer; void ( *func)(Integer)) (n: Integer): Pointer; cdecl; external 'libpl.so';
procedure PL_interrupt(sig: Integer); cdecl; external 'libpl.so';
procedure PL_raise(sig: Integer); cdecl; external 'libpl.so';
function PL_handle_signals(): Integer; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// PROLOG ACTION/QUERY
////////////////////////////////////////////////////////////////////////////////
const
  PL_ACTION_TRACE = 1; // switch to trace mode
  PL_ACTION_DEBUG = 2; // switch to debug mode
  PL_ACTION_BACKTRACE = 3; // show a backtrace (stack dump)
  PL_ACTION_BREAK = 4; // create a break environment
  PL_ACTION_HALT = 5; // halt Prolog execution
  PL_ACTION_ABORT = 6; // generate a Prolog abort
                                // 7: Obsolete PL_ACTION_SYMBOLFILE
  PL_ACTION_WRITE = 8; // write via Prolog i/o buffer
  PL_ACTION_FLUSH = 9; // Flush Prolog i/o buffer
  PL_ACTION_GUIAPP = 10; // Win32: set when this is a gui

//TODO!!!! function PL_action(action: Integer, ...): Integer; cdecl; external 'libpl.so';	// perform some action
//procedure PL_on_halt(void (*)(Integer, void *), void *); cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// QUERY PROLOG
////////////////////////////////////////////////////////////////////////////////
const
  PL_QUERY_ARGC = 1; // return main() argc
  PL_QUERY_ARGV = 2; // return main() argv
                          // 3: Obsolete PL_QUERY_SYMBOLFILE
                          // 4: Obsolete PL_QUERY_ORGSYMBOLFILE
  PL_QUERY_GETC = 5; // Read character from terminal
  PL_QUERY_MAX_INTEGER = 6; // largest integer
  PL_QUERY_MIN_INTEGER = 7; // smallest integer
  PL_QUERY_MAX_TAGGED_INT = 8; // largest tagged integer
  PL_QUERY_MIN_TAGGED_INT = 9; // smallest tagged integer
  PL_QUERY_VERSION = 10; // 207006 = 2.7.6

function PL_query(q: Integer): LongInt; cdecl; external 'libpl.so'; // get information from Prolog



////////////////////////////////////////////////////////////////////////////////
// PROLOG THREADS
////////////////////////////////////////////////////////////////////////////////
type
  PL_thread_attr_t = packed record
    local_size: LongWord; // Stack sizes
    global_size: LongWord;
    trail_size: LongWord;
    argument_size: LongWord;
    alias: PChar; // alias name
  end;

  PL_thread_exit_func_t = procedure;

function PL_thread_self(): Integer; cdecl; external 'libpl.so'; // Prolog thread id (-1 if none)
function PL_thread_attach_engine(var attr: PL_thread_attr_t): Integer; cdecl; external 'libpl.so';
function PL_thread_destroy_engine(): Integer; cdecl; external 'libpl.so';
function PL_thread_at_exit(function_: PL_thread_exit_func_t;
  closure: Pointer;
  global: Integer): Integer; cdecl; external 'libpl.so';

// Windows specific:
function PL_w32thread_raise(dwTid: LongWord; sig: Integer): Integer; cdecl; external 'libpl.so';


////////////////////////////////////////////////////////////////////////////////
// ENGINES (MT-ONLY)
////////////////////////////////////////////////////////////////////////////////
{
const
  PL_ENGINE_MAIN:    PL_engine_t = $01;
  PL_ENGINE_CURRENT: PL_engine_t = $02;

  PL_ENGINE_SET = 0;   // Engine set successfully
  PL_ENGINE_INVAL = 2; // Engine doesn't exist
  PL_ENGINE_INUSE = 3; // Engine is in use

function PL_create_engine(var attributes: PL_thread_attr_t): PL_engine_t; cdecl; external 'libpl.so';
function PL_set_engine(engine: PL_engine_t; var old: PL_engine_t): Integer; cdecl; external 'libpl.so';
function PL_destroy_engine(engine: PL_engine_t): Integer; cdecl; external 'libpl.so';
}


////////////////////////////////////////////////////////////////////////////////
// WINDOWS MESSAGES
////////////////////////////////////////////////////////////////////////////////

const
  PL_MSG_EXCEPTION_RAISED = -1;
  PL_MSG_IGNORED = 0;
  PL_MSG_HANDLED = 1;

{$IFDEF win32}
function PL_win_message_proc(h: HWND;
  message: Cardinal;
  wParam: Cardinal;
  lParam: LongInt): Integer; cdecl; external 'libpl.so';
{$ENDIF}
////////////////////////////////////////////////////////////////////////////////
// FAST XPCE SUPPORT
////////////////////////////////////////////////////////////////////////////////
type
  xpceref_t = packed record
    type_: Integer; // PL_INTEGER or PL_ATOM
    value: packed record
      case Integer of
        0: (i: LongWord); // integer reference value
        1: (a: atom_t); // atom reference value
    end;
  end;

function _PL_get_xpce_reference(t: term_t; var ref: xpceref_t): Integer; cdecl; external 'libpl.so';
function _PL_unify_xpce_reference(t: term_t; var ref: xpceref_t): Integer; cdecl; external 'libpl.so';
procedure _PL_put_xpce_reference_i(t: term_t; r: LongWord); cdecl; external 'libpl.so';
procedure _PL_put_xpce_reference_a(t: term_t; name: atom_t); cdecl; external 'libpl.so';





 {
////////////////////////////////////////////////////////////////////////////////
// COMPATIBILITY
////////////////////////////////////////////////////////////////////////////////
(*#ifdef PL_OLD_INTERFACE

typedef term_t term;
typedef atomic_t atomic;

#ifndef _PL_INCLUDE_H
     /* renamed functions */
#define PL_is_var(t)		PL_is_variable(t)
#define PL_is_int(t)		PL_is_integer(t)
#define PL_is_term(t)		PL_is_compound(t)
#define PL_type(t)		PL_term_type(t)
#define PL_atom_value(a)	(char * )PL_atom_chars((atom_t)(a))
#define PL_predicate(f, m)	PL_pred(f, m)

     /* force undefined symbols */
     /* if PL_OLD_INTERFACE isn't set */
#define PL_strip_module(t, m)	_PL_strip_module(t, m)
#define PL_atomic(t)		_PL_atomic(t)
#define PL_float_value(t)	_PL_float_value(t)
#define PL_integer_value(t)	_PL_integer_value(t)
#define PL_string_value(t)	_PL_string_value(t)
#define PL_functor(t)		_PL_functor(t)
#define PL_arg(t, n)		_PL_arg(t, n)
#define PL_new_term()		_PL_new_term()
#define PL_new_integer(i)	_PL_new_integer(i)
#define PL_new_float(f)		_PL_new_float(f)
#define PL_new_string(s)	_PL_new_string(s)
#define PL_new_var()		_PL_new_var()
#define PL_term(a)		_PL_term(a)
#define PL_unify_atomic(t, a)	_PL_unify_atomic(t, (atomic_t) (a))

typedef fid_t			bktrk_buf;
#define PL_mark(b)		(*(b) = PL_open_foreign_frame())
#define PL_bktrk(b)		PL_discard_foreign_frame(*(b))
#endif /*_PL_INCLUDE_H*/
*)

////////////////////////////////////////////////////////////////////////////////
// ANALYSIS
////////////////////////////////////////////////////////////////////////////////
function _PL_atomic(t: term_t): atomic_t; cdecl; external 'libpl.so';
function _PL_integer_value(t: atomic_t): LongInt; cdecl; external 'libpl.so';
function _PL_float_value(t: atomic_t): double; cdecl; external 'libpl.so';
function _PL_string_value(t: atomic_t): PChar; cdecl; external 'libpl.so';
function _PL_list_string_value(t: term_t): PChar; cdecl; external 'libpl.so';
function _PL_functor(t: term_t): functor_t; cdecl; external 'libpl.so';
function _PL_arg(t: term_t; n: Integer): term_t; cdecl; external 'libpl.so';



////////////////////////////////////////////////////////////////////////////////
// CONSTRUCT
////////////////////////////////////////////////////////////////////////////////
function _PL_new_term(): term_t; cdecl; external 'libpl.so';
function _PL_new_integer(i: LongInt): atomic_t; cdecl; external 'libpl.so';
function _PL_new_float(f: double): atomic_t; cdecl; external 'libpl.so';
function _PL_new_string(const s: PChar): atomic_t; cdecl; external 'libpl.so';
function _PL_new_var(): atomic_t; cdecl; external 'libpl.so';
function _PL_term(a: atomic_t): term_t; cdecl; external 'libpl.so';


////////////////////////////////////////////////////////////////////////////////
// UNIFY
////////////////////////////////////////////////////////////////////////////////
//function _PL_unify_atomic(t: term_t; a: atomic_t): Integer; cdecl; external 'libpl.so';

////////////////////////////////////////////////////////////////////////////////
// MODULES
////////////////////////////////////////////////////////////////////////////////
function _PL_strip_module(t: term_t; var m: module_t): term_t; cdecl; external 'libpl.so';
//#endif /*PL_OLD_INTERFACE*/
  }

{$ENDIF }





implementation

end.
