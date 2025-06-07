if Rails.const_defined?(:Console)
  Rails.logger = Logger.new($stdout)
  Rails.logger.level = Logger::DEBUG

  readonly   = ENV.fetch("readonly", nil)
  db_config  = ActiveRecord::Base.connection_db_config
  db_name    = db_config.database
  db_env     = Rails.env

  is_safe_env  = db_env.development? || db_env.test?
  is_safe_name = db_name.end_with?("_development", "_test")
  is_unexpected = !(is_safe_env && is_safe_name)

  if is_unexpected && readonly.nil?
    Rails.logger.error { "🚨 WARNING: You are connected to an unexpected database: '#{db_name}' (env: #{db_env})" }
    Rails.logger.error { "❌ Console session aborted for safety." }
    Rails.logger.error { "➤ Use 'readonly=true' to allow read-only access" }
    Rails.logger.error { "➤ Use 'readonly=false' to allow full access (be careful!)" }
    abort
  end

  if readonly.present?
    db_url = ENV.fetch("DATABASE_URL", nil)
    if db_url.blank?
      Rails.logger.fatal { "❌ DATABASE_URL is not set. Cannot establish connection." }
      abort
    end

    ActiveRecord::Base.establish_connection(db_url)
    db_name = ActiveRecord::Base.connection_db_config.database
    Rails.logger.info { "🌐 Connected to database: #{db_name}" }

    if readonly == "true"
      Rails.logger.info { "🔒 Console in READ-ONLY mode (readonly=true)" }

      module ActiveRecord
        class Base
          def readonly? = true

          def readonly!
            raise ActiveRecord::ReadOnlyRecord, "This console is in read-only mode (readonly=true)"
          end

          before_save    :readonly!
          before_create  :readonly!
          before_update  :readonly!
          before_destroy :readonly!
        end
      end
    else
      Rails.logger.warn { "⚠️ FULL ACCESS granted to remote database (readonly=false)" }
    end
  else
    Rails.logger.debug { "🛠️ Safe console session (#{db_env}) using '#{db_name}' — access allowed" }
  end
end
