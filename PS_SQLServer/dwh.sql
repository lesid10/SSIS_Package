USE [master]
GO
/****** Object:  Database [DWH]    Script Date: 26/08/2020 14:51:32 ******/
CREATE DATABASE [DWH]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DWH', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DWH.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DWH_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\DWH_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [DWH] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [DWH].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [DWH] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DWH] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DWH] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DWH] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DWH] SET ARITHABORT OFF 
GO
ALTER DATABASE [DWH] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DWH] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DWH] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DWH] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DWH] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DWH] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DWH] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DWH] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DWH] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DWH] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DWH] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DWH] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DWH] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [DWH] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [DWH] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DWH] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DWH] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [DWH] SET RECOVERY FULL 
GO
ALTER DATABASE [DWH] SET  MULTI_USER 
GO
ALTER DATABASE [DWH] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DWH] SET DB_CHAINING OFF 
GO
ALTER DATABASE [DWH] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [DWH] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DWH] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'DWH', N'ON'
GO
ALTER DATABASE [DWH] SET QUERY_STORE = OFF
GO
USE [DWH]
GO
/****** Object:  UserDefinedFunction [dbo].[FaitSansParam]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FaitSansParam] (@idActivite integer)
RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @NOMFAIT varchar(100);
	SELECT @NOMFAIT = [TABLE_NAME]   --, count(COLUMN_NAME)
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE COLUMN_NAME LIKE 'ID_DIM_%' AND TABLE_NAME LIKE 'FSP_%' --ID_DIM_
	AND COLUMN_NAME IN
	(
	SELECT distinct CONCAT('ID_DIM_',dbo.axes.nomAxe) as dimension--ID_DIM_
			FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
			WHERE dbo.axes.idAxe = dbo.questions.idAxe and 
			  dbo.questions.idQuestion = dbo.questionnaire.idQuestion and 
			  dbo.questionnaire.typeParam = 'null' and
			  dbo.questionnaire.idActivite = dbo.activites.idActivite and dbo.axes.type ='DIMENSION' and
			  --dbo.activites.idActivite = 11
			  dbo.activites.idActivite = @idActivite
	)
	group by TABLE_NAME
	having count(COLUMN_NAME)=(
								SELECT count(distinct CONCAT('ID_DIM_',dbo.axes.nomAxe))--ID_DIM_
								FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
								WHERE dbo.axes.idAxe = dbo.questions.idAxe and 
								  dbo.questions.idQuestion = dbo.questionnaire.idQuestion and 
								  dbo.questionnaire.typeParam = 'null' and
								  dbo.questionnaire.idActivite = dbo.activites.idActivite and dbo.axes.type ='DIMENSION' and
								  --dbo.activites.idActivite = @idActivite --par
								  dbo.activites.idActivite = @idActivite
								)

RETURN @NOMFAIT;
END
GO
/****** Object:  UserDefinedFunction [dbo].[P_Fait]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[P_Fait] (@idActivite integer)

RETURNS NVARCHAR(20)
AS
BEGIN
	DECLARE @NOMFAIT varchar(100);
	SELECT @NOMFAIT = [TABLE_NAME]   --, count(COLUMN_NAME)
	FROM INFORMATION_SCHEMA.COLUMNS 
	WHERE COLUMN_NAME LIKE 'ID_DIM_%' AND TABLE_NAME LIKE 'FP_%' --ID_DIM_
	AND COLUMN_NAME IN
	(
	SELECT distinct CONCAT('ID_DIM_',dbo.axes.nomAxe) as dimension--ID_DIM_
			FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
			WHERE dbo.axes.idAxe = dbo.questions.idAxe and 
			  dbo.questions.idQuestion = dbo.questionnaire.idQuestion and 
			  dbo.questionnaire.typeParam <> 'null' and
			  dbo.questionnaire.idActivite = dbo.activites.idActivite and dbo.axes.type ='DIMENSION' and
			  --dbo.activites.idActivite = 11
			  dbo.activites.idActivite = @idActivite
	)
	group by TABLE_NAME
	having count(COLUMN_NAME)=(
								SELECT count(distinct CONCAT('ID_DIM_',dbo.axes.nomAxe))--ID_DIM_
								FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
								WHERE dbo.axes.idAxe = dbo.questions.idAxe and 
								  dbo.questions.idQuestion = dbo.questionnaire.idQuestion and 
								  dbo.questionnaire.typeParam <> 'null' and
								  dbo.questionnaire.idActivite = dbo.activites.idActivite and dbo.axes.type ='DIMENSION' and
								  --dbo.activites.idActivite = @idActivite --par
								  dbo.activites.idActivite = @idActivite
								)

RETURN @NOMFAIT;

END
GO
/****** Object:  Table [dbo].[activites]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[activites](
	[idActivite] [int] NOT NULL,
	[nomActivite] [varchar](255) NULL,
	[description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idActivite] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[activitesutilisateurs]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[activitesutilisateurs](
	[idActivite] [int] NOT NULL,
	[matricule] [varchar](255) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[axes]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[axes](
	[idAxe] [int] NOT NULL,
	[nomAxe] [varchar](255) NULL,
	[type] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idAxe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DIM_LOCALISATION]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIM_LOCALISATION](
	[ID_DIM_LOCALISATION] [int] IDENTITY(1,1) NOT NULL,
	[COMMUNE] [varchar](255) NULL,
	[QUARTIER] [varchar](255) NULL,
	[SECTEUR] [varchar](255) NULL,
	[ZONE] [varchar](255) NULL,
 CONSTRAINT [PK_ID_LOCALISATION] PRIMARY KEY CLUSTERED 
(
	[ID_DIM_LOCALISATION] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DIM_PDV]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIM_PDV](
	[ID_DIM_PDV] [int] IDENTITY(1,1) NOT NULL,
	[CONTACT] [varchar](255) NULL,
	[NOM] [varchar](255) NULL,
	[TYPE_PDV] [varchar](255) NULL,
 CONSTRAINT [PK_ID_PDV] PRIMARY KEY CLUSTERED 
(
	[ID_DIM_PDV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DIM_PRODUIT]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DIM_PRODUIT](
	[ID_DIM_PRODUIT] [int] IDENTITY(1,1) NOT NULL,
	[LIB_PRODUIT] [varchar](255) NULL,
 CONSTRAINT [PK_ID_PRODUIT] PRIMARY KEY CLUSTERED 
(
	[ID_DIM_PRODUIT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FP_COMMANDO_BTQ]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FP_COMMANDO_BTQ](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_SEQ] [int] NOT NULL,
	[ID_DEVICE] [varchar](255) NOT NULL,
	[ID_DIM_LOCALISATION] [int] NULL,
	[ID_DIM_PDV] [int] NULL,
	[ID_DIM_PRODUIT] [int] NULL,
	[ACHAT_PDV] [int] NULL,
	[PRESENCE] [varchar](5) NULL,
 CONSTRAINT [PK_FP_ID_SEQ_ID_DEVICE_COMMANDO_BTQ] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ID_SEQ] ASC,
	[ID_DEVICE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FSP_COMMANDO_BTQ]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FSP_COMMANDO_BTQ](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_SEQ] [int] NOT NULL,
	[ID_DEVICE] [varchar](255) NOT NULL,
	[ID_DIM_LOCALISATION] [int] NULL,
	[ID_DIM_PDV] [int] NULL,
 CONSTRAINT [PK_FSP_ID_SEQ_ID_DEVICE_COMMANDO_BTQ] PRIMARY KEY CLUSTERED 
(
	[ID] ASC,
	[ID_SEQ] ASC,
	[ID_DEVICE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[questionnaire]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[questionnaire](
	[idQuestionnaire] [int] NOT NULL,
	[idQuestion] [int] NOT NULL,
	[idTypeReponsePossible] [varchar](255) NOT NULL,
	[numQuestion] [int] NULL,
	[numGroupe] [int] NULL,
	[numBoucle] [int] NULL,
	[obligatoire] [int] NULL,
	[objetReponse] [varchar](255) NULL,
	[idActivite] [int] NOT NULL,
	[Param1] [varchar](255) NULL,
	[valeurParam1] [varchar](255) NULL,
	[Param2] [varchar](255) NULL,
	[valeurParam2] [varchar](255) NULL,
	[Param3] [varchar](255) NULL,
	[valeurParam3] [varchar](255) NULL,
	[typeParam] [varchar](255) NULL,
	[libelle] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idQuestionnaire] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[questions]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[questions](
	[idQuestion] [int] NOT NULL,
	[idAxe] [int] NULL,
	[corpsQuestion] [varchar](255) NULL,
	[propriete] [varchar](255) NULL,
	[typeQuestion] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idQuestion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reponsepossibles]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reponsepossibles](
	[idReponsePossible] [varchar](255) NOT NULL,
	[valeur] [varchar](255) NULL,
	[indexVal] [int] NULL,
	[idTypeReponsePossible] [varchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[idReponsePossible] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[reponses]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[reponses](
	[idReponse] [int] NOT NULL,
	[idQuestionnaire] [int] NOT NULL,
	[valeurText] [varchar](255) NULL,
	[valeurNum] [decimal](18, 0) NULL,
	[matricule] [varchar](255) NOT NULL,
	[sequenceRep] [int] NOT NULL,
	[Param1] [varchar](255) NULL,
	[valeurParam1] [varchar](255) NULL,
	[Param2] [varchar](255) NULL,
	[valeurParam2] [varchar](255) NULL,
	[Param3] [varchar](255) NULL,
	[valeurParam3] [varchar](255) NULL,
	[dateSave] [datetime] NULL,
	[traiter] [int] NOT NULL,
	[champParam1] [varchar](255) NULL,
	[champParam2] [varchar](255) NULL,
	[champParam3] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idReponse] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[typereponsepossibles]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[typereponsepossibles](
	[idTypeReponsePossible] [varchar](255) NOT NULL,
	[description] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[idTypeReponsePossible] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[utilisateurs]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[utilisateurs](
	[matricule] [varchar](255) NOT NULL,
	[nom] [varchar](255) NULL,
	[prenom] [varchar](255) NULL,
	[email] [varchar](255) NULL,
	[motDePasse] [varchar](255) NULL,
	[type] [varchar](255) NULL,
	[lieu_travail] [varchar](255) NULL,
PRIMARY KEY CLUSTERED 
(
	[matricule] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[reponses] ADD  DEFAULT ((0)) FOR [traiter]
GO
ALTER TABLE [dbo].[activitesutilisateurs]  WITH CHECK ADD  CONSTRAINT [activites_idActivite_new_fk] FOREIGN KEY([idActivite])
REFERENCES [dbo].[activites] ([idActivite])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[activitesutilisateurs] CHECK CONSTRAINT [activites_idActivite_new_fk]
GO
ALTER TABLE [dbo].[activitesutilisateurs]  WITH CHECK ADD  CONSTRAINT [utilisateurs_idActivite_new_fk] FOREIGN KEY([matricule])
REFERENCES [dbo].[utilisateurs] ([matricule])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[activitesutilisateurs] CHECK CONSTRAINT [utilisateurs_idActivite_new_fk]
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ]  WITH CHECK ADD  CONSTRAINT [DIM_PRODUIT_ID_DIM_PRODUIT_fk] FOREIGN KEY([ID_DIM_PRODUIT])
REFERENCES [dbo].[DIM_PRODUIT] ([ID_DIM_PRODUIT])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ] CHECK CONSTRAINT [DIM_PRODUIT_ID_DIM_PRODUIT_fk]
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ]  WITH CHECK ADD  CONSTRAINT [P_DIM_LOCALISATION_ID_DIM_LOCALISATION_fk] FOREIGN KEY([ID_DIM_LOCALISATION])
REFERENCES [dbo].[DIM_LOCALISATION] ([ID_DIM_LOCALISATION])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ] CHECK CONSTRAINT [P_DIM_LOCALISATION_ID_DIM_LOCALISATION_fk]
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ]  WITH CHECK ADD  CONSTRAINT [P_DIM_PDV_ID_DIM_PDV_fk] FOREIGN KEY([ID_DIM_PDV])
REFERENCES [dbo].[DIM_PDV] ([ID_DIM_PDV])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FP_COMMANDO_BTQ] CHECK CONSTRAINT [P_DIM_PDV_ID_DIM_PDV_fk]
GO
ALTER TABLE [dbo].[FSP_COMMANDO_BTQ]  WITH CHECK ADD  CONSTRAINT [DIM_LOCALISATION_ID_DIM_LOCALISATION_fk] FOREIGN KEY([ID_DIM_LOCALISATION])
REFERENCES [dbo].[DIM_LOCALISATION] ([ID_DIM_LOCALISATION])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FSP_COMMANDO_BTQ] CHECK CONSTRAINT [DIM_LOCALISATION_ID_DIM_LOCALISATION_fk]
GO
ALTER TABLE [dbo].[FSP_COMMANDO_BTQ]  WITH CHECK ADD  CONSTRAINT [DIM_PDV_ID_DIM_PDV_fk] FOREIGN KEY([ID_DIM_PDV])
REFERENCES [dbo].[DIM_PDV] ([ID_DIM_PDV])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FSP_COMMANDO_BTQ] CHECK CONSTRAINT [DIM_PDV_ID_DIM_PDV_fk]
GO
ALTER TABLE [dbo].[questionnaire]  WITH CHECK ADD  CONSTRAINT [activite_idActivite_fk] FOREIGN KEY([idActivite])
REFERENCES [dbo].[activites] ([idActivite])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[questionnaire] CHECK CONSTRAINT [activite_idActivite_fk]
GO
ALTER TABLE [dbo].[questionnaire]  WITH CHECK ADD  CONSTRAINT [new_typereponsepossible_idTypeReponsePossible_fk] FOREIGN KEY([idTypeReponsePossible])
REFERENCES [dbo].[typereponsepossibles] ([idTypeReponsePossible])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[questionnaire] CHECK CONSTRAINT [new_typereponsepossible_idTypeReponsePossible_fk]
GO
ALTER TABLE [dbo].[questionnaire]  WITH CHECK ADD  CONSTRAINT [question_idQuestion_fk] FOREIGN KEY([idQuestion])
REFERENCES [dbo].[questions] ([idQuestion])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[questionnaire] CHECK CONSTRAINT [question_idQuestion_fk]
GO
ALTER TABLE [dbo].[questions]  WITH CHECK ADD  CONSTRAINT [axe_idAxe_fk] FOREIGN KEY([idAxe])
REFERENCES [dbo].[axes] ([idAxe])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[questions] CHECK CONSTRAINT [axe_idAxe_fk]
GO
ALTER TABLE [dbo].[reponsepossibles]  WITH CHECK ADD  CONSTRAINT [typereponsepossible_idTypeReponsePossible_fk] FOREIGN KEY([idTypeReponsePossible])
REFERENCES [dbo].[typereponsepossibles] ([idTypeReponsePossible])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[reponsepossibles] CHECK CONSTRAINT [typereponsepossible_idTypeReponsePossible_fk]
GO
ALTER TABLE [dbo].[reponses]  WITH CHECK ADD  CONSTRAINT [questionnaire_idQuestionnaire_fk] FOREIGN KEY([idQuestionnaire])
REFERENCES [dbo].[questionnaire] ([idQuestionnaire])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[reponses] CHECK CONSTRAINT [questionnaire_idQuestionnaire_fk]
GO
ALTER TABLE [dbo].[reponses]  WITH CHECK ADD  CONSTRAINT [utilisateurs_matricule_fk] FOREIGN KEY([matricule])
REFERENCES [dbo].[utilisateurs] ([matricule])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[reponses] CHECK CONSTRAINT [utilisateurs_matricule_fk]
GO
/****** Object:  StoredProcedure [dbo].[Create_DWH]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Create_DWH]   
  (@idActivite int )
AS     
BEGIN
--Déclaration des variables
DECLARE @v_ID integer;
DECLARE @v_IdDevice varchar(100);
DECLARE @v_DIM varchar(100);
DECLARE @v_attribut varchar(100);
DECLARE @v_propriete varchar(255);
DECLARE @v_valeurText varchar(255);
DECLARE @v_valeurNum decimal;
DECLARE @sqlQueryCreateTable NVARCHAR(MAX);
DECLARE @sqlQueryInsertTable NVARCHAR(MAX);
DECLARE @sqlQueryAlterTable NVARCHAR(MAX);
DECLARE @sqlQueryUpdateTable NVARCHAR(MAX);
DECLARE @sqlQuerySelect NVARCHAR(MAX);
DECLARE @nbrLigne integer;

--Déclaration du curseur
DECLARE My_Cursor CURSOR FOR
SELECT dbo.reponses.sequenceRep as id,dbo.reponses.matricule as idDevice, dbo.axes.nomAxe as dimension, dbo.questions.corpsQuestion as attribut,
	   dbo.questions.type as propriete,dbo.reponses.valeurText as valeurText, 
	   dbo.reponses.valeurNum as valeurNum
FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire,dbo.reponses
WHERE dbo.axes.idAxe = dbo.questions.idAxe and 
  dbo.questions.idQuestion = dbo.questionnaire.idQuestion and 
  dbo.reponses.idQuestionnaire = dbo.questionnaire.idQuestionnaire and 
  dbo.questionnaire.idActivite = dbo.activites.idActivite and 
  dbo.activites.idActivite = @idActivite ORDER BY id ASC;

-- Ouverture du curseur 
OPEN My_Cursor;

-- Assignation des valeurs aux variables
FETCH NEXT FROM My_Cursor INTO @v_ID,@v_IdDevice,@v_DIM,@v_attribut,@v_propriete,@v_valeurText,@v_valeurNum;

WHILE @@FETCH_STATUS = 0
BEGIN
-- Vérifier si la table existe 
	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name= @v_DIM AND xtype='U')
		BEGIN
		print ' creation de table';
			-- Création de la table
			SET @sqlQueryCreateTable = N'CREATE TABLE ' + @v_DIM + '(
			  Id_Seq INTEGER NOT NULL, 
			  Id_Device VARCHAR(255) NOT NULL,
			  CONSTRAINT PK_Id_Seq_Id_Device_'+@v_DIM+' PRIMARY KEY (ID_Seq, ID_Device) );' ;
			
			-- Execution de la requete de creation
			EXEC sp_executesql @sqlQueryCreateTable;
			
			--Ajout de l'ID dans la table
			SET @sqlQueryInsertTable = N'INSERT INTO dbo.'+@v_DIM+' (ID_Seq,ID_Device) VALUES (@v_ID,@v_IdDevice);'
			
			--Execution
			EXEC sp_executesql @sqlQueryInsertTable, N'@v_ID INT,@v_IdDevice VARCHAR(255)',@v_ID,@v_IdDevice;
		END
	
-- Vérifier si la colonne existe	
	IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @v_DIM AND COLUMN_NAME = @v_attribut)
		BEGIN
			print ' colonne existe pas';
			--Ajoute d'une nouvelle colonne
			SET @sqlQueryAlterTable = N'ALTER TABLE dbo.'+@v_DIM+' ADD '+@v_attribut+' '+@v_propriete +';' ;
		
			--Execution de l'ajout
			EXEC sp_executesql @sqlQueryAlterTable;

			--Ajoute de la valeur text
			IF @v_valeurText <> 'null'
			BEGIN
				SET @sqlQueryUpdateTable = N'UPDATE dbo.'+@v_DIM+' SET '+@v_attribut+'= @v_valeurText WHERE dbo.'+@v_DIM+'.ID_Seq = @v_ID AND dbo.'+@v_DIM+'.ID_Device = @v_IdDevice ;' ;
				EXEC sp_executesql @sqlQueryUpdateTable, N'@v_valeurText varchar(255), @v_ID INT, @v_IdDevice VARCHAR(255)',@v_valeurText,@v_ID,@v_IdDevice;
			END
			--Ajoute de la valeur numérique
			IF @v_valeurText = 'null'
			BEGIN
				SET @sqlQueryUpdateTable = N'UPDATE dbo.'+@v_DIM+' SET '+@v_attribut+'= @v_valeurNum WHERE dbo.'+@v_DIM+'.ID_Seq = @v_ID AND dbo.'+@v_DIM+'.ID_Device = @v_IdDevice ;' ;
				EXEC sp_executesql @sqlQueryUpdateTable, N'@v_valeurNum INT,@v_ID INT,@v_IdDevice VARCHAR(255)',@v_valeurNum,@v_ID,@v_IdDevice ;
			END
			
		END
	ELSE  --La colonne existe
		BEGIN
			--Insert if not exist new key 
			SET @sqlQueryInsertTable = 'IF NOT EXISTS (SELECT * FROM '+@v_DIM+' WHERE Id_Seq = @v_ID AND Id_Device =@v_IdDevice)
			BEGIN INSERT INTO dbo.'+@v_DIM+' (Id_Seq,Id_Device) VALUES (@v_ID,@v_IdDevice); END'
			EXEC sp_executesql @sqlQueryInsertTable, N'@v_ID INT,@v_IdDevice VARCHAR(255)',@v_ID,@v_IdDevice;
		  
		  --Insert if not exist new colonne values
		  IF @v_valeurText <> 'null'
			BEGIN
				SET @sqlQueryUpdateTable = N'UPDATE dbo.'+@v_DIM+' SET '+@v_attribut+'= @v_valeurText WHERE dbo.'+@v_DIM+'.ID_Seq = @v_ID AND dbo.'+@v_DIM+'.ID_Device = @v_IdDevice ;' ;
				EXEC sp_executesql @sqlQueryUpdateTable, N'@v_valeurText varchar(255), @v_ID INT, @v_IdDevice VARCHAR(255)',@v_valeurText,@v_ID,@v_IdDevice;
			END
			--Ajoute de la valeur numérique
			IF @v_valeurText = 'null'
			BEGIN
				SET @sqlQueryUpdateTable = N'UPDATE dbo.'+@v_DIM+' SET '+@v_attribut+'= @v_valeurNum WHERE dbo.'+@v_DIM+'.ID_Seq = @v_ID AND dbo.'+@v_DIM+'.ID_Device = @v_IdDevice ;' ;
				EXEC sp_executesql @sqlQueryUpdateTable, N'@v_valeurNum INT,@v_ID INT,@v_IdDevice VARCHAR(255)',@v_valeurNum,@v_ID,@v_IdDevice ;
			END
			

		END
FETCH NEXT FROM My_Cursor INTO @v_ID,@v_IdDevice,@v_DIM,@v_attribut,@v_propriete,@v_valeurText,@v_valeurNum; 

END
CLOSE My_Cursor;
DEALLOCATE My_Cursor;

END
GO
/****** Object:  StoredProcedure [dbo].[DATA_MIGRATION_V1]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DATA_MIGRATION_V1]
	(@idActivite int )	
AS
BEGIN
--DECLARATION DES VARIABLES
 DECLARE @v_nomActivite VARCHAR(255); 
 DECLARE @v_IdSeq INTEGER;
 DECLARE @v_IdDevice VARCHAR(255);
 DECLARE @v_Dim VARCHAR(50);
 DECLARE @v_ID_DIM INTEGER;
 DECLARE @var_ID_DIM INTEGER;
 DECLARE @val_ID INTEGER;
 DECLARE @val_ID_DIM INTEGER;

 DECLARE @v_IdSeqCol INTEGER;
 DECLARE @v_Attribut varchar(100);
 DECLARE @v_valeurText varchar(255);
 DECLARE @v_valeurNum decimal;
 DECLARE @v_NumQ INTEGER;

 DECLARE @f_Attribut varchar(100);
 DECLARE @f_valeurText varchar(255);
 DECLARE @f_valeurNum decimal;

 DECLARE @v_P1 varchar(100);
 DECLARE @v_C1 varchar(100);
 DECLARE @v_V1 varchar(100);
 DECLARE @v_P2 varchar(100);
 DECLARE @v_C2 varchar(100);
 DECLARE @v_V2 varchar(100);
 DECLARE @v_P3 varchar(100);
 DECLARE @v_C3 varchar(100);
 DECLARE @v_V3 varchar(100);

 DECLARE @v_InsertCol1 NVARCHAR(MAX);
 DECLARE @v_InsertVal1 NVARCHAR(MAX);
 DECLARE @v_InsertCol2 NVARCHAR(MAX);
 DECLARE @v_InsertVal2 NVARCHAR(MAX);
 DECLARE @v_InsertCol3 NVARCHAR(MAX);
 DECLARE @v_InsertVal3 NVARCHAR(MAX);
 DECLARE @v_InsertCol4 NVARCHAR(MAX);
 DECLARE @v_InsertVal4 NVARCHAR(MAX);
 DECLARE @v_InsertCol5 NVARCHAR(MAX);
 DECLARE @v_InsertVal5 NVARCHAR(MAX);

 DECLARE @v_InsertCol3_P1 NVARCHAR(MAX);
 DECLARE @v_InsertVal3_P1 NVARCHAR(MAX);
 DECLARE @v_InsertCol3_P2 NVARCHAR(MAX);
 DECLARE @v_InsertVal3_P2 NVARCHAR(MAX);
 DECLARE @v_InsertCol3_P3 NVARCHAR(MAX);
 DECLARE @v_InsertVal3_P3 NVARCHAR(MAX);


 DECLARE @str_COL NVARCHAR(MAX);;
 DECLARE @str_COL_lite NVARCHAR(MAX);
 DECLARE @str_Values NVARCHAR(MAX);
 DECLARE @str_Values_lite NVARCHAR(MAX);

 DECLARE @v_Col varchar(255);

 DECLARE @str_COLND NVARCHAR(MAX);
 DECLARE @str_VCOLND NVARCHAR(MAX);

 DECLARE @F_colonne NVARCHAR(MAX);
 DECLARE @F_values NVARCHAR(MAX);
 DECLARE @F_colonne_lite NVARCHAR(MAX);
 DECLARE @F_values_lite NVARCHAR(MAX);

 DECLARE @sqlQuerySelect NVARCHAR(MAX);
 DECLARE @sqlQueryInsertTable NVARCHAR(MAX);
 DECLARE @sqlQueryUpdateTable NVARCHAR(MAX);
 DECLARE @sqlQueryDeleteTable NVARCHAR(MAX);

 DECLARE @p_ColonneFait NVARCHAR(MAX);
 DECLARE @p_ValuesFait NVARCHAR(MAX);

 DECLARE @useInsert5 varchar(10);
 DECLARE @noParam varchar(10);

--INITIALISATION	
 SET @v_InsertCol1 = '(';
 SET @v_InsertVal1 = '(';
 SET @v_InsertCol2 = '';
 SET @v_InsertVal2 = '';
 SET @v_InsertCol3 = '';
 SET @v_InsertVal3 = '';
 SET @v_InsertCol4 = '';
 SET @v_InsertVal4 = '';
 SET @v_InsertCol5 = '';
 SET @v_InsertVal5 = '';
 SET @v_ID_DIM = 0;
 SET @p_ColonneFait = '';
 SET @p_ValuesFait = '';

 SET @useInsert5 = 'false';
 SET @noParam = 'false'

--CURSEUR SEQUENCE DE REPONSE ET ID DEVICE
	DECLARE Curseur_seq CURSOR FOR
	SELECT DISTINCT dbo.activites.nomActivite as nomActivite,
		dbo.reponses.sequenceRep as idSeq, dbo.reponses.matricule as idDevice
    FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire,dbo.reponses
    WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
          dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
		  dbo.reponses.idQuestionnaire = dbo.questionnaire.idQuestionnaire AND
		  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.reponses.traiter = 0 AND
		  dbo.activites.idActivite = @idActivite ORDER BY idSeq ASC;
	OPEN Curseur_seq;
    FETCH NEXT FROM Curseur_seq INTO @v_nomActivite,@v_IdSeq,@v_IdDevice
  
    WHILE @@FETCH_STATUS = 0
    BEGIN
		SET @v_InsertCol1 = @v_InsertCol1+'ID_SEQ,ID_DEVICE,';
		SET @v_InsertVal1 = @v_InsertVal1+CONCAT(@v_IdSeq,',''',@v_IdDevice,''',');
	
	--CURSEUR DIMENSION SANS PARAMETRE PAR RAPPORT AUX SEQUENCES DE REPONSE ET ID DEVICE
		 DECLARE Curseur_Dim CURSOR FOR
		 SELECT DISTINCT dbo.axes.nomAxe as dimension
		 FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire,dbo.reponses
		 WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
			dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
			dbo.axes.type = 'DIMENSION' AND dbo.questionnaire.typeParam = 'null' AND
			dbo.reponses.idQuestionnaire = dbo.questionnaire.idQuestionnaire AND
			dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
			dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.reponses.traiter = 0 AND
			dbo.activites.idActivite = @idActivite ;
		 OPEN Curseur_Dim;
		 FETCH NEXT FROM Curseur_Dim INTO @v_Dim
  
		 WHILE @@FETCH_STATUS = 0
		 BEGIN
			--INITIALISATION DES STR
			SET @str_COL = '(';
			SET @str_COL_lite = 'CONCAT(';
			SET @str_Values = '(';
			SET @str_Values_lite = '';
			SET @str_COLND = '';
			SET @str_VCOLND = '';
			
			--CURSEUR DES COLONNES
			DECLARE Curseur_Colonne CURSOR FOR
			SELECT DISTINCT dbo.reponses.sequenceRep as idSeq, dbo.questions.corpsQuestion as attribut,
	                dbo.reponses.valeurText as valeurText, dbo.reponses.valeurNum as valeurNum,
	                dbo.questionnaire.numQuestion as numQ
			FROM  dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire,dbo.reponses
			WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
				  dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
				  dbo.reponses.idQuestionnaire = dbo.questionnaire.idQuestionnaire AND
				  dbo.axes.type = 'DIMENSION' AND dbo.questionnaire.typeParam = 'null' AND
				  dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
				  CONCAT('dbo.DIM_',dbo.axes.nomAxe) = CONCAT('dbo.DIM_',@v_Dim) AND
				  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.reponses.traiter = 0 AND
				  dbo.activites.idActivite = @idActivite ORDER BY idSeq,numQ ASC;
			OPEN Curseur_Colonne;
			FETCH NEXT FROM Curseur_Colonne INTO @v_IdSeqCol,@v_Attribut,@v_valeurText,@v_valeurNum, @v_NumQ
  
			WHILE @@FETCH_STATUS = 0
			BEGIN
			--CONCATENATION DES COLONNES
				
				SET @str_COL = @str_COL+@v_Attribut+',';
				SET @str_COL_lite = @str_COL_lite+@v_Attribut+',';
				
			--CONCATENATION DES VALEURS
				IF @v_valeurText <> 'null'
				--Ajoute de la valeur texte
				BEGIN
					SET @str_Values = @str_Values+CONCAT('''',@v_valeurText,''',') ;--@v_valeurText+',';
					SET @str_Values_lite = @str_Values_lite+@v_valeurText;
				END
				
				IF @v_valeurText = 'null'
				BEGIN
					SET @str_Values = @str_Values+@v_valeurNum+','; --A échapper
					SET @str_Values_lite = @str_Values_lite+@v_valeurNum+','; --A échapper
				END

			FETCH NEXT FROM Curseur_Colonne INTO @v_IdSeqCol,@v_Attribut,@v_valeurText,@v_valeurNum, @v_NumQ
			END
			CLOSE Curseur_Colonne
		    DEALLOCATE Curseur_Colonne
			
			PRINT 'str col '+@str_COL;
			PRINT 'str col lite '+@str_COL_lite;

			DECLARE Curseur_ColonneNonDef CURSOR FOR
			SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
			WHERE TABLE_NAME = CONCAT('DIM_',@v_Dim) AND COLUMN_NAME <> CONCAT('ID_DIM_',@v_Dim) AND
			CONCAT(TABLE_NAME,COLUMN_NAME) NOT IN(
				SELECT DISTINCT CONCAT('DIM_',dbo.axes.nomAxe,dbo.questions.corpsQuestion) as attribut
				FROM   
					dbo.axes
					INNER JOIN dbo.questions ON dbo.axes.idAxe = dbo.questions.idAxe
					INNER JOIN dbo.questionnaire ON dbo.questions.idQuestion = dbo.questionnaire.idQuestion
					INNER JOIN dbo.reponses ON dbo.reponses.idQuestionnaire = dbo.questionnaire.idQuestionnaire
					INNER JOIN dbo.activites on dbo.questionnaire.idActivite = dbo.activites.idActivite
				WHERE 
					dbo.axes.type = 'DIMENSION' AND dbo.questionnaire.typeParam = 'null' AND
					dbo.reponses.traiter = 0 AND
					dbo.activites.idActivite = @idActivite --ORDER BY id,numQ ASC
					and dbo.reponses.sequenceRep = @v_IdSeq
					)
			OPEN Curseur_ColonneNonDef
			FETCH NEXT FROM Curseur_ColonneNonDef INTO @v_Col
	
			WHILE @@FETCH_STATUS = 0
			BEGIN
				--CHAINE DES COLONNES NON DEFINIES
				SET @str_COLND = @str_COLND+@v_Col+',';
				SET @str_VCOLND = @str_VCOLND+''''',' ;
			FETCH NEXT FROM Curseur_ColonneNonDef INTO @v_Col
			END

			CLOSE Curseur_ColonneNonDef
			DEALLOCATE Curseur_ColonneNonDef

			--CONCATENATION FINALE
			SET @F_colonne = @str_COL
			SET @F_values = @str_Values;
			SET @F_colonne_lite = @str_COL_lite;
			SET @F_values_lite = @str_Values_lite;

			--SUPPRESSION DE LA VIRGULE DE FIN
			SET @F_colonne = SUBSTRING(@F_colonne, 1, (LEN(@F_colonne)-1));
			SET @F_colonne_lite = SUBSTRING(@F_colonne_lite, 1, (LEN(@F_colonne_lite)-1));
			SET @F_values = SUBSTRING(@F_values, 1, (LEN(@F_values)-1));
			
			-- FERMETURE DES PARENTHESE
			SET @F_colonne = @F_colonne+')';
			SET @F_colonne_lite = @F_colonne_lite+')';
			SET @F_values = @F_values+')';
			
			--AFFICHAGE
			PRINT 'Col == '+@F_colonne;
			PRINT 'Val == '+@F_values_lite;
			PRINT 'F val == '+@F_values;
			
			--VERIFICATION DE L'EXISTENCE DE L'ENREGISTREMENT DANS LA TABLE
			SET @sqlQuerySelect = CONCAT('SELECT @v_ID_DIM = dbo.DIM_',@v_Dim,'.','ID_DIM_',@v_Dim,' FROM dbo.DIM_',@v_Dim,' WHERE ',@F_colonne_lite,'=''',@F_values_lite,'''');
			print @sqlQuerySelect;
			EXEC sp_executesql @sqlQuerySelect, N'@v_ID_DIM int OUTPUT',@v_ID_DIM  OUTPUT;
			
			--PRINT 'ID vaut '+CAST(@v_ID_DIM as VARCHAR(255));
			IF @v_ID_DIM = 0
				BEGIN
				--INSERTION
					SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_Dim,@F_colonne,' VALUES ',@F_values,';  COMMIT;');
					PRINT @sqlQueryInsertTable;
					EXEC sp_executesql @sqlQueryInsertTable;

				--RECUPERATION DE L'ID D'INSERTION
					SET @sqlQuerySelect = CONCAT('SELECT @var_ID_DIM = dbo.DIM_',@v_Dim,'.','ID_DIM_',@v_Dim,' FROM dbo.DIM_',@v_Dim,' WHERE ',@F_colonne_lite,'=''',@F_values_lite,'''');
					EXEC sp_executesql @sqlQuerySelect, N'@var_ID_DIM int output',@var_ID_DIM OUTPUT;
					PRINT @sqlQuerySelect;

					SET @v_InsertCol2 = @v_InsertCol2+CONCAT('ID_DIM_',@v_Dim,',');
					SET @v_InsertVal2 = @v_InsertVal2+CONCAT(@var_ID_DIM,',');
				END
			ELSE
				BEGIN
					 SET @v_InsertCol2 = @v_InsertCol2+CONCAT('ID_DIM_',@v_Dim,',');
					 SET @v_InsertVal2 = @v_InsertVal2+CONCAT(@v_ID_DIM,',');
				END
		 
		 FETCH NEXT FROM Curseur_Dim INTO @v_Dim
		 END
		 CLOSE Curseur_Dim
		 DEALLOCATE Curseur_Dim
		 --A cette étape nous devons avoir les idDim dans les Dim concerner

	--CURSEUR DES FAIT DE DIMENSION SANS PARAMETRE
	DECLARE Curseur_FAIT CURSOR FOR
	SELECT DISTINCT  dbo.questions.corpsQuestion , dbo.reponses.valeurText, dbo.reponses.valeurNum 
	FROM dbo.questionnaire, dbo.reponses, dbo.activites,dbo.axes, dbo.questions
	WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questionnaire.typeParam = 'null' AND
		dbo.axes.type = 'FAIT'  AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
		dbo.questionnaire.idActivite = dbo.activites.idActivite AND 
		dbo.questionnaire.idQuestionnaire = dbo.reponses.idQuestionnaire 
		AND dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice
		AND dbo.activites.idActivite = @idActivite AND dbo.reponses.traiter = 0
	 OPEN Curseur_FAIT
	 FETCH NEXT FROM Curseur_FAIT INTO @v_Attribut, @v_valeurText, @v_valeurNum
	 WHILE @@FETCH_STATUS = 0
	 BEGIN
		--PRINT 'IS not null'
			IF @v_valeurText <> 'null'
			BEGIN
				SET @v_InsertCol5 = @v_InsertCol5+ CONCAT(@v_Attribut,',') ;
				SET @v_InsertVal5 = @v_InsertVal5+ CONCAT('''',@v_valeurText,''',') ;
				SET @useInsert5 = 'true'; --Pour dire que le fait n'est pas lier à un parametre 
			END
				
			IF @v_valeurText = 'null'
			BEGIN
				SET @v_InsertCol5 = @v_InsertCol5+ CONCAT(@v_Attribut,',') ;
				SET @v_InsertVal5 = @v_InsertVal5+ CONCAT(@v_valeurNum,',') ;
				SET @useInsert5 = 'true'; --Pour dire que le fait n'est pas lier à un parametre 
			END
	 FETCH NEXT FROM Curseur_FAIT INTO @v_Attribut, @v_valeurText, @v_valeurNum
	 END

	 CLOSE Curseur_FAIT
	 DEALLOCATE Curseur_FAIT
			
		
	--
	--
	--
	--CURSEUR DIMENSION AVEC PARAMETRE PAR RAPPORT AUX SEQUENCES DE REPONSE ET ID DEVICE
	 DECLARE Curseur_Dim_P CURSOR FOR
	SELECT DISTINCT dbo.reponses.Param1 as P1, dbo.reponses.champParam1 as C1, dbo.reponses.valeurParam1 as V1,
			dbo.reponses.Param2 as P2, dbo.reponses.champParam2 as C2, dbo.reponses.valeurParam2 as V2,
			dbo.reponses.Param3 as P3,dbo.reponses.champParam3 as C3, dbo.reponses.valeurParam3 as V3
	FROM dbo.questionnaire, dbo.reponses, dbo.activites,dbo.axes, dbo.questions
	WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questionnaire.typeParam <> 'null' AND
		dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND --Precisier fait
		dbo.questionnaire.idActivite = dbo.activites.idActivite AND 
		dbo.questionnaire.idQuestionnaire = dbo.reponses.idQuestionnaire AND dbo.reponses.traiter = 0 AND
		dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
		dbo.activites.idActivite = @idActivite  
	 OPEN Curseur_Dim_P;
	 FETCH NEXT FROM Curseur_Dim_P INTO @v_P1,@v_C1,@v_V1, @v_P2,@v_C2,@v_V2, @v_P3,@v_C3,@v_V3
	 WHILE @@FETCH_STATUS = 0
	 BEGIN
		 SET @v_InsertCol3 = '';
		 SET @v_InsertVal3 = '';
		 SET @v_InsertCol3_P1 = '';
		 SET @v_InsertVal3_P1 = '';
		 SET @v_InsertCol3_P2 = '';
		 SET @v_InsertVal3_P2 = '';
		 SET @v_InsertCol3_P3 = '';
		 SET @v_InsertVal3_P3 = '';

		 SET @v_InsertCol4 = '';
		 SET @v_InsertVal4 = '';
		 IF @v_P1 <> 'aucun' AND @v_P2 = 'aucun' AND @v_P3 = 'aucun' 
			BEGIN
				SET @noParam = 'true' --Ca veut dire que nous somme rentrer ici
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,')',' VALUES (''',@v_V1,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'=''',@v_V1,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID,',');

					END

				--CURSEUR DES MESURES LIER AUX PARAMETRES
				DECLARE Curseur_Mesure_P CURSOR FOR
				SELECT DISTINCT 
					dbo.questions.corpsQuestion as attribut, 
					dbo.reponses.valeurText as valeurText, dbo.reponses.valeurNum as valeurNum 
				FROM dbo.questionnaire, dbo.reponses, dbo.activites,dbo.axes, dbo.questions
				WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questionnaire.typeParam <> 'null' AND
					dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
					dbo.questionnaire.idActivite = dbo.activites.idActivite AND 
					dbo.questionnaire.idQuestionnaire = dbo.reponses.idQuestionnaire AND 
					dbo.reponses.Param1 = @v_P1 AND dbo.reponses.champParam1 = @v_C1 AND dbo.reponses.valeurParam1 = @v_V1 AND
					dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
					dbo.activites.idActivite = @idActivite AND dbo.reponses.traiter = 0
				OPEN Curseur_Mesure_P;
				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
  
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @v_valeurText <> 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT('''',@v_valeurText,''',') ;
						END
				
						IF @v_valeurText = 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT(@v_valeurNum,',') ;
						END

				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
				END

				CLOSE Curseur_Mesure_P
				DEALLOCATE Curseur_Mesure_P
			END

		 IF @v_P1 <> 'aucun' AND @v_P2 <> 'aucun' AND @v_P3 = 'aucun'
		 BEGIN
			SET @noParam = 'true' --Ca veut dire que nous somme rentrer ici
			IF @v_P1 = @v_P2
			BEGIN
				--Insert P1P2
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,',',@v_C2,')',' VALUES (''',@v_V1,''',''',@v_V2,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID,',');
					END
				
			END
			ELSE
			BEGIN
				--Insert P1
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,')',' VALUES (''',@v_V1,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'=''',@v_V1,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID,',');

					END
				
				--Insert P2
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P2,'.ID_DIM_',@v_P2,
									' FROM dbo.DIM_',@v_P2,' WHERE ',@v_C2,'= ''',@v_V2,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P2,' (',@v_C2,')',' VALUES (''',@v_V2,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P2,'.','ID_DIM_',@v_P2,' FROM dbo.DIM_',@v_P2,' WHERE ',@v_C2,'=''',@v_V2,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P2 = @v_InsertCol3_P2+CONCAT('ID_DIM_',@v_P2,',');
						SET @v_InsertVal3_P2 = @v_InsertVal3_P2+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P2 = @v_InsertCol3_P2+CONCAT('ID_DIM_',@v_P2,',');
						SET @v_InsertVal3_P2 = @v_InsertVal3_P2+CONCAT(@val_ID,',');

					END
				--Fusion P1 P2 
				SET @v_InsertCol3 = @v_InsertCol3 + CONCAT(@v_InsertCol3_P1,',',@v_InsertCol3_P2,',')
				SET @v_InsertVal3 = @v_InsertVal3 + CONCAT(@v_InsertVal3_P1,',',@v_InsertVal3_P2,',')

			END
			
			--CURSEUR DES MESURES LIER AUX PARAMETRES
				DECLARE Curseur_Mesure_P CURSOR FOR
				SELECT DISTINCT 
					dbo.questions.corpsQuestion as attribut, 
					dbo.reponses.valeurText as valeurText, dbo.reponses.valeurNum as valeurNum 
				FROM dbo.questionnaire, dbo.reponses, dbo.activites,dbo.axes, dbo.questions
				WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questionnaire.typeParam <> 'null' AND
					dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
					dbo.questionnaire.idActivite = dbo.activites.idActivite AND 
					dbo.questionnaire.idQuestionnaire = dbo.reponses.idQuestionnaire AND 
					dbo.reponses.Param1 = @v_P1 AND dbo.reponses.champParam1 = @v_C1 AND dbo.reponses.valeurParam1 = @v_V1 AND
					dbo.reponses.Param2 = @v_P2 AND dbo.reponses.champParam2 = @v_C2 AND dbo.reponses.valeurParam2 = @v_V2 AND
					
					dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
					dbo.activites.idActivite = @idActivite AND dbo.reponses.traiter = 0
				OPEN Curseur_Mesure_P;
				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
  
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @v_valeurText <> 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT('''',@v_valeurText,''',') ;
						END
				
						IF @v_valeurText = 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT(@v_valeurNum,',') ;
						END

				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
				END

				CLOSE Curseur_Mesure_P
				DEALLOCATE Curseur_Mesure_P

		 END

		 IF @v_P1 <> 'aucun' AND @v_P2 <> 'aucun' AND @v_P3 <> 'aucun'
		 BEGIN
			SET @noParam = 'true' --Ca veut dire que nous somme rentrer ici
			IF @v_P1 = @v_P2 AND @v_P2 = @v_P3
			BEGIN
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,''', AND ',@v_C3,'= ''',@v_V3,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
			
				IF @val_ID = 0
				BEGIN
					SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,',',@v_C2,',',@v_C3,')',' VALUES (''',@v_V1,''',''',@v_V2,''',''',@v_V3,'''); COMMIT;')
					EXEC sp_executesql @sqlQueryInsertTable;
					--print @sqlQueryInsertTable

					--Recuperation de l'ID d'insertion	
					SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,''', AND ',@v_C3,'= ''',@v_V3,'''');
					EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
					PRINT @sqlQuerySelect

					SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
					SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID_DIM,',');
				END
				ELSE
				BEGIN
					SET @v_InsertCol3 = @v_InsertCol3+CONCAT('ID_DIM_',@v_P1,',');
					SET @v_InsertVal3 = @v_InsertVal3+CONCAT(@val_ID,',');
				END
			END

			IF @v_P1 = @v_P2 AND @v_P2 <> @v_P3
			BEGIN
				--Insert P1P2
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,',',@v_C2,')',' VALUES (''',@v_V1,''',''',@v_V2,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,''' AND ',@v_C2,'= ''',@v_V2,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID,',');
					END

				--Insert P3
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P3,'.ID_DIM_',@v_P3,
									' FROM dbo.DIM_',@v_P3,' WHERE ',@v_C3,'= ''',@v_V3,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P3,' (',@v_C3,')',' VALUES (''',@v_V3,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P3,'.','ID_DIM_',@v_P3,' FROM dbo.DIM_',@v_P3,' WHERE ',@v_C3,'=''',@v_V3,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P3 = @v_InsertCol3_P3+CONCAT('ID_DIM_',@v_P3,',');
						SET @v_InsertVal3_P3 = @v_InsertVal3_P3+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P3 = @v_InsertCol3_P3+CONCAT('ID_DIM_',@v_P3,',');
						SET @v_InsertVal3_P3 = @v_InsertVal3_P3+CONCAT(@val_ID,',');

					END

				--Fusion P1P2 P3
				SET @v_InsertCol3 = @v_InsertCol3 + CONCAT(@v_InsertCol3_P1,',',@v_InsertCol3_P3)
				SET @v_InsertVal3 = @v_InsertVal3 + CONCAT(@v_InsertVal3_P1,',',@v_InsertVal3_P3)
			
			END

			IF @v_P1 <> @v_P2 AND @v_P2 <> @v_P3 AND @v_P1 <> @v_P3 
			BEGIN
				--Insert P1
				SET @val_ID = 0;
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P1,'.ID_DIM_',@v_P1,
									' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'= ''',@v_V1,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P1,' (',@v_C1,')',' VALUES (''',@v_V1,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P1,'.','ID_DIM_',@v_P1,' FROM dbo.DIM_',@v_P1,' WHERE ',@v_C1,'=''',@v_V1,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P1 = @v_InsertCol3_P1+CONCAT('ID_DIM_',@v_P1,',');
						SET @v_InsertVal3_P1 = @v_InsertVal3_P1+CONCAT(@val_ID,',');

					END
				
				--Insert P2
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P2,'.ID_DIM_',@v_P2,
									' FROM dbo.DIM_',@v_P2,' WHERE ',@v_C2,'= ''',@v_V2,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P2,' (',@v_C2,')',' VALUES (''',@v_V2,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P2,'.','ID_DIM_',@v_P2,' FROM dbo.DIM_',@v_P2,' WHERE ',@v_C2,'=''',@v_V2,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P2 = @v_InsertCol3_P2+CONCAT('ID_DIM_',@v_P2,',');
						SET @v_InsertVal3_P2 = @v_InsertVal3_P2+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P2 = @v_InsertCol3_P2+CONCAT('ID_DIM_',@v_P2,',');
						SET @v_InsertVal3_P2 = @v_InsertVal3_P2+CONCAT(@val_ID,',');

					END

				--Insert P3
				SET @sqlQuerySelect = CONCAT('SELECT @val_ID = dbo.DIM_',@v_P3,'.ID_DIM_',@v_P3,
									' FROM dbo.DIM_',@v_P3,' WHERE ',@v_C3,'= ''',@v_V3,'''');
				EXEC sp_executesql @sqlQuerySelect, N'@val_ID int OUTPUT',@val_ID  OUTPUT;
				--print @sqlQuerySelect
				IF @val_ID = 0
					BEGIN
						SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO dbo.DIM_',@v_P3,' (',@v_C3,')',' VALUES (''',@v_V3,'''); COMMIT;')
						EXEC sp_executesql @sqlQueryInsertTable;
						--print @sqlQueryInsertTable

						--Recuperation de l'ID d'insertion	
						SET @sqlQuerySelect = CONCAT('SELECT @val_ID_DIM = dbo.DIM_',@v_P3,'.','ID_DIM_',@v_P3,' FROM dbo.DIM_',@v_P3,' WHERE ',@v_C3,'=''',@v_V3,'''');
						EXEC sp_executesql @sqlQuerySelect, N'@val_ID_DIM int output',@val_ID_DIM OUTPUT;
						PRINT @sqlQuerySelect

						SET @v_InsertCol3_P3 = @v_InsertCol3_P3+CONCAT('ID_DIM_',@v_P3,',');
						SET @v_InsertVal3_P3 = @v_InsertVal3_P3+CONCAT(@val_ID_DIM,',');
					END
				ELSE
					BEGIN
						SET @v_InsertCol3_P3 = @v_InsertCol3_P3+CONCAT('ID_DIM_',@v_P3,',');
						SET @v_InsertVal3_P3 = @v_InsertVal3_P3+CONCAT(@val_ID,',');

					END

				--Fusion P1 P2 P3
				SET @v_InsertCol3 = @v_InsertCol3 + CONCAT(@v_InsertCol3_P1,',',@v_InsertCol3_P2,',',@v_InsertCol3_P3)
				SET @v_InsertVal3 = @v_InsertVal3 + CONCAT(@v_InsertVal3_P1,',',@v_InsertVal3_P2,',',@v_InsertVal3_P3)
			END

			--CURSEUR DES MESURES LIER AUX PARAMETRES
				DECLARE Curseur_Mesure_P CURSOR FOR
				SELECT DISTINCT 
					dbo.questions.corpsQuestion as attribut, 
					dbo.reponses.valeurText as valeurText, dbo.reponses.valeurNum as valeurNum 
				FROM dbo.questionnaire, dbo.reponses, dbo.activites,dbo.axes, dbo.questions
				WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questionnaire.typeParam <> 'null' AND
					dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
					dbo.questionnaire.idActivite = dbo.activites.idActivite AND 
					dbo.questionnaire.idQuestionnaire = dbo.reponses.idQuestionnaire AND 
					dbo.reponses.Param1 = @v_P1 AND dbo.reponses.champParam1 = @v_C1 AND dbo.reponses.valeurParam1 = @v_V1 AND
					dbo.reponses.Param2 = @v_P2 AND dbo.reponses.champParam2 = @v_C2 AND dbo.reponses.valeurParam2 = @v_V2 AND
					dbo.reponses.Param3 = @v_P3 AND dbo.reponses.champParam3 = @v_C3 AND dbo.reponses.valeurParam3 = @v_V3 AND
					dbo.reponses.sequenceRep = @v_IdSeq AND dbo.reponses.matricule = @v_IdDevice AND
					dbo.activites.idActivite = @idActivite AND dbo.reponses.traiter = 0
				OPEN Curseur_Mesure_P;
				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
  
				WHILE @@FETCH_STATUS = 0
				BEGIN
					IF @v_valeurText <> 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT('''',@v_valeurText,''',') ;
						END
				
						IF @v_valeurText = 'null'
						BEGIN
							SET @v_InsertCol4 = @v_InsertCol4+ CONCAT(@v_Attribut,',') ;
							SET @v_InsertVal4 = @v_InsertVal4+ CONCAT(@v_valeurNum,',') ;
						END

				FETCH NEXT FROM Curseur_Mesure_P INTO @v_Attribut,@v_valeurText,@v_valeurNum
				END

				CLOSE Curseur_Mesure_P
				DEALLOCATE Curseur_Mesure_P

		 END
	 -- INSERER ICI
	 PRINT '--------------------------------------------AFFICHAGE DES RESULTATS DE SEQUENCE---------------------------';
	 /*PRINT 'Insert col1 vaut ==> '+@v_InsertCol1+' InsertVal1 vaut ===> '+@v_InsertVal1;
	 PRINT 'Insert col2 vaut ==> '+@v_InsertCol2+' InsertVal2 vaut ===> '+@v_InsertVal2;
	 PRINT 'Insert col3 vaut ==> '+@v_InsertCol3+' InsertVal3 vaut ===> '+@v_InsertVal3;
	 PRINT 'Insert col4 vaut ==> '+@v_InsertCol4+' InsertVal4 vaut ===> '+@v_InsertVal4;*/
	 IF @useInsert5 = 'false' AND @noParam = 'true' 
	 BEGIN
		SET @p_ColonneFait = CONCAT(@v_InsertCol1,@v_InsertCol2,@v_InsertCol3,@v_InsertCol4);
		 SET @p_ValuesFait = CONCAT(@v_InsertVal1,@v_InsertVal2,@v_InsertVal3,@v_InsertVal4);
	 
		 --SUPRESSION DE LA VIRGULE DE FIN
		 SET @p_ColonneFait = SUBSTRING(@p_ColonneFait, 1, (LEN(@p_ColonneFait)-1));
		 SET @p_ValuesFait = SUBSTRING(@p_ValuesFait, 1, (LEN(@p_ValuesFait)-1));
	 
		 --FERMETURE DES PARENTHESES
		 SET @p_ColonneFait = CONCAT(@p_ColonneFait,')'); 
		 SET @p_ValuesFait = CONCAT(@p_ValuesFait,')') ;

		 PRINT 'Colonne Finale vaut ===> '+@p_ColonneFait;
		 PRINT 'Values Finale vaut ===> '+@p_ValuesFait;
	 
		 SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO FP_',@v_nomActivite,@p_ColonneFait,' VALUES ',@p_ValuesFait,'; COMMIT;' )
		 PRINT @sqlQueryInsertTable;
	 
		 
		 EXEC sp_executesql @sqlQueryInsertTable;
	 END
	 IF @useInsert5 = 'true' AND @noParam = 'true'
	 BEGIN
		SET @p_ColonneFait = CONCAT(@v_InsertCol1,@v_InsertCol2,@v_InsertCol5,@v_InsertCol3,@v_InsertCol4);
		SET @p_ValuesFait = CONCAT(@v_InsertVal1,@v_InsertVal2,@v_InsertVal5,@v_InsertVal3,@v_InsertVal4);
		
		--SUPRESSION DE LA VIRGULE DE FIN
		 SET @p_ColonneFait = SUBSTRING(@p_ColonneFait, 1, (LEN(@p_ColonneFait)-1));
		 SET @p_ValuesFait = SUBSTRING(@p_ValuesFait, 1, (LEN(@p_ValuesFait)-1));
	 
		 --FERMETURE DES PARENTHESES
		 SET @p_ColonneFait = CONCAT(@p_ColonneFait,')'); 
		 SET @p_ValuesFait = CONCAT(@p_ValuesFait,')') ;

		 PRINT 'Colonne Finale vaut ===> '+@p_ColonneFait;
		 PRINT 'Values Finale vaut ===> '+@p_ValuesFait;
	 
		 SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO FP_',@v_nomActivite,@p_ColonneFait,' VALUES ',@p_ValuesFait,'; COMMIT;' )
		 PRINT @sqlQueryInsertTable;
	 
		 
		 EXEC sp_executesql @sqlQueryInsertTable;
	 END
	 IF @useInsert5 = 'true' AND @noParam = 'false'
	 BEGIN
		SET @p_ColonneFait = CONCAT(@v_InsertCol1,@v_InsertCol2,@v_InsertCol5,@v_InsertCol3,@v_InsertCol4);
		SET @p_ValuesFait = CONCAT(@v_InsertVal1,@v_InsertVal2,@v_InsertVal5,@v_InsertVal3,@v_InsertVal4);
		
		--SUPRESSION DE LA VIRGULE DE FIN
		 SET @p_ColonneFait = SUBSTRING(@p_ColonneFait, 1, (LEN(@p_ColonneFait)-1));
		 SET @p_ValuesFait = SUBSTRING(@p_ValuesFait, 1, (LEN(@p_ValuesFait)-1));
	 
		 --FERMETURE DES PARENTHESES
		 SET @p_ColonneFait = CONCAT(@p_ColonneFait,')'); 
		 SET @p_ValuesFait = CONCAT(@p_ValuesFait,')') ;

		 PRINT 'Colonne Finale vaut ===> '+@p_ColonneFait;
		 PRINT 'Values Finale vaut ===> '+@p_ValuesFait;
	 
		 SET @sqlQueryInsertTable = CONCAT('BEGIN TRANSACTION; INSERT INTO FSP_',@v_nomActivite,@p_ColonneFait,' VALUES ',@p_ValuesFait,'; COMMIT;' )
		 PRINT @sqlQueryInsertTable;
	 
		 
		 EXEC sp_executesql @sqlQueryInsertTable;
	 END

	 

	 FETCH NEXT FROM Curseur_Dim_P INTO @v_P1,@v_C1,@v_V1, @v_P2,@v_C2,@v_V2, @v_P3,@v_C3,@v_V3
	 END
	 
	 CLOSE Curseur_Dim_P
	 DEALLOCATE Curseur_Dim_P

	--CURSEUR DIMENSION AVEC PARAMETRE PAR RAPPORT AUX SEQUENCES DE REPONSE ET ID DEVICE
	
	PRINT '--------------------------------------------PROCHAINE SEQUENCE---------------------------';
	SET @v_InsertCol1 = '(';
	SET @v_InsertVal1 = '(';
	SET @v_InsertCol2 = '';
	SET @v_InsertVal2 = '';
	SET @v_InsertCol5 = '';
	SET @v_InsertVal5 = '';
	
	SET @v_ID_DIM = 0;
	FETCH NEXT FROM Curseur_seq INTO @v_nomActivite,@v_IdSeq,@v_IdDevice
	END

	CLOSE Curseur_seq
    DEALLOCATE Curseur_seq

	--Mettre la colonne traiter a 1
	UPDATE dbo.reponses SET traiter = 1 
END
GO
/****** Object:  StoredProcedure [dbo].[DWH_V1]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DWH_V1]   
  (@idActivite int )
AS     
BEGIN
--Déclaration des variables
DECLARE @v_ID integer;
DECLARE @v_IdDevice varchar(100);
DECLARE @v_DIM varchar(100);
DECLARE @v_TDIM varchar(100);
DECLARE @v_attribut varchar(100);
DECLARE @v_propriete varchar(255);
DECLARE @v_tAttribut varchar(255);
DECLARE @v_P1 varchar(255);
DECLARE @v_V1 varchar(255);
DECLARE @v_P2 varchar(255);
DECLARE @v_V2 varchar(255);
DECLARE @v_P3 varchar(255);
DECLARE @v_V3 varchar(255);
DECLARE @v_valeurText varchar(255);
DECLARE @v_valeurNum decimal;
DECLARE @New_DIM varchar(100);

DECLARE @sqlSelectDim NVARCHAR(MAX);
DECLARE @sqlQueryCreateTable NVARCHAR(MAX);
DECLARE @sqlQueryInsertTable NVARCHAR(MAX);
DECLARE @sqlQueryAlterTable NVARCHAR(MAX);
DECLARE @sqlQueryUpdateTable NVARCHAR(MAX);
DECLARE @sqlQuerySelect NVARCHAR(MAX);
DECLARE @nbrLigne integer;

--Déclaration du curseur des dimension inexistante

DECLARE Curs_DIM CURSOR FOR
SELECT distinct dbo.axes.nomAxe as dimension
FROM  dbo.axes
WHERE dbo.axes.nomAxe not in (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='DWH')

 --Ouverture
 OPEN Curs_DIM;

 --TEST
FETCH NEXT FROM Curs_DIM INTO @New_DIM

-- Création de la table
SET @sqlQueryCreateTable = N'CREATE TABLE ' + @New_DIM + '(
	Id_Seq'+@New_DIM+' INTEGER NOT NULL, 
	Id_Device'+@New_DIM+' VARCHAR(255) NOT NULL,
	CONSTRAINT PK_Id_Seq_Id_Device_'+@New_DIM+' PRIMARY KEY (Id_Seq'+@New_DIM+', Id_Device'+@New_DIM+') );' ;

-- Execution de la requete de creation
EXEC sp_executesql @sqlQueryCreateTable;
FETCH NEXT FROM Curs_DIM INTO @New_DIM
--Fermeture
CLOSE Curs_DIM;
DEALLOCATE Curs_DIM;

END
GO
/****** Object:  StoredProcedure [dbo].[DWH_V2]    Script Date: 26/08/2020 14:51:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DWH_V2]  
  (@idActivite int )
AS     
BEGIN
--Déclaration des variables
	DECLARE @v_ID varchar(100);
	DECLARE @v_DIM varchar(100);
	DECLARE @v_attribut varchar(100);
	DECLARE @v_propriete varchar(255);
	
	DECLARE @New_DIM varchar(100);
	DECLARE @NOMFAIT varchar(100);
	DECLARE @P_NOMFAIT varchar(100);
	DECLARE @v_fait varchar(100);
	DECLARE @v_Activite varchar(100);

	DECLARE @sqlQueryCreateTable NVARCHAR(MAX);
	DECLARE @sqlQueryAlterTable NVARCHAR(MAX);

--Création des dimensions inexistantes
	--Debut
		DECLARE Curs_DIM CURSOR FOR
		SELECT distinct dbo.axes.nomAxe as dimension
		FROM  dbo.axes
		WHERE dbo.axes.type ='DIMENSION' AND  CONCAT('DIM_',dbo.axes.nomAxe) NOT IN (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG='DWH')

		OPEN Curs_DIM;
		FETCH NEXT FROM Curs_DIM INTO @New_DIM

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Création de la dimension
			SET @sqlQueryCreateTable = N'CREATE TABLE DIM_' + @New_DIM + '(
				ID_DIM_'+@New_DIM+' INTEGER NOT NULL identity(1,1), 
				CONSTRAINT PK_ID_'+@New_DIM+' PRIMARY KEY (ID_DIM_'+@New_DIM+') );' ;
			EXEC sp_executesql @sqlQueryCreateTable;

		FETCH NEXT FROM Curs_DIM INTO @New_DIM;
		END

		CLOSE Curs_DIM;
		DEALLOCATE Curs_DIM;
	--Fin

--Créations des attributs inexistants des dimensions
	--Debut
		DECLARE Curs_Attr CURSOR FOR
		SELECT distinct dbo.axes.nomAxe as dimension, dbo.questions.corpsQuestion as attribut, dbo.questions.propriete as propriete
		FROM  dbo.axes,dbo.questions
		WHERE dbo.axes.type ='DIMENSION' AND dbo.axes.idAxe = dbo.questions.idAxe 
		AND dbo.questions.corpsQuestion NOT IN (SELECT dbo.questions.corpsQuestion FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('DIM_',dbo.axes.nomAxe) AND COLUMN_NAME = dbo.questions.corpsQuestion)
	
		OPEN Curs_Attr;
		FETCH NEXT FROM Curs_Attr INTO @v_DIM,@v_attribut,@v_propriete;

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Création des attributs
			SET @sqlQueryAlterTable = N'ALTER TABLE dbo.DIM_'+@v_DIM+' ADD '+@v_attribut+' '+@v_propriete +';' ;
			EXEC sp_executesql @sqlQueryAlterTable;
		
		FETCH NEXT FROM Curs_Attr INTO @v_DIM,@v_attribut,@v_propriete;
		END
	
		CLOSE Curs_Attr;
		DEALLOCATE Curs_Attr;
	--Fin

-- Création de la table des faits sans parametre associer aux dimensions sans parametre
	--Debut
		DECLARE Curs_FAIT CURSOR FOR
		SELECT dbo.FaitSansParam(@idActivite) AS NOMFAIT;
	
		OPEN Curs_FAIT;
		FETCH NEXT FROM Curs_FAIT INTO @v_fait ;
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @v_fait IS NULL
				BEGIN 
				   DECLARE curs_activite CURSOR FOR
				   SELECT distinct dbo.activites.nomActivite FROM dbo.activites WHERE dbo.activites.idActivite = @idActivite

				   OPEN curs_activite 
				   FETCH NEXT FROM curs_activite INTO @v_Activite ;
			   
				   WHILE @@FETCH_STATUS = 0
				   BEGIN
					   --Création du fait avec le nom de l'activité
					   SET @sqlQueryCreateTable = N'CREATE TABLE FSP_'+@v_Activite+'(
							ID int identity(1,1),
							ID_SEQ int not null,
							ID_DEVICE varchar(255) not null,
							CONSTRAINT PK_FSP_ID_SEQ_ID_DEVICE_'+@v_Activite+' PRIMARY KEY (ID,ID_SEQ, ID_DEVICE) );' ;
					   EXEC sp_executesql @sqlQueryCreateTable;
			  
				  FETCH NEXT FROM curs_activite INTO @v_Activite ;
				  END
			  
				  CLOSE curs_activite;
				  DEALLOCATE curs_activite;
			  
				  -- Ajout des dimensions au fait créer
				  DECLARE curs_Id_Dim CURSOR FOR
				  SELECT distinct dbo.activites.nomActivite as nomActivite, CONCAT('DIM_',dbo.axes.nomAxe) as dimension, CONCAT('ID_DIM_',dbo.axes.nomAxe) as IdDimension
				  FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
				  WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						dbo.questionnaire.typeParam = 'null' AND
						dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='DIMENSION' AND
						dbo.activites.idActivite = @idActivite
			   
				  OPEN curs_Id_Dim 
				  FETCH NEXT FROM curs_Id_Dim INTO @v_Activite, @v_DIM, @v_ID ;
				
				  WHILE @@FETCH_STATUS = 0
				  BEGIN 
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FSP_'+@v_Activite+
						' ADD '+@v_ID+' int CONSTRAINT '+@v_DIM+'_'+@v_ID+'_fk FOREIGN KEY('+@v_ID+') REFERENCES dbo.'+@v_DIM+'('+@v_ID+') ON UPDATE CASCADE ON DELETE CASCADE ;' ;		
						EXEC sp_executesql @sqlQueryAlterTable;
				
				  FETCH NEXT FROM curs_Id_Dim INTO @v_Activite, @v_DIM, @v_ID ;		
				  END

				  CLOSE curs_Id_Dim;
				  DEALLOCATE curs_Id_Dim;

				  -- Ajout des mesures et metriques au fait créer
				  DECLARE curs_Metric CURSOR FOR
				  SELECT distinct dbo.activites.nomActivite as dimension, dbo.questions.corpsQuestion as attribut,  dbo.questions.propriete as propriete
				  FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
				  WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
						dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						dbo.questionnaire.typeParam = 'null' AND
						dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='FAIT' AND
						dbo.activites.idActivite = @idActivite
         
				  OPEN curs_Metric 
				  FETCH NEXT FROM curs_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
        
				  WHILE @@FETCH_STATUS = 0
				  BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FSP_'+@v_Activite+' ADD '+@v_attribut+' '+@v_propriete +';' ;
						EXEC sp_executesql @sqlQueryAlterTable;	
					
					 FETCH NEXT FROM curs_Metric INTO @v_Activite, @v_attribut,@v_propriete ;    
				  END

					 CLOSE curs_Metric;
					 DEALLOCATE curs_Metric;
				END
		
			ELSE
			--Ajout Des nouvelles dimensions et mesures
				BEGIN
				-- Debut nouvelle dimension
					print @v_fait; 
					DECLARE curs_New_Dim CURSOR FOR
					SELECT distinct dbo.activites.nomActivite as nomActivite, CONCAT('DIM_',dbo.axes.nomAxe) as dimension, CONCAT('ID_DIM_',dbo.axes.nomAxe) as IdDimension
					FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
					WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						  dbo.questionnaire.typeParam = 'null' AND
						  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='DIMENSION' AND
						  dbo.activites.idActivite = @idActivite AND 
						  CONCAT('ID_DIM_',dbo.axes.nomAxe) NOT IN (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('FSP_',dbo.activites.nomActivite) AND COLUMN_NAME LIKE 'ID_DIM_%')

					OPEN curs_New_Dim
					FETCH NEXT FROM curs_New_Dim INTO @v_Activite, @v_DIM, @v_ID ;
				
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FSP_'+@v_Activite+
						' ADD '+@v_ID+' int CONSTRAINT '+@v_DIM+'_'+@v_ID+'_fk FOREIGN KEY('+@v_ID+') REFERENCES dbo.'+@v_DIM+'('+@v_ID+') ON UPDATE CASCADE ON DELETE CASCADE ;' ;		
						EXEC sp_executesql @sqlQueryAlterTable;
	
					FETCH NEXT FROM curs_New_Dim INTO @v_Activite, @v_DIM, @v_ID ;
					END

					CLOSE curs_New_Dim;
					DEALLOCATE curs_New_Dim;
				--Fin nouvelle dimension 
			
				--Debut nouvelle metrique
					DECLARE curs_New_Metric CURSOR FOR
					SELECT distinct dbo.activites.nomActivite as dimension, dbo.questions.corpsQuestion as attribut,  dbo.questions.propriete as propriete
					FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
					WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
						  dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						  dbo.questionnaire.typeParam = 'null' AND
						  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='FAIT' AND
						  dbo.activites.idActivite = @idActivite AND dbo.questions.corpsQuestion NOT IN (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('FSP_',dbo.activites.nomActivite))
         
					 OPEN curs_New_Metric 
					 FETCH NEXT FROM curs_New_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
        
					 WHILE @@FETCH_STATUS = 0
					 BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FSP_'+@v_Activite+' ADD '+@v_attribut+' '+@v_propriete +';' ;
						EXEC sp_executesql @sqlQueryAlterTable;	
				 
					 FETCH NEXT FROM curs_New_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
					 END

					 CLOSE curs_New_Metric;
					 DEALLOCATE curs_New_Metric;
				--Fin nouvelle metrique
			
				END
		FETCH NEXT FROM Curs_FAIT INTO @v_fait ;
		END

	
		CLOSE Curs_FAIT;
		DEALLOCATE Curs_FAIT;
	--Fin

-- Création de la table des faits avec parametre associer au dimension avec parametre
	--Debut
		DECLARE P_Curs_FAIT CURSOR FOR
		SELECT dbo.P_Fait(@idActivite) AS P_NOMFAIT;
	
		OPEN P_Curs_FAIT;
		FETCH NEXT FROM P_Curs_FAIT INTO @v_fait ;
	
		WHILE @@FETCH_STATUS = 0
		BEGIN
			IF @v_fait IS NULL
				BEGIN
				   DECLARE P_curs_activite CURSOR FOR
				   SELECT distinct dbo.activites.nomActivite FROM dbo.activites WHERE dbo.activites.idActivite = @idActivite

				   OPEN P_curs_activite 
				   FETCH NEXT FROM P_curs_activite INTO @v_Activite ;
			   
				   WHILE @@FETCH_STATUS = 0
				   BEGIN
					   --Création du fait avec le nom de l'activité	
					   SET @sqlQueryCreateTable = N'CREATE TABLE FP_'+@v_Activite+'(
							ID int identity(1,1),
							ID_SEQ int not null,
							ID_DEVICE varchar(255) not null,
							CONSTRAINT PK_FP_ID_SEQ_ID_DEVICE_'+@v_Activite+' PRIMARY KEY (ID, ID_SEQ, ID_DEVICE) );' ;
					   EXEC sp_executesql @sqlQueryCreateTable;
				  FETCH NEXT FROM P_curs_activite INTO @v_Activite ;
				  END
			  
				  CLOSE P_curs_activite;
				  DEALLOCATE P_curs_activite;

				  --Migration des autres dimensions
				  DECLARE curs_Migr_Dim CURSOR FOR
				  SELECT distinct dbo.activites.nomActivite as nomActivite, CONCAT('DIM_',dbo.axes.nomAxe) as dimension, CONCAT('ID_DIM_',dbo.axes.nomAxe) as IdDimension
				  FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
				  WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						dbo.questionnaire.typeParam = 'null' AND
						dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='DIMENSION' AND
						dbo.activites.idActivite = 11 AND 
					    CONCAT('ID_DIM_',dbo.axes.nomAxe) NOT IN (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('FP_',dbo.activites.nomActivite) AND COLUMN_NAME LIKE 'ID_DIM_%')
				  OPEN curs_Migr_Dim
				  FETCH NEXT FROM curs_Migr_Dim INTO @v_Activite, @v_DIM, @v_ID ;
			 	  WHILE @@FETCH_STATUS = 0
				  BEGIN
					  SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FP_'+@v_Activite+
					   ' ADD '+@v_ID+' int CONSTRAINT P_'+@v_DIM+'_'+@v_ID+'_fk FOREIGN KEY('+@v_ID+') REFERENCES dbo.'+@v_DIM+'('+@v_ID+') ON UPDATE CASCADE ON DELETE CASCADE ;' ;		
					  EXEC sp_executesql @sqlQueryAlterTable;
	
				  FETCH NEXT FROM curs_Migr_Dim INTO @v_Activite, @v_DIM, @v_ID ;
				  END

				  CLOSE curs_Migr_Dim;
				  DEALLOCATE curs_Migr_Dim;


				  -- Ajout lSes dimensions
				  DECLARE P_curs_Id_Dim CURSOR FOR
				  SELECT distinct dbo.activites.nomActivite as nomActivite, CONCAT('DIM_',dbo.axes.nomAxe) as dimension, CONCAT('ID_DIM_',dbo.axes.nomAxe) as IdDimension
				  FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
				  WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						dbo.questionnaire.typeParam <> 'null' AND
						dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='DIMENSION' AND
						dbo.activites.idActivite = @idActivite
			   
				  OPEN P_curs_Id_Dim 
				  FETCH NEXT FROM P_curs_Id_Dim INTO @v_Activite, @v_DIM, @v_ID ;
				
				  WHILE @@FETCH_STATUS = 0
				  BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FP_'+@v_Activite+
						' ADD '+@v_ID+' int CONSTRAINT '+@v_DIM+'_'+@v_ID+'_fk FOREIGN KEY('+@v_ID+') REFERENCES dbo.'+@v_DIM+'('+@v_ID+') ON UPDATE CASCADE ON DELETE CASCADE ;' ;		
						EXEC sp_executesql @sqlQueryAlterTable;

				  FETCH NEXT FROM P_curs_Id_Dim INTO @v_Activite, @v_DIM, @v_ID ;		
		 		  END

				  CLOSE P_curs_Id_Dim;
				  DEALLOCATE P_curs_Id_Dim;

				  -- Ajout des mesures et metriques
				  DECLARE P_curs_Metric CURSOR FOR
				  SELECT distinct CONCAT('FP_',dbo.activites.nomActivite) as dimension, dbo.questions.corpsQuestion as attribut,  dbo.questions.propriete as propriete
				  FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
				  WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
						  dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						  dbo.questionnaire.typeParam <> 'null' AND
						  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='FAIT' AND
						  dbo.activites.idActivite = @idActivite
         
				  OPEN P_curs_Metric 
				  FETCH NEXT FROM P_curs_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
        
				  WHILE @@FETCH_STATUS = 0
				  BEGIN
					   SET @sqlQueryAlterTable = N'ALTER TABLE dbo.'+@v_Activite+' ADD '+@v_attribut+' '+@v_propriete +';' ;
						EXEC sp_executesql @sqlQueryAlterTable;	
					
				  FETCH NEXT FROM P_curs_Metric INTO @v_Activite, @v_attribut,@v_propriete ;    
				  END

				  CLOSE P_curs_Metric;
				  DEALLOCATE P_curs_Metric;
				END
		
			ELSE
			-- Nouvelle dimension pour fait avec parametre
				BEGIN
					-- Debut nouvelle dimension 
					DECLARE P_curs_New_Dim CURSOR FOR
					SELECT distinct dbo.activites.nomActivite as nomActivite, CONCAT('DIM_',dbo.axes.nomAxe) as dimension, CONCAT('ID_DIM_',dbo.axes.nomAxe) as IdDimension
					FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
					WHERE dbo.axes.idAxe = dbo.questions.idAxe AND dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
							dbo.questionnaire.typeParam <> 'null' AND
							dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='DIMENSION' AND
							dbo.activites.idActivite = @idActivite AND 
						  CONCAT('ID_DIM_',dbo.axes.nomAxe) NOT IN (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('FP_',dbo.activites.nomActivite) AND COLUMN_NAME LIKE 'ID_DIM_%')

					OPEN P_curs_New_Dim
					FETCH NEXT FROM P_curs_New_Dim INTO @v_Activite, @v_DIM, @v_ID ;
				
					WHILE @@FETCH_STATUS = 0
					BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FP_'+@v_Activite+
						' ADD '+@v_ID+' int CONSTRAINT '+@v_DIM+'_'+@v_ID+'_fk FOREIGN KEY('+@v_ID+') REFERENCES dbo.'+@v_DIM+'('+@v_ID+') ON UPDATE CASCADE ON DELETE CASCADE ;' ;		
						EXEC sp_executesql @sqlQueryAlterTable;
				
					FETCH NEXT FROM P_curs_New_Dim INTO @v_Activite, @v_DIM, @v_ID ;
					END

					CLOSE P_curs_New_Dim;
					DEALLOCATE P_curs_New_Dim;
					--Fin nouvelle dimension
				
					--Debut nouvelle metrique
					DECLARE P_curs_New_Metric CURSOR FOR
					SELECT distinct CONCAT('FP_',dbo.activites.nomActivite) as dimension, dbo.questions.corpsQuestion as attribut,  dbo.questions.propriete as propriete
					FROM dbo.activites, dbo.axes, dbo.questions, dbo.questionnaire
					WHERE dbo.axes.idAxe = dbo.questions.idAxe AND 
						  dbo.questions.idQuestion = dbo.questionnaire.idQuestion AND 
						  dbo.questionnaire.typeParam <> 'null' AND
						  dbo.questionnaire.idActivite = dbo.activites.idActivite AND dbo.axes.type ='FAIT' AND
						  dbo.activites.idActivite = @idActivite AND dbo.questions.corpsQuestion NOT IN (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = CONCAT('FP_',dbo.activites.nomActivite) )
         
					 OPEN P_curs_New_Metric 
					 FETCH NEXT FROM P_curs_New_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
        
					 WHILE @@FETCH_STATUS = 0
					 BEGIN
						SET @sqlQueryAlterTable = N'ALTER TABLE dbo.FP_'+@v_Activite+' ADD '+@v_attribut+' '+@v_propriete +';' ;
						EXEC sp_executesql @sqlQueryAlterTable;	
					 FETCH NEXT FROM P_curs_New_Metric INTO @v_Activite, @v_attribut,@v_propriete ;
					 END

					 CLOSE P_curs_New_Metric;
					 DEALLOCATE P_curs_New_Metric;

					--Fin nouvelle metrique
				END
		FETCH NEXT FROM P_Curs_FAIT INTO @v_fait ;
		END

		--Fermeture
		CLOSE P_Curs_FAIT;
		DEALLOCATE P_Curs_FAIT;
	--Fin

END
GO
USE [master]
GO
ALTER DATABASE [DWH] SET  READ_WRITE 
GO
