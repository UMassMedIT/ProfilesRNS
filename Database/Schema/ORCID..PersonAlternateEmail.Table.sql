SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [ORCID.].[PersonAlternateEmail](
	[PersonAlternateEmailID] [int] IDENTITY(1,1) NOT NULL,
	[PersonID] [int] NOT NULL,
	[EmailAddress] [varchar](200) NOT NULL,
	[PersonMessageID] [int] NULL,
 CONSTRAINT [PK_PersonAlternateEmail] PRIMARY KEY CLUSTERED 
(
	[PersonAlternateEmailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [ORCID.].[PersonAlternateEmail]  WITH CHECK ADD  CONSTRAINT [fk_PersonAlternateEmail_Personid] FOREIGN KEY([PersonID])
REFERENCES [ORCID.].[Person] ([PersonID])
GO
ALTER TABLE [ORCID.].[PersonAlternateEmail] CHECK CONSTRAINT [fk_PersonAlternateEmail_Personid]
GO
ALTER TABLE [ORCID.].[PersonAlternateEmail]  WITH CHECK ADD  CONSTRAINT [fk_PersonAlternateEmail_PersonMessageid] FOREIGN KEY([PersonMessageID])
REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID])
GO
ALTER TABLE [ORCID.].[PersonAlternateEmail] CHECK CONSTRAINT [fk_PersonAlternateEmail_PersonMessageid]
GO
