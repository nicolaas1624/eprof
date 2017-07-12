unit _dm;

{$mode objfpc}{$H+}

interface

uses
  Classes, IBConnection, sqldb, Registry;

type

  { Tdm }

  Tdm = class(TDataModule)
    fdatabase: TIBConnection;
    ftransaction: TSQLTransaction;
    XQ: TSQLQuery;
  private
  public
    procedure OpenQ(SelectSQL: string);
    procedure RunSQL(SQLStr: string);
    function GetLookupItems(ADD_ALLVal: integer; GRPVal, ORDERVal: string): string;
    function GetT_LOOKUPID(GRPVal, DESCRVal: string): integer;
    procedure PDFWriterBypassSaveAs(Value: string);
    procedure PDFWriterSetOutputFile(FileName: string);
    function GetPrinterIndex(PrinterName: string): longint;
    function GetParamValue(PARAMIDVal: String): String;
    procedure InsUpdParamValue(PARAMIDVal, PARAMVal: String);
  end;

var
  dm: Tdm;

implementation

uses _global;

{$R *.lfm}

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
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := fdatabase;
    Q.Transaction := ftransaction;
    Q.SQL.Add(SQLStr);
    Q.Prepare;
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

function Tdm.GetLookupItems(ADD_ALLVal: integer; GRPVal, ORDERVal: string): string;
var
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := fdatabase;
    Q.Transaction := ftransaction;
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
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := fdatabase;
    Q.Transaction := ftransaction;
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
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := fdatabase;
    Q.Transaction := ftransaction;
    Q.SQL.Add('EXECUTE PROCEDURE GET_PARAMETER(:PARAMIDVAL)');
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
  Q: TSQLQuery;
begin
  Q := TSQLQuery.Create(nil);
  try
    Q.DataBase := fdatabase;
    Q.Transaction := ftransaction;
    Q.SQL.Add('EXECUTE PROCEDURE T_PARAMVALUES_IU(:PARAMID, :PARAMVALUE)');
    Q.ParamByName('PARAMID').AsString := PARAMIDVal;
    Q.ParamByName('PARAMVALUE').AsString := PARAMVal;
    Q.Prepare;
    Q.ExecSQL;
    Q.Close;
  finally
    Q.Free;
  end;
end;

end.