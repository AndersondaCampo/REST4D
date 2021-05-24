unit REST4D;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  REST.Client,
  REST.Response.Adapter,
  REST.Types,
  Data.DB,
  REST4D.interfaces;

type
  TREST4D = Class(TInterfacedObject, IREST4D)
  private
    { Fields }
    FStatusCode   : Integer;
    FJSONValue    : TJSONValue;
    FJSONString   : String;
    FServerMessage: String;
    FAsync        : Boolean;

    { Objects }
    FRESTClient        : TRESTClient;
    FRESTResponse      : TRESTResponse;
    FRESTRequest       : TRESTRequest;
    FRESTDatasetAdapter: TRESTResponseDataSetAdapter;
    FDataset           : TDataSet;
    FProcsOnStatusCode : TDictionary<Integer, TProc<Integer, String>>;

    { interfaces }
    FIClient  : IClient<IREST4D>;
    FIResponse: IResponse<IREST4D>;
    FIRequest : IRequest<IREST4D>;

    { Events }
    FOnAfterRequest   : TProc;
    FOnBeforeRequest  : TProc;
    FOnBeforeRequestP : TProc<Integer, String>;
    FOnRaisedException: TProc<Exception>;

    procedure JoinObjects;
    procedure ResetFields;
    procedure SetConfiguration;
    procedure SetResult;
    procedure ExecProcs;
  public
    function RESTClient: IClient<IREST4D>;
    function RESTResponse: IResponse<IREST4D>;
    function RESTRequest: IRequest<IREST4D>;
    function BaseUrl(const AValue: String): IREST4D;
    function Resource(const AValue: String): IREST4D;
    function AddHeader(const AKey, AValue: String): IREST4D;
    function AddParam(const AKey, AValue: String): IREST4D;
    function ParamOption(const AParamName: String; AOptions: TRESTRequestParameterOptions): IREST4D;
    function AddBody(const AValue: String; const ContentType: String): IREST4D;
    function AddFile(const AName, AFilePath: String): IREST4D;
    function Get(ResetConfiguration: Boolean = False): IREST4D;
    function Put(ResetConfiguration: Boolean = False): IREST4D;
    function Post(ResetConfiguration: Boolean = False): IREST4D;
    function Delete(ResetConfiguration: Boolean = False): IREST4D;
    function DatasetAdapter(var AValue: TDataSet): IREST4D;
    function OnAfterRequest(AValue: TProc): IREST4D;
    function OnBeforeRequest(AValue: TProc): IREST4D; overload;
    function OnBeforeRequest(AValue: TProc<Integer, String>): IREST4D; overload;
    function OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, String>): IREST4D;
    function OnRaisedException(AValue: TProc<Exception>): IREST4D;
    function StatusCode: Integer;
    function JSONValue: TJSONValue;
    function JSONString: String;

    class function New: IREST4D;
    constructor Create;
    destructor Destroy; override;
  End;

implementation

uses
  IpPeerClient,
  REST4D.Response,
  REST4D.Client,
  REST4D.Request;

{ TREST4D<T> }

function TREST4D.AddBody(const AValue: String; const ContentType: String): IREST4D;
begin
  Result := Self;

  if AValue.IsEmpty then
    Exit;

  FRESTRequest.Body.Add(AValue, ContentTypeFromString(ContentType));
end;

function TREST4D.AddFile(const AName, AFilePath: String): IREST4D;
begin
  Result := Self;
  FRESTRequest.AddFile(AName,  AFilePath);
end;

function TREST4D.AddHeader(const AKey, AValue: String): IREST4D;
begin
  Result := Self;
  FRESTRequest.Params.AddHeader(AKey, AValue);
end;

function TREST4D.AddParam(const AKey, AValue: String): IREST4D;
begin
  Result := Self;
  FRESTRequest.Params.AddItem(AKey, AValue);
end;

function TREST4D.BaseUrl(const AValue: String): IREST4D;
begin
  Result              := Self;
  FRESTClient.BaseURL := AValue;
end;

constructor TREST4D.Create();
begin
  { Fields }
  ResetFields;

  { Objects }
  FRESTClient         := TRESTClient.Create(nil);
  FRESTResponse       := TRESTResponse.Create(nil);
  FRESTRequest        := TRESTRequest.Create(nil);
  FProcsOnStatusCode  := TDictionary<Integer, TProc<Integer, String>>.Create();
  FRESTDatasetAdapter := TRESTResponseDataSetAdapter.Create(nil);

  JoinObjects;

  FIClient   := TClient<IREST4D>.New(Self, FRESTClient);
  FIResponse := TResponse<IREST4D>.New(Self, FRESTResponse);
  FIRequest  := TRequest<IREST4D>.New(Self, FRESTRequest);
end;

function TREST4D.DatasetAdapter(var AValue: TDataSet): IREST4D;
begin
  Result                         := Self;
  FRESTDatasetAdapter.Response   := FRESTResponse;
  FRESTDatasetAdapter.Dataset    := AValue;
  FRESTDatasetAdapter.Active     := True;
  FRESTDatasetAdapter.AutoUpdate := True;
end;

function TREST4D.Delete(ResetConfiguration: Boolean): IREST4D;
begin
  Result              := Self;
  FRESTRequest.Method := rmDELETE;

  if Assigned(FOnAfterRequest) then
    FOnAfterRequest();

  SetConfiguration;
  try
    FRESTRequest.Execute;
    SetResult;
  except
    on E: Exception do
    begin
      if Assigned(FOnRaisedException) then
      begin
        FOnRaisedException(E);

        Exit;
      end;
    end;
  end;

  ExecProcs;
end;

destructor TREST4D.Destroy;
begin
  FRESTClient.DisposeOf;
  FRESTResponse.DisposeOf;
  FRESTRequest.DisposeOf;
  FRESTDatasetAdapter.DisposeOf;
  FProcsOnStatusCode.DisposeOf;

  inherited;
end;

procedure TREST4D.ExecProcs;
var
  Proc: TProc<Integer, String>;
begin
  if Assigned(FOnBeforeRequest) then
    FOnBeforeRequest();

  if Assigned(FOnBeforeRequestP) then
    FOnBeforeRequestP(FStatusCode, FJSONString);

  if FProcsOnStatusCode.TryGetValue(FStatusCode, Proc) then
    Proc(FStatusCode, FJSONString);
end;

function TREST4D.Get(ResetConfiguration: Boolean): IREST4D;
begin
  Result := Self;

  FRESTRequest.Method := rmGET;

  if Assigned(FOnAfterRequest) then
    FOnAfterRequest();

  SetConfiguration;
  try
    FRESTRequest.Execute;
    SetResult;
  except
    on E: Exception do
    begin
      if Assigned(FOnRaisedException) then
      begin
        FOnRaisedException(E);

        Exit;
      end;
    end;
  end;

  ExecProcs;
end;

procedure TREST4D.JoinObjects;
begin
  FRESTRequest.Client         := FRESTClient;
  FRESTRequest.Response       := FRESTResponse;
end;

function TREST4D.JSONValue: TJSONValue;
begin
  Result := FJSONValue;
end;

class function TREST4D.New: IREST4D;
begin
  Result := TREST4D.Create;
end;

function TREST4D.OnAfterRequest(AValue: TProc): IREST4D;
begin
  Result          := Self;
  FOnAfterRequest := AValue;
end;

function TREST4D.OnBeforeRequest(AValue: TProc<Integer, String>): IREST4D;
begin
  Result            := Self;
  FOnBeforeRequestP := AValue;
end;

function TREST4D.OnBeforeRequest(AValue: TProc): IREST4D;
begin
  Result           := Self;
  FOnBeforeRequest := AValue;
end;

function TREST4D.OnRaisedException(AValue: TProc<Exception>): IREST4D;
begin
  Result             := Self;
  FOnRaisedException := AValue;
end;

function TREST4D.OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, String>): IREST4D;
begin
  Result := Self;
  FProcsOnStatusCode.AddOrSetValue(ACode, AProc);
end;

function TREST4D.ParamOption(const AParamName: String; AOptions: TRESTRequestParameterOptions): IREST4D;
begin
  Result                                                  := Self;
  FRESTRequest.Params.ParameterByName(AParamName).Options := AOptions;
end;

function TREST4D.Post(ResetConfiguration: Boolean): IREST4D;
begin
  Result              := Self;
  FRESTRequest.Method := rmPOST;

  if Assigned(FOnAfterRequest) then
    FOnAfterRequest();

  SetConfiguration;
  try
    FRESTRequest.Execute;
    SetResult;
  except
    on E: Exception do
    begin
      if Assigned(FOnRaisedException) then
      begin
        FOnRaisedException(E);

        Exit;
      end;
    end;
  end;

  ExecProcs;
end;

function TREST4D.Put(ResetConfiguration: Boolean): IREST4D;
begin
  Result              := Self;
  FRESTRequest.Method := rmPUT;;

  if Assigned(FOnAfterRequest) then
    FOnAfterRequest();

  SetConfiguration;
  try
    FRESTRequest.Execute;
    SetResult;
  except
    on E: Exception do
    begin
      if Assigned(FOnRaisedException) then
      begin
        FOnRaisedException(E);

        Exit;
      end;
    end;
  end;

  ExecProcs;
end;

procedure TREST4D.ResetFields;
begin
  FStatusCode   := 0;
  FJSONValue    := nil;
  FJSONString   := EmptyStr;
  FServerMessage:= EmptyStr;
  FAsync        := False;
end;

function TREST4D.Resource(const AValue: String): IREST4D;
begin
  Result := Self;
  FRESTRequest.Resource := AValue;
end;

function TREST4D.RESTClient: IClient<IREST4D>;
begin
  Result := FIClient;
end;

function TREST4D.RESTRequest: IRequest<IREST4D>;
begin
  Result := FIRequest;
end;

function TREST4D.RESTResponse: IResponse<IREST4D>;
begin
  Result := FIResponse;
end;

procedure TREST4D.SetConfiguration;
begin
  if Assigned(FIClient) then
  begin
    FRESTClient.Accept              := FIClient.Accept;
    FRESTClient.ContentType         := FIClient.ContentType;
    FRESTClient.UserAgent           := FIClient.UserAgent;
    FRESTClient.AcceptCharset       := FIClient.AcceptCharset;
    FRESTClient.HandleRedirects     := FIClient.HandleRedirects;
    FRESTClient.RaiseExceptionOn500 := FIClient.RaiseExceptionOn500;
  end;

  if Assigned(FIResponse) then
  begin
    FRESTResponse.ContentType := FIResponse.ContentType;
  end;

  if Assigned(FIRequest) then
  begin
    FRESTRequest.SynchronizedEvents := FIRequest.SynchronizedEvents;
    FRESTRequest.AcceptEncoding     := FIRequest.AcceptEncoding;
  end;
end;

procedure TREST4D.SetResult;
begin
  FStatusCode := FRESTResponse.StatusCode;
  FJSONValue  := FRESTResponse.JSONValue;
  FJSONString := FRESTResponse.JSONText;
end;

function TREST4D.StatusCode: Integer;
begin
  Result := FStatusCode;
end;

function TREST4D.JSONString: String;
begin
  Result := FJSONString;
end;

end.
