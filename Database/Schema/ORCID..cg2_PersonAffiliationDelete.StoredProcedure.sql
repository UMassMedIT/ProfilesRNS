SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationDelete]
 
    @PersonAffiliationID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonAffiliation] WHERE         [ORCID.].[PersonAffiliation].[PersonAffiliationID] = @PersonAffiliationID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonAffiliation record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal



GO
