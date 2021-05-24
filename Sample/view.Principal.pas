unit view.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Classes,
  System.SysUtils,
  System.Variants,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.WinXCtrls;

type
  TFrmPrincipal = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    edtLink: TEdit;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure edtLinkKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  REST.Types,
  REST4D;

{$R *.dfm}

procedure TFrmPrincipal.Button1Click(Sender: TObject);
begin
  TREST4D.New
    .BaseUrl(edtLink.Text)
    .RESTResponse
      .ContentType(CONTENTTYPE_APPLICATION_JSON)
    .&End
    .OnAfterRequest(
      procedure()
      begin
        Memo1.Lines.Clear;
      end)
    .OnSpecificStatusCode(400,
      procedure(ACode: Integer; AJson: String)
      begin
        Memo1.Lines.Add('Falha na requisição');
        Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
      end)
    .OnSpecificStatusCode(200,
      procedure(ACode: Integer; AJson: String)
      begin
        Memo1.Lines.Add('Sucesso na requisição');
        Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
        Memo1.Lines.Add(AJson);
      end)
    .OnRaisedException(
      procedure(E: Exception)
      begin
        Memo1.Lines.Add('Error: '+ E.Message);
      end)
    .Get();
end;

procedure TFrmPrincipal.edtLinkKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    Button1.Click;
end;

end.
