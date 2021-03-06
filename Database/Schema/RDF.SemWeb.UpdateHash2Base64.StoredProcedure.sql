SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [RDF.SemWeb].[UpdateHash2Base64]
	@FullUpdate BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @FullUpdate = 1
		TRUNCATE TABLE [RDF.SemWeb].[Hash2Base64]
		
	DECLARE @StartNodeID BIGINT
	SELECT @StartNodeID = ISNULL((SELECT MAX(NodeID) FROM [RDF.SemWeb].[Hash2Base64]),-1)

	INSERT INTO [RDF.SemWeb].[Hash2Base64] (NodeID, SemWebHash)
		SELECT NodeID, [RDF.SemWeb].[fnHash2Base64](ValueHash) SemWebHash
			FROM [RDF.].Node
			WHERE NodeID > @StartNodeID

END

GO
