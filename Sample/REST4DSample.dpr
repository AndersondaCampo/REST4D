program REST4DSample;

uses
  Vcl.Forms,
  view.Principal in 'view.Principal.pas' {FrmPrincipal},
  REST4D.Client in '..\src\REST4D.Client.pas',
  REST4D.interfaces in '..\src\REST4D.interfaces.pas',
  REST4D in '..\src\REST4D.pas',
  REST4D.Request in '..\src\REST4D.Request.pas',
  REST4D.Response in '..\src\REST4D.Response.pas',
  REST4D.Objects in '..\src\REST4D.Objects.pas',
  REST4D.OAuth2 in '..\src\REST4D.OAuth2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  ReportMemoryLeaksOnShutdown   := True;

  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
