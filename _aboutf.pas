unit _aboutf;

{$mode objfpc}{$H+}

interface

uses Forms, StdCtrls, Buttons, ExtCtrls, Classes;

type

  { Taboutf }

  Taboutf = class(TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    OKBtn: TBitBtn;
    Memo1: TMemo;
    Panel4: TPanel;
    ProgramIcon: TImage;
    procedure FormShow(Sender: TObject);
  private
  public
  end;

var
  aboutf: Taboutf;

implementation

uses _global;

{$R *.lfm}

{ Taboutf }

procedure Taboutf.FormShow(Sender: TObject);
begin
  Caption := 'About ' + AppName;
end;

end.

