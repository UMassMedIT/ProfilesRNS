SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  procedure [Profile.Data].[Publication.Group.MyPub.UpdatePublication]
	@mpid nvarchar(50),
	@HMS_PUB_CATEGORY nvarchar(60) = '',
	@PUB_TITLE nvarchar(2000) = '',
	@ARTICLE_TITLE nvarchar(2000) = '',
	@CONF_EDITORS nvarchar(2000) = '',
	@CONF_LOC nvarchar(2000) = '',
	@EDITION nvarchar(30) = '',
	@PLACE_OF_PUB nvarchar(60) = '',
	@VOL_NUM nvarchar(30) = '',
	@PART_VOL_PUB nvarchar(15) = '',
	@ISSUE_PUB nvarchar(30) = '',
	@PAGINATION_PUB nvarchar(30) = '',
	@ADDITIONAL_INFO nvarchar(2000) = '',
	@PUBLISHER nvarchar(255) = '',
	@CONF_NM nvarchar(2000) = '',
	@CONF_DTS nvarchar(60) = '',
	@REPT_NUMBER nvarchar(35) = '',
	@CONTRACT_NUM nvarchar(35) = '',
	@DISS_UNIV_NM nvarchar(2000) = '',
	@NEWSPAPER_COL nvarchar(15) = '',
	@NEWSPAPER_SECT nvarchar(15) = '',
	@PUBLICATION_DT smalldatetime = '',
	@ABSTRACT varchar(max) = '',
	@AUTHORS varchar(max) = '',
	@URL varchar(1000) = '',
	@updated_by varchar(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	---------------------------------------------------
	-- Update the MyPub General information
	---------------------------------------------------
 
	UPDATE [Profile.Data].[Publication.Group.MyPub.General] SET
		HmsPubCategory = @HMS_PUB_CATEGORY,
		PubTitle = @PUB_TITLE,
		ArticleTitle = @ARTICLE_TITLE,
		ConfEditors = @CONF_EDITORS,
		ConfLoc = @CONF_LOC,
		EDITION = @EDITION,
		PlaceOfPub = @PLACE_OF_PUB,
		VolNum = @VOL_NUM,
		PartVolPub = @PART_VOL_PUB,
		IssuePub = @ISSUE_PUB,
		PaginationPub = @PAGINATION_PUB,
		AdditionalInfo = @ADDITIONAL_INFO,
		PUBLISHER = @PUBLISHER,
		ConfNm = @CONF_NM,
		ConfDTs = @CONF_DTS,
		ReptNumber = @REPT_NUMBER,
		ContractNum = @CONTRACT_NUM,
		DissUnivNm = @DISS_UNIV_NM,
		NewspaperCol = @NEWSPAPER_COL,
		NewspaperSect = @NEWSPAPER_SECT,
		PublicationDT = @PUBLICATION_DT,
		ABSTRACT = @ABSTRACT,
		AUTHORS = @AUTHORS,
		URL = @URL,
		UpdatedBy = @updated_by,
		UpdatedDT = GetDate()
	WHERE mpid = @mpid
		and mpid not in (select mpid from [Profile.Data].[Publication.DSpace.MPID])
		and mpid not in (select mpid from [Profile.Data].[Publication.ISI.MPID])


	IF @@ROWCOUNT > 0
	BEGIN

		DECLARE @SQL NVARCHAR(MAX)

		---------------------------------------------------
		-- Update the InformationResource Entity
		---------------------------------------------------
	
		-- Get publication information
	
		CREATE TABLE #Publications
		(
			PMID INT NULL ,
			MPID NVARCHAR(50) NULL ,
			EntityDate DATETIME NULL ,
			Reference VARCHAR(MAX) NULL ,
			Source VARCHAR(25) NULL ,
			URL VARCHAR(1000) NULL ,
			Title VARCHAR(4000) NULL
		)

		INSERT  INTO #Publications
				( MPID ,
				  EntityDate ,
				  Reference ,
				  Source ,
				  URL ,
				  Title
				)
				SELECT  MPID ,
						EntityDate ,
						Reference = REPLACE(authors
											+ (CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
											+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
											+ y
											+ CASE WHEN y <> ''
														AND vip <> '' THEN '; '
												   ELSE ''
											  END + vip
											+ CASE WHEN y <> ''
														OR vip <> '' THEN '.'
												   ELSE ''
											  END, CHAR(11), '') ,
						Source = 'Custom' ,
						URL = url,
						Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000)
				FROM    ( SELECT    MPID ,
									EntityDate ,
									url ,
									authors = CASE WHEN authors = '' THEN ''
												   WHEN RIGHT(authors, 1) = '.'
												   THEN LEFT(authors,
															 LEN(authors) - 1)
												   ELSE authors
											  END ,
									article = CASE WHEN article = '' THEN ''
												   WHEN RIGHT(article, 1) = '.'
												   THEN LEFT(article,
															 LEN(article) - 1)
												   ELSE article
											  END ,
									pub = CASE WHEN pub = '' THEN ''
											   WHEN RIGHT(pub, 1) = '.'
											   THEN LEFT(pub, LEN(pub) - 1)
											   ELSE pub
										  END ,
									y ,
									vip
						  FROM      ( SELECT    MPG.mpid ,
												EntityDate = MPG.publicationdt ,
												authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
																  ''))) = ''
															   THEN ''
															   WHEN RIGHT(COALESCE(MPG.authors,
																  ''), 1) = '.'
																THEN  COALESCE(MPG.authors,
																  '') + ' '
															   ELSE COALESCE(MPG.authors,
																  '') + '. '
														  END ,
												url = CASE WHEN COALESCE(MPG.url,
																  '') <> ''
																AND LEFT(COALESCE(MPG.url,
																  ''), 4) = 'http'
														   THEN MPG.url
														   WHEN COALESCE(MPG.url,
																  '') <> ''
														   THEN 'http://' + MPG.url
														   ELSE ''
													  END ,
												article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
																  ''))) ,
												pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
																  ''))) ,
												y = CASE WHEN MPG.publicationdt > '1/1/1901'
														 THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
														 ELSE ''
													END ,
												vip = COALESCE(MPG.volnum, '')
												+ CASE WHEN COALESCE(MPG.issuepub,
																  '') <> ''
													   THEN '(' + MPG.issuepub
															+ ')'
													   ELSE ''
												  END
												+ CASE WHEN ( COALESCE(MPG.paginationpub,
																  '') <> '' )
															AND ( COALESCE(MPG.volnum,
																  '')
																  + COALESCE(MPG.issuepub,
																  '') <> '' )
													   THEN ':'
													   ELSE ''
												  END + COALESCE(MPG.paginationpub,
																 '')
									  FROM      [Profile.Data].[Publication.Group.MyPub.General] MPG
									  WHERE MPID = @mpid
									) T0
						) T0

		-- Update the entity record
		DECLARE @EntityID INT		
		UPDATE e
			SET e.EntityDate = p.EntityDate,
				e.Reference = p.Reference,
				e.Source = p.Source,
				e.URL = p.URL,
				@EntityID = e.EntityID
			FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
			WHERE p.MPID = e.MPID

	END
 
END

GO
