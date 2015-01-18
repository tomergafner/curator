require 'date'

class Custodian
  def curate
    persist_reports
    create_csvs
  end

  private

  attr_reader :file, :num_to_keep

  def initialize(file:, num_to_keep:)
    @file = file
    @num_to_keep = num_to_keep
  end

  def persist_reports
    ReportCreator.new(
      data: ey_data,
      type: CompanyReportByEarningsYield
    ).create_company_reports

    ReportCreator.new(
      data: roc_data,
      type: CompanyReportByReturnOnCapital
    ).create_company_reports
  end

  def ey_data
    @ey_data ||= Sorter.new(
      data: company_data,
      metric: :earnings_yield,
      num_to_keep: num_to_keep
    ).sort_company_data
  end

  def roc_data
    @roc_data ||= Sorter.new(
      data: company_data,
      metric: :return_on_capital,
      num_to_keep: num_to_keep
    ).sort_company_data
  end

  def company_data
    @company_data ||= DataFactory.new(
      ticker_array: ticker_array
    ).make_company_hashes
  end

  def ticker_array
    ticker_file = File.open(file, "r")
    TickerExtractor.new(ticker_file: ticker_file).extract_tickers
  end

  def create_csvs
    Clerk.new(
      data: ey_data,
      file_name: "Earnings Yield #{Date.today}"
    ).create_csv

    Clerk.new(
      data: roc_data,
      file_name: "Return on Capital #{Date.today}"
    ).create_csv
  end
end
