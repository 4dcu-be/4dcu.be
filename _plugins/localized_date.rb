require 'time'
require 'date'

module Jekyll
  # Renders post dates as DD-MM-YYYY. Liquid's `date: "%B %-d, %Y"` only knows
  # English month names, which looked wrong on the Dutch pages; a numeric
  # format reads the same in both languages.
  #
  # Usage: {{ post.date | localized_date }}
  module LocalizedDateFilter
    def localized_date(input, _requested_locale = nil)
      date = coerce_to_date(input)
      return input if date.nil?

      format('%02d-%02d-%04d', date.day, date.month, date.year)
    end

    # Public rather than private: Liquid mixes filter modules into its strainer,
    # where private helpers are not reliably callable.
    def coerce_to_date(input)
      case input
      when Time, DateTime, Date
        input
      when String
        return Time.now if input == 'now'
        begin
          Time.parse(input)
        rescue ArgumentError, TypeError
          nil
        end
      else
        input.respond_to?(:to_time) ? input.to_time : nil
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::LocalizedDateFilter)
