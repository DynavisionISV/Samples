page 50500 "DYN Quot. Buffer Prop. List"
{
    ApplicationArea = All;
    Caption = 'Properties', Locked = true;
    Editable = false;
    InherentEntitlements = X;
    InherentPermissions = X;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "DYN Quot. Buffer Prop. Value";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Property Name"; Rec."Property Name")
                {
                    Caption = 'Name', Locked = true;
                }
                field(Value; ValueAsText)
                {
                    Caption = 'Value', Locked = true;
                    ToolTip = 'Specifies the value of the property.', Locked = true;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ValueAsText := Rec.GetValueAsText()
    end;

    var
        ValueAsText: Text;
}