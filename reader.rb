#! /usr/bin/env ruby

require 'csv'
require 'mechanize'
require 'optparse'
require 'date'
require 'pp'

URL = "http://www.surveymonkey.com/s/UserEdFY15"


class Survey
  URL = "http://www.surveymonkey.com/s/UserEdFY15"


  def initialize
    @agent ||= Mechanize.new
  end

end


def parse_date(date)
  parts = date.split('/')
  @month = "%02d" % parts[0]
  @day   = "%02d" % parts[1]
  @year  = "%04d" % (parts[2].to_i + 2000)
end

def explode_instructors(instructors)
  people = instructors.split(',')
  #TODO map co-instructors to field
  pp people[0]
end

file = "consultations.csv"

@agent ||= Mechanize.new


consultations = CSV.foreach(file, :headers => true) do |row|
  unless row['processed'] == true
    @id_field    = "text_663167644_0"
    @co_instructor_1_field = "text_663175496_7751542265"
    @co_instructor_2_field = "text_663175496_7751542266"
    @co_instructor_3_field = "text_663175496_7751542266"

    parse_date(row['date'])
    explode_instructors(row['instructor_ids']) unless row['instructor_ids'] == nil

    @agent.get(URL) do |form|
        form["date_663167643_7654357724_mm"]   = @month
        form["date_663167643_7654357724_dd"]   = @day
        form["date_663167643_7654357724_yyyy"] = @year
        form["text_663167644_0"]               = row['uva_id']

        unless row['instructor_ids'].nil?
          #TODO finish this
          form["text_663175496_7751542265"]     = row['instructor_ids'].split(',')[0]
          form["text_663175496_7751542266"]     = row['instructor_ids'].split(',')[0]
          form["text_663175496_7751542267"]     = row['instructor_ids'].split(',')[0]
        end

        form["input_663167645_50_7654527096_7654527097"] = row['unit'] # 7654527100 is Scholars' Lab
        


    end
  end
end


