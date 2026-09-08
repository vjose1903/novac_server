class ChangeReferenceTasaCambioUserToAllowNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tasas_de_cambio, :user_id, true
  end
end
