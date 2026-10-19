codeunit 50303 "DYN Json Tools"
{
    Access = Internal;

    internal procedure Json2Rec(JO: JsonObject; Rec: Variant): Variant
    var
        Ref: RecordRef;
    begin
        Ref.GetTable(Rec);
        exit(Json2Rec(JO, Ref.Number()));
    end;

    internal procedure Json2Rec(JO: JsonObject; TableNo: Integer): Variant
    var
        Ref: RecordRef;
        FR: FieldRef;
        FieldHash: Dictionary of [Text, Integer];
        i: Integer;
        T: JsonToken;
        JsonKeyValue: JsonValue;
        JsonKey: Text;
        RecVar: Variant;
    begin
        Ref.Open(TableNo);
        for i := 1 to Ref.FieldCount() do begin
            FR := Ref.FieldIndex(i);
            FieldHash.Add(GetJsonFieldName(FR), FR.Number);
        end;
        Ref.Init();
        foreach JsonKey in JO.Keys() do
            if JO.Get(JsonKey, T) then
                if T.IsValue() then begin
                    JsonKeyValue := T.AsValue();
                    FR := Ref.Field(FieldHash.Get(JsonKey));
                    AssignValueToFieldRef(FR, JsonKeyValue);
                end;
        RecVar := Ref;
        exit(RecVar);
    end;

    internal procedure Rec2Json(Rec: Variant): JsonObject
    var
        Ref: RecordRef;
    begin
        if not Rec.IsRecord then
            Error('Parameter Rec is not a record');
        Ref.GetTable(Rec);
        exit(RecRef2Json(Ref));
    end;

    internal procedure RecRef2Json(Ref: RecordRef): JsonObject
    var
        FRef: FieldRef;
        i: Integer;
        Out: JsonObject;
    begin
        for i := 1 to Ref.FieldCount() do begin
            FRef := Ref.FieldIndex(i);
            case FRef.Class of
                FRef.Class::Normal:
                    Out.Add(GetJsonFieldName(FRef), FieldRef2JsonValue(FRef));
                FRef.Class::FlowField:
                    begin
                        FRef.CalcField();
                        Out.Add(GetJsonFieldName(FRef), FieldRef2JsonValue(FRef));
                    end;
            end;
        end;
        exit(Out);
    end;

    local procedure FieldRef2JsonValue(FRef: FieldRef): JsonValue
    var
        D: Date;
        DT: DateTime;
        V: JsonValue;
        T: Time;
    begin
        case FRef.Type() of
            FieldType::Date:
                begin
                    D := FRef.Value;
                    V.SetValue(D);
                end;
            FieldType::Time:
                begin
                    T := FRef.Value;
                    V.SetValue(T);
                end;
            FieldType::DateTime:
                begin
                    DT := FRef.Value;
                    V.SetValue(DT);
                end;
            else
                V.SetValue(Format(FRef.Value, 0, 9));
        end;
        exit(V);
    end;

    local procedure GetJsonFieldName(FRef: FieldRef): Text
    var
        i: Integer;
        Name: Text;
    begin
        Name := FRef.Name();
        for i := 1 to StrLen(Name) do
            if Name[i] < '0' then
                Name[i] := '_';
        exit(Name.Replace('__', '_').TrimEnd('_').TrimStart('_'));
    end;

    local procedure AssignValueToFieldRef(var FR: FieldRef; JsonKeyValue: JsonValue)
    begin
        case FR.Type() of
            FieldType::Code,
            FieldType::Text,
            FieldType::Guid,
            FieldType::DateFormula:
                FR.Value(JsonKeyValue.AsText());
            FieldType::Integer:
                FR.Value(JsonKeyValue.AsInteger());
            FieldType::Date:
                FR.Value(JsonKeyValue.AsDate());
            FieldType::BigInteger:
                FR.Value(JsonKeyValue.AsBigInteger());
            FieldType::Boolean:
                FR.Value(JsonKeyValue.AsBoolean());
            FieldType::DateTime:
                FR.Value(JsonKeyValue.AsDateTime());
            FieldType::Decimal:
                FR.Value(JsonKeyValue.AsDecimal());
            FieldType::Option:
                FR.Value(JsonKeyValue.AsOption());
            FieldType::Time:
                FR.Value(JsonKeyValue.AsTime());
        end;
    end;
}