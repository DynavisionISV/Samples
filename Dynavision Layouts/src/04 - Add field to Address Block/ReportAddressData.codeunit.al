codeunit 50003 "DYN Report Address Data"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Get Report Address Data", OnAfterGetExtraParametersFromCompanyInformation, '', false, false)]
    local procedure OnAfterGetExtraParametersFromCompanyInformation(var TempReportAddressBuffer: Record "ESCA Report Address Buffer" temporary; CompanyInformation: Record "Company Information")
    begin
        TempReportAddressBuffer."DYN RPR" := CompanyInformation."DYN RPR";
    end;
}