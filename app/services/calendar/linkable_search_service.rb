module Calendar
  class LinkableSearchService
    DEFAULT_PAGE = 1
    DEFAULT_PER_PAGE = 20

    def initialize(params)
      @params = params
    end

    def call
      res = Response.new
      config = LinkableRegistry[@params[:entity_type].to_s]

      unless config
        res.add_msg('Tipo de entidad no permitido para calendario.')
        res.set_status(HTTP_STATUS_CODE[:bad_request])
        return res
      end

      page = page_value
      per_page = per_page_value
      records = config[:relation].call
      records = records.where(config[:search_sql], q: "%#{ActiveRecord::Base.sanitize_sql_like(@params[:q].to_s)}%") if @params[:q].present?

      total = records.count
      paginated = records.offset((page - 1) * per_page).limit(per_page)

      res.set_data(
        {
          records: paginated.map { |record| serialize_record(record, config) },
          pagination: {
            page: page,
            per_page: per_page,
            total: total,
            total_pages: (total.to_f / per_page).ceil
          }
        }
      )
      res
    end

    private

    def page_value
      value = @params[:page].to_i
      value.positive? ? value : DEFAULT_PAGE
    end

    def per_page_value
      value = @params[:per_page].to_i
      value.positive? ? [value, 100].min : DEFAULT_PER_PAGE
    end

    def serialize_record(record, config)
      {
        id: record.id,
        label: safe_public_send(record, config[:label_method]),
        subtitle: safe_public_send(record, config[:subtitle_method]),
        entity_type: record.class.name,
        metadata: {}
      }
    end

    def safe_public_send(record, method_name)
      return nil if method_name.blank? || !record.respond_to?(method_name)

      record.public_send(method_name)
    end
  end
end
