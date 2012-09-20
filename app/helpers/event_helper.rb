module EventHelper

  def weekday_options
    [
      ["Monday", 1],
      ["Tuesday", 2],
      ["Wednesday", 3],
      ["Thursday", 4],
      ["Friday", 5],
      ["Saturday", 6],
      ["Sunday", 7]
    ]
  end

  def week_of_month_options
    [
      ["1st", 1],
      ["2nd", 2],
      ["3rd", 3],
      ["4th", 4],
      ["Last", -1]
    ]
  end

  def date_of_month_options
    (1..31).map { |n| [n.ordinalize, n] }
  end

end