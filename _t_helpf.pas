unit _t_helpf;

interface

uses
  Controls, Forms, DBGrids, StdCtrls, ExtCtrls, DB, Buttons, DBCtrls,
  IBQuery, IBCustomDataSet;

type

  { Tt_helpf }

  Tt_helpf = class(TForm)
    DBNavigator1: TDBNavigator;
    T_HELPQ: TIBQuery;
    T_HELPQCATID: TIntegerField;
    T_HELPQCATIDDESCR: TIBStringField;
    T_HELPQDESCR: TIBStringField;
    T_HELPQFILENAME: TIBStringField;
    T_HELPQID: TIntegerField;
    T_HELPQKEYWORDS: TIBStringField;
    T_HELPQORDERNO: TIntegerField;
    Panel1: TPanel;
    Label3: TLabel;
    SpeedButton2: TSpeedButton;
    CATIDBox: TComboBox;
    SearchBox: TLabeledEdit;
    DataSource1: TDataSource;
    Panel2: TPanel;
    CancelBtn: TBitBtn;
    OpenBtn: TBitBtn;
    Panel3: TPanel;
    DBGrid1: TDBGrid;
    Label1: TLabel;
    SortBox: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure SortBoxChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure SpeedButton2Click(Sender: TObject);
    procedure OpenBtnClick(Sender: TObject);
  private
    IDVal: SmallInt;
    procedure OpenT_HELPQ(Order: String);
  public
  end;

var
  t_helpf: Tt_helpf;

implementation

{$R *.lfm}

uses _dm, _mainf;

procedure Tt_helpf.FormShow(Sender: TObject);
begin
  try
    Screen.Cursor := crHourglass;
    SortBox.Items.CommaText := 'Type, Description';
    SortBox.Text := 'Type';
    CATIDBox.Items.CommaText := dm.GetLookupItems(1, 'HELP_CAT', 'DESCR');
    CATIDBox.Text := '*ALL*';
    SortBoxChange(Sender);
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure Tt_helpf.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  T_HELPQ.Close;
end;

procedure Tt_helpf.OpenT_HELPQ(Order: String);
begin
  T_HELPQ.Close;
  T_HELPQ.SQL.Clear;
  T_HELPQ.SQL.Add('SELECT * FROM V_HELP WHERE ID >= 0');
  if CATIDBox.Text <> '*ALL*' then
  begin
    T_HELPQ.SQL.Add('AND CATIDDESCR = :CATIDDESCR');
    T_HELPQ.ParamByName('CATIDDESCR').AsString := CATIDBox.Text;
  end;
  if SearchBox.Text <> '' then
  begin
    T_HELPQ.SQL.Add('AND KEYWORDS CONTAINING :KEYWORDS');
    T_HELPQ.ParamByName('KEYWORDS').AsString := SearchBox.Text;
  end;
  T_HELPQ.SQL.Add('ORDER BY ' + Order);
  T_HELPQ.Prepare;
  T_HELPQ.Open;
end;

procedure Tt_helpf.SortBoxChange(Sender: TObject);
var
  S: String;
begin
  if SortBox.Text = 'Description' then
    S := 'DESCR'
  else
    S := 'CATID, ORDERNO';
  OpenT_HELPQ(S);
  T_HELPQ.Locate('ID', IDVal, []);
end;

procedure Tt_helpf.SpeedButton2Click(Sender: TObject);
begin
  SearchBox.Text := '';
  ActiveControl := SearchBox;
end;

procedure Tt_helpf.OpenBtnClick(Sender: TObject);
begin
  mainf.ShowPDFHelp(T_HELPQID.AsInteger);
end;

end.
