unit TestMapping.RttiExplorer;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, Mapping.Attributes, Generics.Collections, Mapping.RttiExplorer,
  Rtti, uModels;

type
  // Test methods for class TRttiExplorer

  TestTRttiExplorer = class(TTestCase)
  private
    FCustomer: TCustomer;
    FProduct: TProduct;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGetClassMembers;
    procedure TestGetTable;
    procedure TestGetUniqueConstraints;
    procedure TestGetAssociations;
    procedure TestGetColumns;
    procedure TestGetSequence;
    procedure TestHasSequence;
    procedure TestGetAutoGeneratedColumnMemberName;
    procedure TestGetMemberValue;
    procedure TestSetMemberValue;
    procedure TestEntityChanged;
    procedure TestGetChangedMembers;
    procedure TestCopyFieldValues;
    procedure TestClone;
    procedure TestCloneSpeed;
    procedure GetPrimaryKey();
  end;

implementation

uses
  DateUtils,
  SysUtils,
  Math
  ,Diagnostics
  ;

procedure TestTRttiExplorer.GetPrimaryKey;
var
  LColumn: ColumnAttribute;
begin
  LColumn := TRttiExplorer.GetPrimaryKeyColumn(FCustomer.ClassType);
  CheckTrue(Assigned(LColumn));

  CheckEqualsString('CUSTID', LColumn.Name);
  CheckEqualsString('CUSTID',TRttiExplorer.GetPrimaryKeyColumnName(FCustomer.ClassType));
  CheckEqualsString('FId',TRttiExplorer.GetPrimaryKeyColumnMemberName(FCustomer.ClassType));
end;

procedure TestTRttiExplorer.SetUp;
begin
  FCustomer := TCustomer.Create;
  FProduct := TProduct.Create;
end;

procedure TestTRttiExplorer.TearDown;
begin
  FCustomer.Free;
  FProduct.Free;
end;

procedure TestTRttiExplorer.TestGetClassMembers;
var
  ReturnValue: TList<EntityAttribute>;
  LColumns: TList<ColumnAttribute>;
  AClassInfo: Pointer;
begin
  AClassInfo := FProduct.ClassType;
  ReturnValue := TRttiExplorer.GetClassMembers<EntityAttribute>(AClassInfo);
  try
    CheckEquals(0, ReturnValue.Count);

  finally
    ReturnValue.Free;
  end;

  LColumns := TRttiExplorer.GetClassMembers<ColumnAttribute>(AClassInfo);
  try
    CheckEquals(3, LColumns.Count);

  finally
    LColumns.Free;
  end;
end;

procedure TestTRttiExplorer.TestGetTable;
var
  ReturnValue: TableAttribute;
  AClass: TClass;
begin
  AClass := FProduct.ClassType;
  ReturnValue := TRttiExplorer.GetTable(AClass);
  CheckEqualsString('Products', ReturnValue.TableName);

  AClass := FCustomer.ClassType;
  ReturnValue := TRttiExplorer.GetTable(AClass);
  CheckEqualsString('Customers', ReturnValue.TableName);
end;

procedure TestTRttiExplorer.TestGetUniqueConstraints;
var
  ReturnValue: TList<UniqueConstraint>;
  AClass: TClass;
begin
  AClass := FCustomer.ClassType;

  ReturnValue := TRttiExplorer.GetUniqueConstraints(AClass);
  try
    CheckEquals(1, ReturnValue.Count);
    CheckEqualsString('FId', ReturnValue.First.ClassMemberName);
  finally
    ReturnValue.Free;
  end;
end;

procedure TestTRttiExplorer.TestGetAssociations;
var
  ReturnValue: TList<Association>;
  AClass: TClass;
begin
  AClass := FCustomer.ClassType;
  ReturnValue := TRttiExplorer.GetAssociations(AClass);
  try
    CheckEquals(0, ReturnValue.Count);
  finally
    ReturnValue.Free;
  end;
end;

procedure TestTRttiExplorer.TestGetColumns;
var
  ReturnValue: TList<ColumnAttribute>;
  AClass: TClass;
begin
  AClass := FCustomer.ClassType;

  ReturnValue := TRttiExplorer.GetColumns(AClass);
  try
    CheckEquals(CustomerColumnCount, ReturnValue.Count);
  finally
    ReturnValue.Free;
  end;
end;

procedure TestTRttiExplorer.TestGetSequence;
var
  ReturnValue: SequenceAttribute;
  AClass: TClass;
begin
  AClass := FCustomer.ClassType;

  ReturnValue := TRttiExplorer.GetSequence(AClass);

  CheckTrue(Assigned(ReturnValue));
  CheckEquals(1, ReturnValue.Increment);
end;

procedure TestTRttiExplorer.TestHasSequence;
var
  ReturnValue: Boolean;
  AClass: TClass;
  AClas2: TClass;
begin
  AClass := FCustomer.ClassType;
  AClas2 := FProduct.ClassType;

  ReturnValue := TRttiExplorer.HasSequence(AClass);
  CheckTrue(ReturnValue);

  ReturnValue := TRttiExplorer.HasSequence(AClas2);
  CheckFalse(ReturnValue);
end;

procedure TestTRttiExplorer.TestGetAutoGeneratedColumnMemberName;
var
  ReturnValue: string;
  AClass: TClass;
begin
  AClass := FCustomer.ClassType;

  ReturnValue := TRttiExplorer.GetAutoGeneratedColumnMemberName(AClass);

  CheckEqualsString('FId', ReturnValue);
end;

procedure TestTRttiExplorer.TestGetMemberValue;
var
  ReturnValue: TValue;
  AMemberName: string;
begin
  AMemberName := 'Name';
  FCustomer.Name := 'Test';
  ReturnValue := TRttiExplorer.GetMemberValue(FCustomer, AMemberName);
  CheckEqualsString('Test', ReturnValue.AsString);

  AMemberName := 'LastEdited';
  FCustomer.LastEdited := EncodeDate(2009, 11, 15);
  ReturnValue := TRttiExplorer.GetMemberValue(FCustomer, AMemberName);
  CheckTrue(SameDate(EncodeDate(2009, 11, 15), ReturnValue.AsExtended));
end;

procedure TestTRttiExplorer.TestSetMemberValue;
var
  AValue: TValue;
  AMemberName: string;
  AEntity: TObject;
begin
  AEntity := FCustomer;
  //string
  AValue := 'John White';
  AMemberName := 'Name';
  TRttiExplorer.SetMemberValue(nil, AEntity, AMemberName, AValue);
  CheckEqualsString('John White', FCustomer.Name);
  //integer
  AValue := 25;
  AMemberName := 'Age';
  TRttiExplorer.SetMemberValue(nil, AEntity, AMemberName, AValue);
  CheckEquals(25, FCustomer.Age);
  //tdatetime
  AValue := Today;
  AMemberName := 'LastEdited';
  TRttiExplorer.SetMemberValue(nil, AEntity, AMemberName, AValue);
  CheckTrue(SameDate(Today, FCustomer.LastEdited));
  //double
  AValue := 1.89;
  AMemberName := 'Height';
  TRttiExplorer.SetMemberValue(nil, AEntity, AMemberName, AValue);
  CheckTrue(SameValue(1.89, FCustomer.Height));
end;

procedure TestTRttiExplorer.TestEntityChanged;
var
  ReturnValue: Boolean;
  AEntity2: TCustomer;
  AEntity1: TCustomer;
begin
  AEntity1 := TCustomer.Create;
  AEntity2 := TCustomer.Create;
  try
    ReturnValue := TRttiExplorer.EntityChanged(AEntity1, AEntity2);
    CheckFalse(ReturnValue);

    //change something
    AEntity1.Name := 'Entity Changed';
    ReturnValue := TRttiExplorer.EntityChanged(AEntity1, AEntity2);
    CheckTrue(ReturnValue);
    //rollback changes
    AEntity1.Name := AEntity2.Name;
    ReturnValue := TRttiExplorer.EntityChanged(AEntity1, AEntity2);
    CheckFalse(ReturnValue);

  finally
    AEntity1.Free;
    AEntity2.Free;
  end;
end;

procedure TestTRttiExplorer.TestGetChangedMembers;
var
  ReturnValue: TList<ColumnAttribute>;
  ADirtyObj: TCustomer;
  AOriginalObj: TCustomer;
begin
  ADirtyObj := TCustomer.Create;
  AOriginalObj := TCustomer.Create;
  try
    ReturnValue := TRttiExplorer.GetChangedMembers(AOriginalObj, ADirtyObj);
    try
      CheckTrue(ReturnValue.Count = 0);
    finally
      ReturnValue.Free;
    end;

    ADirtyObj.Name := 'Changed';
    ADirtyObj.Age := 1111;
    ADirtyObj.Height := 15.56;
    ReturnValue := TRttiExplorer.GetChangedMembers(AOriginalObj, ADirtyObj);
    try
      CheckTrue(ReturnValue.Count = 3);
    finally
      ReturnValue.Free;
    end;

  finally
    ADirtyObj.Free;
    AOriginalObj.Free;
  end;
end;

procedure TestTRttiExplorer.TestCopyFieldValues;
var
  AEntityTo: TCustomer;
  AEntityFrom: TCustomer;
begin
  AEntityTo := TCustomer.Create;
  AEntityFrom := TCustomer.Create;
  try
    AEntityFrom.Name := 'From';
    AEntityFrom.Age := 15;
    AEntityFrom.Height := 1.111;
    AEntityFrom.EMail := 'test@gmail.com';
    AEntityFrom.LastEdited := Tomorrow;

    TRttiExplorer.CopyFieldValues(AEntityFrom, AEntityTo);

    CheckEqualsString('From', AEntityTo.Name);
    CheckEquals(15, AEntityTo.Age);
    CheckTrue(SameValue(1.111, AEntityTo.Height));
    CheckEqualsString('test@gmail.com', AEntityTo.EMail);
    CheckTrue(SameDate(Tomorrow, AEntityTo.LastEdited));
  finally
    AEntityTo.Free;
    AEntityFrom.Free;
  end;
end;

procedure TestTRttiExplorer.TestClone;
var
  ReturnValue: TCustomer;
  AEntity: TCustomer;
begin
  AEntity := TCustomer.Create;
  try
    AEntity.Name := 'Clone';

    ReturnValue := TRttiExplorer.Clone(AEntity) as TCustomer;
    try
      CheckFalse(TRttiExplorer.EntityChanged(AEntity, ReturnValue));
      CheckEqualsString('Clone', ReturnValue.Name);
    finally
      ReturnValue.Free;
    end;
  finally
    AEntity.Free;
  end;
end;

procedure TestTRttiExplorer.TestCloneSpeed;
var
  LCustomer, LCloned: TCustomer;
  i, iMax: Integer;
  sw: TStopwatch;
  LCustomers: TObjectList<TCustomer>;
  LClonedCustomers: TObjectList<TCustomer>;
begin
  iMax := 10000;
  LCustomers := TObjectList<TCustomer>.Create(True);
  LClonedCustomers := TObjectList<TCustomer>.Create(True);
  try
    for i := 1 to iMax do
    begin
      LCustomer := TCustomer.Create;
      LCustomer.Age := i;

      LCustomers.Add(LCustomer);
    end;


    sw := TStopwatch.StartNew;

    for i := 0 to LCustomers.Count - 1 do
    begin
      LCustomer := LCustomers[i];

      LCloned := TRttiExplorer.Clone(LCustomer) as TCustomer;
      LClonedCustomers.Add(LCloned);
    end;

    sw.Stop;
  finally
    LCustomers.Free;
    LClonedCustomers.Free;
  end;

  Status(Format('Cloned %D objects in %D ms.',
    [iMax, sw.ElapsedMilliseconds]));
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTRttiExplorer.Suite);
end.

