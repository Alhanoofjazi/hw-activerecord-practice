require 'sqlite3'
require 'active_record'
require 'byebug'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'customers.sqlite3')
# Show queries in the console.
# Comment this line to turn off seeing the raw SQL queries.
ActiveRecord::Base.logger = Logger.new($stdout)

# Normally a separate file in a Rails app.
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Customer < ApplicationRecord
  def to_s
    "  [#{id}] #{first} #{last}, <#{email}>, #{birthdate.strftime('%Y-%m-%d')}"
  end

  #  NOTE: Every one of these can be solved entirely by ActiveRecord calls.
  #  You should NOT need to call Ruby library functions for sorting, filtering, etc.

  def self.any_candice
    Customer.where(first: 'Candice')
  end

  def self.with_valid_email
    Customer.where('email like "%@%"')
  end

  def self.with_dot_org_email
    Customer.where('email like "%.org"')
  end

  def self.with_invalid_email
    Customer.where('email NOT like "%@%"').where('email NOT like ""')
  end

  def self.with_blank_email
    Customer.where(email: nil)
  end

  def self.born_before_1980
    Customer.where("birthdate < ?", Date.new(1980, 1, 1))
  end

  def self.with_valid_email_and_born_before_1980
    Customer.where('email like "%@%"').where("birthdate < ?", Date.new(1980, 1, 1))
  end

  def self.last_names_starting_with_b
    b = Customer.where('last like "b%"')
    b.order(:birthdate)
  end

  def self.twenty_youngest
    ordered = Customer.order(birthdate: :desc)
    ordered.limit(20)
  end

  def self.update_gussie_murray_birthdate
    murray = find_by(first: 'Gussie', last: 'Murray')
    murray.birthdate = Time.parse('2004-02-08')
    murray.save
  end

  def self.change_all_invalid_emails_to_blank
    invalid = Customer.where('email NOT like "%@%"').where('email NOT like ""')
    invalid.each do |i|
      i.email = nil
      i.save
    end
  end

  def self.delete_meggie_herman
    maggie = find_by(first: 'Meggie', last: 'Herman')
    maggie.destroy
  end

  def self.delete_everyone_born_before_1978
    customers = Customer.where("birthdate < ?", Date.new(1978, 1, 1))
    customers.each do |c|
      c.destroy
    end
  end
end
