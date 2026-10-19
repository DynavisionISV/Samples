codeunit 50300 "DYN Installer"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        GenerateBooks();
    end;

    local procedure GenerateBooks()
    begin
        CreateBook('The Great Adventure', 'John Smith', 'Penguin Books');
        CreateBook('Mystery at Midnight', 'Emily Johnson', 'HarperCollins');
        CreateBook('Code Complete', 'Steve McConnell', 'Microsoft Press');
        CreateBook('Business Central Essentials', 'Maria Garcia', 'Packt Publishing');
        CreateBook('AL Programming Guide', 'David Wilson', 'Microsoft Press');
        CreateBook('The Lost City', 'Sarah Brown', 'Random House');
        CreateBook('Digital Transformation', 'Michael Lee', 'Wiley');
        CreateBook('Cloud Computing Basics', 'Jennifer Taylor', 'O''Reilly Media');
        CreateBook('Data Analysis Techniques', 'Robert Anderson', 'Springer');
        CreateBook('ERP Implementation Strategies', 'Lisa Martinez', 'Apress');
    end;

    local procedure CreateBook(BookName: Text[100]; BookAuthor: Text[50]; BookPublisher: Text[100])
    var
        Book: Record "DYN Book";
    begin
        Book.Reset();
        Book.SetRange(Name, BookName);
        Book.SetRange(Author, BookAuthor);

        if Book.IsEmpty then begin
            Book.Init();
            Book.Validate(Name, BookName);
            Book.Validate(Author, BookAuthor);
            Book.Validate(Publisher, BookPublisher);
            Book.Insert(true);
        end;
    end;
}