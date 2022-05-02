CREATE PROCEDURE [App].[usp_TraceFlagInventory_CALC_Insert]

AS

BEGIN

	SET NOCOUNT ON;

	DECLARE @Me VARCHAR(64) = CONCAT(OBJECT_SCHEMA_NAME(@@PROCID), '.',OBJECT_NAME(@@PROCID))
	DECLARE @CensusDate DATETIME = GETDATE()

	BEGIN TRY

		BEGIN TRANSACTION

			INSERT INTO Inventory.TraceFlags(TraceFlag,Status,Global,Session) 
			EXEC('DBCC TRACESTATUS(-1);')

		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0 
		ROLLBACK TRANSACTION

	EXEC [App].[usp_InsertRunLog] @ProcedureName = @Me, @Action = 'ERROR'

	INSERT INTO App.SQL_Errors ([Username], [Error_Number], [ERROR_STATE], [ERROR_SEVERITY], [ERROR_LINE], [stored_Procedure], [ERROR_MESSAGE], [EventDate])
	VALUES
		(
		SUSER_SNAME(),
		ERROR_NUMBER(),
		ERROR_STATE(),
		ERROR_SEVERITY(),
		ERROR_LINE(),
		ERROR_PROCEDURE(),
		ERROR_MESSAGE(),
		GETDATE()
		);

	END CATCH
END