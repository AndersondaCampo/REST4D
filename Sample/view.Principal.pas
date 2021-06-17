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
    Button2: TButton;
    ActivityIndicator: TActivityIndicator;
    procedure Button1Click(Sender: TObject);
    procedure edtLinkKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
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
  { requisição pela thread principal do app }
  TREST4D.New
    .BaseUrl(edtLink.Text)
    .RESTResponse
      .ContentType(CONTENTTYPE_APPLICATION_JSON)
    .&End
    .OnBeforeRequest(
      procedure()
      begin
        Memo1.Lines.Clear;
        Sleep(5000);
      end)
    .OnSpecificStatusCode(400,
      procedure(ACode: Integer; AJson: String)
      begin
        Memo1.Lines.Add('Falha na requisição por thread principal');
        Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
      end)
    .OnSpecificStatusCode(200,
      procedure(ACode: Integer; AJson: String)
      begin
        Memo1.Lines.Add('Sucesso na requisição por thread principal');
        Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
      end)
    .OnAfterRequest(
      procedure(ACode: Integer; AJson: String)
      begin
        Memo1.Lines.Add(AJson);
      end)
    .OnRaisedException(
      procedure(E: Exception)
      begin
        Memo1.Lines.Add('Error: '+ E.Message);
      end)
    .Get();
end;

procedure TFrmPrincipal.Button2Click(Sender: TObject);
begin
  { requisição por thread paralela }
  TREST4D.Async
    .BaseUrl(edtLink.Text)
    .RESTResponse
      .ContentType(CONTENTTYPE_APPLICATION_JSON)
    .&End
    .OnBeforeRequest(
      procedure()
      begin
        TThread.Queue(nil,
          procedure()
          begin
            ActivityIndicator.Animate := True;
            Memo1.Lines.Clear;
          end);

          Sleep(5000);
      end)
    .OnSpecificStatusCode(400,
      procedure(ACode: Integer; AJson: String)
      begin
        TThread.Queue(nil,
          procedure()
          begin
            Memo1.Lines.Add('Falha na requisição por thread paralela');
            Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
            ActivityIndicator.Animate := False;
          end);
      end)
    .OnSpecificStatusCode(200,
      procedure(ACode: Integer; AJson: String)
      begin
        TThread.Queue(nil,
          procedure()
          begin
            Memo1.Lines.Add('Sucesso na requisição por thread paralela');
            Memo1.Lines.Add('StatusCode: '+ ACode.ToString);
            ActivityIndicator.Animate := False;
          end);
      end)
    .OnAfterRequest(
      procedure(ACode: Integer; AJson: String)
      begin
        TThread.Queue(nil,
          procedure()
          begin
            Memo1.Lines.Add(AJson);
          end);
      end)
    .OnRaisedException(
      procedure(E: Exception)
      begin
        TThread.Queue(nil,
          procedure()
          begin
            Memo1.Lines.Add('Error: '+ E.Message);
            ActivityIndicator.Animate := False;
          end);
      end)
    .Get();
end;

procedure TFrmPrincipal.edtLinkKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
    Button1.Click;
end;

end.
