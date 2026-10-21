page 50301 "DYN Book Card"
{
    ApplicationArea = All;
    Caption = 'Book Card';
    InherentEntitlements = X;
    InherentPermissions = X;
    PageType = Card;
    SourceTable = "DYN Book";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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