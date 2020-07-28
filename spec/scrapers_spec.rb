# frozen_string_literal: true

require_relative '../lib/scrapers'

describe ArgenpropScraper do
  describe '#leer_avisos!', :vcr do
    let(:avisos) { ArgenpropScraper.leer_avisos! }

    it { expect(avisos[0]).to eq({ id: '7930909', tipo: 'ph', titulo: 'PH TIPO CASA :: 2 HABITACIONES :: COCHERA :: PATIO :: UNICO', direccion: 'Bouchard 3700', precio: '$ 25.000', url: 'https://www.argenprop.com/ph-en-alquiler-en-caseros-3-ambientes--7930909' }) }
  end
end

describe ArgencasasScraper do
  describe '#leer_avisos!', :vcr do
    let(:avisos) { ArgencasasScraper.leer_avisos! }

    it { expect(avisos[0]).to eq({ id: '154237', tipo: 'casas', titulo: 'En zona com/res de Moreno Sur GBA Zona Oeste alquiler de casa de estilo clasico', direccion: 'Hipólito Yrigoyen al 0 - Moreno Sur GBA Zona Oeste', precio: '$ 26.000', url: 'https://www.argencasas.com/propiedad-casa-alquiler-moreno-sur-154-237' }) }
  end
end
