unit _password;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, StdCtrls;

type
  Tpassworddlg = class(TForm)
    Label1: TLabel;
    PassWord: TEdit;
    OKBtn: TButton;
    CancelBtn: TButton;
    procedure OKBtnClick(Sender: TObject);
  private
    PassWordStr: String;
    PassWordOk: Boolean;
  public
  end;

var
  passworddlg: Tpassworddlg;

function GetPassWord(PassWord: String): Boolean;  

implementation

{$R *.lfm}

procedure Tpassworddlg.OKBtnClick(Sender: TObject);
begin
  PassWordOk := PassWordStr = passworddlg.PassWord.Text;
end;

function GetPassWord(PassWord: String): Boolean;
begin
  passworddlg := Tpassworddlg.Create(Application);
  passworddlg.PassWordStr := PassWord;
  try
    passworddlg.ShowModal;
    Result := passworddlg.PassWordOk;
  finally
    FreeAndNil(passworddlg);
  end;
end;

end.

