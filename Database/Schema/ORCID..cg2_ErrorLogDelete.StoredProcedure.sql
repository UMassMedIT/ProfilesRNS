SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORCID.].[cg2_ErrorLogDelete]
 
    @ErrorLogID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[ErrorLog] WHERE         [ORCID.].[ErrorLog].[ErrorLogID] = @ErrorLogID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the ErrorLog record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal



GO
