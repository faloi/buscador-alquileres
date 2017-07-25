require 'scraperwiki'
require 'mechanize'
require 'ostruct'
require 'active_support/all'

class ZonaPropWebScraper
  def initialize
    @agent = Mechanize.new
  end

  def leer_avisos!
    leer_avisos_con_tipo!('ph') + leer_avisos_con_tipo!('casas')
  end

  def leer_avisos_con_tipo!(tipo)
    page = @agent.get "http://www.zonaprop.com.ar/#{tipo}-alquiler-almagro-boedo-caballito-flores-parque-chacabuco-villa-crespo-4-ambientes.html"

    page.search('li.post').map do |aviso|
      {
        :id => aviso['id'].gsub('aviso-', ''),
        :tipo => tipo,
        :titulo => aviso.search('.post-titulo').text,
        :barrio => aviso.search('.post-location span').text.gsub(', Capital Federal', ''),
        :direccion => aviso.search('.post-location').text.gsub(/\n|\t/, ''),
        :precio => aviso.search('.precio-valor').text.strip,
        :url => 'http://www.zonaprop.com.ar' + aviso.search('.post-titulo a').attr('href').value
      }
    end
  end
end

class MorphNotifier
  def notify!(resultado)
    ScraperWiki.save_sqlite([:id], resultado)
  end
end

resultado = ZonaPropWebScraper.new.leer_avisos!
[MorphNotifier.new].each { |n| n.notify! resultado }
