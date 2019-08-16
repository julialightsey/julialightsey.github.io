use [chamomile];

go

declare @entry [xml]=N'<style type="text/css">
                table.parameter{
                        border: 1px solid black;
                        border-collapse: collapse;
                        padding:5px;
                        width:100%;
                } 
                table.object{
                        border: 1px solid black;
                        border-collapse: collapse;
                        padding:5px;
                        width:100%;
                } 
                td {
                        border: 1px solid black;
                        border-collapse: collapse;
                }
                th {
                        border: 1px solid black;
                        border-collapse: collapse;
                        background-color: green;
                        color: white;
                }
                h1 {
                        text-align:center;
                }
                h2 {
                        text-align:center;
                }
</style>';

insert into [metadata].[data]
            ([category],
             [class],
             [type],
             [entry])
values      (N'chamomile',
             N'html',
             N'stylesheet',
             @entry); 
