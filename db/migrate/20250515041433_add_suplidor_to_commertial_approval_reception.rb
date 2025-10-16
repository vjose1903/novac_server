class AddSuplidorToCommertialApprovalReception < ActiveRecord::Migration[7.0]
  def up
    unless column_exists?(:commertial_approval_receptions, :suplidor_id)
      add_reference :commertial_approval_receptions, :suplidor, foreign_key: true, null: true, index: true
    end
  end

  def down
    if column_exists?(:commertial_approval_receptions, :suplidor_id)
      remove_reference :commertial_approval_receptions, :suplidor
    end
  end
end
