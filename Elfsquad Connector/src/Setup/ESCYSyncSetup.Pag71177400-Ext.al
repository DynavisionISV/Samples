pageextension 50500 DYNSyncSetup extends "ESCY Sync Setup" // 71177400
{
    actions
    {
        addlast(Processing)
        {
            action(DYNCreateCustomSyncMapping)
            {
                Caption = 'Create Custom Sync Mapping', Locked = true;
                ToolTip = 'Creates a custom sync mapping for an existing sync setup.', Locked = true;
                Image = TestFile;
                ApplicationArea = All;

                #region OnAction
                trigger OnAction()
                var
                    DYNSampleSyncMapping: Codeunit "DYN Sample Sync Mapping";
                begin
                    DYNSampleSyncMapping.Execute();
                end;
                #endregion OnAction
            }
            action(DYNCreateSampleImportToBuffer)
            {
                Caption = 'Create Sample Import To Buffer', Locked = true;
                ToolTip = 'Creates the required setup to import custom data to a buffer table.', Locked = true;
                Image = TestFile;
                ApplicationArea = All;

                #region OnAction
                trigger OnAction()
                var
                    DYNSampleImportToBuffer: Codeunit "DYN Sample Import To Buffer";
                begin
                    DYNSampleImportToBuffer.Execute();
                end;
                #endregion OnAction
            }
        }
        addlast(Category_Process)
        {
            actionref(DYNSampleSyncMapping_Promoted; DYNCreateCustomSyncMapping) { }
            actionref(DYNSampleImportToBuffer_Promoted; DYNCreateSampleImportToBuffer) { }
        }
    }
}