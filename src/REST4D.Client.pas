unit REST4D.Client;

interface

uses
  REST4D.interfaces,
  REST.Client;

type
  TClient<T: IInterface> = Class(TInterfacedObject, IClient<T>)
  private
    [weak]
    FParent: T;
    FClient: TRESTClient;
  public
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

    class function New(AParent: T; Client: TRESTClient): IClient<T>;
    constructor Create(AParent: T; Client: TRESTClient);
    destructor Destroy; override;
  End;

implementation

{ TClient<T> }

function TClient<T>.Accept: String;
begin
  Result := FClient.Accept;
end;

function TClient<T>.Accept(const AValue: String): IClient<T>;
begin
  Result         := Self;
  FClient.Accept := AValue;
end;

function TClient<T>.AcceptCharset: String;
begin
  Result := FClient.AcceptCharset;
end;

function TClient<T>.AcceptCharset(const AValue: String): IClient<T>;
begin
  Result                := Self;
  FClient.AcceptCharset := AValue;
end;

function TClient<T>.ContentType: String;
begin
  Result := FClient.ContentType;
end;

function TClient<T>.ContentType(const AValue: String): IClient<T>;
begin
  Result              := Self;
  FClient.ContentType := AValue;
end;

constructor TClient<T>.Create(AParent: T; Client: TRESTClient);
begin
  FParent := AParent;
  FClient := Client;
end;

destructor TClient<T>.Destroy;
begin

  inherited;
end;

function TClient<T>.&End: T;
begin
  Result := FParent;
end;

function TClient<T>.HandleRedirects: Boolean;
begin
  Result := FClient.HandleRedirects;
end;

function TClient<T>.HandleRedirects(const AValue: Boolean): IClient<T>;
begin
  Result                  := Self;
  FClient.HandleRedirects := AValue;
end;

class function TClient<T>.New(AParent: T; Client: TRESTClient): IClient<T>;
begin
  Result := TClient<T>.Create(AParent, Client);
end;

function TClient<T>.RaiseExceptionOn500: Boolean;
begin
  Result := FClient.RaiseExceptionOn500;
end;

function TClient<T>.RaiseExceptionOn500(AValue: Boolean): IClient<T>;
begin
  Result                      := Self;
  FClient.RaiseExceptionOn500 := AValue
end;

function TClient<T>.UserAgent(const AValue: String): IClient<T>;
begin
  Result            := Self;
  FClient.UserAgent := AValue;
end;

function TClient<T>.UserAgent: String;
begin
  Result := FClient.UserAgent;
end;

end.
