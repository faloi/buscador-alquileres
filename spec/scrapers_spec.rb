require_relative '../lib/zonaprop_scraper'

describe ArgenpropScraper do
  describe '#leer_avisos!' do
    let(:avisos) { ArgenpropScraper.leer_avisos_con_tipo!('casa') }

    it { expect(avisos).to eq [] }
  end
end
