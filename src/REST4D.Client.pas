unit REST4D.Client;

interface

uses
  REST4D.interfaces;

type
  TClient<T: IInterface> = Class(TInterfacedObject, IClient<T>)
  private
    [weak]
    FParent             : T;
    FUserAgent          : String;
    FAccept             : String;
    FAcceptCharset      : String;
    FHandleRedirects    : Boolean;
    FRaiseExceptionOn500: Boolean;
    FContentType        : String;

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

    class function New(AParent: T): IClient<T>;
    constructor Create(AParent: T);
    destructor Destroy; override;
  End;

implementation

{ TClient<T> }

function TClient<T>.Accept: String;
begin
  Result := FAccept;
end;

function TClient<T>.Accept(const AValue: String): IClient<T>;
begin
  Result  := Self;
  FAccept := AValue;
end;

function TClient<T>.AcceptCharset: String;
begin
  Result := FAcceptCharset;
end;

function TClient<T>.AcceptCharset(const AValue: String): IClient<T>;
begin
  Result         := Self;
  FAcceptCharset := AValue;
end;

function TClient<T>.ContentType: String;
begin
  Result := FContentType;
end;

function TClient<T>.ContentType(const AValue: String): IClient<T>;
begin
  Result       := Self;
  FContentType := AValue;
end;

constructor TClient<T>.Create(AParent: T);
begin
  FParent := AParent;
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
  Result := FHandleRedirects;
end;

function TClient<T>.HandleRedirects(const AValue: Boolean): IClient<T>;
begin
  Result           := Self;
  FHandleRedirects := AValue;
end;

class function TClient<T>.New(AParent: T): IClient<T>;
begin
  Result := TClient<T>.Create(AParent);
end;

function TClient<T>.RaiseExceptionOn500: Boolean;
begin
  Result := FRaiseExceptionOn500;
end;

function TClient<T>.RaiseExceptionOn500(AValue: Boolean): IClient<T>;
begin
  Result               := Self;
  FRaiseExceptionOn500 := AValue
end;

function TClient<T>.UserAgent(const AValue: String): IClient<T>;
begin
  Result     := Self;
  FUserAgent := AValue;
end;

function TClient<T>.UserAgent: String;
begin
  Result := FUserAgent;
end;

end.
