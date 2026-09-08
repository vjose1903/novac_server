module Calendar
  class EventsController < ApplicationController
    def index
      resultado = CalendarEvent.get_events_by_range(params, get_parametros_opcionales)
      resultado.send_response self
    end

    def create
      resultado = CalendarEvent.create_event(params)
      resultado.send_response self
    end

    def update
      resultado = CalendarEvent.update_event(params)
      resultado.send_response self
    end

    def destroy
      resultado = CalendarEvent.delete_event(params)
      resultado.send_response self
    end

    def get_parametros_opcionales
      {
        all: true,
        links: validate_optional_param(params, 'links') ? params['links'].to_boolean : false
      }
    end
  end
end
