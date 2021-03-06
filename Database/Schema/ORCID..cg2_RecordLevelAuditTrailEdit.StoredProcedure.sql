SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailEdit]

    @RecordLevelAuditTrailID  BIGINT =NULL OUTPUT 
    , @MetaTableID  INT 
    , @RowIdentifier  BIGINT 
    , @RecordLevelAuditTypeID  INT 
    , @CreatedDate  SMALLDATETIME 
    , @CreatedBy  VARCHAR(10) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
 
  
        UPDATE [ORCID.].[RecordLevelAuditTrail]
        SET
            [MetaTableID] = @MetaTableID
            , [RowIdentifier] = @RowIdentifier
            , [RecordLevelAuditTypeID] = @RecordLevelAuditTypeID
            , [CreatedDate] = @CreatedDate
            , [CreatedBy] = @CreatedBy
        FROM
            [ORCID.].[RecordLevelAuditTrail]
        WHERE
        [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID] = @RecordLevelAuditTrailID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the RecordLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
