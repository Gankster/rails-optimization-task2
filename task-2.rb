# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require_relative 'models/user'
require_relative 'models/session'

DEFAULT_FILE = 'files/data.txt'.freeze
USER = 'user'
SEPARATOR = ','

def write_to_file(result_file, user)
  result_file.write(user.to_json.sub!('{', '').chomp!('}'))
end

def work(filename: '', disable_gc: false)
  GC.disable if disable_gc

  file_name = ENV['DATA_FILE'] || filename || DEFAULT_FILE
  session = nil
  user = nil
  unique_browsers = {}
  report = {
    totalUsers: 0,
    totalSessions: 0
  }

  result_file = File.open('result.json', 'w')
  result_file.write '{"usersStats":{'

  File.foreach(file_name) do |line|
    cols = line.chomp!.split(SEPARATOR)

    if line.start_with?(USER)
      if user
        write_to_file(result_file, user)
        result_file.write(SEPARATOR)
      end

      user = User.new(*cols[1..3])
      report[:totalUsers] += 1
    else
      session = Session.new(*cols[1..5])

      unique_browsers[session.browser] = nil
      report[:totalSessions] += 1
      user.update_stats(session)
    end
  end

  write_to_file(result_file, user) if user
  result_file.write('},')

  browsers = unique_browsers.keys.sort!

  report[:uniqueBrowsersCount] = browsers.count
  report[:allBrowsers] = browsers.join(SEPARATOR)

  result_file.write(report.to_json.sub!('{', ''))
  result_file.write("\n")
  result_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('files/data.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work(filename: 'files/data.txt')
    expected_result = '{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},"totalUsers":3,"totalSessions":15,"uniqueBrowsersCount":14,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
