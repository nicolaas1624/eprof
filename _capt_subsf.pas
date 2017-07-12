unit _capt_subsf;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, _global;

type

  { Tcapt_subsf }

  Tcapt_subsf = class(TForm)
    CancelBtn: TBitBtn;
    DESCRBox: TLabeledEdit;
    SERIALNOBox: TLabeledEdit;
    GroupBox1: TGroupBox;
    SUBIDBox: TLabeledEdit;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
  private
  public
    procedure FillForm(CaptureState: TCaptureState);
  end;

var
  capt_subsf: Tcapt_subsf;

implementation

uses _t_subsf;

{$R *.lfm}

procedure Tcapt_subsf.FillForm(CaptureState: TCaptureState);
begin
  if CaptureState = csInsert then
  begin
  end
  else if CaptureState = csEdit then
  begin
    SUBIDBox.Text := t_subsf.T_SUBSQSUBID.AsString;
    DESCRBox.Text := t_subsf.T_SUBSQDESCR.AsString;
    SERIALNOBox.Text := t_subsf.T_SUBSQSERIALNO.AsString;
  end;
end;

end.

