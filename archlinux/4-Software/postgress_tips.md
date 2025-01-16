# Arch Linux: Managing PostgreSQL Users, Databases, and Roles

This guide provides instructions for managing PostgreSQL users, roles, databases, and related privileges. It includes commands for viewing users, terminating active connections, and deleting users and databases, as well as managing privileges and ownership.

## Table of Contents

- [1. List PostgreSQL Users (Roles)](#1-list-postgresql-users-roles)
- [2. Terminate Active Connections for Databases](#2-terminate-active-connections-for-databases)
- [3. Drop Databases](#3-drop-databases)
- [4. Drop Users](#4-drop-users)
- [5. Verify Results](#5-verify-results)
- [6. Identify Objects Associated with a Role](#6-identify-objects-associated-with-a-role)
- [7. Revoke Role Privileges](#7-revoke-role-privileges)
- [8. Drop Objects Owned by a Role](#8-drop-objects-owned-by-a-role)
- [9. Drop the Role](#9-drop-the-role)

---

## 1. List PostgreSQL Users (Roles)

To list all PostgreSQL users (roles), execute one of the following commands:

### Using SQL:

```sql
SELECT rolname FROM pg_roles;
```

### Using `psql` Command:

```bash
sudo -u postgres psql
\du
```

This will display a list of users with their roles and associated privileges.

### Example Output:
```plaintext
  Role Name    | Attributes | Member of
---------------+------------+-----------
 postgres      | Superuser  | {}
 corso_user    |            | {}
 user_test     |            | {}
```

---

## 2. Terminate Active Connections for Databases

To terminate active connections for a specific database (e.g., `corso_fullstack`), run the following SQL query:

```sql
SELECT pg_terminate_backend(pg_stat_activity.pid)
FROM pg_stat_activity
WHERE datname = 'corso_fullstack'
  AND pid <> pg_backend_pid();
```

This will disconnect all other users from the specified database.

---

## 3. Drop Databases

Once the active connections are terminated, you can drop the database using the `DROP DATABASE` command. Example:

```sql
DROP DATABASE corso_fullstack;
DROP DATABASE prova;
DROP DATABASE provola;
DROP DATABASE your_database_name;
```

---

## 4. Drop Users

Before deleting a user, ensure that they do not own any objects in the database. If needed, transfer ownership of databases. Example:

```sql
ALTER DATABASE provola OWNER TO postgres;
```

Once ownership has been reassigned, you can drop the user with the following commands:

```sql
DROP USER user_corso;
DROP USER corso_user;
```

---

## 5. Verify Results

You can verify the deletion of databases and users by running the following commands:

### List Databases:
```sql
\l
```

### List Users:
```sql
\du
```

---

## 6. Identify Objects Associated with a Role

To identify the objects or privileges dependent on a role (e.g., `corso_user`), run the following SQL query:

```sql
SELECT grantee, privilege_type, table_schema, table_name
FROM information_schema.role_table_grants
WHERE grantee = 'corso_user';
```

You can also check privileges at the schema level:

```sql
SELECT *
FROM information_schema.role_usage_grants
WHERE grantee = 'corso_user';
```

---

## 7. Revoke Role Privileges

To revoke all privileges associated with a role (e.g., `corso_user`), use the `REVOKE` command. Examples:

### Revoke privileges on a schema:
```sql
REVOKE ALL ON SCHEMA public FROM corso_user;
```

### Revoke privileges on specific objects (e.g., tables):
```sql
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM corso_user;
```

---

## 8. Drop Objects Owned by a Role

If the role owns any objects (e.g., tables, sequences, etc.), you can either transfer the ownership to another role or delete the objects. To transfer ownership:

```sql
ALTER TABLE nome_tabella OWNER TO postgres;
ALTER SEQUENCE nome_sequenza OWNER TO postgres;
```

Alternatively, you can drop the objects:

```sql
DROP TABLE nome_tabella;
DROP SEQUENCE nome_sequenza;
```

---

## 9. Drop the Role

After removing all the associated privileges and objects, you can now drop the role with the following command:

```sql
DROP ROLE corso_user;
```

---
