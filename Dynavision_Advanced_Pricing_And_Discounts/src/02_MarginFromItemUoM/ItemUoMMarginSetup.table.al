table 50401 "DYN Item UoM Margin Setup"
{
    Access = Public;
    AllowInCustomizations = AsReadWrite;
    Caption = 'Item UoM Margin Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "DYN Item UoM Margin Setup List";
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;
    LookupPageId = "DYN Item UoM Margin Setup List";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
            ToolTip = 'Specifies the item number.';
        }
        field(2; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
            ToolTip = 'Specifies the unit of measure code.';
        }
        field(10; "Targeted Margin Percentage"; Decimal)
        {
            Caption = 'Targeted Margin %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            ToolTip = 'Specifies the targeted profit margin percentage used to calculate selling prices for this item and unit of measure.';
        }
        field(11; "Threshold Percentage"; Decimal)
        {
            Caption = 'Threshold %';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
            ToolTip = 'Specifies the threshold margin percentage used for green/red margin status indication on sales and price lines.';
        }
    }

    keys
    {
        key(PK; "Item No.", "Unit of Measure Code")
        {
            Clustered = true;
        }
    }
}