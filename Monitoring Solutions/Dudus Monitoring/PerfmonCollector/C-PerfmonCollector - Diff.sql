USE [DB_DBA] 
GO 

ALTER TABLE [Perfmon].[CounterCollector] ALTER COLUMN [CounterValue]	DECIMAL(19,3)

SET IDENTITY_INSERT [Perfmon].[CountersType] ON
INSERT INTO  [Perfmon].[CountersType] (Id, Origin)
	VALUES (2,'Perfmon')
SET IDENTITY_INSERT [Perfmon].[CountersType] OFF

SET IDENTITY_INSERT [Perfmon].[Counters] ON
INSERT INTO  [Perfmon].[Counters] (Id, TypeId, DisplayName, CounterName, InstanceName, ObjectName )
VALUES 
(14,2,N'CPU usage %',				N'% Processor Time',		N'_Total',		N'Processor'),
(15,2,N'Memory- Available MB',		N'Available MBytes',		N'',			N'Memory'),
(16,2,N'Memory- Pages Input/sec',	N'Pages Input/sec',			N'',			N'Memory'),
(17,2,N'Paging File Usage %',		N'% Usage',					N'_Total',		N'Paging File'),
(18,2,N'Paging File Usage Peak %',	N'% Usage Peak',			N'_Total',		N'Paging File')
SET IDENTITY_INSERT [Perfmon].[Counters] OFF


CREATE TYPE [Perfmon].[CounterCollectorType] AS TABLE 
(
	[CounterId]		[bigint] NOT NULL,
	[CounterValue]	DECIMAL(19,3) NOT NULL
)
GO 

CREATE PROCEDURE [Perfmon].[usp_CounterCollectorOutCall]
	@Table [Perfmon].[CounterCollectorType] READONLY 
AS 
BEGIN 
		BEGIN TRY 

			BEGIN TRAN 

				DECLARE @ProcesseId BIGINT 
				INSERT INTO [Perfmon].[CounterCollectorProcesses] (StartDateTime) VALUES (DEFAULT)

				SELECT @ProcesseId = SCOPE_IDENTITY()

				INSERT INTO [Perfmon].[CounterCollector] ([ProcesseId],[CounterId],[CounterValue]) 
				SELECT @ProcesseId,[CounterId],[CounterValue] FROM @Table

				UPDATE [Perfmon].[CounterCollectorProcesses]
					SET EndDateTime = SYSDATETIME()
				WHERE Id = @ProcesseId

			COMMIT 

		END TRY 

		BEGIN CATCH 
			IF @@TRANCOUNT > 0 
				ROLLBACK;
			THROW;
		END CATCH;
END 
