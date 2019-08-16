
                SET @error.modify(N'insert text{sql:variable("@message")} as first into (/*/application_message)[1]');


          if (select @test.value(N'(/*/description/text())[1]', N'[nvarchar](max)')) is null
            set @test.modify(N'insert text{sql:variable("@test_description")} as first into (/*/description)[1]');
          else
            set @test.modify(N'replace value of (/*/description/text())[1] with sql:variable("@test_description")');