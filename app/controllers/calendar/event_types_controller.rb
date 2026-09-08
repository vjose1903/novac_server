module Calendar
  class EventTypesController < ApplicationController
    def index
      resultado = CalendarEventType.get_event_types(params, set_paginate_options(params))
      resultado.send_response self
    end

    def create
      resultado = CalendarEventType.create_update_event_type(params)
      resultado.send_response self
    end

    def update
      resultado = CalendarEventType.create_update_event_type(params)
      resultado.send_response self
    end

    def destroy
      resultado = CalendarEventType.deactivate_event_type(params[:id])
      resultado.send_response self
    end
  end
end
