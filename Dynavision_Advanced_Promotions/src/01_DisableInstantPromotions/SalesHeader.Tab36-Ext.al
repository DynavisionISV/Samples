tableextension 50100 DYN01SalesHeader extends "Sales Header" // 36
{
    fields
    {
        field(50100; "DYN Web Order"; Boolean)
        {
            AllowInCustomizations = AsReadWrite;
            Caption = 'Web Order';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this sales document originates from a web shop.';
        }
    }
}