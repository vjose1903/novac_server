class HealthController < ActionController::API
  def show
    checks = {
      database: database_check,
      migrations: migrations_check
    }

    overall_status = checks.values.all? { |check| check[:status] == "ok" || check[:status] == "skipped" } ? :ok : :service_unavailable

    render json: {
      status: overall_status == :ok ? "ok" : "error",
      timestamp: Time.current.iso8601,
      checks: checks
    }, status: overall_status
  end

  private

  def database_check
    ActiveRecord::Base.connection.execute("SELECT 1")
    { status: "ok" }
  rescue => error
    { status: "down", error: error.message }
  end

  def migrations_check
    migration_context = ActiveRecord::Base.connection.migration_context
    pending_migrations = migration_context.pending_migrations

    if pending_migrations.empty?
      { status: "ok", pending_migrations: 0 }
    else
      {
        status: "down",
        pending_migrations: pending_migrations.size,
        versions: pending_migrations.map { |migration| migration.version.to_s }
      }
    end
    rescue => error
      { status: "down", error: error.message }
  end
end
