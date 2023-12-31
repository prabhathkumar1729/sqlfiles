create DATABASE EventManagementSystem_TeamZeal;
drop database EventManagementSystem_TeamZeal;
USE EventManagementSystem_TeamZeal;
use master
go

CREATE TABLE Roles(
    RoleId TINYINT PRIMARY KEY IDENTITY(1,1),
    RoleName VARCHAR(255) NOT NULL
)
INSERT INTO ROLES VALUES('ADMIN'),('PRIMARY_OWNER'),('SECONDARY_OWNER'),('PEER');
GO

CREATE TABLE AccountCredentials(
    AccountCredentialsId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    Password VARCHAR(255) NOT NULL,
    UpdatedOn DATETIME NOT NULL
)
GO

CREATE TABLE Organisations (
  OrganisationId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
  OrganisationName VARCHAR(255) UNIQUE NOT NULL,
  OrganisationDescription VARCHAR(1024) NOT NULL,
  Location VARCHAR(512) NOT NULL,
  CreatedOn DATE DEFAULT GETDATE(), 
  isActive BIT DEFAULT 0 NOT NULL,
  UpdatedOn DATETIME DEFAULT GETDATE()
);

GO 

CREATE TABLE Administration(
       AdministratorId UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY ,
       AdministratorName VARCHAR(255) NOT NULL,
       GoogleId VARCHAR(255) DEFAULT NULL ,
       AdministratorAddress VARCHAR(512) NOT NULL,
       Email VARCHAR(255) NOT NULL,
       PhoneNumber VARCHAR(32) NOT NULL,
	   AccountCredentialsId UNIQUEIDENTIFIER ,
       CreatedOn DATETIME DEFAULT GetDate(),
       UpdatedOn DATETIME DEFAULT GetDate(),
	   RoleId TINYINT NOT NULL,
       IsAccepted BIT DEFAULT 0,
	   CreatedBy UNIQUEIDENTIFIER REFERENCES Administration(AdministratorId) DEFAULT NULL,
       AcceptedBy UNIQUEIDENTIFIER REFERENCES Administration(AdministratorId) DEFAULT NULL,
       RejectedBy UNIQUEIDENTIFIER REFERENCES Administration(AdministratorId) DEFAULT NULL,
	   DeletedBy UNIQUEIDENTIFIER REFERENCES Administration(AdministratorId) DEFAULT NULL,
	   OrganisationId UNIQUEIDENTIFIER NOT NULL,
	   BlockedBy UNIQUEIDENTIFIER references Administration(administratorid),
       CONSTRAINT FK_ORGANISATIONID FOREIGN KEY (OrganisationId) REFERENCES Organisations(OrganisationId) ,
       IsActive BIT DEFAULT 0,
	   CONSTRAINT FK_ROLEID FOREIGN KEY (RoleId) REFERENCES Roles(RoleId) ,
	   CONSTRAINT FK_ADMINISTRATION_AccountCredentialsID FOREIGN KEY (AccountCredentialsId) REFERENCES AccountCredentials(AccountCredentialsID),
);
go 
CREATE UNIQUE INDEX Unique_Administration_Google_Id
ON Administration (GoogleId)
WHERE GoogleId IS NOT NULL;
go
CREATE TABLE Users
(
    UserId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    GoogleId VARCHAR(255) UNIQUE NOT NULL ,
    Name VARCHAR(255) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(255) NOT NULL,
    AccountCredentialsId UNIQUEIDENTIFIER ,
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1 NOT NULL,
	DeletedBy UNIQUEIDENTIFIER DEFAULT NULL,
    CONSTRAINT FK_USERS_AccountCredentialsID FOREIGN KEY (AccountCredentialsId) REFERENCES AccountCredentials(AccountCredentialsId),
	CONSTRAINT FK_USERS_ADMINISTRATORID FOREIGN KEY (DeletedBy) REFERENCES Administration(AdministratorId)
)
 GO 
CREATE UNIQUE INDEX Unique_Users_Google_Id
ON Users (GoogleId)
WHERE GoogleId IS NOT NULL;
GO 


CREATE TABLE RegistrationStatus(
	RegistrationStatusId TINYINT PRIMARY KEY IDENTITY(1,1),
	RegStatus VARCHAR(255) NOT NULL,
)

GO

INSERT INTO RegistrationStatus VALUES('YetToOpen'),('Open'),('Close');
GO

CREATE TABLE FieldTypes
(
    FieldTypeId TINYINT PRIMARY KEY IDENTITY(1,1),
    Type VARCHAR(25) NOT NULL
)

INSERT INTO FieldTypes VALUES ('Text'),('Number'),('Select'),('Date'),('Email');

GO

CREATE TABLE Forms
(
    FormId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	FormName VARCHAR(255) NOT NULL,
    OrganisationId UNIQUEIDENTIFIER NOT NULL,
    CreatedBy UNIQUEIDENTIFIER NOT NULL,
    CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT DEFAULT 1 NOT NULL,
    CONSTRAINT FK_createrId FOREIGN KEY (CreatedBy) REFERENCES [Administration] (AdministratorId),
    CONSTRAINT FK_orgId FOREIGN KEY (OrganisationId) REFERENCES [Organisations] (OrganisationId)
)




CREATE TABLE RegistrationFormFields
(
    RegistrationFormFieldId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    FormId UNIQUEIDENTIFIER NOT NULL,
    FieldTypeId TINYINT NOT NULL,
    Lable VARCHAR(50) NOT NULL,
	Validations VARCHAR(MAX) NOT NULL, 
    Options VARCHAR(255),
    IsRequired BIT DEFAULT 1 NOT NULL,
    CONSTRAINT FK_formId FOREIGN KEY (FormId) REFERENCES [Forms] (FormId),
    CONSTRAINT FK_fieldId FOREIGN KEY (FieldTypeId) REFERENCES [FieldTypes] (FieldTypeId)
)

--ALTER TABLE RegistrationFormFields
--ADD Validations VARCHAR(MAX) NOT NULL

CREATE TABLE EventCategories ( CategoryId TINYINT PRIMARY KEY IDENTITY(1,1), CategoryName VARCHAR(255) NOT NULL ); 

INSERT INTO EventCategories ( CategoryName) VALUES ( 'Conference'), ( 'Seminar'), ( 'Workshop'), ('Networking'), ( 'Exhibition'), ('Trade Show'), ( 'Concert'), ( 'Festival'), ( 'Sporting Event'), ( 'Webinar');


CREATE TABLE Events(
	 EventId UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
	 EventName VARCHAR(255) NOT NULL ,
	 StartDate DATETIME NOT NULL,
	 CategoryId TINYINT NOT NULL,
	 EndDate DATETIME NOT NULL,
	 Capacity INT NOT NULL,
	 AvailableSeats as Capacity,
	 Description VARCHAR(1024) NOT NULL,
	 Location VARCHAR(1024) NOT NULL,
	 IsPublished BIT NOT NULL DEFAULT 0,
	 IsOffline BIT NOT NULL DEFAULT 1,
	 IsCancelled BIT NOT NULL DEFAULT 0,
	 MaxNoOfTicketsPerTransaction TINYINT NOT NULL,
	 CreatedOn DATETIME NOT NULL DEFAULT GETDATE(),
	 IsFree BIT NOT NULL DEFAULT 0,
	 IsActive BIT NOT NULL DEFAULT 1,
	 OrganisationId UNIQUEIDENTIFIER NOT NULL,
	 FormId UNIQUEIDENTIFIER NOT NULL,
	 RegistrationStatusId TINYINT NOT NULL,
	 CreatedBy UNIQUEIDENTIFIER NOT NULL,
	 AcceptedBy UNIQUEIDENTIFIER NOT NULL,
	 CONSTRAINT FK_EVENTS_ORGANISATIONID FOREIGN KEY (OrganisationId) REFERENCES Organisations(OrganisationId),
	 CONSTRAINT FK_EVENTS_FORMID FOREIGN KEY (FormId) REFERENCES Forms(FormId),
	 CONSTRAINT FK_EVENTS_REGISTRATIONSTATUSID FOREIGN KEY (RegistrationStatusId) REFERENCES RegistrationStatus(RegistrationStatusId),
	 CONSTRAINT FK_EVENTS_CREATEDBY FOREIGN KEY (CREATEDBY) REFERENCES Administration(AdministratorId),
	  CONSTRAINT FK_EVENTS_ACCEPTEDBY FOREIGN KEY (ACCEPTEDBY) REFERENCES Administration(AdministratorId),
	  CONSTRAINT FK_EVENTS_CATEGORYID FOREIGN KEY (CategoryId) REFERENCES EventCategories(CategoryId),
)

CREATE TABLE Transactions ( 

TransactionId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
UserId UNIQUEIDENTIFIER NOT NULL,
 EventId UNIQUEIDENTIFIER NOT NULL, 
 NoOfTickets INT NOT NULL ,
TransactionTime DATETIME DEFAULT GETDATE(),
 IsSuccessful BIT NOT NULL, 
CONSTRAINT FK_Transactions_Users FOREIGN KEY (UserId) REFERENCES Users(UserId),
 CONSTRAINT FK_Transactions_Events FOREIGN KEY (EventId) REFERENCES Events(EventId) 

);

go
 CREATE TABLE UserInputForm(
 UserInputFormId UNIQUEIDENTIFIER PRIMARY KEY NOT NULL,
 UserId UNIQUEIDENTIFIER NOT NULL,
 EventId UNIQUEIDENTIFIER NOT NULL,
 CONSTRAINT FK_EVENTID_EVENTS FOREIGN KEY (EventId) REFERENCES EVENTS(EventId),
 CONSTRAINT FK_UserID_Users FOREIGN KEY (UserID) REFERENCES Users(UserId)
 )
 GO
 CREATE TABLE Tickets ( 
TicketId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(), 
TransactionId UNIQUEIDENTIFIER NOT NULL, 
UserInputFormId UNIQUEIDENTIFIER NOT NULL,
IsCancelled BIT DEFAULT 0, 
UpdatedOn DATETIME NOT NULL,
EventId UNIQUEIDENTIFIER NOT NULL, 
CONSTRAINT FK_Tickets_Transactions FOREIGN KEY (TransactionId) REFERENCES Transactions(TransactionId), CONSTRAINT FK_Tickets_Events FOREIGN KEY (EventId) REFERENCES Events(EventId),
	CONSTRAINT FK_UserInputFormId_UserInputForm	FOREIGN KEY  (UserInputFormId) REFERENCES UserInputForm(UserInputFormId),

 );
 GO
CREATE TABLE UserInputFormFields(
    UserInputFormFieldid UNIQUEIDENTIFIER PRIMARY KEY NOT NULL,
    RegistrationFormFieldId UNIQUEIDENTIFIER NOT NULL,
    UserInputFormId UNIQUEIDENTIFIER NOT NULL,
    Label VARCHAR(255) NOT NULL,
    StringResponse VARCHAR(MAX) DEFAULT NULL,
    NumberResponse INT DEFAULT NULL,
    DateResponse DATETIME DEFAULT NULL,
	CONSTRAINT FK_RegistrationFormFieldId_RegistrationFormFields FOREIGN KEY (RegistrationFormFieldId) REFERENCES RegistrationFormFields(RegistrationFormFieldId),
	CONSTRAINT FK_UserInputFormIdd_UserInputForm	FOREIGN KEY  (UserInputFormId) REFERENCES UserInputForm(UserInputFormId),
)
INSERT INTO Organisations (OrganisationId, OrganisationName, OrganisationDescription, Location, CreatedOn, isActive, UpdatedOn)
VALUES
    (NEWID(), 'BookMyEvent', 'Indias most used event management application', 'India', GETDATE(), 1, GETDATE())
    ;
INSERT INTO AccountCredentials VALUES (newid(), 'Password', GETDATE());
insert into Administration values (newid(), 'Prabhath Kumar', null, 'Hyderabad' , 'prabhath@abc.com', '7702341604', 'CC4AAD53-679B-444C-8D5E-C39FBA6B6B70', getdate(), getdate(), 1, 1, null, null, null, null, null, null, '087D77F2-0E65-4637-AA41-72526523AC57', 1);

update AccountCredentials set Password = '723a74ec4a34ae52491175445dea14261e192e9a9b12fe353ac389145f816ea0' where Password = 'Password';

Delete from Administration where AdministratorId = 'EDA351B1-F0F3-4E5C-B379-CDDB5F780121';
SELECT * FROM Roles  ;
SELECT * FROM Users  ;
SELECT * FROM Organisations  ;
SELECT * FROM Administration  ;
SELECT * FROM AccountCredentials;
SELECT * FROM EventCategories  ;
SELECT * FROM Transactions  ;
SELECT * FROM Events  ;
SELECT * FROM Forms  ;
SELECT * FROM RegistrationFormFields  ;
SELECT * FROM RegistrationStatus  ;
SELECT * FROM UserInputForm  ;
SELECT * FROM UserInputFormFields  ;
SELECT * FROM FieldTypes  ;
SELECT * FROM Tickets where eventid = '6FA41EC1-2992-484A-AC6B-59F0C68C9A07' ;


update Administration set ImgBody = '0xFFD8FFE000104A46494600010100000100010000FFDB00840009060712121215121212151515151517151515171717151517151517171715171515181D2820181D251D151521312125292B2E2E2E171F3338332D37282D2E2B010A0A0A0E0D0E170F10152D1D151D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D2D372DFFC000110800E100E103012200021101031101FFC4001B00000105010100000000000000000000000100020304050607FFC400381000020102040306040308030100000000000102031104052131124151061322617191143281A12362B1071533425272C1F063D1F124FFC400190100030101010000000000000000000000000102030405FFC4002111010100020202030101010000000000000001021103122131134151223204FFDA000C03010002110311003F00D9FDE50FEB8FBA1DF1B1FEA5EE71F4E9DDDBCD1AF569AE2678B94923D3E8D958B4F67EC3FE2BD4CCCBE1AFD4D19C0CF52A329A3962474B14889407700F5092AC5798962C8BBB17761A8127C5096246280EE01EA16EA4F8A07C50CEE831A62D41B3BE246FC58BBB0F763EB06E93C48962BD42A98BBB0EB06E9BDFFA8BE27D42A03FBB1758368FE23C98DF89D7664CA987BA0EB06D03C47A8BBFF52654C77763EB06EABFC4FA85D6F264EA98EE11782DD547887D1FB01D77D1FB173BB0AA63D43DA92AEFA314AB3E8FD8BCA98BBB0F03754BBE7D1FB08D0EE9087B89DD705865E2F6362AFCCCC7C3BF1A352ADEF2F50CFD3B2FB5CC02F11A3233B2F5E2FA2345911966686C1414524121D61D42939BE18ABB26AD839C37561EAFB45AAE9058074490514384C480CD1F64015C6343C22B04480838475809858685868EB0241680C905A1445611524161482D0036C2B0F881B1E8121C041B881C206BE410F05B79EE163F8B05D5A36386D292F37FA99197EB5A1EA6A62D5A727F98BCFD3AD7305F31A1233B02FC4683338CB2F622B8105022AEE553E19C5F9EA754E1192B35738DA13B3B9D3E598AE34BA9D9C194D6AB0E497DAB66196412BAD0C2A90E1763B59C535666266396B4DB8EAB7F41F3717DC1C7C8C5112C70D64DC9DADC8854D72D8E4B34DA6E8A08D4C5716C1C98465C72900D08502C100120B62131C03108D41B88A9E82307819A8724041B94058DB84221A1B845A7FB710CB4F3ECA1FE341FE635310EF525EACCAC9D7E2C3D4D693BCE5EAC7C9E9D3F6B182F98D2666E09EBEC693338CF3F60142684081B96B078D7069950499AE196AA6CDBAFC3636328A7732B3EED02A49C62F5B19D86C438DD727B9CEF6A78AE9FB79A3A72CEDC53871CEC5FBE273959BDC9E58EE1491894A94B8535FF0080EF249EAF9A39329BAEC924746F19E15AEE40F1126FE6D0C9A55DB7AF425EF3855EDABD88D68B536D594DF527A5376DCC69D676D77FF25AA75AD103B8C6B52AFB1656BB18D4B156DB51AF379C5E8D2F5299DC1BEE93E836C62E1F36A937F36CAE474F195A726A376BA8E63B475FD6E3762E65F87E392BE8B999997E06736B89B7FA23A8A34D423636E3E2FD659555CD28462970AB19A8D5C7BBC527EA6411CD35461450E4002216709004841208421879F649AD58FAB34D4BC52F36FF005337267F8CBCAEFEC68437FAB0E4F4E85DC0FCC685CCDC07CCCD16462CF3BE450989B045DC693832836B400F53B58BC215ACB9D59C2450CEB19C70E0B6BF73731767AD91CE66DA3D0AB955E325332EAF64D3E5FE48269B9B51577CBFC952B57E05A3DCBF954FC0E5FCEF664EAFB6DB59C250507E369B6ED61F521294AE97862AFEE65D3AD295551DDA7FA9DBE0B037C3BBAD6ECBC30DB3CF3EAE6F2FA327C4DF37A731F5E2E1A32697142AA515A6B72BE6BE24ECF54CCF29AAAC6EC954E18DF9BB99B89C5712F42DCEED474E5A956A538BFA7DC78E9561986CC382FCDBB2476F9150E38C6CAD74AECE3B24CAA55EAF1356845EE7A6E028AA71492D91BE3239F92E96A8D250565B8D72BF3248D44F9875BDDC4DE787328E3A5F6338BD8DA9BF86DE6CA099C9CB7CB4C0E030A158C97407C465C7418A1C49EE2104AD969E7D92AFC5FF007A17E0B57EA53C83F8BAFF004BFD0B7196B6EAD8F91D2BD80DD97CA3815B97999C6591063A0D0DCA4ECE4194465C996A8DB0C7C33B556B3D3EC62E329B96B6D8DAC53B68470C2717EBEA171698E5A71F89C236F6BB6FD8E8B21C9E4E95DC75E4BCDE868C3276E49DB9EBE475D96E194209595D1A638279397F1CF651D99EEE129CD5EA4B4FED5E46E51C3A8C144D2922A631F0ABFA9AF591CF73B6B93C6E1382A4F9F13BA3966E53ACD2D933ABC4B954E2D7C5FA1532EC028293B5E52765FF00672F23B78EEA2863229248A35B0527A7B237A7844F7DD16F0F825F539EDAD664192C3862B4D6C6CC3137D0828E1AC4D1C34A5B2B5CDF8B6E6E4B3ED2D1C5C6F68EAF635A9464D36F4D0AB96E5D185BAF366BA8D96C76E31CF9E53E9CFE3AFADCCD4CBF9BCBC56338E0E4BFD35C0E424212666B10A1B70DCA349708C08C9C1E44FC77FCACB317ADCAB913F1BF28C8B301F2366A65DCCBAD9472EE65D891233CD9999E754A85F89B6D2D52FF002CE4731EDB557754A2A2BAEEEC33B5353FFA250FAB31249F43BF8B8B1D6EC72679DDF87A36458A94E11949EAD2B9BF464AC794E0B3CAD49AD9A5CB63A5CBFB634DAB4EF17EEBDCAB81CCDD3D78F148D2A11F0AF231B0399539EA9A77E8CD8A5593488B8E95DB6D3C2C743468CEC8CFC34D58B1C7E11A2CDADC1EA3719478A2369CB424E2BA657B4FDB9AA3826B89F36F6F243285269B6FAEC6E386A51C7C2DAAE6639E0DF1CF6A7F0DAB7D7626842C0A13E2B2F32FF74AC6178EDF51AF790CC3C8D1A3033E9D27746AE174B1B7161630E4CB69E92B135F420C5558C62E4DD9224C0568D4A6A4B54D1D9239ED73199B7C6FD4AA99D2E6795A95DC5599CE56A2E0ECCF3F9B8EE36D74F1E72CD1A828084632B510A0242199E20FD043270992FCD3F28BFB96A256C8FE69FF006B2C44AE46D1A5966CCBA52CB568CB8999C465EDC176BF0FC38952E528FDCC4923B8ED8E5AEAD2E38FCD0D57A1C2A775D1F4F33D1E2CB78C71E78EAA29909254E644D9BC454B86C4CE0EF0934CE932EED8CE365357B735A1CADC0C7A953B7AC65DDAEA724BC493E8CD07DA1868F897B9E350849ED71CD4D68DB33BC50FE4AF5FC6F6D68C379AFA6ACCAAFF00B4D8A56A7093F37A1E6AD11F1B2B1E39076DBB8AFF00B47C43F921049F5BB650C476CF1935AC927E48E514F5248D465F5943A2A5DA7C5AD7BCFB1768F6C318B79A7F43945518E55DA26E327D0BB76D4BB7B5E3F324FE875FD97CF7118A5750518AFE66AC9FA1E45807C752317B3924CF6DC9671A74D46292492B11750E4B5B1572E5563C329CADCEDA234B2FC346941538BD119F86C5DF52FD3AC984CA26E2B4CC9CF30E9C6F6D4D58C8AD9853E28343CE76C68C6EAB8F00FAB1B3686A3CAB355DB2F80B8E486A0828FF00F77102E843270F926F51FE526A322B64EFF89FDA4D48BCDB46C65CB49168AD80D9964CA7A465EC9ED67B1C2F69B239424EAD3578BDD2E4772D87BABAB3574F7F335E2CEE358E78EDE3F264133BFCEFB20A4DCA8E8FA1C9E3322AF07AC19E8E194AE7CA56571124137627865B55BFE1BF63ABECF766250B55AAB5FE58BFD595739214C6D5BECBF679F0F1CD6AFA8EED3766ED17384755AE8769808AB22F4E82945A7CCC3BDDEDA5C3C69E075159DBE80E0B9D8F6AFB33284A53847C3ABD0E4541ADD1BE376CBD227484A04A148BD8DC46A209225921D4E9B93B462E4DF242B41F96623BBA919B49D99EAD80C7714636D9AB9C2E53D90AD57C553C11FB9DD659858D182A6AED4568D9CDC9635E38D9A188E15E76357015ED6D7D4E6ABD469A7CB997F0588BB5632EDA5E51D8519DD12357465E1313CAE69537A23AB1BB8E6CA69839C606CF8923151D963E971459C8D783526BA1C5FF00461ABE1D1C396E23B85802736DB88875C41B0E13285E1A9FDA89E9B2B653F2547E5625A6F637CDA46CE5FB32D15F00BC2CB0611390245B8408294752FC63A1B613C32A85A4314137668964AC31DCD77A1ADA4861217BF0A062B0B75A72D810AF6DCB54EA26B4612A278AC4A58C941F0BFB9A397E3A753E55757DF64439AE1232B7EA696574A318A48B8D32CA58B33C329AB496FB9CBE6DD8AA551B70F0BFB1D826392B972E9CD66DE5788FD9FD4BE93D3D86D3FD9F56E73D0F589532B554877929CC6380C1F6069AFE2CDCBD0E932FC92850F929ABF57AB357841C065792D54C62170453AD4AC694A043561D48548A54A375663A9CB839106327C3B6FE435D5B59B1346FE5989527D19D1519E88E4B2D9C774CE8F0D55686FC55CDC91A1BA39BCDF0D66DDB99D1D396852CDE9271B97CB8F6C51865AAE4AE06C7D6D1D869E659A76C3AE219C4105389CA9782A7D07C2C43943F055F543A86E6D9348DFCBFE42C732B65FF0021730F1BB33C59E553E1E9F32DA4320B427844DE20CE0192813B8814468AA356911C1F0F234FBB23952B882B4529F327C3DE232585153C3496CC72868C2B12AAE8CFF8797525841EC5CC91A5CA9897B22250E7717737428506BA8AEC691F1C53DEE0956FCAC99619741CE8A168F6AB29C9EDA1055849F32FB890D510DB22BD157F32595156D47CA179FA165C01A4F4A7868F0BF236F0359F528C289730B4ECD0F1BA6793A1C34EE86E3E1C51760E1E3644957E57E875CFF2E6FB7178A5E264122DE3978994EE7959CF35DD8FA3C42110A733C4926924973D3723524B9222A9321750DD6BB1C43D9336F2AA6ED77CCE7B034DCE692FA9D752A7A2B688A91156211F327822184113459B6B4C6D09C6C048B095C6CA3A86895E4EC3A0C7CC8A534B76912AF69A2AE392EA434EB45BB264AACB56F61E92925C295D90E1A9BBB6C745C66ECB958B318D9BE88345B04EDBE818544F6154871475191828AB22827882488155B0F53B8B40268AB5892B54B15E33E29D8930A34F9F5248409386C18211EF434A96A5BA14ECC6D345BA08BC7146557A83D0924B46434C9F91D53D31BFAE671B08F13D0AFDD47A163327C33653550E0CE7F4EAC2F84BDCC7A7DC447DEFA083AC53CF2731B1BB674CFB25FF002FD8970FD968A77752FF00414B34D6D419060AC9C9F3D8E8E952161F06A36B722751639948CAEC15921EB865E628CB4192A6AF75A17DE23AD2EEBA3B10D7AF2868D5CB3119528A96E1F241D68EF1BAE867D5A57776F52FAA7656444B08B76DB0F921EAB3A7525192518DCBD42B29DE36DB72C2C320D2C3A8BBA17782CA9A9C5475EA19D6493239C5BE62846DABD5A1F7C53D2A4727C3D0AF4632726DBF0F25CC92AC78B9830F4781BD5EA2EF0FAD3E74972428F424722054B5BDC3E4C475A188822BE1E094D17AD718A293BD85DF1FD3EB467123A71B325925B8921768571A969A2D512A46687AAF6349C98FEA32C6D69C09E265471AD72439664FA2369CD8FEB3BC7928E7F4ED2BF5315D4D0DEC7CD55B5F4287EED83FE6672E765BE1BE12C9E59B7F311A3FBA61FD52113E5A6D2582817D0319187669A3C57236C78761A240E20261B6A1D868F62889822C5D8B43161686C770DC3B1E8EB82E2020EE5D44371A83242EC344848024299090E616C6098FB1E86E0B886A176D8D1F715C0C2D8FB0D0053197020D97549710D0DC7321D4930A646D810F67A5AB08878C43D9691B040423350B247C84202A68E6210E7B338084215010131080A9442C420327B8A42104070D8EE21125082842182635084107D0B1AC420A62C0210104798FE421150CC605C8421C070842292FFFD9'  where OrganisationId = 'AE82246D-61A1-42C2-ADD7-560A28145801';
update Organisations set isactive = 1;
update Administration set IsActive = 1, AcceptedBy = null where AdministratorId = 'BDA2FBB2-38D9-42E9-8EFC-33B11FECDDB7'
delete from Administration where AdministratorId = '0A26A5EC-E44E-461F-802E-662CB298DA92';

select * from filetypes;

insert into filetypes values (1,'text/plain'), (2,'application/pdf'),(3,'image/jpeg'),(4,'image/png'),(5,'audio/mpeg'),(6,'video/mp4')

insert into FieldTypes values ('Radio'), ('File')

SET IDENTITY_INSERT fieldtypes  ON
truncate table fieldtypes;

update FieldTypes set FieldTypeId=6 where Type = 'Radio'

INSERT INTO fieldtypes 

VALUES (6, 'Radio'), (7,'File') 

SET IDENTITY_INSERT fieldtypes OFF

