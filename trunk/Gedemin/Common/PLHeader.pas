unit PLHeader;

interface

const
  PL_VARIABLE             = 1; // nothing
  PL_ATOM                 = 2; // const char *
  PL_INTEGER              = 3; // int
  PL_FLOAT                = 4; // double
  PL_STRING               = 5; // const char *
  PL_TERM                 = 6;

  PL_Q_DEBUG              = $01; // (!) = TRUE for backward compatibility
  PL_Q_NORMAL             = $02; // normal usage
  PL_Q_NODEBUG            = $04; // use this one
  PL_Q_CATCH_EXCEPTION    = $08; // handle exceptions in C
  PL_Q_PASS_EXCEPTION     = $10; // pass to parent environment
  PL_Q_DETERMINISTIC      = $20; // (!) call was deterministic
  MON_PL_Q                = $04 + $20;

  CVT_ATOM                = $0001;
  CVT_STRING              = $0002;
  CVT_LIST                = $0004;
  CVT_INTEGER             = $0008;
  CVT_FLOAT               = $0010;
  CVT_VARIABLE            = $0020;
  CVT_NUMBER              = CVT_INTEGER or CVT_FLOAT;
  CVT_ATOMIC              = CVT_NUMBER or CVT_ATOM or CVT_STRING;
  CVT_WRITE               = $0040; // as of version 3.2.10
  CVT_ALL                 = CVT_ATOMIC or CVT_LIST;
  CVT_MASK                = $00FF;
  CVT_WRITEQ              = $00C0;

  BUF_DISCARDABLE         = $0000;
  BUF_RING                = $0100;
  BUF_MALLOC              = $0200;

  REP_UTF8                = $1000;
  FL_FPC                  = CVT_ALL or REP_UTF8;

  Libgmp10_dll = 'libgmp-10.dll';
  Libswipl_dll = 'libswipl.dll';
  PthreadGC2_dll = 'pthreadGC2.dll';
  PrologPath = 'swipl';
  PrologTempPath = 'swipl\temp';

type
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
  pl_function_t = Pointer; // can only pass function as void *

  TPL_initialise = function(argc: Integer; argv: array of PChar): Integer; cdecl;
  TPL_is_initialised = function(var argc: Integer; var argv: array of PChar): Integer; cdecl;
  TPL_cleanup = function(status: Integer): Integer; cdecl;
  TPL_halt = procedure(status: Integer); cdecl;
  //latunov
  TPL_open_foreign_frame = function: fid_t; cdecl;
  TPL_close_foreign_frame = procedure(fid: fid_t); cdecl;
  TPL_discard_foreign_frame = procedure(fid: fid_t); cdecl;
  TPL_rewind_foreign_frame = procedure(fid: fid_t); cdecl;
  //
  TPL_open_query = function(m: module_t; flags: Integer; pred: predicate_t; t0: term_t): qid_t; cdecl;
  TPL_next_solution = function(qid: qid_t): smallint; cdecl;
  TPL_close_query = procedure(qid: qid_t); cdecl;
  TPL_cut_query = procedure(qid: qid_t); cdecl;
  TPL_call = function(t: term_t; m: module_t): Integer; cdecl;
  TPL_call_predicate = function(m: module_t; debug: Integer; pred: predicate_t;
    t0: term_t): Integer; cdecl;
  TPL_new_term_refs = function(n: Integer): term_t; cdecl;
  TPL_new_term_ref = function: term_t; cdecl;
  TPL_copy_term_ref = function(from: term_t): term_t; cdecl;
  TPL_reset_term_refs = procedure(r: term_t); cdecl;

  TPL_new_atom = function(s: PChar): atom_t; cdecl;
  TPL_new_atom_nchars = function(len: Cardinal; s: PChar): atom_t; cdecl;
  TPL_atom_chars = function(a: atom_t): PChar; cdecl;
  TPL_atom_nchars = function(a: atom_t; var len: Cardinal): PChar; cdecl;
  TPL_register_atom = procedure(a: atom_t); cdecl;
  TPL_unregister_atom = procedure(a: atom_t); cdecl;
  TPL_new_functor = function(f: atom_t; a: Integer): functor_t; cdecl;
  TPL_functor_name = function(f: functor_t): atom_t; cdecl;
  TPL_functor_arity = function(f: functor_t): Integer; cdecl;
  TPL_get_atom = function(t: term_t; var a: atom_t): Integer; cdecl;
  TPL_get_bool = function(t: term_t; var value: Integer): Integer; cdecl;
  TPL_get_atom_chars = function(t: term_t; var a: PChar): Integer; cdecl;
  TPL_get_string = function(t: term_t; var s: PChar; var len: Cardinal): Integer; cdecl;
  TPL_get_chars = function(t: term_t; var s: PChar; flags: Cardinal): Integer; cdecl;
  TPL_get_list_chars = function(l: term_t; var s: PChar; flags: Cardinal): Integer; cdecl;
  TPL_get_atom_nchars = function(t: term_t; var length: Cardinal; var a: PChar): Integer; cdecl;
  TPL_get_list_nchars = function(l: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl;
  TPL_get_nchars = function(t: term_t; var length: Cardinal; var s: PChar; flags: Cardinal): Integer; cdecl;
  TPL_get_integer = function(t: term_t; var i: Integer): Integer; cdecl;
  TPL_get_long = function(t: term_t; var i: LongInt): Integer; cdecl;
  TPL_get_pointer = function(t: term_t; var ptr: Pointer): Integer; cdecl;
  TPL_get_float = function(t: term_t; var f: double): Integer; cdecl;
  TPL_get_functor = function(t: term_t; var f: functor_t): Integer; cdecl;
  TPL_get_name_arity = function(t: term_t; var name: atom_t; var arity: Integer): Integer; cdecl;
  TPL_get_module = function(t: term_t; var module: module_t): Integer; cdecl;
  TPL_get_arg = function(index: Integer; t, a: term_t): Integer; cdecl;
  TPL_get_list = function(l, h, t: term_t): Integer; cdecl;
  TPL_get_head = function(l, h: term_t): Integer; cdecl;
  TPL_get_tail = function(l, t: term_t): Integer; cdecl;
  TPL_get_nil = function(l: term_t): Integer; stdcall;  
  TPL_quote = function(chr: Integer; data: PChar): PChar; cdecl;
  TPL_get_int64 = function(t: term_t; var I64: Int64): Integer; cdecl;
  TPL_cons_functor_v = function(h: term_t; fd: functor_t; a0: term_t): Integer; cdecl;
  TPL_put_variable = procedure (t: term_t); cdecl;
  TPL_put_atom = procedure(t: term_t; a: atom_t); cdecl;
  TPL_put_atom_chars = procedure(t: term_t; chars: PChar); cdecl;
  TPL_put_string_chars = procedure(t: term_t; chars: PChar); cdecl;
  TPL_put_list_chars = procedure(t: term_t; chars: PChar); cdecl;
  TPL_put_list_codes = procedure(t: term_t; chars: PChar); cdecl;
  TPL_put_atom_nchars = procedure(t: term_t; l: Cardinal; chars: PChar); cdecl;
  TPL_put_string_nchars = procedure(t: term_t; len: Cardinal; chars: PChar); cdecl;
  TPL_put_list_nchars = procedure(t: term_t; l: Cardinal; chars: PChar); cdecl;
  TPL_put_list_ncodes = procedure(t: term_t; l: Cardinal; chars: PChar); cdecl;
  TPL_put_integer = procedure(t: term_t; i: LongInt); cdecl;
  TPL_put_pointer = procedure(t: term_t; ptr: Pointer); cdecl;
  TPL_put_float = procedure(t: term_t; f: double); cdecl;
  TPL_put_functor = procedure(t: term_t; functor: functor_t); cdecl;
  TPL_put_list = procedure(l: term_t); cdecl;
  TPL_put_nil = procedure(l: term_t); cdecl;
  TPL_put_term = procedure(t1, t2: term_t); cdecl;
  TPL_put_int64 = procedure(t: term_t; i: int64); cdecl;
  TPL_term_type = function(t: term_t): Integer; cdecl;
  TPL_predicate = function(name: PChar; arity: Integer; module: PChar): predicate_t; cdecl;
  TPL_chars_to_term = function(chars: PChar; term: term_t): Integer; cdecl;
  TPL_exception = function(qid: qid_t): term_t; cdecl;
  TPL_raise_exception = function(exception: term_t): Integer; cdecl;
  TPL_throw = function(exception: term_t): Integer; cdecl;

  TPL_pred = function(f: functor_t; m: module_t): predicate_t; cdecl;    
  TPL_predicate_info = function(pred: predicate_t; var name: atom_t; var arity: Integer;
    var module: module_t): Integer; cdecl;    

implementation    

end.
