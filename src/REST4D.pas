unit REST4D;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.JSON,
  REST.Types,
  Data.DB,
  REST4D.interfaces;

type
  TREST4D = Class(TInterfacedObject, IREST4D)
  private
  class var
    Rest4DAsync: TList<IREST4D>;
    FAsync     : Boolean;

  var
    { Fields }
    FStatusCode: Integer;
    FJSONValue : TJSONValue;
    FJSONString: String;
    FStream    : TMemoryStream;
    FUseOauth2 : Boolean;
    FToken     : String;
    FQuery     : TDictionary<String, String>;

    { Objects }
    FProcsOnStatusCode  : TDictionary<Integer, TProc<Integer, String>>;
    FProcsOnStatusCodeJV: TDictionary<Integer, TProc<Integer, TJSONValue>>;

    { interfaces }
    FREST     : IREST4DObjects;
    FIClient  : IClient<IREST4D>;
    FIResponse: IResponse<IREST4D>;
    FIRequest : IRequest<IREST4D>;
    FOAuth2   : IOAuth2<IREST4D>;

    { Events }
    FOnAuth                 : TProc<String>;
    FOnAuthRaiseException   : TProc<Exception>;
    FOnBeforeRequest        : TProc;
    FOnAfterRequest         : TProc;
    FOnAfterRequestJSON     : TProc<Integer, String>;
    FOnAfterRequestJSONValue: TProc<Integer, TJSONValue>;
    FOnRaisedException      : TProc<Exception>;

    procedure ResetFields;
    procedure SetResult;
    procedure ProcessQuery;
    procedure Execute;
    procedure ResetREST(AValue: Boolean);
    procedure ExecOAuth2;
  public
    function RESTClient: IClient<IREST4D>;
    function RESTResponse: IResponse<IREST4D>;
    function RESTRequest: IRequest<IREST4D>;
    function OAuth2: IOAuth2<IREST4D>;
    function Authenticate: IREST4D;
    function Bearer(const AValue: String): IREST4D;
    function OnAuthenticateRaiseException(AValue: TProc<Exception>): IREST4D;
    function BaseUrl(const AValue: String): IREST4D;
    function Resource(const AValue: String): IREST4D;
    function AddHeader(const AKey, AValue: String): IREST4D;
    function AddQuery(const AKey, AValue: String): IREST4D;
    function AddParam(const AKey, AValue: String): IREST4D;
    function ParamOption(const AParamName: String; AOptions: TRESTRequestParameterOptions): IREST4D;
    function AddBody(const AValue: String; const ContentType: String): IREST4D; overload;
    function AddBody(AValue: TStream; const ContentType: String): IREST4D; overload;
    function AddFile(const AName, AFilePath: String): IREST4D;
    function Get(ResetConfiguration: Boolean = False): IREST4D;
    function Put(ResetConfiguration: Boolean = False): IREST4D;
    function Post(ResetConfiguration: Boolean = False): IREST4D;
    function Delete(ResetConfiguration: Boolean = False): IREST4D;
    function DatasetAdapter(var AValue: TDataSet): IREST4D;
    function OnAuthenticate(AValue: TProc<String>): IREST4D;
    function OnBeforeRequest(AValue: TProc): IREST4D;
    function OnAfterRequest(AValue: TProc): IREST4D; overload;
    function OnAfterRequest(AValue: TProc<Integer, String>): IREST4D; overload;
    function OnAfterRequest(AValue: TProc<Integer, TJSONValue>): IREST4D; overload;
    function OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, String>): IREST4D; overload;
    function OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, TJSONValue>): IREST4D; overload;
    function OnRaisedException(AValue: TProc<Exception>): IREST4D;
    function StatusCode: Integer;
    function JSONValue: TJSONValue;
    function JSONString: String;
    function ResultStream: TMemoryStream;

    /// <summary> Nova instância de TREST4D para requisição na main thread </summary>
    /// <returns> TREST4D: IREST4D </returns>
    class function New: IREST4D;
    /// <summary> Nova instância de TREST4D para requisição em thread paralela </summary>
    /// <returns> TREST4D: IREST4D </returns>
    class function Async: IREST4D;

    constructor Create;
    destructor Destroy; override;
  End;

implementation

uses
  System.Net.HttpClient,
  System.Net.URLClient,
  System.NetConsts,
  System.NetEncoding,
  System.Threading,
  IpPeerClient,
  REST.JSON,
  REST4D.Objects,
  REST4D.Response,
  REST4D.Client,
  REST4D.Request,
  REST4D.OAuth2,
  REST.Utils;

{ TREST4D<T> }

function TREST4D.AddBody(const AValue: String; const ContentType: String): IREST4D;
begin
  Result := Self;

  if AValue.IsEmpty then
    Exit;

  FREST.Request.Body.Add(AValue, ContentTypeFromString(ContentType));
end;

function TREST4D.AddBody(AValue: TStream; const ContentType: String): IREST4D;
begin
  Result := Self;

  if Assigned(AValue) then
    FREST.Request.Body.Add(AValue, ContentTypeFromString(ContentType));
end;

function TREST4D.AddFile(const AName, AFilePath: String): IREST4D;
begin
  Result := Self;
  FREST.Request.AddFile(AName, AFilePath);
end;

function TREST4D.AddHeader(const AKey, AValue: String): IREST4D;
begin
  Result := Self;
  FREST.Request.Params.AddHeader(AKey, AValue);
end;

function TREST4D.AddParam(const AKey, AValue: String): IREST4D;
begin
  Result := Self;
  FREST.Request.Params.AddItem(AKey, AValue);
end;

function TREST4D.AddQuery(const AKey, AValue: String): IREST4D;
begin
  Result := Self;
  FQuery.AddOrSetValue(AKey, AValue);
end;

class function TREST4D.Async: IREST4D;
begin
  Result := TREST4D.Create;
  FAsync := True;

  Rest4DAsync.Add(Result);
end;

function TREST4D.Authenticate: IREST4D;
begin
  Result := Self;

  if FUseOauth2 then
    ExecOAuth2;
end;

function TREST4D.BaseUrl(const AValue: String): IREST4D;
begin
  Result               := Self;
  FREST.Client.BaseUrl := AValue;
end;

function TREST4D.Bearer(const AValue: String): IREST4D;
begin
  Result := Self;

  if AValue <> '' then
  begin
    FToken := AValue;
    FREST.Request.Params.AddHeader('Authorization', 'Bearer ' + AValue);
    FREST.Request.Params.ParameterByName('Authorization').Options := [poDoNotEncode];
  end;
end;

constructor TREST4D.Create();
begin
  { Objects }
  FStream := TMemoryStream.Create;

  FREST                := TREST4DObjects.New;
  FProcsOnStatusCode   := TDictionary < Integer, TProc < Integer, String >>.Create();
  FProcsOnStatusCodeJV := TDictionary < Integer, TProc < Integer, TJSONValue >>.Create();
  FUseOauth2           := False;
  FQuery               := TDictionary<String, String>.Create;

  FIClient   := TClient<IREST4D>.New(Self, FREST.Client);
  FIResponse := TResponse<IREST4D>.New(Self, FREST.Response);
  FIRequest  := TRequest<IREST4D>.New(Self, FREST.Request);
  FOAuth2    := TOAuth2<IREST4D>.New(Self);
end;

function TREST4D.DatasetAdapter(var AValue: TDataSet): IREST4D;
begin
  Result                   := Self;
  FREST.Adapter.Response   := FREST.Response;
  FREST.Adapter.Dataset    := AValue;
  FREST.Adapter.Active     := True;
  FREST.Adapter.AutoUpdate := True;
end;

function TREST4D.Delete(ResetConfiguration: Boolean): IREST4D;
begin
  Result               := Self;
  FREST.Request.Method := rmDELETE;

  Execute;
  ResetREST(ResetConfiguration);
end;

destructor TREST4D.Destroy;
begin
  FQuery.DisposeOf;
  FStream.DisposeOf;
  FProcsOnStatusCode.DisposeOf;

  inherited;
end;

procedure TREST4D.ExecOAuth2;
var
  Response: IHTTPResponse;
  Client  : THTTPClient;
  props   : TOAuth2Params;
  source  : TStringStream;
  jo      : TJSONObject;
  jv      : TJSONValue;
begin
  props := FOAuth2.props;

  jo := TJSONObject.Create;
  try
    jo.AddPair('grant_type', 'client_credentials');

    if props.ClientID <> '' then
      jo.AddPair('client_id', props.ClientID);

    if props.ClientSecret <> '' then
      jo.AddPair('client_secret', props.ClientSecret);

    source := TStringStream.Create(jo.ToJSON);
    Client := THTTPClient.Create;
    try
      Client.ContentType := 'application/json';
      try
        Response := Client.Post(props.AuthorizationEndpoint, source);

        if Response.StatusCode <> 200 then
          raise Exception.Create('Request error(' + Response.StatusCode.ToString + ') ' + Response.ContentAsString());

        jv := jo.ParseJSONValue(Response.ContentAsString());
        try
          jv.TryGetValue<String>('access_token', FToken);

        finally
          jv.DisposeOf;
        end;

        if Assigned(FOnAuth) then
          FOnAuth(Response.ContentAsString());
      except
        on E: Exception do
          if Assigned(FOnAuthRaiseException) then
            FOnAuthRaiseException(E)
          else
            raise Exception.Create(E.Message);
      end;
    finally
      if Assigned(Response) then
        Response._Release;

      source.DisposeOf;
      Client.DisposeOf;
    end;
  finally
    jo.DisposeOf;
  end;
end;

procedure TREST4D.Execute;
var
  LProc: TProc;
begin
  LProc :=
    procedure
    var
      Proc: TProc<Integer, String>;
      ProcJV: TProc<Integer, TJSONValue>;
    begin
      ResetFields;

      if Assigned(FOnBeforeRequest) then
        FOnBeforeRequest();

      try
        ProcessQuery;
        FREST.Request.Execute;
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

      if Assigned(FOnAfterRequest) then
        FOnAfterRequest();

      if Assigned(FOnAfterRequestJSON) then
        FOnAfterRequestJSON(FStatusCode, FJSONString);

      if FProcsOnStatusCode.TryGetValue(FStatusCode, Proc) then
        Proc(FStatusCode, FJSONString);

      if FProcsOnStatusCodeJV.TryGetValue(FStatusCode, ProcJV) then
        ProcJV(FStatusCode, FJSONValue);
    end;

  if FAsync then
    TTask.Run(LProc)
  else
    LProc();
end;

function TREST4D.Get(ResetConfiguration: Boolean): IREST4D;
begin
  Result               := Self;
  FREST.Request.Method := rmGET;

  ProcessQuery;
  Execute;
  ResetREST(ResetConfiguration);
end;

function TREST4D.JSONValue: TJSONValue;
begin
  Result := FJSONValue;
end;

class function TREST4D.New: IREST4D;
begin
  Result := TREST4D.Create;
  FAsync := False;
end;

function TREST4D.OnAfterRequest(AValue: TProc): IREST4D;
begin
  Result          := Self;
  FOnAfterRequest := AValue;
end;

function TREST4D.OAuth2: IOAuth2<IREST4D>;
begin
  Result     := FOAuth2;
  FUseOauth2 := True;
end;

function TREST4D.OnAfterRequest(AValue: TProc<Integer, String>): IREST4D;
begin
  Result              := Self;
  FOnAfterRequestJSON := AValue;
end;

function TREST4D.OnAuthenticate(AValue: TProc<String>): IREST4D;
begin
  Result  := Self;
  FOnAuth := AValue;
end;

function TREST4D.OnAuthenticateRaiseException(AValue: TProc<Exception>): IREST4D;
begin
  Result                := Self;
  FOnAuthRaiseException := AValue;
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

function TREST4D.OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, TJSONValue>): IREST4D;
begin
  Result := Self;
  FProcsOnStatusCodeJV.Add(ACode, AProc);
end;

function TREST4D.OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, String>): IREST4D;
begin
  Result := Self;
  FProcsOnStatusCode.AddOrSetValue(ACode, AProc);
end;

function TREST4D.ParamOption(const AParamName: String; AOptions: TRESTRequestParameterOptions): IREST4D;
begin
  Result                                                   := Self;
  FREST.Request.Params.ParameterByName(AParamName).Options := AOptions;
end;

function TREST4D.Post(ResetConfiguration: Boolean): IREST4D;
begin
  Result               := Self;
  FREST.Request.Method := rmPOST;

  Execute;
  ResetREST(ResetConfiguration);
end;

procedure TREST4D.ProcessQuery;
var
  Item: TPair<String, String>;
  Idx : Integer;
begin
  if FQuery.Count > 0 then
    FREST.Request.Resource := FREST.Request.Resource + '?'
  else
    Exit;

  Idx := 0;
  for Item in FQuery do
  begin
    FREST.Request.Resource := FREST.Request.Resource + Item.Key + '=' + Item.Value;

    if Idx < FQuery.Count then
      FREST.Request.Resource := FREST.Request.Resource + '&';

    Inc(Idx);
  end;
end;

function TREST4D.Put(ResetConfiguration: Boolean): IREST4D;
begin
  Result               := Self;
  FREST.Request.Method := rmPUT;;

  Execute;
  ResetREST(ResetConfiguration);
end;

procedure TREST4D.ResetFields;
begin
  FStatusCode := 0;
  FJSONValue  := nil;
  FJSONString := EmptyStr;
end;

procedure TREST4D.ResetREST(AValue: Boolean);
begin
  if AValue then
  begin
    FREST.Client.ResetToDefaults;
    FREST.Response.ResetToDefaults;
    FREST.Request.ResetToDefaults;
  end;
end;

function TREST4D.Resource(const AValue: String): IREST4D;
begin
  Result                 := Self;
  FREST.Request.Resource := AValue;
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

function TREST4D.ResultStream: TMemoryStream;
begin
  Result := FStream;
end;

procedure TREST4D.SetResult;
begin
  FStatusCode := FREST.Response.StatusCode;

  if Assigned(FREST.Response.JSONValue) then
  begin
    FJSONValue  := FREST.Response.JSONValue;
    FJSONString := TJson.Format(FREST.Response.JSONValue);
  end;

  FStream.Clear;
  FStream.Write(FREST.Response.RawBytes, 0, Length(FREST.Response.RawBytes));
  FStream.Position := 0;
end;

function TREST4D.StatusCode: Integer;
begin
  Result := FStatusCode;
end;

function TREST4D.JSONString: String;
begin
  Result := FJSONString;
end;

function TREST4D.OnAfterRequest(AValue: TProc<Integer, TJSONValue>): IREST4D;
begin
  Result                   := Self;
  FOnAfterRequestJSONValue := AValue;
end;

initialization

TREST4D.Rest4DAsync := TList<IREST4D>.Create;

finalization

TREST4D.Rest4DAsync.DisposeOf;

end.
