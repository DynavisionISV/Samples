pageextension 50002 "DYNSales Order Card" extends "Sales Order" // 42
{
    actions
    {
        addafter("&Order Confirmation")
        {
            group("DYN Print")
            {
                Caption = 'Print', Locked = true;

                action("DYN Print Custom Version")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Print Custom Version';
                    Ellipsis = true;
                    Image = Print;
                    ToolTip = 'Print the custom version of the report.';

                    trigger OnAction()
                    begin
                        ReportDatastore.SetReportLayoutVersion(1);

                        Rec.SetRecFilter();
                        Report.Run(Report::"ESCR Sales Order", true, false, Rec);

                        ReportDatastore.ClearReportLayoutVersion();
                    end;
                }
            }
        }
    }

    var
        ReportDatastore: Codeunit "ESCA Report Datastore";
}