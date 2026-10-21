page 50302 "DYN Sample FTP"
{
    ApplicationArea = All;
    Caption = 'Sample FTP';
    InherentEntitlements = X;
    InherentPermissions = X;
    PageType = Card;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(FTP)
            {
                Caption = 'FTP';

                field(FTPCode; FTPCode)
                {
                    Caption = 'FTP Code';
                    ShowMandatory = true;
                    TableRelation = "ESCA FTP Setup";
                    ToolTip = 'Specifies the FTP code to use for the FTP.';
                }
                field(FTPPath; FTPPath)
                {
                    Caption = 'FTP Path';
                    ToolTip = 'Specifies the FTP path to use for the FTP.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(UploadFile)
            {
                Caption = 'Upload File';
                Image = MoveUp;
                ToolTip = 'Uploads a file to the FTP.';

                trigger OnAction();
                var
                    FTPSetup: Record "ESCA FTP Setup";
                    FTPRequest: Record "ESCA FTP Request";
                    FTPRequestMgt: Codeunit "ESCA FTP Request Mgt.";
                    TempBlob: Codeunit "Temp Blob";
                    InStream: InStream;
                    OutStream: OutStream;
                    FromFile: Text;
                begin
                    if FTPCode = '' then
                        Error('Please enter a FTP Code');

                    FTPSetup.Get(FTPCode);
                    Ftpsetup.TestField(FTPSetup."FTP Request Type", FTPSetup."FTP Request Type"::"Upload File");

                    if not File.UploadIntoStream('Upload File', '', 'Image files(*.*,)|*.*', FromFile, InStream) then
                        Error('Please select a file to upload');

                    TempBlob.CreateOutStream(OutStream);
                    CopyStream(OutStream, InStream);

                    if not FTPRequestMgt.UploadFile(FTPCode, FTPPath, TempBlob, CopyStr(FromFile, 1, 250), not GuiAllowed(), FTPRequest) then
                        Error('Error uploading file');

                    Message('File uploaded successfully');
                end;
            }
        }
    }

    var
        FTPCode: Code[20];
        FTPPath: Text;
}