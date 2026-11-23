class ChangeRncBancoToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :bancos, :rnc, true
  end
end
