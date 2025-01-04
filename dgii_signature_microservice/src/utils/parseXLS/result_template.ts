export const result = {
    "ECF": {
      "Encabezado": {
        "Version": "",
        "IdDoc": {
          "TipoeCF": "",
          "eNCF": "",
          "FechaVencimientoSecuencia": "",
          "IndicadorEnvioDiferido": "",
          "IndicadorMontoGravado": "",
          "IndicadorServicioTodoIncluido": "",
          "TipoIngresos": "",
          "TipoPago": "",
          "FechaLimitePago": "",
          "TerminoPago": "",
          "TablaFormasPago": {
            "FormaDePago": [
              {
                "FormaPago": "",
                "MontoPago": ""
              },
            ]
          },
          "TipoCuentaPago": "",
          "NumeroCuentaPago": "",
          "BancoPago": "",
          "FechaDesde": "",
          "FechaHasta": "",
          "TotalPaginas": ""
        },
        "Emisor": {
          "RNCEmisor": "",
          "RazonSocialEmisor": "",
          "NombreComercial": "",
          "Sucursal": "",
          "DireccionEmisor": "",
          "Municipio": "",
          "Provincia": "",
          "TablaTelefonoEmisor": {
            "TelefonoEmisor": [""]
          },
          "CorreoEmisor": "",
          "WebSite": "",
          "ActividadEconomica": "",
          "CodigoVendedor": "",
          "NumeroFacturaInterna": "",
          "NumeroPedidoInterno": "",
          "ZonaVenta": "",
          "RutaVenta": "",
          "InformacionAdicionalEmisor": "",
          "FechaEmision": ""
        },
        "Comprador": {
          "RNCComprador": "",
          "RazonSocialComprador": "",
          "ContactoComprador": "",
          "CorreoComprador": "",
          "DireccionComprador": "",
          "MunicipioComprador": "",
          "ProvinciaComprador": "",
          "FechaEntrega": "",
          "ContactoEntrega": "",
          "DireccionEntrega": "",
          "TelefonoAdicional": "",
          "FechaOrdenCompra": "",
          "NumeroOrdenCompra": "",
          "CodigoInternoComprador": "",
          "ResponsablePago": "",
          "InformacionAdicionalComprador": ""
        },
        "InformacionesAdicionales": {
          "FechaEmbarque": "",
          "NumeroEmbarque": "",
          "NumeroContenedor": "",
          "NumeroReferencia": "",
          "PesoBruto": "",
          "PesoNeto": "",
          "UnidadPesoBruto": "",
          "UnidadPesoNeto": "",
          "CantidadBulto": "",
          "UnidadBulto": "",
          "VolumenBulto": "",
          "UnidadVolumen": ""
        },
        "Transporte": {
          "Conductor": "",
          "DocumentoTransporte": "",
          "Ficha": "",
          "Placa": "",
          "RutaTransporte": "",
          "ZonaTransporte": "",
          "NumeroAlbaran": ""
        },
        "Totales": {
          "MontoGravadoTotal": "",
          "MontoGravadoI1": "",
          "MontoGravadoI2": "",
          "MontoGravadoI3": "",
          "MontoExento": "",
          "ITBIS1": "",
          "ITBIS2": "",
          "ITBIS3": "",
          "TotalITBIS": "",
          "TotalITBIS1": "",
          "TotalITBIS2": "",
          "TotalITBIS3": "",
          "MontoImpuestoAdicional": "",
          "ImpuestosAdicionales": {
            "ImpuestoAdicional": [
              {
                "TipoImpuesto": "",
                "TasaImpuestoAdicional": "",
                "MontoImpuestoSelectivoConsumoEspecifico": "",
                "MontoImpuestoSelectivoConsumoAdvalorem": "",
                "OtrosImpuestosAdicionales": ""
              },
            ]
          },
          "MontoTotal": "",
          "MontoNoFacturable": "",
          "MontoPeriodo": "",
          "SaldoAnterior": "",
          "MontoAvancePago": "",
          "ValorPagar": "",
          "TotalITBISRetenido": "",
          "TotalISRRetencion": "",
          "TotalITBISPercepcion": "",
          "TotalISRPercepcion": ""
        },
        "OtraMoneda": {
          "TipoMoneda": "",
          "TipoCambio": "",
          "MontoGravadoTotalOtraMoneda": "",
          "MontoGravado1OtraMoneda": "",
          "MontoGravado2OtraMoneda": "",
          "MontoGravado3OtraMoneda": "",
          "MontoExentoOtraMoneda": "",
          "TotalITBISOtraMoneda": "",
          "TotalITBIS1OtraMoneda": "",
          "TotalITBIS2OtraMoneda": "",
          "TotalITBIS3OtraMoneda": "",
          "MontoImpuestoAdicionalOtraMoneda": "",
          "ImpuestosAdicionalesOtraMoneda": {
            "ImpuestoAdicionalOtraMoneda": [
              {
                "TipoImpuestoOtraMoneda": "",
                "TasaImpuestoAdicionalOtraMoneda": "",
                "MontoImpuestoSelectivoConsumoEspecificoOtraMoneda": "",
                "MontoImpuestoSelectivoConsumoAdvaloremOtraMoneda": "",
                "OtrosImpuestosAdicionalesOtraMoneda": ""
              },
            ]
          },
          "MontoTotalOtraMoneda": ""
        }
      },
      "DetallesItems": {
        "Item": [
          {
            "NumeroLinea": "",
            "TablaCodigosItem": {
              "CodigosItem": [
                {
                  "TipoCodigo": "TipoCodigo1",
                  "CodigoItem": "CodigoItem1"
                }
              ]
            },
            "IndicadorFacturacion": "",
            "Retencion": {
              "IndicadorAgenteRetencionoPercepcion": "",
              "MontoITBISRetenido": "",
              "MontoISRRetenido": ""
            },
            "NombreItem": "",
            "IndicadorBienoServicio": "",
            "DescripcionItem": "",
            "CantidadItem": "",
            "UnidadMedida": "",
            "CantidadReferencia": "",
            "UnidadReferencia": "",
            "TablaSubcantidad": {
              "SubcantidadItem": [
                {
                  "Subcantidad": "",
                  "CodigoSubcantidad": ""
                }
              ]
            },
            "GradosAlcohol": "",
            "PrecioUnitarioReferencia": "",
            "FechaElaboracion": "",
            "FechaVencimientoItem": "",
            "PrecioUnitarioItem": "",
            "DescuentoMonto": "",
            "TablaSubDescuento": {
              "SubDescuento": [
                {
                  "TipoSubDescuento": "",
                  "SubDescuentoPorcentaje": "",
                  "MontoSubDescuento": ""
                },
              ]
            },
            "RecargoMonto": "",
            "TablaSubRecargo": {
              "SubRecargo": [
                {
                  "TipoSubRecargo": "",
                  "SubRecargoPorcentaje": "",
                  "MontoSubRecargo": ""
                }
              ]
            },
            "TablaImpuestoAdicional": {
              "ImpuestoAdicional": [
                {
                  "TipoImpuesto": ""
                }
              ]
            },
            "OtraMonedaDetalle": {
              "PrecioOtraMoneda": "",
              "DescuentoOtraMoneda": "",
              "RecargoOtraMoneda": "",
              "MontoItemOtraMoneda": ""
            },
            "MontoItem": ""
          }
        ]
      },
      "Subtotales": {
        "Subtotal": [
          {
            "NumeroSubTotal": "",
            "DescripcionSubtotal": "",
            "Orden": "",
            "SubTotalMontoGravadoTotal": "",
            "SubTotalMontoGravadoI1": "",
            "SubTotalMontoGravadoI2": "",
            "SubTotalMontoGravadoI3": "",
            "SubTotaITBIS": "",
            "SubTotaITBIS1": "",
            "SubTotaITBIS2": "",
            "SubTotaITBIS3": "",
            "SubTotalImpuestoAdicional": "",
            "SubTotalExento": "",
            "MontoSubTotal": "",
            "Lineas": ""
          },
        ]
      },
      "DescuentosORecargos": {
        "DescuentoORecargo": [
          {
            "NumeroLinea": "",
            "TipoAjuste": "",
            "IndicadorNorma1007": "",
            "DescripcionDescuentooRecargo": "",
            "TipoValor": "",
            "ValorDescuentooRecargo": "",
            "MontoDescuentooRecargo": "",
            "MontoDescuentooRecargoOtraMoneda": "",
            "IndicadorFacturacionDescuentooRecargo": ""
          },
        ]
      },
      "Paginacion": {
        "Pagina": [
          {
            "PaginaNo": "",
            "NoLineaDesde": "",
            "NoLineaHasta": "",
            "SubtotalMontoGravadoPagina": "",
            "SubtotalMontoGravado1Pagina": "",
            "SubtotalMontoGravado2Pagina": "",
            "SubtotalMontoGravado3Pagina": "",
            "SubtotalExentoPagina": "",
            "SubtotalItbisPagina": "",
            "SubtotalItbis1Pagina": "",
            "SubtotalItbis2Pagina": "",
            "SubtotalItbis3Pagina": "",
            "SubtotalImpuestoAdicionalPagina": "",
            "SubtotalImpuestoAdicional": {
              "SubtotalImpuestoSelectivoConsumoEspecificoPagina": "",
              "SubtotalOtrosImpuesto": ""
            },
            "MontoSubtotalPagina": "",
            "SubtotalMontoNoFacturablePagina": ""
          },
        ]
      },
      "InformacionReferencia": {
        "NCFModificado": "",
        "RNCOtroContribuyente": "",
        "FechaNCFModificado": "",
        "CodigoModificacion": ""
      },
      "FechaHoraFirma": "",
    }
  };