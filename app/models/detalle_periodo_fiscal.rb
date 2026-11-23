class DetallePeriodoFiscal < ApplicationRecord
  belongs_to :periodo_fiscal

  # ============================================================================================================================================

  def self.create_update_detalle(params, padre, is_save=false)
    res                                       = Response.new

    detalle_periodo_fiscal                    = DetallePeriodoFiscal.where(:id => params[:id]).first_or_create

    detalle_periodo_fiscal.enero              = params[:enero]
    detalle_periodo_fiscal.febrero            = params[:febrero]
    detalle_periodo_fiscal.marzo              = params[:marzo]
    detalle_periodo_fiscal.abril              = params[:abril]
    detalle_periodo_fiscal.mayo               = params[:mayo]
    detalle_periodo_fiscal.junio              = params[:junio]
    detalle_periodo_fiscal.julio              = params[:julio]
    detalle_periodo_fiscal.agosto             = params[:agosto]
    detalle_periodo_fiscal.septiembre         = params[:septiembre]
    detalle_periodo_fiscal.octubre            = params[:octubre]
    detalle_periodo_fiscal.noviembre          = params[:noviembre]
    detalle_periodo_fiscal.diciembre          = params[:diciembre]

    detalle_periodo_fiscal.valid?

    detalle_periodo_fiscal.errors.delete(:periodo_fiscal) if !is_save

    if detalle_periodo_fiscal.errors.empty? && (!is_save || (is_save && detalle_periodo_fiscal.save!))
      res.set_data(detalle_periodo_fiscal)
    else
      res.add_msgs(detalle_periodo_fiscal.errors.to_a)
      res.set_status(HTTP_STATUS_CODE[:conflict])
    end

    return res
  end

end
