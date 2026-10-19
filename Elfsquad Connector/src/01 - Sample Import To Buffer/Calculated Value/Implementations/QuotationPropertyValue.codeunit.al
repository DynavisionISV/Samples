codeunit 50503 "DYN Quotation Property Value" implements "ESCY Calculated Value"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure IsPushSupported(): Boolean
    begin
        exit(false);
    end;

#pragma warning disable PC0038
    procedure GetSourceValueForPush(Source: Variant) ReturnValue: JsonValue
#pragma warning restore PC0038
    begin
    end;

    procedure IsPullSupported(): Boolean
    begin
        exit(true);
    end;

    procedure GetDestinationFieldAndValueForPull(Destination: RecordRef; var DestinationField: FieldRef; var ValueToSet: Text)
    var
        QuotBufferPropValue: Record "DYN Quot. Buffer Prop. Value";
        FieldNo: Integer;
    begin
        if Destination.Number <> Database::"DYN Quot. Buffer Prop. Value" then exit;
        if ValueToSet = '' then exit;

        Destination.SetTable(QuotBufferPropValue);

        QuotBufferPropValue.CalcFields("Property Type");

        case QuotBufferPropValue."Property Type" of
            QuotBufferPropValue."Property Type"::Number:
                FieldNo := QuotBufferPropValue.FieldNo("Value Decimal");
            QuotBufferPropValue."Property Type"::Toggle:
                FieldNo := QuotBufferPropValue.FieldNo("Value Boolean");
            QuotBufferPropValue."Property Type"::Date:
                FieldNo := QuotBufferPropValue.FieldNo("Value Date");
            QuotBufferPropValue."Property Type"::MultiLine,
            QuotBufferPropValue."Property Type"::Html:
                FieldNo := QuotBufferPropValue.FieldNo("Value Blob");
            else
                FieldNo := QuotBufferPropValue.FieldNo("Value Text");
        end;

        DestinationField := Destination.Field(FieldNo);
        ValueToSet := ValueToSet; // Avoid warning
    end;
}