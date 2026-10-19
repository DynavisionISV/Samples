table 50400 "DYN Custom Cost Setup"
{
    Access = Public;
    Caption = 'Custom Cost Setup';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
            NotBlank = false;
        }
        field(2; Active; Boolean)
        {
            Caption = 'Active';
            ToolTip = 'Specifies if the custom cost settings are active.';
        }
        field(10; "Cost Factor"; Decimal)
        {
            Caption = 'Cost Factor';
            InitValue = 1;
            MinValue = 0;
            ToolTip = 'A multiplier applied to the base cost to calculate the custom cost. E.g. 1.15 adds 15% overhead.';
        }
        field(11; "Fixed Cost Addition"; Decimal)
        {
            Caption = 'Fixed Cost Addition';
            MinValue = 0;
            ToolTip = 'A fixed amount added to the cost after applying the factor. E.g. a handling fee per unit.';
        }
        field(12; "Margin Cost Source"; Enum "ESCP Cost Source")
        {
            Caption = 'Margin Cost Source';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the cost source that should be used when creating margin cost definitions.';
        }
        field(13; "Purch. Price Form. Cost Source"; Enum "ESCP Cost Source")
        {
            Caption = 'Purch. Price Form. Cost Source';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the cost source that should be used when creating purchase price formulas (and templates).';
        }

    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        RecordHasBeenRead: Boolean;

    internal procedure InsertIfNotExists()
    begin
        Reset();
        if not Get() then begin
            Init();
            Insert(true);
        end;
    end;

    internal procedure GetRecordOnce()
    begin
        if RecordHasBeenRead then
            exit;
        InsertIfNotExists();
        Get();
        RecordHasBeenRead := true;
    end;
}