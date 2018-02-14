class CanCreateNewDreamValidator < ActiveModel::Validator
  def validate(record)
    if Rails.application.config.x.firestarter_settings['disable_open_new_dream']
      record.errors[:base] << I18n.t("new_dream_is_disabled")
    end
  end
end

class Camp < ActiveRecord::Base
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :images #, :dependent => :destroy
  has_many :grants
  has_many :people, class_name: 'Person'
  has_many :roles, through: :people

  has_paper_trail
  
  accepts_nested_attributes_for :people, :roles, allow_destroy: true

  validates :creator, presence: true
  validates :name, presence: true
  validates :subtitle, presence: true
  validates :contact_name, presence: true
  validates :minbudget, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :minbudget_realcurrency, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :maxbudget, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates :maxbudget_realcurrency, :numericality => { :greater_than_or_equal_to => 0 }, allow_blank: true
  validates_with CanCreateNewDreamValidator, :on => :create

  # This directive enables Filterrific for the Article class.
  # We define a default sorting by most recent sign up, and then
  # we make a number of filters available through Filterrific.
  filterrific(
      default_filter_params: { sorted_by: 'created_at_desc' },
      available_filters: [
          :sorted_by,
          :search_query
      ]
  )

  # Scope definitions. We implement all Filterrific filters through ActiveRecord
  # scopes. In this example we omit the implementation of the scopes for brevity.
  # Please see 'Scope patterns' for scope implementation details.
  scope :search_query, lambda { |query|
    # Searches the articles table on the 'title' and 'text' columns.
    # Matches using LIKE, automatically appends '%' to each term.
    # LIKE is case INsensitive with MySQL, however it is case
    # sensitive with PostGreSQL. To make it work in both worlds,
    # we downcase everything.
    return nil  if query.blank?

    # TODO: remove
    puts "### camp.rb > search_query > query: " + query

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)

    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 2
    where(
        terms.map { |term|
          "(LOWER(camps.name) LIKE ? OR LOWER(camps.subtitle) LIKE ?)"
        }.join(' AND '),
        *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'

    # TODO: remove
    puts "### camp.rb > sorted_by > sort_option: " + sort_option

    case sort_option.to_s
      when /^created_at_/
        # Simple sort on the created_at column.
        # Make sure to include the table name to avoid ambiguous column names.
        # Joining on other tables is quite common in Filterrific, and almost
        # every ActiveRecord table has a 'created_at' column.
        order("camps.created_at #{ direction }")
      when /^name_/
        # Simple sort on the name colums
        order("LOWER(camps.name) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  # This method provides select options for the `sorted_by` filter select input.
  # It is called in the controller as part of `initialize_filterrific`.
  def self.options_for_sorted_by
    [
        ['Name (a-z)', 'name_asc'],
        ['Creation date (newest first)', 'created_at_desc'],
        ['Creation date (oldest first)', 'created_at_asc']
    ]
  end

  scope :not_fully_funded, lambda { |flag|
    return nil  if '0' == flag # checkbox unchecked
    where(fullyfunded: false)
  }

  scope :not_min_funded, lambda { |flag|
    return nil  if '0' == flag # checkbox unchecked
    where(minfunded: false)
  }

  scope :not_seeking_funding, lambda { |flag|
    return nil  if '0' == flag # checkbox unchecked
    where(grantingtoggle: true)
  }

  scope :active, lambda { |flag|
    where(active: true)
  }

  scope :not_hidden, lambda { |flag|
    where(is_public: flag)
  }

  scope :is_cocreation, lambda { |flag|
    where.not(camps: { cocreation: nil }).where.not(camps: { cocreation: '' })
  }

  scope :is_current_event, lambda { |flag|
    where(camps: { event_id: Rails.application.config.default_event })
  }

  scope :is_old_event, lambda { |flag|
    where.not(camps: { event_id: Rails.application.config.default_event })
  }

  before_save do
    align_budget
  end


  def grants_received
    return self.grants.sum(:amount)
  end

  # Translating the real currency to budget
  # This called on create and on update
  # Rounding up 0.1 = 1, 1.2 = 2
  def align_budget
    if self.minbudget_realcurrency.nil?
      self.minbudget = nil
    elsif self.minbudget_realcurrency > 0
      self.minbudget = (self.minbudget_realcurrency / Rails.application.config.coin_rate).ceil
    else
      self.minbudget = 0
    end

    if self.maxbudget_realcurrency.nil?
      self.maxbudget = nil
    elsif self.maxbudget_realcurrency > 0
      self.maxbudget = (self.maxbudget_realcurrency / Rails.application.config.coin_rate).ceil
    else
      self.maxbudget = 0
    end
  end
end
