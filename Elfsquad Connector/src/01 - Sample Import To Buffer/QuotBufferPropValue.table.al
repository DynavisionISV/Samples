table 50500 "DYN Quot. Buffer Prop. Value"
{
    Access = Public;
    Caption = 'Quotation Buffer Property Value', Locked = true;
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    LookupPageId = "DYN Quot. Buffer Prop. List";
    DrillDownPageId = "DYN Quot. Buffer Prop. List";

    fields
    {
        field(1; Id; Guid)
        {
            Caption = 'Id', Locked = true;
        }
        field(2; "Quotation Id"; Guid)
        {
            Caption = 'Quotation Id', Locked = true;
            TableRelation = "ESCZ Quotation Buffer".Id;
        }
        field(3; "Property Id"; Guid)
        {
            Caption = 'Property Id', Locked = true;
            TableRelation = "DYN Quotation Buffer Property".Id;
        }
        field(4; "Property Name"; Text[250])
        {
            CalcFormula = lookup("DYN Quotation Buffer Property".Name where(Id = field("Property Id")));
            Caption = 'Property Name', Locked = true;
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the name of the property.', Locked = true;
        }
        field(5; "Property Type"; Enum "ESCZ Property Type")
        {
            CalcFormula = lookup("DYN Quotation Buffer Property".Type where(Id = field("Property Id")));
            Caption = 'Property Type', Locked = true;
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Value Text"; Text[2048])
        {
            Caption = 'Value Text', Locked = true;
        }
        field(7; "Value Decimal"; Decimal)
        {
            Caption = 'Value Decimal', Locked = true;
        }
        field(8; "Value Boolean"; Boolean)
        {
            Caption = 'Value Boolean', Locked = true;
        }
        field(9; "Value Date"; Date)
        {
            Caption = 'Value Date', Locked = true;
        }
        field(10; "Value Blob"; Blob)
        {
            Caption = 'Value Blob', Locked = true;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    internal procedure GetValueAsText() Value: Text
    var
        InStream: InStream;
    begin
        CalcFields("Property Type");

        case "Property Type" of
            "Property Type"::Number:
                Value := Format("Value Decimal");
            "Property Type"::Toggle:
                Value := Format("Value Boolean");
            "Property Type"::Date:
                Value := Format("Value Date");
            "Property Type"::MultiLine,
            "Property Type"::Html:
                begin
                    CalcFields("Value Blob");
                    "Value Blob".CreateInStream(InStream, TextEncoding::UTF8);
                    InStream.ReadText(Value);
                end
            else
                Value := "Value Text";
        end;
    end;
}