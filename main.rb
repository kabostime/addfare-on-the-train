#encoding: utf-8
require 'csv'
require 'optparse'
require 'mechanize'

class StationNotFoundError < StandardError
end

class Request
	attr_reader :from, :to, :month, :day, :hour, :min

	def initialize from, to, date=nil
		@from = from
		@to = to
		
		if date
			now = Time.at(date)
		else
			now = Time.now
		end
		@month = now.month
		@day = now.day
		@hour = now.hour
		@min = now.min
	end
end

class AddfareRequestService
	BASE_URL = 'http://www.navitime.co.jp/transfer/search'

	FROM_PARAM = 'orvStationName'
	TO_PARAM = 'dnvStationName'
	MONTH_PARAM = 'month'
	DAY_PARAM = 'day'
	HOUR_PARAM = 'hour'
	MINUTE_PARAM = 'minute'
	SORT_PARAM = 'sort'
	BASIS_PARAM = 'basis' #出発or到着

	SORT_VALUES = { :time => 0, :cost => 1, :count =>2 }
	BASIS_VALUES = { :go => 0, :arrival => 0, :first =>4 , :last => 3}

	DEFAULT_SORT_VALUE = SORT_VALUES[:cost]
	DEFAULT_BASIS_VALUE = SORT_VALUES[:go]

	def initialize 
		@agent = Mechanize.new do |agent|
			agent.user_agent_alias = 'Windows Chrome'
		end
	end

	def get request
		params = {
			FROM_PARAM => request.from,
			TO_PARAM => request.to,
			MONTH_PARAM => request.month,
			DAY_PARAM =>request.day,
			HOUR_PARAM => request.hour,
			MINUTE_PARAM =>request.min,
			SORT_PARAM => DEFAULT_SORT_VALUE,
			BASIS_PARAM => DEFAULT_BASIS_VALUE,
		}
		addfare = 0
		@agent.get(BASE_URL, params) do |page|
			raise StationNotFoundError if page.body.force_encoding('UTF-8')['お探しの駅が見つかりませんでした']

			addfare = page.search('//*[@id="routesum_frame"]/div/div[1]/div[3]/div[2]/span').text[0..-2].to_i
		end
		addfare
	end
end

class AddfareOnTheTrainApplication
		SLEEP_INTERVAL = 1 # [sec]

	def initialize args
		raise RuntimeError.new unless args[0]

		@date = Time.now
		@sleep_interval = SLEEP_INTERVAL

		parser = OptionParser.new do |parser|
			parser.accept(Time) do |s, |
				begin
					Time.parse(s) if s
				rescue
					raise OptionParser::InvalidArgument, s
				end
			end
		end

		parser.on('-f', '--file CSV_FILE', '精算する駅を列挙したCSVファイルのパス') {|v| @csv_file_name = v }
		parser.on('-d', '--date DATE', Time, '乗車日時(YYYY-mm-dd HH:MM形式)') {|v| @date = v }
		parser.parse!(args)
	end

	def execute
		service = AddfareRequestService.new
		csv = CSV.open(@csv_file_name)

		begin
			addfares = csv.map do |route|
				request = Request.new(route[0], route[1], @date)
				addfare = service.get request

				p "#{request.from} - #{request.to}間: #{addfare}円"

				sleep @sleep_interval
				addfare
			end

			p "トータル: #{addfares.inject(:+)}円"
		ensure
			csv.close
		end
	end
end

begin
	AddfareOnTheTrainApplication.new(ARGV).execute
rescue RuntimeError => e 
	p e.to_s 
end
