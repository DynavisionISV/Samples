codeunit 50500 "DYN Sync Setup Mgt."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    internal procedure CreateOneSyncSetup(CodeToSet: Code[20]; EndPointUrlToSet: Text; TableNoToSet: Integer; SequenceNoToSet: Integer; RecordFilterToSet: Text[1024]; OperationToSet: Enum "ESCY Operation"; InsertToSet: Boolean; ModifyToSet: Boolean; DeleteToSet: Boolean; OnlyProcessModifiedDataToSet: Boolean; PreProcessorToSet: Enum "ESCY Sync Processor"; PostProcessorToSet: Enum "ESCY Sync Processor"; RequiresContextToSet: Boolean; var SyncSetup: Record "ESCY Sync Setup"): Boolean
    var
        APIURL: Record "ESCA API URL";
    begin
        if SyncSetup.Get(CodeToSet) then
            exit(false);

        CreateOneAPIURL(CodeToSet, EndPointUrlToSet, TableNoToSet, APIURL);

        SyncSetup.Create(CodeToSet, SequenceNoToSet, TableNoToSet, APIURL.Code, RecordFilterToSet, false, 0, OperationToSet, InsertToSet, ModifyToSet, DeleteToSet, OnlyProcessModifiedDataToSet, PreProcessorToSet, PostProcessorToSet, RequiresContextToSet, Enum::"ESCA Module"::"ESCZ Elfsquad Connector", SyncSetup);
        SyncSetup.Enabled := true; // Skip validation
        SyncSetup.Modify(true);
        exit(true);
    end;

    internal procedure CreateOneSyncMapping(SyncSetupCodeToSet: Code[20]; APIFieldNameToSet: Text[50]; TableNoToSet: Integer; FieldNoToSet: Integer; ValidationOrderToSet: Integer; IsMasterSystemIdToSet: Boolean; SkipFieldValidationToSet: Boolean; FixValueToSet: Text[2048]; CalculatedValue: Enum "ESCY Calculated Value"; UpdateFieldFromResponseToSet: Boolean; var SyncMapping: Record "ESCY Sync Mapping")
    begin
        SyncMapping.Create(SyncSetupCodeToSet, APIFieldNameToSet, TableNoToSet, FieldNoToSet, false, ValidationOrderToSet, IsMasterSystemIdToSet, SkipFieldValidationToSet, FixValueToSet, CalculatedValue, UpdateFieldFromResponseToSet, Enum::"ESCA Module"::"ESCZ Elfsquad Connector", SyncMapping);
        SyncMapping.Enabled := true; // Skip validation
        SyncMapping.Modify(true);
    end;

    local procedure CreateOneAPIURL(Code: Code[20]; EndPoint: Text; SourceTableNo: Integer; var APIURL: Record "ESCA API URL")
    var
        ElfsquadSetup: Record "ESCZ Elfsquad Setup";
        UriFunctions: Codeunit "ESCA Uri Functions";
    begin
        if APIURL.Get(Code) then
            exit;

        ElfsquadSetup.Get();
        ElfsquadSetup.TestField("Authentication Code");

        APIURL.Validate(Code, Code);
        APIURL.Validate(URL, CopyStr(UriFunctions.CombineUriPath(ElfsquadSetup."API Base URL", EndPoint), 1, MaxStrLen(APIURL.URL)));
        APIURL.Validate("Authorization Code", ElfsquadSetup."Authentication Code");
        APIURL.Validate("Source Table No.", SourceTableNo);
        APIURL.ESCZCreateNewElfquadAPIUrl(APIURL);
    end;
}