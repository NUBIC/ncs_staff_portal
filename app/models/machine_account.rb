require 'forwardable'

##
# {Staff}-like representations of machine accounts.  See
# {Aker::Authorities::MachineAccount} for more information.
class MachineAccount
  extend Forwardable

  ##
  # The underlying {Aker::User} object.
  attr_reader :aker_user

  ##
  # {Role} objects derived from {#aker_user}.
  attr_reader :roles

  def_delegators :aker_user, :identifiers, :username

  def self.find_by_username(username)
    first_matching(username)
  end

  def self.find_by_numeric_id(id)
    first_matching(:identifiers => { :numeric_id => id, :machine_account => true })
  end

  ##
  # Polls the Aker authority for machine accounts.
  def self.first_matching(*criteria)
    users = Aker.authority.find_users(*criteria)
    user = users.detect { |u| u.identifiers[:machine_account] }

    new(user) if user
  end

  def initialize(aker_user)
    @aker_user = aker_user

    reify_roles
  end

  ##
  # A machine account that is a staff supervisor can see all staff members.
  # Other machine accounts may only see themselves.
  def can_see_staff?(staff)
    role_names.include?(Roles::STAFF_SUPERVISOR) || staff.username == username
  end

  def role_names
    roles.map(&:name)
  end

  ##
  # Converts group data from {#aker_user} into {Role} objects.
  def reify_roles(portal = Aker.configuration.portal)
    names = aker_user.group_memberships(portal).map(&:group_name)

    @roles = Role.where(:name => names)
  end

  def numeric_id
    identifiers[:numeric_id]
  end

  ##
  # The ID of the machine account is its numeric ID.
  alias_method :id, :numeric_id

  ##
  # Machine accounts are always active.
  def is_active
    true
  end

  ##
  # The JSON representation for a machine account.
  def as_json(options = nil)
    {
      'machine_account' => true,
      'numeric_id' => id,
      'roles' => roles.map { |r| { 'name' => r.name } },
      'username' => username
    }
  end
end
