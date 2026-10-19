codeunit 50501 "DYN Sample Sync Mapping"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure Execute()
    var
        Item: Record Item;
        SyncMapping: Record "ESCY Sync Mapping";
        SyncSetup: Record "ESCY Sync Setup";
        PageManagement: Codeunit "Page Management";
    begin
        SyncSetup.Get('ELF_EXP_ITEM_1');
        CreateOneSyncMapping(SyncSetup, 'apiExampleField', Database::Item, Item.FieldNo("Description 2"), true, 0, false, false, '', false, SyncMapping);

        SyncMapping.Reset();
        SyncMapping.SetRange("Sync Setup Code", SyncSetup.Code);
        PageManagement.PageRun(SyncMapping);
    end;

    internal procedure CreateOneSyncMapping(SyncSetup: Record "ESCY Sync Setup"; APIFieldNameToSet: Text[50]; TableNoToSet: Integer; FieldNoToSet: Integer; EnabledToSet: Boolean; ValidationOrderToSet: Integer; IsMasterSystemIDToSet: Boolean; SkipFieldValidationToSet: Boolean; FixValueToSet: Text[2048]; UpdateFieldFromResponseToSet: Boolean; var SyncMapping: Record "ESCY Sync Mapping")
    var
    begin
        SyncMapping.SetRange("Sync Setup Code", SyncSetup.Code);
        SyncMapping.SetRange("API Field Name", APIFieldNameToSet);
        if not SyncMapping.FindFirst() then begin
            SyncMapping.Init();
            SyncMapping."Line No." := 0;
            SyncMapping.Validate("Sync Setup Code", SyncSetup.Code);
            SyncMapping."API Field Name" := APIFieldNameToSet; // Do not trigger search related field functionality
            SyncMapping.Validate("Table No.", TableNoToSet);
            if FieldNoToSet <> 0 then
                SyncMapping.Validate("Field No.", FieldNoToSet);
            SyncMapping.Validate(Enabled, EnabledToSet);
            SyncMapping.Validate("Validation Order", ValidationOrderToSet);
            SyncMapping.Validate("Is Master System Id", IsMasterSystemIDToSet);
            SyncMapping.Validate("Skip Field Validation", SkipFieldValidationToSet);
            if FixValueToSet <> '' then
                SyncMapping.Validate("Fix Value", FixValueToSet);
            SyncMapping.Validate("Update Field From Response", UpdateFieldFromResponseToSet);
            SyncMapping.Validate(Module, SyncSetup.Module);
            SyncMapping.Insert(true);
        end;
    end;
}