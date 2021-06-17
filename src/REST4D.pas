unit REST4D;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.JSON,
  REST.Types,
  Data.DB,
  REST4D.interfaces;

type
  TREST4D = Class(TInterfacedObject, IREST4D)
  strict private
    class var
      Rest4DAsync: IREST4D;
      FAsync     : Boolean;
  private
    { Fields }
    FStatusCode: Integer;
    FJSONValue : TJSONValue;
    FJSONString: String;

    { Objects }
    FProcsOnStatusCode: TDictionary<Integer, TProc<Integer, String>>;

    { interfaces }
    FREST     : IREST4DObjects;
    FIClient  : IClient<IREST4D>;
    FIResponse: IResponse<IREST4D>;
    FIRequest : IRequest<IREST4D>;

    { Events }
    FOnBeforeRequest  : TProc;
    FOnAfterRequest   : TProc;
    FOnAfterRequestJSON : TProc<Integer, String>;
    FOnRaisedException: TProc<Exception>;

    procedure ResetFields;
    procedure SetResult;
    procedure Execute;
    procedure ResetREST(AValue: Boolean);
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
    function OnBeforeRequest(AValue: TProc): IREST4D;
    function OnAfterRequest(AValue: TProc): IREST4D; overload;
    function OnAfterRequest(AValue: TProc<Integer, String>): IREST4D; overload;
    function OnSpecificStatusCode(ACode: Integer; AProc: TProc<Integer, String>): IREST4D;
    function OnRaisedException(AValue: TProc<Exception>): IREST4D;
    function StatusCode: Integer;
    function JSONValue: TJSONValue;
    function JSONString: String;

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
  System.Threading,
  IpPeerClient,
  REST4D.Objects,
  REST4D.Response,
  REST4D.Client,
  REST4D.Request;

{ TREST4D<T> }

function TREST4D.AddBody(const AValue: String; const ContentType: String): IREST4D;
begin
  Result := Self;

  if AValue.IsEmpty then
    Exit;

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

class function TREST4D.Async: IREST4D;
begin
  Rest4DAsync := TREST4D.Create;
  Result      := Rest4DAsync;
  FAsync      := True;
end;

function TREST4D.BaseUrl(const AValue: String): IREST4D;
begin
  Result               := Self;
  FREST.Client.BaseUrl := AValue;
end;

constructor TREST4D.Create();
begin
  { Objects }
  FREST              := TREST4DObjects.New;
  FProcsOnStatusCode := TDictionary <Integer, TProc<Integer, String>>.Create();

  FIClient   := TClient<IREST4D>.New(Self, FREST.Client);
  FIResponse := TResponse<IREST4D>.New(Self, FREST.Response);
  FIRequest  := TRequest<IREST4D>.New(Self, FREST.Request);
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
  FProcsOnStatusCode.DisposeOf;

  inherited;
end;

procedure TREST4D.Execute;
var
  LProc: TProc;
begin
  LProc :=  procedure
            var
              Proc: TProc<Integer, String>;
            begin
              ResetFields;

              if Assigned(FOnBeforeRequest) then
                FOnBeforeRequest();

              try
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

function TREST4D.OnAfterRequest(AValue: TProc<Integer, String>): IREST4D;
begin
  Result              := Self;
  FOnAfterRequestJSON := AValue;
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

procedure TREST4D.SetResult;
begin
  FStatusCode := FREST.Response.StatusCode;
  FJSONValue  := FREST.Response.JSONValue;
  FJSONString := FREST.Response.JSONText;
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
