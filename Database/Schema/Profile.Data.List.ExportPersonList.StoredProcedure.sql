SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[List.ExportPersonList] 
	@UserID INT
AS
BEGIN

	DECLARE @IsAdmin INT
	SELECT @IsAdmin=1
		FROM [Profile.Data].[List.Admin] a
		WHERE @UserID IS NOT NULL
			AND a.UserID=@UserID

	SELECT Data 
	FROM (
		SELECT -1 PersonID, 
				'"PersonID","First Name","Last Name","Display Name"'
				+',"Address Line 1","Address Line 2","Address Line 3","Address Line 4","Address","Latitude","Longitude"'
				+',"Phone","Fax","Institution","Department","Division","Faculty Rank"'
				+',"Publications","CoAuthors"'
				+(CASE WHEN @IsAdmin=1 THEN ',"Email"' ELSE '' END)
				+',"Profiles URL"'
				Data
		UNION ALL
		SELECT m.PersonID, 
				CAST(m.PersonID AS VARCHAR(50)) 
				+ ',"' + REPLACE(FirstName,'"','""') + '"'
				+ ',"' + REPLACE(LastName,'"','""') + '"'
				+ ',"' + REPLACE(DisplayName,'"','""') + '"'
				+ ',' + (CASE WHEN ShowAddress = 'Y' THEN 
								'"' + REPLACE(ISNULL(AddressLine1,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressLine2,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressLine3,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressLine4,''),'"','""') + '"'
								+ ',"' + REPLACE(ISNULL(AddressString,''),'"','""') + '"'
								+ ',' + ISNULL(CAST(Latitude AS VARCHAR(50)), '')
								+ ',' + ISNULL(CAST(Longitude AS VARCHAR(50)), '') 
							ELSE ',,,,,,' END)
				+ ',' + (CASE WHEN ShowPhone = 'Y' THEN '"'+REPLACE(REPLACE(Phone,',','-'),'"','""')+'"' ELSE '' END)
				+ ',' + (CASE WHEN ShowFax = 'Y' THEN '"'+REPLACE(REPLACE(Fax,',','-'),'"','""')+'"' ELSE '' END)
				+ ',"' + REPLACE(ISNULL(InstitutionName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(DepartmentName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(DivisionFullName,''),'"','""') + '"'
				+ ',"' + REPLACE(ISNULL(FacultyRank,''),'"','""') + '"'
				+ ',' + (CASE WHEN ShowPublications='Y' THEN 
								CAST(ISNULL(NumPublications,0) AS VARCHAR(50)) 
								+ ',' + CAST(ISNULL(Reach1,0) AS VARCHAR(50))
							ELSE ',' END)
				+ (CASE WHEN @IsAdmin=1 THEN ',' + (CASE WHEN ShowEmail='Y' AND x.UserID IS NOT NULL THEN '"'+REPLACE(EmailAddr,'"','""')+'"' ELSE '""' END) ELSE '' END)
				+ ',"' + 'https://connects.catalyst.harvard.edu/Profiles/Profile/Person/' + CAST(m.PersonID AS VARCHAR(50)) + '"'
			FROM [Profile.Data].[List.Member] m 
				INNER JOIN [Profile.Cache].[Person] p 
					ON m.PersonID = p.PersonID AND m.UserID = @UserID
				OUTER APPLY (
					SELECT MAX(UserID) UserID
					FROM [Profile.Data].[List.Admin] a
					WHERE @UserID IS NOT NULL
						AND a.UserID=@UserID
						AND (CASE WHEN a.AdminForInstitution IS NULL THEN 1 WHEN a.AdminForInstitution=p.InstitutionName THEN 1 ELSE 0 END)=1
						AND (CASE WHEN a.AdminForDepartment IS NULL THEN 1 WHEN a.AdminForDepartment=p.DepartmentName THEN 1 ELSE 0 END)=1
						AND (CASE WHEN a.AdminForDivision IS NULL THEN 1 WHEN a.AdminForDivision=p.DivisionFullName THEN 1 ELSE 0 END)=1
				) x
	) t
	ORDER BY PersonID

END

GO
