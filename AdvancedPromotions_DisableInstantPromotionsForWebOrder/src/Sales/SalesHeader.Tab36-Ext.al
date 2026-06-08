tableextension 50100 "DYN Web Order Sales Header" extends "Sales Header" // 36
{
    fields
    {
        field(50100; "Web Order"; Boolean)
        {
            Caption = 'Web Order';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this sales document originates from a web shop. When enabled, instant promotions are not calculated on line entry but are included when Check for Promotions is run.';
        }
    }
}
