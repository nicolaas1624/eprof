unit _initlookupsf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, StdCtrls, IBSQL;

type

  { Tinitlookupsf }

  Tinitlookupsf = class(TForm)
    Memo1: TMemo;
    procedure FormActivate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure RunSQL(SQLStr: String);
    procedure InitLookupData;
    procedure InitHelpData;
  public
    InitFlag: SmallInt; // 0 = lookups, 1 = Help
  end;

var
  initlookupsf: Tinitlookupsf;

implementation

uses _dm, _mainf;

{$R *.lfm}

procedure Tinitlookupsf.FormActivate(Sender: TObject);
begin
  if InitFlag = 0 then
    InitLookupData
  else if InitFlag = 1 then
    InitHelpData;
end;

procedure Tinitlookupsf.FormShow(Sender: TObject);
begin
  Top := 2 * mainf.StatusBar1.Height;
  Height := mainf.Height - 4 * mainf.StatusBar1.Height;
end;

procedure Tinitlookupsf.RunSQL(SQLStr: String);
begin
  try
    Memo1.Lines.Add(SQLStr);
    dm.RunSQL(SQLStr);
  except // on E:Exception do
  end;
end;

procedure Tinitlookupsf.InitLookupData;
var
  S: String;

  procedure InsT_LOOKUP(GRPVal: String; IDVal: Integer; DESCRVal: String);
  begin
    try
      S := 'INSERT INTO T_LOOKUP (GRP,ID,DESCR) VALUES (''' + GRPVal + ''',' + IntToStr(IDVal) + ',''' + DESCRVal + ''')';
      Memo1.Lines.Add(S);
      dm.RunSQL(S);
    except
    end;
  end;

begin
  Memo1.Lines.Add('Initialize lookups...');

  InsT_LOOKUP('YESNO', 0, 'No');
  InsT_LOOKUP('YESNO', 1, 'Yes');

  InsT_LOOKUP('MONTHS', 1, 'January');
  InsT_LOOKUP('MONTHS', 2, 'February');
  InsT_LOOKUP('MONTHS', 3, 'March');
  InsT_LOOKUP('MONTHS', 4, 'April');
  InsT_LOOKUP('MONTHS', 5, 'May');
  InsT_LOOKUP('MONTHS', 6, 'June');
  InsT_LOOKUP('MONTHS', 7, 'July');
  InsT_LOOKUP('MONTHS', 8, 'August');
  InsT_LOOKUP('MONTHS', 9, 'September');
  InsT_LOOKUP('MONTHS', 10, 'October');
  InsT_LOOKUP('MONTHS', 11, 'November');
  InsT_LOOKUP('MONTHS', 12, 'December');

  InsT_LOOKUP('SHORTMONTHS', 1, 'Jan');
  InsT_LOOKUP('SHORTMONTHS', 2, 'Feb');
  InsT_LOOKUP('SHORTMONTHS', 3, 'Mar');
  InsT_LOOKUP('SHORTMONTHS', 4, 'Apr');
  InsT_LOOKUP('SHORTMONTHS', 5, 'May');
  InsT_LOOKUP('SHORTMONTHS', 6, 'Jun');
  InsT_LOOKUP('SHORTMONTHS', 7, 'Jul');
  InsT_LOOKUP('SHORTMONTHS', 8, 'Aug');
  InsT_LOOKUP('SHORTMONTHS', 9, 'Sep');
  InsT_LOOKUP('SHORTMONTHS', 10, 'Oct');
  InsT_LOOKUP('SHORTMONTHS', 11, 'Nov');
  InsT_LOOKUP('SHORTMONTHS', 12, 'Dec');

  InsT_LOOKUP('SHORTDAYS', 1, 'Sun');
  InsT_LOOKUP('SHORTDAYS', 2, 'Mon');
  InsT_LOOKUP('SHORTDAYS', 3, 'Tue');
  InsT_LOOKUP('SHORTDAYS', 4, 'Wed');
  InsT_LOOKUP('SHORTDAYS', 5, 'Thu');
  InsT_LOOKUP('SHORTDAYS', 6, 'Fri');
  InsT_LOOKUP('SHORTDAYS', 7, 'Sat');

  InsT_LOOKUP('PICT_GROUP', 0, 'General');
  InsT_LOOKUP('PICT_GROUP', 1, 'Contacts');

  InsT_LOOKUP('LOG_ACTIVITY', 1, 'Insert');
  InsT_LOOKUP('LOG_ACTIVITY', 2, 'Edit');
  InsT_LOOKUP('LOG_ACTIVITY', 3, 'Delete');
  InsT_LOOKUP('LOG_ACTIVITY', 4, 'Verify');

  InsT_LOOKUP('EMAILLOGTYPES', 0, 'General');

  InsT_LOOKUP('DATEFORMAT', 1, 'dd/mm/yyyy');
  InsT_LOOKUP('DATEFORMAT', 2, 'mm/dd/yyyy');
  InsT_LOOKUP('DATEFORMAT', 3, 'dd/mm/yy');
  InsT_LOOKUP('DATEFORMAT', 4, 'yyyy/mm/dd');
  InsT_LOOKUP('DATEFORMAT', 5, 'yy/mm/dd');
  InsT_LOOKUP('DATEFORMAT', 6, 'dd.mm.yyyy');
  InsT_LOOKUP('DATEFORMAT', 7, 'mm.dd.yyyy');
  InsT_LOOKUP('DATEFORMAT', 8, 'dd.mm.yy');
  InsT_LOOKUP('DATEFORMAT', 9, 'yyyy.mm.dd');
  InsT_LOOKUP('DATEFORMAT', 10, 'yy.mm.dd');
  InsT_LOOKUP('DATEFORMAT', 11, 'ddmmyyyy');
  InsT_LOOKUP('DATEFORMAT', 12, 'ddmmmyyyy');
  InsT_LOOKUP('DATEFORMAT', 13, 'ddmmyy');
  InsT_LOOKUP('DATEFORMAT', 14, 'yyyymmdd');
  InsT_LOOKUP('DATEFORMAT', 15, 'yymmdd');
  InsT_LOOKUP('DATEFORMAT', 16, 'yyyy-mm-dd');

  InsT_LOOKUP('TIMEFORMAT', 1, 'hh:mm');
  InsT_LOOKUP('TIMEFORMAT', 2, 'hh:mm AM');
  InsT_LOOKUP('TIMEFORMAT', 3, 'hhmm');
  InsT_LOOKUP('TIMEFORMAT', 4, 'hhmmss');
  InsT_LOOKUP('TIMEFORMAT', 5, 'hhmm AM');
  InsT_LOOKUP('TIMEFORMAT', 6, 'hh:mm:ss');
  InsT_LOOKUP('TIMEFORMAT', 7, 'hh:mm:ss AM');

  dm.InsUpdParamValue('DEL_PASSW', 'Delete');
  dm.InsUpdParamValue('IMAGE_W_MM', '44');
  dm.InsUpdParamValue('IMAGE_H_MM', '33');
  dm.InsUpdParamValue('IMAGE_X_MM', '10');
  dm.InsUpdParamValue('IMAGE_Y_MM', '10');

  InsT_LOOKUP('HELP_CAT', 1, 'General');

  dm.IBTransaction1.CommitRetaining;
  Memo1.Lines.Add('Commit retaining');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Finished.....');
end;

procedure Tinitlookupsf.InitHelpData;

  procedure InsUpdDelT_HELP(IDVal, CATIDVal, ORDERNOVal: Integer; DESCRVal, FILENAMEVal, KEYWORDSVal: String);
  var
    Q: TIBSQL;
  begin
    Q := TIBSQL.Create(nil);
    try
      Q.Database := dm.IBDatabase1;
      Q.Transaction := dm.IBTransaction1;
      Q.SQL.Add('INSERT INTO T_HELP(ID,CATID,ORDERNO,DESCR,FILENAME,KEYWORDS)');
      Q.SQL.Add('VALUES(:ID,:CATID,:ORDERNO,:DESCR,:FILENAME,:KEYWORDS)');
      Q.ParamByName('ID').AsInteger := IDVal;
      Q.ParamByName('CATID').AsInteger := CATIDVal;
      Q.ParamByName('ORDERNO').AsInteger := ORDERNOVal;
      Q.ParamByName('DESCR').AsString := DESCRVal;
      Q.ParamByName('FILENAME').AsString := FILENAMEVal;
      Q.ParamByName('KEYWORDS').AsString := KEYWORDSVal;
      Q.Prepare;
      Q.ExecQuery;
      Q.Close;
    finally
      Q.Free;
    end;
    Memo1.Lines.Add(DESCRVal);
  end;

begin
  Memo1.Lines.Add('Initialize Help data...');

  dm.RunSQL('DELETE FROM T_HELP');
  InsUpdDelT_HELP(10, 1, 1, 'Images', 'context_images.pdf', 'images pictures');

  dm.IBTransaction1.CommitRetaining;
  Memo1.Lines.Add('Commit retaining');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Finished.....');
end;

end.

procedure Tinitlookupsf.pFibErrorHandler1FIBErrorEvent(Sender: TObject; ErrorValue: EFIBError; KindIBError: TKindIBError; var DoRaise: Boolean);
begin
  Memo1.Lines.Add('IBErrorCode: ' + IntToStr(ErrorValue.IBErrorCode) + ' IBMessage: ' + ErrorValue.IBMessage);

  { Application.MessageBox(PChar('Error by creating database.' + #10#13 +
    'IBErrorCode: ' + IntToStr(ErrorValue.IBErrorCode) + #10#13 +
    'IBMessage: ' + ErrorValue.IBMessage),'Error', MB_OK + MB_ICONSTOP); }
end;

