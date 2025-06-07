# Safe Console Access for Rails

This script enhances **Rails console safety** by restricting access to production-like databases unless explicitly authorized via environment variables. It helps avoid accidental writes or destructive operations on sensitive environments.

## 🔒 Purpose

Prevent accidental modification of **production or staging databases** when accessing the Rails console by mistake or misconfiguration.

## 🚦 Behavior Overview

This initializer runs **only when the Rails console is invoked**, and:

1. Detects if you're connecting to a potentially unsafe environment (non-development/test).
2. Aborts the session unless `readonly` or `readonly=false` is explicitly set.
3. Enforces **read-only mode** if `readonly=true`.
4. Logs clearly what mode you're in and what database is connected.

---

## ⚙️ Environment Variables

- `readonly=true`  
  👉 Enables **read-only** mode. All write operations (save, update, delete) will raise an error.
  
- `readonly=false`  
  ⚠️ Enables **full write** access to the database. Use with caution!

- `DATABASE_URL`  
  Required when using `readonly=true` or `readonly=false` to connect to a remote database.

---

## 🧪 Safe Environments

The script automatically allows full access if:

- `Rails.env` is `development` or `test`, **AND**
- The database name ends with `_development` or `_test`

Otherwise, you must explicitly allow access.

---

## 📌 Example Usage

```bash
# Default behavior in development (allowed):
bin/rails console

# Aborts in production-like environments unless readonly is specified:
RAILS_ENV=production bin/rails console

# Safe read-only access:
readonly=true RAILS_ENV=production DATABASE_URL=postgres://... bin/rails console

# Full access (not recommended):
readonly=false RAILS_ENV=production DATABASE_URL=postgres://... bin/rails console
```

📢 Logs & Warnings
The logger provides clear visual feedback:
```bash
🔒 Read-only mode enforced

⚠️ Full access granted

🚨 Unexpected database or environment

❌ Session aborted

🛠️ Safe session
```

```bash
✅ Example Output (Read-only mode)

🌐 Connected to database: myapp_production
🔒 Console in READ-ONLY mode (readonly=true)
```

```bash
❌ Example Output (Unsafe access attempt)

🚨 WARNING: You are connected to an unexpected database: 'myapp_production' (env: production)
❌ Console session aborted for safety.
➤ Use 'readonly=true' to allow read-only access
➤ Use 'readonly=false' to allow full access (be careful!)
```

```bash
📂 Placement
Save this script in:

config/initializers/safe_console.rb
```

I hope u enjoy it.
