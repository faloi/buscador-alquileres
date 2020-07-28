require 'net/http'
require 'uri'
require 'json'
require 'scraperwiki'
require 'ostruct'
require 'active_support/all'

require_relative './lib/scrapers'

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
    post_json! "https://maker.ifttt.com/trigger/zonaprop_scraper/with/key/#{@ifttt_key}", {value1: aviso[:titulo], value2: "#{aviso[:precio]} - #{aviso[:direccion]}", value3: aviso[:url]}
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

resultado = [ArgenpropScraper, ArgencasasScraper].flat_map(&:leer_avisos!)
[LogNotifier.new, TelegramNotifier.new(ENV['MORPH_IFTTT_KEY']), MorphNotifier.new].each { |n| n.notify! resultado, ResultadoDiff.solo_nuevos(resultado) }
