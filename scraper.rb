require 'net/http'
require 'uri'
require 'json'
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
        id: aviso['id'].gsub('aviso-', ''),
        tipo: tipo,
        titulo: aviso.search('.post-titulo').text,
        barrio: aviso.search('.post-location span').text.gsub(', Capital Federal', ''),
        direccion: aviso.search('.post-location').text.gsub(/\n|\t/, ''),
        precio: aviso.search('.precio-valor').text.strip,
        url: 'http://www.zonaprop.com.ar' + aviso.search('.post-titulo a').attr('href').value
      }
    end
  end
end

class ResultadoDiff
  def self.solo_nuevos(resultado)
    id_viejos = begin ScraperWiki.select('id from data').map { |x| x['id']} rescue [] end
    resultado.reject { |aviso| id_viejos.include? aviso[:id] }
  end
end

class LogNotifier
  def notify!(resultado, nuevos)
    puts "Se encontraron #{resultado.size} propiedades, de las cuales #{nuevos.size} son nuevas."
  end
end

class MorphNotifier
  def notify!(resultado, nuevos)
    ScraperWiki.save_sqlite([:id], resultado)
  end
end

class TelegramNotifier
  def initialize(ifttt_key)
    @ifttt_key = ifttt_key
  end

  def notify!(resultado, nuevos)
    nuevos.each { |aviso| send_message! aviso }
  end

  def send_message!(aviso)
    post_json! "https://maker.ifttt.com/trigger/zonaprop_scraper/with/key/#{@ifttt_key}", {value1: "#{aviso[:titulo]} (#{aviso[:precio]})", value2: aviso[:direccion], value3: aviso[:url]}
  end

  def post_json!(url, data)
    uri = URI.parse(url)

    request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
    request.body = data.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    http.request(request)
  end
end

resultado = ZonaPropWebScraper.new.leer_avisos!
[LogNotifier.new, TelegramNotifier.new(ENV['MORPH_IFTTT_KEY']), MorphNotifier.new].each { |n| n.notify! resultado, ResultadoDiff.solo_nuevos(resultado) }
