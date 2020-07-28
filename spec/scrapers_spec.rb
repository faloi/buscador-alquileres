require_relative '../lib/scrapers'

# describe ArgenpropScraper do
#   describe '#leer_avisos!' do
#     let(:avisos) { ArgenpropScraper.leer_avisos! }

#     it { expect(avisos).to eq [] }
#   end
# end

describe ArgencasasScraper do
  describe '#leer_avisos!' do
    let(:avisos) { ArgencasasScraper.leer_avisos! }

    it { expect(avisos).to eq [] }
  end
end
