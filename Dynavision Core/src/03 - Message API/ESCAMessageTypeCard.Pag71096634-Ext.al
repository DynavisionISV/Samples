pageextension 50302 DYN03MessageTypeCard extends "ESCA Message Type Card" // 71096634
{
    actions
    {
        addlast(Processing)
        {
            action(DYNMessageAPIPushExample)
            {
                ApplicationArea = All;
                Caption = 'Run Example';
                Image = ExecuteBatch;
                RunObject = page "DYN Message API Push Example";
                ToolTip = 'Opens the example page where you can send a test message to the other side';
                Visible = Rec."Message Format" = Rec."Message Format"::"DYN Message API Push Example";
            }
            action(DYNMessageAPIPullExample)
            {
                ApplicationArea = All;
                Caption = 'Sample';
                Image = ExecuteBatch;
                ToolTip = 'Imports the asked item no.';
                Visible = Rec."Message Format" = Rec."Message Format"::"DYN Message API Pull Example";

                trigger OnAction()
                var
                    MessageAPIPullExample: Codeunit "DYN Message API Pull Example";
                begin
                    MessageAPIPullExample.ImportItem();
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(DYNMessageAPIPushExample_Promoted; DYNMessageAPIPushExample) { }
            actionref(DYNMessageAPIPullExample_Promoted; DYNMessageAPIPullExample) { }
        }
    }
}