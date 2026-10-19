enum 50300 "DYN Message Direction"
{
    Access = Internal;
    Extensible = false;

    value(0; Incoming)
    {
        Caption = 'Incoming';
    }
    value(1; Outgoing)
    {
        Caption = 'Outgoing';
    }
}