CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;


DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE TABLE contact_messages (
        "Id" uuid NOT NULL,
        "Name" character varying(120) NOT NULL,
        "Email" character varying(254) NOT NULL,
        "Subject" character varying(160),
        "Message" character varying(5000) NOT NULL,
        "Status" character varying(32) NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_contact_messages" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE TABLE projects (
        "Id" uuid NOT NULL,
        "Title" character varying(160) NOT NULL,
        "Slug" character varying(180) NOT NULL,
        "ShortDescription" character varying(500) NOT NULL,
        "Description" text,
        "ImageUrl" character varying(1000),
        "ProjectUrl" character varying(1000),
        "GithubUrl" character varying(1000),
        "IsPublished" boolean NOT NULL,
        "DisplayOrder" integer NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        "DeletedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_projects" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE TABLE services (
        "Id" uuid NOT NULL,
        "Title" character varying(160) NOT NULL,
        "Slug" character varying(180) NOT NULL,
        "Description" character varying(2000) NOT NULL,
        "Icon" character varying(100),
        "IsPublished" boolean NOT NULL,
        "DisplayOrder" integer NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "UpdatedAtUtc" timestamp with time zone,
        CONSTRAINT "PK_services" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE INDEX "IX_contact_messages_CreatedAtUtc" ON contact_messages ("CreatedAtUtc");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE INDEX "IX_contact_messages_Status" ON contact_messages ("Status");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE INDEX "IX_projects_IsPublished_DisplayOrder" ON projects ("IsPublished", "DisplayOrder");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE UNIQUE INDEX "IX_projects_Slug" ON projects ("Slug");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE INDEX "IX_services_IsPublished_DisplayOrder" ON services ("IsPublished", "DisplayOrder");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    CREATE UNIQUE INDEX "IX_services_Slug" ON services ("Slug");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824115510_InitialCreate') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260824115510_InitialCreate', '8.0.8');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;


DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824122914_AddAdminAuth') THEN
    CREATE TABLE admin_users (
        "Id" uuid NOT NULL,
        "Email" character varying(254) NOT NULL,
        "NormalizedEmail" character varying(254) NOT NULL,
        "PasswordHash" character varying(1000) NOT NULL,
        "IsActive" boolean NOT NULL,
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        "LastLoginAtUtc" timestamp with time zone,
        CONSTRAINT "PK_admin_users" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824122914_AddAdminAuth') THEN
    CREATE INDEX "IX_admin_users_IsActive" ON admin_users ("IsActive");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824122914_AddAdminAuth') THEN
    CREATE UNIQUE INDEX "IX_admin_users_NormalizedEmail" ON admin_users ("NormalizedEmail");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824122914_AddAdminAuth') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260824122914_AddAdminAuth', '8.0.8');
    END IF;
END $EF$;
COMMIT;

START TRANSACTION;


DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824131134_AddAuditLogging') THEN
    CREATE TABLE audit_logs (
        "Id" uuid NOT NULL,
        "AdminUserId" uuid,
        "ActorEmail" character varying(254),
        "Action" character varying(120) NOT NULL,
        "EntityType" character varying(120) NOT NULL,
        "EntityId" character varying(100),
        "Metadata" character varying(2000),
        "TraceId" character varying(100),
        "CreatedAtUtc" timestamp with time zone NOT NULL,
        CONSTRAINT "PK_audit_logs" PRIMARY KEY ("Id")
    );
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824131134_AddAuditLogging') THEN
    CREATE INDEX "IX_audit_logs_AdminUserId" ON audit_logs ("AdminUserId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824131134_AddAuditLogging') THEN
    CREATE INDEX "IX_audit_logs_CreatedAtUtc" ON audit_logs ("CreatedAtUtc");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824131134_AddAuditLogging') THEN
    CREATE INDEX "IX_audit_logs_EntityType_EntityId" ON audit_logs ("EntityType", "EntityId");
    END IF;
END $EF$;

DO $EF$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM "__EFMigrationsHistory" WHERE "MigrationId" = '20260824131134_AddAuditLogging') THEN
    INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
    VALUES ('20260824131134_AddAuditLogging', '8.0.8');
    END IF;
END $EF$;
COMMIT;

