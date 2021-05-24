unit REST4D.interfaces;

interface

uses
  System.SysUtils,
  System.JSON,
  Data.DB,
  REST.Types;

type
  IClient<T: IInterface> = Interface
    ['{1E793D7C-7078-41B2-B388-B8375B8CC2CD}']
    function UserAgent(const AValue: String): IClient<T>; overload;
    function UserAgent: String; overload;
    function Accept(const AValue: String): IClient<T>; overload;
    function Accept: String; overload;
    function AcceptCharset(const AValue: String): IClient<T>; overload;
    function AcceptCharset: String; overload;
    function HandleRedirects(const AValue: Boolean): IClient<T>; overload;
    function HandleRedirects: Boolean; overload;
    function RaiseExceptionOn500(AValue: Boolean): IClient<T>; overload;
    function RaiseExceptionOn500: Boolean; overload;
    function ContentType(const AValue: String): IClient<T>; overload;
    function ContentType: String; overload;
    function &End: T;
  End;

  IResponse<T: IInterface> = Interface
    ['{CC368209-88F1-41BB-9E97-18735A94F64E}']
    function ContentType(const AValue: String): IResponse<T>; overload;
    function ContentType: String; overload;
    function &End: T;
  End;

  IRequest<T: IInterface> = Interface
    ['{A5064091-E622-4D5F-8B32-FAC581911EE7}']
    function SynchronizedEvents(const AValue: Boolean): IRequest<T>; overload;
    function SynchronizedEvents: Boolean; overload;
    function AcceptEncoding(const AValue: String): IRequest<T>; overload;
    function AcceptEncoding: String; overload;
    function &end: T;
  End;

  IREST4D = Interface
    ['{01100448-9189-47BB-89BE-DAA32905ACFA}']

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
  End;

implementation

end.
