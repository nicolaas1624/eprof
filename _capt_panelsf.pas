unit _capt_panelsf;

{$mode objfpc}{$H+}

interface

uses
  Forms, ExtCtrls, StdCtrls, Buttons, _global, strutils, Classes, sysutils;

type

  { Tcapt_panelsf }

  Tcapt_panelsf = class(TForm)
    CancelBtn: TBitBtn;
    panelidbox: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    SUBIDBox: TComboBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    paneltypebox: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
  public
    procedure FillForm(CaptureState: TCaptureState);
  end;

var
  capt_panelsf: Tcapt_panelsf;

implementation

uses _dm, _t_panelsf;

{$R *.lfm}

procedure Tcapt_panelsf.FormCreate(Sender: TObject);
begin
  //if Sender = t_panelsf then
  //begin
  //  Width := 275;
  //  panelidbox.Visible:= false;
  //  paneltypebox.Visible:= false;
  //  label2.Visible:= false;
  //  label3.Visible:= false;
  //end
  //else
  //begin
  //  Width := 475;
  //  panelidbox.Visible:= true;
  //  paneltypebox.Visible:= true;
  //  label2.Visible:= true;
  //  label3.Visible:= true;
  //end;
  paneltypebox.Items.CommaText := 'P,Q,S,F';
  paneltypebox.ItemIndex := 0;
end;

procedure Tcapt_panelsf.FillForm(CaptureState: TCaptureState);
begin
  dm.OpenQ('SELECT DESCR FROM T_SUBS ORDER BY DESCR');
  while not dm.XQ.EOF do
  begin
    SUBIDBox.Items.Add(dm.XQ.FieldByName('DESCR').AsString);
    dm.XQ.Next;
  end;
  dm.XQ.Close;
  if CaptureState = csEdit then
  begin
    SUBIDBox.Text := t_panelsf.t_panelsQSUBIDDESCR.AsString;
    if t_panelsf.t_panelsQPANELTPE.AsString <> '' then
      paneltypebox.text := t_panelsf.t_panelsQPANELTPE.AsString
    else
      paneltypebox.ItemIndex := 0;
    if t_panelsf.t_panelsQPANELID.AsString <> '' then
      panelidbox.text := IntToStr(t_panelsf.t_panelsQPANELID.AsInteger)
    else
      panelidbox.text := IntToStr(t_panelsf.t_panelsQRECNO.AsInteger);
  end;
end;


end.

