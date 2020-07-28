# frozen_string_literal: true

require 'mechanize'

module Scraper
  def agent
    Mechanize.new
  end

  def leer_avisos!
    tipos.flat_map { |t| leer_avisos_con_tipo! t }
  end

  def leer_avisos_con_tipo!(tipo)
    page = agent.get "#{dominio}/#{tipo}-#{parametros}"
    parsear_avisos(page, tipo).compact
  end
end

module ArgenpropScraper
  class << self
    include Scraper

    def tipos
      ['ph', 'casa']
    end

    def dominio
      'https://www.argenprop.com'
    end

    def parametros
      'alquiler-region-zona-oeste-hasta-35000-pesos-1-o-m%C3%A1s-cocheras-orden-masnuevos'
    end

    def parsear_avisos(page, tipo)
      page.search('div.listing-container div.listing__item').map do |aviso|
        link = aviso.search('a').attr('href').value
        {
          id: link.split('-').last,
          tipo: tipo,
          titulo: aviso.search('h3.card__title').text.strip,
          direccion: aviso.search('h2.card__address').text.strip,
          precio: aviso.search('p.card__price').text.strip,
          url: "#{dominio}#{link}"
        }
      end
    end
  end
end

module ArgencasasScraper
  class << self
    include Scraper

    def tipos
      ['casas', 'ph', 'duplex']
    end

    def dominio
      'https://www.argencasas.com'
    end

    def parametros
      'alquiler-de-0-a-35000-pesos-cochera-gba-zona-oeste'
    end

    def parsear_avisos(page, tipo)
      page.search('.list-props-container div.kol-m-9 div.row').map do |aviso|
        article = aviso.search('article .row')
        figure = aviso.search('figure')

        link = article.search('.kol-s-10 .titulo_ficha a').attr('href').to_s

        if link.empty?
          nil
        else
          {
            id: link.split('-')[-2, 2].join,
            tipo: tipo,
            titulo: article.search('div.titulo_ficha h2').text.strip,
            direccion: article.search('div.direccion').text.strip,
            precio: figure.search('figure div.precio').text.strip,
            url: "#{dominio}#{link}"
          }
        end
      end
    end
  end
end
