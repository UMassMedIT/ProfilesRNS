SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailEdit]

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
 
  
        UPDATE [ORCID.].[PersonAlternateEmail]
        SET
            [PersonID] = @PersonID
            , [EmailAddress] = @EmailAddress
            , [PersonMessageID] = @PersonMessageID
        FROM
            [ORCID.].[PersonAlternateEmail]
        WHERE
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID] = @PersonAlternateEmailID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonAlternateEmail record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
