program NumeroLingo;

uses
  Forms,
  MainForm in 'MainForm.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Numero Lingo';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
