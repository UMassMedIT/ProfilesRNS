SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierEdit]

    @PersonWorkIdentifierID  INT =NULL OUTPUT 
    , @PersonWorkID  INT 
    , @WorkExternalTypeID  INT 
    , @Identifier  VARCHAR(250) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3615
 
  
        UPDATE [ORCID.].[PersonWorkIdentifier]
        SET
            [PersonWorkID] = @PersonWorkID
            , [WorkExternalTypeID] = @WorkExternalTypeID
            , [Identifier] = @Identifier
        FROM
            [ORCID.].[PersonWorkIdentifier]
        WHERE
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID] = @PersonWorkIdentifierID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonWorkIdentifier record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
