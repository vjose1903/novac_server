class Health
  def self.base
    checks = {
      database: database_check,
      migrations: migrations_check
    }

    overall_status = checks.values.all? { |check| check[:status] == "ok" || check[:status] == "skipped" } ? :ok : :service_unavailable

    build_response(
      overall_status,
      {
        status: overall_status == :ok ? "ok" : "error",
        timestamp: Time.current.iso8601,
        checks: checks
      }
    )
  end
  # --------------------------------------------------------------------------------------------------------------------------------------------------

  def self.dgii
    check = dgii_microservice_check
    status = check[:status] == "ok" ? :ok : :service_unavailable

    build_response(
      status,
      {
        status: status == :ok ? "ok" : "error",
        timestamp: Time.current.iso8601,
        checks: {
          dgii: check
        }
      }
    )
  end
  # --------------------------------------------------------------------------------------------------------------------------------------------------

  def self.build_response(status, payload)
    response = Response.new(nil, status == :ok ? HTTP_STATUS_CODE[:ok] : HTTP_STATUS_CODE[:service_unavailable], nil, [])
    response.set_data(payload)
    response
  end

  private_class_method :build_response

  def self.database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok" }
  rescue => error
    { status: "down", error: error.message }
  end


  # ===================================================================================================================================================
  private_class_method :database_check

  def self.migrations_check
    migration_context = ActiveRecord::Base.connection_pool.migration_context
    pending_migrations = migration_context.pending_migration_versions

    if pending_migrations.empty?
      { status: "ok", pending_migrations: 0 }
    else
      {
        status: "down",
        pending_migrations: pending_migrations.size,
        versions: pending_migrations.map(&:to_s)
      }
    end
  rescue => error
    { status: "down", error: error.message }
  end

  # ===================================================================================================================================================
  private_class_method :migrations_check

  def self.dgii_microservice_check
    validation = DGII_MANAGER.auth_test
    data = validation.get_data.is_a?(Hash) ? validation.get_data.with_indifferent_access : {}

    if validation.status_valid && data[:token].present?
      {
        status: "ok",
        microservice_status: validation.get_status,
        auth: "ok",
        message: validation.get_msgs.to_a.join(", ").presence || "Autenticación DGII exitosa"
      }
    else
      {
        status: "down",
        microservice_status: validation.get_status,
        auth: "failed",
        message: validation.get_msgs.to_a.join(", ").presence || "El microservicio DGII no respondió correctamente",
        data: data.slice(:expira, :expedido)
      }
    end
  rescue => error
    {
      status: "down",
      auth: "failed",
      error: error.message
    }
  end
  private_class_method :dgii_microservice_check
end
