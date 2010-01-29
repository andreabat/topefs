CREATE TABLE [budgetitems] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[budget_id] integer  NOT NULL,
[quantity] NUMERIC  NULL,
[cost] FLOAT  NULL,
[price] FLOAT  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[category_id] INTEGER  NULL,
[description] text  NULL
);
CREATE TABLE [budgets] (
[id] INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
[project_id] integer  NOT NULL,
[user_id] integer  NOT NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL
);
CREATE TABLE [categories] (
[category] NVARCHAR(200)  NOT NULL,
[id] INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT
);
CREATE TABLE [companies] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[ragionesociale] varchar(255)  NULL,
[indirizzo] varchar(255)  NULL,
[comune] varchar(255)  NULL,
[cap] varchar(255)  NULL,
[prov] varchar(255)  NULL,
[coordinatebancarie] varchar(255)  NULL,
[telefono] varchar(255)  NULL,
[partitaiva] varchar(255)  NULL,
[codicefiscale] varchar(255)  NULL,
[email] varchar(255)  NULL,
[fax] varchar(255)  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[logo] nvarchar(150)  NULL,
[rea] nvarchar(200)  NULL,
[web] NVARCHAR(200)  NULL
);
CREATE TABLE [customers] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[ragionesociale] varchar(255)  NOT NULL,
[partitaiva] varchar(11)  UNIQUE NOT NULL,
[codicefiscale] char(16)  NULL,
[indirizzo] varchar(255)  NULL,
[civico] varchar(15)  NULL,
[comune] varchar(255)  NULL,
[cap] varchar(6)  NULL,
[prov] char(2)  NULL,
[note] text  NULL,
[telefono] varchar(25)  NULL,
[fax] varchar(25)  NULL,
[email] varchar(150)  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[coordinatebancarie] text  NULL
);
CREATE TABLE customers_ALTER_BACKUP_1202465654(
  id INTEGER,
  ragionesociale varchar(255),
  partitaiva varchar(255),
  codicefiscale varchar(255),
  indirizzo varchar(255),
  civico varchar(255),
  comune varchar(255),
  cap varchar(255),
  prov varchar(255),
  note text,
  telefono varchar(255),
  fax varchar(255),
  email varchar(255),
  created_at datetime,
  updated_at datetime
);
CREATE TABLE [documents] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[project_id] INTEGER  NOT NULL,
[doc] NVARCHAR(400)  NULL,
[user_id] integer  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[doctype] nvarchar(20)  NULL
);
CREATE TABLE [orderitems] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[order_id] integer  NOT NULL,
[quantity] NUMERIC  NULL,
[cost] FLOAT  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[description] text  NULL
);
CREATE TABLE [orders] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[project_id] INTEGER  NOT NULL,
[user_id] INTEGER  NULL,
[budget_id] INTEGER  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[title] nvarchar(150)  NULL,
[delivery] nvarchar(100)  NULL,
[vat] INTEGER  NULL,
[supplier_id] integer  NULL,
[paymentmethod_id] INTEGER  NULL,
[people] TEXT  NULL,
[notes] TEXT  NULL,
[document_id] INTEGER  NULL
);
CREATE TABLE [paymentmethods] (
[id] INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
[paymentmethod] NVARCHAR(100)  NULL
);
CREATE TABLE [pricingitems] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[pricing_id] integer  NOT NULL,
[quantity] NUMERIC  NULL,
[cost] FLOAT  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[description] text  NULL,
[category_id] INTEGER  NULL
);
CREATE TABLE [pricings] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[project_id] INTEGER  NOT NULL,
[user_id] INTEGER  NULL,
[budget_id] INTEGER  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[code] nvarchar(20)  NULL,
[year] INTEGER  NULL,
[title] nvarchar(150)  NULL,
[customer_id] integer  NULL,
[paymentmethod_id] INTEGER  NULL,
[invoicing] nvarchar(100)  NULL,
[delivery] nvarchar(100)  NULL,
[people] TEXT  NULL,
[notes] TEXT  NULL,
[document_id] INTEGER  NULL
);
CREATE TABLE [projects] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[title] varchar(255) DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[start] date DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[end] date DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[note] text DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[customer_id] integer DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[company_id] integer DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[created_at] datetime DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[updated_at] datetime DEFAULT '''''''''''''''''''''''''''''''NULL''''''''''''''''''''''''''''''' NULL,
[status_id] integer  NULL,
[contact] NVARCHAR(150)  NULL,
[code] NVARCHAR(10)  NULL,
[year] char(4)  NULL
);
CREATE TABLE roles ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar(255) DEFAULT NULL);
CREATE TABLE roles_users ("role_id" integer DEFAULT NULL, "user_id" integer DEFAULT NULL);
CREATE TABLE schema_info (version integer);
CREATE TABLE status ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "status" varchar(255) DEFAULT NULL, "created_at" datetime DEFAULT NULL, "updated_at" datetime DEFAULT NULL);
CREATE TABLE [suppliers] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[ragionesociale] varchar(255)  NOT NULL,
[partitaiva] varchar(11)  UNIQUE NOT NULL,
[codicefiscale] vchar(16)  NULL,
[indirizzo] varchar(255)  NULL,
[civico] varchar(15)  NULL,
[comune] varchar(255)  NULL,
[cap] varchar(6)  NULL,
[prov] char(2)  NULL,
[note] text  NULL,
[telefono] varchar(25)  NULL,
[fax] varchar(25)  NULL,
[email] varchar(150)  NULL,
[coordinatebancarie] TEXT  NULL,
[created_at] datetime  NULL,
[updated_at] datetime  NULL,
[paymentmethod_id] INTEGER  NULL
);
CREATE TABLE suppliers_ALTER_BACKUP_1202731722(
  id INTEGER,
  ragionesociale varchar(255),
  partitaiva varchar(255),
  codicefiscale varchar(255),
  indirizzo varchar(255),
  civico varchar(255),
  comune varchar(255),
  cap varchar(255),
  prov varchar(255),
  note text,
  telefono varchar(255),
  fax varchar(255),
  email varchar(255),
  coordinatebancarie varchar(255),
  created_at datetime,
  updated_at datetime
);
CREATE TABLE [users] (
[id] INTEGER  PRIMARY KEY AUTOINCREMENT NOT NULL,
[login] varchar(255) DEFAULT '''NULL''' NULL,
[email] varchar(255) DEFAULT '''NULL''' NULL,
[crypted_password] varchar(40) DEFAULT '''NULL''' NULL,
[salt] varchar(40) DEFAULT '''NULL''' NULL,
[created_at] datetime DEFAULT '''NULL''' NULL,
[updated_at] datetime DEFAULT '''NULL''' NULL,
[remember_token] varchar(255) DEFAULT '''NULL''' NULL,
[remember_token_expires_at] datetime DEFAULT '''NULL''' NULL,
[active] BOOLEAN  NULL,
[nominativo] NVARCHAR(20)  NULL
);
CREATE TABLE xp_proc ("view_name" varchar(20) DEFAULT NULL, "param_list" varchar(255) DEFAULT NULL, "xSQL" text DEFAULT NULL, "def_param" varchar(255) DEFAULT NULL, "opt_param" varchar(255) DEFAULT NULL, "comment" text DEFAULT NULL);
CREATE INDEX "index_roles_users_on_role_id" ON roles_users ("role_id");
CREATE INDEX "index_roles_users_on_user_id" ON roles_users ("user_id");
INSERT INTO schema_info (version) VALUES (12)