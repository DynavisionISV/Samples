page 50401 "DYN Item UoM Margin Setup List"
{
    ApplicationArea = All;
    Caption = 'Item UoM Margin Setup List';
    InherentEntitlements = X;
    InherentPermissions = X;
    PageType = List;
    SourceTable = "DYN Item UoM Margin Setup";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.") { }
                field("Unit of Measure Code"; Rec."Unit of Measure Code") { }
                field("Targeted Margin Percentage"; Rec."Targeted Margin Percentage") { }
                field("Threshold Percentage"; Rec."Threshold Percentage") { }
            }
        }
    }
}