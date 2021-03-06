SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailAdd]

    @PersonAlternateEmailID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @EmailAddress  VARCHAR(200) 
    , @PersonMessageID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3579
 
  
        INSERT INTO [ORCID.].[PersonAlternateEmail]
        (
            [PersonID]
            , [EmailAddress]
            , [PersonMessageID]
        )
        (
            SELECT
            @PersonID
            , @EmailAddress
            , @PersonMessageID
        )
   
        SET @intReturnVal = @@error
        SET @PersonAlternateEmailID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonAlternateEmail record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
