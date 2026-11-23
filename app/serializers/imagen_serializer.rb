class ImagenSerializer < ActiveModel::Serializer
  attribute :id,                       if: Proc.new { self.get_param('id') || self.get_param('all') }
  attribute :file_name,                if: Proc.new { self.get_param('file_name') || self.get_param('all') }
  attribute :base_64,                  if: Proc.new { self.get_param('base_64') || self.get_param('all') }

	def get_param(col)
		return @instance_options[:"#{col}"]
	end
end
