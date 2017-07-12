unit _emailsetupf;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Buttons, StdCtrls, ExtCtrls;

type
  Temailsetupf = class(TForm)
    Panel2: TPanel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Panel1: TPanel;
    GroupBox2: TGroupBox;
    SMTPHostBox: TLabeledEdit;
    SMTPPortBox: TLabeledEdit;
    FromEmailAddrBox: TLabeledEdit;
    EmailUsernameBox: TLabeledEdit;
    EmailPasswordBox: TLabeledEdit;
    procedure FormShow(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
  private
  public
  end;

var
  emailsetupf: Temailsetupf;

implementation

uses _global;

{$R *.lfm}

procedure Temailsetupf.FormShow(Sender: TObject);
begin
  FromEmailAddrBox.Text := cnf.FromEmailAddr;
  SMTPHostBox.Text := cnf.SMTPHost;
  SMTPPortBox.Text := IntToStr(cnf.SMTPPort);
  EmailUsernameBox.Text := cnf.EmailUsername;
  EmailPasswordBox.Text := cnf.EmailPassword;
end;

procedure Temailsetupf.OkBtnClick(Sender: TObject);
begin
  cnf.FromEmailAddr := FromEmailAddrBox.Text;
  cnf.SMTPHost := SMTPHostBox.Text;
  cnf.SMTPPort := StrToInt(SMTPPortBox.Text);
  cnf.EmailUsername := EmailUsernameBox.Text;
  cnf.EmailPassword := EmailPasswordBox.Text;
end;

end.
