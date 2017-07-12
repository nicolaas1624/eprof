unit _dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, IBDatabase, IBSQL, IBQuery, IBStoredProc, Registry;

type

  { Tdm }

  ftpRecType = record
    RemoteHost: string;
    Username: string;
    Pword: string;
    RemotePath: string;
    Localfolder: string;
    FileName: string;
  end;  

  Tdm = class(TDataModule)
    IBDatabase1: TIBDatabase;
    XSPQ: TIBStoredProc;
    XQ: TIBQuery;
    IBTransaction1: TIBTransaction;
  private
  public
    ftpRec: ftpRecType;
    procedure CloseDatabase;
    procedure OpenQ(SelectSQL: string);
    procedure RunSQL(SQLStr: string);
    function GetLookupItems(ADD_ALLVal: integer; GRPVal, ORDERVal: string): string;
    function GetT_LOOKUPID(GRPVal, DESCRVal: string): integer;
    function GetT_SUBSID(DESCRVal: string): integer;
    procedure PDFWriterBypassSaveAs(Value: string);
    procedure PDFWriterSetOutputFile(FileName: string);
    function GetPrinterIndex(PrinterName: string): longint;
    function GetParamValue(PARAMIDVal: String): String;
    procedure InsUpdParamValue(PARAMIDVal, PARAMVal: String);
  end;

var
  dm: Tdm;

implementation

uses _global, printers;

{$R *.lfm}

procedure Tdm.CloseDatabase;
var
  i: Integer;
begin
  if IBDatabase1.Connected then
  begin
    for i := 0 to IBDatabase1.TransactionCount - 1 do
      if TIBTransaction(IBDatabase1.Transactions[i]).InTransaction then
        TIBTransaction(IBDatabase1.Transactions[i]).Commit;
    IBDatabase1.CloseDataSets;
    IBDatabase1.Close;
  end;
end;

procedure Tdm.OpenQ(SelectSQL: string);
begin
  XQ.Close;
  XQ.SQL.Clear;
  XQ.SQL.Add(SelectSQL);
  XQ.Prepare;
  XQ.Open;
end;

procedure Tdm.RunSQL(SQLStr: string);
var
  Q: TIBSQL;
begin
  Q := TIBSQL.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.SQL.Add(SQLStr);
    Q.Prepare;
    Q.ExecQuery;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function Tdm.GetLookupItems(ADD_ALLVal: integer; GRPVal, ORDERVal: string): string;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.SQL.Add('SELECT RESULT FROM GETLOOKUPITEMS(:GRPVAL,:ADDALL,:ORDERVAL)');
    Q.ParamByName('GRPVAL').AsString := GRPVal;
    Q.ParamByName('ADDALL').AsInteger := ADD_ALLVal;
    Q.ParamByName('ORDERVAL').AsString := ORDERVal;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('RESULT').AsString;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function Tdm.GetT_LOOKUPID(GRPVal, DESCRVal: string): integer;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.SQL.Add('SELECT ID FROM T_LOOKUP WHERE GRP = :GRP AND DESCR = :DESCR');
    Q.ParamByName('GRP').AsString := GRPVal;
    Q.ParamByName('DESCR').AsString := DESCRVal;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('ID').AsInteger;
    Q.Close;
  finally
    Q.Free;
  end;
end;

function Tdm.GetT_SUBSID(DESCRVal: string): integer;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.SQL.Add('SELECT SUBID FROM T_SUBS WHERE DESCR = :DESCR');
    Q.ParamByName('DESCR').AsString := DESCRVal;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('SUBID').AsInteger;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Tdm.PDFWriterBypassSaveAs(Value: string);      //'1' = By pass save as dialog
begin
  RegIni := TRegIniFile.Create('Software');
  RegIni.WriteString('NBSystems PDF Writer', 'BypassSaveAs', Value);
  RegIni.FreeInstance;
end;

procedure Tdm.PDFWriterSetOutputFile(FileName: string);
begin
  RegIni := TRegIniFile.Create('Software');
  RegIni.WriteString('NBSystems PDF Writer', 'OutputFile', FileName);
  RegIni.WriteString('NBSystems PDF Writer', 'EmailPDF', '');
  RegIni.FreeInstance;
end; 

function Tdm.GetPrinterIndex(PrinterName: string): longint;
var
  i: integer;
begin
  result := -1;
  for i := 0 to Printer.Printers.Count - 1 do
    if Printer.Printers[i] = PrinterName then
    begin
      result := i;
      exit;
    end;
end;  

function Tdm.GetParamValue(PARAMIDVal: String): String;
var
  Q: TIBQuery;
begin
  Q := TIBQuery.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.SQL.Add('SELECT RESULT FROM GET_PARAMETER(:PARAMIDVAL)');
    Q.ParamByName('PARAMIDVAL').AsString := PARAMIDVal;
    Q.Prepare;
    Q.Open;
    Result := Q.FieldByName('RESULT').AsString;
    Q.Close;
  finally
    Q.Free;
  end;
end;

procedure Tdm.InsUpdParamValue(PARAMIDVal, PARAMVal: String);
var
  Q: TIBStoredProc;
begin
  Q := TIBStoredProc.Create(nil);
  try
    Q.DataBase := IBDatabase1;
    Q.Transaction := IBTransaction1;
    Q.StoredProcName := 'T_PARAMVALUES_IU';
    Q.ParamByName('PARAMID').AsString := PARAMIDVal;
    Q.ParamByName('PARAMVALUE').AsString := PARAMVal;
    Q.Prepare;
    Q.ExecProc;
    Q.Close;
  finally
    Q.Free;
  end;
end;

end.
