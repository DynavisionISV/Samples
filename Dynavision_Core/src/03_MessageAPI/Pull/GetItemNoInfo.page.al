page 50303 "DYN Get Item No. Info"
{
    ApplicationArea = All;
    Caption = 'Get Item No. Info';
    PageType = StandardDialog;
    UsageCategory = NOne;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;
                field(ExistingItemNo; ExistingItemNo)
                {
                    Caption = 'Existing Item No.';
                    ToolTip = 'Specifies the no. of the existing item to receive';
                }
                field(NewItemNo; NewItemNo)
                {
                    Caption = 'New Item No.';
                    ToolTip = 'Specifies the no. of the new item that will be created based on the existing item';

                    #region OnValidate
                    trigger OnValidate()
                    var
                        Item: Record Item;
                        ItemAlreadyExistsErr: Label 'Item with no. %1 already exists.';
                    begin
                        if Item.Get(NewItemNo) then
                            Error(ItemAlreadyExistsErr, NewItemNo);
                    end;
                    #endregion OnValidate
                }
            }
        }
    }

    // Triggers
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        EnterExistingItemNoErr: Label 'Please enter an Existing Item No.';
        EnterNewItemNoErr: Label 'Please enter a New Item No.';
    begin
        if CloseAction = CloseAction::LookupOK then begin
            if ExistingItemNo = '' then
                Error(EnterExistingItemNoErr);
            if NewItemNo = '' then
                Error(EnterNewItemNoErr);
        end;
    end;

    // Procedures
    internal procedure AskItemInfo(var ExistingItemNoToGet: Code[20]; var NewItemNoToGet: Code[20])
    var
        GetItemNoPage: Page "DYN Get Item No. Info";
    begin
        if GetItemNoPage.RunModal() <> Action::OK then
            Error('');
        GetItemNoPage.GetItemInfo(ExistingItemNoToGet, NewItemNoToGet);
    end;

    internal procedure GetItemInfo(var ExistingItemNoToGet: Code[20]; var NewItemNoToGet: Code[20])
    begin
        ExistingItemNoToGet := ExistingItemNo;
        NewItemNoToGet := NewItemNo;
    end;

    var
        ExistingItemNo: Code[20];
        NewItemNo: Code[20];
}