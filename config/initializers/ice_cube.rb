module IceCube
  class Rule
    def self.from_ical ical
      params = {:validations => {}}
      
      ical.split(';').each do |rule|
        (name, value) = rule.split('=')
        case name
        when 'FREQ'
          params[:freq] = value.downcase
        when 'INTERVAL'
          params[:interval] = value.to_i
        when 'COUNT'
          params[:count] = value.to_i
        when 'UNTIL'
          params[:until] = DateTime.parse(value).to_time.utc
          
        when 'BYSECOND'
          params[:validations][:second_of_minute] = value.split(',').collect{ |v| v.to_i }
        when "BYMINUTE"
          params[:validations][:minute_of_hour] = value.split(',').collect{ |v| v.to_i }
        when "BYHOUR"
          params[:validations][:hour_of_day] = value.split(',').collect{ |v| v.to_i }
        when "BYDAY"
          dows = {}
          days = []
          value.split(',').each do |expr|
              day = TimeUtil.ical_day_to_symbol(expr.strip[-2..-1])
              if expr.strip.length > 2  # day with occurence
                occ = expr[0..-3].to_i 
                dows[day].nil? ? dows[day] = [occ] : dows[day].push(occ)
                days.delete(TimeUtil.symbol_to_day(day))
              else
                days.push TimeUtil.symbol_to_day(day) if dows[day].nil?
              end
          end
          params[:validations][:day_of_week] = dows unless dows.empty?
          params[:validations][:day] = days unless days.empty?
        when "BYMONTHDAY"
          params[:validations][:day_of_month] = value.split(',').collect{ |v| v.to_i }
        when "BYMONTH"
          params[:validations][:month_of_year] = value.split(',').collect{ |v| v.to_i }
        when "BYYEARDAY"
          params[:validations][:day_of_year] = value.split(',').collect{ |v| v.to_i }
          
        else
          raise "Invalid or unsupported rrule command : #{name}"
        end
      end
      
      rule = IceCube::Rule.send(params[:freq], params[:interval] || 1)
      rule.count(params[:count]) if params[:count]
      rule.until(params[:until]) if params[:until]
      params[:validations].each do |key, value|
        value.is_a?(Array) ? rule.send(key, *value) : rule.send(key, value)
      end

      rule
    end

  end
  
  module TimeUtil

    ICAL_DAYS = {
      'SU' => :sunday, 'MO' => :monday, 'TU' => :tuesday, 'WE' => :wednesday,
      'TH' => :thursday, 'FR' => :friday, 'SA' => :saturday
    }

    def self.ical_day_to_symbol(str)
      day = ICAL_DAYS[str]
      raise "No such day: #{str}" if day.nil?
      day
    end
    
    # Serialize a time appropriate for storing
    def self.serialize_time(time)
      t = time.to_s
      Time.parse(t).utc
    end

    # Deserialize a time serialized with serialize_time
    def self.deserialize_time(time)
      time = time[:time] if time.is_a? Hash
      time.in_time_zone Time.zone
    end
    
  end
end

module Icalendar
  class Parser < Icalendar::Base
    # Dates, Date-Times & Times
    # NOTE: icalendar's datetime parser sucks compared to Rails. So let's defer to Rails.
    def parse_datetime(name, params, value)
      Time.parse value
    end
  end
end
