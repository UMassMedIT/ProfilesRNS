SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [ORCID.].[GetPublications]
	@Subject BIGINT -- = 147559
AS
BEGIN

	DECLARE @AuthorInAuthorship BIGINT -- = 94
	SELECT @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 

	DECLARE @LinkedInformationResource BIGINT -- = 1535
	SELECT @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 

	DECLARE @InformationResourceReference BIGINT -- = 381
	SELECT @InformationResourceReference = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#informationResourceReference') 

	SELECT TOP (100) PERCENT 
		Triple_1.TripleID, 
		[RDF.].Triple.SortOrder, 
		[RDF.].Triple.ViewSecurityGroup, 
		[RDF.].Node.Value
	FROM            
		[RDF.].Triple 
		INNER JOIN [RDF.].Triple AS Triple_1 ON [RDF.].Triple.Object = Triple_1.Subject 
		INNER JOIN [RDF.].Triple AS Triple_2 ON Triple_1.Object = Triple_2.Subject 
		INNER JOIN [RDF.].Node ON Triple_2.Object = [RDF.].Node.NodeID
	WHERE        
		([RDF.].Triple.Subject = @Subject) 
		AND ([RDF.].Triple.Predicate = @AuthorInAuthorship) 
		AND (Triple_1.Predicate = @LinkedInformationResource) 
		AND  (Triple_2.Predicate = @InformationResourceReference)
	ORDER BY 
		[RDF.].Triple.SortOrder

END


GO
