codeunit 50005 "DYN Report Footer Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"ESCA Report Layout", OnAfterGetPageFooterTextHTML, '', false, false)]
    local procedure "ESCA Report Layout_OnAfterGetPageFooterTextHTML"(ReportLayoutSetup: Record "ESCA Report Layout Setup"; LanguageCode: Code[10]; var PageFooterTextHTML: Text)
    var
        CompanyInformation: Record "Company Information";
    begin
        // Only Apply for Sales Quote Report
        if ReportLayoutSetup."Report ID" <> Report::"ESCR Sales Quote" then
            exit;

        CompanyInformation.Get();

        PageFooterTextHTML := '<p>By accepting this quote, you agree to the terms and conditions of the quote.<br/>';
        PageFooterTextHTML += '<br/>';
        PageFooterTextHTML += StrSubstNo('%1 %2', CompanyInformation."Bank Name", CompanyInformation.IBAN);
        PageFooterTextHTML += '</p>';
    end;
}