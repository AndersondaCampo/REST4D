unit REST4D.interfaces;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  Data.DB,
  REST.Client,
  REST.Response.Adapter,
  REST.Types;

type
  IClient<T: IInterface> = Interface
    ['{1E793D7C-7078-41B2-B388-B8375B8CC2CD}']
    function UserAgent(const AValue: String): IClient<T>;
    function Accept(const AValue: String): IClient<T>;
    function AcceptCharset(const AValue: String): IClient<T>;
    function HandleRedirects(const AValue: Boolean): IClient<T>;
    function RaiseExceptionOn500(AValue: Boolean): IClient<T>;
    function ContentType(const AValue: String): IClient<T>;
    function &End: T;
  End;

  IResponse<T: IInterface> = Interface
    ['{CC368209-88F1-41BB-9E97-18735A94F64E}']
    function ContentType(const AValue: String): IResponse<T>;
    function &End: T;
  End;

  IRequest<T: IInterface> = Interface
    ['{A5064091-E622-4D5F-8B32-FAC581911EE7}']
    function SynchronizedEvents(const AValue: Boolean): IRequest<T>;
    function AcceptEncoding(const AValue: String): IRequest<T>;
    function TimeOut(const AValue: Integer): IRequest<T>;
    function &end: T;
  End;

  TOAuth2Params = Record
    AuthorizationEndpoint: String;
    AccessTokenEndpoint  : String;
    RedirectionEndpoint  : String;
    ClientID             : String;
    ClientSecret         : String;
    Scope                : String;
    ResponseType         : String;
    Token                : String;
  End;

  IOAuth2<T: IInterface> = Interface
    ['{D272DFD1-3701-4DA9-BADE-5F008940C325}']
    function AuthorizationEndpoint(const AValue: String): IOAuth2<T>;
    function AccessTokenEndpoint(const AValue: String): IOAuth2<T>;
    function ClientID(const AValue: String): IOAuth2<T>;
    function ClientSecret(const AValue: String): IOAuth2<T>;
    function ResponseType(const AValue: String): IOAuth2<T>;
    function Props: TOAuth2Params;
    function &End: T;
  End;

  IREST4DObjects = Interface
    ['{C037042D-73C4-48D1-A988-D462BF389D3E}']
    function Client: TRESTClient;
    function Request: TRESTRequest;
    function Response: TRESTResponse;
    function Adapter: TRESTResponseDataSetAdapter;
  End;

  IREST4D = Interface
    ['{01100448-9189-47BB-89BE-DAA32905ACFA}']
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
  End;

implementation

end.
