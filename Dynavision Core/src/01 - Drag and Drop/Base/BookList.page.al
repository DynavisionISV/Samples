page 50300 "DYN Book List"
{
    ApplicationArea = All;
    Caption = 'Books';
    CardPageId = "DYN Book Card";
    InherentEntitlements = X;
    InherentPermissions = X;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "DYN Book";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID) { }
                field(Name; Rec.Name) { }
                field(Author; Rec.Author) { }
                field(Publisher; Rec.Publisher) { }
            }
        }
        area(FactBoxes)
        {
            part("Doc. Attachment List Factbox"; "Doc. Attachment List Factbox")
            {
                Caption = 'Documents';
                SubPageLink = "Table ID" = const(Database::"DYN Book"), "ESCA Source System Id" = field("SystemId");
                UpdatePropagation = Both;
            }
        }
    }
}