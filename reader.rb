#! /usr/bin/env ruby

require 'csv'
require 'mechanize'
require 'optparse'
require 'date'
require 'pp'

URL = "http://www.surveymonkey.com/s/UserEdFY15"

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
@csv_out = CSV.open('new.csv', 'wb')
@csv_out << %w(date	uva_id instructor_ids unit schools session_type count course_number location notes processed) # add headers

@agent ||= Mechanize.new
@agent.user_agent_alias = "Mac Safari"

CSV.foreach(file, :headers => true) do |row|
  if row['processed'].nil?
    pp row['processed']
    parse_date(row['date'])
    explode_instructors(row['instructor_ids']) unless row['instructor_ids'].nil?

    @agent.get(URL) do |page|

        form = page.form('frmS')

        form["date_663167643_7654357724_mm"]   = @month
        form["date_663167643_7654357724_dd"]   = @day
        form["date_663167643_7654357724_yyyy"] = @year
        form["text_663167644_0"]               = row['uva_id']

        unless row['instructor_ids'].nil?
          #TODO finish this
          form["text_663175496_7751542265"]     = row['instructor_ids'].split(',')[0]
          form["text_663175496_7751542266"]     = row['instructor_ids'].split(',')[1]
          form["text_663175496_7751542267"]     = row['instructor_ids'].split(',')[2]
        end

        unit_options    = form.field_with(:name => "input_663167645_50_7654527096_7654527097")
        school_options  = form.field_with(:name => "input_663167653_50_7654544578_7654544579")
        session_options = form.field_with(:name => "input_663167649_50_7654538337_7654538338")

        # TODO Make these validate
        unit_value    = unit_options.options_with(:text => row['unit'])
        school_value  = school_options.options_with(:text => row['schools'])
        session_value = session_options.options_with(:text => row['session_type'])

        form["input_663167645_50_7654527096_7654527097"] = unit_value
        form["input_663167653_50_7654544578_7654544579"] = school_value
        form["input_663167649_50_7654538337_7654538338"] = session_value

        form["text_663167650_7654917885"]                = row['count']
        form["text_663167646_0"]                         = row['course'] unless row['course'].nil?
        form["text_663167652_0"]                         = row['notes']

        form.submit
        #pp submission
        # Save the form
    end


    row['processed'] = true

   end

   @csv_out << row
end

# Hack; just rename the file
File.rename("new.csv", "consultations.csv")


class Survey
  URL = "http://www.surveymonkey.com/s/UserEdFY15"


  def initialize
    @agent ||= Mechanize.new
  end

end
