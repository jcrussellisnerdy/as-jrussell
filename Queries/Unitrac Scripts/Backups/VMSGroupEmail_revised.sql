USE [VUT]
GO
/****** Object:  StoredProcedure [dbo].[VMSGroupEmail]    Script Date: 9/26/2019 4:04:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




ALTER  PROCEDURE [dbo].[VMSGroupEmail] (@gname as varchar(20), @body as varchar(6000), @attachment as varchar(1000)=NULL )AS

Declare @efrom as varchar(500)
Declare @subject as varchar(500)
Declare @eto as varchar(5000)

Select @efrom = efrom, @subject = subject, @eto = eGroupEmail from lkuGroupEmail where GroupCode = @gname

DECLARE @object int
Declare @hr as int

EXEC @hr = sp_OACreate 'CDO.Message', @object OUT

EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2' 
EXEC @hr = sp_OASetProperty @object, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', 'mailrelay.alliedsolutions.net' 

--EXEC @hr = sp_OASetProperty @object, 'Configuration.fields ("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','1'
EXEC @hr = sp_OAMethod @object, 'Configuration.Fields.Update', null

EXEC @hr = sp_OASetProperty @object, 'From',@efrom
EXEC @hr = sp_OASetProperty @object, 'TextBody', @body
EXEC @hr = sp_OASetProperty @object, 'Subject', @subject
EXEC @hr = sp_OASetProperty @object, 'To', @eto
EXEC @hr = sp_OASetProperty @object, 'MailFormat', 0
if @attachment is not null
EXEC @hr = sp_OAMethod @object, 'AddAttachment', NULL, @attachment
EXEC @hr = sp_OAMethod @object, 'Send', NULL
EXEC @hr = sp_OADestroy @object
