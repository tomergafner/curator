class DataFetcher
  attr_reader :ticker, :query_hash

  BASE_URL = "https://www.quandl.com/api/v1/datasets/SF1/"

  def initialize(ticker:, query_hash:)
    @ticker = ticker
    @query_hash = query_hash
  end

  def get_company_data
    data_responses = {}
    query_hash.each do |metric, quandl_query|
      data_responses[metric] = HTTParty.get(BASE_URL + "#{ticker}_#{quandl_query}.json?rows=1&auth_token=#{ENV['QUANDL_AUTH_TOKEN']}")
      if data_responses[metric]['error']
        puts "#{ticker} ----- " + data_responses[metric]['error']
      elsif data_responses[metric]['errors'] && !data_responses[metric]['errors'].empty?
        puts "#{ticker} ----- " + data_responses[metric]['errors']
      end
    end
    data_responses
  end
end
