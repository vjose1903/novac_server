class DocumentReference < ApplicationRecord
  belongs_to :document_origin,     polymorphic: true
  belongs_to :document_referenced, polymorphic: true
  belongs_to :referenced_by,       class_name: 'User'


  def self.create_reference(document_origin, document_referenced)
    res = Response.new

    document_reference                          = DocumentReference.new

    document_reference.document_origin          = document_origin
    document_reference.document_referenced      = document_referenced
    document_reference.referenced_by_id         = get_current_user[:id]
    document_reference.referenced_at            = DateTime.now

    document_reference.valid?

    if document_reference.errors.empty? &&  document_reference.save!
      res.set_data(document_reference)
    else
      res.add_msgs(res_valid.get_msgs.to_a)
      res.add_msgs(document_reference.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
    raise ActiveRecord::Rollback if !document_reference.errors.empty? || !res.status_valid
  end
end
