class ClientesController < ApplicationController
  before_action :set_cliente, only: [:show, :update, :destroy]

  # GET /clientes
  def index
    @clientes = []

    Cliente.all.each do |cliente|
      if cliente["estado"] == true
        @clientes.push(cliente)
      end
    end
    render json: @clientes
  end

  def getClientesByName
    nom_ = params[:nombre].downcase

    clientes_ = Cliente.where("lower(nombre) LIKE ?", "%" + nom_ + "%")

    @clientes = []
    clientes_.each do |cliente|
      if cliente["estado"] == true && cliente["nombre"] != "Cliente contado"
        @clientes.push(cliente)
      end
    end
    render json: @clientes
  end

  # GET /clientes/1
  def show
    cliente = @cliente
    if cliente["estado"] == false
      cliente = { "nombre": "Este cliente esta desactivado." }
    end
    render json: cliente
  end

  # POST /clientes
  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      render json: @cliente, status: :created, location: @cliente
    else
      render json: @cliente.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clientes/1
  def update
    Cliente.transaction do
      oldDocuments = DocumentoDeIdentidad.where({ cliente_id: params[:id] })[0]

      puts "oldDocuments.nil?".red, oldDocuments.nil?

      unless oldDocuments.nil?
        if oldDocuments.delete()
          puts "ELIMINADO"
        end
      end

      if @cliente.update(cliente_params)
        render json: @cliente
      else
        render json: @cliente.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /clientes/1
  def destroy
    @cliente.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cliente
    @cliente = Cliente.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def cliente_params
    params.require(:cliente).permit(:nombre, :telefono, :direccion, :email, :estado, :apellido,
                                    documento_de_identidad_attributes: [:suplidor_id, :descripcion, :documento])
  end
end
