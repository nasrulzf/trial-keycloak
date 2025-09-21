-- Idempotent init for Keycloak database & principal
-- Variabel dari sqlcmd: $(KEYCLOAK_DB_PASSWORD)

-- 1) Create database if not exists
PRINT 'Checking Database [keycloak]...';
IF NOT EXISTS (SELECT 1
FROM sys.databases
WHERE name = N'keycloak')
BEGIN
    PRINT 'Creating database [keycloak]...';
    CREATE DATABASE [keycloak];
END
ELSE
BEGIN
    PRINT 'Database [keycloak] already exists.';
END
GO

-- 2) Create server login if not exists
PRINT 'Checking LOGIN [keycloak_user]...';
IF NOT EXISTS (SELECT 1
FROM sys.server_principals
WHERE name = N'keycloak_user')
BEGIN
    PRINT 'Creating LOGIN [keycloak_user]...';
    DECLARE @sql NVARCHAR(MAX) = N'CREATE LOGIN [keycloak_user] WITH PASSWORD = ''' + REPLACE(CONVERT(NVARCHAR(4000), '$(KEYCLOAK_DB_PASSWORD)'), '''', '''''') + N''', CHECK_POLICY=ON, CHECK_EXPIRATION=OFF;';
    EXEC(@sql);
END
ELSE
BEGIN
    PRINT 'LOGIN [keycloak_user] already exists.';
END
GO

-- 3) Create database user mapped to login if not exists
PRINT 'Checking USER [keycloak_user] in database [keycloak]...';
USE [keycloak];
GO
IF NOT EXISTS (SELECT 1
FROM sys.database_principals
WHERE name = N'keycloak_user')
BEGIN
    PRINT 'Creating USER [keycloak_user] for LOGIN [keycloak_user]...';
    CREATE USER [keycloak_user] FOR LOGIN [keycloak_user];
END
ELSE
BEGIN
    PRINT 'USER [keycloak_user] already exists.';
END
GO

-- 4) Grant role membership db_owner
PRINT 'Checking ROLE db_owner for USER [keycloak_user]...';
IF NOT EXISTS (
    SELECT 1
FROM sys.database_role_members drm
    JOIN sys.database_principals r ON r.principal_id = drm.role_principal_id AND r.name = N'db_owner'
    JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id AND m.name = N'keycloak_user'
)
BEGIN
    PRINT 'Adding [keycloak_user] to db_owner...';
    EXEC sp_addrolemember N'db_owner', N'keycloak_user';
END
ELSE
BEGIN
    PRINT '[keycloak_user] already in db_owner.';
END
GO

PRINT 'Keycloak DB/user/role init done.';
GO