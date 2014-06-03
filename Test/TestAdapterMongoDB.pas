unit TestAdapterMongoDB;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Core.Interfaces, bsonDoc, Generics.Collections, mongoWire, Core.Base, SvSerializer,
  SysUtils, Mapping.Attributes, SQL.Params, Adapters.MongoDB, mongoId, Core.Session, SQL.Interfaces;

type

  [Table('MongoTest', 'UnitTests')]
  TMongoAdapter = class
  private
    [Column('_id', [cpNotNull, cpPrimaryKey])]
    FId: Int64;

    FKey: Int64;
  public
    [Column('KEY')]
    [SvSerialize('KEY')]
    property Key: Int64 read FKey write FKey;

    [SvSerialize('_id')]
    property Id: Int64 read FId write FId;
  end;

  // Test methods for class TMongoResultSetAdapter
  TBaseMongoTest = class(TTestCase)
  private
    FConnection: TMongoDBConnection;
    FQuery: TMongoDBQuery;
    function GetKeyValue(const AValue: Variant): Variant;
  public
    procedure SetUp; override;
    procedure TearDown; override;

    property Connection: TMongoDBConnection read FConnection;
    property Query: TMongoDBQuery read FQuery;
  end;


  TestTMongoResultSetAdapter = class(TTestCase)
  private
    FConnection: TMongoDBConnection;
    FQuery: TMongoDBQuery;
    FMongoResultSetAdapter: TMongoResultSetAdapter;
  protected
    procedure FetchValue(const AValue: Variant);
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestIsEmpty;
    procedure TestNext;
    procedure TestGetFieldValue;
    procedure TestGetFieldValue1;
    procedure TestGetFieldCount;
    procedure TestGetFieldName;
  end;
  // Test methods for class TMongoStatementAdapter

  TestTMongoStatementAdapter = class(TBaseMongoTest)
  private
//    FConnection: TMongoDBConnection;
   // FQuery: TMongoDBQuery;
    FMongoStatementAdapter: TMongoStatementAdapter;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSetSQLCommand;
    procedure TestSetParams;
    procedure TestExecute;
    procedure TestExecuteQuery;
  end;
  // Test methods for class TMongoConnectionAdapter

  TestTMongoConnectionAdapter = class(TTestCase)
  private
    FConnection: TMongoDBConnection;
    FMongoConnectionAdapter: TMongoConnectionAdapter;
  protected
    class constructor Create;
  public
    class var
      DirMongoDB: string;

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConnect;
    procedure TestDisconnect;
    procedure TestIsConnected;
    procedure TestCreateStatement;
    procedure TestBeginTransaction;
    procedure TestGetDriverName;
  end;

  TestMongoSession = class(TTestCase)
  private
    FConnection: IDBConnection;
    FMongoConnection: TMongoDBConnection;
    FManager: TSession;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure First();
    procedure FindAll();
    procedure Save_Update_Delete();
    procedure Page();
    procedure Performance();
  end;

implementation

uses
  Windows
  ,ShellAPI
  ,Forms
  ,Messages
  ,Core.ConnectionFactory
  ,SQL.Generator.MongoDB
  ,Variants
  ,Diagnostics
  ,SPring.Collections
  ;

const
  CT_KEY = 'KEY';
  NAME_COLLECTION = 'UnitTests.MongoTest';




procedure InsertObject(AConnection: TMongoDBConnection; const AValue: Variant);
begin
  AConnection.Insert(NAME_COLLECTION, BSON([CT_KEY, AValue, '_id', 1]));
end;

procedure RemoveObject(AConnection: TMongoDBConnection; const AValue: Variant);
begin
  AConnection.Delete(NAME_COLLECTION, BSON(['_id', 1]));
end;

procedure TestTMongoResultSetAdapter.FetchValue(const AValue: Variant);
var
  LDoc: IBSONDocument;
begin
  LDoc := BSON([CT_KEY, AValue]);
  FMongoResultSetAdapter.Document := LDoc;
  FQuery.Query(NAME_COLLECTION, FMongoResultSetAdapter.Document);
  FMongoResultSetAdapter.Next;
end;

procedure TestTMongoResultSetAdapter.SetUp;
begin
  FConnection := TMongoDBConnection.Create;
  FConnection.Open();
  FQuery := TMongoDBQuery.Create(FConnection);
  FMongoResultSetAdapter := TMongoResultSetAdapter.Create(FQuery);
end;

procedure TestTMongoResultSetAdapter.TearDown;
begin
  FMongoResultSetAdapter.Free;
  FMongoResultSetAdapter := nil;
  FConnection.Free;
end;

procedure TestTMongoResultSetAdapter.TestIsEmpty;
begin
  CheckTrue(FMongoResultSetAdapter.IsEmpty);
  InsertObject(FConnection, 10);
  try
    FetchValue(10);
    CheckFalse(FMongoResultSetAdapter.IsEmpty);
  finally
    RemoveObject(FConnection, 10);
  end;
end;

procedure TestTMongoResultSetAdapter.TestNext;
begin
  CheckTrue(FMongoResultSetAdapter.Next);
end;

procedure TestTMongoResultSetAdapter.TestGetFieldValue;
var
  ReturnValue: Variant;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldValue(0);
    CheckEquals(iValue, Integer(ReturnValue));
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TestTMongoResultSetAdapter.TestGetFieldValue1;
var
  ReturnValue: Variant;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldValue(CT_KEY);
    CheckEquals(iValue, Integer(ReturnValue));
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TestTMongoResultSetAdapter.TestGetFieldCount;
var
  ReturnValue: Integer;
  iValue: Integer;
begin
  ReturnValue := FMongoResultSetAdapter.GetFieldCount;
  CheckEquals(0, ReturnValue);
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldCount;
    CheckEquals(1, ReturnValue);
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TestTMongoResultSetAdapter.TestGetFieldName;
var
  ReturnValue: string;
  iValue: Integer;
begin
  iValue := Random(1000000);
  InsertObject(FConnection, iValue);
  try
    FetchValue(iValue);
    ReturnValue := FMongoResultSetAdapter.GetFieldName(0);
    CheckEqualsString(CT_KEY, ReturnValue);
  finally
    RemoveObject(FConnection, iValue);
  end;
end;

procedure TestTMongoStatementAdapter.SetUp;
begin
  inherited;
  FMongoStatementAdapter := TMongoStatementAdapter.Create(Query);
end;

procedure TestTMongoStatementAdapter.TearDown;
begin
  FMongoStatementAdapter.Free;
  FMongoStatementAdapter := nil;
  Connection.Free;
end;

procedure TestTMongoStatementAdapter.TestSetSQLCommand;
var
  LJson: string;
  LResult: Variant;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  FMongoStatementAdapter.Execute;

  LResult := GetKeyValue(1);
  CheckEquals(1, LResult);
end;

procedure TestTMongoStatementAdapter.TestSetParams;
begin
  // TODO: Setup method call parameters
//  FMongoStatementAdapter.SetParams(Params);
  // TODO: Validate method results
end;

procedure TestTMongoStatementAdapter.TestExecute;
var
  LJson: string;
  LResult: Variant;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  FMongoStatementAdapter.Execute;

  LResult := GetKeyValue(1);
  CheckEquals(1, LResult);
end;

procedure TestTMongoStatementAdapter.TestExecuteQuery;
var
  LJson: string;
  LResult: Variant;
  LResultset: IDBResultset;
begin
  LJson := 'I[UnitTests.MongoTest]{"KEY": 1}';
  FMongoStatementAdapter.SetSQLCommand(LJson);
  LResultset := FMongoStatementAdapter.ExecuteQuery;
  LResult := LResultset.GetFieldValue(0);
  CheckEquals(1, LResult);
end;

class constructor TestTMongoConnectionAdapter.Create;
begin
  DirMongoDB := 'D:\Downloads\Programming\General\NoSQL\mongodb-win32-i386-2.2.2\bin\';
end;

procedure TestTMongoConnectionAdapter.SetUp;
begin
  FConnection := TMongoDBConnection.Create();
  FConnection.Open();
  FMongoConnectionAdapter := TMongoConnectionAdapter.Create(FConnection);
end;

procedure TestTMongoConnectionAdapter.TearDown;
begin
  FMongoConnectionAdapter.Free;
  FMongoConnectionAdapter := nil;
  FConnection.Free;
end;

procedure TestTMongoConnectionAdapter.TestConnect;
begin
  CheckFalse(FMongoConnectionAdapter.IsConnected);
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
end;

procedure TestTMongoConnectionAdapter.TestDisconnect;
begin
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
  FMongoConnectionAdapter.Disconnect;
  CheckFalse(FMongoConnectionAdapter.IsConnected);
end;

procedure TestTMongoConnectionAdapter.TestIsConnected;
begin
  CheckFalse(FMongoConnectionAdapter.IsConnected);
  FMongoConnectionAdapter.Connect;
  CheckTrue(FMongoConnectionAdapter.IsConnected);
end;

procedure TestTMongoConnectionAdapter.TestCreateStatement;
var
  LStatement: IDBStatement;
begin
  LStatement := FMongoConnectionAdapter.CreateStatement;
  CheckTrue(Assigned(LStatement));
  LStatement := nil;
end;

procedure TestTMongoConnectionAdapter.TestBeginTransaction;
var
  LTran: IDBTransaction;
begin
  LTran := FMongoConnectionAdapter.BeginTransaction;
  CheckTrue(Assigned(LTran));
end;

procedure TestTMongoConnectionAdapter.TestGetDriverName;
var
  LDriverName: string;
begin
  LDriverName := FMongoConnectionAdapter.GetDriverName;
  CheckEquals('MongoDB', LDriverName);
end;

var
  sExecLine: string;
  StartInfo  : TStartupInfo;
  ProcInfo   : TProcessInformation;
  bCreated: Boolean;



{ TBaseMongoTest }

function TBaseMongoTest.GetKeyValue(const AValue: Variant): Variant;
var
  LDoc: IBSONDocument;
begin
  LDoc := BSON([CT_KEY, AValue]);
  FQuery.Query(NAME_COLLECTION, LDoc);
  Result := LDoc.Item[CT_KEY];
end;

procedure TBaseMongoTest.SetUp;
begin
  inherited;
  FConnection := TMongoDBConnection.Create;
  FConnection.Open();
  FQuery := TMongoDBQuery.Create(FConnection);
end;

procedure TBaseMongoTest.TearDown;
begin
  FQuery.Free;
  FConnection.Free;
  inherited;
end;

{ TestMongoSession }

procedure TestMongoSession.FindAll;
var
  LKey: TMongoAdapter;
  LKeys: IList<TMongoAdapter>;
begin
  LKey := TMongoAdapter.Create;
  try
    LKey.Id := 1;
    LKey.Key := 100;

    FManager.Save(LKey);

    LKey.Id := 2;
    LKey.Key := 900;

    FManager.Save(LKey);

    LKeys := FManager.FindAll<TMongoAdapter>();
    CheckEquals(2, LKeys.Count);

    FManager.Delete(LKey);
    LKey.Id := 1;
    FManager.Delete(LKey);
  finally
    LKey.Free;
  end;
end;

procedure TestMongoSession.First;
var
  LKey: TMongoAdapter;
begin
  InsertObject(FMongoConnection, 100);
  LKey := nil;
  try
    LKey := FManager.FindOne<TMongoAdapter>(1);
    CheckEquals(100, LKey.Key);
  finally
    RemoveObject(FMongoConnection, 100);
    LKey.Free;
  end;
end;

procedure TestMongoSession.Page;
var
  LPage: IDBPage<TMongoAdapter>;
  LKey: TMongoAdapter;
begin
  // TODO: implement paging
  LKey := TMongoAdapter.Create;
  try
    LKey.Id := 1;
    LKey.Key := 100;

    FManager.Save(LKey);

    LKey.Id := 2;
    LKey.Key := 900;

    FManager.Save(LKey);

    LPage := FManager.Page<TMongoAdapter>(1, 10);
    CheckEquals(2, LPage.Items.Count);
  finally
    FManager.Delete(LKey);
    LKey.Id := 1;
    FManager.Delete(LKey);
    LKey.Free;
  end;
end;

procedure TestMongoSession.Performance;
var
  LKey: TMongoAdapter;
  i, iCount: Integer;
  sw : TStopwatch;
begin
  iCount := 10000;
  sw := TStopwatch.StartNew;
  for i := 1 to iCount do
  begin
    LKey := TMongoAdapter.Create;
    try
      LKey.FId := i;
      LKey.Key := i + 1;
      FManager.Save(LKey);
    finally
      LKey.Free;
    end;
  end;
  sw.Stop;
  Status(Format('Saved %D simple entities in %D ms', [iCount, sw.ElapsedMilliseconds]));
  FManager.Execute('D[UnitTests.MongoTest]{}', []); //delete all
end;

procedure TestMongoSession.Save_Update_Delete;
var
  LKey: TMongoAdapter;
begin
  LKey := TMongoAdapter.Create();
  try
    LKey.FId := 2;
    LKey.Key := 100;

    FManager.Save(LKey);
    LKey.Free;

    LKey := FManager.FindOne<TMongoAdapter>(2);
    CheckEquals(100, LKey.Key);

    LKey.Key := 999;
    FManager.Save(LKey);
    LKey.Free;

    LKey := FManager.FindOne<TMongoAdapter>(2);
    CheckEquals(999, LKey.Key);


    FManager.Delete(LKey);
  finally
    LKey.Free;
  end;
  LKey := FManager.FindOne<TMongoAdapter>(2);
  CheckNull(LKey);
end;

procedure TestMongoSession.SetUp;
begin
  inherited;
  FMongoConnection := TMongoDBConnection.Create;
  FMongoConnection.Open();
  FConnection := TConnectionFactory.GetInstance(dtMongo, FMongoConnection);
  FConnection.AutoFreeConnection := True;
  FConnection.SetQueryLanguage(qlMongoDB);
  FManager := TSession.Create(FConnection);
  FManager.Execute('D[UnitTests.MongoTest]{}', []); //delete all
  if DebugHook <> 0 then
  begin
    FConnection.AddExecutionListener(
    procedure(const ACommand: string; const AParams: TObjectList<TDBParam>)
    var
      i: Integer;
    begin
      Status(ACommand);
      for i := 0 to AParams.Count - 1 do
      begin
        Status(Format('%2:D Param %0:S = %1:S', [AParams[i].Name, VarToStrDef(AParams[i].Value, 'NULL'), i]));
      end;
      Status('-----');
    end);
  end;
end;

procedure TestMongoSession.TearDown;
begin
  inherited;
  FManager.Free;
  FConnection := nil;
end;

initialization
  if DirectoryExists(TestTMongoConnectionAdapter.DirMongoDB) then
  begin
    sExecLine := TestTMongoConnectionAdapter.DirMongoDB + 'mongod.exe' +
      Format(' --dbpath "%S" --journal', [TestTMongoConnectionAdapter.DirMongoDB + 'data\db']);

    FillChar(StartInfo,SizeOf(TStartupInfo),#0);
    FillChar(ProcInfo,SizeOf(TProcessInformation),#0);
    StartInfo.cb := SizeOf(TStartupInfo);
    StartInfo.wShowWindow := SW_HIDE;
    bCreated := CreateProcess(nil, PChar(sExecLine), nil, nil, True, 0, nil, nil, StartInfo, ProcInfo);
    if bCreated then
    begin
      RegisterTest(TestTMongoResultSetAdapter.Suite);
      RegisterTest(TestTMongoStatementAdapter.Suite);
      RegisterTest(TestTMongoConnectionAdapter.Suite);
      RegisterTest(TestMongoSession.Suite);
    end;
  end;

finalization
  if bCreated then
  begin
    TerminateProcess(ProcInfo.hProcess, 0);
  end;


end.

