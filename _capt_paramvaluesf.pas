unit _capt_paramvaluesf;

{$mode objfpc}{$H+}

interface

uses
  Forms, ExtCtrls, Buttons, StdCtrls, _global;

type

  { Tcapt_paramvaluesf }

  Tcapt_paramvaluesf = class(TForm)
    CancelBtn: TBitBtn;
    GroupBox1: TGroupBox;
    OkBtn: TBitBtn;
    Panel1: TPanel;
    Panel2: TPanel;
    PARAMIDBox: TLabeledEdit;
    PARAMVALUEBox: TLabeledEdit;
  private
  public
    procedure FillForm(CaptureState: TCaptureState);
  end;

var
  capt_paramvaluesf: Tcapt_paramvaluesf;

implementation

uses _t_paramvaluesf;

{$R *.lfm}

procedure Tcapt_paramvaluesf.FillForm(CaptureState: TCaptureState);
begin
  if CaptureState = csEdit then
  begin
    PARAMIDBox.Text := t_paramvaluesf.T_PARAMVALUESQPARAMID.AsString;
    PARAMVALUEBox.Text := t_paramvaluesf.T_PARAMVALUESQPARAMVALUE.AsString;
  end;
end;

end.

