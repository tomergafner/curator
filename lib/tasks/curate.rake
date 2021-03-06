desc "This task retrieves and persists all necessary data from Quandl, and adds company names"
task :curate => :environment do
  Overseer.new(ticker_file: "russell3000.txt").retrieve_and_persist_data
  NameFinder.new(file: "russell3000.txt").get_company_names
  MagicRanker.rank_reports
end
