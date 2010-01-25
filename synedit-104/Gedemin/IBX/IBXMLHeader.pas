unit IBXMLHeader;

interface

uses
  IBExternals, IBHeader, IBSQL;

type

 TVary = Record
    vary_length : Short;
    vary_string : Char;
 End;
 PVary = ^TVary;


  Tib_xmlda = record
    xmlda_file_name : PChar; { pointer to a char string containing the name of the
					    file used by xml_fetch(), ignored by the buffer 
					    function }
	  xmlda_header_tag : PChar; { points to the string which is printed out as the
					    header tag }
	  xmlda_database_tag : PChar; { points to the string which is printed
                                 out as the database tag in the xml file }
	  xmlda_table_tag : PChar; { points to the string which is printed
                               out as the tablename tag in the xml file }
	  xmlda_row_tag : PChar; { points to the string which is printed
                             out as the rowname tag in the xml file }
    xmlda_file_ptr : ^FILE; { used internally by the API to hold the file pointer
					    can be POINTER type in non C, C++ programs }
    xmlda_temo_buffer : ^PChar; { internal use only, used for storing the String array
					    from fetch() }
    xmlda_fetch_stata : ISC_STATUS; { this element holds the return value from the
					    isc_dsql_fetch() call, it indicates if we have 
					    received all the records or if we have a error }

    xmlda_flags : ULong;    { flags explained below }
    xmlda_more_data : ULong; { used by the buffer call to maintian status of the last
					    record, 0 if there is no more data 1 if there is more 
				            data has been fetched but not put out in the buffer }
    xmlda_temp_size : ULong; { internal use only, used to store the last records
					    size }
    xmlda_status : Short; { internal status set to 0 when called for the first time }
    xmlda_more : Short; { this flag is used in conjunction with the
				            buffered mode, if there is more XML data this is set }

	  xmlda_version : UShort;	 { version of XMLDA }
    xmlda_array_size : UShort; { internal use only }
    xmlda_reserved :	ULong; { reserved for future use }
  end;
  PIB_XMLDA = ^TIB_XMLDA;

const
  XMLDA_ATTRIBUTE_FLAG       = $01;
  XMLDA_DISPLAY_NULL_FLAG    = $02;
  XMLDA_NO_HEADER_FLAG       = $04;

  MAXCHARSET_LENGTH          = 32;   { CHARSET names }
  SHORT_LEN                  =  7;   { NUMERIC (4,2) = -327.68 }
  LONG_LEN                   = 12;   { NUMERIC (9,2) = -21474836.48 }
  INT64_LEN                  = 21; 	 { NUMERIC(18,2) = -92233720368547758.08 }
  QUAD_LEN                   = 19;
  FLOAT_LEN                  = 14;   { -1.2345678E+38 }
  DOUBLE_LEN                 = 23;   { -1.234567890123456E+300 }
  DATE_LEN                   = 11;   { 11 for date only }
  DATETIME_LEN               = 25;   { 25 for date-time }
  TIME_ONLY_LEN              = 13;   { 13 for time only }
  DATE_ONLY_LEN              = 11;
  UNKNOWN_LEN                = 20;   { Unknown type: %d }

  ERR_NOT_ENOUGH_MEMORY      = -1;
  ERR_BUFFERSIZE_NOT_ENOUGH  = -2;

type

  Tisc_dsql_xml_fetch = function(status: PISC_STATUS;
                               stmt: PISC_STMT_HANDLE;
                               da_version: USHORT;
                               sqlda: PXSQLDA;
                               ib_xmlda: PIB_XMLDA): Integer stdcall;

  Tisc_dsql_xml_fetch_all = function(status: PISC_STATUS;
                                   stmt: PISC_STMT_HANDLE;
                                   da_version: USHORT;
                                   sqlda: PXSQLDA;
                                   ib_xmlda: PIB_XMLDA): Integer stdcall;

  Tisc_dsql_xml_buffer_fetch = function(status : PISC_STATUS;
                                   stmt: PISC_STMT_HANDLE;
		                               buffer : PChar; buffer_size : Integer;
                                   da_version: USHORT;
                                   sqlda: PXSQLDA;
                                   ib_xmlda: PIB_XMLDA): Integer stdcall;

  function isc_dsql_xml_fetch_stub(status: PISC_STATUS;
                                 stmt: PISC_STMT_HANDLE;
                                 da_version: USHORT;
                                 sqlda: PXSQLDA;
                                 ib_xmlda: PIB_XMLDA): Integer stdcall;

  function isc_dsql_xml_fetch_all_stub(status: PISC_STATUS;
                                     stmt: PISC_STMT_HANDLE;
                                     da_version: USHORT;
                                     sqlda: PXSQLDA;
                                     ib_xmlda: PIB_XMLDA): Integer stdcall;

  function isc_dsql_xml_buffer_fetch_stub(status : PISC_STATUS;
                                   stmt: PISC_STMT_HANDLE;
		                               buffer : PChar; buffer_size : Integer;
                                   da_version: USHORT;
                                   sqlda: PXSQLDA;
                                   ib_xmlda: PIB_XMLDA): Integer stdcall;

var
  isc_dsql_xml_fetch : Tisc_dsql_xml_fetch;
  isc_dsql_xml_fetch_all : Tisc_dsql_xml_fetch_all;
  isc_dsql_xml_buffer_fetch : Tisc_dsql_xml_buffer_fetch;


implementation

uses IBXConst, IB, SysUtils;

function isc_dsql_xml_fetch_stub(status: PISC_STATUS;
                               stmt: PISC_STMT_HANDLE;
                               da_version: USHORT;
                               sqlda: PXSQLDA;
                               ib_xmlda: PIB_XMLDA): Integer stdcall;
begin
  raise EIBClientError.Create(Format(SIB65feature, ['isc_dsql_xml_fetch '])); {do not localize}
end;

function isc_dsql_xml_fetch_all_stub (status: PISC_STATUS;
                                   stmt: PISC_STMT_HANDLE;
                                   da_version: USHORT;
                                   sqlda: PXSQLDA;
                                   ib_xmlda: PIB_XMLDA): Integer stdcall;
begin
  raise EIBClientError.Create(Format(SIB65feature, ['isc_dsql_xml_fetch_all '])); {do not localize}
end;

function isc_dsql_xml_buffer_fetch_stub(status : PISC_STATUS;
                                 stmt: PISC_STMT_HANDLE;
                                 buffer : PChar; buffer_size : Integer;
                                 da_version: USHORT;
                                 sqlda: PXSQLDA;
                                 ib_xmlda: PIB_XMLDA): Integer stdcall; 
begin
  raise EIBClientError.Create(Format(SIB65feature, ['isc_dsql_xml_buffer_fetch '])); {do not localize}
end;

end.
