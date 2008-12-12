# This is a tabless implementation of an ActiveRecord model, which will allow
# us to do validation without creating a table in our DB.
#
# For example, our contact form model will inherit from this.
#
# /Dave

class Tableless < ActiveRecord::Base
  def self.columns()
    @columns ||= [];
  end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  # Override save, since we have no table
  def save(validate = true)
    validate ? valid? : true
  end
end