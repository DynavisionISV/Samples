page 50304 "DYN Message API Push Example"
{
    ApplicationArea = All;
    Caption = 'Message API Push Example';
    Editable = false;
    PageType = List;
    SourceTable = "DYN Message API Test";
#pragma warning disable AL0254
    SourceTableView = sorting(SystemCreatedAt) order(descending);
#pragma warning restore AL0254
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    StyleExpr = LineStyle;
                }
                field("Original ID"; Rec."Original ID")
                {
                    StyleExpr = LineStyle;
                }
                field(Direction; Rec.Direction)
                {
                    StyleExpr = LineStyle;
                }
                field("AAD Tenant ID"; Rec."AAD Tenant ID")
                {
                    StyleExpr = LineStyle;
                }
                field("Environment Name"; Rec."Environment Name")
                {
                    StyleExpr = LineStyle;
                }
                field("Company Name"; Rec."Company Name")
                {
                    StyleExpr = LineStyle;
                }
                field("Error"; Rec.Error)
                {
                    StyleExpr = LineStyle;
                }
                field("Error Message"; Rec."Error Message")
                {
                    StyleExpr = LineStyle;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    StyleExpr = LineStyle;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    StyleExpr = LineStyle;
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action(SendMessage)
            {
                Caption = 'Send Message';
                Image = SendTo;
                ToolTip = 'Sends a test message';

                trigger OnAction()
                begin
                    Rec.CreateAndSendMessage();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(SendMessage_Promoted; SendMessage) { }
            }
        }
    }

    // Triggers
    trigger OnAfterGetRecord()
    begin
        if Rec.Error then
            LineStyle := Format(PageStyle::Attention)
        else
            LineStyle := Format(PageStyle::Standard);
    end;

    var
        LineStyle: Text;
}
