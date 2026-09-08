class CreateDocumentReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :document_references do |t|
      t.references :document_origin,     polymorphic: true, null: false
      t.references :document_referenced, polymorphic: true, null: false
      t.datetime   :referenced_at
      t.references :referenced_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
