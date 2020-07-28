# frozen_string_literal: true

require 'mechanize'

module ArgenpropScraper
  @agent = Mechanize.new

  class << self
    def leer_avisos!
      leer_avisos_con_tipo!('ph') + leer_avisos_con_tipo!('casa')
    end

    def leer_avisos_con_tipo!(tipo)
      page = @agent.get "https://www.argenprop.com/#{tipo}-alquiler-region-zona-oeste-hasta-35000-pesos-1-o-m%C3%A1s-cocheras-orden-masnuevos"

      page.search('div.listing-container div.listing__item').map do |aviso|
        link = aviso.search('a').attr('href').value
        {
          id: link.split('-').last,
          tipo: tipo,
          titulo: aviso.search('h3.card__title').text.strip,
          direccion: aviso.search('h2.card__address').text.strip,
          precio: aviso.search('p.card__price').text.strip,
          url: "https://www.argenprop.com#{link}"
        }
      end
    end
  end
end
