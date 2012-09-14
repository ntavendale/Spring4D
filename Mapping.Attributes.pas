(*
* Copyright (c) 2012, Linas Naginionis
* Contacts: lnaginionis@gmail.com or support@soundvibe.net
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of the <organization> nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ''AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*)
unit Mapping.Attributes;

interface

uses
  Generics.Collections, Rtti, TypInfo;

type
  TFetchType = (ftEager, ftLazy);

  TCascadeType = (ctCascadeAll, ctCascadeMerge, ctCascadeRefresh, ctCascadeRemove);

  TForeignStrategy = (fsOnDeleteSetNull, fsOnDeleteSetDefault, fsOnDeleteCascade, fsOnDeleteNoAction
                      ,fsOnUpdateSetNull, fsOnUpdateSetDefault, fsOnUpdateCascade, fsOnUpdateNoAction);

  TForeignStrategies = set of TForeignStrategy;

  TCascadeTypes = set of TCascadeType;

  TColumnProperty = (cpRequired, cpUnique, cpDontInsert, cpDontUpdate, cpPrimaryKey, cpNotNull);

  TColumnProperties = set of TColumnProperty;

  TDiscriminatorType = (dtString, dtInteger);
  {TODO -oLinas -cGeneral : finish defining enums}
  TInheritenceStrategy = (isJoined, isSingleTable, isTablePerClass);

  TMemberType = (mtField, mtProperty);

  TORMAttribute = class(TCustomAttribute)
  private
    FMemberType: TMemberType;
    FClassMemberName: string;
    FTypeInfo: PTypeInfo;
    function GetBaseEntityClass: TClass;
  public
    function AsRttiObject(ATypeInfo: PTypeInfo): TRttiNamedObject; overload;
    function AsRttiObject(): TRttiNamedObject; overload;
    function GetTypeInfo(AEntityTypeInfo: PTypeInfo): PTypeInfo;
    function GetColumnTypeInfo(): PTypeInfo;

    property BaseEntityClass: TClass read GetBaseEntityClass;
    property EntityTypeInfo: PTypeInfo read FTypeInfo write FTypeInfo;
    property ClassMemberName: string read FClassMemberName write FClassMemberName;
    property MemberType: TMemberType read FMemberType write FMemberType;
  end;

  EntityAttribute = class(TORMAttribute);

  Id = class(TORMAttribute);

  TableAttribute = class(TORMAttribute)
  private
    FTable: string;
    FSchema: string;
  public
    constructor Create(const ATablename: string; const ASchema: string = '');

    property TableName: string read FTable;
    property Schema: string read FSchema;
  end;

  AutoGenerated = class(TORMAttribute);

  UniqueConstraint = class(TORMAttribute)
  public
    constructor Create(); virtual;
  end;

  SequenceAttribute = class(TORMAttribute)
  private
    FSeqName: string;
    FInitValue: NativeInt;
    FIncrement: Integer;
  public
    constructor Create(const ASeqName: string; AInitValue: NativeInt; AIncrement: Integer);

    property SequenceName: string read FSeqName;
    property InitialValue: NativeInt read FInitValue;
    property Increment: Integer read FIncrement;
  end;

  Association = class(TORMAttribute)
  private
    FFetchType: TFetchType;
    FRequired: Boolean;
    FCascade: TCascadeTypes;
  public
    constructor Create(AFetchType: TFetchType; ARequired: Boolean; ACascade: TCascadeTypes);

    property FetchType: TFetchType read FFetchType;
    property Required: Boolean read FRequired;
    property Cascade: TCascadeTypes read FCascade;
  end;

  ManyValuedAssociation = class(Association)
  private
    FMappedBy: string;
  public
    constructor Create(AFetchType: TFetchType; ARequired: Boolean; ACascade: TCascadeTypes; const AMappedBy: string); overload;

    property MappedBy: string read FMappedBy;
  end;

  ManyToOneAttribute = class(ManyValuedAssociation)

  end;

  JoinColumn = class(TORMAttribute)
  private
    FName: string;
   // FProperties: TColumnProperties;
    FReferencedColName: string;
    FReferencedTableName: string;
  public
    constructor Create(const AName: string; const AReferencedTableName, AReferencedColumnName: string);

    property Name: string read FName;
   // property Properties: TColumnProperties read FProperties;
    property ReferencedColumnName: string read FReferencedColName;
    property ReferencedTableName: string read FReferencedTableName;
  end;

  ForeignJoinColumnAttribute = class(JoinColumn)
  private
    FForeignStrategies: TForeignStrategies;
  public
    constructor Create(const AName: string; const AReferencedTableName, AReferencedColumnName: string;
      AForeignStrategies: TForeignStrategies); overload;

    property ForeignStrategies: TForeignStrategies read FForeignStrategies write FForeignStrategies;
  end;

  ColumnAttribute = class(TORMAttribute)
  private
    FName: string;
    FProperties: TColumnProperties;
    FLength: Integer;
    FPrecision: Integer;
    FScale: Integer;
    FDescription: string;
    FIsIdentity: Boolean;
  public
    constructor Create(const AName: string; AProperties: TColumnProperties = []); overload;
    constructor Create(const AName: string; AProperties: TColumnProperties; ALength: Integer; APrecision: Integer;
      AScale: Integer; const ADescription: string); overload;

    function IsDiscriminator(): Boolean; virtual;

    property IsIdentity: Boolean read FIsIdentity write FIsIdentity;
    property Name: string read FName;
    property Properties: TColumnProperties read FProperties;
    property Length: Integer read FLength;
    property Precision: Integer read FPrecision;
    property Scale: Integer read FScale;
    property Description: string read FDescription;
  end;

  TColumnData = record
  public
    Properties: TColumnProperties;
    Name: string;
    ColTypeInfo: PTypeInfo;
    ClassMemberName: string;
  end;

  DiscriminatorValue = class(TORMAttribute)
  private
    FValue: TValue;
  public
    constructor Create(const AValue: TValue);

    property Value: TValue read FValue;
  end;

  DiscriminatorColumn = class(ColumnAttribute)
  private
    FName: string;
    FDiscrType: TDiscriminatorType;
    FLength: Integer;
  public
    constructor Create(const AName: string; ADiscrType: TDiscriminatorType; ALength: Integer);

    function IsDiscriminator(): Boolean; override;

    property Name: string read FName;
    property DiscrType: TDiscriminatorType read FDiscrType;
    property Length: Integer read FLength;
  end;

  Inheritence = class(TORMAttribute)
  private
    FStrategy: TInheritenceStrategy;
  public
    constructor Create(AStrategy: TInheritenceStrategy);

    property Strategy: TInheritenceStrategy read FStrategy;
  end;

  {TODO -oLinas -cGeneral : OrderBy attribute. see: http://docs.oracle.com/javaee/5/api/javax/persistence/OrderBy.html}
  {TODO -oLinas -cGeneral : ManyToMany attribute. see: http://docs.oracle.com/javaee/5/api/javax/persistence/ManyToMany.html}


implementation


{ Table }

constructor TableAttribute.Create(const ATablename: string; const ASchema: string);
begin
  inherited Create;
  FTable := ATablename;
  FSchema := ASchema;
end;

{ UniqueConstraint }

constructor UniqueConstraint.Create();
begin
  inherited Create;
end;

{ Sequence }

constructor SequenceAttribute.Create(const ASeqName: string; AInitValue: NativeInt; AIncrement: Integer);
begin
  inherited Create;
  FSeqName := ASeqName;
  FInitValue := AInitValue;
  FIncrement := AIncrement;
end;

{ Association }

constructor Association.Create(AFetchType: TFetchType; ARequired: Boolean; ACascade: TCascadeTypes);
begin
  inherited Create;
  FFetchType := AFetchType;
  FRequired := ARequired;
  FCascade := ACascade;
end;

{ ManyValuedAssociation }

constructor ManyValuedAssociation.Create(AFetchType: TFetchType; ARequired: Boolean; ACascade: TCascadeTypes;
  const AMappedBy: string);
begin
  Create(AFetchType, ARequired, ACascade);
  FMappedBy := AMappedBy;
end;

{ JoinColumn }

constructor JoinColumn.Create(const AName: string; const AReferencedTableName, AReferencedColumnName: string);
begin
  inherited Create;
  FName := AName;
  //FProperties := AProperties;
  FReferencedColName := AReferencedColumnName;
  FReferencedTableName := AReferencedTableName;
end;

{ Column }

constructor ColumnAttribute.Create(const AName: string; AProperties: TColumnProperties; ALength, APrecision, AScale: Integer;
  const ADescription: string);
begin
  Create(AName, AProperties);
  FLength := ALength;
  FPrecision := APrecision;
  FScale := AScale;
  FDescription := ADescription;
end;

constructor ColumnAttribute.Create(const AName: string; AProperties: TColumnProperties);
begin
  inherited Create();
  FName := AName;
  FProperties := AProperties;
  FLength := 50;
  FPrecision := 10;
  FScale := 2;
  FDescription := '';
end;

function ColumnAttribute.IsDiscriminator: Boolean;
begin
  Result := False;
end;

{ DiscriminatorValue }

constructor DiscriminatorValue.Create(const AValue: TValue);
begin
  inherited Create;
  FValue := AValue;
end;

{ DiscriminatorColumn }

constructor DiscriminatorColumn.Create(const AName: string; ADiscrType: TDiscriminatorType; ALength: Integer);
begin
  inherited Create(AName, [], ALength, 0, 0, '');
  FName := AName;
  FDiscrType := ADiscrType;
  FLength := ALength;
end;

function DiscriminatorColumn.IsDiscriminator: Boolean;
begin
  Result := True;
end;

{ Inheritence }

constructor Inheritence.Create(AStrategy: TInheritenceStrategy);
begin
  inherited Create;
  FStrategy := AStrategy;
end;

{ TORMAttribute }

function TORMAttribute.AsRttiObject(ATypeInfo: PTypeInfo): TRttiNamedObject;
var
  LType: TRttiType;
begin
  LType := TRttiContext.Create.GetType(ATypeInfo);
  Result := LType.GetField(ClassMemberName);
  if not Assigned(Result) then
    Result := LType.GetProperty(ClassMemberName);
end;

function TORMAttribute.AsRttiObject: TRttiNamedObject;
begin
  Result := AsRttiObject(FTypeInfo);
end;

function TORMAttribute.GetBaseEntityClass: TClass;
begin
  Result := TRttiContext.Create.GetType(EntityTypeInfo).AsInstance.MetaclassType;
end;

function TORMAttribute.GetColumnTypeInfo: PTypeInfo;
begin
  Result := GetTypeInfo(FTypeInfo);
end;

function TORMAttribute.GetTypeInfo(AEntityTypeInfo: PTypeInfo): PTypeInfo;
var
  LRttiObj: TRttiNamedObject;
begin
  Result := nil;

  LRttiObj := AsRttiObject(AEntityTypeInfo);
  if LRttiObj is TRttiField then
  begin
    Result := TRttiField(LRttiObj).FieldType.Handle;
  end
  else if LRttiObj is TRttiProperty then
  begin
    Result := TRttiProperty(LRttiObj).PropertyType.Handle;
  end;
end;

{ ForeignJoinColumnAttribute }

constructor ForeignJoinColumnAttribute.Create(const AName, AReferencedTableName, AReferencedColumnName: string;
  AForeignStrategies: TForeignStrategies);
begin
  inherited Create(AName, AReferencedTableName, AReferencedColumnName);
  FForeignStrategies := AForeignStrategies;
end;

end.
