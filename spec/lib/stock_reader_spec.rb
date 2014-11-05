require 'spec_helper'
require 'stock_reader'
require 'sample_data'

RSpec.describe StockReader do

  describe '.extract_tickers' do
    it 'returns a correct array of ticker symbols' do
      test_file = File.open("test_file.txt", "w")
      File.readlines("russell3000.txt").take(4).each { |line| test_file.write(line) }
      test_file.rewind
      expected = ['FLWS', 'SRCE', 'FUBC', 'FOXA']
      expect(StockReader.extract_tickers(test_file)).to eq(expected)
      File.delete("test_file.txt")
    end
  end

  describe '.data_exists?' do
    it 'checks whether each response is empty' do
      ticker = 'AAPL'
      ebit_response       = HTTParty.get("https://www.quandl.com/api/v1/datasets/SF1/#{ticker}_EBIT_MRQ.json?rows=1&auth_token=#{ENV['QUANDL_AUTH_TOKEN']}")
      market_cap_response = HTTParty.get("https://www.quandl.com/api/v1/datasets/SF1/#{ticker}_MARKETCAP.json?rows=1&auth_token=#{ENV['QUANDL_AUTH_TOKEN']}")
      cash_response       = HTTParty.get("https://www.quandl.com/api/v1/datasets/SF1/#{ticker}_CASHNEQ_MRQ.json?rows=1&auth_token=#{ENV['QUANDL_AUTH_TOKEN']}")
      debt_response       = HTTParty.get("https://www.quandl.com/api/v1/datasets/SF1/#{ticker}_DEBT_MRQ.json?rows=1&auth_token=#{ENV['QUANDL_AUTH_TOKEN']}")
      actual = StockReader.data_exists?([ebit_response, market_cap_response, cash_response, debt_response])
      expect(actual).to be(true)
    end
  end

  describe '.get_earnings_yield' do
    it 'returns accurate data' do
      test_ticker = 'AAPL'
      actual = StockReader.get_earnings_yield(test_ticker)
      expect(actual).to eq(earnings_yield_data_1)
    end
  end

  describe '.get_return_on_capital_data' do
    it 'retrieves data' do
      ticker = 'AAPL'
      roc_data = StockReader.get_return_on_capital_data(ticker)
      expect(roc_data[:total_assets]["data"].flatten[1]).to be_kind_of(Float)
      expect(roc_data[:current_assets]["data"].flatten[1]).to be_kind_of(Float)
      expect(roc_data[:working_capital]["data"].flatten[1]).to be_kind_of(Float)
    end
  end

  describe '.get_return_on_capital' do
    it 'returns accurate data' do
      test_ticker = 'AAPL'
      actual = StockReader.get_return_on_capital(test_ticker)
      expect(actual).to eq(return_on_capital_data_1)
    end
  end

  describe '.retrieve_data' do
    it 'returns an array of combined hashes' do
      ticker_array = ['AAPL']
      actual = StockReader.retrieve_data(ticker_array)
      expected = [return_on_capital_data_1.merge(earnings_yield_data_1)]
      expect(actual).to eq(expected)
    end
  end

  describe '.sort_company_data' do
    it 'sorts by the given metric' do
      company_data = [earnings_yield_data_1, earnings_yield_data_2]
      actual = StockReader.sort_company_data(company_data, :earnings_yield, 30)
      expect(actual).to eq(company_data.reverse)
    end
  end

  describe '.create_company_reports' do
    before(:all) do
      CompanyReportByEarningsYield.delete_all
      CompanyReportByReturnOnCapital.delete_all
    end

    it 'creates earnings yield reports' do
      earnings_yield_array = [earnings_yield_data_1, earnings_yield_data_2]
      StockReader.create_company_reports(earnings_yield_array, CompanyReportByEarningsYield)
      expect(CompanyReportByEarningsYield.count).to eq(2)
    end

    it 'creates return on capital reports' do
      return_on_capital_array = [return_on_capital_data_1, return_on_capital_data_2]
      StockReader.create_company_reports(return_on_capital_array, CompanyReportByReturnOnCapital)
      expect(CompanyReportByReturnOnCapital.count).to eq(2)
    end
  end

  describe '.create_csv' do
    it 'creates csv files' do
      return_on_capital_array = [return_on_capital_data_1, return_on_capital_data_2]
      StockReader.create_csv(return_on_capital_array, "company_report")
      expect(File.file?("company_report.csv")).to be(true)
    end
    after(:all) do
      File.delete("company_report.csv")
    end
  end
end
